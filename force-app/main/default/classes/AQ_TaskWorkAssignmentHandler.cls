/**
  * @name AQ_TaskWorkAssignmentHandler
  * @author Team Skynet
  * @createdDate 11/10/2022
  * @description  This class will handle Assignment logic for Tasks using Work Assignment Rules
*/
public with sharing class AQ_TaskWorkAssignmentHandler{

    private static List<Task> tasksToUpdate = new List<Task>();
    private static Map<Id, AQ_WorkAssignmentRule__c> rulesToUpdateMap = new Map<Id, AQ_WorkAssignmentRule__c>();
    private static final String CLASS_NAME = 'AQ_TaskWorkAssignmentHandler';

    private static final String CS_AGENTQUEUE_CONFIG_HOURS_BEHIND = 'BatchAgentQueueHoursBehind';
    private static final CS_AGENTQUEUE_Config__c HOURS_BEHIND = CS_AGENTQUEUE_Config__c.getValues(CS_AGENTQUEUE_CONFIG_HOURS_BEHIND);

    private AQ_TaskWorkAssignmentHandler(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('AQ_TaskWorkAssignmentHandler', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }

    /**
    * @name: assignTasksToUsers
    * @description Method to assign Users to Unassigned Tasks.
    * @param tasksToAssign from flow
    */
    public static void assignTasksToUsers(List<Task> tasksToAssign){

        Set<Id> taskOwnerIdList = new Set<Id>();
        DateTime tempCSDateTime;
        Map<Id, Set<AQ_WorkAssignmentRule__c>> ownerIdToRulesMap = new Map<Id, Set<AQ_WorkAssignmentRule__c>>();

        for (Task newTask : tasksToAssign) {
            taskOwnerIdList.add(newTask.OwnerId);
            if(String.ValueOfGMT(tempCSDateTime) == null || newTask.CreatedDate > tempCSDateTime) {
                tempCSDateTime = newTask.CreatedDate;
            }
        }

        List<AQ_WorkAssignmentRule__c> workAssignmentRuleList = Security.stripInaccessible(AccessType.READABLE,
                                                            [SELECT Id, EndAlpha__c, LOB_Stored__c, StartAlpha__c,
                                                                Task_Subject__c, User__c, User__r.Name, LastAssignedDateTime__c, OwnerId
                                                            FROM AQ_WorkAssignmentRule__c
                                                            WHERE OwnerId IN :taskOwnerIdList
                                                            AND User__r.IsActive = true AND User__r.FederationIdentifier != ''
                                                            WITH SECURITY_ENFORCED
                                                            ORDER BY LastAssignedDateTime__c ASC]).getRecords();

        ownerIdToRulesMap = populateOwnerIdToRulesMap(workAssignmentRuleList);


        assignTasks(tasksToAssign, ownerIdToRulesMap);
        updateTasks();
        updateRules();
        updateCustomSetting(tempCSDateTime);
    }

    private static Map<Id, Set<AQ_WorkAssignmentRule__c>> populateOwnerIdToRulesMap(List<AQ_WorkAssignmentRule__c> workAssignmentRuleList){

        Map<Id, Set<AQ_WorkAssignmentRule__c>> ownerIdToRulesMap = new Map<Id, Set<AQ_WorkAssignmentRule__c>>();
        for (AQ_WorkAssignmentRule__c rule : workAssignmentRuleList) {
            Set<AQ_WorkAssignmentRule__c> ruleSet = ownerIdToRulesMap.get(rule.OwnerId);
            if (ruleSet == null || ruleSet.isEmpty()) {
                ruleSet = new Set<AQ_WorkAssignmentRule__c>();
                ruleSet.add(rule);
                ownerIdToRulesMap.put(rule.OwnerId, ruleSet);
            } else {
                ruleSet.add(rule);
            }

        }
        return ownerIdToRulesMap;
    }

    private static void assignTasks(List<Task> tasksToAssign, Map<Id, Set<AQ_WorkAssignmentRule__c>> ownerIdToRulesMap){

        for (Task taskToAssign : tasksToAssign) {
            try {
                if (ownerIdToRulesMap.get(taskToAssign.OwnerId) != null) {
                    assignTaskUsingAssignmentRules(taskToAssign,ownerIdToRulesMap.get(taskToAssign.OwnerId));
                }
            } catch (Exception ex) {
                LoggingService.logHandledException(ex, CLASS_NAME, 'assignTasks', LoggingLevel.ERROR);
            }
        }
    }

    private static void assignTaskUsingAssignmentRules(Task taskToAssign, Set<AQ_WorkAssignmentRule__c> assignmentRules) {

        AQ_WorkAssignmentRule__c ruleToUse;
        DateTime oldestAssignedDateTime;

        for(AQ_WorkAssignmentRule__c assignmentRule : assignmentRules){
            if(isRuleEligible(taskToAssign, assignmentRule)){

                if(assignmentRule.LastAssignedDateTime__c == null){
                    ruleToUse = assignmentRule;
                    break;
                }

                if(oldestAssignedDateTime == null || assignmentRule.LastAssignedDateTime__c < oldestAssignedDateTime){
                    oldestAssignedDateTime = assignmentRule.LastAssignedDateTime__c;
                    ruleToUse = assignmentRule;
                }
            }
        }

        if(ruleToUse != null){

            AQ_WorkAssignmentRule__c ruleToUpdate = new AQ_WorkAssignmentRule__c();
            ruleToUpdate.Id = ruleToUse.Id;
            ruleToUse.LastAssignedDateTime__c = System.now();
            ruleToUpdate.LastAssignedDateTime__c = ruleToUse.LastAssignedDateTime__c;
            rulesToUpdateMap.put(ruleToUpdate.Id, ruleToUpdate);

            Task taskToUpdate = new Task();
            taskToUpdate.Id = taskToAssign.Id;
            taskToUpdate.AssignedTo__c = ruleToUse.User__c;
            taskToUpdate.Original_Subject__c = taskToAssign.Subject;
            tasksToUpdate.add(taskToUpdate);
        }
    }

    private static boolean isRuleEligible(Task taskToAssign, AQ_WorkAssignmentRule__c assignmentRule){
        return isRuleNotBlank(assignmentRule)
                && isCriteriaMatched(assignmentRule.Task_Subject__c, taskToAssign.Subject)
                && isCriteriaMatched(assignmentRule.LOB_Stored__c, taskToAssign.LineofBusiness__c)
                && isLastNameMatched(taskToAssign.Account.LastName, assignmentRule.Startalpha__c, assignmentRule.EndAlpha__c);
    }

    private static boolean isRuleNotBlank(AQ_WorkAssignmentRule__c rule){
        return String.isNotBlank(rule.Task_Subject__c) || String.isNotBlank(rule.LOB_Stored__c)
                || (String.isNotBlank(rule.StartAlpha__c) && String.isNotBlank(rule.EndAlpha__c));
    }

    private static boolean isCriteriaMatched(String criteria, String value){
        return (String.isBlank(criteria)) || (String.isNotEmpty(criteria) &&  String.isNotBlank(value) && criteria.contains(value));
    }

    private static boolean isLastNameMatched(String lastName, String startAlpha, String endAlpha){

        //Rule is eligible if start alpha or endalpha is not defined.
        if(String.isBlank(startAlpha) || String.isBlank(endAlpha)){
            return true;
        }

        if(String.isBlank(lastName)){
            return false;
        }

        String startAlphaEncoded = encodingUtil.convertToHex(blob.valueOf(startAlpha));
        String endAlphaEncoded = encodingUtil.convertToHex(blob.valueOf(endAlpha));
        String lnStartsWith = encodingUtil.convertToHex(blob.valueOf(lastName.substring(0,1)));

        return (lnStartsWith >= startAlphaEncoded && lnStartsWith <= endAlphaEncoded);

    }

    private static void updateTasks(){

        if (!tasksToUpdate.isEmpty()) {
            List<Database.SaveResult> taskAssignmentUpdateResults = Database.update(Security.stripInaccessible(AccessType.UPDATABLE, tasksToUpdate, true).getRecords(), false);
            LoggingService.logDatabaseResult(taskAssignmentUpdateResults, tasksToUpdate, CLASS_NAME, 'updateTasks', LoggingLevel.ERROR);
        }
    }

    private static void updateRules(){

        if(!rulesToUpdateMap.isEmpty()) {
            List<AQ_WorkAssignmentRule__c> rulesToUpdateList = rulesToUpdateMap.values();
            List<Database.SaveResult> routingRuleUpdateResults = Database.update(Security.stripInaccessible(AccessType.UPDATABLE, rulesToUpdateList, true).getRecords(), false);
            LoggingService.logDatabaseResult(routingRuleUpdateResults, rulesToUpdateList, CLASS_NAME, 'updateRules', LoggingLevel.ERROR);
        }
    }

    private static void updateCustomSetting(DateTime newestDate){
        //Update Custom Setting for TaskBatch query criteria
        // If the last TaskToAssign has a newer CreatedDate than the Custom Setting, Update the Custom Setting

        DateTime compareDateTime = (DateTime)JSON.deserialize('"'+HOURS_BEHIND.TaskBatchStartTime__c+'"', DateTime.class);
        if(newestDate > compareDateTime) {
            HOURS_BEHIND.TaskBatchStartTime__c = newestDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            List<CS_AGENTQUEUE_Config__c> customSettingUpdateList = new List<CS_AGENTQUEUE_Config__c>();
            customSettingUpdateList.add(HOURS_BEHIND);
            List<Database.SaveResult> csUpdateResults = Database.update(Security.stripInaccessible(AccessType.UPDATABLE, customSettingUpdateList, true).getRecords(), false);
            LoggingService.logDatabaseResult(csUpdateResults, customSettingUpdateList, CLASS_NAME, 'updateCustomSettingHoursBack', LoggingLevel.ERROR);
        }
    }

}