/**
* @Name UTIL_OrchestrationJSONtoC2CConverter  
* @Author Loco Motivated
* @description This is a utility class that implements Mapping for Customer to Customer fields from JSON
*/
public without sharing class UTIL_OrchestrationJSONtoC2CConverter {
     
    /**
    * @name jsontoCustomerRelationshipConverter
    * @description This method takes JSON to insert or update
    * @param parseJSON
    * @return List<Relationship__c> 
    */
    public static List<Relationship__c> jsontoCustomerRelationshipConverter(AP_StageOrchestrationJSONParser parseJSON){ 
        List<Relationship__c> relationshipList = new List<Relationship__c>();
        for (AP_StageOrchestrationJSONParser.OrchestrationDataName orchestrationDataName : parseJSON.orchestrationInfo.orchestrationDataName) {
            if(UTIL_StageOrchestrationConstants.RELATIONSHIP_TRANSACTION.equalsIgnoreCase(orchestrationDataName.orchestrationNameDetail.dataName)){
                Relationship__c relatnshp = new Relationship__c();
                relatnshp = insertJsonToRelatioshipFields(relatnshp,orchestrationDataName);
                relatnshp.RelationshipIdentifier__c=orchestrationDataName.orchestrationNameDetail.dataExternalKeyValue;
                relatnshp.ExternalSourceSyncTime__c=orchestrationDataName.orchestrationNameDetail.externalSourceSyncTime;
                relationshipList.add(relatnshp);
            }
        }
        return relationshipList;
    }
    
    /**
    * @description This method takes Relationship__c relatnshp and JSON OrchestrationDataName 
    * and inserts the OrchestrationDataName values into the Relationship__c
    * @name insertJsonToAccountFields
    * @param relatnshp
    * @param orchDataName
    * @return Relationship__c
    */     
    private static Relationship__c insertJsonToRelatioshipFields(Relationship__c relatnshp,AP_StageOrchestrationJSONParser.OrchestrationDataName orchDataName){
        AP_StageOrchestrationJSONParser.OrchestrationDataValues dataValues = orchDataName.orchestrationNameDetail.orchestrationDataValues;
        relatnshp.AccountTwo__r         = new account(clientIdentifier__c=dataValues.customer);
        relatnshp.AccountOne__r         = new account(clientIdentifier__c=dataValues.relationWith);
        relatnshp.RelationshipType__c   = dataValues.relationshipNature;  
        if(String.isBlank(dataValues.relationshipNature)){
        	relatnshp.RelationshipType__c   = UTIL_StageOrchestrationConstants.OTHER_JSON;
        }
        return relatnshp;
    }
}