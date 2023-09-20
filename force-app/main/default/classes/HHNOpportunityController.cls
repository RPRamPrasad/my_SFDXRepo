/**
* Author : Team Astro
* Date Created : 06/01/2022
* @description : retrieves account and household data for AO
* Version : 1.0
*/
public with sharing class HHNOpportunityController {

    /**
     * @description - Queries for all opportunities in the household and the tasks and events related to those opportunities. Used on opportunity pages that have a household id
     * @param householdId
     * @param includeArchive
     * @return List<ActivityOutlineSObjectWrapper> - returns a list that contains all record data of the opportunities and their related tasks and events
     */
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdOpportunities(String householdId, boolean includeArchive) {

        String queryToExecute = HHNConstants.OPPORTUNITY_FIELDS
                                + ',(' + HHNConstants.TASK_FIELDS + HHNConstants.TASK_FROM_REF_OBJECT + HHNConstants.TASK_WHERE + '), ('
                                + HHNConstants.EVENT_FIELDS + HHNConstants.EVENT_FROM_REF_OBJECT + '), ('
                                + HHNConstants.OPPORTUNITY_NOTE_FIELDS + HHNConstants.OPPORTUNITY_NOTE_FROM_REF_OBJECT + ')'
                                + HHNConstants.OPPORTUNITY_FROM_OBJECT + HHNConstants.FINSERV_HOUSEHOLD_WHERE;

        if(includeArchive == true) {
            queryToExecute =  queryToExecute + ' AND isDeleted = false ALL ROWS ';
        }

        List<Opportunity> opportunities = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        return HHNUtilities.transformOpportunities(opportunities);
    }

    /**
     * @description - Queries for all opportunities in the account and the tasks and events related to those opportunities. Used on opportunity pages that do not have a household id
     * @param accountId
     * @param includeArchive
     * @return List<ActivityOutlineSObjectWrapper> - returns a list that contains all record data of the opportunities and their related tasks and events
     */
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForAccountOpportunities(String accountId, boolean includeArchive) {

        String queryToExecute = HHNConstants.OPPORTUNITY_FIELDS
                                + ',(' + HHNConstants.TASK_FIELDS + HHNConstants.TASK_FROM_REF_OBJECT + HHNConstants.TASK_WHERE + '), ('
                                + HHNConstants.EVENT_FIELDS + HHNConstants.EVENT_FROM_REF_OBJECT + '), ('
                                + HHNConstants.OPPORTUNITY_NOTE_FIELDS + HHNConstants.OPPORTUNITY_NOTE_FROM_REF_OBJECT + ')'
                                + HHNConstants.OPPORTUNITY_FROM_OBJECT + HHNConstants.ACCOUNT_ID_WHERE;

        if(includeArchive == true) {
            queryToExecute =  queryToExecute + ' AND isDeleted = false ALL ROWS ';
        }

        List<Opportunity> opportunities = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        return HHNUtilities.transformOpportunities(opportunities);
    }
}