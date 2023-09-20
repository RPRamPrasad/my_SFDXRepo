/**
@Author: Team AKITA
@Name: HLPR_LWC_NewOpportunityWorkflow
@CreateDate: 10/15/2019
@Description: This class is used has a Helper for LWC_NewOpportunityWorkflow
@Version 1.0
Copyright © StateFarm
Version     Author       Date                      Description
1.1         Akita    01-08-2020    Added performCreate method to create opportunities
1.2         Opptimizers 6/28/2022  added isOppQuoteCanvasable method
*/
/**
 * @description HLPR_LWC_NewOpportunityWorkflow
 */
public with sharing class HLPR_LWC_NewOpportunityWorkflow {
    static final String TILDE = '~';
    static final String CLASS_NAME = 'HLPR_LWC_NewOpportunityWorkflow';
    static final String METHOD_NAME  = 'performCreate';

    /**
     * @description : Method to get the LoggedInUser Information.
     * @return User : LoggedIn User Details.
     */
    public static User getLoggedInUser(){
        User userRecord;
        String userId = userInfo.getUserId();
        List<User> userlist = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id,Name,Associate_ID__c,ProfileId,Profile.Name FROM User WHERE Id = :userId Limit 1]
        )
            .getRecords();
        if(!Userlist.isEmpty()){
            userrecord = Userlist.get(0);
        }
        return userrecord;
    }

    /**
     * @description : Method to get the LoggedInUser Profile Name.
     * @return String : LoggedInUser information for agent.
     */
    public static String getLoggedInUserProfileName(){
        return new HLPR_LWC_NewOpportunityWorkflow_Wrapper().getLoggedInUserProfileName();
    }

    /**
     * @description : Method to query Account Information.
     * @param accountId
     * @return Account : Account Details.
     */
    public static Account getAccountRecord(Id accountId) {
        String accId = accountId;
        Account accountRecord;
        List<Account> accountList = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id,name,ClientIdentifier__c,recordType.name FROM Account WHERE Id = :accId Limit 1]
        )
            .getRecords();

        if(!accountList.isEmpty()){
            accountRecord = accountList.get(0);
        }
        return accountRecord;
    }

	 /**
     * @description : Method to query Agent Roles.
     * @param accId
     * @return List<AgentRole__c> : list of Agent Roles related to Account.
     */
    public static  List<AgentRole__c> getAgentRoleOptions(Id accId) {
        String accountId = accId;
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('AccountId', accountId, Account.class);
        return [SELECT id, Agent__r.Name, Agent__r.Alias, Agent__r.Associate_ID__c, Agent__r.Id
                FROM AgentRole__c WHERE Customer__c =: accountId WITH SECURITY_ENFORCED ORDER BY Agent__r.Name];
    }

    /**
     * @description : Method to query Agent Context Options.
     * @param accId
     * @param usrId
     * @return List<AgentContext__c> : list of Agent Context Options related to Account.
     */
    public static  List<AgentContext__c> getAgentContextOptions(Id accId, Id usrId) {
        String accountId = accId;
        String userId = usrId;
        List<AgentContext__c> agentContextOptions = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id,Agent__r.Name,Agent__r.Alias,Agent__r.Associate_ID__c,Agent__r.Id  FROM AgentContext__c WHERE Customer__c =:accountId and CCCRepresentative__c =:userId]
        )
            .getRecords();
        return agentContextOptions;
    }

    /**
     * @description : Method to Upsert the Selected Agent Context.
     * @param paramAgentAssociateID
     * @param paramLoggedInUserAssociateID
     * @param accountInfo
     */
    public static void upsertAgentContext(String paramAgentAssociateID, String paramLoggedInUserAssociateID, Account accountInfo){

        AgentContext__c agentContext = new AgentContext__c(Customer__c = accountInfo.id,
                                                           CCCRepresentative__c = userInfo.getUserId(), Agent__r = new User(UserExternalID__c = paramAgentAssociateID+'_'+paramAgentAssociateID),
                                                           AgentContextIdentifier__c = paramLoggedInUserAssociateID + TILDE + accountInfo.ClientIdentifier__c);

        Schema.SObjectField idField = AgentContext__c.Fields.AgentContextIdentifier__c;

        Database.upsert( Security.stripInaccessible(AccessType.UPSERTABLE, new List<AgentContext__c> {agentContext}).getRecords(),idField);

    }

    /**
     * @description : Method to get priority Lob list
     * @return List<CM_LOB_Priority_Mapping__mdt> : list of LOB's w.r.t priority.
     */
    public static  List<CM_LOB_Priority_Mapping__mdt> getPriorityLob() {
        List<CM_LOB_Priority_Mapping__mdt> lobPriorityList = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id,Label,Priority__c FROM CM_LOB_Priority_Mapping__mdt WHERE Priority__c!=null order by Priority__c asc]
        )
            .getRecords();
        return lobPriorityList;
    }

    /**
     * @description : Method to insert oppportunities and throw exception
     * @param itemsToCreate
     */
    public static void performCreate(List<Opportunity> itemsToCreate) {
        new HLPR_LWC_NewOpportunityWorkflow_Wrapper().performCreate(itemsToCreate);
    }

    /**
     * @description : Method to insert oppportunities and throw exception
     * @param itemToUpdate
     */
    public static void performUpdate(Opportunity itemToUpdate) {
        update Security.stripInaccessible(AccessType.UPDATABLE, new List<Opportunity> {itemToUpdate}).getRecords();
    }

    /**
     * @description queries isQuoteCanvasable__c field on Opp object
     * @param oppId
     * @return boolean
     */
    @AuraEnabled
    public Static String isOppQuoteCanvasable(String oppId){
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('oppId', oppId, Opportunity.class);
        boolean isOppQuoteCanvasable = false;
        List<Opportunity> oppRecord = Security.stripInaccessible(AccessType.READABLE, [SELECT isQuoteCanvasable__c, StageName, AdditionalOwner__r.clientidentifier__c FROM Opportunity WHERE Id=:oppId LIMIT 1]).getRecords();
        if(!oppRecord.isEmpty()) {
            isOppQuoteCanvasable = oppRecord[0].isQuoteCanvasable__c;
            if(isOppQuoteCanvasable && oppRecord[0].StageName == 'Quoting'){
                LWC_OppUpdateOnQuoting.hideIntermediateScreen(Id.valueOf(oppId),true);
            }
        }
        
        String appName = HLPR_OppButtonNavController.getApplicationName();

        return ((isOppQuoteCanvasable) ? 'true' : 'false')+';'+appName+';'+ (String.isNotEmpty(oppRecord[0].AdditionalOwner__r.clientidentifier__c) ? oppRecord[0].AdditionalOwner__r.clientidentifier__c : '');
    }

    private with sharing class HLPR_LWC_NewOpportunityWorkflow_Wrapper{
        private String getLoggedInUserProfileName(){
            return [select id, name from profile where id=:UserInfo.getProfileId()].get(0).Name;
        }

        private void performCreate(List<Opportunity> itemsToCreate) {
            if(!itemsToCreate.isEmpty()) {
                insert itemsToCreate;
            }
        }
    }
}