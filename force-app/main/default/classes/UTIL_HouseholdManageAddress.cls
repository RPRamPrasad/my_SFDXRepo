/**
@author Team Targaryen
@owner Team Targaryen
@name UTIL_HouseholdManageAddress
@CreateDate 08/11/2022
@modifiedDate 
@description This class is used by LWC Household Manage Address components to leverage the AccountContactRelation object operations
@version 1.0
*/
public with sharing class UTIL_HouseholdManageAddress {
    
    @TestVisible 
    private static IDAO_AccountCreateEditHelper helperDAOInstance = new UTIL_AccountCreateEditHelper();
    @TestVisible 
    private static UTIL_AccountIDAO daoInstance = new UTIL_AccountDAO();

    private static String srApiKeyCS = TechnicalPlatformDetails.getApiKey();
    private static String srCategoryCS = TechnicalPlatformDetails.getSubcategory();
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String JSON_TYPE = 'application/json';
    private static final String CUST_AGGT_NAMED_CREDENTIALS = 'callout:Customer_Aggregator_Process_Id';
    private static final String SR_API_KEY = 'SR_API_KEY';
    private static final String SR_CATEGORY = 'SR_CATEGORY';
    private static final String CALLBACK_METHOD = 'processBulkAddrUpdateResponse';
    
    private static final String CLASS_NAME = 'UTIL_HouseholdManageAddress';
    private static final String VALIDATE_AND_SAVE = 'validateAndSave';
    private static final String INVOKE_BULK_AADR_UPDATE_CONTINUATION = 'invokeBulkAddrUpdateContinuation';
    private static final String CREATE_TASK_ON_ADDRESS_CHANGED = 'createCasesAndTasksForMembers';

    /**
    * @description This method fetch members name and address data from account record
    * @name : fetchMembersNameAddressesNoCache
    * @param hhAcctId : input account json
    * @return List<Account> : output updated account id
    */
    @AuraEnabled (cacheable = false)
    public static List<Account> fetchMembersNameAddressesNoCache(String hhAcctId) {
        try {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhAcctId, Account.class);
            return UTIL_HouseholdMemberHelper.getAllMembersNameAddressFromHousehold(String.escapeSingleQuotes(hhAcctId));
        } catch(Exception e){
            throw new AuraHandledException('No members found');
        }
    }
    
    /**
    * @description This method fetch members name and address data from account record
    * @name : fetchMembersNameAddresses
    * @param hhAcctId : input account json
    * @return List<Account> : output updated account id
    */
    @AuraEnabled (cacheable = true)
    public static List<Account> fetchMembersNameAddresses(String hhAcctId) {
        try {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhAcctId, Account.class);
            return UTIL_HouseholdMemberHelper.getAllMembersNameAddressFromHousehold(String.escapeSingleQuotes(hhAcctId));
        } catch(Exception e){
            throw new AuraHandledException('No members found');
        }
    }

    /**
    * @description This method fetch mailing (billing) address from account record
    * @name : fetchMailingAddressesNoCache
    * @param hhAcctId : input account json
    * @return List<Account> : output updated account id
    */
    @AuraEnabled (cacheable = true)
    public static List<Account> fetchMailingAddressesNoCache(String hhAcctId) {
        try {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhAcctId, Account.class);
            return UTIL_HouseholdAddMember.fetchMailingAddresses(hhAcctId);
        } catch(Exception e){
            throw new AuraHandledException('No address found');
        }
    }

    /**
    * @description This method fetch mailing (billing) address from account record
    * @name : fetchMailingAddresses
    * @param hhAcctId : input account json
    * @return List<Account> : output updated account id
    */
    @AuraEnabled (cacheable = true)
    public static List<Account> fetchMailingAddresses(String hhAcctId) {
        try {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhAcctId, Account.class);
            return UTIL_HouseholdAddMember.fetchMailingAddresses(hhAcctId);
        } catch(Exception e){
            throw new AuraHandledException('No address found');
        }
    }

    /**
    * @description This method used to create case and task for members
    * @name : createCasesAndTasksForMembers
    * @param caseAndTaskJson : input account json
    */
    @AuraEnabled
    public static void createCasesAndTasksForMembers(String caseAndTaskJson) {
        try {
            UTIL_HouseholdManageAddress_Addtl.createCasesAndTasksForMembers(caseAndTaskJson);
        } catch(Exception e){
            throw new AuraHandledException('No cases and task created');
        }
    }

    /**
    * @description This method is used to save account record
    * @name : validateAndSave
    * @param hhMembAddrJSON : input HH address member json
    * @return Object : output response from aggregator servie
    */
    @AuraEnabled(continuation=true)
    public static Object validateAndSave(String hhMembAddrJSON) {
        Object returnObj = null;
        try{
            returnObj = invokeBulkAddrUpdateContinuation(hhMembAddrJSON); 
        }
        catch(Exception e){
            LoggingService.logHandledException(e, CLASS_NAME, VALIDATE_AND_SAVE, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('validateAndSave ' + e.getMessage());
        }
        return returnObj;
    }

    /**
    * @description This method is used to save account record
    * @name : invokeBulkAddrUpdateContinuation
    * @param hhMembAddrJSON : input HH address member json
    * @return Object : output response from aggregator servie
    */
    @AuraEnabled(continuation=true cacheable=true)
    public static Object invokeBulkAddrUpdateContinuation(String hhMembAddrJSON) {
        Continuation con = new Continuation(120);
        con.continuationMethod = CALLBACK_METHOD;
        HttpRequest httpReq = new HttpRequest();
        try {
            httpHhMgmtAddrHeader(httpReq);
            String reqBody = UTIL_CreateCustomerConstants.EMPTY_STRING;
            httpReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            HLPR_HhMembsAddrPatchReqWrapper reqWrap = (HLPR_HhMembsAddrPatchReqWrapper) JSON.deserialize(hhMembAddrJSON,HLPR_HhMembsAddrPatchReqWrapper.class);
            reqBody = HLPR_HhMembAddrAggtPatchReq.getHhMembAddrPatchReq(reqWrap);
            httpReq.setBody(reqBody);
            System.debug(LoggingLevel.INFO, 'HH Member Addr Agg request -->'+httpReq.getBody());
            con.state = helperDAOInstance.getContinuationState(con,httpReq);
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, INVOKE_BULK_AADR_UPDATE_CONTINUATION, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('invokeBulkAddrUpdateContinuation Error ' + e.getMessage());
        }
        return con;
    }

    /**
    * @description This method is used to save account record
    * @name : processBulkAddrUpdateResponse
    * @param labels : get the continuation response
    * @param state : state of response
    * @return Object : output response from aggregator servie
    */
    @AuraEnabled
    public static Object processBulkAddrUpdateResponse(List<String> labels, Object state) {
        HttpResponse response;
        List<Account> updatedAcctList = new List<Account>();
        List<String> successList = new List<String>();
        List<String> errorList = new List<String>();
        List<Object> resultList;
        response = helperDAOInstance.getContinuationResponse(labels[0]);
        System.debug(LoggingLevel.INFO, 'HH Member Addr Agg response -->'+response.getBody());
        try {
            Object result = JSON.deserializeUntyped(response.getBody());
            if(result instanceOf Map<String, Object>) {
                Map<String, Object> meta = (Map<String, Object>) result;
                resultList = (List<Object>) meta.get('customerResponse');
                for(Object res:resultList) {
                    AP_CustAggtRes custAggtRes;
                    custAggtRes = AP_CustAggtRes.parse(JSON.serialize(res));
                    AP_CustAggtRes.cls_errors[] errors = custAggtRes.errors;
                    if(errors != null && !errors.isEmpty()) {
                        System.debug(LoggingLevel.INFO, 'HH Member Addr Agg error response -->'+errors[0].detail);
                        errorList.add(errors[0].detail);
                    } else {
                        Account customer = new Account();
                        customer = HLPR_CustAggtRes.buildCustomerFromAggtRes(new Account(), custAggtRes);
                        customer.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(custAggtRes.data.attributes.customerType).getRecordTypeId();
                        customer.Edit_In_VFP__c = true;
                        updatedAcctList.add(customer);
                        successList.add(custAggtRes.data.clientId);
                    }
                }
            saveCustomerAfterAddressUpdate(updatedAcctList);
            }
            Map<String,List<String>> jsonMap = new Map<String,List<String>>();
            jsonMap.put('successList',successList);
            jsonMap.put('errorList',errorList);
            return jsonMap;
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'processCustAggResponse', System.LoggingLevel.ERROR);  //Unrecoverable
            throw e;
        }
            
    }

    private static void saveCustomerAfterAddressUpdate(List<Account> customers){
        UTIL_AccountDAO.upsertAccountsByClientIdentifier(customers);
    }

    /**
    * @description This method is used to set HTTP Address Std Header
    * @name : httpAddrStdHeader
    * @param httpReq : input http request
    */
    private static void httpHhMgmtAddrHeader(HttpRequest httpReq) {
        CM_Customer_Aggregator_Resource__mdt customerResource = UTIL_HouseholdMemberHelper.getCustomerBulkAddressResource();
        httpReq.setEndpoint(CUST_AGGT_NAMED_CREDENTIALS+customerResource.Resource_Path__c); 
        httpReq.setHeader(CONTENT_TYPE, JSON_TYPE);
        if (String.isNotBlank(srApiKeyCS)) { httpReq.setHeader(SR_API_KEY, srApiKeyCS); }
        if (String.isNotBlank(srCategoryCS)) { httpReq.setHeader(SR_CATEGORY, srCategoryCS); }
    }

}