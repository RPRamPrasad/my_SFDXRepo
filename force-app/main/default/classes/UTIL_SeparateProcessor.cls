/**
@Author: ej13 & ehil Team Pike & Team Dream Builders
@CreatedDate: 9/01/2016
@Description: This class is responsible for having the sync between MPD database and SFDC. It takes the JSON response
              and accordingly separate the Original and New Customers
@Version <1.0>
@reference: StageOrchestrationProcessor

@Author: Loco-Motivated - Added C2C relationship and Refactor the code to reduce the number of SOQL and DML which could hit Governor Limit
@ModifiedDate: 6/20/2017
@Description: This class is responsible for having the sync between MPD database and SFDC. It takes the JSON response
              and accordingly separate the Original and New Customers
@Version <1.5>
@reference: StageOrchestrationProcessor

@Author: Club-Car - Added functionality to handle seperate of cases from original to new account, as case object is enabled as part of CCC
@ModifiedDate: 7/14/2017

@Version <2.0>
@reference: StageOrchestrationProcessor

@Author: Loco-Motivated - Added functionality to handle Group and GroupMember details for both clients
@ModifiedDate: 1/3/2018

@Author: Team Golden Spikes - Updated to handle original account planning conversation log record owner as SYSTEM_USER_REC_OWNER for no Book of Business match.
@ModifiedDate: 5/10/2018

@Author: Team Orca - Updated to clone Customer Initiated Cancellations to new account.
@ModifiedDate: 7/23/2018

@Author: Team Golden Spikes - Updated to handle original account simple conversation record owner as SYSTEM_USER_REC_OWNER for no Book of Business match.
@ModifiedDate: 08/10/2018

@Author: Team ITIC - Updated to handle original account campaign members for no Book of Business match.
@ModifiedDate: 09/18/2019

@Author: Team Club Car - Updated to handle signed written consent not duplicated from originial to new account.
@ModifiedDate: 12/21/2020
*/
/**
 * @description This class is responsible for having the sync between MPD database and SFDC
 */
