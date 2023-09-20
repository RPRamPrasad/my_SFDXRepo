/**
  * @name Batch_SFRecommendationExpiration
  * @author Team Skynet
  * @createdDate 1/21/2022
  * @description Batch class to set the status from New => Expired SFCustomRecommendations that are
  *              unmodified for a certain number of days as the Recommendation is considered stale
  */
  public with sharing class Batch_SFRecommendationExpiration implements Schedulable, Database.Batchable<SObject> {
    private static final String CLASS_NAME = 'Batch_SFRecommendationExpiration';
    private static final String START_METHOD_NAME = 'start';
    private static final String UPDATE_RECOMMENDATIONS_METHOD_NAME = 'updateSFCustomRecommendations';

    private static final String STATUS_NEW = 'New';
    private static final String STATUS_EXPIRED = 'Expired';
    private static final String CS_NBA_CONFIG_EXPIRE_DAYS = 'DaysUntilExpired'; // TO-DO: Include this in the CSVDataLoad
    private static Integer daysOlderThan = 30;

    private static final CS_NBA_Config__c EXPIRATION_DAYS = CS_NBA_Config__c.getValues(CS_NBA_CONFIG_EXPIRE_DAYS);

    /**
     * @description This method executes the batchable records
     * @method execute: execute method for the batch
     * @param sc Schedulable context set by platform
     */
    public void execute(SchedulableContext sc) {
          Batch_SFRecommendationExpiration sfRecommendationExpiration = new Batch_SFRecommendationExpiration();
          Database.executeBatch(sfRecommendationExpiration, 2000);
     }

    /**
    * @description This method identifies expirable SFCustomRecommendations records
    * @param bc Batchable context set by platform
    * @return SFCustomRecommendations list
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        String queryString = '';
        try {

            if(EXPIRATION_DAYS != null) {
                daysOlderThan = Integer.valueOf(EXPIRATION_DAYS.Value__c);
            }
            // Fetch all the New SFCustomRecommendations modified equal to or more than :daysOlderThan 90 days ago
            DateTime daysOld = System.Now().addDays(-daysOlderThan);
            queryString = 'SELECT Id ' +
                'FROM SFCustomRecommendation__c ' +
                'WHERE Status__c = :STATUS_NEW ' +
                'AND (' +
                '(CreatedDate <= :daysOld)'+
                ') WITH SECURITY_ENFORCED ' +
                'ORDER BY CreatedDate DESC ' +
                'LIMIT 200000';

        } catch(Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME , START_METHOD_NAME, System.LoggingLevel.ERROR);
        }

        return Database.getQueryLocator(queryString);

    }

    /**
    * @description This method executes the batch
    * @param bc Batchable context set by platform
    * @param recommendationsToExpire scope: Objects in scope for this batch execution
    */
    public void execute(Database.BatchableContext bc, List<SFCustomRecommendation__c> recommendationsToExpire){
        if(!recommendationsToExpire.isEmpty()){
            updateSFCustomRecommendations(recommendationsToExpire);
        }
    }

    private void updateSFCustomRecommendations(List<SFCustomRecommendation__c> recommendationsToExpire) {
        try {
            for (SFCustomRecommendation__c recommendationToExpire : recommendationsToExpire) {
                recommendationToExpire.Status__c = STATUS_EXPIRED;
            }

                List<Database.SaveResult> recommendationsSaveResults = Database.update(security.stripInaccessible(AccessType.UPDATABLE, recommendationsToExpire, true).getRecords(), false);
                handleSaveResults(recommendationsSaveResults);
        } catch (Exception ex) {
            // No action
            LoggingService.logHandledException(ex, CLASS_NAME , UPDATE_RECOMMENDATIONS_METHOD_NAME, System.LoggingLevel.ERROR);
        }

    }

    private void handleSaveResults(List<Database.SaveResult> saveResults) {
        DML_ALLOrNothingException ex = new DML_ALLOrNothingException(saveResults);
        if (String.isNotBlank(ex.getMessage())) {
            throw ex;
        }
    }

    /**
    * @description This method is required by the Schedulable interface but does nothing here
    * @param bc Batchable context set by platform
    */
    public void finish(Database.BatchableContext bc){
        // this is enforced method. But need to do nothing.
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info(CLASS_NAME, 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
}
