/**
* Author : Golden Spikes Team
* Date Created : 07/19/2018
* @description : Common class to access various SimpleConversation related operations for various Processor.
*/

public without sharing class UTIL_SimpleConversationDAO {

    /**
    * @description updateSimpleConversation: update Simple Conversation
    * @param simpleConversationList of Simple Conversation
    */
    public static void updateSimpleConversation(List<SimpleConversation__c> simpleConversationList) {
        if(simpleConversationList != null && !simpleConversationList.isEmpty()) {
            update simpleConversationList;
        }
    }

    /**
    * @description deleteSimpleConversation: delete Simple Conversation
    * @param simpleConversationList of Simple Conversation
    */
    public static void deleteSimpleConversation(List<SimpleConversation__c> simpleConversationList) {
        if(simpleConversationList != null && !simpleConversationList.isEmpty()) {
            delete simpleConversationList;
        }
    }
}