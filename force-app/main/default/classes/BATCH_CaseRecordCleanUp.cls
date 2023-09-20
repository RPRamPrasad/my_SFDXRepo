/**
  * @name BATCH_CaseRecordCleanUp
  * @author Team Baby Yoda
  * @createdDate 05/24/2021
  * @description Batch class to expire and close unattended cases created more than 90 days ago
  */
  public with sharing class BATCH_CaseRecordCleanUp implements Schedulable, Database.Batchable<sObject> {
    private static final String CLASS_NAME = 'BATCH_CaseRecordCleanUp';
    private static final String EXECUTE_METHOD_NAME = 'execute';
    private static final String START_METHOD = 'start';
      
    @TestVisible private static List<Case> testCases = new List<Case>();

    /**
     * @description  
     * @param sc
     */
    public void execute(SchedulableContext sc) {
          BATCH_CaseRecordCleanUp recordRemoveBatch = new BATCH_CaseRecordCleanUp();
          Database.executeBatch(recordRemoveBatch, 2000);
     }
     
    /** 
    * @description <This method Start identifies expirable case records>           
    * @param bc          
    * @return                   
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        Database.QueryLocator locator;
        try{
            locator = Database.getQueryLocator('SELECT Id, ' +
                                              '(SELECT Id FROM Tasks LIMIT 1), ' + 
                                              '(SELECT Id FROM Events LIMIT 1), ' +
                                              '(SELECT Id FROM Case_Notes__r LIMIT 1)' +
                                              'FROM Case ' +
                                              'WHERE MasterRecordId != null ' +
                                              'OR Created_In_Error__c = true ');                    
        }catch(Exception e){
            LoggingService.logHandledException(e, CLASS_NAME, START_METHOD, System.LoggingLevel.ERROR); 
        }
        return locator;
    }
    /**
    * @description execute: execute method for the batch
    * @param bc
    * @param errorOrMergedCases
    */ 
    public void execute(Database.BatchableContext bc, List<Case> errorOrMergedCases){
        List<Case> casesToRemove = new List<Case>();
        try {
            if(!errorOrMergedCases.isEmpty()){
                casesToRemove = handleEmptyTask(errorOrMergedCases);
                Database.delete(casesToRemove, false);
            }
        } catch (Exception ex) {
            // No action
            LoggingService.logHandledException(ex, CLASS_NAME , EXECUTE_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }

    /**
     * @description : No code for Finish Method
     * @param bc
     */
    public void finish(Database.BatchableContext bc){
        // this is enforced method. But need to do nothing. 
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('BATCH_CaseRecordCleanUp', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
      
      private List<Case> handleEmptyTask(List<Case> errorOrMergedCases) {
          List<Case> casesToRemove = new List<Case>();
          
          for (Case errorOrMergedCase : errorOrMergedCases) {
                if (errorOrMergedCase.Tasks.isEmpty() && errorOrMergedCase.Events.isEmpty() && errorOrMergedCase.Case_Notes__r.isEmpty()) {
                    casesToRemove.add(errorOrMergedCase);
                }
       	  }
          if(Test.isRunningTest()){
              testCases = casesToRemove;
          }
          return casesToRemove;
      }

}