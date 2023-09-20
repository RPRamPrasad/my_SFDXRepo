/**
 * @description TaskClosureModalController
 */
public without sharing class TaskClosureModalController {
	private static final String TASK_AUTO_CLOSED_STATUS = 'Auto-Closed';
    @TestVisible private static List<Task> mockTaskData = new List<Task>();
    /**
     * @description closeTasks
     * @param recordId 
     */
    @AuraEnabled
    public static void closeTasks(String recordId) {
        List<Task> openTasks = fetchOpenActivitiesForCase(recordId);
        Case relatedCase = openTasks[0].what;
        if(FeatureManagement.checkPermission('Agency_User') && !relatedCase.IsOwnerProxyofCurrentUser__c){
            AuraHandledException e = new AuraHandledException('insufficient access rights on object id');
            throw e;
        }
        for(Task openTask : openTasks){
            openTask.Status = TASK_AUTO_CLOSED_STATUS;
        }
        update Security.stripInaccessible(AccessType.UPDATABLE, openTasks, true).getRecords();
        List<Case> caseList = new List<Case>();
        Case caseToClose = new Case(Id=recordId);
        caseToClose.Status = 'Closed';
        caseList.add(caseToClose);
        update Security.stripInaccessible(AccessType.UPDATABLE, caseList, true).getRecords();
    }
    /**
     * @description closeTasksWithOutcome
     * @param recordId 
     * @param outcomeEntered 
     */
    @AuraEnabled
    public static void closeTasksWithOutcome(String recordId, String outcomeEntered) {
        List<Task> openTasks = fetchOpenActivitiesForCase(recordId);
        Case relatedCase = openTasks[0].what;
        if(FeatureManagement.checkPermission('Agency_User') && !relatedCase.IsOwnerProxyofCurrentUser__c){
            AuraHandledException e = new AuraHandledException('insufficient access rights on object id');
            throw e;
        }
        for(Task openTask : openTasks){
            if (!openTask.Outcome_Added__c) {
				openTask.Outcome_Added__c = true;
            	openTask.Description = outcomeEntered;                
            }
            openTask.Status = TASK_AUTO_CLOSED_STATUS;
        }
        update Security.stripInaccessible(AccessType.UPDATABLE, openTasks, true).getRecords();
        List<Case> caseList = new List<Case>();
        Case caseToClose = new Case(Id=recordId);
        caseToClose.Status = 'Closed';
        caseList.add(caseToClose);
        update Security.stripInaccessible(AccessType.UPDATABLE, caseList, true).getRecords();
    }
    
    @TestVisible private static List<Task> fetchOpenActivitiesForCase(String recordId) {
        List<Task> fetchResults = Security.stripInaccessible(AccessType.READABLE, 
                                                             [Select Id, WhatId, Status, Outcome_Added__c, Description,
                                                              TYPEOF What
                                                              	WHEN Case THEN IsOwnerProxyofCurrentUser__c
                                                              END
                                                              FROM Task 
                                                              WHERE WhatId =: recordId 
                                                              AND (Status = 'In Progress' OR Status = 'Not Started')]).getRecords();
        return fetchResults;
    }
}