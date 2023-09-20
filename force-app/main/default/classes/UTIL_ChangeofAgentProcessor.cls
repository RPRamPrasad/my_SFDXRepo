/****************************************************************************************
Name: ChangeofAgentProcessor
Copyright © State Farm
=========================================================================================
Purpose:
-------
Decription: This class is responsible for reassiging a customer from one to another book of bussiness
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0           Nithin Malla              04/25/2018              Initial Development
2.0           Golden Spikes             05/16/2018              Updated to handle planning conversation log record owner as SYSTEM_USER_REC_OWNER for removed book of business.
3.0           Golden Spikes             08/16/2018              Updated to handle simple conversation record owner as SYSTEM_USER_REC_OWNER for removed book of business.
3.1           Targaryen                 04/01/2019              Updated to handle tasks which are assigned to contacts
3.2           Golden Spikes             10/21/2019              Updated to delete lead records on the loosing agent relationship.
3.3           Golden Spikes             02/26/2020              Added logic to update the Lead Metric object for delete Lead records on the loosing agent relationship.
3.4           Club Car                  01/05/2021              Added logic to handle Signed Written Consent related to loosing agent relationship.
******************************************************************************************/
/**
 * @description class for Change of Agent Processor
 */
public without sharing class UTIL_ChangeofAgentProcessor extends UTIL_StageOrchestrationProcessor{

    private static final String CLASS_NAME = 'UTIL_ChangeofAgentProcessor';
    private String entityIsDeleted='ENTITY_IS_DELETED';
    private String executeMethodName='execute';
    private static final String NULL_STRING = null;
    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
    private static UTIL_ChangeofAgentProcessorWrapper agentprocessorwrap = new UTIL_ChangeofAgentProcessorWrapper();
   /**
    * @description method Execute method for Change of Agent Processor implemented from UTIL_OrchestrationProcessor
    * @param stageOrchestrationList
    */
    public override void execute(List<StageOrchestration__c> stageOrchestrationList){
        StageOrchestration__c stageOrchestration = stageOrchestrationList.get(0);

        Savepoint sp;

        try{
            sp = Database.setSavepoint();
            final AP_StageOrchestrationJSONParser jsonObject = parseJSON(stageOrchestration.Value__c);
            boolean isFailSafe=(StageOrchestration.ReprocessCount__c==UTIL_StageOrchestrationConstants.MAX_REPROCESS_COUNT);
            List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> agentjson = new List<AP_StageOrchestrationJSONParser.OrchestrationDataValues>();
            AgentRole__c newAgentRoleToUpsert = determineNewAgentRole(jsonObject, isFailSafe, agentjson);

            if(newAgentRoleToUpsert!= null){
                changeOfAgentProcessor(jsonObject, newAgentRoleToUpsert, agentjson);
            }else{
                UTIL_RemoveFromBookProcessor removeFromBookProcess =new UTIL_RemoveFromBookProcessor();
                removeFromBookProcess.execute(stageOrchestrationList); //Perfrom Remove from book process in diassociating child data for loosing agent
            }

        }catch(Exception exp){
            //Changes made to control deletion exception logic
            handleException(exp, CLASS_NAME, sp);
        }
    }

   /**
    *  @description helper function to call Approriate Processor
    *  @name  changeOfAgentProcessor
    *  @param jsonObject
    *  @param newAgentRoleToUpsert
    *  @param agentjson
    *  return Integer
    */
    private void changeOfAgentProcessor(AP_StageOrchestrationJSONParser jsonObject,AgentRole__c newAgentRoleToUpsert, List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> agentjson){

        String clientId = jsonObject.orchestrationInfo.orchestrationEventName.orchestrationEventDetail.orchestrationEventValues.clientId;
        String associateID = jsonObject.orchestrationInfo.orchestrationEventName.orchestrationEventDetail.orchestrationEventValues.fromAssociateId.trim();
        User proxyUser = UTIL_AgentOfficeDetails.getProxyforGivenServicingAgentAssocId(associateID);
        Id loosingAgentProxyId = proxyUser.id;

        List<Account> accountListWithChilddata = new List<Account>();
        for(Account act : [Select Id,
                              (select Id,Agent__c, Primary_Household__c from Agent_Roles__r where AgentRoleIdentifier__c =: associateID+UTIL_StageOrchestrationConstants.TILT_SYMBOL+clientId),
                              (Select Id,status,OwnerId,AssignedTo__c,CreatedDate,IsClosed,whoId From Tasks where OwnerId =: loosingAgentProxyId AND isRecurrence=false),
                              (Select Id From AccountMessage__r where AssociateID__c =:associateID AND Status__c =: UTIL_StageOrchestrationConstants.ACCOUNT_MESSAGE_STATUS),
                              (Select Id From PersonCampaignMembers WHERE Contact.Account.clientidentifier__c=:ClientId AND Campaign.OwnerId=: loosingAgentProxyId),
                              (Select Id From Customer_Groupings__r where Group__r.Agent__r.associate_ID__c=:associateID and Group__r.Agent__r.masterUserRecord__c = true),
                              (Select Id From AssignedStaff__r where ownerId =:loosingagentProxyId),
                              (Select Id From Leads__r where ownerId =:loosingagentProxyId),
                              (Select Id From ProductsServicedByMe__r Where OwnerId =:loosingAgentProxyId),
                              (Select Id From Planning_Conversation_Logs__r Where OwnerId =: loosingAgentProxyId),
                              (Select Id, Account__c,OfficeAssigned__c From Simple_Conversations__r where ownerId =: loosingAgentProxyId),
                              (Select Id From LeadMetrics__r where ownerId =:loosingagentProxyId),
                           	  (Select Id,InitiatedFromId__c from SignedWrittenConsent__r)
                              From account where clientidentifier__c=:ClientId]) {
            accountListWithChilddata.add(act);
        }
        if(!accountListWithChilddata.isEmpty()){
            List<AgentRole__C> agentRoles = accountListWithChilddata.get(0).Agent_Roles__r; //Loosing Agent Relationship
            if(!agentRoles.isEmpty()){
                UTIL_ChangeofAgentProcessor.ReassignmentProcessWrapperList reassignmentWrap = new UTIL_ChangeofAgentProcessor.ReassignmentProcessWrapperList();
	 			reassignmentWrap.accountWithChilddata = accountListWithChilddata.get(0);
	 			reassignmentWrap.agentRoleToSync = newAgentRoleToUpsert;
	 			reassignmentWrap.loosingAgentProxyId = loosingAgentProxyId;
	 			reassignmentWrap.agentjson = agentjson;

	 			performReassignmentProcess(reassignmentWrap);
                deleteAgentRole(agentRoles.get(0)); //deleting Loosing Agent relationship for given client
            }
        }

    }

  /**
    *  @description helper function to determine NewAgentRole
    *  @name determineNewAgentRole
    *  @param jsonObject
    *  @param isFailSafe
    *  @param agentjson
    *  @return AgentRole__c
    */
    private AgentRole__c determineNewAgentRole(AP_StageOrchestrationJSONParser jsonObject, Boolean isFailSafe, List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> agentjson){
        AgentRole__c newAgentRole=null;
        AP_StageOrchestrationJSONParser.OrchestrationDataValues newAgentJson = null;
        List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> listOfAgentRoleDataToSync=new List<AP_StageOrchestrationJSONParser.OrchestrationDataValues>();

        for(AP_StageOrchestrationJSONParser.OrchestrationDataName orchDataName : jsonObject.orchestrationInfo.orchestrationDataName){
            listOfAgentRoleDataToSync.add(orchDataName.orchestrationNameDetail.orchestrationDataValues);
        }
        AgentRoleWrapperList agentRoleDataWrap = new AgentRoleWrapperList();
		    agentRoleDataWrap.newAgentRole = newAgentRole;
		    agentRoleDataWrap.newAgentJson = newAgentJson;
		    agentRoleDataWrap.listOfAgentRoleDataToSync = listOfAgentRoleDataToSync;
		    agentRoleDataWrap.isFailSafe = isFailSafe;
		    agentRoleDataWrap.agentjson = agentjson;
		    agentRoleDataWrap.executeMethodName = executeMethodName;
	    return agentprocessorwrap.agentRoleData(agentRoleDataWrap);
    }

   /**
    *  @description helper function to perform Change of Agent Process
    *  @name  performReassignmentProcess
    *  @param performReassignmentWrapper
    */
    private void performReassignmentProcess(ReassignmentProcessWrapperList performReassignmentWrapper){
        Account accountWithChilddata = performReassignmentWrapper.accountWithChilddata;
        AgentRole__c agentRoleToSync = performReassignmentWrapper.agentRoleToSync;
        Id loosingAgentProxyId = performReassignmentWrapper.loosingAgentProxyId;
        List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> agentjson = performReassignmentWrapper.agentjson;
        Id systemuserId=getSystemRecordOwnerId();
        upsertUserAgentRole(agentRoleToSync);// Upserting New agent Relationship
        UTIL_OrchestrationJSONtoGroupDetails.HLPR_GroupAndGroupMemberWrapper groupDetails = UTIL_OrchestrationJSONtoGroupDetails.getListOfGroupDetails(agentjson);

                upsertCustomerHouseholdGroup(groupDetails.groupList);

                upsertCustomerHouseholdGroupMember(groupDetails.groupMemberList);


        List<agentRole__c> upsertedAR=[select Id,Agent__c,Agent__r.Associate_ID__C,Agent__r.State_Agent_Code__c,Agent__r.State_Agent_Code_List__c from AgentRole__c where AgentRoleIdentifier__c =: agentRoleToSync.AgentRoleIdentifier__c limit 1];

        User newAgentProxyUser = UTIL_AgentOfficeDetails.getProxyforGivenServicingAgentAssocId(upsertedAR.get(0).Agent__r.Associate_ID__C);
        UTIL_ChangeofAgentProcessor.ReassignTasksWrapperList tasksWrap = new UTIL_ChangeofAgentProcessor.ReassignTasksWrapperList();
	 			tasksWrap.accountId = accountWithChilddata.id;
	 			tasksWrap.loosingAgentProxyId = loosingAgentProxyId;
	 			tasksWrap.taskList = accountWithChilddata.tasks;
	 			tasksWrap.newAgentId = upsertedAR.get(0).Agent__c;
				tasksWrap.systemuserId = systemuserId;
	 	reassignTasksApproriately(tasksWrap);

        UTIL_ChangeofAgentProcessor.ReassignCaseWrapperList caseWrap = new UTIL_ChangeofAgentProcessor.ReassignCaseWrapperList();
	 			caseWrap.newAgentId = upsertedAR.get(0).Agent__c;
	 			caseWrap.systemuserId = systemuserId;
	 			caseWrap.newAgentProxyId = newAgentProxyUser.Id;
	 			caseWrap.accId = accountWithChilddata.Id;
				caseWrap.loosingAgentProxyId = loosingAgentProxyId;
	    reassignCasesApproriately(caseWrap);

        UTIL_ChangeofAgentProcessor.ReassignOpportunitiesWrapperList opportunitiesWrap = new UTIL_ChangeofAgentProcessor.ReassignOpportunitiesWrapperList();
	 			opportunitiesWrap.newAgentId = upsertedAR.get(0).Agent__c;
	 			opportunitiesWrap.newAgentProxyId = newAgentProxyUser.Id;
	 			opportunitiesWrap.systemUserId = systemuserId;
	 			opportunitiesWrap.acctRecord = accountWithChilddata;
				opportunitiesWrap.loosingAgentProxyId = loosingAgentProxyId;
                opportunitiesWrap.name=newAgentProxyUser.Name;
                opportunitiesWrap.stateAgentCode= upsertedAR.get(0).Agent__r.State_Agent_Code__c;
                opportunitiesWrap.stateAgentCodeListString = upsertedAR.get(0).Agent__r.State_Agent_Code_List__c;

	    reassignOpportunitiesApproriately(opportunitiesWrap);
        deleteAccountMessages(accountWithChilddata.AccountMessage__r); //deleting scheduled account messages from loosing agent
        deleteCampaignMembers(accountWithChilddata.PersonCampaignMembers); //deleting CampaignMembers that belong to the campaign owned by loosing agent
        deleteHouseholdGroupMember(accountWithChilddata.Customer_Groupings__r);//deleting Lead Record that belong to the losing agent
        UTIL_LeadConversionDetailDAO.deleteLead(accountWithChilddata.Leads__r); //deleting Lead Record that belong to the losing agent
        UTIL_LeadMetricsProcessor.updateLeadMetrics(accountWithChilddata.LeadMetrics__r); //Updating the Lead Metric object of deleting Lead Record that belong to the loosing Agent.
        deleteAssignedStaff(accountWithChilddata.AssignedStaff__r); //deleting Assigned staff that belong to the losing agent
        deleteProductsServicedByMe(accountWithChilddata.ProductsServicedByMe__r); //deleting ProductsServicedByMe for a particular Account associated with loosing Agent
        HLPR_PlanningConversationLogProcessor.reassignedPlanningConversationLogAgent(newAgentProxyUser.Id, accountWithChilddata.Planning_Conversation_Logs__r, upsertedAR.get(0).Agent__r.Id);
        HLPR_SimpleConversationProcessor.reassignedSimpleConversationAgent(newAgentProxyUser, upsertedAR.get(0).Agent__r.Id, accountWithChilddata.Simple_Conversations__r);
    }

    private class ReassignmentProcessWrapperList{
        private Account accountWithChilddata;
        private AgentRole__c agentRoleToSync;
        private Id loosingAgentProxyId;
        private List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> agentjson;
    }
   /**
    *  @description helper function to reassign Task To New Agent for a particular Account
    *  @name  reassignTasksApproriately
    *  @param approriatelyTasksWrapper
    */
    Private static void reassignTasksApproriately(ReassignTasksWrapperList approriatelyTasksWrapper){
        Id accountId = approriatelyTasksWrapper.accountId;
	    Id loosingAgentProxyId = approriatelyTasksWrapper.loosingAgentProxyId;
	    List<Task> taskList = approriatelyTasksWrapper.taskList;
	    Id newAgentId = approriatelyTasksWrapper.newAgentId;
	    Id systemuserId = approriatelyTasksWrapper.systemuserId;
        List<Task> listOfTaskToReassignorClose = new List<Task>();
        List<Id> taskWhatIdsList = new List<Id>{null, accountId};
        List<Account> listOfAccountWithPersonTasks = [Select Id, (Select id, status,OwnerId,AssignedTo__c,CreatedDate,IsClosed,whatId From PersonTasks where whatid in:taskWhatIdsList and OwnerId =:loosingAgentProxyId and isRecurrence=false)
                                                  from account where id =:accountId];
        List<Task> listOfPersonTasks = listOfAccountWithPersonTasks.get(0).PersonTasks;
        Set<Task> taskSet = new Set<Task>(taskList);
        taskSet.addAll(listOfPersonTasks);
        if(taskSet != null){
            for(Task tsk:taskSet){
                agentprocessorwrap.updatingTasks(tsk,newAgentId,systemuserId);
                listOfTaskToReassignorClose.add(tsk);
            }
        }
        UTIL_TaskDAO.updateTasks(listOfTaskToReassignorClose);
    }

    private class ReassignTasksWrapperList{
        private Id accountId;
        private Id loosingAgentProxyId;
        private List<Task> taskList;
        private Id newAgentId;
		private Id systemuserId;
	}

   /**
    *  @description helper function to reassign Cases To New Agent for a particular Account
    *  @name  reassignCasesApproriately
    *  @param approriateCaseWrapper
    */
    Private static void reassignCasesApproriately(ReassignCaseWrapperList approriateCaseWrapper){
        Id newAgentId = approriateCaseWrapper.newAgentId;
	    Id systemuserId = approriateCaseWrapper.systemuserId;
	    Id newAgentProxyId = approriateCaseWrapper.newAgentProxyId;
	    Id accId = approriateCaseWrapper.accId;
	    Id loosingAgentProxyId = approriateCaseWrapper.loosingAgentProxyId;
        List<Case> casesWithTasksList = [
            SELECT status,OwnerId,CreatedDate,IsClosed,Description,Assigned_To__c, (
                SELECT Id, WhoId, WhatId, Status, AccountId,CreatedDate,IsClosed,OwnerId,AssignedTo__c
                FROM Tasks
                WHERE OwnerId=:loosingAgentProxyId AND isRecurrence=false
            )
            FROM Case
            WHERE AccountId=:accId];

        List<Case> listOfCasesToReassignOrClose = new List<Case>();
        List<Task> taskListToUpdate = new List<Task>();
        if (casesWithTasksList != null) {
            for (Case caseRec:casesWithTasksList) {
                if (caseRec.OwnerId == loosingAgentProxyId) {

                    //evaluate Cases and Tasks to either close or reassign to the new Agent/Sys Rec Owner

                    UTIL_ChangeofAgentProcessor.ValidateCaseAndTasksReassignmentWrapperList caseAndTasksWrap = new UTIL_ChangeofAgentProcessor.ValidateCaseAndTasksReassignmentWrapperList();
	 				caseAndTasksWrap.caseRec = caseRec;
	 				caseAndTasksWrap.taskListToUpdate = taskListToUpdate;
	 				caseAndTasksWrap.newAgentId = newAgentId;
	 				caseAndTasksWrap.systemuserId = systemuserId;
					caseAndTasksWrap.newAgentProxyId = newAgentProxyId;
	 				validateCaseAndTasksReassignment(caseAndTasksWrap);
                    listOfCasesToReassignorClose.add(caseRec);

                } else if (caseRec.CreatedDate >= system.today() - 90) {

                    //the case is new enough; tasks which are owned by loosing agent should be reassigned to new agent
                    taskListToUpdate.addAll(reassignRelatedTasks(caseRec.Tasks, newAgentId));

                } else {

                    //due to age close the related tasks
                    taskListToUpdate.addAll(closeRelatedTasks(caseRec.Tasks, systemuserId, false));
                }
            }
        }

        UTIL_TaskDAO.updateTasks(taskListToUpdate);
        UTIL_CaseDAO.updateCases(listOfCasesToReassignOrClose);
    }

    private class ReassignCaseWrapperList{
        private Id newAgentId;
        private Id systemuserId;
        private Id newAgentProxyId;
        private Id accId;
		private Id loosingAgentProxyId;
    }

    private static void validateCaseAndTasksReassignment(ValidateCaseAndTasksReassignmentWrapperList validateCaseAndTasksWrapper) {
        Case caseRec = validateCaseAndTasksWrapper.caseRec;
	    List<Task> taskListToUpdate = validateCaseAndTasksWrapper.taskListToUpdate;
	    Id newAgentId = validateCaseAndTasksWrapper.newAgentId;
	    Id systemuserId = validateCaseAndTasksWrapper.systemuserId;
	    Id newAgentProxyId = validateCaseAndTasksWrapper.newAgentProxyId;
        if (caseRec.CreatedDate >= system.today() - 90) {
            taskListToUpdate.addAll(reassignRelatedTasks(caseRec.Tasks, newAgentId));

            caseRec.Assigned_To__c = newAgentId;
            caseRec.OwnerId = newAgentProxyId;

        } else if (!caseRec.IsClosed) {
            taskListToUpdate.addAll(closeRelatedTasks(caseRec.Tasks, systemuserId, false));

            caseRec.status = UTIL_StageOrchestrationConstants.CASE_CLOSE_STATUS;
            caseRec.Assigned_To__c = caseRec.OwnerId;
            caseRec.OwnerId = systemuserId;
            caseRec.AssignmentReason__c = 'changeOfAgent - closed and reassigned due to age';

        } else {

            caseRec.Assigned_To__c = caseRec.OwnerId;
            caseRec.OwnerId = systemuserId;
            caseRec.AssignmentReason__c = 'changeOfAgent - previously closed';

        }
    }

    private class ValidateCaseAndTasksReassignmentWrapperList{
        private Case caseRec;
        private List<Task> taskListToUpdate;
        private Id newAgentId;
        private Id systemuserId;
		private Id newAgentProxyId;
    }

    private static List<Task> closeRelatedTasks(List<Task> taskList, Id userId, boolean isOppTask){
        return agentprocessorwrap.updateTaskList(taskList,isOppTask,userId);
    }

       private static List<Task> reassignRelatedTasks(List<Task> taskList,Id newAgentId){
        return agentprocessorwrap.reassignRelatedTasks(taskList,newAgentId);
    }

    private static List<Task> reassignRelatedTasksForOpps(List<Task> taskList,Id newAgentId, Id systemUserId){

        List<Task> taskListToReassign = new List<Task>();
        List<Task> swcTaskListToClose = new List<Task>();
        if (taskList !=null) {
            for (Task taskToUpdate : taskList){
                if(taskToUpdate.TaskCategory__c == 'SignedWrittenConsent' && taskToUpdate.AppCode__c == 'SFDC_MKTCLD'){
                    swcTaskListToClose.add(taskToUpdate);
                }
                else{
                    taskToUpdate.AssignedTo__c = NULL_STRING;
                    taskToUpdate.OwnerId = newAgentId;
                    taskListToReassign.add(taskToUpdate);
                }
            }
            taskListToReassign.addAll(closeRelatedTasks(swcTaskListToClose,systemUserId, false));
        }

        return taskListToReassign;
    }

    private void reassignOpportunitiesApproriately(ReassignOpportunitiesWrapperList approriateOpportunitiesWrapper){
        Id newAgentId = approriateOpportunitiesWrapper.newAgentId;
	    Id newAgentProxyId = approriateOpportunitiesWrapper.newAgentProxyId;
	    Id systemUserId = approriateOpportunitiesWrapper.systemUserId;
	    Account acctRecord = approriateOpportunitiesWrapper.acctRecord;
	    Id loosingAgentProxyId = approriateOpportunitiesWrapper.loosingAgentProxyId;

        List<opportunity> oppWithTasksList = [Select StageName,State_Code__c,credit_status__c,Opportunity_Originator__c,Closed_Reason__c,Description,Assigned_To__c,OwnerId,CreatedDate,RecordType.name,IsClosed,
                                              OppSignedWrittenConsentStatus__c,OppSignedWrittenConsentRequestedDate__c,OppSignedWrittenConsentGrantedDate__c,DateCaptured__c,Transaction_Type__c,Transfer_Date__c,
                                              (SELECT Id, WhoId, WhatId, Status,TaskCategory__c, AppCode__c,AccountId,CreatedDate,IsClosed,OwnerId,AssignedTo__c
                                               FROM Tasks where OwnerId=:loosingAgentProxyId AND isRecurrence=false)
                                              FROM opportunity where AccountId= :acctRecord.Id AND OwnerId =:loosingAgentProxyId];
        String newOrUpdatedStateCodeValue = Opportunity_COAProcessor.getStateCodeBasedOnStateCode(approriateOpportunitiesWrapper.stateAgentCode);
        //String newOrUpdatedStateCodeValue = Opportunity_COAProcessor.getStateCodeFromNewAgentOffice(approriateOpportunitiesWrapper.name);
        List<Opportunity> winningAgentOpportunityList = UTIL_AccountProcessorsSwcHandler.getWinningAgentOpportunityList(acctRecord.Id, newAgentProxyId);
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        List<Task> taskListToUpdate = new List<Task>();
        Set<Id> oppIdSet = new Set<Id>();
        List<SignedWrittenConsent__c> swcList = new List<SignedWrittenConsent__c>();
        swcList.addAll(acctRecord.SignedWrittenConsent__r);

         if (oppWithTasksList != null) {

            for (opportunity opp:oppWithTasksList) {
                String updatedStateCodeValue = '';
                oppIdSet.add(opp.Id);
                UTIL_AccountProcessorsSwcHandler.updateOpportunitySwconCOA(opp,winningAgentOpportunityList);
                opp.Transaction_Type__c='Change of Agent';
                opp.Transfer_Date__c=system.now();
                updatedStateCodeValue = Opportunity_COAProcessor.validateSAndMStcodeAssignStateCode(approriateOpportunitiesWrapper,newOrUpdatedStateCodeValue, opp.State_Code__c);
                if (opp.CreatedDate>=system.today()-30 && !(('Internet Lead Provider').equals(opp.Opportunity_Originator__c) ||('RFC Granted').equals(opp.credit_status__c))){

                    taskListToUpdate.addAll(reassignRelatedTasksForOpps(opp.Tasks, newAgentId, systemUserId));
                    opp.OwnerId=newAgentProxyId;
                    opp.Assigned_To__c=NULL_STRING;
                    opp.State_Code__c = updatedStateCodeValue;
                    oppListToUpdate.add(opp);

                } else if (!(('Internet Lead Provider').equals(opp.Opportunity_Originator__c) || ('RFC Granted').equals(opp.credit_status__c))) {
                    taskListToUpdate.addAll(closeRelatedTasks(opp.Tasks,newAgentId, true));
                    opp.State_Code__c = updatedStateCodeValue;
                    oppListToUpdate.add(closeOpportunitiesAndUpdateOwnerToSystemUser(opp, NULL_STRING, newAgentProxyId));
                } else {

                    taskListToUpdate.addAll(closeRelatedTasks(opp.Tasks,systemUserId, false));

                    oppListToUpdate.add(closeOpportunitiesAndUpdateOwnerToSystemUser(opp, opp.OwnerId, systemUserId ));

                }
            }
        }

    	UTIL_AccountProcessorsSwcHandler.updateSwcRecordsToNotApplicable(swcList,oppIdSet);
        UTIL_TaskDAO.updateTasks(taskListToUpdate);
        UTIL_OpportunityDAO.updateOpportunityForAccount(oppListToUpdate);
    }
    /**
     * @description Inner class ReassignOpportunitiesWrapperList
     */
    public class ReassignOpportunitiesWrapperList{
        public Id newAgentId;
        public Id newAgentProxyId;
        public Id systemUserId;
        public Account acctRecord;
		public Id loosingAgentProxyId;
        public String name;
        public String stateAgentCodeListString;
        public String stateAgentCode;
    }

   /**
    *  @description helper function to delete HouseHoldGroupMember for a particular Account associated with Particular Agent
    *  @name  deleteHouseholdGroupMember
    *  @param existingGroupMemberList
    */
    private void deleteHouseholdGroupMember(List<CustomerGroupMember__c> existingGroupMemberList){
        //checking weather Grouping feature is Enable to transform
        boolean isFeatureEnabledToTransform=toggleContext.isActive(UTIL_Toggles.CUSTOMERGROUPINGS);
        if(isFeatureEnabledToTransform){
            deleteCustomerHouseholdGroupMember(existingGroupMemberList);
        }
    }

    private with sharing class UTIL_ChangeofAgentProcessorWrapper{

        private AgentRole__c agentRoleData(AgentRoleWrapperList agentWrapper){
            AgentRole__c newAgentRole = agentWrapper.newAgentRole;
            AP_StageOrchestrationJSONParser.OrchestrationDataValues newAgentJson = agentWrapper.newAgentJson;
            List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> listOfAgentRoleDataToSync = agentWrapper.listOfAgentRoleDataToSync;
            Boolean isFailSafe = agentWrapper.isFailSafe;
            List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> agentjson = agentWrapper.agentjson;
            String executeMethodName = agentWrapper.executeMethodName;
            if(listOfAgentRoleDataToSync.size()>1){
                List<Date> startDateToValidateList = new List<Date>();
                Date maxDate=Date.valueOf(listOfAgentRoleDataToSync.get(0).startDate);
                newAgentJson=listOfAgentRoleDataToSync.get(0);
                for(AP_StageOrchestrationJSONParser.OrchestrationDataValues jsonARValues:listOfAgentRoleDataToSync){
                    if(maxDate < Date.valueOf(jsonARValues.startDate)){
                        maxDate = Date.valueOf(jsonARValues.startDate);
                        newAgentJson =  jsonARValues;
                    }
                    startDateToValidateList.add(Date.valueOf(jsonARValues.startDate));
                }
                Integer numberOfOccurances=getOccurancesOfMaxDatet(maxDate,startDateToValidateList);
                if(numberOfOccurances==1) {
                    newAgentRole = getAgentRoleObjectFromJson(newAgentJson, isFailSafe,executeMethodName);
                }
            } else if(listOfAgentRoleDataToSync.size()==1){
                newAgentJson = listOfAgentRoleDataToSync.get(0);
                agentjson.add(newAgentJson);
                newAgentRole = getAgentRoleObjectFromJson(newAgentJson, isFailSafe,executeMethodName);
            }
            return newAgentRole;
        }

        private Integer getOccurancesOfMaxDatet(Date maxDate,List<Date> startDateToValidateList){
            Integer numberOfOccurances=0;
            for(Date dt:startDateToValidateList){
                if(maxDate==dt){
                    numberOfOccurances=numberOfOccurances+1;
                }
            }
            return numberOfOccurances;
        }

        private AgentRole__c getAgentRoleObjectFromJson(AP_StageOrchestrationJSONParser.OrchestrationDataValues jsonARValues, Boolean isFailSafe,String executeMethodName){
            AgentRole__c agentRole = null;
            String agentUserExternalId=jsonARValues.agent+'_'+jsonARValues.agent;
            User agentUserDetails;
            try{   
                agentUserDetails = [Select UserExternalID__c,id,Associate_ID__c from User where UserExternalID__c = :agentUserExternalId and SubUserType__c in ('Agent', 'PSO', 'SFO')];
                agentRole = new AgentRole__c();
                agentRole.RelationshipNature__c = UTIL_OrchestrationJSONtoAgentRole.getRelationShipNature(jsonARValues.relationshipNature);
                agentRole.AgentRoleIdentifier__c = jsonARValues.agent+UTIL_Constants.TILT_SYMBOL+jsonARValues.customer;
                agentRole.Customer__r=new account(clientidentifier__c=jsonARValues.customer);
                agentRole.Agent__r=new User(UserExternalID__c=agentUserExternalId);
                agentRole.RelationshipStartDate__c=date.valueOf(jsonARValues.startDate);
            } catch(System.QueryException ex){
                if(!isFailSafe && agentUserDetails == null){
                    throw new DataNotFoundException(UTIL_StageOrchestrationConstants.INVALID_USER_NOT_FOUND);
                } else {
                    LoggingService.logHandledException(ex,CLASS_NAME, executeMethodName , LoggingLevel.WARN);
                }
            }
            return agentRole;
        }

        private void updatingTasks(Task tsk,Id newAgentId,Id systemuserId){
            if(tsk.CreatedDate>=system.today()-90){
                        tsk.OwnerId=newAgentId;
                        tsk.AssignedTo__c=newAgentId;
                    }else if(!tsk.IsClosed){
                        //Updating Task status to complete if it not a completed status
                        tsk.status = UTIL_StageOrchestrationConstants.OPPORTUNITY_TASK_CLOSED_REASON;
                        tsk.AssignedTo__c=tsk.OwnerId;//assigning proxy user to all the task for future purpose
                        tsk.OwnerId=systemuserId;//assigning statefarm user
                    }else{
                        tsk.AssignedTo__c=tsk.OwnerId;//assigning proxy user to all the task for future purpose
                        tsk.OwnerId=systemuserId;//assigning statefarm user
                    }
        }

        private List<Task> updateTaskList(List<Task> taskList,boolean isOppTask,Id userId){
            List<Task> taskListToUpdate = new List<Task>();
            if (taskList !=null) {
                for (Task taskToUpdate : taskList) {

                    if (!taskToUpdate.IsClosed) {
                        taskToUpdate.Status = UTIL_StageOrchestrationConstants.OPPORTUNITY_TASK_CLOSED_REASON;
                    }

                    if (isOppTask) {
                        taskToUpdate.AssignedTo__c = NULL_STRING;
                    } else {
                        taskToUpdate.AssignedTo__c = taskToUpdate.OwnerId;
                    }

                    taskToUpdate.OwnerId = userId;
                    taskListToUpdate.add(taskToUpdate);
                }
            }
            return taskListToUpdate;
        }

        private List<Task> reassignRelatedTasks(List<Task> taskList,Id newAgentId){
            List<Task> taskListToReassign = new List<Task>();
            if (taskList !=null) {
                for (Task taskToUpdate : taskList){
                    taskToUpdate.AssignedTo__c = newAgentId;
                    taskToUpdate.OwnerId = newAgentId;
                    taskListToReassign.add(taskToUpdate);
                }
            }
            return taskListToReassign;
        }

    }
    private class AgentRoleWrapperList{
		private AgentRole__c newAgentRole;
		private AP_StageOrchestrationJSONParser.OrchestrationDataValues newAgentJson;
		private List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> listOfAgentRoleDataToSync;
		private Boolean isFailSafe;
		private List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> agentjson;
		private String executeMethodName;
	}

}