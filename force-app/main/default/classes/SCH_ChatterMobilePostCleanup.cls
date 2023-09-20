/**
 * @description SCH_ChatterMobilePostCleanup
 */
global with sharing class SCH_ChatterMobilePostCleanup implements Schedulable {   
    public static final String CHATTER_MOBILE_POST_CLEANUP = 'ChatterMobilePostCleanup';
    private List<CS_BatchChatterCleanUp__c> csbs= CS_BatchChatterCleanUp__c.getall().values();
    private Integer batchSize = csbs[0].BatchSize__c.intValue();
    private String cron_Exp = csbs[0].CRON_EXP__c;
    private String jobName = csbs[0].JobName__c;
    
    /**
     * @description execute
     * @param sc 
     */
    global void execute(SchedulableContext sc) {
      Batch_ChatterMobilePostCleanup chatCleanupBatch = new Batch_ChatterMobilePostCleanup();
      System.schedule(jobName, cron_Exp, chatCleanupBatch); 
      Database.executeBatch(chatCleanupBatch, batchSize);
    }
}