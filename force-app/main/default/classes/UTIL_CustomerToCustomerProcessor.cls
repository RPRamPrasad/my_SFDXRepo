/**
@Author: Team Loco Motivated
@name: UTIL_CustomerToCustomerProcessor
@Description: This class is responsible for maintaining the sync between MPD database and SFDC. It takes the JSON input
and accordingly inserts/updates/deletes the Relationships of a Account
*/
/**
 * @description This class is responsible for maintaining the sync between MPD database and SFDC
 */
public without sharing class UTIL_CustomerToCustomerProcessor extends UTIL_StageOrchestrationProcessor {

    /**
    * @description It takes StageOrchestration__c object and synchronizes the customer information and relationship information
    * @param stageOrchestrationList
    * @throws StageProcessorException
    */
    public override void execute(List<StageOrchestration__c> stageOrchestrationList) {
        StageOrchestration__c stageOrchestration = stageOrchestrationList.get(0);

        Savepoint savePoint = Database.setSavepoint();
        try{
            final AP_StageOrchestrationJSONParser jsonObject = parseJSON(stageOrchestration.Value__c);
            String externalKeyIdnetifier = jsonObject.OrchestrationInfo.OrchestrationDataName.get(0).OrchestrationNameDetail.dataExternalKeyValue;
            List<Relationship__c> sfdcRelatshplist = [SELECT id,ExternalSourceSyncTime__c FROM Relationship__c
                                                  	  WHERE RelationshipIdentifier__c=:externalKeyIdnetifier];

            if(!jsonObject.OrchestrationInfo.OrchestrationDataName.get(0).OrchestrationNameDetail.dataDeleteIndicator){
                List<Relationship__c> relationshipLst=jsontoC2CConverter(jsonObject);
                handleRelationshipToInsertorUpdate(relationshipLst.get(0),sfdcRelatshplist);
            }else{
                handleRelationshipToDelete(sfdcRelatshplist);
            }
        }catch(Exception ex){
            Database.rollback(savePoint);
            throw new StageProcessorException(ex.getMessage(), ex);
        }
    }

    /**
    * @description This method handles the the account data updates or inserts based on availability and the latest and greatest
    * @param relatnObject
    * @param sfdcRelatshplist
    */
    private void handleRelationshipToInsertorUpdate(final Relationship__c relatnObject,final List<Relationship__c> sfdcRelatshplist) {

        //validating to Insert or Update realtionships
        if(sfdcRelatshplist.isEmpty()){
            insertRelationship(relatnObject);
        }else if(sfdcRelatshplist.get(0).ExternalSourceSyncTime__c<relatnObject.ExternalSourceSyncTime__c || String.isBlank(String.valueOf(sfdcRelatshplist.get(0).ExternalSourceSyncTime__c))){
            relatnObject.id=sfdcRelatshplist.get(0).id;
            updateRelationship(relatnObject);
        }
    }

    /**
    * @description This method handles the the Agent Role data updates or inserts based on availability
    * @param sfdcRelatshplistToDelete
    */
    private void handleRelationshipToDelete(List<Relationship__c> sfdcRelatshplistToDelete) {
        //deleting all the Existing Relationships
        deleteRelationship(sfdcRelatshplistToDelete);
    }
}