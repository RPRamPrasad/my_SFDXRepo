/**
  * @name SFCustomRecommendationTriggerHandler
  * @author Team Skynet
  * @createdDate 03/03/2022
  * @description  This class will handle Trigger logic for SFCustomRecommendation Object
*/
public with sharing class SFCustomRecommendationTriggerHandler {

    /**
     * @description - Before Insert Trigger logic. Updates record owner to proxy and adds recoomedation reference.
     * @param sfCustomRecommendationList
     */
    public static void handleBeforeInsert(List<SFCustomRecommendation__c> sfCustomRecommendationList){
        SObjectOwnershipUtility.setObjectOwnerToProxy(sfCustomRecommendationList, false);
        addRecommendationReference(sfCustomRecommendationList);
    }
    
    private static void addRecommendationReference(List<SFCustomRecommendation__c> sfCustomRecommendationList){

		List<String> actionIds = new List<String>();
        for(SFCustomRecommendation__c record : sfCustomRecommendationList) { 
            actionIds.add(record.Action_ID__c);
        }
        
        LIst<Recommendation> recommendations = 
            			Security.stripInaccessible(AccessType.READABLE,
                                                   [Select Id, Action_ID__c from Recommendation where Action_ID__c in :actionIds]).getRecords();
        
        Map<String,Id> actionIdMap = new Map<String, Id>();
        for(Recommendation rec: recommendations){
            actionIdMap.put(rec.Action_ID__c, rec.Id);
        }
        
        for(SFCustomRecommendation__c record : sfCustomRecommendationList) { 
            record.Recommendation__c = actionIdMap.get(record.Action_ID__c);
        }
        
    }
}