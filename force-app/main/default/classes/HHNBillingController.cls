/**
* Author : Team Astro
* Date Created : 8/22/2022
* @description : Retrieves the billing accounts related to an account or household and the related activities of the billing accounts for display in HHN
* Version : 1.0
*/
public with sharing class HHNBillingController {

    /**
     * @description - Queries for all billing accounts in the household and the tasks and events related to those billing accounts. Used on billing account pages that have a household id
     * @param householdId
     * @param includeArchive
     * @return List<ActivityOutlineSObjectWrapper> - returns a list that contains all record data of the billing account and their related tasks and events
     */
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdBillingAccounts(String householdId, boolean includeArchive) {

        String queryToExecute = HHNConstants.BILLING_ACCOUNT_FIELDS
                                + ',(' + HHNConstants.TASK_FIELDS + HHNConstants.TASK_FROM_REF_OBJECT + HHNConstants.TASK_WHERE + '), ('
                                + HHNConstants.EVENT_FIELDS + HHNConstants.EVENT_FROM_REF_OBJECT + ')'
                                + HHNConstants.BILLING_ACCOUNT_FROM_OBJECT + HHNConstants.BILLING_HOUSEHOLD_WHERE;

        if(includeArchive == true) {
            queryToExecute =  queryToExecute + ' AND isDeleted = false ALL ROWS ';
        }

        List<Billing_Account__c> billingAccounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        return HHNUtilities.transformBillingAccounts(billingAccounts);
    }

    /**
     * @description - Queries for all billing accounts in the account and the tasks and events related to those billing accounts. Used on billing account pages that do not have a household id
     * @param accountId
     * @param includeArchive
     * @return List<ActivityOutlineSObjectWrapper> - returns a list that contains all record data of the billing account and their related tasks and events
     */
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForAccountBillingAccounts(String accountId, boolean includeArchive) {

        String queryToExecute = HHNConstants.BILLING_ACCOUNT_FIELDS
                                + ',(' + HHNConstants.TASK_FIELDS + HHNConstants.TASK_FROM_REF_OBJECT + HHNConstants.TASK_WHERE + '), ('
                                + HHNConstants.EVENT_FIELDS + HHNConstants.EVENT_FROM_REF_OBJECT + ')'
                                + HHNConstants.BILLING_ACCOUNT_FROM_OBJECT + HHNConstants.BILLING_ACCOUNT_WHERE;

        if(includeArchive == true) {
            queryToExecute =  queryToExecute + ' AND isDeleted = false ALL ROWS ';
        }

        List<Billing_Account__c> billingAccounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        return HHNUtilities.transformBillingAccounts(billingAccounts);
    }
}