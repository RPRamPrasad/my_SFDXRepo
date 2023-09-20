/**
* Author : Octonauts
* Date Created : 10/14/2020
* @description  Apex class to update Planning Conversation Tool Link Last Accessed By
*/

public with sharing class ConversationController {

    static final String CLASS_NAME = 'ConversationController';
    static final String ROUTE_REQUEST_METHOD_NAME_NEXT = 'updateConversation';


    /**
* @description  Method to update Simple Conversation for last accessed by
* @param recId
*/
    @AuraEnabled
    public static void updateConversation(Id recId){

        if( !string.isBlank(recId)){
            try{
                List<User> loggedInUsr = Security.stripInaccessible(
                    AccessType.READABLE,
                    [Select Id,alias from User where Id =: Userinfo.getUserId()]
                )
                    .getRecords();

                string lastAccessedBy = loggedInUsr[0].alias+ ','+ ' ';
                DateTime lastAccessedTime = System.now();

                list<SimpleConversation__c> simpleConLst = new list<SimpleConversation__c>();

                SimpleConversation__c sv = new SimpleConversation__c(Id = recId, Last_Accessed_By__c = lastAccessedBy, LastAccessedTime__c = lastAccessedTime);
                simpleConLst.add(sv);
                Upsert Security.stripInaccessible(AccessType.UPSERTABLE, simpleConLst, true).getRecords();
            } catch(exception ex){
                LoggingService.logHandledException(ex, CLASS_NAME, ROUTE_REQUEST_METHOD_NAME_NEXT,System.LoggingLevel.ERROR);
            }
        }
    }
}