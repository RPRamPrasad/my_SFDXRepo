/**
* @author Team Loco Motivated
* @name HLPR_C2CRelationshipAggregatorResponse 
* This is JSON object for customer aggregator response 
* @description HLPR C2C Relationship Aggregator Response
* @Date : 11/29/2017
**/

public with sharing class HLPR_C2CRelationshipAggregatorResponse {
    
    //Populate C2C Relationship values received from customer aggregator response
    /**
     * @description Get C2C Relationship From Aggregatort Response
     * @param dataListValues
     * @return List<Relationship__c>
     */
    public static List<Relationship__c> getC2CRelationshipFromAggregatortResponse(list<AP_C2CRelationshipAggregatorResponse.C2CRelationshipData> dataListValues) {
        List<Relationship__c> c2cRelationshipList=new List<Relationship__c>();
        if(dataListValues.isEmpty()){
            throw new CustomerAggregatorException('Aggregator Response empty');
        }
        for(AP_C2CRelationshipAggregatorResponse.C2CRelationshipData jsonc2cRelationshipValue : dataListValues){
            Relationship__c c2cRelationship = new Relationship__c();
            c2cRelationship.AccountTwo__r = new account(clientIdentifier__c=jsonc2cRelationshipValue.attributes.clientId);
            c2cRelationship.AccountOne__r = new account(clientIdentifier__c=jsonc2cRelationshipValue.attributes.relatedClientId);
            c2cRelationship.RelationshipIdentifier__c = jsonc2cRelationshipValue.attributes.clientId+'~'+jsonc2cRelationshipValue.attributes.relatedClientId;
            c2cRelationship.ExternalSourceSyncTime__c = System.now();
            c2cRelationship.RelationshipType__c = jsonc2cRelationshipValue.attributes.relationshipNature; 
            c2cRelationshipList.add(c2cRelationship);
        }
        return c2cRelationshipList; 
    }
    
}