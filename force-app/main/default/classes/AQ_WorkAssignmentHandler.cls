/**
  * @name AQ_WorkAssignmentHandler
  * @author Team Skynet
  * @createdDate 2/9/2023
  * @description  This class will handle Assignment logic for SObjects using Work Assignment Rules
*/
public with sharing class AQ_WorkAssignmentHandler {
    private static AQ_WorkAssignmentHandlerWrapper workassignmentwrap = new AQ_WorkAssignmentHandlerWrapper();
    private static Map<Id, AQ_WorkAssignmentRule__c> rulesToUpdateMap = new Map<Id, AQ_WorkAssignmentRule__c>();
    private static final String CLASS_NAME = 'AQ_WorkAssignmentHandler';

    private AQ_WorkAssignmentHandler(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('AQ_WorkAssignmentHandler', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }

     /**
    * @name: assignWorkToUsers
    * @description Method to assign Users to Unassigned Work.
    * @param workToAssign List of SObjects to assign
    * @return List of SObjects
    */
    public static List<SObject> assignWorkToUsers(List<SObject> workToAssign) {

        Set<Id> objectOwnerIdList = new Set<Id>();
        Map<Id, Set<AQ_WorkAssignmentRule__c>> ownerIdToRulesMap = new Map<Id, Set<AQ_WorkAssignmentRule__c>>();


        // Iterate the objects and get the type of object and get the object ids
        workassignmentwrap.assignWorkToUser(workToAssign,objectOwnerIdList);

        List<AQ_WorkAssignmentRule__c> workAssignmentRuleList = Security.stripInaccessible(AccessType.READABLE,
                                                            [SELECT Id, EndAlpha__c, LOB_Stored__c, StartAlpha__c,
                                                                Task_Subject__c, User__c, User__r.Name, LastAssignedDateTime__c, OwnerId, Marketing_Source__c, Marketing_Source_Stored__c,
                                                                Opportunity_Originator__c, Opp_Originator_Stored__c
                                                            FROM AQ_WorkAssignmentRule__c
                                                            WHERE OwnerId IN :objectOwnerIdList
                                                            AND User__r.IsActive = true AND User__r.FederationIdentifier != ''
                                                            WITH SECURITY_ENFORCED
                                                            ORDER BY LastAssignedDateTime__c ASC]).getRecords();

        ownerIdToRulesMap = populateOwnerIdToRulesMap(workAssignmentRuleList);

        return assignWork(workToAssign, ownerIdToRulesMap);
    }

    private static Map<Id, Set<AQ_WorkAssignmentRule__c>> populateOwnerIdToRulesMap(List<AQ_WorkAssignmentRule__c> workAssignmentRuleList){

       return workassignmentwrap.populateOwnerIdToRuleMap(workAssignmentRuleList);
    }


    private static List<SObject> assignWork(List<SObject> workToAssign, Map<Id, Set<AQ_WorkAssignmentRule__c>> ownerIdToRulesMap) {

        return workassignmentwrap.assignWork(workToAssign,ownerIdToRulesMap);
     }

     private static SObject assignWorkUpdateOpportunity(SObject record, Map<Id, Set<AQ_WorkAssignmentRule__c>> ownerIdToRulesMap){
        return workassignmentwrap.assignWorkUpdateOpportunity(record,ownerIdToRulesMap);
    }

    private static Opportunity assignUsingRulesOpportunity(Opportunity opportunityToAssign, Set<AQ_WorkAssignmentRule__c> assignmentRules) {

        AQ_WorkAssignmentRule__c ruleToUse;
        DateTime oldestAssignedDateTime;
        Opportunity opportunityToUpdate = new Opportunity();

        for(AQ_WorkAssignmentRule__c assignmentRule : assignmentRules){
            if(isRuleEligibleOpportunity(opportunityToAssign, assignmentRule)){

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

            opportunityToUpdate.Id = opportunityToAssign.Id;
            opportunityToUpdate.Assigned_To__c = ruleToUse.User__c;
        }

        return opportunityToUpdate;
    }
     private static SObject assignWorkUpdateLead(SObject record, Map<Id, Set<AQ_WorkAssignmentRule__c>> ownerIdToRulesMap){
        return workassignmentwrap.assignWorkUpdateLead(record,ownerIdToRulesMap);

    }
     private static Lead assignUsingRulesLead(Lead leadToAssign, Set<AQ_WorkAssignmentRule__c> assignmentRules) {

        AQ_WorkAssignmentRule__c ruleToUse;
        DateTime oldestAssignedDateTime;
        Lead leadToUpdate = new Lead();

        for(AQ_WorkAssignmentRule__c assignmentRule : assignmentRules){
            if(isRuleEligibleLead(leadToAssign, assignmentRule)){

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

            leadToUpdate.Id = leadToAssign.Id;
            leadToUpdate.AssignedTo__c = ruleToUse.User__c;
        }

        return leadToUpdate;
    }

    private static Task assignUsingRulesTask(Task taskToAssign, Set<AQ_WorkAssignmentRule__c> assignmentRules) {

        AQ_WorkAssignmentRule__c ruleToUse;
        DateTime oldestAssignedDateTime;
        Task taskToUpdate = new Task();

        for(AQ_WorkAssignmentRule__c assignmentRule : assignmentRules){
            if(isRuleEligibleTask(taskToAssign, assignmentRule)){

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

            taskToUpdate.Id = taskToAssign.Id;
            taskToUpdate.AssignedTo__c = ruleToUse.User__c;
        }

        return taskToUpdate;
    }

    private static boolean isRuleEligibleTask(Task taskToAssign, AQ_WorkAssignmentRule__c assignmentRule){
        return isRuleNotBlank(assignmentRule)
                && isCriteriaMatched(assignmentRule.Task_Subject__c, taskToAssign.Subject)
                && isCriteriaMatched(assignmentRule.LOB_Stored__c, taskToAssign.LineofBusiness__c)
                && isLastNameMatched(taskToAssign.Account.LastName, assignmentRule.StartAlpha__c, assignmentRule.EndAlpha__c);
    }

    private static boolean isRuleEligibleLead(Lead leadToAssign, AQ_WorkAssignmentRule__c assignmentRule){
        return isRuleNotBlank(assignmentRule)
                && isLastNameMatched(leadToAssign.LastName, assignmentRule.StartAlpha__c, assignmentRule.EndAlpha__c);
    }

    private static boolean isRuleEligibleOpportunity(Opportunity opportunityToAssign, AQ_WorkAssignmentRule__c assignmentRule){
        return isRuleNotBlank(assignmentRule)
                && isCriteriaMatched(assignmentRule.LOB_Stored__c, opportunityToAssign.LOB__c)
                && isCriteriaMatched(assignmentRule.Marketing_Source_Stored__c, opportunityToAssign.Marketing_Source__c)
                && isCriteriaMatched(assignmentRule.Opp_Originator_Stored__c, opportunityToAssign.Marketing_Sub_Source__c)
                && isLastNameMatched(opportunityToAssign.Account.LastName, assignmentRule.StartAlpha__c, assignmentRule.EndAlpha__c);

    }


    // Add the additional Sales criteria fields
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

    private static void updateRules(){

        if(!rulesToUpdateMap.isEmpty()) {
            List<AQ_WorkAssignmentRule__c> rulesToUpdateList = rulesToUpdateMap.values();
            List<Database.SaveResult> routingRuleUpdateResults = Database.update(Security.stripInaccessible(AccessType.UPDATABLE, rulesToUpdateList, true).getRecords(), false);
            LoggingService.logDatabaseResult(routingRuleUpdateResults, rulesToUpdateList, CLASS_NAME, 'updateRules', LoggingLevel.ERROR);
        }
    }

    private class AQ_WorkAssignmentHandlerWrapper{

        private Map<Id, Set<AQ_WorkAssignmentRule__c>> populateOwnerIdToRuleMap(List<AQ_WorkAssignmentRule__c> workAssignmentRuleList){
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

        private List<SObject> assignWork(List<SObject> workToAssign, Map<Id, Set<AQ_WorkAssignmentRule__c>> ownerIdToRulesMap){
            // Using Schema interface methods to identify the type of object passed in
            // Ensure that we are updating the same object list regardless of processing
            // Return List of SObjects to the caller
            List<SObject> workUpdated = new List<SObject>();
            Task taskAssigned = new Task();
            for (SObject record : workToAssign) {
                 Schema.SObjectType sObjectType = record.getSObjectType();
                 if (sObjectType == Task.getSObjectType()) {
                     Task taskToAssign = (Task) record;
                     try {
                         if (ownerIdToRulesMap.get(taskToAssign.OwnerId) != null) {
                             taskAssigned = assignUsingRulesTask(taskToAssign,ownerIdToRulesMap.get(taskToAssign.OwnerId));
                         }
                         workUpdated.add(taskAssigned);
                     } catch (Exception ex) {
                         LoggingService.logHandledException(ex, CLASS_NAME, 'assignWork', LoggingLevel.ERROR);
                         workUpdated.add(record);
                     }
                 }

                 else if(sObjectType == Opportunity.getSObjectType()) {
                    workUpdated.add(assignWorkUpdateOpportunity(record,ownerIdToRulesMap));
                }
                 else {
                    workUpdated.add(assignWorkUpdateLead(record, ownerIdToRulesMap));
                }
            }

            updateRules();
            return workUpdated;
        }

        private SObject assignWorkUpdateOpportunity(SObject record, Map<Id, Set<AQ_WorkAssignmentRule__c>> ownerIdToRulesMap){
            Schema.SObjectType sObjectType = record.getSObjectType();
                Opportunity oppAssigned = new Opportunity();
                if (sObjectType == Opportunity.getSObjectType()) {
                Opportunity oppToAssign = (Opportunity) record;
                        try {
                            if (ownerIdToRulesMap.get(oppToAssign.OwnerId) != null) {
                                oppAssigned = assignUsingRulesOpportunity(oppToAssign,ownerIdToRulesMap.get(oppToAssign.OwnerId));
                            }
                            return oppAssigned;
                        } catch (Exception ex) {
                            LoggingService.logHandledException(ex, CLASS_NAME, 'assignWork', LoggingLevel.ERROR);
                            return record;
                        }
                }
                    return record;
        }

        private SObject assignWorkUpdateLead(SObject record, Map<Id, Set<AQ_WorkAssignmentRule__c>> ownerIdToRulesMap){
            Schema.SObjectType sObjectType = record.getSObjectType();
                Lead leadAssigned = new Lead();
                if (sObjectType == Lead.getSObjectType()) {
                Lead leadToAssign = (Lead) record;
                        try {
                            if (ownerIdToRulesMap.get(leadToAssign.OwnerId) != null) {
                                leadAssigned = assignUsingRulesLead(leadToAssign,ownerIdToRulesMap.get(leadToAssign.OwnerId));
                            }
                            return leadAssigned;
                        } catch (Exception ex) {
                            LoggingService.logHandledException(ex, CLASS_NAME, 'assignWork', LoggingLevel.ERROR);
                            return record;
                        }

                }
                    return record;
        }

        private void assignWorkToUser(List<SObject> workToAssign,Set<Id> objectOwnerIdList){
            for (SObject record : workToAssign) {
                Schema.SObjectType sObjectType = record.getSObjectType();
                if (sObjectType == Task.getSObjectType()) {
                    Task taskToAssign = (Task) record;
                    objectOwnerIdList.add(taskToAssign.OwnerId);
                } else if(sObjectType == Opportunity.getSObjectType()) {
                    Opportunity opportunityToAssign = (Opportunity) record;
                    objectOwnerIdList.add(opportunityToAssign.OwnerId);
                } else if (sObjectType == Lead.getSObjectType()) {
                    Lead leadToAssign = (Lead) record;
                    objectOwnerIdList.add(leadToAssign.OwnerId);
                }
            }
        }

    }

}