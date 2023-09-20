/**
* Author : Golden Spikes Team
* Date Created : 05/07/2018
* @description : Common class to access various PlanningConversationLog related operations for various Processor.
*/

public without sharing class UTIL_PlanningConversationLogDAO {

    /**
    * @description updatePlanningConversationLog: update Planning Conversation Log
    * @param planningConversationLogList of Planning Conversation Log
    */
    public static void updatePlanningConversationLog(List<PlanningConversationLog__c> planningConversationLogList) {
        if(planningConversationLogList != null && !planningConversationLogList.isEmpty()) {
            update planningConversationLogList;
        }
    }

    /**
    * @description deletePlanningConversationLog: delete Planning Conversation Log
    * @param planningConversationLogList of Planning Conversation Log
    */
    public static void deletePlanningConversationLog(List<PlanningConversationLog__c> planningConversationLogList) {
        if(planningConversationLogList != null && !planningConversationLogList.isEmpty()) {
            delete planningConversationLogList;
        }
    }
}