/**
@Author Team Dream Builders
@Name UTIL_FeedItemDAO
@CreateDate 12/8/2016
@description Common class to access various Task related operations for various Processor.
@Version 1.0
*/
public without sharing class UTIL_TaskRelationDAO {

     /**
    * @description Takes the List of TaskRelations and inserts them
    * @name insertTaskRelations
    * @param taskRelationList list of TaskRelations for inserting
    */
    public static void insertTaskRelations(List<TaskRelation> taskRelationList) {
        if(taskRelationList != null && !taskRelationList.isEmpty()) {
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE,taskRelationList);
            insert securityDecision.getRecords();
        }
    }

}