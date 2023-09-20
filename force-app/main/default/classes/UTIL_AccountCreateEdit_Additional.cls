/**
@author Team Atlas
@owner Team Atlas
@name UTIL_AccountCreateEdit_Additional
@createDate 10/24/2019
@modifiedDate 04/10/2023
@description This Additional class is used by LWC Account components to leverage the existing account callouts
@version 2.0
*/
public with sharing class UTIL_AccountCreateEdit_Additional {
    
    @TestVisible private static IDAO_AccountCreateEditHelper helperDAOInstance = new UTIL_AccountCreateEditHelper();
    private static Account customer = new Account();
    private static Account oldCustomer  = new Account();
    private static Boolean isCCCUser = true;
    private static String srApiKeyCS = TechnicalPlatformDetails.getApiKey();
    private static String srCategoryCS = TechnicalPlatformDetails.getSubcategory();

    private static final String POPULATE_REQ_WRAPPER = 'populateReqWrapper';
    private static final String CLASS_NAME = 'UTIL_AccountCreateEdit_Additional';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String JSON_TYPE = 'application/json';
    private static final String CUST_AGGT_NAMED_CREDENTIALS = 'callout:Customer_Aggregator_Process_Id';
    private static final String SR_API_KEY = 'SR_API_KEY';
    private static final String SR_CATEGORY = 'SR_CATEGORY';
    
    private static HLPR_CustAggtReqWrapper reqWrapper { get; set; }
    private static String targetDomains {get; set;}

    /**
    * @description This method is used get the external app target domain
    * @name : getTargetDomains
    * @return String
    */
    public static String getTargetDomains() {
        targetDomains = UTIL_CreateCustomerConstants.EMPTY_STRING;
        List<CS_EnterpriseAppsTargetDomain__c> domainList = UTIL_AccountCreateEditHelper.getEnterpriseAppTargetDomain();
        for(CS_EnterpriseAppsTargetDomain__c domain : domainList){
            if (String.isNotBlank(targetDomains)) {
                targetDomains = targetDomains + UTIL_CreateCustomerConstants.COMMA_NO_SPACE + domain.TargetDomain__c;
            }
            else {
                targetDomains = domain.TargetDomain__c;
            }
        }
        return targetDomains;
    }

    /**
    * @description This method is used to set HTTP Address Std Header
    * @name : httpAddrStdHeader
    * @param httpReq : input http request
    */
    public static void httpAddrStdHeader(HttpRequest httpReq) {
        CM_Customer_Aggregator_Resource__mdt customerResource = UTIL_AccountCreateEditHelper.getCustomerAddressResource();
        httpReq.setEndpoint(CUST_AGGT_NAMED_CREDENTIALS+customerResource.Resource_Path__c); 
        httpReq.setHeader(CONTENT_TYPE, JSON_TYPE);
        if (String.isNotBlank(srApiKeyCS)) { httpReq.setHeader(SR_API_KEY, srApiKeyCS); }
        if (String.isNotBlank(srCategoryCS)) { httpReq.setHeader(SR_CATEGORY, srCategoryCS); }
    }

    /**
    * @description This method is used to set HTTP Header
    * @name : httpHeader
    * @param httpReq : input http request
    */
    public static void httpHeader(HttpRequest httpReq) {
        CM_Customer_Aggregator_Resource__mdt customerResource = UTIL_AccountCreateEditHelper.getCustomerResource();
        httpReq.setEndpoint(CUST_AGGT_NAMED_CREDENTIALS+customerResource.Resource_Path__c); 
        httpReq.setHeader(CONTENT_TYPE, JSON_TYPE);
        if (String.isNotBlank(srApiKeyCS)) { httpReq.setHeader(SR_API_KEY, srApiKeyCS); }
        if (String.isNotBlank(srCategoryCS)) { httpReq.setHeader(SR_CATEGORY, srCategoryCS); }
    }

    /**
    * @description This method is used to request for POST method
    * @name : postRequest
    * @param accountJSON : input account json
    * @param reqJSON : input request json
    * @param reqBody : input request body
    * @return String : output request body
    */
    public static String postRequest(String accountJSON,String reqJSON,String reqBody) {
        String strReqBody = reqBody;
        AccountJSONWrapper accountWrapper = (AccountJSONWrapper) JSON.deserialize(accountJSON, AccountJSONWrapper.class);
        customer = (Account) JSON.deserializeStrict(accountWrapper.customer,Account.class);
        String recordTypeDevName = UTIL_AccountCreateEditHelper.getRecordTypeNameById(UTIL_CreateCustomerConstants.ACCOUNT_IMPL,customer.RecordTypeId);
        if (recordTypeDevName.equals(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME)) { 
             strReqBody = HLPR_CustAggt.getIndCreateCustReq(UTIL_AccountCreateEdit_Additional.populateReqWrapper(accountJSON,reqJSON));
            
        }
        else { 
              strReqBody  = HLPR_CustAggt.getOrgCreateCustReq(UTIL_AccountCreateEdit_Additional.populateReqWrapper(accountJSON,reqJSON));
        }
        return strReqBody;
    }

    /**
    * @description This method is used populate request wrapper data used by HTTP Request
    * @name : populateReqWrapper
    * @param accountJSON : input account json
    * @param reqJSON : input request json
    * @return HLPR_CustAggtReqWrapper : output customer aggregator helper wrapper class
    */
    public static HLPR_CustAggtReqWrapper populateReqWrapper(String accountJSON, String reqJSON){
        AccountJSONWrapper accountWrapper = (AccountJSONWrapper) JSON.deserialize(accountJSON, AccountJSONWrapper.class);
        isCCCUser = helperDAOInstance.isAgentContextAllowed();
        reqWrapper = new HLPR_CustAggtReqWrapper();
        reqWrapper.isIndividual = false;
        customer = (Account) JSON.deserializeStrict(accountWrapper.customer,Account.class);
        RequesAddressWrapper reqAddressWrap = (RequesAddressWrapper) JSON.deserialize(reqJSON,RequesAddressWrapper.class);
        RequestAdditionalWrapper reqAdditionalWrap = (RequestAdditionalWrapper) JSON.deserialize(reqJSON,RequestAdditionalWrapper.class);
        String recordTypeDevName = UTIL_AccountCreateEditHelper.getRecordTypeNameById(UTIL_CreateCustomerConstants.ACCOUNT_IMPL,customer.RecordTypeId);
        if(recordTypeDevName.equals(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME)) { reqWrapper.isIndividual = true; }
        if (customer.AnnualRevenue != null) { customer.AnnualRevenue = customer.AnnualRevenue.setScale(0); }
        reqWrapper.oldCustomer = null;
        if(accountWrapper.oldCustomer != null){
        	reqWrapper.oldCustomer = (Account) JSON.deserializeStrict(accountWrapper.oldCustomer, Account.class);   
        }
        reqWrapper.customer = customer;
        reqWrapper.billingStreet1 = reqAddressWrap.billingStreet1;
        reqWrapper.billingStreet2 = reqAddressWrap.billingStreet2;
        reqWrapper.billingStreet3 = reqAddressWrap.billingStreet3;
        reqWrapper.shippingStreet1 = reqAddressWrap.shippingStreet1;
        reqWrapper.shippingStreet2 = reqAddressWrap.shippingStreet2;
        reqWrapper.shippingStreet3 = reqAddressWrap.shippingStreet3;
        reqWrapper.billingAddStdCode = reqAddressWrap.billingAddStdCode;
        reqWrapper.shippingAddStdCode = reqAddressWrap.shippingAddStdCode;
        reqWrapper.isMailingUpdated = reqAddressWrap.isMailingUpdated;
        reqWrapper.isResidenceUpdated = reqAddressWrap.isResidenceUpdated;
        reqWrapper.associateId = reqAdditionalWrap.associateId;
        reqWrapper.isUpdateAfterSearch = reqAdditionalWrap.isUpdateAfterSearch;
        if(reqAdditionalWrap.isUpdateAfterSearch) { reqWrapper.oldCustomer = customer; }
        reqWrapper.emailValidationCode = reqAdditionalWrap.emailValidationCode;
        reqWrapper.isEmailValidationChanged = reqAdditionalWrap.isEmailValidationChanged;
        reqWrapper.agentAssociateId = populateAgentIdFromAgentContext(customer, reqAdditionalWrap.agentAssociateId);
        reqWrapper.isAgentContextSetForCCCUser = false;
        reqWrapper.isJoesiCallNeeded = reqAdditionalWrap.isJoesiCallNeeded;
        reqWrapper.optInEmail = reqAdditionalWrap.optInEmail;
        reqWrapper.optInText = reqAdditionalWrap.optInText;
        if(!String.isBlank(reqAdditionalWrap.joesiContext)) {
            reqWrapper.joesiContext = reqAdditionalWrap.joesiContext;
        }
        if(isCCCUser && reqWrapper.agentAssociateId != null) { reqWrapper.isAgentContextSetForCCCUser = true; }
        reqWrapper.groupId = reqAdditionalWrap.groupId;
        return reqWrapper;
    }

    private static String populateAgentIdFromAgentContext(Account customer, String agentAssociateId) {
        if (agentAssociateId != null) { return agentAssociateId; }
        User loggedInUser = helperDAOInstance.getLoggedInUser();
        String agentContextId = loggedInUser.Associate_ID__c + UTIL_CreateCustomerConstants.TILDE;
        if (String.isNotBlank(customer.ClientIdentifier__c)) { agentContextId += customer.ClientIdentifier__c; }
        List<AgentContext__c> existingAgentContext = helperDAOInstance.getAgentContextDetails(agentContextId);
        if (existingAgentContext != null && !existingAgentContext.isEmpty()) { return existingAgentContext[0].Agent__r.Associate_ID__c; }
        else { return null; }
    }

    /**
    * @description This inner class is used make address wrapper JSON
    * @name : RequestWrapper
    */
    public with sharing class RequesAddressWrapper {
        String billingStreet1;
        String billingStreet2;
        String billingStreet3;
        String shippingStreet1;
        String shippingStreet2;
        String shippingStreet3;
        String billingAddStdCode;
        String shippingAddStdCode;
        Boolean isMailingUpdated;
        Boolean isResidenceUpdated;
    }

    /**
    * @description This inner class is used to make addtional wrapper JSON
    * @name : RequestWrapper
    */
    public with sharing class RequestAdditionalWrapper {
        Boolean isIndividual;
        String associateId;
        String agentAssociateId;
        Boolean isUpdateAfterSearch;
        Boolean isAgentContextSetForCCCUser;
        String groupId;
        String emailValidationCode;
        Boolean isEmailValidationChanged;
        Boolean isJoesiCallNeeded;
        String joesiContext;
        String optInEmail;
        String optInText;
    }
    
    /**
     * @description This is used to seperate the accountJSON parameter into both the oldcustomer and the customer data
     * @name: accountJSONWrapper
     */
    public with sharing class AccountJSONWrapper {
        public String customer;
        public String oldCustomer;
    }
}