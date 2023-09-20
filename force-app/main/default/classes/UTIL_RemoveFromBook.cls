/**
* @Name UTIL_RemoveFromBook
* @Author Team Atlas
* @CreateDate 07/06/2023
* @Description: For remove from book functionality
* @Version 1.0
*/

public with sharing class UTIL_RemoveFromBook {
    @TestVisible 
    private static IDAO_AccountCreateEditHelper helperDAOInstance = new UTIL_AccountCreateEditHelper();
    private static String requesterAssociateId;
    private static List<String> rfbUnSuccessfulList;
    private static List<String> rfbSuccessfulList;
    private static final String BLANK_SPACE =' ';
    private static final String CALLBACK_METHOD = 'processRemoveFromBookAggregatorResponse';
    private static final String CUST_END_AGENT_RELATIONSHIP_RESOURCE_DEVELOPER_NAME='Customer_End_Agent_Relationship_Resource';
    private static final String CUST_AGGT_NAMED_CREDENTIALS = 'callout:Customer_Aggregator_Process_Id';
    private static final String CLASS_NAME = 'UTIL_RemoveFromBook';
    private static final String METHOD_NAME = 'processRemoveFromBookAggregatorResponse';
    private static final String ENTIRE_TRANSACTION_FAILED ='The entire transaction has failed!';
    private static final String TRANSACTION_FAILED ='RFB transaction failed';
    private static final String PROCESS_REMOVE_FROM_BOOK = 'processRemoveFromBook';

    /**
     * @description isSuccess
     */
    public static Boolean isSuccess {get; private set;}

    /**
     * @description selectedAgentContext
     */
    public static User selectedAgentContext {get; set;}

    //Gets the list of members and info on the household for given account id and agent assoc id
    @AuraEnabled (cacheable = false)
    public static List<AgentRole__c> getLoggedInContextForRFB(String acctId, string agentAssocId){
        String methodName = 'getLoggedInContextForRFB';
        //List<AgentRole__c> emptyList;
        try{
            String expectedAgentExternalId;
            expectedAgentExternalId = agentAssocId+'_'+agentAssocId;
            List<User> loggedInUser =  Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT Id, Name, Associate_ID__c, Profile.Name, Servicing_Agent_Associate_ID__c,UserExternalID__C FROM User Where UserExternalID__C=: expectedAgentExternalId]
                )
                .getRecords();
            selectedAgentContext = loggedInUser[0];
            return getAllActiveMembersWithAgentRelFromHousehold(acctId, selectedAgentContext);

        }catch(Exception ex){
            LoggingService.logHandledException(ex, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            throw new AuraHandledException(ex.getMessage());
        } 
    }

    private static Id getPrimaryHouseholdInfo(String acctId){
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', acctId, Account.class);
        List<Account> acctList = new List<Account>(); 
        acctList = Security.stripInaccessible(
                AccessType.READABLE,
                [
                    SELECT Primary_Household__pc FROM Account WHERE Id = :String.escapeSingleQuotes(acctId) LIMIT 1
                ]
            )
            .getRecords();
        return acctList[0].Primary_Household__pc;
    }

    @AuraEnabled (cacheable = true)
    public static List<AgentRole__c> getAllActiveMembersWithAgentRelFromHousehold(String acctId, User selectedAgentContext) {
        String methodName = 'getAllActiveMembersWithAgentRelFromHousehold';
   	try{
        Id primaryHHId = getPrimaryHouseholdInfo(acctId);
        List<AgentRole__c> getAllAgentRoleRelatedHH = new List<AgentRole__c>();
        if(primaryHHId == null){
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', acctId, Account.class);
        getAllAgentRoleRelatedHH =  Security.stripInaccessible(
                    AccessType.READABLE,
                    [ 
                        SELECT Id,Customer__c,Customer__r.Name,Customer__r.ClientIdentifier__c,RelationshipNature__c,RelationshipStartDate__c,Agent__c,Agent__r.name,Agent__r.Associate_Id__c,Customer__r.PersonBirthdate
                        FROM AgentRole__c
                            WHERE Agent__c IN 
                                (SELECT Id FROM User WHERE Associate_ID__c = :selectedAgentContext.Servicing_Agent_Associate_ID__c)
                            AND Customer__c = :String.escapeSingleQuotes(acctId)
                    ]
                )
                .getRecords();
        }else{
            getAllAgentRoleRelatedHH =  Security.stripInaccessible(
                AccessType.READABLE,
                [ 
                    SELECT Id,Customer__c,Customer__r.Name,Customer__r.ClientIdentifier__c,RelationshipNature__c,RelationshipStartDate__c,Agent__c,Agent__r.name,Agent__r.Associate_Id__c,Customer__r.PersonBirthdate
                    FROM AgentRole__c
                        WHERE Primary_Household__c =:String.escapeSingleQuotes(primaryHHId)
                        AND agent__c IN 
                            (SELECT Id FROM User WHERE Associate_ID__c = :selectedAgentContext.Servicing_Agent_Associate_ID__c)
                ]
            )
            .getRecords();  
        }
            return getAllAgentRoleRelatedHH;
    }catch(Exception ex){
            LoggingService.logHandledException(ex, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            throw new AuraHandledException(ex.getMessage());
    }
    }

    private static List<AgentRole__c> getFinalEligibleList(String selectedMemberIds) {
        String methodName = 'getFinalEligibleList';
        List<AgentRole__c> finalRemoveMemberList;
        try {
            List<Id> agIdList = (List<Id>) JSON.deserializeStrict(selectedMemberIds,List<Id>.class);
        	finalRemoveMemberList = [ SELECT Id, Customer__r.ClientIdentifier__c,Agent__r.Associate_Id__c
        	FROM AgentRole__c Where Id IN:agIdList WITH SECURITY_ENFORCED];
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
        return finalRemoveMemberList;
        }

    //Continuation callout
    @AuraEnabled(continuation=true)
    public static Object processRemoveFromBook(String selectedMemberIds ) {
        Object returnObj = null;
        try{
            returnObj = invokeContinuation(selectedMemberIds); 
        }
        catch(Exception ex){
            LoggingService.logHandledException(ex, CLASS_NAME, PROCESS_REMOVE_FROM_BOOK, System.LoggingLevel.ERROR);
            throw new AuraHandledException(ex.getMessage());
        }
        return returnObj;
    }

    //Apex call out and continuation set up method
    /**
     * @description invokeContinuation
     * @return  `Object`
     */
    @AuraEnabled(continuation=true cacheable=true)
    public static Object invokeContinuation(String selectedMemberIds) {
       String methodName = 'invokeContinuation';
        Continuation con = new Continuation(120);
    try{
        con.continuationMethod = CALLBACK_METHOD;

        HttpRequest req = TechnicalPlatformDetails.buildHttpRequestForTP();
        req.setMethod(TechnicalPlatformDetails.POST);

        CM_Customer_Aggregator_Resource__mdt custEndAgentRelResource;

        if(CM_Customer_Aggregator_Resource__mdt.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
           custEndAgentRelResource = [SELECT Resource_Path__c, DeveloperName FROM CM_Customer_Aggregator_Resource__mdt
                                                            WHERE DeveloperName = :CUST_END_AGENT_RELATIONSHIP_RESOURCE_DEVELOPER_NAME 
                                                            WITH SECURITY_ENFORCED];
        }
        req.setEndpoint(CUST_AGGT_NAMED_CREDENTIALS+custEndAgentRelResource.Resource_Path__c);
        req.setHeader(TechnicalPlatformDetails.CONTENT_TYPE, TechnicalPlatformDetails.JSON_TYPE);

        String reqBody = UTIL_CreateCustomerConstants.EMPTY_STRING;
        List<User> currentUsers = Security.stripInaccessible(
                AccessType.READABLE,
            [Select Associate_ID__c, Profile.Name from User Where Id = :UserInfo.getUserId()]
            )
            .getRecords();
        User currentUser = currentUsers[0];
        requesterAssociateId=currentUser.Associate_ID__c;
        reqBody = HLPR_RemoveFromBookAggregatorRequest.getRemoveFromBookRequest(getFinalEligibleList(selectedMemberIds),requesterAssociateId);
        req.setBody(reqBody);
        System.debug(LoggingLevel.INFO, 'Request -->> '+reqBody);
        con.state = helperDAOInstance.getContinuationState(con,req);
    }catch(Exception ex){
        LoggingService.logHandledException(ex, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        throw new AuraHandledException(ex.getMessage());

    }
        return con;
    
    }

    // APEX callout response method
    /**
     * @description processRemoveFromBookAggregatorResponse
     * @return  `object`
     */
    @AuraEnabled
    public static Object processRemoveFromBookAggregatorResponse(List<String> labels, Object state){
        Map<String,List<String>> jsonMap = new Map<String,List<String>>();
        try {
            isSuccess = false;
            HttpResponse response = helperDAOInstance.getContinuationResponse(labels[0]);
            AP_RemoveFromBookAggregatorResponse custRFBAggtRes = AP_RemoveFromBookAggregatorResponse.parse(response.getBody());
            System.debug(LoggingLevel.INFO, 'custRFBAggtRes -->> '+custRFBAggtRes);
            String errorMsg;

            if(response.getStatusCode()>=2000 ||!custRFBAggtRes.errors.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CL_Exception_Message));
                List<AP_RemoveFromBookAggregatorResponse.RemoveFromBookErrors> errorList=custRFBAggtRes.getErrorList();
                errorMsg=ENTIRE_TRANSACTION_FAILED;
                for(AP_RemoveFromBookAggregatorResponse.RemoveFromBookErrors error: errorList){
                    errorMsg=errorMsg+BLANK_SPACE+error.detail;
                }
                LoggingService.logHandledException(new CustomerAggregatorException(errorMsg), CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
            }
            else {
                rfbUnSuccessfulList = new List<String>();
                rfbSuccessfulList = new List<String>();
                rfbUnSuccessfulList=HLPR_RemoveFromBookAggregatorResponse.getRemoveFromBookFromAggregatorFailedResponse(custRFBAggtRes.getDataList());
                rfbSuccessfulList=HLPR_RemoveFromBookAggregatorResponse.getRemoveFromBookFromAggregatorSuccessfulResponse(custRFBAggtRes.getDataList());
                if(!rfbUnSuccessfulList.isEmpty()){
                    errorMsg=TRANSACTION_FAILED;
                    for(String str :rfbUnSuccessfulList){
                        errorMsg=errorMsg+' ; '+str;
                    }
                    LoggingService.logHandledException(new CustomerAggregatorException(errorMsg), CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
                }

            } 
            jsonMap.put('rfbSuccessfulList',rfbSuccessfulList);
            jsonMap.put('rfbUnSuccessfulList',rfbUnSuccessfulList);
            System.debug(LoggingLevel.INFO, 'jsonMap -->> '+jsonMap);
        }catch(Exception exp) {
            string errorMsg=ENTIRE_TRANSACTION_FAILED;
            exp.setMessage(errorMsg);
            LoggingService.logHandledException(exp, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
            throw new AuraHandledException (exp.getMessage());
        }
        return jsonMap;
    }
}