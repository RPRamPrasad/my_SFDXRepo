/**
* Author : Golden Spikes Team
* Date Created : 05/03/2018
* Date Updated: 08/06/2018
* @description   Updates PlanningConversationLog Owner field from Simple Conversation Owner.
                Updates PlanningConversationLog Agent field from Simple Conversation Agent.
                Updates PlanningConversationLog Account field from Simple Conversation Account.
                Prevent the PlanningConversationLog being deleted.
*/

public with sharing class AP_PlanningConversationLogTrigger {

    /**
     * @description entry point method to process the planning conversation log before insert records.
     * @param planningConversationLogList
     */
    public void processPlanningConversationLogOnAfterInsert(List<PlanningConversationLog__c> planningConversationLogList) {
        try {
            updatePlanningConvOnAfterInsert(planningConversationLogList);
        } catch(Exception planningConvLogException) {
            UTIL_AgentProxySelection.tagAllErrors(planningConversationLogList, planningConvLogException.getMessage());
        }
    }

    /**
     * @description entry point method to process the planning conversation log before update records.
     * @param planningConversationLogList
     * @param oldPlanningConversationMap
     */
    public void processPlanningConversationLogOnBeforeUpdate(List<PlanningConversationLog__c> planningConversationLogList, Map<Id, PlanningConversationLog__c> oldPlanningConversationMap) {
        try {
            updatePlanningConvOnBeforeUpdate(planningConversationLogList, oldPlanningConversationMap);
        } catch(Exception planningConvLogException) {
            UTIL_AgentProxySelection.tagAllErrors(planningConversationLogList, planningConvLogException.getMessage());
        }
    }

    /**
     * @description method to update the planning conversation log record owner, agent and account field values on After Insert Trigger.
     * @param planningConversationLogList
     */
    public void updatePlanningConvOnAfterInsert(List<PlanningConversationLog__c> planningConversationLogList) {
        List<PlanningConversationLog__c> planningConversationToBeUpdated = new List<PlanningConversationLog__c>();
        List<String> simpleConversationIdSet = new List<String>();
        Map<Id, Id> simpleAccountIdMap = new Map<Id, Id>();
        Map<Id, Id> simpleAgentIdMap = new Map<Id, Id>();
        Map<Id, Id> simpleOwnerIdMap = new Map<Id, Id>();

        for(PlanningConversationLog__c planningConvLog: planningConversationLogList) {
            simpleConversationIdSet.add(planningConvLog.SimpleConversation__c);
        }

        if(!simpleConversationIdSet.isEmpty()) {
            if (Schema.sObjectType.SimpleConversation__c.isAccessible()) {
                for(SimpleConversation__c simple: [Select Id, Account__c, Agent__c, OwnerId from SimpleConversation__c
                                               Where id in: simpleConversationIdSet]) {
                    simpleAccountIdMap.put(simple.Id, simple.Account__c);
                    simpleAgentIdMap.put(simple.Id, simple.Agent__c);
                    simpleOwnerIdMap.put(simple.Id, simple.OwnerId);
                }
            }

            for(PlanningConversationLog__c planningConvLog: planningConversationLogList) {
                planningConversationToBeUpdated.add(new PlanningConversationLog__c(Id = planningConvLog.Id,
                            Account__c = simpleAccountIdMap.get(planningConvLog.SimpleConversation__c),
                            Agent__c = simpleAgentIdMap.get(planningConvLog.SimpleConversation__c),
                            OwnerId = simpleOwnerIdMap.get(planningConvLog.SimpleConversation__c)
                            ));
            }

            if(!planningConversationToBeUpdated.isEmpty()) {
                update planningConversationToBeUpdated;
            }
        }
    }

    /**
     * @description method to update the planning conversation log record owner, agent and account field values on Before Update Trigger.
     * @param planningConversationLogList
     * @param oldPlanningConversationMap
     */
    public void updatePlanningConvOnBeforeUpdate(List<PlanningConversationLog__c> planningConversationLogList,  Map<Id, PlanningConversationLog__c> oldPlanningConversationMap) {
        List<String> simpleConversationIdSet = new List<String>();
        List<PlanningConversationLog__c> updatePlanningConversationLogList = new List<PlanningConversationLog__c>();
        Map<Id, Id> simpleAccountIdMap = new Map<Id, Id>();
        Map<Id, Id> simpleAgentIdMap = new Map<Id, Id>();
        Map<Id, Id> simpleOwnerIdMap = new Map<Id, Id>();

        for(PlanningConversationLog__c planningConvLog: planningConversationLogList) {
            PlanningConversationLog__c oldPlanningConversationLog = oldPlanningConversationMap.get(planningConvLog.Id);
            if(String.isNotBlank(planningConvLog.SimpleConversation__c) && !planningConvLog.SimpleConversation__c.equals(oldPlanningConversationLog.SimpleConversation__c)) {
               simpleConversationIdSet.add(planningConvLog.SimpleConversation__c);
               updatePlanningConversationLogList.add(planningConvLog);
            }
        }

        if(!simpleConversationIdSet.isEmpty()) {
            for(SimpleConversation__c simple: [Select Id, Account__c, Agent__c, OwnerId from SimpleConversation__c
                                               Where id in: simpleConversationIdSet]) {
                simpleAccountIdMap.put(simple.Id, simple.Account__c);
                simpleAgentIdMap.put(simple.Id, simple.Agent__c);
                simpleOwnerIdMap.put(simple.Id, simple.OwnerId);
            }
            for(PlanningConversationLog__c planningConvLog: updatePlanningConversationLogList) {
                planningConvLog.Account__c = simpleAccountIdMap.get(planningConvLog.SimpleConversation__c);
                planningConvLog.Agent__c = simpleAgentIdMap.get(planningConvLog.SimpleConversation__c);
                planningConvLog.OwnerId = simpleOwnerIdMap.get(planningConvLog.SimpleConversation__c);
            }
        }
    }

    /**
     * @description method to prevent user from deleting PlanningConversationLog records
     * @param planningConversationLogList
     */
    public void preventPlanningConversationLogDelete(List<PlanningConversationLog__c> planningConversationLogList) {
        for(PlanningConversationLog__c deletePlanningConversationLog : planningConversationLogList) {
            deletePlanningConversationLog.addError(Label.CL_PlanningConversationLogPreventDeleteMsg);
        }
    }
}