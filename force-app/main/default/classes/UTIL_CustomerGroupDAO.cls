/**
* @Author Team Loco-Motivated
* @Name UTIL_CustomerGroupDAO
* @CreateDate 12/21/2017
* @description Common class to access various Group Object related operations for various Processor.
* @Version 1.0
*/
public without sharing class UTIL_CustomerGroupDAO {
   
  /**
    * Method Name: insertRelationship
    * @description Upsert Customer Group List
    * @param groupListToUpsert
    */
    public static void upsertCustomerGroupList(List<CustomerGroup__c> groupListToUpsert) {
        if(groupListToUpsert != null && !groupListToUpsert.isEmpty()) {
            upsert groupListToUpsert SFGroupIdentifier__c; 
        }
    }

    /**
     * @description Upserted Group Result
     * @param groupListToUpsert
     * @return List<Database.UpsertResult>
     */
    public static List<Database.UpsertResult> upsertedGroupResult(List<CustomerGroup__c> groupListToUpsert){
        List<Database.UpsertResult> groupUpsertedResult = Database.upsert(groupListToUpsert, CustomerGroup__c.SFGroupIdentifier__c, false);
        return groupUpsertedResult;
    }
}