/**
* Author : Team Astro
* Date Created : 06/01/2022
* @description : retrieves account and household data for activity outline 2.0
* Version : 1.0
*/ 
public with sharing class HHNAccountController {

    /**
     * @description - Queries for all accounts in the household and the 
     * tasks, events, interactions, and virtual meetings related to 
     * those accounts. Used on account pages that have a household id 
     * and household pages
     * @param householdId
     * @param includeArchive
     * @return List<ActivityOutlineSObjectWrapper> - returns a list 
     * that contains all record data of the account and their related
     *  tasks, events, interactions, and virtual meetings
     */   
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdAccounts(String householdId, boolean includeArchive) {
        
        String queryToExecute = HHNConstants.ACCOUNT_FIELDS 
                                + ',(' + HHNConstants.ACCOUNT_NOTE_FIELDS + HHNConstants.ACCOUNT_NOTE_FROM_REF_OBJECT + '), ('
                                + HHNConstants.INTERACTIONS_FIELDS + HHNConstants.INTERACTIONS_FROM_REF_OBJECT + '), ('
                                + HHNConstants.VIRTUAL_MEETING_P_FIELDS + HHNConstants.VIRTUAL_MEETING_P_FROM_REF_OBJECT + ')'
                                + HHNConstants.ACCOUNT_FROM_OBJECT + HHNConstants.PRIMARY_HOUSEHOLD_WHERE;
        
        if(includeArchive == true) {
            queryToExecute =  queryToExecute + ' AND isDeleted = false ALL ROWS ';
        }

        List<Account> accounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        List<Event> events = HHNUtilities.getEventsForHouseholdAccounts(householdId, includeArchive);
        List<Task> tasks = HHNUtilities.getTasksForHouseholdAccounts(householdId, includeArchive);

        Map<String, List<Event>> accountEvents = HHNUtilities.addEventsToAccounts(accounts, events);
        Map<String, List<Task>> accountTasks = HHNUtilities.addTasksToAccounts(accounts, tasks);

        return HHNUtilities.transformAccounts(accounts, accountEvents, accountTasks);
    }

    /**
     * @description - Queries for an account and the tasks and
     * events related to the account. Used on account pages 
     * that do not have a household id
     * @param accountId
     * @param includeArchive
     * @return List<ActivityOutlineSObjectWrapper> - returns a 
     * list that contains all record data of the account and their related tasks and events
     */   
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForAccount(String accountId, boolean includeArchive) {
        
        String queryToExecute = HHNConstants.ACCOUNT_FIELDS 
                                + ',(' + HHNConstants.ACCOUNT_NOTE_FIELDS + HHNConstants.ACCOUNT_NOTE_FROM_REF_OBJECT + '), ('
                                + HHNConstants.INTERACTIONS_FIELDS + HHNConstants.INTERACTIONS_FROM_REF_OBJECT + '), ('
                                + HHNConstants.VIRTUAL_MEETING_P_FIELDS + HHNConstants.VIRTUAL_MEETING_P_FROM_REF_OBJECT + ')'
                                + HHNConstants.ACCOUNT_FROM_OBJECT + HHNConstants.ACCOUNT_WHERE;

        List<Account> accounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
       
        List<Event> events = HHNUtilities.getEventsForAccount(accountId, includeArchive);
        List<Task> tasks = HHNUtilities.getTasksForAccount(accountId, includeArchive);

        Map<String, List<Event>> accountEvents = HHNUtilities.addEventsToAccounts(accounts, events);
        Map<String, List<Task>> accountTasks = HHNUtilities.addTasksToAccounts(accounts, tasks);

        return HHNUtilities.transformAccounts(accounts, accountEvents, accountTasks);
    }
}