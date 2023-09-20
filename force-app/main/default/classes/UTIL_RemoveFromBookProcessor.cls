/****************************************************************************************
Name: RemoveFromBookProcessor
Copyright © State Farm
=========================================================================================
Purpose:
-------
Decription: This class is responsible deleting a customer from the book of bussiness
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0            Zeev Feldbeine           10/05/2016              Initial Development
2.0            Zeev Feldbeine           11/05/2016              added logic
2.0            Zeev Feldbeine           11/18/2016              Added logic/fixed
3.0            Zeev Feldbeine           11/30/2016              fixed errors/bags
4.0            Abhiram Raja Vemuri      02/01/2016              fixed defect
5.0            Nithin Malla             02/06/2017              added logic
6.0            Kalimatha Mandadi        03/06/2017              Fixed exception logic for Defect
7.0            Jonathan Elliott         03/23/2017              Fix for defect 17485 (recurrent tasks)
8.0            Hemanth Lakkam           05/25/2017              Added logic for Case object
9.0            Suvankar Saha            12/28/2017              Household Member Removed
10.0           Nithin Malla             04/18/2018              added logic/Improved SOQL's
11.0           Golden Spikes            05/10/2018              Added logic for Planning Conversation Log Object for removed book of business
12.0           Shenanigans              07/18/2018              Added logic for Customer Initiated Cancellations Object for removed book of business
13.0           Golden Spikes            08/10/2018              Added logic for Simple Conversation Object for removed book of business
14.0           Targaryen                04/01/2019              Added logic to handle tasks which are associated to contacts
15.0           Golden Spikes            10/15/2019              Added logic for Lead Object for removed book of business
16.0           Golden Spikes            02/21/2020              Added logic for LeadMetric Object for removed book of business
17.0		   Club Car					01/26/2021				Added logic to clear Signed Written Consent on remove book of business.
******************************************************************************************/
/**
 * @description This class is responsible deleting a customer from the book of bussiness
 */
