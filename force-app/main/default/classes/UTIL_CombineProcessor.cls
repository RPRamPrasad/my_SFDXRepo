/**
* @Name UTIL_CombineProcessor
* @Author Team ClubCar
* @Description UTIL_CombineProcessor class is one of the processors of the stageorchestration which is used for merging customer details.
* @UTIL_CombineProcessor is defined without sharing as merge operations such as reparenting,upsert,update is performed on all child objects
*/

/**
* @Name UTIL_CombineProcessor
* @Author Team Loco-Motivated
* @CreateDate 5/02/2017
* @Description: Updated UTIL_CombineProcessor to accomodate Customer Relationships
* @Version 2.0
*/

/**
* @Name UTIL_CombineProcessor
* @Author Team Loco-Motivated
* @CreateDate 1/03/2018
* @Description: Updated UTIL_CombineProcessor to integrate Household Group
* @Version 3.0
*/

/**
* @Name UTIL_CombineProcessor
* @Author Team Choo_Choo
* @CreateDate 5/1/2018
* @Description: Updated UTIL_CombineProcessor to integrate Assigned Staff
* @Version 4.0
*/

/**
* @Name UTIL_CombineProcessor
* @Author Team Akita
* @CreateDate 5/1/2018
* @Description: Updated UTIL_CombineProcessor to merge customer details for multiple loosing clientIds
* @Version 4.0
*/

/**
* @Author Team Golden Spikes
* @ModifiedDate 5/8/2018
* @Description: Updated UTIL_CombineProcessor to update Planning Conversation Log record owner as SYSTEM_USER_REC_OWNER for No Book of Business match.
* @Version 5.0
*/

/**
* @Author Team Shenanigans
* @ModifiedDate 07/19/2018
* @Description: Added logic for Customer Initiated Cancellations Object for removed book of business, split and merge accounts
* @Version 6.0
*/

/**
* @Author Team Golden Spikes
* @ModifiedDate 08/10/2018
* @Description: Updated UTIL_CombineProcessor to update Simple Conversation record owner as SYSTEM_USER_REC_OWNER for No Book of Business match.
* @Version 7.0
*/

/**
* @Author Team ITIC
* @ModifiedDate 09/16/2019
* @Description: Updated UTIL_CombineProcessor to delete campaign members related to losing client.
* @Version 8.0
*/

/**
* @Author Team Club Car
* @ModifiedDate 01/20/2021
* @Description: Updated UTIL_CombineProcessor to handle Signed Written Consent related to losing client.
* @Version 9.0
*/
/**
* @Author Team Trailblazer
* @ModifiedDate 01/19/2022
* @Description: Updated UTIL_CombineProcessor to handle Household Group.
* @Version 9.0
*/

/**
 *@description class is one of the processors of the stageorchestration which is used for merging customer details.
 */
