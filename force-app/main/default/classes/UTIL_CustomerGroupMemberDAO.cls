/**
* @Author Team Loco-Motivated
* @Name UTIL_CustomerGroupMemberDAO
* @CreateDate 12/21/2017
* @description Common class to access various Group Object related operations for various Processor.
* @Version 1.0
*/
public without sharing class UTIL_CustomerGroupMemberDAO {
   
    private static final String DELETE_HOUSEHOLDGROUPMEMBER_METHOD_NAME = 'deleteHouseholdCustomerGroupMemberList';
    private static final String CLASS_NAME = 'UTIL_CustomerGroupMemberDAO';
  
  /**
    * Method Name: upsert Group Member
    * @description Upsert Group Member List
    * @param groupMemberListToUpsert
    */
    public static void upsertCustomerGroupMemberList(List<CustomerGroupMember__c> groupMemberListToUpsert) {
        if(groupMemberListToUpsert != null && !groupMemberListToUpsert.isEmpty()) {
            upsert groupMemberListToUpsert GroupMemberId__c; 
        }
    }

    /**
     * @description Upserted Group Member Result
     * @param groupMemberListToUpsert
     * @return List<Database.UpsertResult>
     */
    public static List<Database.UpsertResult> upsertedGroupMemberResult(List<CustomerGroupMember__c> groupMemberListToUpsert){
        List<Database.UpsertResult> groupMemberUpsertedResult = Database.upsert(groupMemberListToUpsert, CustomerGroupMember__c.GroupMemberId__c, false);
        return groupMemberUpsertedResult;
    }
    
    /**
    * Takes the list of Relationship and delete list of CustomerGroupMember__c associated with Account in and Associated with particular Agent in SFDC
    * @Name : deleteHouseholdGroupMemberList    
    * @description Delete Household Group Member List
    * @param groupMemberListToDelete
    */    
    public static void deleteHouseholdCustomerGroupMemberList(List<CustomerGroupMember__c> groupMemberListToDelete){        
        if(groupMemberListToDelete != null && !groupMemberListToDelete.isEmpty()) {
            List<Database.DeleteResult> deleteResultList = Database.delete(groupMemberListToDelete, false);
            String alreadyDeletedIds=UTIL_Constants.NO_SPACE;
            for (Database.DeleteResult delreslt : deleteResultList) {
                if(!delreslt.isSuccess()){
                    alreadyDeletedIds=alreadyDeletedIds+validateFailures(delreslt); 
                }
            }             
            if(String.isNotBlank(alreadyDeletedIds)){
                alreadyDeletedIds = alreadyDeletedIds.removeEnd(UTIL_StageOrchestrationConstants.COMMA); 
                LoggingService.logHandledException(new EntityDeletedException(UTIL_StageOrchestrationConstants.DELETED_WARNING_MSG+UTIL_Constants.COLON_SYMBOL+
                                                                              UTIL_Constants.SPACE_SYMBOL+alreadyDeletedIds),CLASS_NAME, DELETE_HOUSEHOLDGROUPMEMBER_METHOD_NAME,
                                                   							  LoggingLevel.WARN);
            }
        }        
    }
    
    /**
    * Takes the deleted result of GroupMember
    * @Name : validateFailures
    * @description Validate Failures
    * @param  delreslt
    * @return : String
    */
    private static String validateFailures(Database.DeleteResult delreslt){
        Database.Error[] errors=delreslt.getErrors();
        for(Database.Error error:errors){
            if(!StatusCode.ENTITY_IS_DELETED.equals(error.getStatusCode())){
                throw new DmlException(error.getMessage());
            }
        } 
        return delreslt.getId()+UTIL_StageOrchestrationConstants.COMMA;
    }
}