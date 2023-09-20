/**
  * @name Batch_CaseTasksExpiration
  * @author Team Grumpy Cats
  * @createdDate 11/21/2019
  * @description Batch class to expire and close cases those are 
  *              open and unattended for certain days and may
  *              have non-due tasks unattended for more than 90 days
  */
  public without sharing class Batch_CaseTasksExpiration implements Schedulable, Database.Batchable<SObject> {
    private static final String CLASS_NAME = 'Batch_CaseTasksExpiration';
    private static final String EXECUTE_METHOD_NAME = 'execute';
    private static final String START_METHOD_NAME = 'start';
    private static final String UPDATE_CASES_METHOD_NAME = 'updateCases';
    private static final String UPDATE_TASKS_METHOD_NAME = 'updateTasks';
    @TestVisible private static Integer days30OlderThan;
    @TestVisible private static Integer days90OlderThan;
    @TestVisible private static Integer monthsOlderThan;
    @TestVisible private static Integer yearsOlderThan;
    public static final Id ONBOARDING_RECORD_TYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Onboarding').getRecordTypeId();
    public static final Id CSR_RECORD_TYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Default_Case').getRecordTypeId();
    public static final Id POLICY_CHANGE_RECORD_TYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Policy_Change').getRecordTypeId();
    public static final Id RETENSION_RECORD_TYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Retention_Case').getRecordTypeId();
    public static final Id DAR_RECORD_TYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DAR_Case').getRecordTypeId();
    private static Id enrollmentCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enrollment_Case').getRecordTypeId();

    private static final String AUTO = 'Auto';

    static {
        days30OlderThan = 30;
        days90OlderThan = 90;
        monthsOlderThan = 6;
        yearsOlderThan = 1;
    }
    /**
     * @description execute
     * @param sc 
     */
    public void execute(SchedulableContext sc) {
          Batch_CaseTasksExpiration caseExpiration = new Batch_CaseTasksExpiration();
          Database.executeBatch(caseExpiration, 2000);
     }
     
   /**
    * @description - This method Start identifies expirable case records
    * @param bc <Database.BatchableContext>
    * @return  `Database.QueryLocator` <cases>
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        // Fetch Case Onboarding record type Id
        String queryString = '';
        try {
            List<String> recordTypes = new List<String>();
            recordTypes.add(CSR_RECORD_TYPEID);
            recordTypes.add(POLICY_CHANGE_RECORD_TYPEID);
            recordTypes.add(RETENSION_RECORD_TYPEID);
            recordTypes.add(DAR_RECORD_TYPEID);
            recordTypes.add(enrollmentCaseRecordTypeId);
            
            // Fetch all the open cases modified equal to or more than :daysOlderThan90 days ago        
            DateTime days90Old;
            days90Old = System.Now().addDays(-days90OlderThan);
            DateTime months6Old;
            months6Old = System.Now().addMonths(-monthsOlderThan);
            DateTime oneYearOld;
            oneYearOld = System.Now().addYears(-yearsOlderThan);
            queryString = 'SELECT Id, Status, Expired__c, LastModifiedDate, CreatedDate, RecordTypeId, Follow_up_Date__c ' +
                'FROM Case ' +
                'WHERE IsClosed = false ' +
                'AND (' +
                '(RecordTypeId = :ONBOARDING_RECORD_TYPEID AND ((LOB__c = :AUTO AND LastModifiedDate <= :months6Old) OR LastModifiedDate <= :oneYearOld )) ' +
                'OR (RecordTypeId IN :recordTypes AND LastModifiedDate <= :days90Old)'+
                ') WITH SECURITY_ENFORCED ' +
                'ORDER BY LastModifiedDate DESC ' +
                'LIMIT 200000';
            
        } catch(Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME , START_METHOD_NAME, System.LoggingLevel.ERROR);
        } 
        
        return Database.getQueryLocator(queryString);
        
    }

    /**
    * @description execute: execute method for the batch
    * @param bc BC: Batchable context set by platform
    * @param openCases scope: Objects in scope for this batch execution
    */ 
    public void execute(Database.BatchableContext bc, List<Case> openCases){
        

        // Prepare a list of open tasks for above cases. These tasks will be marked completed and expired
        try {
            List<Case> casesToClose = filterCasesToUpdate(openCases);
            List<Task> caseTasksToComplete = filterTasksToUpdate(casesToClose);

            if(!casesToClose.isEmpty()){
            	updateTasks(caseTasksToComplete);
                updateCases(casesToClose);
            }
        } catch (Exception ex) {
            // No action
            LoggingService.logHandledException(ex, CLASS_NAME , EXECUTE_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }
    
    private List<Task> filterTasksToUpdate(List<Case> casesToClose) {
        
        return [SELECT WhatId, Status, Expired__c  
                                FROM Task 
                                WHERE WhatId IN :casesToClose 
                                AND IsRecurrence = false
                                AND IsClosed = false
                                WITH SECURITY_ENFORCED];
    }
    
    private List<Case> filterCasesToUpdate(List<Case> openCases) {
        List<Case> casesToClose = new List<Case>();
        DateTime searchDate = System.Now().addDays(-days90OlderThan);
        Date task3DaysOverDue = Date.today().addDays(-3);
        
        // Prepare list of fetched case Ids
        List<String> openCaseIDs = new List<String>();
        for (Case openCase : openCases) {
            openCaseIDs.add(openCase.Id);
        }
            
        // Prepare a filtered list of above case Ids for which task is created and not Completed or Cancelled
        // and not touched for last 90 days
        List<Task> caseTasksOpen = [SELECT WhatId 
                                FROM Task 
                                WHERE WhatId in :openCaseIDs 
                                AND IsRecurrence = false
                                AND (
                                        (ActivityDate > :task3DaysOverDue AND IsClosed = false)  // use isClosed instead of status
                                        OR
                                        (LastModifiedDate > :searchDate)
                                )
                                WITH SECURITY_ENFORCED];
        Set<Id> caseIdsToBypass = new Set<Id>();
        for (Task task : caseTasksOpen) {
            caseIdsToBypass.add(task.WhatId);
        }
            
        // Filter out case Ids with task created. Remaining cases have no tasks and are ready to be expired
        for (Case openCase : openCases) {
            if (!caseIdsToBypass.contains(openCase.Id)) {
                casesToClose.add(openCase);
            }
        }
        
        return casesToClose;
    }
    
    private void updateCases(List<Case> casesToClose) {
        try {
            for (Case caseToExpire : casesToClose) {
                caseToExpire.Expired__c = TRUE;
                caseToExpire.Status = UTIL_StageOrchestrationConstants.CASE_CLOSE_STATUS;
                caseToExpire.SkipSPIBeforeUpdateTrigger__c = TRUE;
            }
                
                List<Database.SaveResult> casesSaveResults = Database.update(security.stripInaccessible(AccessType.UPDATABLE, casesToClose, true).getRecords(), false);
                handleSaveResults(casesSaveResults);
        } catch (Exception ex) {
            // No action
            LoggingService.logHandledException(ex, CLASS_NAME , UPDATE_CASES_METHOD_NAME, System.LoggingLevel.ERROR);
        }
        
    }
    
    private void updateTasks(List<Task> caseTasksToComplete) {
        try {
           
            for (Task taskToExpire : caseTasksToComplete) {
                taskToExpire.Expired__c = TRUE;
                taskToExpire.Status = UTIL_StageOrchestrationConstants.TASK_COMPLETE_STATUS;
                taskToExpire.SkipSPIBeforeUpdateTrigger__c = TRUE;
            }
				
                
            List<Database.SaveResult> tasksSaveResults = Database.update(security.stripInaccessible(AccessType.UPDATABLE, caseTasksToComplete, true).getRecords(), false);
            
            handleSaveResults(tasksSaveResults);
                
        } catch (Exception ex) {
            // No action
            LoggingService.logHandledException(ex, CLASS_NAME , UPDATE_TASKS_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }
    
    private void handleSaveResults(List<Database.SaveResult> saveResults) {
        DML_ALLOrNothingException ex = new DML_ALLOrNothingException(saveResults);
        if (String.isNotBlank(ex.getMessage())) {
            throw ex;
        }
    }
    
    /* No code for Finish Method*/
    /**
     * @description finish
     * @param bc 
     */
    public void finish(Database.BatchableContext bc){
        // this is enforced method. But need to do nothing. 
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('Batch_CaseTaskExpiration', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }

}