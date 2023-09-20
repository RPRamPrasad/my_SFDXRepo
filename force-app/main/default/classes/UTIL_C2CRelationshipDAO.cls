/**
* @Author Team Loco-Motivated
* @Name UTIL_C2CRelationshipDAO
* @CreateDate 4/05/2016
* @description Common class to access various Relatioship Object related operations for various Processor.
* @Version 1.0
*/
public without sharing class UTIL_C2CRelationshipDAO {
    
    private static final String CLASS_NAME = 'UTIL_RelationshipDAO';
    private static final String DELETE_RELATIONSHIP_METHOD_NAME = 'deleteCustomerRelationships';
    private static final String INSERT_C2C_RELATIONSHIPS_FAIL_SAFE='insertC2CRelationshipsFailSafe';
	
    /**
    * Method Name: insertRelationship
    * @description Insert Relationship
    * @param relationship
    */
    public static void insertRelationship(Relationship__c relationship) {
        if(relationship != null) {
            insert relationship; 
        }
    }
    
    /**
    * Method Name: insertRelationship
    * @description Insert C2C Relationships
    * @param relationshipListToInsert
    */
    public static void insertC2CRelationships(List<Relationship__c> relationshipListToInsert) {
        if(relationshipListToInsert != null && !relationshipListToInsert.isEmpty()) {
            insert relationshipListToInsert; 
        }
    }
    
       /**
    * Method Name: insertC2CRelationshipsFailSafe
    * @description Insert C2C Relationships Fail Safe
    * @param relationshipListToInsert
    */
    public static void insertC2CRelationshipsFailSafe(List<Relationship__c> relationshipListToInsert) {
        if(relationshipListToInsert != null && !relationshipListToInsert.isEmpty()) {
            List<Database.SaveResult> saveResults = Database.insert(relationshipListToInsert, false);
            LoggingService.logDatabaseResult(saveResults, relationshipListToInsert, CLASS_NAME, INSERT_C2C_RELATIONSHIPS_FAIL_SAFE, System.LoggingLevel.WARN); 
        }
    }
	
    /**
    * Method Name: updateRelationship
    * @description Update Relationship
    * @param relationship
    */
    public static void updateRelationship(Relationship__c relationship) {
        if(relationship != null) {
            update relationship;          
        }
    }
    
     /**
    * Method Name: insertRelationship
    * @description Upsert C2C Relationships
    * @param relationshipListToUpsert
    */
    public static void upsertC2CRelationships(List<Relationship__c> relationshipListToUpsert) {
        if(relationshipListToUpsert != null && !relationshipListToUpsert.isEmpty()) {
            upsert relationshipListToUpsert RelationshipIdentifier__c; 
        }
    }
    
    /**
    * Takes the list of Relationship and delete list of Relationship__c associated with Account in SFDC
    * @Name : deleteCustomerRelationships
    * @description Delete Customer Relationships
    * @param deletedClientRelationshiplst
    */    
    public static void deleteCustomerRelationships(List<Relationship__c> deletedClientRelationshiplst){        
        if(deletedClientRelationshiplst != null && !deletedClientRelationshiplst.isEmpty()) {
            List<Database.DeleteResult> deleteResultList = Database.delete(deletedClientRelationshiplst, false);
            String alreadyDeletedIds=UTIL_Constants.NO_SPACE;
            for (Database.DeleteResult delreslt : deleteResultList) {
                if(!delreslt.isSuccess()){
                    alreadyDeletedIds=alreadyDeletedIds+validateFailures(delreslt); 
                }
            }             
            if(String.isNotBlank(alreadyDeletedIds)){
                alreadyDeletedIds = alreadyDeletedIds.removeEnd(UTIL_StageOrchestrationConstants.COMMA); 
                LoggingService.logHandledException(new EntityDeletedException(UTIL_StageOrchestrationConstants.DELETED_WARNING_MSG+UTIL_Constants.COLON_SYMBOL+
                                                                              UTIL_Constants.SPACE_SYMBOL+alreadyDeletedIds),CLASS_NAME, DELETE_RELATIONSHIP_METHOD_NAME,
                                                   							  LoggingLevel.WARN);
            }
        }        
    }
    
    /**
    * Takes the deleted result of Relationship 
    * @Name : validateFailures
    * @description Validate Failures
    * @param delreslt
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
    
  /**
    * @method getC2CRelationshipRecord: Gets the Relationship__C record for a given relationship Id
    * @description Get C2C Relationship Record
    * @param relId
    * @return Relationship__C
    */  
    public static Relationship__C getC2CRelationshipRecord(id relId){
        Relationship__C relationshipRecord=[select Id, accountOne__r.name,accountOne__r.recordtype.name,accountTwo__r.name,accountTwo__r.recordtype.name,
                                            accountTwo__r.ClientIdentifier__c,accountOne__r.ClientIdentifier__c, RelationshipType__c 
                                            From Relationship__C Where Id=:relId LIMIT 1];
        return relationshipRecord;
    }
  
  /**
    * @method getAccountIdStringToLogForGiveClientIds
    * @description Get Account Id String To Log For Give ClientIds
    * @param listofClientIds
    * @return string
    */ 
    public static string getAccountIdStringToLogForGiveClientIds(List<String> listofClientIds){
        List<Account> accList = [Select Id From Account Where ClientIdentifier__c IN :listofClientIds];
        string accountIdString=VFC_C2CRelationshipController.BLANK_SPACE;
        for(account acc:accList){
            accountIdString+=acc.id+VFC_C2CRelationshipController.BLANK_SPACE;
        }
        return accountIdString;
    }
}