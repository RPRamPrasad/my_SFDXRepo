/**
* Author : Octonauts
* Date Created : 12/01/2021
* @description : This class is used has a Helper for Simple Conversation Agent Reassignment.
Copyright © StateFarm
*/

public with sharing class HLPR_SimpleConversationProcessor {

    /**
* @description helper function for getting Simple Conversation List to update for removed book of business
* @name getSimpleConversationListToUpdate
* @param newAgentProxyuser systemUserId from Account Owner Custom Settings
* @param newAgentId
* @param losingAgentSimpleConversationList - List of Simple Conversation related to the losing Agent
*/


    public static void reassignedSimpleConversationAgent(User newAgentProxyuser, String newAgentId, List<SimpleConversation__c> losingAgentSimpleConversationList) {

        List<SimpleConversation__c> simpleConversationLogListToBeUpdated = new List<SimpleConversation__c>();
        List<PlanningConversationLog__c> planningConversationLogListToBeInserted = new List<PlanningConversationLog__c>();

        if(losingAgentSimpleConversationList !=null && !losingAgentSimpleConversationList.isEmpty()) {

            for(SimpleConversation__c losingAgentSimpleConversation: losingAgentSimpleConversationList) {

                PlanningConversationLog__c pcrecord = createPlanningConversationLog(losingAgentSimpleConversation, newAgentProxyuser, newAgentId);
                losingAgentSimpleConversation.ownerId = newAgentProxyuser.Id;
                losingAgentSimpleConversation.Agent__c = newAgentId;
                losingAgentSimpleConversation.Reassigned__c = true; //updating checkbox

                simpleConversationLogListToBeUpdated.add(losingAgentSimpleConversation);
                planningConversationLogListToBeInserted.add(pcrecord);
            }
        }
        Update Security.stripInaccessible(AccessType.UPDATABLE, simpleConversationLogListToBeUpdated, true).getRecords();
        insert Security.stripInaccessible(System.AccessType.CREATABLE, planningConversationLogListToBeInserted, true).getRecords();
    }


    /**
    * @description Method to send an outlook calendar invite.
    * @param recordToUpdate
    * @param newAgentProxy
    * @param newAgentId
    * @return pclrecord
    */

    private static PlanningConversationLog__c createPlanningConversationLog(SimpleConversation__c recordToUpdate, User newAgentProxy, String newAgentId) {

        PlanningConversationLog__c pclrecord = new PlanningConversationLog__c (); //instance of PCL
        pclrecord.Account__c = recordToUpdate.Account__c;
        pclrecord.Comments__c = 'Reassignment Process has initiated and reassigned this Simple Conversation record from ' +  recordToUpdate.OfficeAssigned__c + ' to ' + newAgentProxy.Name;
        pclrecord.Agent__c = newAgentId;
        pclrecord.SimpleConversation__c = recordToUpdate.Id;
        pclrecord.OwnerId = newAgentProxy.Id;

        return pclrecord;
    }
}