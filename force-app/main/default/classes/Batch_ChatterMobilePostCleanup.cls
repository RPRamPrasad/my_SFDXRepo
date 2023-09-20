/**
 * @description Batch_ChatterMobilePostCleanup
 */
global with sharing class Batch_ChatterMobilePostCleanup implements Schedulable,Database.Batchable<sObject> {
    
    private static final String BATCH_CLASS_NAME = 'Batch_ChatterMobilePostCleanup';
    private static final String BATCH_EXECUTE_METHOD = 'execute';
    private static List<CS_BatchChatterCleanUp__c> csbs= CS_BatchChatterCleanUp__c.getall().values();
    
    /**
     * @description execute
     * @param sc 
     */
    global void execute(SchedulableContext sc) {
          Batch_ChatterMobilePostCleanup chatCleanupBatch = new Batch_ChatterMobilePostCleanup();
          Integer batchSize=csbs[0].BatchSize__c.intValue();
          Database.executeBatch(chatCleanupBatch, batchSize);
     }
     
     /**
      * @description start
      * @param context 
      * @return  `Database.QueryLocator`
      */
     global Database.QueryLocator start(Database.BatchableContext context) {
        String batchQuery = '';
        Datetime twoHourBack;
        Integer timeOffset =csbs[0].TimeOffSet__c.intValue();
        twoHourBack = System.now().addMinutes(-timeOffset);
        if(Test.isRunningTest()){
           batchQuery ='SELECT id, name, createdDate FROM ChatterPostCleanup__c';
        }
        else{
           batchQuery =' SELECT id, name, createdDate FROM ChatterPostCleanup__c WHERE createdDate < :twoHourBack';
        }
        
        return Database.getQueryLocator(batchQuery);
    }
    
    /**
     * @description execute
     * @param context 
     * @param scope 
     */
    global void execute(Database.BatchableContext context, List<ChatterPostCleanup__c> scope) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<FeedItem> feedToDelete = new List<FeedItem>();
            List<ChatterPostCleanup__c> stageToDelete = new List<ChatterPostCleanup__c>();
            for(ChatterPostCleanup__c postCleanup : scope) {
                feedToDelete.add(new FeedItem(Id=postCleanup.Name));
                stageToDelete.add(postCleanup);
            }
            delete feedToDelete;
            delete stageToDelete;
        } catch(Exception e) {
            Database.rollback(sp);
            LoggingService.logHandledException(e, BATCH_CLASS_NAME, BATCH_EXECUTE_METHOD, System.LoggingLevel.ERROR);
        }
    }
    
    /**
     * @description finish
     * @param context 
     */
    global void finish(Database.BatchableContext context) { 
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.error(BATCH_CLASS_NAME, 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
    
}