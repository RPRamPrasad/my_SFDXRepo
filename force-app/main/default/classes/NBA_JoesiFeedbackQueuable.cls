/**
 * @name NBA_JoesiFeedbackQueuable
 * @author Skynet
 * @description Class that reinvokes failed Joesi Feedback Calls. 
 */
public with sharing class NBA_JoesiFeedbackQueuable implements Queueable, Database.AllowsCallouts {

    private Integer joesiCalloutCount = 0;
    private static final String CS_NBA_CONFIG_FEEDBACK_API_MAX_RETRY_COUNTER = 'FeedbackAPIMaxRetryCounter';
    private static final CS_NBA_Config__c JOESI_CALLOUT_LIMIT = CS_NBA_Config__c.getValues(CS_NBA_CONFIG_FEEDBACK_API_MAX_RETRY_COUNTER);
    private SFCustomRecommendation__c recommendation;
    private Integer maxRetryCount = 3;
	private Boolean recommendationAccepted;
    private static final String CLASS_NAME = 'NBA_JoesiFeedbackQueuable';
    private static final String METHOD_NAME_HANDLE_JOESI_CALLOUT = 'handleJoesiCallout';
    private static final String METHOD_NAME_HANDLE_DATABASE_UPDATE = 'handleDatabaseUpdate';
    private static final String SUCCESSFUL = 'Successful';
    private static final String FAILED = 'Failed';




    /**
     * @name Constructor
     * @description creates a JoesiFeedbackQueable instance
     * @param calloutCount 
     * @param recommendation
     * @param recommendationAccepted 
     */
    public NBA_JoesiFeedbackQueuable(Integer calloutCount, SFCustomRecommendation__c recommendation, Boolean recommendationAccepted) {
        if(JOESI_CALLOUT_LIMIT != null) {
            this.maxRetryCount = Integer.valueOf(JOESI_CALLOUT_LIMIT.Value__c);
        }
        this.joesiCalloutCount = calloutCount;
        this.recommendation = recommendation;
        // grab status / id from Rec Obj
        this.recommendationAccepted = recommendationAccepted;
    }

    /**
     * @name execute
     * @description Manages Feed Back call outs asynchronously.
     * @param context 
    */ 
    public void execute(QueueableContext context) {
        handleJoesiCallout();
    }
    
    /**
    * @name handleJoesiCallout
    * @description Manage retry http callouts to JOESI
    */ 
    private void handleJoesiCallout() {
        try{
            // invoke joesi callout
            HttpResponse response = NBA_JoesiCallout.callJoesiFeedback(this.recommendation, this.recommendationAccepted, this.recommendation.EIID__c);
			
            if (response.getStatusCode() != 200) {
				handleDatabaseUpdate(FAILED);
                
                // set recommendation object status to false, continue chained queueable
                if(this.joesiCalloutCount < this.maxRetryCount){
                	System.enqueueJob(new NBA_JoesiFeedbackQueuable(this.joesiCalloutCount + 1, this.recommendation, this.recommendationAccepted));
                }
                //Logging an exception for Invalid response code on JOESI Feedback Callout.
                throw new CalloutException('Joesi Feedback Callout Retry Attempt' + 'Status: ' + response.getStatusCode() + ' Response:' + response.getBody() + ' ClientId: ' + this.recommendation.Account__r.ClientIdentifier__c + ' EIID: ' + recommendation.EIID__c +
                                            ' ActionID:' + recommendation.Action_ID__c);             
            }else{
               	handleDatabaseUpdate(SUCCESSFUL);
            }
        } catch(Exception exp){
            handleDatabaseUpdate(FAILED);
            LoggingService.logHandledException(exp, CLASS_NAME, METHOD_NAME_HANDLE_JOESI_CALLOUT, LoggingLevel.ERROR);
        }
    }
    
    private void handleDatabaseUpdate(String calloutStatus){
        List<SFCustomRecommendation__c> recommendationsToUpdate = new List<SFCustomRecommendation__c>();
        SFCustomRecommendation__c recordToUpdate = new SFCustomRecommendation__c();
        recordToUpdate.Id = this.recommendation.Id;
        recordToUpdate.FeedbackAPIRetryCounter__c = this.joesiCalloutCount;
        recordToUpdate.FeedbackAPICalloutSuccess__c = calloutStatus;
        recommendationsToUpdate.add(recordToUpdate);
        List<Database.SaveResult> recommendationSaveResults = Database.update(Security.stripInaccessible(AccessType.UPDATABLE, recommendationsToUpdate, true).getRecords(), false);
        LoggingService.logDatabaseResult(recommendationSaveResults, recommendationsToUpdate, CLASS_NAME, METHOD_NAME_HANDLE_DATABASE_UPDATE, LoggingLevel.ERROR);
    }

    
}
