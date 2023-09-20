/**
@author Team STARK
@owner Team STARK
@name UTIL_AccountAddressStandardization
@createDate 05/31/2020
@modifiedDate 
@description This class is used by LWC Account components to leverage the existing account address standardization callout
@version 1.0
*/
public with sharing class UTIL_AccountAddressStandardization {

    @TestVisible 
    private static IDAO_AccountCreateEditHelper helperDAOInstance = new UTIL_AccountCreateEditHelper();

    private static String changeDescription = UTIL_Constants.NO_SPACE;
    private static Boolean isBillingUpdate = false;
    private static Boolean isShippingUpdate = false;
    private static User loggedInUser = helperDAOInstance.getLoggedInUser();

  
    private static final String CLASS_NAME = 'UTIL_AccountAddressStandardization';
   
    private static final String ADDRESS_STD_CALLBACK_METHOD = 'processAddrStdResponse';
   

    private static final String VALIDATE_ADDRESS = 'validateAddress';
    private static final String INVOKE_ADD_STD_CONTINUATION = 'invokeAddStdContinuation';
    private static final String CREATE_TASK_ON_ADDRESS_CHANGED = 'createTaskOnAddressChanged';

    /**
    * @description This method is used to validate Address and call Address standardization service
    * @name : validateAddress
    * @param addressJSON : input address values in json format
    * @return Object : output response received through service
    */
    @AuraEnabled(continuation=true cacheable=true)
    public static Object validateAddress(String addressJSON) {
        Object returnObj = null;
        try{
            returnObj = invokeAddStdContinuation(addressJSON);
        }
        catch (Exception e){
            LoggingService.logHandledException(e, CLASS_NAME, VALIDATE_ADDRESS, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('deserialization error ' + e.getMessage());
        }
        return returnObj;
    }
    
    /**
    * @description This method is used to invoke Address standardization service
    * @name : invokeAddStdContinuation
    * @param addressJSON : input address values in json format
    * @return Object : output response received through service
    */
    @AuraEnabled(continuation=true)
    public static Object invokeAddStdContinuation(String addressJSON) {
        Continuation con = new Continuation(120);
        con.continuationMethod = ADDRESS_STD_CALLBACK_METHOD;
        HttpRequest httpReq = new HttpRequest();
        try{
            UTIL_AccountCreateEdit_Additional.httpAddrStdHeader(httpReq);
            String reqBody = UTIL_CreateCustomerConstants.EMPTY_STRING;
            httpReq.setMethod(UTIL_CreateCustomerConstants.POST);
            reqBody = HLPR_AddrStdAggtReq.getCustAddrStdReq(addressJSON, loggedInUser);
            httpReq.setBody(reqBody);
            System.debug(LoggingLevel.INFO, 'Aggt Addr Std request -->'+httpReq.getBody());
            con.state = helperDAOInstance.getContinuationState(con,httpReq);
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, INVOKE_ADD_STD_CONTINUATION, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('invokeAddStdContinuation Error ' + e.getMessage());
        }
        return con;
    }
    
    /**
    * @description This method is used to get address standardization response from service
    * @name : processAddrStdResponse
    * @param labels : input from service in form of list of labels - httpresponse
    * @param state : input from service as state
    * @return Object : output response from service in form of json
    */
    @AuraEnabled
    public static Object processAddrStdResponse(List<String> labels, Object state) {
        HttpResponse addStdresponse;
        AP_AddrStdAggtRes addrAggtRes;
        String errMsg;
        try {
            addStdresponse = helperDAOInstance.getContinuationResponse(labels[0]);
            System.debug(LoggingLevel.INFO, 'Aggt Addr Std response -->'+addStdresponse.getBody());
            switch on addStdresponse.getStatusCode() {
                when 200, 201 {
                    addrAggtRes = AP_AddrStdAggtRes.parse(addStdresponse.getBody());
                }
                when 2000, 2001, 2002, 2003, 2004 {  //callout exception
                    errMsg = 'Callout Exception: The address standardization cannot be verified at this time. You may continue saving without verification.';
                    throw new AccountCreateEditException('processAddrStdResponse Error ' +addStdresponse);
                }
                when 401, 403, 404, 500 { //address standardization service exception
                    errMsg = 'Service Exception: The address standardization cannot be verified at this time. You may continue saving without verification.';
                	throw new AccountCreateEditException('processAddrStdResponse Error ' +addStdresponse);
                }
                when else {
                    errMsg = 'General Exception: The address standardization cannot be verified at this time. You may continue saving without verification.';
                    throw new AccountCreateEditException('processAddrStdResponse Error ' +addStdresponse);
                }
            }
        } 
        catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, ADDRESS_STD_CALLBACK_METHOD, System.LoggingLevel.ERROR);
            throw e;
        }
        return JSON.serialize(addrAggtRes);
    }

    /**
    * @description This method is used to create case and task when address is changed
    * @name : createTaskOnAddressChanged
    * @param oldAccount : old Account
    * @param accountId : new Account Id
    */
    @AuraEnabled
    public static void createTaskOnAddressChanged(String oldAccount, String accountId) {
        try {
            checkForAddressUpdate(oldAccount, accountId);
            if(isBillingUpdate || isShippingUpdate) {
                UTIL_ChangeofAddressProcess.assignCaseAndTaskForAddressChange(accountId, changeDescription);
            }
        }
        catch(exception exp) {
            LoggingService.logHandledException(exp, CLASS_NAME, CREATE_TASK_ON_ADDRESS_CHANGED, System.LoggingLevel.ERROR);
        }
    }

    private static void checkForAddressUpdate(String oldAccount, String accountId) {
        Account oldCustomer = (Account) JSON.deserializeStrict(oldAccount, Account.class);
        Account newCustomer = helperDAOInstance.getAccountDetails(accountId);
        isBillingUpdate = checkForBillingUpdate(oldCustomer,newCustomer);
        isShippingUpdate = checkForShippingUpdate(oldCustomer,newCustomer);
    }

    private static Boolean checkForBillingUpdate(Account oldCustomer, Account newCustomer) {
        Boolean changed = valueChanged(newCustomer.BillingCity, oldCustomer.BillingCity) 
                       || valueChanged(newCustomer.BillingState, oldCustomer.BillingState) 
                       || valueChanged(newCustomer.BillingPostalCode, oldCustomer.BillingPostalCode) 
                       || valueChanged(newCustomer.BillingCountry, oldCustomer.BillingCountry) 
                       || valueChanged(newCustomer.MailingInCareOf__c, oldCustomer.MailingInCareOf__c) 
                       || valueChanged(newCustomer.MailingAttention__c, oldCustomer.MailingAttention__c)
                       || valueChanged(newCustomer.BillingStreet, oldCustomer.BillingStreet);
        if(changed) {
            Map<String,String> oldAddressJSON = new Map<String,String>{
                    'addressLabel'=>'Old Mailing','address1'=>oldCustomer.BillingStreet,
                    'city'=>oldCustomer.BillingCity,'state'=>oldCustomer.BillingState,
                    'zip'=>oldCustomer.BillingPostalCode,'country'=>oldCustomer.BillingCountry,
                    'inCareOf'=>oldCustomer.MailingInCareOf__c,'attention'=>oldCustomer.MailingAttention__c
                };

            Map<String,String> newAddressJSON = new Map<String,String>{
                    'addressLabel'=>'New Mailing','address1'=>newCustomer.BillingStreet,
                    'city'=>newCustomer.BillingCity,'state'=>newCustomer.BillingState,
                    'zip'=>newCustomer.BillingPostalCode,'country'=>newCustomer.BillingCountry,
                    'inCareOf'=>newCustomer.MailingInCareOf__c,'attention'=>newCustomer.MailingAttention__c
                };
            appendToChangeDescription(JSON.serialize(oldAddressJSON));
            appendToChangeDescription(JSON.serialize(newAddressJSON));
        }
        return changed;
    }

    private static Boolean checkForShippingUpdate(Account oldCustomer, Account newCustomer) {
        Boolean changed = valueChanged(newCustomer.ShippingCity, oldCustomer.ShippingCity) 
                       || valueChanged(newCustomer.ShippingState, oldCustomer.ShippingState) 
                       || valueChanged(newCustomer.ShippingPostalCode, oldCustomer.ShippingPostalCode) 
                       || valueChanged(newCustomer.ShippingCountry, oldCustomer.ShippingCountry)
                       || valueChanged(newCustomer.ShippingStreet, oldCustomer.ShippingStreet);

        if(changed) {
            String label;
            if(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME.equalsIgnoreCase(newCustomer.RecordType.DeveloperName)) {
                label = 'Residence';
            }
            else {
                label = 'Business';
            }
            Map<String,String> oldAddressJSON = new Map<String,String>{
                    'addressLabel'=>'Old '+label,'address1'=>oldCustomer.ShippingStreet,
                    'city'=>oldCustomer.ShippingCity,'state'=>oldCustomer.ShippingState,
                    'zip'=>oldCustomer.ShippingPostalCode,'country'=>oldCustomer.ShippingCountry
                };

            Map<String,String> newAddressJSON = new Map<String,String>{
                    'addressLabel'=>'New '+label,'address1'=>newCustomer.ShippingStreet,
                    'city'=>newCustomer.ShippingCity,'state'=>newCustomer.ShippingState,
                    'zip'=>newCustomer.ShippingPostalCode,'country'=>newCustomer.ShippingCountry
                };
            appendToChangeDescription(JSON.serialize(oldAddressJSON));
            appendToChangeDescription(JSON.serialize(newAddressJSON));
        }
        return changed;
    }

    private static void appendToChangeDescription(String aadressJSON) {
        RequestAddressWrapper addressData = (RequestAddressWrapper) JSON.deserializeStrict(aadressJSON,RequestAddressWrapper.class);
        String street = addressData.address1;
        street = String.isBlank(street) ? '' : street.normalizeSpace();
        if (String.isEmpty(changeDescription)) {
            changeDescription += 'An address change has been made on this account.\r\n';
        }
        changeDescription += '\r\n' + addressData.addressLabel + ' Address:\r\n\t';
        if (String.isNotEmpty(addressData.inCareOf)) {
            changeDescription += '\tC/O: ' + emptyOrValue(addressData.inCareOf) + '\r\n';
        }
        if (String.isNotEmpty(addressData.attention)) {
            changeDescription += '\tAttn: ' + emptyOrValue(addressData.attention) + '\r\n';
        }
        changeDescription += emptyOrValue(street) + '\r\n\t';
        changeDescription += emptyOrValue(addressData.city) + UTIL_Constants.COMMA_WITH_SPACE;
        changeDescription += emptyOrValue(addressData.state) + UTIL_Constants.SPACE_SYMBOL;
        changeDescription += validatePostalCode(addressData.zip,addressData.country) + '\r\n\t';
        changeDescription += emptyOrValue(addressData.country) + '\r\n';
    }

    private static String validatePostalCode(String postalCode, String country) {
        if (String.isNotBlank(postalCode) && postalCode.length() > 5 
            && (country.equals('US') || country.equals('USA') || country.equalsIgnoreCase('United States'))
            ) {
            return postalCode.substring(0, 5) + '-' + postalCode.substring(5);
        }
        return postalCode;
    }

    private static String emptyOrValue(String value) {
        return (String.isBlank(value)) ? '' : value;
    }

    private static Boolean valueChanged(String newValue, String oldValue) {
        return (String.isNotBlank(newValue) && !newValue.equalsIgnoreCase(oldValue))
            || (String.isBlank(newValue) && String.isNotBlank(oldValue));
    }

    /**
    * @description This inner class is used to make request Address Wrapper JSON
    * @name : RequestAddressWrapper
    */
    public with sharing class RequestAddressWrapper {
        String addressLabel;
        String adType;
        String address1;
        String address2;
        String address3;
        String city;
        String state;
        String zip;
        String country;
        String inCareOf;
        String attention;
    }

}