public without sharing class UTIL_RemoveFromBookProcessor extends UTIL_StageOrchestrationProcessor{

    private static final String CLASS_NAME = 'UTIL_RemoveFromBookProcessor';
    private String entityIsDeleted='ENTITY_IS_DELETED';
    private String executeMethodName='execute';
    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();

   /**
    * @description Execute method for Remove From Book Processor implemented from UTIL_OrchestrationProcessor
    * @param stageOrchestrationList
    */
    public override void execute(List<StageOrchestration__c> stageOrchestrationList){

        StageOrchestration__c stageOrchestration = stageOrchestrationList.get(0);
             Savepoint sp;

        try{
            sp = Database.setSavepoint();
            final AP_StageOrchestrationJSONParser jsonObject = parseJSON(stageOrchestration.Value__c);
            String clientId = jsonObject.orchestrationInfo.orchestrationEventName.orchestrationEventDetail.orchestrationEventValues.clientId;
            String associateID = jsonObject.orchestrationInfo.orchestrationEventName.orchestrationEventDetail.orchestrationEventValues.fromAssociateId.trim();
            User proxyUser = UTIL_AgentOfficeDetails.getProxyforGivenServicingAgentAssocId(associateID);
            Id agentProxyId = proxyUser.id;
            List<Account> accountListWithChilddata = new List<Account>();
            for(Account act : [Select id,
                                (select Id,Agent__c, Primary_Household__c from Agent_Roles__r where AgentRoleIdentifier__c =: associateID+UTIL_StageOrchestrationConstants.TILT_SYMBOL+clientId),
                                (Select Id,status,OwnerId,AssignedTo__c,whoId From Tasks where OwnerId =: agentProxyId AND isRecurrence=false),
                                (Select Id From AccountMessage__r where AssociateID__c =:associateID AND Status__c =: UTIL_StageOrchestrationConstants.ACCOUNT_MESSAGE_STATUS),
                                (Select Id From PersonCampaignMembers WHERE Contact.Account.clientidentifier__c=:ClientId AND Campaign.OwnerId=: agentProxyId),
                                (Select Id From Customer_Groupings__r where Group__r.Agent__r.associate_ID__c=:associateID and Group__r.Agent__r.masterUserRecord__c = true),
                                (Select Id From ProductsServicedByMe__r Where OwnerId =:agentProxyId),
                                (Select Id From AssignedStaff__r where ownerId =:agentProxyId),
                                (Select Id From Leads__r where ownerId =:agentProxyId),
                                (Select Id From Planning_Conversation_Logs__r where ownerId =: agentProxyId),
                                (Select Id From Simple_Conversations__r where ownerId =: agentProxyId),
                                (Select Id From Customer_Initiated_Cancellations__r where ownerId =: agentProxyId),
                                (Select Id From LeadMetrics__r where ownerId =: agentProxyId),
                               	(Select Id,InitiatedFromId__c from SignedWrittenConsent__r)
                                From account where clientidentifier__c=:ClientId]) {
                accountListWithChilddata.add(act);
            }

            List<AgentRole__C> agentRoles = accountListWithChilddata.get(0).Agent_Roles__r; //Loosing Agent Relationship
            if(!accountListWithChilddata.isEmpty()){
                if(!agentRoles.isEmpty()){
                    executeRemoveFromBookProcess(accountListWithChilddata.get(0),agentProxyId, agentRoles); //Perfrom Remove from book process in diassociating child data for loosing agent
                    deleteAgentRole(agentRoles.get(0)); //deleting Loosing Agent relationship for given client
                }
            }
        }catch(Exception exp){
            //Changes made to control deletion exception logic
            handleException(exp, CLASS_NAME, sp);
        }
    }

    /**
     * @description test method used to execute remove from book process
     * @param accountWithChilddata
     * @param loosingAgentProxyId
     * @param agentRoles
     */
    public void executeRemoveFromBookProcess(Account accountWithChilddata, Id loosingAgentProxyId, List<AgentRole__C> agentRoles){

        Id systemuserId=getSystemRecordOwnerId();
        updateAllTasks(accountWithChilddata,systemuserId,loosingAgentProxyId); //Removing tasks of loosing customers from book of bussienss
        updateCases(accountWithChilddata.Id,systemuserId,loosingAgentProxyId);
        closeOpportunitiesAndAssociatedTasks(accountWithChilddata,systemuserId,loosingAgentProxyId);
        deleteAccountMessages(accountWithChilddata.AccountMessage__r); //deleting scheduled account messages from loosing agent
        UTIL_CampaignMemberDAO.deleteCampaignMembers(accountWithChilddata.PersonCampaignMembers); //deleting CampaignMembers that belong to the campaign owned by loosing agent
        deleteHouseholdGroupMember(accountWithChilddata.Customer_Groupings__r);
        deleteAssignedStaff(accountWithChilddata.AssignedStaff__r); //deleting Assigned staff that belong to the losing agent
        UTIL_LeadConversionDetailDAO.deleteLead(accountWithChilddata.Leads__r); //deleting Lead Record that belong to the losing agent
        UTIL_LeadMetricsProcessor.updateLeadMetrics(accountWithChilddata.LeadMetrics__r); //Updating Leadmetric for a particular Account associated with loosing Agent
        HLPR_PlanningConversationLogProcessor.reassignedPlanningConversationLogAgent(systemuserId, accountWithChilddata.Planning_Conversation_Logs__r, agentRoles.get(0).Agent__c);
        updateSimpleConversation(getSimpleConversationListToUpdate(systemuserId, accountWithChilddata.Simple_Conversations__r)); //update simple conversation record that belong to the losing agent
        updateCustomerInitiatedCancellation(prepareCustomerInitiatedCancellationListForUpdate(systemuserId, accountWithChilddata.Customer_Initiated_Cancellations__r)); // Update CIC record for the losing agent
        deleteProductsServicedByMe(accountWithChilddata.ProductsServicedByMe__r); //deleting ProductsServicedByMe for a particular Account associated with loosing Agent
    }

   /**
    *  @description Helper method for updating CICs for the removed book of business
    *  @name prepareCustomerInitiatedCancellationListForUpdate
    *  @param systemUserId
    *  @param losingAgentCustomerInitiatedCancellationList
    *  @return listToBeUpdated
    */
    private List<CustomerInitiatedCancellations__c> prepareCustomerInitiatedCancellationListForUpdate(Id systemUserId, List<CustomerInitiatedCancellations__c> losingAgentCustomerInitiatedCancellationList) {
        List<CustomerInitiatedCancellations__c> listToBeUpdated = new List<CustomerInitiatedCancellations__c>();
        if(losingAgentCustomerInitiatedCancellationList !=null && !losingAgentCustomerInitiatedCancellationList.isEmpty()) {
            for(CustomerInitiatedCancellations__c losingAgentCustomerInitiatedCancellation: losingAgentCustomerInitiatedCancellationList) {
                losingAgentCustomerInitiatedCancellation.ownerId = systemUserId;
                listToBeUpdated.add(losingAgentCustomerInitiatedCancellation);
            }
        }
        return listToBeUpdated;
    }

   /**
    *  @description helper function for getting Planning Conversation Log List to update for removed book of business
    *  @name getPlanningConversationLogListToUpdate
    *  @param systemUserId
    *  @param losingAgentPlanningConversationLogList
    *  @return planningConversationLogListToBeUpdated
    */
    private List<PlanningConversationLog__c> getPlanningConversationLogListToUpdate(Id systemUserId, List<PlanningConversationLog__c> losingAgentPlanningConversationLogList) {
        List<PlanningConversationLog__c> planningConversationLogListToBeUpdated = new List<PlanningConversationLog__c>();
        if(losingAgentPlanningConversationLogList !=null && !losingAgentPlanningConversationLogList.isEmpty()) {
            for(PlanningConversationLog__c losingAgentPlanningConversationLog: losingAgentPlanningConversationLogList) {
                losingAgentPlanningConversationLog.ownerId = systemUserId;
                planningConversationLogListToBeUpdated.add(losingAgentPlanningConversationLog);
            }
        }
        return planningConversationLogListToBeUpdated;
    }

   /**
    *  @description helper function for getting Simple Conversation List to update for removed book of business
    *  @name getSimpleConversationListToUpdate
    *  @param systemUserId
    *  @param losingAgentSimpleConversationList
    *  @return simpleConversationLogListToBeUpdated
    */
    private List<SimpleConversation__c> getSimpleConversationListToUpdate(Id systemUserId, List<SimpleConversation__c> losingAgentSimpleConversationList) {
        List<SimpleConversation__c> simpleConversationLogListToBeUpdated = new List<SimpleConversation__c>();
        if(losingAgentSimpleConversationList !=null && !losingAgentSimpleConversationList.isEmpty()) {
            for(SimpleConversation__c losingAgentSimpleConversation: losingAgentSimpleConversationList) {
                losingAgentSimpleConversation.ownerId = systemUserId;
                simpleConversationLogListToBeUpdated.add(losingAgentSimpleConversation);
            }
        }
        return simpleConversationLogListToBeUpdated;
    }

   /**
    *  @description helper function to close cases of customers from book of bussienss
    *  @name  updateCases
    *  @param accId
    *  @param systemuserId
    *  @param loosingAgentProxyId
    */
    private void updateCases(Id accId, Id systemuserId, Id loosingAgentProxyId) {

        //given an account
        // - select all of the related cases
        // - select related tasks, but only those assigned to the agent
        List<Case> casesWithTasksToMove = [Select Status, IsClosed, Id, AccountId, OwnerId,
                                           (Select Status, AccountId, AssignedTo__c,OwnerId From Tasks where OwnerId=:loosingAgentProxyId AND isRecurrence=false)
                                           From Case where AccountId=:accId ];

        List<Task> taskList = new List<Task>();
        List<Case> caseListToMove = new List<Case>();

        if (!casesWithTasksToMove.isEmpty()){
            for (Case caseRec:casesWithTasksToMove){

                //collect tasks are owned by the agent
                taskList.addAll(caseRec.Tasks);

                //alter cases owned by the agent
                if (caseRec.OwnerId == loosingAgentProxyId) {
                    caseRec.status = UTIL_StageOrchestrationConstants.CASE_CLOSE_STATUS;
                    caseRec.OwnerId = systemuserId;
                    caseRec.AssignmentReason__c = 'removeFromBookProcessor - account removed from BoB';

                    caseListToMove.add(caseRec);
                }
            }

            //closing all the tasks which are owned by loosingAgentOffice
            updateandDisaasociateTask(taskList, systemuserId);

            //impacted cases have been reassigned, removed from the account, and closed
            UTIL_CaseDAO.updateCases(caseListToMove);
        }
    }

    private void closeOpportunitiesAndAssociatedTasks(Account acctRecord, Id systemuserId, Id loosingAgentProxyId){
        List<opportunity> oppWithTasksList = [Select StageName,Closed_Reason__c,Description,Assigned_To__c,OwnerId,
                                              (SELECT Id, WhoId, WhatId, Status, IsClosed, AccountId,OwnerId,AssignedTo__c
                                               FROM Tasks where OwnerId=:loosingAgentProxyId AND isRecurrence=false)
                                              FROM opportunity where AccountId=:acctRecord.Id AND OwnerId =:loosingAgentProxyId];

        List<SignedWrittenConsent__c> swcList = new List<SignedWrittenConsent__c>();
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        List<Task> taskListToUpdate = new List<Task>();
        Set<Id> opptyIdSet = new Set<Id>();
        swcList.addAll(acctRecord.SignedWrittenConsent__r);

         if(!oppWithTasksList.isEmpty()){
             for(opportunity opp:oppWithTasksList){
                 opptyIdSet.add(opp.Id);
                 UTIL_AccountProcessorsSwcHandler.updateOpportunitySwc(opp);
                 taskListToUpdate.addAll(closeRelatedTasks(opp.Tasks,systemuserId));
                 oppListToUpdate.add(closeOpportunitiesAndUpdateOwnerToSystemUser(opp, opp.OwnerId, systemuserId ));
             }
        }
        UTIL_TaskDAO.updateTasks(taskListToUpdate);
        UTIL_OpportunityDAO.updateOpportunityForAccount(oppListToUpdate);
        UTIL_AccountProcessorsSwcHandler.updateSwcRecordsToNotApplicable(swcList,opptyIdSet);
    }

    private static List<Task> closeRelatedTasks(List<Task> taskList,Id userId){

        List<Task> taskListToUpdate = new List<Task>();
        if(taskList !=null){
            for(Task taskToUpdate : taskList){
                if(!taskToUpdate.IsClosed){
                    taskToUpdate.Status = UTIL_StageOrchestrationConstants.OPPORTUNITY_TASK_CLOSED_REASON ;
                    taskToUpdate.AssignedTo__c=userId;
                }
                taskToUpdate.OwnerId = userId;
                taskListToUpdate.add(taskToUpdate);
            }
        }
        return taskListToUpdate;
    }

    private void updateAllTasks(Account accountWithChilddata,Id systemuserId, Id loosingAgentProxyId){
        List<Task> taskList = accountWithChilddata.tasks;
        List<Id> taskWhatIds = new List<Id>{null, accountWithChilddata.Id};
        List<Id> taskIdsList = new List<Id>();
        for (Task singleTask:taskList){
            taskIdsList.add(singleTask.Id);
        }
        List<Account> accountsWithPersonTasks = [SELECT Id, (select Id, status,OwnerId,AssignedTo__c,whatId from Persontasks where whatId In : taskWhatIds and OwnerId =: loosingAgentProxyId and isRecurrence=false)  from account where Id =: accountWithChilddata.Id];
        List<Task> listOfPersonTasks = accountsWithPersonTasks.get(0).persontasks;
        Set<Task> taskSet = new Set<Task>(taskList);
        taskSet.addAll(listOfPersonTasks);
        List<Task> taskslist = new List<Task>(taskSet);
        updateandDisaasociateTask(taskslist,systemuserId);

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
}