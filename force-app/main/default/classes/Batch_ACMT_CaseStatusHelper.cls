/**
* @name Batch_ACMT_CaseStatusHelper
* @author Team Mercury-SF Billing
* @createdDate 05/17/2022
* @description Batch class to update ACMT Case Status
*/
public without sharing class Batch_ACMT_CaseStatusHelper {

    private static final String CLOSED = 'Closed';
    private static final String LOG_DESCRIPTION = 'Operations has completed and closed your Case. Please review your open tasks.';
    private static final String LOG_SUBJECT = 'Case Closed';
    private static final String LOW_PRIORITY = 'Low';

    /**
     * @description - Update the open case for status change. Add log for closed case if the case has open task
     * @param secureCases - List of open cases
     * @param openCaseIdsWithTaskLogs - Set of case Ids for cases with existing logs
     * @param caseIdsToBeClosedButWithOpenTask - Set of case Ids for cases to be closed but with open task
     */
    public static void processChanges(List<Case> secureCases, Set<Id> openCaseIdsWithTaskLogs, Set<Id> caseIdsToBeClosedButWithOpenTask) {
        List<Case> casesToUpdate = new List<Case>();
        List<Task> taskLogsToCreate = new List<Task>();
        String status;
        Boolean isCaseClosed;
        Boolean hasStatusChanged;
        
        for (Case c : secureCases) {
            try {
                status = getCaseStatus(c.ACMT_Case_Number__c);
            } catch(Exception ex) {
                LoggingService.logHandledException(ex, 'Batch_ACMT_CaseStatus', 'ACMT Case: ' + c.ACMT_Case_Number__c + ' - execute-getStatus', System.LoggingLevel.ERROR);
            }

            isCaseClosed = (String.isNotBlank(status) && CLOSED.equals(status));
            // Create a log if OSC case is closed, but there is open task for ECRM case
            if (isCaseClosed && caseIdsToBeClosedButWithOpenTask.contains(c.Id)
                && (!openCaseIdsWithTaskLogs.contains(c.Id))) {
                    // Create a log only if there is no existing log
                    taskLogsToCreate.add(buildLog(c.OwnerId, c.ContactId, c.Id));
            }

            hasStatusChanged = (String.isNotBlank(status) && (!(status.equals(c.status))));
            // Update the case status if the status does not match, and, if to be closed there is not open task
            if (hasStatusChanged && (!(CLOSED.equals(status) && caseIdsToBeClosedButWithOpenTask.contains(c.Id)))) {
                    // Otherwise, update status
                    c.status = status;    
                    casesToUpdate.add(c);  
            }                
        }

        // update cases
        updateCases(casesToUpdate);

        // insert logs
        insertLogs(taskLogsToCreate);
    }

    /**
    * @description updateCases: Update the cases for status change
    * @param casesToUpdate - Cases with updates
    */ 
    public static void updateCases(List<Case> casesToUpdate) {
        // update the cases
        try{
            SObjectAccessDecision caseUpdateDecision = Security.stripInaccessible( AccessType.UPDATABLE, casesToUpdate);
            update caseUpdateDecision.getRecords();
        } catch(exception ex){
            LoggingService.logHandledException(ex, 'Batch_ACMT_CaseStatus', 'execute-updateCases', System.LoggingLevel.ERROR);
        }
    }

    /**
    * @description insertLogs: Insert logs for cases to be closed but can't due to open task
    * @param taskLogsToCreate - logs to be inserted
    */ 
    public static void insertLogs(List<Task> taskLogsToCreate) {
        try{
            SObjectAccessDecision taskLogCreateDecision = Security.stripInaccessible( AccessType.UPDATABLE, taskLogsToCreate);
            insert taskLogCreateDecision.getRecords();
        } catch(exception ex){
            LoggingService.logHandledException(ex, 'Batch_ACMT_CaseStatus', 'execute-updateCases', System.LoggingLevel.ERROR);
        }

    }
    
    /**
     * @description - Builds a new log and sets the fields using values from the parameters
     * @param ownerUser
     * @param contactId 
     * @param recordId - The id to use when setting the what id
     * @return Task - returns a log which has the fields set using the parameters
     */
    @TestVisible
    private static Task buildLog(Id ownerUser, Id contactId, Id recordId) {
        SObjectType objectType = recordId.getSobjectType();

        TaskFactoryNewLog logFactory = new TaskFactoryNewLog();
        logFactory.setLogTitle(LOG_SUBJECT)
                  .setDescription(LOG_DESCRIPTION)
                  .setAppCode('SFDC UI - ' + String.valueOf(objectType))
                  .setPriority(LOW_PRIORITY)
                  .setOwnerId(String.valueOf(ownerUser))
                  .setWhoId(String.valueOf(contactId))
                  .setWhatId(recordId);
        
        return logFactory.returnNewLog();
    }

    /**
    * @description getCaseStatus: private method for API call to get case status
    * @param aCMTCaseNumber String : aCMT Case number to get the status update
    * @return String : returns ACMT case status
    */ 
    @TestVisible
    private static String getCaseStatus(String aCMTCaseNumber){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ACMTCaseCreation/status/' + aCMTCaseNumber);
        req.setMethod('GET');
        
        HttpResponse res = http.send(req);
        String status;
        
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null){
                if(parser.getText() == 'status'){
                    parser.nextValue();
                    status = parser.getText();
                }
            }
        }
        
        return status;
    }

    /**
    * @description taskLogsForCases: private method to retrieve existing log IDs for Cases to be closed
    * @param secureCases List<Case> - Open cases
    * @return Set<Id> - Ids of Logs for Open cases
    */ 
    public static Set<Id> taskLogsForCases(List<Case> secureCases) {
        List<Task> taskLogsForOpenCases = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, WhatId FROM Task WHERE WhatId IN :secureCases AND RecordTypeId = :TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID AND Subject = :LOG_SUBJECT]).getRecords();
        
        Set<Id> openCaseIdsWithTaskLogs = new Set<Id>();
        for (Task taskLogForOpenCase : taskLogsForOpenCases) {
            openCaseIdsWithTaskLogs.add(taskLogForOpenCase.WhatId);
        }
        return openCaseIdsWithTaskLogs;
    }

    /**
    * @description caseIdsForCaseWithOpenTask: private method to retrieve Case IDs for Cases with open task
    * @param caseIdsForOpenCases Set<Id> - Case Ids for open cases
    * @return Set<Id> - Ids of cases with open task
    */ 
    public static Set<Id> caseIdsForCaseWithOpenTask(Set<Id> caseIdsForOpenCases) {
        // Retrieve open tasks, if any, for open cases
        List<Task> caseTasksToComplete = Security.stripInaccessible(AccessType.READABLE, [SELECT WhatId, Status, Expired__c  
                                FROM Task 
                                WHERE WhatId IN :caseIdsForOpenCases 
                                AND IsRecurrence = false
                                AND IsClosed = false
                                WITH SECURITY_ENFORCED]).getRecords();

        Set<Id> caseIdsToBeClosedButWithOpenTask = new Set<Id>();
        for (Task caseTaskToComplete : caseTasksToComplete) {
            caseIdsToBeClosedButWithOpenTask.add(caseTaskToComplete.WhatId);
        }
        return caseIdsToBeClosedButWithOpenTask;
    }
    
}