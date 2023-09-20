/**
@author Team STARK
@owner Team STARK
@name UTIL_AccountCreateEdit
@CreateDate 10/24/2019
@modifiedDate 
@description This class is used by LWC Account components to leverage the existing account callouts
@version 2.0
*/
public with sharing class UTIL_AccountCreateEdit {

    private static String agentAssociateId;
    

    @TestVisible 
    private static IDAO_AccountCreateEditHelper helperDAOInstance = new UTIL_AccountCreateEditHelper();
    private static final String VALIDATE_AND_SAVE = 'validateAndSave';
    private static final String INVOKE_AGG_CONTINUATION = 'invokeAggContinuation';
    private static final String SAVE_CUSTOMER_AND_AGENT_ROLES = 'saveCustomerAndAgentRoles';
    private static final String SAVE_CUSTOMER_GROUPS_AND_MEMBERS = 'saveCustomerGroupsAndMembers';
    @TestVisible 
    private static UTIL_AccountIDAO daoInstance = new UTIL_AccountDAO();

    
    private static final String CLASS_NAME = 'UTIL_AccountCreateEdit';
    
   
    private static final String CALLBACK_METHOD = 'processCustAggResponse';
    private static Account customer = new Account();
   
    private static List<AgentRole__c> agentRoles = new List<AgentRole__c>();
    private static List<CustomerGroup__c> customerGroups = new List<CustomerGroup__c>();
    private static List<CustomerGroupMember__c> customerGroupMembers = new List<CustomerGroupMember__c>();
    private static List<AgentContext__c> agentContexts = new List<AgentContext__c>();
    private static Boolean isUpsertReqd = true;
    private static Boolean isCCCUser = true;
    private static HLPR_CustAggtReqWrapper reqWrapper {get;set;}
    
    private static String selectedReason {get; set;}

    /**
    * @description This method is used to retrieve record types
    * @name : fetchCustomerRecordTypes
    * @return List<RecordType>
    */
    @AuraEnabled(cacheable=true)
    public static List<RecordType> fetchCustomerRecordTypes() { return UTIL_AccountCreateEditHelper.getAccountRecordTypes(); } 

    /**
    * @description This method is used to retrieve State/Province data
    * @name : getStateProvinceData
    * @param searchKey : inout search key
    * @return List<String> : output state or province data
    */
    @AuraEnabled(cacheable = true)
    public static List<String> getStateProvinceData(String searchKey) {
        List<String> stateOptions = new List <String>();
        List<CM_US_Canada_State__mdt> states = UTIL_AccountCreateEditHelper.getStateProvinceData(searchKey);
        for(CM_US_Canada_State__mdt state : states) { stateOptions.add(state.DeveloperName + ',' + state.MasterLabel); }
        return stateOptions;
    }

    /**
    * @description This method is used to retrieve Military city data
    * @name : getMilitaryCityData
    * @return List<String>
    */
    @AuraEnabled(cacheable = true)
    public static List<String> getMilitaryCityData() {
        List<String> cityOptions = new List <String>();
        List<CM_US_Canada_State__mdt> cities = UTIL_AccountCreateEditHelper.getMilitaryCityData(UTIL_CreateCustomerConstants.OVERSEAS_MILITARY);
        for(CM_US_Canada_State__mdt city : cities) { cityOptions.add(city.DeveloperName + ',' + city.MasterLabel); }
        return cityOptions;
    }

    /**
    * @description This method is used to retrieve suffix data
    * @name : getSuffixOptions
    * @return List<String> 
    */
    @AuraEnabled(cacheable = true)
    public static List<String> getSuffixOptions() {
        List<String> suffixOptions = new List<String>();
        for(CS_Customer_Suffix__c suffix : UTIL_AccountCreateEditHelper.getSuffixData()) { suffixOptions.add(suffix.Name); }
        return suffixOptions;
    }
 
    /**
    * @description This method updated an account
    * @name : updateCustomerRecord
    * @param accountJSON : input account json
    * @return Object : output updated account id
    */
    @AuraEnabled
    public static Object updateCustomerRecord(String accountJSON) {
        Account customer = (Account) JSON.deserializeStrict(accountJSON,Account.class);
        daoInstance.updateCustomerRec(customer);
        return (String) customer.id;
    }

    /**
    * @description This logs an exception in the SFDC exception logs, used by LWC
    * @name : logError
    * @description Log Error
    * @param exceptionMessage
    * @param className
    * @param methodName
    * @param loggingLevel
    */
    @AuraEnabled
    public static void logError(String exceptionMessage, String className, String methodName, String loggingLevel) { 
        try {
            throw new AccountCreateEditException('Error: ' + exceptionMessage);
        }  
        catch(Exception e) {
            switch on loggingLevel {
                when 'INFO' {
                    LoggingService.logHandledException(e, className, methodName, System.LoggingLevel.INFO);
                }
                when 'WARN' {
                    LoggingService.logHandledException(e, className, methodName, System.LoggingLevel.WARN);
                }
                when else {
                    LoggingService.logHandledException(e, className, methodName, System.LoggingLevel.ERROR);
                }
            }
        }
    }

    /**
    * @description This method is used to save account record
    * @name : validateAndSave
    * @param accountJSON : input account json
    * @param reqJSON : input request json
    * @param isNewCustomer : input boolean is customer new ?
    * @return Object : output response from aggregator servie
    */
    @AuraEnabled(continuation=true)
    public static Object validateAndSave(String accountJSON, String reqJSON, Boolean isNewCustomer) {
        Object returnObj = null;
        try { 
            returnObj = invokeAggContinuation(accountJSON,reqJSON,isNewCustomer); 
        }   
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, VALIDATE_AND_SAVE, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('validateAndSave ' + e.getMessage());
        }
        return returnObj;
    } 

    /**
    * @description This method is used to invoke Continuation for POST and PATCH request to Aggregator
    * @name : invokeAggContinuation
    * @param accountJSON : input account json
    * @param reqJSON : input request json
    * @param isNewCustomer : input boolean is customer new ?
    * @return Object : output response from aggregator servie
    */
    @AuraEnabled(continuation=true cacheable=true)
    public static Object invokeAggContinuation(String accountJSON, String reqJSON, Boolean isNewCustomer) {
        Continuation con = new Continuation(120);
        con.continuationMethod = CALLBACK_METHOD;
        HttpRequest httpReq = new HttpRequest();
        try {
            UTIL_AccountCreateEdit_Additional.httpHeader(httpReq);
            String reqBody = UTIL_CreateCustomerConstants.EMPTY_STRING;
            if (isNewCustomer) {
                httpReq.setMethod(UTIL_CreateCustomerConstants.POST);
                reqBody = UTIL_AccountCreateEdit_Additional.postRequest(accountJSON,reqJSON,reqBody);
            } else {
                httpReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
                reqBody = HLPR_CustAggt.getCustPatchReq(UTIL_AccountCreateEdit_Additional.populateReqWrapper(accountJSON,reqJSON));
                
                AP_CustAggtPatchReq patchReq = AP_CustAggtPatchReq.parse(reqBody);
                if ((patchReq.data.attributes.operations == null || patchReq.data.attributes.operations.isEmpty())) {
                    reqBody = UTIL_CreateCustomerConstants.EMPTY_STRING;
                    isUpsertReqd = false;
                    UTIL_AccountCreateEdit_Additional.AccountJSONWrapper accoutWrapper = (UTIL_AccountCreateEdit_Additional.AccountJSONWrapper) JSON.deserialize(accountJSON, UTIL_AccountCreateEdit_Additional.AccountJSONWrapper.class);
                    Account customer = (Account) JSON.deserializeStrict(accoutWrapper.customer,Account.class);
                    Map<String,String> result = new Map<String,String>();
                    result.put('id',customer.Id);
                    result.put('clientId',customer.ClientIdentifier__c);
                    result.put('PersonContactId',customer.PersonContactId);
                    result.put('Name',customer.FirstName+' '+customer.LastName);
                    return JSON.serialize(result);
                }
            } 
            httpReq.setBody(reqBody);
            System.debug(LoggingLevel.INFO, 'Agg request -->'+httpReq.getBody());
            con.state = helperDAOInstance.getContinuationState(con,httpReq);
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, INVOKE_AGG_CONTINUATION, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('invokeAggContinuation ' + e.getMessage());        }
        return con;
    }

    /**
    * @description This method is used to process and get Customer response from Aggregator
    * @name : processCustAggResponse
    * @param labels : input labels
    * @param state : input state
    * @return Object : output response from service
    */
    @AuraEnabled
    public static Object processCustAggResponse(List<String> labels, Object state) {
        HttpResponse response;
        AP_CustAggtRes custAggtRes;
        response = helperDAOInstance.getContinuationResponse(labels[0]);
        try {
            custAggtRes = AP_CustAggtRes.parse(response.getBody());
            System.debug(LoggingLevel.INFO, 'Agg response -->'+response.getBody());
        
            AP_CustAggtRes.cls_errors[] errors = custAggtRes.errors;
            if(errors != null && !errors.isEmpty()) {
              System.debug(LoggingLevel.INFO, 'Agg error response -->'+errors[0].detail);
              throw new AccountCreateEditException(errors[0].detail);
            } else {
              if(String.isBlank(selectedReason)) { selectedReason = UTIL_CreateCustomerConstants.EMPTY_STRING; }
              Boolean isUpdateAfterSearch = false;
              customer = HLPR_CustAggtRes.buildCustomerFromAggtRes(new Account(), custAggtRes);
              customer.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(custAggtRes.data.attributes.customerType).getRecordTypeId();
              customer.Edit_In_VFP__c = true;

                HLPR_CustAggtRes.HLPR_CustAggtResWrapper hlprWrap = new HLPR_CustAggtRes.HLPR_CustAggtResWrapper();
                hlprWrap.custAggtRes = custAggtRes;
                hlprWrap.selectedReason = selectedReason;
                hlprWrap.isUpdateAfterSearch = isUpdateAfterSearch;
                hlprWrap.agentAssociateId = agentAssociateId;

              agentRoles = HLPR_CustAggtRes.buildAgentRolesFromAggtRes(hlprWrap);
              customerGroups = HLPR_CustAggtRes.buildCustomerGroupsFromAggtRes(custAggtRes);
              customerGroupMembers = HLPR_CustAggtRes.buildCustomerGroupMembers(customerGroups, customer.clientIdentifier__c);
              saveCustomerAndAgentRoles();
              saveCustomerGroupsAndMembers();
              HLPR_CustAggtResNba.buildSFCustomRecommendations(custAggtRes);
            }
            Account customerStr = helperDAOInstance.getAccountDetails(customer.Id);
            Map<String,String> result = new Map<String,String>();
            result.put('id',customerStr.Id);
            result.put('clientId',customerStr.ClientIdentifier__c);
            result.put('PersonContactId',customerStr.PersonContactId);
            result.put('Name',customerStr.Name);
            return JSON.serialize(result);
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'processCustAggResponse', System.LoggingLevel.ERROR);  //Unrecoverable
            throw e;
        }
    }

    private static void saveCustomerAndAgentRoles() {
        try {
            daoInstance.upsertCustomerRec(customer);
            if(!agentRoles.isEmpty()){
                Database.UpsertResult[] upsertAgentRolesResults = UTIL_AgentRoleDAO.upsertedAgentRolesResult(agentRoles);
                LoggingService.logDatabaseResult(upsertAgentRolesResults, agentRoles, CLASS_NAME, SAVE_CUSTOMER_AND_AGENT_ROLES, System.LoggingLevel.ERROR);
            }
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, SAVE_CUSTOMER_AND_AGENT_ROLES, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('saveCustomerAndAgentRoles Error: ' + e.getMessage());
        }
    }

    private static void saveCustomerGroupsAndMembers() {
        try {
            if(!customerGroups.isEmpty()) {
                Database.UpsertResult[] upsertCustomerGroupResults = UTIL_CustomerGroupDAO.upsertedGroupResult(customerGroups);
                LoggingService.logDatabaseResult(upsertCustomerGroupResults, customerGroups, CLASS_NAME, SAVE_CUSTOMER_GROUPS_AND_MEMBERS, System.LoggingLevel.ERROR);
            }
            if(!customerGroupMembers.isEmpty()) {
                Database.UpsertResult[] upsertCustomerGroupMemberResults = UTIL_CustomerGroupMemberDAO.upsertedGroupMemberResult(customerGroupMembers);
                LoggingService.logDatabaseResult(upsertCustomerGroupMemberResults, customerGroupMembers, CLASS_NAME, SAVE_CUSTOMER_GROUPS_AND_MEMBERS, System.LoggingLevel.ERROR);
            }
        }  
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, SAVE_CUSTOMER_GROUPS_AND_MEMBERS, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('saveCustomerGroupsAndMembers Error: ' + e.getMessage());
        }   
    }

    /**
    * @description passing through method for Lead Conversion
    * @name : fetchLeadData
    * @param leadId : input leadId
    * @return LeadConversionController.ConvertLeadWrapper : output wrapper lead conversion
    */
    @AuraEnabled
    public static LeadConversionController.ConvertLeadWrapper fetchLeadData(String leadId) {
    	return LeadConversionController.fetchLeadDataWrapper(leadId);
    }

    /**
    * @description passing through method for retrieving OppQuoteCanvasable after Lead Conversion
    * @name : isOppQuoteCanvasable
    * @param oppId : input oppId
    * @return LeadConversionController.isOppQuoteCanvasable : output wrapper lead conversion
    */
    @AuraEnabled
    public static String isOppQuoteCanvasable(String oppId) {
    	return LeadConversionController.isOppQuoteCanvasable(oppId);
    }

}