public without sharing class UTIL_CombineProcessor extends UTIL_StageOrchestrationProcessor {

    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
    private static final String METHOD_NAME = 'handleMergeOperations';
    private static final String CLASS_NAME = 'UTIL_CombineProcessor';
    private static final String ASSIGNED_STAFF_METHOD_NAME = 'handleAssignedStaffData';
    private boolean isFSCEnabled = false;

    private UTIL_CombineProcessor_Wrapper procWrap = new UTIL_CombineProcessor_Wrapper();
    private UTIL_CombineProcessorWrapper combineprocessorwrap = new UTIL_CombineProcessorWrapper();
    private static UTIL_CombineProcessorWrapper2 combineprocesswrap2 = new UTIL_CombineProcessorWrapper2();
    class UTIL_CombineProcessor_Wrapper{
        private StageOrchestration__c stageOrchestration;
        private Savepoint sp;
        private AP_StageOrchestrationJSONParser parseJSON;
        private String winningCustomer;
        private String loosingCustomer;
        private List<String> clientIds;
        private List<string> loosingCustomersList;
        private List<Relationship__c> jsonC2CRealtionshipList;
        private List<Account> updatedAccountList;
        private List<Account> listOfSFDCAccounts;
        private Set<String> listOfAgentExternalIds;
        private Account winningAccountRecordOnSFDC;
        private List<Account> losingAccountRecordsOnSFDC;
        private boolean isC2CFailSafe;
    }

    private void initProperties(){
        procWrap.parseJSON = parseJSON(procWrap.stageOrchestration.Value__c);
        procWrap.winningCustomer=procWrap.parseJSON.orchestrationInfo.orchestrationEventName.orchestrationEventDetail.orchestrationEventValues.wclientId;
        procWrap.loosingCustomer=procWrap.parseJSON.orchestrationInfo.orchestrationEventName.orchestrationEventDetail.orchestrationEventValues.lclientId;
        procWrap.clientIds = new List<string>{procWrap.winningCustomer};
        procWrap.loosingCustomersList = new List<string>();
        for(String clientId : procWrap.loosingCustomer.split(','))
        {
            procWrap.loosingCustomersList.add(clientId);
            procWrap.clientIds.add(clientId);
        }

        procWrap.jsonC2CRealtionshipList = jsontoC2CConverter(procWrap.parseJSON); //Converting JSON for Customer Relationships Information
        procWrap.updatedAccountList = jsontoAccountConverter(procWrap.parseJSON); //Converting JSON for Account Information
        procWrap.listOfSFDCAccounts = retrieveAccounts(procWrap.clientIds);
        procWrap.listOfAgentExternalIds = jsonToAgentAssocIdConverter(procWrap.parseJSON);

        procWrap.winningAccountRecordOnSFDC = getAccountFromListforGivenClient(procWrap.winningCustomer,procWrap.listOfSFDCAccounts);
        procWrap.losingAccountRecordsOnSFDC = getAccountFromGivenLoosingClientIdsList(procWrap.loosingCustomersList,procWrap.listOfSFDCAccounts);
        procWrap.isC2CFailSafe=(procWrap.StageOrchestration.ReprocessCount__c==UTIL_StageOrchestrationConstants.MAX_REPROCESS_COUNT);
    }

   /**
    * @description Execute method for combine processor implemented from UTIL_OrchestrationProcessor
    * @param stageOrchestrationList
    * @throws StageProcessorException
    */
    public override void execute(List<StageOrchestration__c> stageOrchestrationList) {
        procWrap.stageOrchestration = stageOrchestrationList.get(0);
                   Savepoint sp;
        try{
            sp = Database.setSavepoint();
            initProperties();

            //If both accounts are in SFDC
          if(!procWrap.losingAccountRecordsOnSFDC.isEmpty() && procWrap.winningAccountRecordOnSFDC != null){
                UTIL_CombineProcessor.HandleMergeOperationWrapperList operationWrap = new UTIL_CombineProcessor.HandleMergeOperationWrapperList();
					operationWrap.winningAccount = procWrap.winningAccountRecordOnSFDC;
					operationWrap.losingAccountList = procWrap.losingAccountRecordsOnSFDC;
					operationWrap.jsonC2CRealtionshipList = procWrap.jsonC2CRealtionshipList;
					operationWrap.isC2CFailSafe = procWrap.isC2CFailSafe;
					operationWrap.listOfAgentExternalIds = procWrap.listOfAgentExternalIds;
				handleMergeOperations(operationWrap);
                accountUpdate(procWrap.winningAccountRecordOnSFDC, procWrap.updatedAccountList, procWrap.listOfSFDCAccounts);
                upsertUserAgentRoles(jsonAgentRoleConverter(procWrap.parseJSON));
                upsertHouseholdGroupAndGroupMember(procWrap.parseJSON);
            }

            //If Losing account not in SFDC
            else if(procWrap.losingAccountRecordsOnSFDC.isEmpty()&& procWrap.winningAccountRecordOnSFDC != null){
                deleteRelationship(procWrap.winningAccountRecordOnSFDC.Relationships__r);
                deleteCustomerHouseholdGroupMember(procWrap.winningAccountRecordOnSFDC.Customer_Groupings__r);
                insertC2CRelationships(procWrap.jsonC2CRealtionshipList,procWrap.isC2CFailSafe);
                accountUpdate(procWrap.winningAccountRecordOnSFDC, procWrap.updatedAccountList, procWrap.listOfSFDCAccounts);
                upsertHouseholdGroupAndGroupMember(procWrap.parseJSON);
                upsertUserAgentRoles(jsonAgentRoleConverter(procWrap.parseJSON));

            }

            //If winning account not in SFDC
            else if(procWrap.winningAccountRecordOnSFDC == null && !procWrap.losingAccountRecordsOnSFDC.isEmpty()){
                insertAccounts(procWrap.updatedAccountList);
                List<String> winningClient=new List<String>{procWrap.winningCustomer};
                List<Account> winningNewAccount=retrieveAccounts(winningClient);
                UTIL_CombineProcessor.HandleMergeOperationWrapperList handleMergeWrap = new UTIL_CombineProcessor.HandleMergeOperationWrapperList();
                    handleMergeWrap.winningAccount = winningNewAccount[0];
                    handleMergeWrap.losingAccountList = procWrap.losingAccountRecordsOnSFDC;
                    handleMergeWrap.jsonC2CRealtionshipList = procWrap.jsonC2CRealtionshipList;
                    handleMergeWrap.isC2CFailSafe = procWrap.isC2CFailSafe;
                    handleMergeWrap.listOfAgentExternalIds = procWrap.listOfAgentExternalIds;
                    handleMergeOperations(handleMergeWrap);
                accountUpdate(winningNewAccount[0], procWrap.updatedAccountList, procWrap.listOfSFDCAccounts);
                upsertUserAgentRoles(jsonAgentRoleConverter(procWrap.parseJSON));
                upsertHouseholdGroupAndGroupMember(procWrap.parseJSON);
            }

            //If both accounts not in SFDC
            else{
                insertAccounts(procWrap.updatedAccountList);
                insertC2CRelationships(procWrap.jsonC2CRealtionshipList,procWrap.isC2CFailSafe);
                upsertUserAgentRoles(jsonAgentRoleConverter(procWrap.parseJSON));
                upsertHouseholdGroupAndGroupMember(procWrap.parseJSON);
            }
        }
        catch(Exception exp){
            combineprocesswrap2.getMessage(exp,sp);
            throw new StageProcessorException(exp.getmessage(),exp);
        }
    }



   /**
    * @description <This method is used to return matching account for list of account>
    * @name getAccountFromListforGivenClient
    * @param clientId
    * @param retrivedAccountsList
    * @return Account
    */
    private Account getAccountFromListforGivenClient(String clientId,List<Account> retrivedAccountsList){
        return combineprocessorwrap.getAccountFromList(clientId,retrivedAccountsList);
    }


   /**
    * @description <This method is used to return matching accounts for Loosing ClientIds for list of account>
    * @name getAccountFromGivenLoosingClientIdsList
    * @param loosingClientIds
    * @param retrivedAccountsList
    * @return Account
    */
    private List<Account> getAccountFromGivenLoosingClientIdsList(List<String> loosingClientIds,List<Account> retrivedAccountsList){
        return combineprocessorwrap.getAccountFromGivenLoosingClientId(loosingClientIds,retrivedAccountsList);
    }


   /**
    * @description <This method is used to retrieve Accounts using a SOQL query based on ClientID>
    * @name retrieveAccounts
    * @param clientIds
    * @return List of accounts
    */
    private List<Account> retrieveAccounts(List<String> clientIds){
        List<Account> accountWithChildRecords = [Select Id, ClientIdentifier__c, ExternalSourceSyncTime__c, LivingArrangements__c, LivingArrangementsOtherDescription__c,
                                                 LivingArrangementsModDate__c, NumberOfEmployeesModDate__c, NumberOfEmployees, RecordType.Name, Primary_Household__pc, PersonContactId,
                                                 (Select Id From LeadConversionDetails__r),
                                                 (Select Id,Customer__c, Agent__c, Primary_Household__c From Agent_Roles__r),
                                                 (Select Id From AgentContexts__r),
                                                 (Select Id From PersonCampaignMembers),
                                                 (Select Id From Customer_Groupings__r),
                                                 (Select Id, Account__c, Status__c From AccountMessage__r Where Status__c!=null),
                                                 (Select Id, AccountOne__c From Relationships__r),
                                                 (Select Id, AccountTwo__c From Relationships1__r),
                                                 (Select Id, Agent__r.Associate_Id__c, Staff__r.Associate_Id__c From AssignedStaff__r),
                                                 (Select Id, Agent__r.Associate_Id__c From Planning_Conversation_Logs__r),
                                                 (Select Id, Agent__r.Associate_Id__c From Simple_Conversations__r),
                                                 (Select Id From Customer_Initiated_Cancellations__r),
                                                 (Select Id, Primary_Household__c from Account_Notes__r),
                                                 (Select Id,InitiatedFromId__c from SignedWrittenConsent__r),
                                                 (Select Id,OwnerId,DateCaptured__c,OppSignedWrittenConsentStatus__c,OppSignedWrittenConsentRequestedDate__c,OppSignedWrittenConsentGrantedDate__c from Opportunities),
                                                 (Select Id, Primary_Household__c from ProductsServicedByMe__r),
                                                 (Select Id,Primary_Household__c from BillingParticipants__r),
                                                 (Select Id,Primary_Household__c from InteractionSummarys__r)
                                                  From Account WHERE ClientIdentifier__c IN :clientIds];
        return accountWithChildRecords;
    }


   /**
    * @description <This method is used to perform set of merge operations to clean up data>
    * @name handleMergeOperations
    * @param mergeOperationWrapper
    */
    private void handleMergeOperations(HandleMergeOperationWrapperList mergeOperationWrapper){
        Account winningAccount = mergeOperationWrapper.winningAccount;
	    List<Account> losingAccountList = mergeOperationWrapper.losingAccountList;
	    List<Relationship__c> jsonC2CRealtionshipList = mergeOperationWrapper.jsonC2CRealtionshipList;
	    Boolean isC2CFailSafe = mergeOperationWrapper.isC2CFailSafe;
	    Set<String> listOfAgentExternalIds = mergeOperationWrapper.listOfAgentExternalIds;

		isFSCEnabled=toggleContext.isActive(UTIL_Toggles.TOGGLE_FSC);
        Id systemUserId = getSystemRecordOwnerId();
        List<AccountMessage__c> accountMessagesToDelete = new List<AccountMessage__c>();
        List<AgentRole__c> agentRoleListToDelete = new List<Agentrole__C>();
        List<AgentContext__c> agentContextsToDelete = new List<AgentContext__c>();
        List<CustomerGroupMember__c> customerGroupingsToDelete = new List<CustomerGroupMember__c>();
        List<LeadConversionDetail__c> leadConversationsToDelete = new List<LeadConversionDetail__c>();
        List<Relationship__c> relationshipsToDelete = new List<Relationship__c>();
        List<AssignedStaff__c> assignedStaffListToDelete = new List<AssignedStaff__c>();
        List<PlanningConversationLog__c> losingAccountPlanningConversationList = new List<PlanningConversationLog__c>();
        List<SimpleConversation__c> losingAccountSimpleConvList = new List<SimpleConversation__c>();
        List<CustomerInitiatedCancellations__c> losingAccountCICList = new List<CustomerInitiatedCancellations__c>();
        List<CampaignMember> losingCampaignMemberList = new List<CampaignMember>();
        List<Account_Note__c> losingCustomerAccountNotes = new List<Account_Note__c>();
        List<SignedWrittenConsent__c> swcList = new List<SignedWrittenConsent__c>();
        List<Opportunity> losingAccountOpportunityList = new List<Opportunity>();
        List<Id> losingAccountPersonContactIds = new List<Id>();
        List<ProductsServicedByMe__c> losingProductsServicedByMeList = new List<ProductsServicedByMe__c>();
        List<Billing_Participant__c> losingBillingParticipants = new List<Billing_Participant__c>();
        List<InteractionSummary__c> losingInteractionSummaryList = new List<InteractionSummary__c>();

        for(Account losingAccount : losingAccountList){
            accountMessagesToDelete.addAll(losingAccount.AccountMessage__r);
            agentRoleListToDelete.addAll(losingAccount.Agent_Roles__r);
            agentContextsToDelete.addAll(losingAccount.AgentContexts__r);
            customerGroupingsToDelete.addAll(losingAccount.Customer_Groupings__r);
            leadConversationsToDelete.addAll(losingAccount.LeadConversionDetails__r);
            relationshipsToDelete.addAll(losingAccount.Relationships__r);
            relationshipsToDelete.addAll(losingAccount.Relationships1__r);
            assignedStaffListToDelete.addAll(losingAccount.AssignedStaff__r);
            losingAccountPlanningConversationList.addAll(losingAccount.Planning_Conversation_Logs__r);
            losingAccountSimpleConvList.addAll(losingAccount.Simple_Conversations__r);
            losingAccountCICList.addAll(losingAccount.Customer_Initiated_Cancellations__r);
            losingCampaignMemberList.addAll(losingAccount.PersonCampaignMembers);
            losingCustomerAccountNotes.addAll(losingAccount.Account_Notes__r);
            losingAccountPersonContactIds.add(losingAccount.PersonContactId);
            swcList.addAll(losingAccount.SignedWrittenConsent__r);
            losingAccountOpportunityList.addAll(losingAccount.Opportunities);
            losingProductsServicedByMeList.addAll(losingAccount.ProductsServicedByMe__r);
            losingBillingParticipants.addAll(losingAccount.BillingParticipants__r);
            losingInteractionSummaryList.addAll(losingAccount.InteractionSummarys__r);
        }

        assignAccountMessages(accountMessagesToDelete, winningAccount);
        deleteAgentRoles(agentRoleListToDelete);
        UTIL_CampaignMemberDAO.deleteCampaignMembers(losingCampaignMemberList);
        UTIL_AccountProcessorsSwcHandler.processSwcOnCombine(winningAccount,losingAccountOpportunityList,swcList);
        deletesObjectList(agentContextsToDelete,CLASS_NAME, METHOD_NAME);

        removeHouseholdGroupMember(winningAccount.Customer_Groupings__r,customerGroupingsToDelete);
        removingC2CRelationships(winningAccount.Relationships__r, relationshipsToDelete);
        deleteLeadConversionDetails(leadConversationsToDelete);
        insertC2CRelationships(jsonC2CRealtionshipList,isC2CFailSafe);
        handleAssignedStaffData(winningAccount, assignedStaffListToDelete, listOfAgentExternalIds);
        handlePlanningConversationLogData(losingAccountPlanningConversationList, listOfAgentExternalIds, systemUserId);
        handleSimpleConversationData(losingAccountSimpleConvList, listOfAgentExternalIds, systemUserId);
        handleCICData(losingAccountCICList, winningAccount);
        List<Id> contactIdsOfWinningAndLosing = new List<Id>();
        contactIdsOfWinningAndLosing.add(winningAccount.PersonContactId);
        contactIdsOfWinningAndLosing.addAll(losingAccountPersonContactIds);
        List<AccountContactRelation> acrList = [Select Id, ContactId, isActive FROM accountcontactrelation where contactid IN :contactIdsOfWinningAndLosing];
        List<AccountContactRelation> losingAccountAcrList = new List<AccountContactRelation>();
        List<AccountContactRelation> winningAccountAcrList = new List<AccountContactRelation>();
        for(AccountContactRelation acr: acrList){
            if(acr.contactId.equals(winningAccount.PersonContactId)){
                winningAccountAcrList.add(acr);
            }else{
                losingAccountAcrList.add(acr);
            }
        }
        if(isFSCEnabled){
            deleteLosingAccountAcrs(losingAccountAcrList);
            UTIL_CombineProcessor.HandleChildObjectWrapperList childObjectWrap = new UTIL_CombineProcessor.HandleChildObjectWrapperList();
				childObjectWrap.winningAccount = winningAccount;
				childObjectWrap.losingBillingParticipants = losingBillingParticipants;
				childObjectWrap.losingCustomerAccountNotes = losingCustomerAccountNotes;
				childObjectWrap.losingProductsServicedByMeList = losingProductsServicedByMeList;
				childObjectWrap.losingInteractionSummaryList = losingInteractionSummaryList;
			handleChildObjects(childObjectWrap);
        }
        UTIL_CombineProcessor.CallMergeApiWrapperList callApiWrap = new UTIL_CombineProcessor.CallMergeApiWrapperList();
			callApiWrap.winningMergeAccount = winningAccount;
			callApiWrap.losingMergeAccountsList = losingAccountList;
			callApiWrap.winningAcrList = winningAccountAcrList;
			callApiWrap.isFSCEnabled = isFSCEnabled;
		callMergeApi(callApiWrap);
        AP_NewAgentRoleTrigger.agentRoleAfterInsertAddToShare(winningAccount.Agent_Roles__r);

    }

    private class HandleMergeOperationWrapperList{
        private Account winningAccount;
        private List<Account> losingAccountList;
        private List<Relationship__c> jsonC2CRealtionshipList;
        private Boolean isC2CFailSafe;
		private Set<String> listOfAgentExternalIds;
    }

    /**
    * @description <This method handles the Primary_Household__c on  Accout Note, PSBM and Deletes losing Accounts ACR records on combine>
    * @name handleChildObjects
    * @param childObjectWrapper
    */
    private void handleChildObjects(HandleChildObjectWrapperList childObjectWrapper){
        Account winningAccount = childObjectWrapper.winningAccount;
	    List<Billing_Participant__c> losingBillingParticipants = childObjectWrapper.losingBillingParticipants;
	    List<Account_Note__c> losingCustomerAccountNotes = childObjectWrapper.losingCustomerAccountNotes;
	    List<ProductsServicedByMe__c> losingProductsServicedByMeList = childObjectWrapper.losingProductsServicedByMeList;
	    List<InteractionSummary__c> losingInteractionSummaryList = childObjectWrapper.losingInteractionSummaryList;
        handleAccountNotes(winningAccount, losingCustomerAccountNotes);
        AP_ProductsServicedByMeHandler.updateProductsServicedByMeHHId(winningAccount, losingProductsServicedByMeList);
        handleBillingParticipants(winningAccount, losingBillingParticipants);
        InteractionSummaryHandler.updateInteractionSummaryHHId(winningAccount, losingInteractionSummaryList);
    }

    private class HandleChildObjectWrapperList{
        private Account winningAccount;
        private List<Billing_Participant__c> losingBillingParticipants;
        private List<Account_Note__c> losingCustomerAccountNotes;
        private List<ProductsServicedByMe__c> losingProductsServicedByMeList;
		private List<InteractionSummary__c> losingInteractionSummaryList;
    }

    private void handleBillingParticipants(Account winningAccount, List<Billing_Participant__c> losingBillingParticipants){
        combineprocessorwrap.handleBillingParticipant(winningAccount,losingBillingParticipants);
    }

    /**
    * @description <This method deletes the losing Accounts ACR Records>
    * @name deleteLosingAccountAcrs
    * @param losingAccountAcrList
    */
    private void deleteLosingAccountAcrs(List<AccountContactRelation> losingAccountAcrList) {
        delete losingAccountAcrList;
    }

    /**
    * @description <This method updates the Primary_Household__c of losing customers account notes with winning one>
    * @name handleAccountNotes
    * @param winningAccount
    * @param accountNotes
    */
    private void handleAccountNotes(Account winningAccount, List<Account_Note__c> accountNotes){
		combineprocessorwrap.handleAccountNote(winningAccount,accountNotes);
    }

    /**
	* @description <This method is to update the acr record of the winning customer so that it triggers the ACR standard triggers to update Finserv Household id on standard child objects>
	* @name updateACR
	* @param winningAccountACRList
	*/
    private static void updateACR(List<AccountContactRelation> winningAccountACRList) {
        List<AccountContactRelation> acrsToBeUpdated = new List<AccountContactRelation>();
        if(!winningAccountACRList.isEmpty()){
            combineprocesswrap2.updateACR(winningAccountACRList,acrsToBeUpdated);
            update acrsToBeUpdated;
        }
    }

   /**
    * @description <This method is used for moving the CICs from the losing to the winning account>
    * @name handleCICData
    * @param losingAccountCICList
    * @param winningAccount
    */
    private void handleCICData(List<CustomerInitiatedCancellations__c> losingAccountCICList, Account winningAccount){
        List<CustomerInitiatedCancellations__c> cicListToBeUpdated = new List<CustomerInitiatedCancellations__c>();

        if(losingAccountCICList != null && !losingAccountCICList.isEmpty()) {
            combineprocesswrap2.handleCICData(losingAccountCICList,winningAccount,cicListToBeUpdated);

            updateCustomerInitiatedCancellation(cicListToBeUpdated);
        }
    }

    /**
    * @description <This method is used to handle merge operations of PlanningConversation Records and assigning PlanningConversation record owner as SYSTEM_USER_REC_OWNER for no book of business match>
    * @name handlePlanningConversationLogData
    * @param losingAccountPlanningConversationLogList
    * @param agentExternalIdSetFromAgentRoleJSON
    * @param systemUserId
    */
    private void handlePlanningConversationLogData(List<PlanningConversationLog__c> losingAccountPlanningConversationLogList, Set<String> agentExternalIdSetFromAgentRoleJSON, Id systemUserId) {
        List<PlanningConversationLog__c> planningConversationLogListToBeUpdated = new List<PlanningConversationLog__c>();
        PlanningConLogWrapperList planningConvoWrap = new PlanningConLogWrapperList();
		    planningConvoWrap.losingAccountPlanningConversationLogList = losingAccountPlanningConversationLogList;
		    planningConvoWrap.agentExternalIdSetFromAgentRoleJSON = agentExternalIdSetFromAgentRoleJSON;
		    planningConvoWrap.systemUserId = systemUserId;
	    combineprocessorwrap.handlePlanningConversationLog(planningConversationLogListToBeUpdated,planningConvoWrap);
        updatePlanningConversationLog(planningConversationLogListToBeUpdated);
    }

    /**
    * @description <This method is used to handle merge operations of SimpleConversation Records and assigning SimpleConversation record owner as SYSTEM_USER_REC_OWNER for no book of business match>
    * @name handleSimpleConversationData
    * @param losingAccountSimpleConversationList
    * @param agentExternalIdSetFromAgentRoleJSON
    * @param systemUserId
    */
    private void handleSimpleConversationData(List<SimpleConversation__c> losingAccountSimpleConversationList, Set<String> agentExternalIdSetFromAgentRoleJSON, Id systemUserId) {
        List<SimpleConversation__c> simpleConversationListToBeUpdated = new List<SimpleConversation__c>();
        SimpleConWrapperList simpleConvoWrap = new SimpleConWrapperList();
		    simpleConvoWrap.losingAccountSimpleConversationList = losingAccountSimpleConversationList;
		    simpleConvoWrap.agentExternalIdSetFromAgentRoleJSON = agentExternalIdSetFromAgentRoleJSON;
		    simpleConvoWrap.systemUserId = systemUserId;
	    combineprocessorwrap.handleSimpleConversation(simpleConversationListToBeUpdated,simpleConvoWrap);
        updateSimpleConversation(simpleConversationListToBeUpdated);
    }


    /**
* @description <This method is used to handle merge operations of Assigned Staff object to clean up data>
* @name handleAssignedStaffData
* @param winningAccount
* @param losingAccountAssignedStaff
* @param agentIdFromAgentRoles
*/
    private void handleAssignedStaffData(Account winningAccount, List<AssignedStaff__c> losingAccountAssignedStaff, Set<String> agentIdFromAgentRoles){
        if(!losingAccountAssignedStaff.isEmpty()){
            List<AssignedStaff__c> assignedStaffListToUpdate = new List<AssignedStaff__c>();
            List<AssignedStaff__c> assignedStaffListToDelete = new List<AssignedStaff__c>();
            Map<Id, AssignedStaff__c> assignedStaffMapToUpdate = new Map<Id, AssignedStaff__c>();
            AssignedStaffWrapperList handleStaffWrap = new AssignedStaffWrapperList();
		        handleStaffWrap.winningAccount = winningAccount;
		        handleStaffWrap.losingAccountAssignedStaff = losingAccountAssignedStaff;
		        handleStaffWrap.agentIdFromAgentRoles = agentIdFromAgentRoles;
		        handleStaffWrap.assignedStaffListToUpdate = assignedStaffListToUpdate;
		        handleStaffWrap.assignedStaffMapToUpdate = assignedStaffMapToUpdate;
		        handleStaffWrap.assignedStaffListToDelete = assignedStaffListToDelete;
	        combineprocesswrap2.handleAssignedStaff(handleStaffWrap);
            if(!assignedStaffListToUpdate.isEmpty()){
                List<Database.SaveResult> updateAssignedStaffResult = updateAssignedStaff(assignedStaffListToUpdate);
                LoggingService.logDatabaseResult(updateAssignedStaffResult, assignedStaffListToUpdate, CLASS_NAME, ASSIGNED_STAFF_METHOD_NAME, System.LoggingLevel.WARN);
                assignedStaffListToDelete.addAll(handleFailedAssignedStaffUpdate(updateAssignedStaffResult, assignedStaffMapToUpdate));
            }
            if(!assignedStaffListToDelete.isEmpty()){
                deleteAssignedStaff(assignedStaffListToDelete);
            }
        }
    }

    private List<AssignedStaff__c> handleFailedAssignedStaffUpdate(List<Database.SaveResult> updateAssignedStaffResult, Map<Id, AssignedStaff__c> assignedStaffMapToUpdate){
        return combineprocesswrap2.handleFailedAssignedStaff(updateAssignedStaffResult,assignedStaffMapToUpdate);
    }

    /**
* @description <This method is used for combining Account Message details>
* @name assignAccountMessages
* @param accountMsgList
* @param winningAccount
*/
    private void assignAccountMessages(List<AccountMessage__c> accountMsgList, Account winningAccount){

        List<AccountMessage__c> accountMsgStatusFutureList=new List<AccountMessage__c>();
        List<AccountMessage__c> accountMsgStatusSentList=new List<AccountMessage__c>();
        if(!accountMSgList.isEmpty()) {
            AccountMessaageWrapperList assignAccWrap = new AccountMessaageWrapperList();
		        assignAccWrap.accountMsgList = accountMsgList;
		        assignAccWrap.winningAccount = winningAccount;
	        combineprocessorwrap.assignAccountMessage(accountMsgStatusFutureList,accountMsgStatusSentList,assignAccWrap);

            if(!accountMsgList.isEmpty()) {
                updateAccountMessages(accountMsgStatusSentList);
            }
            if(!accountMsgStatusFutureList.isEmpty()){
                deleteAccountMessages(accountMsgStatusFutureList);
            }
        }
    }


    /**
* @description <This method is used for deleting Customer Relationships>
* @name removingC2CRelationships
* @param winningC2CMasterList
* @param losingC2CList
*/
    private void removingC2CRelationships(List<Relationship__c> winningC2CMasterList, List<Relationship__c> losingC2CList) {

        List<Relationship__c> dedupedRelationshipLstToDelete = new List<Relationship__C>();
        combineprocesswrap2.removingC2CRelationship(losingC2CList,winningC2CMasterList,dedupedRelationshipLstToDelete);
        deleteRelationship(dedupedRelationshipLstToDelete);
    }


    /**
* @description <This method is used to execute the merge API so that the child records are in SYNC to winner>
* @name callMergeApi
* @param mergeApiWrapper
*/
  private static void callMergeApi(CallMergeApiWrapperList mergeApiWrapper){
    Account winningMergeAccount = mergeApiWrapper.winningMergeAccount;
	List<Account> losingMergeAccountsList = mergeApiWrapper.losingMergeAccountsList;
	List<AccountContactRelation> winningAcrList = mergeApiWrapper.winningAcrList;
	boolean isFSCEnabled = mergeApiWrapper.isFSCEnabled;
    CallMergeWrapperList callAPIWrap = new CallMergeWrapperList();
		callAPIWrap.losingMergeAccountsList = losingMergeAccountsList;
		callAPIWrap.winningMergeAccount = winningMergeAccount;
		callAPIWrap.isFSCEnabled = isFSCEnabled;
		callAPIWrap.winningAcrList = winningAcrList;
	combineprocesswrap2.apiCallMerge(callAPIWrap);
    }

    private static void doMerge(Account ac , List<Id> lstIds){
        database.merge(ac, lstIds);
    }

    private class CallMergeApiWrapperList{
        private Account winningMergeAccount;
        private List<Account> losingMergeAccountsList;
        private List<AccountContactRelation> winningAcrList;
        private boolean isFSCEnabled;
    }

    /**
* @description <This method is used to update account with most updated information from JSON>
* @name accountUpdate
* @param existingAccount
* @param jsonAccount
* @param listOfSFDCAccounts
*/
    private void accountUpdate(Account existingAccount , List<Account> jsonAccount, List<Account> listOfSFDCAccounts){
        Account updateAccount;
        for(Account account : jsonAccount) {
            if(existingAccount.ClientIdentifier__c.equals(account.ClientIdentifier__c)) {
                updateAccount = account;
                break;
            }
        }
        if(updateAccount != null){
            if((existingAccount.ExternalSourceSyncTime__c < updateAccount.ExternalSourceSyncTime__c)|| String.isBlank(String.valueOf(existingAccount.ExternalSourceSyncTime__c))){
                updateAccount = getLatestSFDCMasteredValue(updateAccount, listOfSFDCAccounts);
                updateAccount.id = existingAccount.id;
            }
            else{
                updateAccount = getLatestSFDCMasteredValue(existingAccount, listOfSFDCAccounts);
            }
            updateAccount(updateAccount);
        }
    }

    /**
* @description <This method is used to update account with most updated information from JSON>
* @name getLatestSFDCMasteredValue
* @param winningAccount
* @param accList
* @return winningAccount
*/
    private Account getLatestSFDCMasteredValue(Account winningAccount, List<Account> accList){
        return combineprocessorwrap.getLatestSFDCValue(winningAccount,accList);
    }

    /**
*  @description helper function to delete HouseHoldGroupMember for a particular Account associated with Particular Agent
*  @name  deleteHouseholdGroupMember
*  @param listofWinningClientHouseholdGroupMember
*  @param listofLoosingClientHouseholdGroupMember
*/
    private void removeHouseholdGroupMember(List<CustomerGroupMember__c> listofWinningClientHouseholdGroupMember,List<CustomerGroupMember__c> listofLoosingClientHouseholdGroupMember){
        List<CustomerGroupMember__c> listofHouseholdGroupMemberToDelete = new List<CustomerGroupMember__c>();
        listofHouseholdGroupMemberToDelete.addAll(listofWinningClientHouseholdGroupMember);
        listofHouseholdGroupMemberToDelete.addAll(listofLoosingClientHouseholdGroupMember);
        //check in weather Grouping feature is Enable to transform
        boolean isFeatureEnabledToTransform=toggleContext.isActive(UTIL_Toggles.CUSTOMERGROUPINGS);
        if(isFeatureEnabledToTransform){
            deleteCustomerHouseholdGroupMember(listofHouseholdGroupMemberToDelete);
        }
    }

    /**
*  @description helper function to upsert HouseHoldGroup And GroupMember for a particular Account associated with multiple Agent
*  @name  upsertHouseholdGroupAndGroupMember
*  @param jsonObject
*  @preturn void
*/
    private void upsertHouseholdGroupAndGroupMember(final AP_StageOrchestrationJSONParser jsonObject){
        //check in weather Grouping feature is Enable to transform
        boolean isFeatureEnabledToTransform=toggleContext.isActive(UTIL_Toggles.CUSTOMERGROUPINGS);
        if(isFeatureEnabledToTransform){
            UTIL_OrchestrationJSONtoGroupDetails.HLPR_GroupAndGroupMemberWrapper
                houseHoldGroupDetails=UTIL_OrchestrationJSONtoGroupDetails.jsonGroupDetailsConverter(jsonObject);
            upsertCustomerHouseholdGroup(houseHoldGroupDetails.groupList);
            upsertCustomerHouseholdGroupMember(houseHoldGroupDetails.groupMemberList);
        }
    }

    private without sharing class UTIL_CombineProcessorWrapper{

        private Account getAccountFromList(String clientId,List<Account> retrivedAccountsList){
            Account matchingAccount;
            for(Account accountToMatch:retrivedAccountsList){
                if(accountToMatch.Clientidentifier__c.equals(clientId)){
                    matchingAccount= accountToMatch;
                }
            }
            return matchingAccount;
        }

        private List<Account> getAccountFromGivenLoosingClientId(List<String> loosingClientIds,List<Account> retrivedAccountsList){
            List<Account> matchingAccountsList = new List<Account>();
            for(String clientId:loosingClientIds){
                 for(Account accountToMatch:retrivedAccountsList){
                    if(accountToMatch.Clientidentifier__c.equals(clientId)){
                        matchingAccountsList.add(accountToMatch);
                    }
                }
            }
            return matchingAccountsList;
        }

        private Account getLatestSFDCValue(Account winningAccount, List<Account> accList){
            for(Account acc : accList){
                if(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME.equalsIgnoreCase(acc.recordtype.name) && acc.LivingArrangementsModDate__c != null
                        && isLivingArrangementsModDateValid(winningAccount, acc)){
                    winningAccount.LivingArrangements__c = acc.LivingArrangements__c;
                    winningAccount.LivingArrangementsModDate__c = acc.LivingArrangementsModDate__c;
                    winningAccount.LivingArrangementsOtherDescription__c = acc.LivingArrangementsOtherDescription__c;
                }
                else if(UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME.equalsIgnoreCase(acc.recordtype.name) && acc.NumberOfEmployeesModDate__c != null
                        && isNumberOfEmployeesModDateValid(winningAccount, acc)){
                    winningAccount.NumberOfEmployees = acc.NumberOfEmployees;
                    winningAccount.NumberOfEmployeesModDate__c = acc.NumberOfEmployeesModDate__c;
                }
            }
            return winningAccount;
        }

        private boolean isLivingArrangementsModDateValid(Account winningAccount, Account acc) {

            return ((winningAccount.LivingArrangementsModDate__c != null && acc.LivingArrangementsModDate__c > winningAccount.LivingArrangementsModDate__c)
                        || winningAccount.LivingArrangementsModDate__c == null);
        }

        private boolean isNumberOfEmployeesModDateValid(Account winningAccount, Account acc){
            return ((winningAccount.NumberOfEmployeesModDate__c != null && acc.NumberOfEmployeesModDate__c > winningAccount.NumberOfEmployeesModDate__c)
                        || winningAccount.NumberOfEmployeesModDate__c == null);
        }

        private void handleBillingParticipant(Account winningAccount, List<Billing_Participant__c> losingBillingParticipants){
            List<Billing_Participant__c> billingParticipantsToBeUpdated = new List<Billing_Participant__c>();
            for(Billing_Participant__c billingParticipant : losingBillingParticipants) {
                billingParticipant.Primary_Household__c = winningAccount.Primary_Household__pc;
                billingParticipantsToBeUpdated.add(billingParticipant);
            }
            if(!billingParticipantsToBeUpdated.isEmpty()){
                update billingParticipantsToBeUpdated;
            }
        }

        private void handleAccountNote(Account winningAccount, List<Account_Note__c> accountNotes){
            List<Account_Note__c> accountNotesToBeUpdated = new List<Account_Note__c>();
            for(Account_Note__c accountNote : accountNotes) {
                accountNote.Primary_Household__c = winningAccount.Primary_Household__pc;
                accountNotesToBeUpdated.add(accountNote);
            }
            if(!accountNotesToBeUpdated.isEmpty()){
                update accountNotesToBeUpdated;
            }
        }

        private void handlePlanningConversationLog(List<PlanningConversationLog__c> planningConversationLogListToBeUpdated,PlanningConLogWrapperList planConWrapper) {
            List<PlanningConversationLog__c> losingAccountPlanningConversationLogList = planConWrapper.losingAccountPlanningConversationLogList;
            Set<String> agentExternalIdSetFromAgentRoleJSON = planConWrapper.agentExternalIdSetFromAgentRoleJSON;
            Id systemUserId = planConWrapper.systemUserId;
            for(PlanningConversationLog__c losingAccountPlanningConversationLog : losingAccountPlanningConversationLogList) {
                if(!agentExternalIdSetFromAgentRoleJSON.contains(losingAccountPlanningConversationLog.Agent__r.Associate_Id__c)) {
                    losingAccountPlanningConversationLog.ownerId = systemUserId;
                    planningConversationLogListToBeUpdated.add(losingAccountPlanningConversationLog);
                }
            }
        }

        private void handleSimpleConversation(List<SimpleConversation__c> simpleConversationListToBeUpdated,SimpleConWrapperList simpleConvWrapper){
            List<SimpleConversation__c> losingAccountSimpleConversationList = simpleConvWrapper.losingAccountSimpleConversationList;
            Set<String> agentExternalIdSetFromAgentRoleJSON = simpleConvWrapper.agentExternalIdSetFromAgentRoleJSON;
            Id systemUserId = simpleConvWrapper.systemUserId;
            for(SimpleConversation__c losingAccountSimpleConversation : losingAccountSimpleConversationList) {
                if(!agentExternalIdSetFromAgentRoleJSON.contains(losingAccountSimpleConversation.Agent__r.Associate_Id__c)) {
                    losingAccountSimpleConversation.ownerId = systemUserId;
                    simpleConversationListToBeUpdated.add(losingAccountSimpleConversation);
                }
            }
        }

        private void assignAccountMessage(List<AccountMessage__c> accountMsgStatusFutureList,List<AccountMessage__c> accountMsgStatusSentList,AccountMessaageWrapperList assignAccWrapper){
            List<AccountMessage__c> accountMsgList = assignAccWrapper.accountMsgList;
            Account winningAccount = assignAccWrapper.winningAccount;
			for(AccountMessage__c accountMsg: accountMsgList) {
                if(accountMSg.Status__c.equals(UTIL_StageOrchestrationConstants.ACCOUNT_MESSAGE_STATUS)) {
                    accountMsgStatusFutureList.add(accountMsg);
                }
                else {
                    accountMsg.Account__c=winningAccount.Id;
                    accountMsgStatusSentList.add(accountMsg);
                }
            }
	    }
    }

    private class PlanningConLogWrapperList{
		private List<PlanningConversationLog__c> losingAccountPlanningConversationLogList;
		private Set<String> agentExternalIdSetFromAgentRoleJSON;
		private Id systemUserId;
	}

    private class SimpleConWrapperList{
		private List<SimpleConversation__c> losingAccountSimpleConversationList;
		private Set<String> agentExternalIdSetFromAgentRoleJSON;
		private Id systemUserId;
	}

    private class AccountMessaageWrapperList{
		private List<AccountMessage__c> accountMsgList;
		private Account winningAccount;
	}

    private without sharing class UTIL_CombineProcessorWrapper2 {

        private void handleAssignedStaff(AssignedStaffWrapperList handleStaffWrapper){
            Account winningAccount = handleStaffWrapper.winningAccount;
            List<AssignedStaff__c> losingAccountAssignedStaff = handleStaffWrapper.losingAccountAssignedStaff;
            Set<String> agentIdFromAgentRoles = handleStaffWrapper.agentIdFromAgentRoles;
            List<AssignedStaff__c> assignedStaffListToUpdate = handleStaffWrapper.assignedStaffListToUpdate;
            Map<Id, AssignedStaff__c> assignedStaffMapToUpdate = handleStaffWrapper.assignedStaffMapToUpdate;
            List<AssignedStaff__c> assignedStaffListToDelete = handleStaffWrapper.assignedStaffListToDelete;
            Map<String, List<String>> winningAgentToStaffMap = populateAssignStaffMap(winningAccount.AssignedStaff__r);
			for(AssignedStaff__c losingAssignStaff : losingAccountAssignedStaff){
                if(agentIdFromAgentRoles.contains(losingAssignStaff.Agent__r.Associate_Id__c) && checkForAssignStaffMove(losingAssignStaff, winningAgentToStaffMap)){
                    losingAssignStaff.Customer__c = winningAccount.id;
                    assignedStaffListToUpdate.add(losingAssignStaff);
                    assignedStaffMapToUpdate.put(losingAssignStaff.id, losingAssignStaff);
                    winningAgentToStaffMap = addToAgentToStaffMap(winningAgentToStaffMap, losingAssignStaff);
                }
                else {
                    assignedStaffListToDelete.add(losingAssignStaff);
                }
            }
	    }

        private Boolean checkForAssignStaffMove(AssignedStaff__c losingAssignStaff, Map<String, List<String>> winningAgentToStaffMap){
            Boolean isUpdateReqd = true;
            if(winningAgentToStaffMap.containsKey(losingAssignStaff.Agent__r.Associate_Id__c)){
                for(String staffAssocId: winningAgentToStaffMap.get(losingAssignStaff.Agent__r.Associate_Id__c)){
                    if(staffAssocId.equalsIgnoreCase(losingAssignStaff.Staff__r.Associate_Id__c)){
                        isUpdateReqd = false;
                        break;
                    }
                }
            }
            return isUpdateReqd;
        }

        private Map<String, List<String>> populateAssignStaffMap(List<AssignedStaff__c> assignStaffList){
            Map<String, List<String>> agentToStaffAssignStaffMap = new Map<String, List<String>>();
            if(!assignStaffList.isEmpty()){
                for(AssignedStaff__c assignStaff: assignStaffList){
                    agentToStaffAssignStaffMap = addToAgentToStaffMap(agentToStaffAssignStaffMap, assignStaff);
                }
            }
            return agentToStaffAssignStaffMap;
        }

        private Map<String, List<String>> addToAgentToStaffMap(Map<String, List<String>> agentToStaffAssignStaffMap, AssignedStaff__c assignStaff) {
            if(agentToStaffAssignStaffMap.containsKey(assignStaff.Agent__r.Associate_Id__c)){
                List<String> assignedStaffAssocIdList = agentToStaffAssignStaffMap.get(assignStaff.Agent__r.Associate_Id__c);
                assignedStaffAssocIdList.add(assignStaff.Staff__r.Associate_Id__c);
                agentToStaffAssignStaffMap.put(assignStaff.Agent__r.Associate_Id__c, assignedStaffAssocIdList);
            }
            else {
                agentToStaffAssignStaffMap.put(assignStaff.Agent__r.Associate_Id__c, new List<String>{assignStaff.Staff__r.Associate_Id__c});
            }
            return agentToStaffAssignStaffMap;
        }

        private void apiCallMerge(CallMergeWrapperList apiCallWrapper){
            List<Account> losingMergeAccountsList = apiCallWrapper.losingMergeAccountsList;
            Account winningMergeAccount = apiCallWrapper.winningMergeAccount;
            boolean isFSCEnabled = apiCallWrapper.isFSCEnabled;
            List<AccountContactRelation> winningAcrList = apiCallWrapper.winningAcrList;
            for (Integer a=0;a<losingMergeAccountsList.size();)
            {
             List<id> loosingAccountIdsToDelete = new List<id>();
                if(a<losingMergeAccountsList.size()){
                    loosingAccountIdsToDelete.add(losingMergeAccountsList[a].id);
                }
                if(a+1<losingMergeAccountsList.size()){
                    loosingAccountIdsToDelete.add(losingMergeAccountsList[a+1].id);
                }
                doMerge(new Account(Id=winningMergeAccount.Id),loosingAccountIdsToDelete);
                loosingAccountIdsToDelete.clear();
                a=a+2;
            }
            if(isFSCEnabled){
              updateACR(winningAcrList);
            }
        }

        private void updateACR(List<AccountContactRelation> winningAccountACRList,List<AccountContactRelation> acrsToBeUpdated){
            for(AccountContactRelation winnigACR : winningAccountACRList){
                    if(winnigACR.isActive){
                        acrsToBeUpdated.add(winnigACR);
                    }
                }
        }

        private void getMessage(Exception exp,Savepoint sp){
            if(exp.getmessage()!=UTIL_StageOrchestrationConstants.INVALID_USER_NOT_FOUND){
                    Database.rollback(sp);
            }
        }

        private List<AssignedStaff__c> handleFailedAssignedStaff(List<Database.SaveResult> updateAssignedStaffResult, Map<Id, AssignedStaff__c> assignedStaffMapToUpdate){
            for(Database.SaveResult saveResult: updateAssignedStaffResult){
                if(saveResult.isSuccess()){
                    assignedStaffMapToUpdate.remove(saveResult.getId());
                }
            }
            return assignedStaffMapToUpdate.values();
        }

        private void removingC2CRelationship(List<Relationship__c> losingC2CList,List<Relationship__c> winningC2CMasterList,List<Relationship__c> dedupedRelationshipLstToDelete){
            Set<Id> relationshipIdSetToDedupe = new Set<Id>();
            losingC2CList.addAll(winningC2CMasterList);

            for(Relationship__c rel : losingC2CList) {
                if(!relationshipIdSetToDedupe.contains(rel.Id)){
                    dedupedRelationshipLstToDelete.add(rel);
                    relationshipIdSetToDedupe.add(rel.Id);
                }
            }
        }

        private void handleCICData(List<CustomerInitiatedCancellations__c> losingAccountCICList, Account winningAccount, List<CustomerInitiatedCancellations__c> cicListToBeUpdated){
            for(CustomerInitiatedCancellations__c losingAccountCIC : losingAccountCICList) {
                losingAccountCIC.Customer__c = winningAccount.Id;
                cicListToBeUpdated.add(losingAccountCIC);
            }
        }
    }

    private class AssignedStaffWrapperList{
		private Account winningAccount;
		private List<AssignedStaff__c> losingAccountAssignedStaff;
		private Set<String> agentIdFromAgentRoles;
		private List<AssignedStaff__c> assignedStaffListToUpdate;
		private Map<Id, AssignedStaff__c> assignedStaffMapToUpdate;
		private List<AssignedStaff__c> assignedStaffListToDelete;
	}

    private class CallMergeWrapperList{
		private List<Account> losingMergeAccountsList;
		private Account winningMergeAccount;
		private boolean isFSCEnabled;
		private List<AccountContactRelation> winningAcrList;
	}
}
