/**
  * @name SR_ExceptionReplayCleanup
  * @author Baby Yoda
  * @createdDate 06/17/2021
  * @description Batch class to delete successfully replayed
  * SR Exception replay records after 30 days
  */

  public with sharing class SR_ExceptionReplayCleanup implements Schedulable, Database.Batchable<SObject> {
    private static final String CLASS_NAME = 'SR_ExceptionReplayCleanup';
    private static final String EXECUTE_METHOD_NAME = 'execute';
    private static final String START_METHOD_NAME = 'start';  
    private static final String EXCEPTION_RECORD_TYPE_AUTO_RETRY = SR_Constants.EXCEPTION_RECORD_TYPE_AUTO_RETRY; 
    @TestVisible CS_SR_Config__c srConfig = CS_SR_Config__c.getInstance();
    @TestVisible private Integer daysOlderThan = (srConfig.Exception_Replay_Cleanup_Days_Old__c == null) ? 30 : Integer.valueOf(srConfig.Exception_Replay_Cleanup_Days_Old__c);
    /**
     * @description execute
     * @param context 
     */
    public void execute(SchedulableContext context) {
        SR_ExceptionReplayCleanup sreCleanupBatch = new SR_ExceptionReplayCleanup();
        Database.executeBatch(sreCleanupBatch, 2000);
    }
    /**
     * @description start
     * @param context 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext context){
        DateTime daysOld;
        daysOld = System.Now().addDays(-daysOlderThan);
     	String query = '';
        try {
            query = 'SELECT Id, Payload__c, Retry_Count__c, isSuccessfullyReplayed__c ' +
                          'FROM Service_Request_Exception__c ' +                          
                          'WHERE isSuccessfullyReplayed__c = true ' +                
                          'AND SystemModstamp <= :daysOld ';
        } catch (Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME, START_METHOD_NAME, System.LoggingLevel.ERROR);
        }

        return Database.getQueryLocator(query);

    }
    /**
     * @description execute
     * @param context 
     * @param exceptionsReplayed 
     */
    public void execute(Database.BatchableContext context, List<Service_Request_Exception__c> exceptionsReplayed) {
        try {
            if (!exceptionsReplayed.isEmpty()) {
                Database.delete(exceptionsReplayed);
            }
        } catch(Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME, EXECUTE_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }

    /* No code for Finish Method*/
    /**
     * @description finish
     * @param context 
     */
    public void finish(Database.BatchableContext context){
        // this is enforced method. But need to do nothing. 
        String pmd;
        pmd = 'Go away PMD';
    }

  }