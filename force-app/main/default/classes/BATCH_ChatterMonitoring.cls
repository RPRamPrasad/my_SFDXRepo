/**
  * @Name BATCH_ChatterMonitoring
  * @Author ITIC
  * @description Batch Class use object FeedStage__c to identify Feed Item and Feed Comments and collect the transcript.
  * The transcript is written in to the Object Captured_Feed_Transcript__c as EmailBody,EmailSubject,
  *  Participants and update the status.
  */

  global with sharing class BATCH_ChatterMonitoring implements Database.Batchable<sObject>, Database.AllowsCallouts{
     private static final String CHATTER_MONITORING_BATCH_ID = 'ChatterMonitoringBatchId';
     private static final String BATCH_CLASS_NAME = 'BATCH_ChatterMonitoring';
     private static final String BATCH_EXECUTE_METHOD = 'execute';
     private static final String BATCH_FINISH_METHOD = 'finish';
     private static final String DATE_FORMAT = 'yyyyMMddhhmmssSSS';

  /**
   * @description method to start the query
   * @param bC
   * @return  `Database.QueryLocator`
   */
   global Database.QueryLocator start(Database.BatchableContext bC){
     String batchQuery = 'SELECT FeedItemID__c FROM FeedStage__c ';
     AP_BatchJobStatus.abortJobIfCurrentlyRunning(BATCH_CLASS_NAME, bC.getJobId());
     if(Test.isRunningTest()) {
             batchQuery += 'order by LastModifiedDate desc Limit 1';
         }
     return Database.getQueryLocator(batchQuery);
   }

  /**
   * @description method to execute the batch query
   * @param bC
   * @param stageFeedList
   */
   global void execute (Database.BatchableContext bC, List<FeedStage__c> stageFeedList){

     try{
       CS_ChatterMonitoringBatchId__c  chatterMonitoringBatchId = CS_ChatterMonitoringBatchId__c.getInstance(CHATTER_MONITORING_BATCH_ID);
       AP_ChatterMonitoringService service = new AP_ChatterMonitoringService();
       String lastExecutedBatchId = chatterMonitoringBatchId.lastExecutedBatchId__c;
       if (!Test.isRunningTest() && !String.isBlank(lastExecutedBatchId)) {
           service.getResponseFromService(lastExecutedBatchId);
       }
       lastExecutedBatchId = system.now().format(DATE_FORMAT);
       chatterMonitoringBatchId.lastExecutedBatchId__c = lastExecutedBatchId;
       update chatterMonitoringBatchId;
       AP_BatchChatterTranscript batchChatterTranscript = new AP_BatchChatterTranscript();
       System.debug(LoggingLevel.DEBUG,'Actual Memory Used in Batch: ' +Limits.getHeapSize());
       System.debug(LoggingLevel.DEBUG,'Total Memory that can be used in Batch: ' +Limits.getLimitHeapSize());
       batchChatterTranscript.processTranscriptForChatterMonitoring (stageFeedList,lastExecutedBatchId);
     }catch (Exception e){
       LoggingService.logHandledException(e, BATCH_CLASS_NAME, BATCH_EXECUTE_METHOD, System.LoggingLevel.ERROR);
      }
   }

  /**
   * @description method to finish the batch query
   * @param bC
   */
   global void finish (Database.BatchableContext bC){
       CS_ChatterMonitoringBatchId__c  chatterMonitoringBatchId = CS_ChatterMonitoringBatchId__c.getInstance(CHATTER_MONITORING_BATCH_ID);
       String lastExecutedBatchId = chatterMonitoringBatchId.lastExecutedBatchId__c;
       AP_ChatterMonitoringService service = new AP_ChatterMonitoringService();
       if (!String.isBlank(lastExecutedBatchId)) {
           if(!Test.isRunningTest()) {
                 service.getResponseFromService(lastExecutedBatchId);
                 chatterMonitoringBatchId.lastExecutedBatchId__c = AP_UserProvisioningConstants.NO_SPACE;
                 update chatterMonitoringBatchId;
           }
       }
   }
 }