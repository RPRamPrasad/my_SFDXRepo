/**
* @name Batch_ACMT_CaseStatus
* @author Team Mercury-SF Billing
* @createdDate 04/25/2022
* @description Batch class to update ACMT Case Status
*/
public without sharing class Batch_ACMT_CaseStatus implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {

    /**
* @description execute: execute method for the scheduler
* @param sc SchedulableContext : Schedulable context set by platform
*/ 
    public void execute(SchedulableContext sc) {
        Batch_ACMT_CaseStatus aCMTCaseUpdate = new Batch_ACMT_CaseStatus();
        Database.executeBatch(aCMTCaseUpdate, 100);
    }
    
    /**
* @description start: start method for the batch
* @param bc Database.BatchableContext : Batchable context set by platform
* @return Database.QueryLocator: returns query locator for the batch
*/ 
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT ACMT_Case_Number__c, Id, OwnerId, ContactId, Status ' + 
            'FROM Case ' + 
            'WHERE IsClosed = false ' +
            'AND ACMT_Case_Number__c != NULL ' + 
            'WITH SECURITY_ENFORCED';
        return Database.getQueryLocator(query);
    }
    
    /**
* @description execute: execute method for the batch
* @param bc Database.BatchableContext : Batchable context set by platform
* @param openCases List<Case> : Objects in scope for this batch execution
*/ 
    public void execute(Database.BatchableContext bc, List<Case> openCases){
        List<Case> secureCases = Security.stripInaccessible(AccessType.READABLE, openCases).getRecords();

        Set<Id> caseIdsForOpenCases = new Set<Id>();
        for (Case openCase : secureCases){
            caseIdsForOpenCases.add(openCase.Id);
        }

        // Retrieve open cases with existing task logs
        Set<Id> openCaseIdsWithTaskLogs = Batch_ACMT_CaseStatusHelper.taskLogsForCases(secureCases);

        // Retrieve open tasks, if any, for open cases
        Set<Id> caseIdsToBeClosedButWithOpenTask = Batch_ACMT_CaseStatusHelper.caseIdsForCaseWithOpenTask(caseIdsForOpenCases);

        // Update cases for status change
        Batch_ACMT_CaseStatusHelper.processChanges(secureCases, openCaseIdsWithTaskLogs, caseIdsToBeClosedButWithOpenTask);
    }

    /* No code for Finish Method*/
    /**
     * @description finish
     * @param bc 
     */
    public void finish(Database.BatchableContext bc){
        // this is enforced method. But need to do nothing. 
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('Batch_ACMT_CaseStatus', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
    
}