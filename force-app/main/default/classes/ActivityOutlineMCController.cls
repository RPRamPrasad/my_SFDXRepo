/**
 * @description controller used to quickly mark a task complete or cancelled
 * @Owner CATS
 */
public with sharing class ActivityOutlineMCController {

    @TestVisible private static List<Task> mockLastList = new List<Task>();
    @TestVisible private static List<Case> mockCaseList = new List<Case>();

    private static final String CLASS_NAME = 'ActivityOutlineMCController';

     /**
     * @description Method to close task and check if this task was the last open task on parent object
     * @param recordId
     * @param status
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean closeTask(Id recordId, String status) {
        try {
            List<Task> taskList = getCurrentTask(recordId);
            if(!taskList.isEmpty()){
                updateTasks(taskList, status);
                return isThisLastOpenTaskOnParent(taskList.get(0));
            }
        } catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'closeTask', LoggingLevel.ERROR);
            throw new AuraHandledException('Unable to close task');
        }

        return false;
    }

    /**
     * @description Method to close task with a specific outcome and check if this task was the last open task on parent object
     * @param recordId
     * @param status
     * @param outcomeEntered
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean closeTaskWithOutcome(Id recordId, String status, String outcomeEntered) {
        try {
            List<Task> taskList = getCurrentTask(recordId);
            if(!taskList.isEmpty()){
                updateTasks(taskList, status, outcomeEntered);
                return isThisLastOpenTaskOnParent(taskList.get(0));
            }
        } catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'closeTaskWithOutcome', LoggingLevel.ERROR);
            throw new AuraHandledException('Unable to close task with outcome');
        }
        return false;
    }

    private static Boolean isThisLastOpenTaskOnParent(Task taskRecord){
        if(taskRecord.What.Type == 'Case' || Test.isRunningTest()){
            return closePromptOnCase(taskRecord.WhatId);
        }
        return false;
    }

    @TestVisible private static List<Task> getCurrentTask(Id recordId){
        List<Task> taskList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, Status, WhatId, What.Type, Description, Outcome_Added__c FROM Task WHERE Id =: recordId LIMIT 1]).getRecords();
        if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
            taskList = mockLastList;
        }
        return taskList;
    }

    @TestVisible private static void updateTasks(List<Task> taskList, String status){
        for(Task taskRecord : taskList){
        	taskRecord.Status = status;
        }
        if(!UnitTestDataUtility.isUnitTest){
        	update Security.stripInaccessible(AccessType.UPDATABLE, taskList, true).getRecords();
        }
    }

    @TestVisible private static void updateTasks(List<Task> taskList, String status, String outcomeEntered){
        for(Task taskRecord : taskList){
            taskRecord.Outcome_Added__c = true;
        	taskRecord.Description = outcomeEntered;
        	taskRecord.Status = status;
        }
        if(!UnitTestDataUtility.isUnitTest){
        	update Security.stripInaccessible(AccessType.UPDATABLE, taskList, true).getRecords();
        }
    }

    @TestVisible private static Boolean closePromptOnCase(Id relatedToId){
        Boolean enablePrompt = false;
        List<Case> c = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, Reason, Status,
                  (SELECT Id, Status, isClosed FROM Tasks WHERE isClosed = false)
                  FROM Case
                  WHERE Id = :relatedToId LIMIT 1]).getRecords();
        if(Test.isRunningTest()){
            c = mockCaseList;
        }
        if(c.size() > 0
           && c[0].Reason != 'Change of Address'
           && c[0].Status != 'Closed'
           && c[0].Tasks.size()==0){
            enablePrompt = true;
        }
        return enablePrompt;
    }
}