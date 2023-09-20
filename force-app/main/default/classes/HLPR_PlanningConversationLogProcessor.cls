/**
* Author : Octonauts
* Date Created : 12/01/2021
* @description : This class is used has a Helper for Simple Conversation Agent Reassignment.
Copyright © StateFarm
*/

public with sharing class HLPR_PlanningConversationLogProcessor {

    /**
* @description helper function for getting Planning Conversation Log List to update for removed book of business
* @name getPlanningConversationLogListToUpdate
* @param newAgentProxyId systemUserId from Account Owner Custom Settings
* @param losingAgentPlanningConversationLogList - List of Planning Conversation Log related to the losing Agent
* @param newAgentId
*/


    public static void reassignedPlanningConversationLogAgent(Id newAgentProxyId, List<PlanningConversationLog__c> losingAgentPlanningConversationLogList, String newAgentId) {
        List<PlanningConversationLog__c> planningConversationLogListToBeUpdated = new List<PlanningConversationLog__c>();

        if(losingAgentPlanningConversationLogList !=null && !losingAgentPlanningConversationLogList.isEmpty()) {
            for(PlanningConversationLog__c losingAgentPlanningConversationLog: losingAgentPlanningConversationLogList) {
                losingAgentPlanningConversationLog.ownerId = newAgentProxyId;
                losingAgentPlanningConversationLog.Agent__c = newAgentId;
                planningConversationLogListToBeUpdated.add(losingAgentPlanningConversationLog);
            }
        }
        Update Security.stripInaccessible(AccessType.UPDATABLE, planningConversationLogListToBeUpdated, true).getRecords();
    }
}