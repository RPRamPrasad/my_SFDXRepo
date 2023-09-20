/**
* @description NBA_RecommendationService will provide services related to SF Custom Recommendation object
*/
public with sharing class NBA_RecommendationService {
    
    private static final String CLASS_NAME = 'NBA_RecommendationService';
    private static final String SAVE_METHOD_NAME = 'saveRecommendations';
    private static final String STATUS_REPLACED = 'Replaced';
    private static final String STATUS_NEW = 'New';
    
    /**
     * @description save recommedations
     * @param newRecommendations 
     */
    public static void saveRecommendations(List<SFCustomRecommendation__c> newRecommendations){
        
        List<SFCustomRecommendation__c> recommendationsToUpsert = new List<SFCustomRecommendation__c>();
        recommendationsToUpsert.addAll(newRecommendations);
        recommendationsToUpsert.addAll(retrieveExistingRecommendations(newRecommendations));

        List<Database.UpsertResult> upsertResults = Database.upsert(Security.stripInaccessible(AccessType.UPSERTABLE, recommendationsToUpsert).getRecords(), false);

        LoggingService.logDatabaseResult(upsertResults, recommendationsToUpsert, CLASS_NAME, SAVE_METHOD_NAME, System.LoggingLevel.ERROR);
        
    }

    private static List<SFCustomRecommendation__c> retrieveExistingRecommendations(List<SFCustomRecommendation__c> newRecommendations){

        Set<Id> accountIds = new Set<Id>(); 
        for(SFCustomRecommendation__c record : newRecommendations) { 
            accountIds.add(record.Account__c); 
        }

        List<SFCustomRecommendation__c> existingRecommendations = 
                        Security.stripInaccessible(AccessType.READABLE, [SELECT Id, Status__c
                                FROM SFCustomRecommendation__c 
                                WHERE Account__c IN: accountIds
                                AND Status__c = :STATUS_NEW ]).getRecords();

        if(!existingRecommendations.isEmpty()){
            replaceRecommendations(existingRecommendations);
        }

        return existingRecommendations;

    }

    private static void replaceRecommendations(List<SFCustomRecommendation__c> existingRecommendations){

        for(SFCustomRecommendation__c record : existingRecommendations) { 
            record.Status__c = STATUS_REPLACED;
        }
    }
}