public without sharing class UTIL_SeparateProcessor extends UTIL_StageOrchestrationProcessor {
    private static final String SELECT_STRING = 'SELECT ';
    private static final String TASK_STRING = 'Task';
    private static final String OPPORTUNITY_STRING = 'Opportunity';
    private static final String CASE_STRING = 'Case';
    private static final String CUSTOMER_INITIATED_CANCELLATIONS_STRING = 'CustomerInitiatedCancellations__c';
    private static final String TASK_SUBJECT = 'Customer Separate';
    private static final String TASK_STATUS = 'Not Started';
    private static final String TASK_PRIORITY = 'Normal';
    private static final String TASK_CATEGORY = 'Change';
    private static final String TASK_APPCODE = 'SFDC Customer Separate';
    private static final String TASK_DESCRIPTION = 'The Corporate Customer Data Quality team received information that this ECRM Account was comingled.  A separate has been completed. To ensure the accuracy of the your customer’s information, you may want to review the policy and personal information then close the task.  If you have any issues, please use the ECRM Request Separate button to submit an automated ticket to our group.';
    private static final String TASK_ACCOUNT_DESCRIPTION = ' This Task was duplicated due to a Client Separate.';
    private static final String ORDER_BY_CREATED = ' Order By CreatedDate';
    private static final String PHONE_NUMBER = 'Phone Number - ';
    private static final String EMAIL = 'Email - ';
    private static final String LANGUAGE = 'Language of Choice - ';
    private static final String ORGANIZATION = 'Organization Type - ';
    private static final String GENDER = 'Gender - ';
    private static final String MARITAL_STATUS = 'Marital Status -';
    private static final String NEW_LINE = ' \r\n';
    private static final String BLANK = '';
    private static final String METHOD_DELETE_AGENTROLE = 'deleteAgentRolesList()';
    private ID originalAccountContactID;
    private Map<Id,Id>  newAccountAgentProxyMap= new Map<Id,Id>();
    private Map<Id,Id> originalAccountAgentProxyMap = new Map<Id, Id>();
    
    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();

    /**
    * @description It takes StageOrchestration__c object and synchronizes the customer information
    * @param stageOrchestrationList
    * @throws StageProcessorException
    */
    public override void execute(List<StageOrchestration__c> stageOrchestrationList) {
        StageOrchestration__c stageOrchestration = stageOrchestrationList.get(0);
        Savepoint savePoint;
        try {
            savePoint = Database.setSavepoint();
            final AP_StageOrchestrationJSONParser jsonObject = parseJSON(stageOrchestration.Value__c);
            final String originalClientId = jsonObject.OrchestrationInfo.OrchestrationEventName.OrchestrationEventDetail
                .OrchestrationEventValues.ClientId1;
            final String newClientId = jsonObject.OrchestrationInfo.OrchestrationEventName.OrchestrationEventDetail
                .OrchestrationEventValues.ClientId2;
            List<String> clientIds = new List<string>{originalClientId,newClientId};
                // Added the map
                Map<String, Account> sfdcAcctMap = getAccountMap([SELECT Id, ExternalSourceSyncTime__c, ClientIdentifier__c, PersonContactId FROM Account
                                                                  WHERE ClientIdentifier__c in :clientIds]);
            if(String.isNotBlank(originalClientId) && String.isNotBlank(newClientId)) {
                List<Account> jsonAccounts = jsontoAccountConverter(jsonObject);
                List<Relationship__c> jsonC2CRelationshipList = jsontoC2CConverter(jsonObject); //Converting JSON for Customer Relationships Information
                handleAccountOperations(jsonAccounts, clientIds, sfdcAcctMap);
                // Retrieving accounts after upsert to get the latest data from SFDC
                List<Account> listOfSFDCAccounts = retrieveAccounts(clientIds);
                Account originalAccountRecordOnSFDC = getAccountFromListforGivenClient(originalClientId,listOfSFDCAccounts);
                Account newAccountRecordOnSFDC = getAccountFromListforGivenClient(newClientId,listOfSFDCAccounts);
                List<AgentRole__c> jsonAgentRoles = jsonAgentRoleConverter(jsonObject);
                HandleAgentroleWrapperList handleAgentroleOperationWrap = new HandleAgentroleWrapperList();
					handleAgentroleOperationWrap.jsonAgentRoles = jsonAgentRoles;
					handleAgentroleOperationWrap.originalClientId = originalClientId;
					handleAgentroleOperationWrap.newClientId = newClientId;
					handleAgentroleOperationWrap.sfdcOriginalAcnt = originalAccountRecordOnSFDC;
					handleAgentroleOperationWrap.sfdcNewAcnt = newAccountRecordOnSFDC;
				handleAgentroleOperations(handleAgentroleOperationWrap);
                boolean isC2CFailSafe=(stageOrchestration.ReprocessCount__c==UTIL_StageOrchestrationConstants.MAX_REPROCESS_COUNT);
                if (originalAccountRecordOnSFDC!=null && newAccountRecordOnSFDC!=null) {
                    callSyncProcess(originalAccountRecordOnSFDC,newAccountRecordOnSFDC);
                    C2CRelationshipsWrapperList removingC2CRelationshipWrap = new C2CRelationshipsWrapperList();
						removingC2CRelationshipWrap.originalC2CMasterList = originalAccountRecordOnSFDC.Relationships__r;
						removingC2CRelationshipWrap.originalC2CChildList = originalAccountRecordOnSFDC.Relationships1__r;
						removingC2CRelationshipWrap.newC2CMasterList = newAccountRecordOnSFDC.Relationships__r;
						removingC2CRelationshipWrap.newC2CChildList = newAccountRecordOnSFDC.Relationships1__r;
					removingC2CRelationships(removingC2CRelationshipWrap);
                    insertC2CRelationships(jsonC2CRelationshipList,isC2CFailSafe);
                    handleCustomerGroupingOperations(originalAccountRecordOnSFDC.Customer_Groupings__r, newAccountRecordOnSFDC.Customer_Groupings__r,jsonObject);
                    deleteProductsServicedByMe(originalAccountRecordOnSFDC.ProductsServicedByMe__r);
                    cloneCustomerInitiatedCancellationsForNewAccount(originalAccountRecordOnSFDC, newAccountRecordOnSFDC);
                }
            }
        } catch(Exception ex) {
            if(ex.getmessage()!=UTIL_StageOrchestrationConstants.INVALID_USER_NOT_FOUND){
                Database.rollback(savePoint);
            }
            throw new StageProcessorException(ex.getMessage(), ex);
        }
    }

    /**    * @description <This method is used to return matching account for list of account>
    * @name getAccountFromListforGivenClient
    * @param clientId
    * @param retrivedAccountsList
    * @return Account    */
    private Account getAccountFromListforGivenClient(String clientId,List<Account> retrivedAccountsList){
        Account matchingAccount;
        for(Account accountToMatch:retrivedAccountsList){
            if(accountToMatch.Clientidentifier__c.equals(clientId)){
               matchingAccount= accountToMatch;
            }
        }
        return matchingAccount;
    }

    /**    * @description <This method is used to retrieve Accounts using a SOQL query based on ClientID>
    * @name retrieveAccounts
    * @param clientIds
    * @return List of accounts    */
    private List<Account> retrieveAccounts(List<String> clientIds){
        List<Account> accountWithRelationshipRecords=[Select Id, ClientIdentifier__c, ExternalSourceSyncTime__c, Ownerid,PreferredSpokenLanguage__pc,RecordType.Name,PersonEmail,Phone,Gender__pc,MaritalStatus__pc, PersonContactId,
                                               (Select Id, AccountOne__c From Relationships__r),
                                               (Select Id, AccountTwo__c From Relationships1__r),
                                               (Select Id, Campaign.OwnerId From PersonCampaignMembers),
                                               (Select Id From Customer_Groupings__r),
                                               (Select Id, Agent__c, Staff__c from AssignedStaff__r),
                                               (Select Id, Agent__c From Planning_Conversation_Logs__r),
                                               (Select Id, Agent__r.Associate_Id__c From Simple_Conversations__r),
                                               (Select AgentRoleIdentifier__c, Agent__c, Agent__r.UserExternalID__c , Customer__c, RelationshipNature__c, Primary_Household__c FROM Agent_Roles__r),
                                               (Select Id from ProductsServicedByMe__r)
                                               From Account WHERE ClientIdentifier__c IN :clientIds];
        return accountWithRelationshipRecords;
    }

    /**    * @description <This method is used for deleting Customer Relationships>
    * @name removingC2CRelationships
    * @param removingC2CRelationshipWrapper    */
   private void removingC2CRelationships(C2CRelationshipsWrapperList removingC2CRelationshipWrapper){
	List<Relationship__c> originalC2CMasterList = removingC2CRelationshipWrapper.originalC2CMasterList;
	List<Relationship__c> originalC2CChildList = removingC2CRelationshipWrapper.originalC2CChildList;
	List<Relationship__c> newC2CMasterList = removingC2CRelationshipWrapper.newC2CMasterList;
	List<Relationship__c> newC2CChildList = removingC2CRelationshipWrapper.newC2CChildList;
        Set<Relationship__c> relationshipSetToDedupe = new Set<Relationship__c>();
        List<Relationship__c> dedupedRelationshipLstToDelete = new List<Relationship__C>();
        relationshipSetToDedupe.addAll(originalC2CMasterList);
        relationshipSetToDedupe.addAll(originalC2CChildList);
        relationshipSetToDedupe.addAll(newC2CMasterList);
        relationshipSetToDedupe.addAll(newC2CChildList);
        dedupedRelationshipLstToDelete.addAll(relationshipSetToDedupe);
        deleteRelationship(dedupedRelationshipLstToDelete);
    }

    private class C2CRelationshipsWrapperList{
        private List<Relationship__c> originalC2CMasterList;
        private List<Relationship__c> originalC2CChildList;
        private List<Relationship__c> newC2CMasterList;
		private List<Relationship__c> newC2CChildList;
    }

  /**    * @description <This method is used for deleting GroupMember details for existing client data
    * @name handleCustomerGroupingOperations
    * @param oldAccountGroupMemberList
    * @param newAccountGroupMemberList
    * @param jsonObject    */
    private void handleCustomerGroupingOperations(List<CustomerGroupMember__c> oldAccountGroupMemberList, List<CustomerGroupMember__c> newAccountGroupMemberList,final AP_StageOrchestrationJSONParser jsonObject){
        //checkin weather Grouping feature is Enable to transform
        boolean isFeatureEnabledToTransform=toggleContext.isActive(UTIL_Toggles.CUSTOMERGROUPINGS);
        if(isFeatureEnabledToTransform){
            removingGroupMemberDetails(oldAccountGroupMemberList, newAccountGroupMemberList);//Removing existing Group members
            upsertGroupDetails(jsonObject);//Upserting Group and Groupmember details from JSON
        }
    }

  /**    * @description <This method is used for deleting GroupMember details for existing client data
    * @name removingGroupMemberDetails
    * @param oldAccountGroupMemberList
    * @param newAccountGroupMemberList    */
    private void removingGroupMemberDetails(List<CustomerGroupMember__c> oldAccountGroupMemberList, List<CustomerGroupMember__c> newAccountGroupMemberList){
        List<CustomerGroupMember__c> groupMemberListToDelete=new List<CustomerGroupMember__c>();
        groupMemberListToDelete.addAll(oldAccountGroupMemberList);
        groupMemberListToDelete.addAll(newAccountGroupMemberList);
        deleteCustomerHouseholdGroupMember(groupMemberListToDelete);
    }

  /**    * @description helper method for getting List of Group and GroupMember Objects
    * @name upsertGroupDetails
    * @param jsonObject    */
    private void upsertGroupDetails(final AP_StageOrchestrationJSONParser jsonObject) {
        UTIL_OrchestrationJSONtoGroupDetails.HLPR_GroupAndGroupMemberWrapper
            groupDetails=UTIL_OrchestrationJSONtoGroupDetails.jsonGroupDetailsConverter(jsonObject);
        upsertCustomerHouseholdGroup(groupDetails.groupList);
        upsertCustomerHouseholdGroupMember(groupDetails.groupMemberList);
    }

    /**    * @description This method takes externalSyncTimes of SFDC Account and JSON Account to compare the two
    * @name isJsonCustomerExtSyncTimeNewer
    * @param sfdcExtSyncTime - external sync time existing in the server
    * @param jsonExtSyncTime - external sync time for the request
    * @return boolean - true if jsonExtSyncTime is newer    */
    private boolean isJsonCustomerExtSyncTimeNewer(final DateTime sfdcExtSyncTime, final DateTime jsonExtSyncTime) {
        return sfdcExtSyncTime < jsonExtSyncTime;
    }

    /**    * @description helper method to get accounts
    * @name getAccountMap
    * @param accountList - List of accounts
    * @return Map<String, Account> - map of ClientIdentifier as the key and account object as the value    */
    private Map<String, Account> getAccountMap(final List <Account> accountList) {
        Map<String, Account> accountMap = new Map<String, Account>();
        for(Account acct : accountList) {
            accountMap.put(acct.ClientIdentifier__c, acct);
        }
        return accountMap;
    }

    /**    * @description helper method for getting Planning Conversation Log List to update for the Original Account
    * @name getPlanningConversationLogListToUpdate
    * @param deleteAgentRoles - List of agent roles to be deleted
    * @param originalRecordPlanningConversationLogList - List of Planning Conversation Log related to the original client
    * @param systemUserId
    * @return List<PlanningConversationLog__c> - List of planning conversation log to update    */
    private List<PlanningConversationLog__c> getPlanningConversationLogListToUpdate(List<AgentRole__c> deleteAgentRoles, List<PlanningConversationLog__c> originalRecordPlanningConversationLogList, Id systemUserId) {
        List<PlanningConversationLog__c> planningConversationLogListToBeUpdated = new List<PlanningConversationLog__c>();
        if(originalRecordPlanningConversationLogList !=null && !originalRecordPlanningConversationLogList.isEmpty()) {
            Set<Id> delAgentIdSet = new Set<Id>();
            for(AgentRole__c delAgentRole: deleteAgentRoles) {
                delAgentIdSet.add(delAgentRole.Agent__c);
            }
            for(PlanningConversationLog__c originalRecordPlanningConversationLog: originalRecordPlanningConversationLogList) {
                if(delAgentIdSet.contains(originalRecordPlanningConversationLog.Agent__c)) {
                    originalRecordPlanningConversationLog.ownerId = systemUserId;
                    planningConversationLogListToBeUpdated.add(originalRecordPlanningConversationLog);
                }
            }
        }
        return planningConversationLogListToBeUpdated;
    }

    /**    * @description helper method for getting Simple Conversation List to update for the Original Account
    * @name getSimpleConversationListToUpdate
    * @param deleteAgentRoles - List of agent roles to be deleted
    * @param originalRecordSimpleConversationList - List of Simple Conversation related to the original client
    * @param systemUserId
    * @return List<SimpleConversation__c> - List of simple conversation to update    */
    private List<SimpleConversation__c> getSimpleConversationListToUpdate(List<AgentRole__c> deleteAgentRoles, List<SimpleConversation__c> originalRecordSimpleConversationList, Id systemUserId) {
        List<SimpleConversation__c> simpleConversationListToBeUpdated = new List<SimpleConversation__c>();
        if(originalRecordSimpleConversationList !=null && !originalRecordSimpleConversationList.isEmpty()) {
            Set<Id> delAgentIdSet = new Set<Id>();
            for(AgentRole__c delAgentRole: deleteAgentRoles) {
                delAgentIdSet.add(delAgentRole.Agent__c);
            }
            for(SimpleConversation__c originalRecordSimpleConversation: originalRecordSimpleConversationList) {
                if(delAgentIdSet.contains(originalRecordSimpleConversation.Agent__c)) {
                    originalRecordSimpleConversation.ownerId = systemUserId;
                    simpleConversationListToBeUpdated.add(originalRecordSimpleConversation);
                }
            }
        }
        return simpleConversationListToBeUpdated;
    }

    /**    * @description helper method for getting Assigned Staff List to delete
    * @name getAssignStaffListToDelete
    * @param deleteAgentRoles - List of agent roles to be deleted
    * @param originalRecordAssignStaffList - List of Assigned staff related to the original client
    * @return List<AssignedStaff__c> - List of assigned staff to delete    */
    private List<AssignedStaff__c> getAssignStaffListToDelete(List<AgentRole__c> deleteAgentRoles, List<AssignedStaff__c> originalRecordAssignStaffList){
        List<AssignedStaff__c> assignedStaffToDelete = new List<AssignedStaff__c>();
        if(!originalRecordAssignStaffList.isEmpty()){
            Set<Id> delAgentIds = new Set<Id>();
            for(AgentRole__c delAgentRole: deleteAgentRoles){
                delAgentIds.add(delAgentRole.Agent__c);
            }
            for(AssignedStaff__c originalAssignStaff: originalRecordAssignStaffList){
                if(delAgentIds.contains(originalAssignStaff.Agent__c)){
                    assignedStaffToDelete.add(originalAssignStaff);
                }
            }
        }
        return assignedStaffToDelete;
    }

    /**    * @description helper method for getting CampaignMember List to delete
    * @name getCampaignMembersToDelete
    * @param deleteAgentRoles - List of agent roles to be deleted
    * @param campaignMembersList - List of CampaignMembers related to the original client
    * @return List<CampaignMember> - List of CampaignMembers to delete    */
    private List<CampaignMember> getCampaignMembersToDelete(List<AgentRole__c> deleteAgentRoles, List<CampaignMember> campaignMembersList) {
        List<CampaignMember> campaignMembersToDelete = new List<CampaignMember>();
        if(!campaignMembersList.isEmpty()) {
            Set<Id> delAgentIds = new Set<Id>();
            for(AgentRole__c delAgentRole: deleteAgentRoles) {
                delAgentIds.add(delAgentRole.Agent__c);
            }
            List<Id> agentProxyId = UTIL_AgentOfficeDetails.getAgentProxyMapForGivenAgentIds(delAgentIds).values();
            for(CampaignMember campaignMember: campaignMembersList) {
                if(agentProxyId.contains(campaignMember.Campaign.OwnerId)) {
                    campaignMembersToDelete.add(campaignMember);
                }
            }
        }
        return campaignMembersToDelete;
    }

    /**    * @description helper method to update accounts
    * @name handleAccountOperations
    * @param jsonAccounts - List of accounts from parsed json object
    * @param clientIds
    * @param sfdcAcctMap Account>sfdcAcctMap - map of ClientIdentifier as the key and account object as the value    */
    private void handleAccountOperations(final List<Account> jsonAccounts, final List<String> clientIds, Map<String, Account> sfdcAcctMap) {
        Map<String, Account> jsonAcctMap = getAccountMap(jsonAccounts);
        List<Account> listOfAccountsToUpsert=new List<Account>();
        for(String clientId:clientIds){
            if (!sfdcAcctMap.containsKey(clientId)) {
                listOfAccountsToUpsert.add(jsonAcctMap.get(clientId));
            } else if (isJsonCustomerExtSyncTimeNewer(sfdcAcctMap.get(clientId).ExternalSourceSyncTime__c, jsonAcctMap.get(clientId).ExternalSourceSyncTime__c)) {
                listOfAccountsToUpsert.add(jsonAcctMap.get(clientId));
            }
        }
        upsertAccountsByClientIdentifier(listOfAccountsToUpsert);
    }

    /**    * @description helper function to update agent roles
    * @name handleAgentroleOperations
    * @param agentroleOperationWrapper    */
   private void handleAgentroleOperations(HandleAgentroleWrapperList agentroleOperationWrapper) {
	final List<AgentRole__c> jsonAgentRoles = agentroleOperationWrapper.jsonAgentRoles;
	Account sfdcOriginalAcnt = agentroleOperationWrapper.sfdcOriginalAcnt;
	Account sfdcNewAcnt = agentroleOperationWrapper.sfdcNewAcnt;
        Id systemUserId = getSystemRecordOwnerId();
        List<AgentRole__c> newCustomerAgentRoles = getjsonAgentRolesForAccount(jsonAgentRoles, sfdcNewAcnt);
        List<AgentRole__c> originalCustomerAgentRoles = getjsonAgentRolesForAccount(jsonAgentRoles, sfdcOriginalAcnt);
        List<AgentRole__c> sfdcAgentRoles = sfdcOriginalAcnt.Agent_Roles__r;
        List<AgentRole__c> upsertAgentRoles = getUpsertAgentRoles(originalCustomerAgentRoles, sfdcAgentRoles);
        List<AgentRole__c> deleteAgentRoles = getDeleteAgentRoles(originalCustomerAgentRoles, sfdcAgentRoles);
        upsertAgentRoles.addAll(newCustomerAgentRoles);
        if (!upsertAgentRoles.isEmpty()) {
            upsertUserAgentRoles(upsertAgentRoles);
        }
        populateOriginalAndNewCustomerAgentIds(originalCustomerAgentRoles, newCustomerAgentRoles);
        if (!deleteAgentRoles.isEmpty()) {
            deleteAssignedStaff(getAssignStaffListToDelete(deleteAgentRoles, sfdcOriginalAcnt.AssignedStaff__r));
            updatePlanningConversationLog(getPlanningConversationLogListToUpdate(deleteAgentRoles, sfdcOriginalAcnt.Planning_Conversation_Logs__r, systemUserId));
            updateSimpleConversation(getSimpleConversationListToUpdate(deleteAgentRoles, sfdcOriginalAcnt.Simple_Conversations__r, systemUserId));
            UTIL_CampaignMemberDAO.deleteCampaignMembers(getCampaignMembersToDelete(deleteAgentRoles, sfdcOriginalAcnt.PersonCampaignMembers));
            deleteAgentRolesList(deleteAgentRoles);
        }
    }

    private class HandleAgentroleWrapperList{
        private List<AgentRole__c> jsonAgentRoles;
        private String originalClientId;
        private String newClientId;
		private Account sfdcOriginalAcnt;
		private Account sfdcNewAcnt;
    }
    /**    * @description function to create a map of agent ids and proxy ids for both original and new customers
    * @name populateOriginalAndNewCustomerAgentIds
    * @param originalCustomerAgentRoles - List of AgentRole__c of original customer
    * @param newCustomerAgentRoles - List of AgentRole__c of original customer    */
    private void populateOriginalAndNewCustomerAgentIds(List<AgentRole__c> originalCustomerAgentRoles, List<AgentRole__c> newCustomerAgentRoles){
        List<String> originalUserExternalIdsList = new List<String>();
        List<String> newUserExternalIdsList = new List<String>();
        for (Agentrole__c agentrole : newCustomerAgentRoles){
            newUserExternalIdsList.add(agentrole.Agent__r.userExternalid__c);
        }
        for (Agentrole__c agentrole : originalCustomerAgentRoles){
            originalUserExternalIdsList.add(agentrole.Agent__r.userExternalid__c);
        }
        Set<String> userExternalIdsSet = new Set<String>();
        userExternalIdsSet.addAll(newUserExternalIdsList);
        userExternalIdsSet.addAll(originalUserExternalIdsList);
        Map<String, Id> proxyExternalIdAgentMap = new Map<String, Id>();
        Map<String, String> proxyExternalIdExternalIdMap = new Map<String, String>();
        List<User> agentUsersList = Security.stripInaccessible(AccessType.READABLE,[Select Id, UserExternalId__c, Proxy_External_ID__c From User Where UserExternalId__c in : userExternalIdsSet]).getRecords();
        for(User agentUser : agentUsersList){
            proxyExternalIdAgentMap.put(agentUser.Proxy_External_ID__c, agentUser.Id);
            proxyExternalIdExternalIdMap.put(agentUser.Proxy_External_ID__c, agentUser.UserExternalID__c);
        }
        List<User> proxyUsersList = Security.stripInaccessible(AccessType.READABLE,[Select id,UserExternalID__c from User where UserExternalID__c=:ProxyExternalIdAgentMap.keySet()]).getRecords();
        for(User proxyUser : proxyUsersList){
            if(newUserExternalIdsList.contains(proxyExternalIdExternalIdMap.get(proxyUser.UserExternalID__c))){
                newAccountAgentProxyMap.put(proxyExternalIdAgentMap.get(proxyUser.UserExternalID__c),proxyUser.Id );
            }
            if(originalUserExternalIdsList.contains(proxyExternalIdExternalIdMap.get(proxyUser.UserExternalID__c))){
                originalAccountAgentProxyMap.put(proxyExternalIdAgentMap.get(proxyUser.UserExternalID__c),proxyUser.Id );
            }
        }
    }
    /**    * @description helper method for getting new agent roles depending on the ID
    * @name getjsonAgentRolesForAccount
    * @param parsedAgentRoles - List of parsed agent roles
    * @param sfdcAccount - Salesforce Account - It could be Original or New depending upon call
    * @return List<AgentRole__c> - List of new agent roles    */
    private List<AgentRole__c> getjsonAgentRolesForAccount(final List<AgentRole__c> parsedAgentRoles, Account sfdcAccount) {
        List<AgentRole__c> agentRoles = new List<AgentRole__c>();
        for(AgentRole__c parsedAgentRole : parsedAgentRoles) {
            if (sfdcAccount != null && sfdcAccount.ClientIdentifier__c.equals(parsedAgentRole.Customer__r.ClientIdentifier__c)) {
                agentRoles.add(parsedAgentRole);
            }
        }
        return agentRoles;
    }

    /**    * @description helper method to get list of upserted agent roles
    * @name getUpsertAgentRoles
    * @param parsedAgentRoles - List of parsed agent roles
    * @param sfdcAgentRoles - List of SFDC agent roles
    * @return List of upserted agent roles    */
    private List<AgentRole__c> getUpsertAgentRoles(final List<AgentRole__c> parsedAgentRoles, final List<AgentRole__c> sfdcAgentRoles) {
        List<AgentRole__c> upsertAgentRoles = new List<AgentRole__c>();
        Map<String, AgentRole__c> sfdcAgentRoleMap = new Map<String, AgentRole__c>();
        for(AgentRole__c sfdcAgentRole : sfdcAgentRoles) {
            sfdcAgentRoleMap.put(sfdcAgentRole.AgentRoleIdentifier__c, sfdcAgentRole);
        }
        for(AgentRole__c jsonRole : parsedAgentRoles) {
            if(!sfdcAgentRoleMap.containsKey(jsonRole.AgentRoleIdentifier__c)) {
                upsertAgentRoles.add(jsonRole);
            } else {
                String sfdcAgent = sfdcAgentRoleMap.get(jsonRole.AgentRoleIdentifier__c).Agent__r.UserExternalID__c;
                String sfdcRelationship = sfdcAgentRoleMap.get(jsonRole.AgentRoleIdentifier__c).RelationshipNature__c;

                if(!jsonRole.Agent__r.UserExternalID__c.equals(sfdcAgent) || !jsonRole.RelationshipNature__c.equals(sfdcRelationship)) {
                    upsertAgentRoles.add(jsonRole);
                }
            }
        }
        return upsertAgentRoles;
    }

    /**    * @description helper method to get list of deleted agent roles
    * @name getDeleteAgentRoles
    * @param parsedAgentRoles - List of parsed agent roles
    * @param sfdcAgentRoles - List of SFDC agent roles
    * @return List of deleted agent roles    */
    private List<AgentRole__c> getDeleteAgentRoles(final List<AgentRole__c> parsedAgentRoles, final List<AgentRole__c> sfdcAgentRoles) {
        List<AgentRole__c> deleteAgentRoles = new List<AgentRole__c>();
        Map<String, AgentRole__c> jsonAgentRoleMap = new Map<String, AgentRole__c>();
        for(AgentRole__c jsonAgentRole : parsedAgentRoles) {
            jsonAgentRoleMap.put(jsonAgentRole.AgentRoleIdentifier__c, jsonAgentRole);
        }
        for(AgentRole__c sfdcRole : sfdcAgentRoles) {
            if(!jsonAgentRoleMap.containsKey(sfdcRole.AgentRoleIdentifier__c)) {
                deleteAgentRoles.add(sfdcRole);
            }
        }
        return deleteAgentRoles;
    }

    /**    * @description This method associates original account chatter posts and tasks to new account
    * @param originalAccountId originalAccount - Original Account (ClientId1)
    * @param newAccountId newAccount - New Account (ClientId2)    */
    private void duplicateFeedItemsOnOriginalAccount(final ID originalAccountId, final ID newAccountId) {
        List<FeedItem> mInsertNewFeedItem = new List<FeedItem>();
        Set<ID> orginalAccountIDs = new Set<ID>();
        orginalAccountIDs.add(originalAccountId);
        for(FeedItem originalFeed : UTIL_DuplicateTasks.retrieveFeedItems(orginalAccountIDs)) {
            if(!String.isEmpty(originalFeed.Body)) {
               mInsertNewFeedItem.add(UTIL_DuplicateTasks.cloneTaskFeed(originalFeed, newAccountId));
            }
        }
        insertFeedItems(mInsertNewFeedItem);
    }
    /**    * @description This method associates original account Tasks to new account
    * @name getTaskOnOriginalAccountWithWhatIDAndWhoID
    * @param accountWithWhatIDAndWhoIDWrapper    */
    private void getTaskOnOriginalAccountWithWhatIDAndWhoID(GetTaskOnOriginalAccountWrapperList accountWithWhatIDAndWhoIDWrapper) {
	    Account originalAccount = accountWithWhatIDAndWhoIDWrapper.originalAccount;
	    Account newAccount = accountWithWhatIDAndWhoIDWrapper.newAccount;
	    Set<ID> associatedTaskIds = accountWithWhatIDAndWhoIDWrapper.associatedTaskIds;
	    boolean isWhat = accountWithWhatIDAndWhoIDWrapper.isWhat;
        Map<ID,Task> newTaskMap = new Map<ID,Task>();
        List<Task> originalTaskList = new List<Task>();
        SObjectType taskType = Schema.getGlobalDescribe().get(TASK_STRING);
        Map<String,Schema.SObjectField> taskfieldsMap = taskType.getDescribe().fields.getMap();
        originalAccountContactID = originalAccount.PersonContactId;
        ID newAccountContactID = newAccount.PersonContactId;
        String selectQuery = SELECT_STRING;
        for (String fieldName : taskfieldsMap.keySet()) {
            selectQuery+= fieldName+' , ';
        }
        String taskIDAsString = '';
        if(associatedTaskIds != null) {
           taskIDAsString = convertSetOfIDSAsString(associatedTaskIds);
        }
        if(isWhat) {
             selectQuery = selectQuery.substringBeforeLast(', ') + ' from Task where whatId = \''+ String.escapeSingleQuotes(originalAccount.Id) +'\' AND IsClosed=false AND isRecurrence=false';
        } else {
            selectQuery = selectQuery.substringBeforeLast(', ') + ' from Task where whatId != \''+ String.escapeSingleQuotes(originalAccount.Id) +'\' AND whoID = \''+
                String.escapeSingleQuotes(originalAccountContactID)+ '\' AND IsClosed=false AND isRecurrence=false';
            if(String.isNotEmpty(taskIDAsString)) {
                selectQuery=selectQuery + ' AND Id NOT IN ('+taskIDAsString +')';
            }
        }
        selectQuery = selectQuery + ORDER_BY_CREATED;
        originalTaskList = Database.query(selectQuery);
        for(Task originalTask : originalTaskList) {
            if(newAccountAgentProxyMap.values().contains(originalTask.ownerid) || newAccountAgentProxyMap.KeySet().contains(originalTask.ownerid)){
                 newTaskMap.put(originalTask.Id, populateNewTask(originalTask, isWhat, newAccount));

            }
        }
        if(!newTaskMap.isEmpty()) {
            insertTasks(newTaskMap.values());
            UTIL_DuplicateTasks.prepareTaskRelationForTask(newAccountContactID, newTaskMap,originalAccountContactID);
            UTIL_DuplicateTasks.createTaskFeeds(newTaskMap, originalTaskList);
        }
    }

    private class GetTaskOnOriginalAccountWrapperList{
        private Account originalAccount;
        private Account newAccount;
        private Set<ID> associatedTaskIds;
		private boolean isWhat;
    }

    /**    * @description This method associates Original Account Opportunity to New Account
    * @name populateNewTask
    * @param originalTask - Task on original account
    * @param isWhat
    * @param newAccount - New Account (ClientId2)
    * @return Task    */
    private Task populateNewTask(Task originalTask, boolean isWhat, Account newAccount){
        Task newTask = originalTask.clone();
        if(isWhat) {
            newTask.WhatId = newAccount.ID;
            if(isWhoIDWithOldAccount(originalTask.WhoId, originalAccountContactID)) {
                newTask.WhoId = newAccount.PersonContactId;
            }
        } else {
            newTask.WhoId = newAccount.PersonContactId;
        }
        newTask.Description = (String.isNotBlank(newTask.Description) ? newTask.Description + ' ( '+originalTask.CreatedDate.format() + TASK_ACCOUNT_DESCRIPTION +' )' : ' ( '+originalTask.CreatedDate.format() + TASK_ACCOUNT_DESCRIPTION +' )');
        return newTask;
    }

    /**
    * @description This method associates Original Account Opportunity to New Account
    * @name getOpportunityOnOriginalAccount
    * @param originalAccount - Original Account (ClientId1)
    * @param newAccount - New Account (ClientId2)
    * @return Map<ID, Task>
    */
    private Map<ID, Task> getOpportunityOnOriginalAccount(Account originalAccount, Account newAccount) {
        Map<ID, Task> tasksFromOriginalOpportunity = new Map<ID, Task>();
        Map<ID, Opportunity> newOpportunityMap = new Map<ID, Opportunity>();
        SObjectType opportunityType = Schema.getGlobalDescribe().get(OPPORTUNITY_STRING);
        Map<String, Schema.SObjectField> taskfieldsMap = opportunityType.getDescribe().fields.getMap();
        String selectQuery = SELECT_STRING;
        for(String fieldName : taskfieldsMap.keySet()) {
            selectQuery += fieldName + ' , ';
        }
        selectQuery = selectQuery.substringBeforeLast(', ') + ' from Opportunity where AccountId = ';
        List<Opportunity> originalOpportunityList = Database.query(String.escapeSingleQuotes(selectQuery)
                                                                    +'\'' + +String.escapeSingleQuotes(originalAccount.id) + '\'');
        if (originalOpportunityList != null && !originalOpportunityList.isEmpty()) {
            for(Opportunity originalOpportunity: originalOpportunityList) {
                if(newAccountAgentProxyMap.values().contains(originalOpportunity.ownerid) || newAccountAgentProxyMap.keySet().contains(originalOpportunity.ownerid)){
                    Opportunity newOpportunity =  originalOpportunity.clone();
                    newOpportunity.AccountId = newAccount.id;
                    newOpportunity = UTIL_AccountProcessorsSwcHandler.updateOpportunitySwc(newOpportunity);
                    newOpportunityMap.put(originalOpportunity.id, newOpportunity);
                }
            }
        }
        if(!newOpportunityMap.isEmpty()) {
            insertOpportunityForAccount(newOpportunityMap.values());
            associateOpportunityFeedToNewOpportunity(originalOpportunityList, newOpportunityMap);
            UTIL_DuplicateTasks.DuplicateTasksWrapperList taskOnOpportunitsWrap = new UTIL_DuplicateTasks.DuplicateTasksWrapperList();
		        taskOnOpportunitsWrap.originalAccount = originalAccount;
		        taskOnOpportunitsWrap.newAccount = newAccount;
		        taskOnOpportunitsWrap.originalOpportunityList = originalOpportunityList;
		        taskOnOpportunitsWrap.addedNewOpportunitysMap = newOpportunityMap;
	        tasksFromOriginalOpportunity = UTIL_DuplicateTasks.duplicateTasksOnOpportunits(taskOnOpportunitsWrap);
        }
        return tasksFromOriginalOpportunity;
    }

    private void cloneCustomerInitiatedCancellationsForNewAccount(Account originalAccount, Account newAccount) {
        List<CustomerInitiatedCancellations__c> newCICs = new List<CustomerInitiatedCancellations__c>();
        SObjectType cICType = Schema.getGlobalDescribe().get(CUSTOMER_INITIATED_CANCELLATIONS_STRING);
        Map<String,Schema.SObjectField> cICfieldsMap = cICType.getDescribe().fields.getMap();
        String selectQuery = SELECT_STRING;
        for (String fieldName : cICfieldsMap.keySet()) {
            selectQuery+= fieldName+' , ';
        }

        selectQuery = selectQuery.substringBeforeLast(', ') + ' from CustomerInitiatedCancellations__c where Customer__c = ';
        List<CustomerInitiatedCancellations__c> originalCICs = Database.query(String.escapeSingleQuotes(selectQuery)
                                                                                + '\'' + String.escapeSingleQuotes(originalAccount.id) + '\'');

        if (originalCICs != null && !originalCICs.isEmpty()) {
            for(CustomerInitiatedCancellations__c originalCIC : originalCICs) {
                CustomerInitiatedCancellations__c newCIC =  originalCIC.clone();
                newCIC.Customer__c = newAccount.id;
                newCICs.add(newCIC);
            }

            if (newCICs != null && !newCICs.isEmpty()) {
                insertCustomerInitiatedCancellation(newCICs);
            }
        }
    }

    /**
    * @description This method associates OppertunityFeed to  New Oppertunity under new Account
    * @name associateOpportunityFeedToNewOpportunity
    * @param orginalOpportunityList - List of Original Opportunity
    * @param addedNewOpportunitysMap -  Map of new opportunity
    */
    private void associateOpportunityFeedToNewOpportunity(List<Opportunity> orginalOpportunityList, Map<Id, Opportunity> addedNewOpportunitysMap) {
        Map<ID, List<FeedItem>> originalOpportunityFeeds = new Map<ID, List<FeedItem>>();
        List<FeedItem> newOpportunityFeedItemList;
        List<FeedItem> allNewOpportunityFeedItemList = new List<FeedItem>();

        for(FeedItem feed : UTIL_DuplicateTasks.retrieveFeedItems(addedNewOpportunitysMap.keySet()) ) {
            if(feed.Body != null) {
                if(!originalOpportunityFeeds.containsKey(feed.ParentID)) {
                    originalOpportunityFeeds.put(feed.ParentID, new List<FeedItem>());
                    originalOpportunityFeeds.get(feed.ParentID).add(feed);
                } else {
                    originalOpportunityFeeds.get(feed.ParentID).add(feed);
                }
            }
        }
        for(Opportunity orignalOpportunity : orginalOpportunityList) {
            if(originalOpportunityFeeds.get(orignalOpportunity.Id) != null) {
                newOpportunityFeedItemList = prepareOpportunityFeeds(orignalOpportunity, originalOpportunityFeeds, addedNewOpportunitysMap);
                if(!newOpportunityFeedItemList.isEmpty()) {
                    allNewOpportunityFeedItemList.addAll(newOpportunityFeedItemList);
                }
            }
        }
        if(!allNewOpportunityFeedItemList.isEmpty()) {
            insertFeedItems(allNewOpportunityFeedItemList);
        }
    }
    /**
    * @description This method creates the new OppertunityFeeds to  New Opportunity under new Account
    * @name prepareOpportunityFeeds
    * @param originalOpportunity  -Original Opportunity
    * @param originalOpportunityFeeds  -Map of lis of orginal feeds
    * @param addedNewOpportunitysMap  -Map of created new Opportunities
    * @return List<FeedItem>
    */
    private List<FeedItem> prepareOpportunityFeeds(Opportunity originalOpportunity, Map<ID, List<FeedItem>> originalOpportunityFeeds, Map<Id,Opportunity> addedNewOpportunitysMap) {
        List<FeedItem> newOpportunityFeedItemList = new List<FeedItem>();
        for(FeedItem opportunityFeed : originalOpportunityFeeds.get(originalOpportunity.Id)) {
            if(!String.isEmpty(opportunityFeed.Body)) {
               newOpportunityFeedItemList.add(UTIL_DuplicateTasks.cloneTaskFeed(opportunityFeed, addedNewOpportunitysMap.get(originalOpportunity.Id).Id));
            }
        }
        return newOpportunityFeedItemList;
    }

    /**
    * @description This method associates Original Account Cases to New Account
    * @name getCaseOnOriginalAccountAndCreateNewCasesWithNewAccount
    * @param originalAccount - Original Account (ClientId1)
    * @param newAccount - New Account (ClientId2)
    * @return void
    */
    private Map<ID, Task> getCaseOnOriginalAccountAndCreateNewCasesWithNewAccount(Account originalAccount, Account newAccount) {
        Map<ID, Task> tasksFromOriginalCase = new Map<ID, Task>();
        Map<ID, Case> newCaseMap = new Map<ID, Case>();
        ID newAccountContactID = newAccount.PersonContactId;
        SObjectType caseType = Schema.getGlobalDescribe().get(CASE_STRING);
        Map<String, Schema.SObjectField> casefieldsMap = caseType.getDescribe().fields.getMap();
        String selectQuery = SELECT_STRING;
        for(String fieldName : casefieldsMap.keySet()) {
            selectQuery += fieldName + ' , ';
        }
        selectQuery = selectQuery.substringBeforeLast(', ') + ' from Case where AccountId = ';
        List<Case> originalCaseList = Database.query(String.escapeSingleQuotes(selectQuery)
                                            +'\'' + String.escapeSingleQuotes(originalAccount.id) + '\'');
        if (originalCaseList != null && !originalCaseList.isEmpty()) {
            for(Case originalCase: originalCaseList) {
                if(newAccountAgentProxyMap.values().contains(originalCase.ownerid) || newAccountAgentProxyMap.keySet().contains(originalCase.ownerid)){
                    Case newCase =  originalCase.clone();
                    newCase.AccountId = newAccount.id;
                    newCase.ContactId = newAccountContactID;
                    newCaseMap.put(originalCase.id, newCase);
                }
            }
        }
        if(!newCaseMap.isEmpty()) {
            UTIL_CaseDAO.insertcases(newCaseMap.values());
            associateOldCasesFeedToNewCases(originalCaseList, newCaseMap);
            UTIL_DuplicateTasks.CasesWrapperList casesOpportunitWrap = new UTIL_DuplicateTasks.CasesWrapperList();
		        casesOpportunitWrap.originalAccount = originalAccount;
		        casesOpportunitWrap.newAccount = newAccount;
		        casesOpportunitWrap.originalCasesList = originalCaseList;
		        casesOpportunitWrap.addedNewCasesMap = newCaseMap;
	        tasksFromOriginalCase = UTIL_DuplicateTasks.duplicateTasksOnCases(casesOpportunitWrap);
        }
        return tasksFromOriginalCase;
    }

    /**
    * @description This method associates Case Feed to  New Case under new Account
    * @name associateOldCasesFeedToNewCases
    * @param orginalAccountCaseList - List of Original Case
    * @param addedNewCasesMap -  Map of new case
    */
    private void associateOldCasesFeedToNewCases(List<Case> orginalAccountCaseList, Map<Id, Case> addedNewCasesMap) {
        Map<ID, List<FeedItem>> originalCaseFeeds = new Map<ID, List<FeedItem>>();
        List<FeedItem> newCasesFeedItemList;
        List<FeedItem> allNewCaseFeedItemList = new List<FeedItem>();
        //get feeds on original account cases
        List<FeedItem> originalCaseFeedItemsList = UTIL_DuplicateTasks.retrieveFeedItems(addedNewCasesMap.keySet());
        for(FeedItem feed : originalCaseFeedItemsList) {
            if(feed.Body != null) {
                if(!originalCaseFeeds.containsKey(feed.ParentID)) {
                    originalCaseFeeds.put(feed.ParentID, new List<FeedItem>());
                    originalCaseFeeds.get(feed.ParentID).add(feed);
                } else {
                    originalCaseFeeds.get(feed.ParentID).add(feed);
                }
            }
        }
        for(Case orignalCase : orginalAccountCaseList) {
            if(originalCaseFeeds.get(orignalCase.Id) != null) {
                newCasesFeedItemList = prepareCaseFeeds(orignalCase, originalCaseFeeds, addedNewCasesMap);
                allNewCaseFeedItemList.addAll(newCasesFeedItemList);
            }
        }
        if(!allNewCaseFeedItemList.isEmpty()) {
            insertFeedItems(allNewCaseFeedItemList);
        }
    }

    //This method creates the new CaseFeeds to  New Case under new Account
    private List<FeedItem> prepareCaseFeeds(Case orignalCase, Map<ID, List<FeedItem>> originalCaseFeeds, Map<Id,Case> addedNewCasesMap) {
        List<FeedItem> newCaseFeedItemList = new List<FeedItem>();
        for(FeedItem caseFeed : originalCaseFeeds.get(orignalCase.Id)) {
            if(!String.isEmpty(caseFeed.Body)) {
               newCaseFeedItemList.add(UTIL_DuplicateTasks.cloneTaskFeed(caseFeed, addedNewCasesMap.get(orignalCase.Id).Id));
            }
        }
        return newCaseFeedItemList;
    }

    /**
    * @description This method creates the new 'Separate Task' for Agnets respective to  Original and New Account
    * @name createTaskForNotificationOnOrginalAndNewCustomer
    * @param originalAccount
    * @param newAccount
    */
    public void createTaskForNotificationOnOrginalAndNewCustomer(Account originalAccount, Account newAccount) {
        List<Task> lOrginalAccountAgentTask = new List<Task>();
        List<Task> lNewAccountAgentTask = new List<Task>();
        List<Task> lAllAgentTask = new List<Task>();
        Id newAccountContactID=newAccount.PersonContactId;
        Id originalAccountContact=originalAccount.PersonContactId;

        String description = makeDescriptionField(originalAccount);
        List<AgentRole__c> agentRoleOriginalAccount=[SELECT Agent__c,Customer__c FROM AgentRole__c WHERE Customer__c IN (:originalAccount.id,:newAccount.id)
                                                     AND RelationshipNature__c =:UTIL_StageOrchestrationConstants.CUSTOMER];

        if(agentRoleOriginalAccount!=null && !agentRoleOriginalAccount.isEmpty()){
            OldAndNewAccountAgentWrapperList accountWrap = new OldAndNewAccountAgentWrapperList();
				accountWrap.description = description;
				accountWrap.agentRoleOriginalAccount = agentRoleOriginalAccount;
				accountWrap.originalAccount = originalAccount;
				accountWrap.originalAccountContact = originalAccountContact;
				accountWrap.lOrginalAccountAgentTask = lOrginalAccountAgentTask;
				accountWrap.newAccount = newAccount;
				accountWrap.newAccountContactID = newAccountContactID;
				accountWrap.lNewAccountAgentTask = lNewAccountAgentTask;
			accountAgentTast(accountWrap);
            lAllAgentTask.addAll(lOrginalAccountAgentTask);
            lAllAgentTask.addAll(lNewAccountAgentTask);
        }

        if(!lAllAgentTask.isEmpty()){
            insertTasks(lAllAgentTask);
            CreateTaskForNotificationWrapperList createTaskRelationWrap = new CreateTaskForNotificationWrapperList();
				createTaskRelationWrap.orginalAgentTask = lOrginalAccountAgentTask;
				createTaskRelationWrap.newAgentTask = lNewAccountAgentTask;
				createTaskRelationWrap.originalAccount = originalAccount;
				createTaskRelationWrap.newAccount = newAccount;
				createTaskRelationWrap.originalAccountContact = originalAccountContact;
				createTaskRelationWrap.newAccountContactId = newAccountContactID;
			createTaskRelationForNotification(createTaskRelationWrap);
        }
    }

    private void accountAgentTast(OldAndNewAccountAgentWrapperList accountAgentWrapper){
        String description = accountAgentWrapper.description;
        List<AgentRole__c> agentRoleOriginalAccount = accountAgentWrapper.agentRoleOriginalAccount;
        Account originalAccount = accountAgentWrapper.originalAccount;
        Id originalAccountContact = accountAgentWrapper.originalAccountContact;
        List<Task> lOrginalAccountAgentTask = accountAgentWrapper.lOrginalAccountAgentTask;
        Account newAccount = accountAgentWrapper.newAccount;
        Id newAccountContactID = accountAgentWrapper.newAccountContactID;
        List<Task> lNewAccountAgentTask = accountAgentWrapper.lNewAccountAgentTask;
        for(AgentRole__c agentOrginalAccount :agentRoleOriginalAccount) {
            if (agentOrginalAccount.Customer__c.equals(originalAccount.Id)){
                Task orginalAccTask = createNotification(description, agentOrginalAccount.Agent__c, originalAccountContact);
                lOrginalAccountAgentTask.add(orginalAccTask);
            }else if (agentOrginalAccount.Customer__c.equals(newAccount.Id)){
                Task newAccTask = createNotification(description, agentOrginalAccount.Agent__c, newAccountContactID);
                lNewAccountAgentTask.add(newAccTask);
            }
        }
    }

    private class OldAndNewAccountAgentWrapperList{
		private String description;
		private List<AgentRole__c> agentRoleOriginalAccount;
		private Account originalAccount;
		private Id originalAccountContact;
		private List<Task> lOrginalAccountAgentTask;
		private Account newAccount;
		private Id newAccountContactID;
		private List<Task> lNewAccountAgentTask;
	}
     /**@description This method creates createNotification for each task
    * @name createNotification
    * @param description - String description,
    * @param agentCode
    * @param accountContactID
    * @return Task */
    private Task createNotification(String description, String agentCode, Id accountContactID) {
        Task accTask = new Task();
        accTask.OwnerId = agentCode;
        accTask.WhoId =  accountContactID;
        accTask.ActivityDate = System.today() +7;
        accTask.Subject = TASK_SUBJECT;
        accTask.Status = TASK_STATUS;
        accTask.Priority = TASK_PRIORITY;
        accTask.TaskCategory__c = TASK_CATEGORY;
        accTask.AppCode__c = TASK_APPCODE;
        accTask.Description = description;
        accTask.IsReminderSet = true;
        accTask.ReminderDateTime = System.today() +3;
        return accTask;
    }
    /**
    * @description This method creates TaskRelaton Data ForNotification for all newly created tasks
    * @name createTaskRelationForNotification
    * @param taskRelationForNotificationWrapper
    */
    private void createTaskRelationForNotification(CreateTaskForNotificationWrapperList taskRelationForNotificationWrapper) {
	List<Task> orginalAgentTask = taskRelationForNotificationWrapper.orginalAgentTask;
	List<Task> newAgentTask = taskRelationForNotificationWrapper.newAgentTask;
	Account originalAccount = taskRelationForNotificationWrapper.originalAccount;
	Account newAccount = taskRelationForNotificationWrapper.newAccount;
	Id originalAccountContact = taskRelationForNotificationWrapper.originalAccountContact;
	Id newAccountContactId = taskRelationForNotificationWrapper.newAccountContactId;
       List<TaskRelation> taskWho = new List<TaskRelation>();

       for(Task orginalTask : orginalAgentTask) {
            taskWho.add(new TaskRelation(RelationId = originalAccount.id, TaskId = orginalTask.id, isWhat=true));
            taskWho.add(new TaskRelation(RelationId = newAccountContactId, TaskId=orginalTask.ID, isWhat = false));
       }
       for(Task newTask : newAgentTask) {
           taskWho.add(new TaskRelation(RelationId = newAccount.id,TaskId=newTask.ID, isWhat = true));
           taskWho.add(new TaskRelation(RelationId = originalAccountContact, TaskId = newTask.ID, isWhat = false));
       }
       if(!taskWho.isEmpty()) {
           insertTaskRelations(taskWho);
       }
    }

    private class CreateTaskForNotificationWrapperList{
        private List<Task> orginalAgentTask;
        private List<Task> newAgentTask;
        private Account originalAccount;
		private Account newAccount;
		private Id originalAccountContact;
		private Id newAccountContactId;
    }

     /**
     * @description This method retruns true if the orginalTask whoID hlods the orginalAccount ContactID
     * @name isWhoIDWithOldAccount
     * @param whoId
     * @param originalAccountContactID
     * @return boolean
     */
    public static boolean isWhoIDWithOldAccount(String whoId, Id originalAccountContactID) {
        return String.isNotBlank(WhoId) && WhoId.equals(originalAccountContactID) ? true : false;
    }

     /**
     * @description This method is to call all sync process methods for duplication and use the global variable to hold the tasks
     * @name callSyncProcess
     * @param originalAccount - originalAccount
     * @param newAccount - newAccount
     */
    private void callSyncProcess(Account originalAccount, Account newAccount) {
        Map<ID, Task> orginalTaksFromOpportunity = new Map<ID, Task>();
        Map<ID, Task> orginalTasksFromCases = new Map<ID, Task>();
        duplicateFeedItemsOnOriginalAccount(originalAccount.id, newAccount.id);
        orginalTaksFromOpportunity = getOpportunityOnOriginalAccount(originalAccount, newAccount);
        GetTaskOnOriginalAccountWrapperList taskOnOriginalAccountWrap = new GetTaskOnOriginalAccountWrapperList();
			taskOnOriginalAccountWrap.originalAccount = originalAccount;
			taskOnOriginalAccountWrap.newAccount = newAccount;
			taskOnOriginalAccountWrap.associatedTaskIds = null;
			taskOnOriginalAccountWrap.isWhat = true;
		getTaskOnOriginalAccountWithWhatIDAndWhoID(taskOnOriginalAccountWrap);
        orginalTasksFromCases = getCaseOnOriginalAccountAndCreateNewCasesWithNewAccount(originalAccount,newAccount);
        for(Id key : orginalTasksFromCases.keySet()){
            orginalTaksFromOpportunity.put(key, orginalTasksFromCases.get(key));
        }
        GetTaskOnOriginalAccountWrapperList originalAccountWithWhatIDAndWhoIDWrap = new GetTaskOnOriginalAccountWrapperList();
			originalAccountWithWhatIDAndWhoIDWrap.originalAccount = originalAccount;
			originalAccountWithWhatIDAndWhoIDWrap.newAccount = newAccount;
			originalAccountWithWhatIDAndWhoIDWrap.associatedTaskIds = !orginalTaksFromOpportunity.isEmpty() ? orginalTaksFromOpportunity.keySet() : null;
			originalAccountWithWhatIDAndWhoIDWrap.isWhat = false;
		getTaskOnOriginalAccountWithWhatIDAndWhoID(originalAccountWithWhatIDAndWhoIDWrap);
        createTaskForNotificationOnOrginalAndNewCustomer(originalAccount, newAccount);
        orginalTaksFromOpportunity = null;
    }
     /**
     * @description This method is a util method to convert the set of ID's as a string by appending both side quotation
     * @param anySetObject -Set object
     * @return String
     */
    public static String convertSetOfIDSAsString(Set<Id> anySetObject) {
        String convertedAsString = '';
        for(ID idFromObject : anySetObject) {
                convertedAsString=convertedAsString +'\'' + idFromObject + '\',';
        }
        convertedAsString = convertedAsString.removeEnd(',');
        return convertedAsString;
    }
     /**
     * @description This method is used to append the customer details to description field based on data availability
     * @name makeDescriptionField
     * @param originalAccount -Account
     * @return String
     */
    private String makeDescriptionField(Account originalAccount) {
        String description = TASK_DESCRIPTION ;
        return description;
    }

   /**
   * @description Takes the List<AgentRole__c> and deletes from SFDC datastore and if any exception happens with any deletion it goes to the next record to delete
   * @name deleteAgentRoles
   * @param agentRoleList - Agent roles to be deleted (Id for each is REQUIRED)
   */
     public static void deleteAgentRolesList(List<AgentRole__c> agentRoleList) {
         List<Database.DeleteResult> deleteResultList = null;
         if(agentRoleList != null && !agentRoleList.isEmpty()) {
             deleteResultList = Database.delete(agentRoleList, false);
         }
         for (Database.DeleteResult dr : deleteResultList) {
              Database.Error[] errors = dr.getErrors();
              if(!errors.isEmpty()) {
                 logEntityDeletedError(errors);
              }
         }
    }

   /**
   * @description Takes the List<Database.Error> and log the exception if any exception happens with any deletion it goes to the next record to delete
   * @name logEntityDeletedError
   * @param errorList - errorList from the Resultset
   */
    public static void logEntityDeletedError(List<Database.Error> errorList){
        for(Database.Error error : errorList) {
            if( StatusCode.ENTITY_IS_DELETED.equals(error.getStatusCode())) {

                  LoggingService.logHandledException(new EntityDeletedException(UTIL_StageOrchestrationConstants.ENTITY_IS_DELETED_WARNING_MSG),
                                                     UTIL_SeparateProcessor.class.getName(), METHOD_DELETE_AGENTROLE , LoggingLevel.WARN);
              } else{
                  throw new DmlException(error.getMessage());
              }
        }
    }
}