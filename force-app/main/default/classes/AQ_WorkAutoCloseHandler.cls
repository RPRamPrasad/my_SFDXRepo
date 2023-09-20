/**
  * @name AQ_WorkAutoCloseHandler
  * @author Team Skynet
  * @createdDate 3/31/2023
  * @description  This class will handle Auto-Completion logic for SObjects using Auto Completion Rules
*/

public with sharing class AQ_WorkAutoCloseHandler {

    private static Map<Id, AQ_AutoCompletionRule__c> rulesToUpdateMap = new Map<Id, AQ_AutoCompletionRule__c>();
    private static final String CLASS_NAME = 'AQ_WorkAutoCloseHandler';

    @TestVisible private AQ_WorkAutoCloseHandler(){}

    /**
    * @name: completeRulesForUsers
    * @description Method to filter through tasks querying the AQ_AutoCompletionRule__c.
    * @param workToComplete List of SObjects to complete
    * @return List of SObjects
    */
    public static List<SObject> completeRulesForUsers(List<SObject> workToComplete) {
        List<SObject> remainingWorkToAutoClose = workToComplete;

        Set<Id> objectOwnerIdList = new Set<Id>();
        Map<Id, Set<AQ_AutoCompletionRule__c>> ownerIdToRulesMap = new Map<Id, Set<AQ_AutoCompletionRule__c>>();
        for (SObject record : workToComplete) {
            Schema.SObjectType sObjectType = record.getSObjectType();
            if (sObjectType == Task.getSObjectType()) {
                Task taskToComplete = (Task) record;
                objectOwnerIdList.add(taskToComplete.OwnerId);
            }
        }

        List<AQ_AutoCompletionRule__c> autoCompletionRuleList = Security.stripInaccessible(AccessType.READABLE,
            [SELECT Id, Name, Active__c, CreatedById, OwnerId,Subject_Stored__c, User__r.name
            FROM AQ_AutoCompletionRule__c
            WHERE OwnerId IN :objectOwnerIdList
            AND Active__c = true
            AND User__r.IsActive = true AND User__r.FederationIdentifier != ''
            WITH SECURITY_ENFORCED
            ORDER BY LastModifiedDate ASC]).getRecords();
        ownerIdToRulesMap = populateOwnerIdToRulesMap(autoCompletionRuleList);

        return completeWork(workToComplete, ownerIdToRulesMap , remainingWorkToAutoClose);

    }


    private static Map<Id, Set<AQ_AutoCompletionRule__c>> populateOwnerIdToRulesMap(List<AQ_AutoCompletionRule__c> autoCompletionRuleList){

        Map<Id, Set<AQ_AutoCompletionRule__c>> ownerIdToRulesMap = new Map<Id, Set<AQ_AutoCompletionRule__c>>();
        for (AQ_AutoCompletionRule__c rule : autoCompletionRuleList) {
            Set<AQ_AutoCompletionRule__c> ruleSet = ownerIdToRulesMap.get(rule.OwnerId);
            if (ruleSet == null || ruleSet.isEmpty()) {
                ruleSet = new Set<AQ_AutoCompletionRule__c>();
                ruleSet.add(rule);
                ownerIdToRulesMap.put(rule.OwnerId, ruleSet);
            } else {
                ruleSet.add(rule);
            }

        }
        return ownerIdToRulesMap;
    }
    private static List<SObject> completeWork(List<SObject> workToComplete, Map<Id, Set<AQ_AutoCompletionRule__c>> ownerIdToRulesMap, List<SObject> remainingWorkToAutoClose) {

        List<SObject> remainingTask = remainingWorkToAutoClose;
        Integer taskIndexCounter = 0;
        List<Integer> indexesToRemove = new List<Integer>();
        for (SObject record : workToComplete) {
             Schema.SObjectType sObjectType = record.getSObjectType();
             if (sObjectType == Task.getSObjectType()) {
                 Task taskToComplete = (Task) record;
                 try {
                    boolean found = findTaskToComplete(ownerIdToRulesMap,taskToComplete);
                    if(found){
                        indexesToRemove.add(taskIndexCounter);
                     }
                 } catch (Exception ex) {
                     LoggingService.logHandledException(ex, CLASS_NAME, 'completeWork', LoggingLevel.ERROR);
                 }
             }
             taskIndexCounter += 1; // change if needed
        }
        for (Integer i : indexesToRemove) {
              // Remove the integer from the list to remove
              remainingTask.remove(i);
        }
        return remainingTask;
     }

    /**
    * @name: findTaskToComplete
    * @description Method to return Task with Auto Complete rules assigned.
    * @param ownerIdToRulesMap List of Task to auto complete
    * @param taskToComplete Task needed to be completed
    * @return Updated Task
    */
    private static boolean findTaskToComplete( Map<Id, Set<AQ_AutoCompletionRule__c>> ownerIdToRulesMap, Task taskToComplete){
        boolean found = false;
        if (ownerIdToRulesMap.get(taskToComplete.OwnerId) != null) {
            found = completeUsingRulesTask(taskToComplete,ownerIdToRulesMap.get(taskToComplete.OwnerId));
        }
        return found;
    }


    /**
    * @name: completeUsingRulesTask
    * @description Method to return Task with Auto Complete rules assigned.
    * @param taskToComplete List of Task to auto complete
    * @param completionRules Set of AQ_AutoCompletionRule__c
    * @param taskIndexCounter Integer representing index in task list
    * @return Updated Task
    */
    private static boolean completeUsingRulesTask(Task taskToComplete, Set<AQ_AutoCompletionRule__c> completionRules){
        AQ_AutoCompletionRule__c ruleToUse;
        Task taskToUpdate = taskToComplete;
        boolean found = false;
        for(AQ_AutoCompletionRule__c completionRule : completionRules){
            if(isRuleEligibleToCompleteTask(taskToComplete, completionRule)){
                ruleToUse = completionRule;
                break;
            }
        }
        if(ruleToUse != null){
            // remove task from task list
            AQ_AutoCompletionRule__c ruleToUpdate = new AQ_AutoCompletionRule__c();
            ruleToUpdate.Id = ruleToUse.Id;
            rulesToUpdateMap.put(ruleToUpdate.Id, ruleToUpdate);
            taskToUpdate.CreatedClosed__c = true;
            taskToUpdate.Status = 'Auto-Closed';
            found = true;
        }
        return found;


    }
    private static boolean isRuleEligibleToCompleteTask(Task taskToComplete, AQ_AutoCompletionRule__c completionRule){
        return isRuleNotBlank(completionRule)
                && isRuleActive(completionRule)
                && isCriteriaMatched(completionRule.Subject_Stored__c, taskToComplete.Subject);

    }
    private static boolean isRuleNotBlank(AQ_AutoCompletionRule__c rule){
        return String.isNotBlank(rule.Subject_Stored__c) || String.isNotBlank(rule.OwnerId);
    }

    private static boolean isRuleActive(Aq_AutoCompletionRule__c rule){
        return rule.Active__c;
    }

    private static boolean isCriteriaMatched(String criteria, String value){
        return (String.isBlank(criteria)) || (String.isNotEmpty(criteria) &&  String.isNotBlank(value) && criteria.contains(value));
    }
}