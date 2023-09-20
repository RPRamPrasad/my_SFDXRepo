/**
  * @name Batch_NBAJoesiFeedbackReprocessor
  * @author Team Skynet
  * @createdDate 05/25/2022
  * @description Reprocesses failed JOESI Feedback callouts for Next Best Action
  */
  public with sharing class Batch_NBAJoesiFeedbackReprocessor implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {
    private static final String CLASS_NAME = 'Batch_NBAJoesiFeedbackReprocessor';
    private static final String START_METHOD_NAME = 'start';
    private static final String REPROCESS_RECOMMENDATIONS_METHOD_NAME = 'reprocessSFCustomRecommendations';
    private static final String UPDATE_RECORDS_METHOD_NAME = 'updateRecords';

    private static final String CS_NBA_CONFIG_BATCH_FEEDBACK_API_MAX_RETRY_COUNTER = 'BatchFeedbackAPIMaxRetryCounter';
    private static final CS_NBA_Config__c FEEDBACK_RETRY_COUNTER = CS_NBA_Config__c.getValues(CS_NBA_CONFIG_BATCH_FEEDBACK_API_MAX_RETRY_COUNTER);
    private static Integer maxRetryCount = 6;
    private static final String CALLOUT_FAILED = 'Failed';
    private static final String CALLOUT_SUCCESSFUL = 'Successful';

    /**
     * @method execute
     * @description Loop through SF Custom Recommendation objects and runs the reInvocateJoesiCallout method to handle reprocessing
     * @param sc a SchedulableContext object
     */
    public void execute(SchedulableContext sc) {

        Batch_NBAJoesiFeedbackReprocessor sfRecommendationReprocess = new Batch_NBAJoesiFeedbackReprocessor();
        Database.executeBatch(sfRecommendationReprocess, 100);
    }

    /**
     * @method start
     * @description This method identifies SFCustomRecommendations records to reprocess
     * @param bc Batchable context set by platform
     * @return <SFCustomRecommendations>
     * @throws exception - <Method is not throwing any exception>
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Loops through each recommendation object
        String queryString = '';

        if(FEEDBACK_RETRY_COUNTER != null) {
            maxRetryCount = Integer.valueOf(FEEDBACK_RETRY_COUNTER.Value__c);
        }
        try {
            // Fetch all the SFCustomRecommendations with FeedbackAPICalloutSuccess that are set to false and rety counter less than 6
            queryString = 'SELECT Id, EIID__c, Account__r.ClientIdentifier__c, External_Interaction_ID__c, ' +
                        'Rank__c, Direction__c, Channel__c, Treatment__c, Action_ID__c, Recommendation__r.Group__c, ' +
                        'Recommendation__r.Issue__c, Recommendation__r.Name, FeedbackAPICalloutSuccess__c, FeedbackAPIRetryCounter__c, Status__c ' +
                        'FROM SFCustomRecommendation__c ' +
                        'WHERE FeedbackAPICalloutSuccess__c = :CALLOUT_FAILED ' +
                        'AND FeedbackAPIRetryCounter__c < ' + maxRetryCount + ' WITH SECURITY_ENFORCED ' +
                        'LIMIT 200000';
        } catch(Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME , START_METHOD_NAME, System.LoggingLevel.ERROR);
        }

        return Database.getQueryLocator(queryString);
    }

    /**
     * @description This method executes the batchable records
     * @method execute: execute method for the batch
     * @param bc Batchable context set by platform
     * @param recommendationsToReprocess Objects in scope for this batch execution
     *
     */
    public void execute(Database.BatchableContext bc, List<SFCustomRecommendation__c> recommendationsToReprocess) {
        if(!recommendationsToReprocess.isEmpty()){
            reprocessSFCustomRecommendations(recommendationsToReprocess);
        }
    }

    private void reprocessSFCustomRecommendations(List<SFCustomRecommendation__c> recommendationsToReprocess) {
        List<SFCustomRecommendation__c> recommendationsToUpdate = new List<SFCustomRecommendation__c>();
        Boolean isRecommendationAccepted = false;
        for (SFCustomRecommendation__c recommendationToReprocess : recommendationsToReprocess) {
            // Call the Joesi process method
            Decimal currentCount = recommendationToReprocess.FeedbackAPIRetryCounter__c;
            if (recommendationToReprocess.Status__c == 'Accepted') {
                isRecommendationAccepted = true;
            }
            try {
                // If no exception, FeedbackAPICalloutSuccess__c is Successful
                // Increment FeedbackAPIRetryCounter
                recommendationToReprocess.FeedbackAPIRetryCounter__c = currentCount + 1.0;
                NBA_JoesiCallout.processJoesiCallout(isRecommendationAccepted, recommendationToReprocess);
                recommendationToReprocess.FeedbackAPICalloutSuccess__c = CALLOUT_SUCCESSFUL;

            } catch (Exception ex) {
                LoggingService.logHandledException(ex, CLASS_NAME , REPROCESS_RECOMMENDATIONS_METHOD_NAME, System.LoggingLevel.ERROR);
            }
            // Add to update list
            recommendationsToUpdate.add(recommendationToReprocess);
        }

        // Update the records in db
        updateRecords(recommendationsToUpdate);
    }

    private void updateRecords(List<SFCustomRecommendation__c> recommendationsToUpdate) {
        try {
            List<Database.SaveResult> recommendationSaveResults = Database.update(security.stripInaccessible(AccessType.UPDATABLE, recommendationsToUpdate, true).getRecords(), false);
            handleSaveResults(recommendationSaveResults);
        } catch (Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME , UPDATE_RECORDS_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }

    private void handleSaveResults(List<Database.SaveResult> saveResults) {
        DML_ALLOrNothingException ex = new DML_ALLOrNothingException(saveResults);
        if (String.isNotBlank(ex.getMessage())) {
            throw ex;
        }
    }

    /**
     * @method finish
     * @description This method is declared but has no implementation for interface
     * @param bc Batchable context set by platform
     */
    public void finish(Database.BatchableContext bc) {
        // this is enforced method. But need to do nothing.
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info(CLASS_NAME, 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
}
