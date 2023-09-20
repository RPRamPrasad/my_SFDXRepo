/**
* Author : Team Astro
* Date Created : 9/20/2022
* @description : Retrieves the financial accounts related to an account or 
* household and the related activities of the financial accounts for display in HHN
* Version : 1.0
*/
public with sharing class HHNFinancialAccountController {
    /**
     * @description - Queries for all financial accounts in the household and the 
     * tasks and events related to those financial accounts. Used on financial 
     * account pages that have a household id
     * @param householdId
     * @param includeArchive
     * @return List<ActivityOutlineSObjectWrapper> - returns a list that contains
     * all record data of the financial accounts and their related tasks and events
     */   
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdFinancialAccounts(String householdId, boolean includeArchive) {
        
        String queryToExecute = HHNConstants.FINANCIAL_ACCOUNT_FIELDS 
                                + ',(' + HHNConstants.TASK_FIELDS + HHNConstants.TASK_FROM_REF_OBJECT + '), (' 
                                + HHNConstants.EVENT_FIELDS + HHNConstants.EVENT_FROM_REF_OBJECT + ')'
                                + HHNConstants.FINANCIAL_ACCOUNT_FROM_OBJECT + HHNConstants.FINSERV_HOUSEHOLD_WHERE;

        if(includeArchive == true) {
            queryToExecute =  queryToExecute + ' AND isDeleted = false ALL ROWS ';
        }

        List<FinServ__FinancialAccount__c> financialAccounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        return HHNUtilities.transformFinancialAccounts(financialAccounts);
    }

    /**
     * @description - Queries for all financial accounts in the 
     * account and the tasks and events related to those financial 
     * accounts. Used on financial account pages that do not have a 
     * household id
     * @param accountId
     * @param includeArchive
     * @return List<ActivityOutlineSObjectWrapper> - returns a list 
     * that contains all record data of the financial accounts and 
     * their related tasks and events
     */   
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForAccountFinancialAccounts(String accountId, boolean includeArchive) {
                         
        String queryToExecute = HHNConstants.FINANCIAL_ACCOUNT_FIELDS 
                                + ',(' + HHNConstants.TASK_FIELDS + HHNConstants.TASK_FROM_REF_OBJECT + '), (' 
                                + HHNConstants.EVENT_FIELDS + HHNConstants.EVENT_FROM_REF_OBJECT + ')'
                                + HHNConstants.FINANCIAL_ACCOUNT_FROM_OBJECT + HHNConstants.FINANCIAL_ACCOUNT_WHERE;

       if(includeArchive == true) {
        queryToExecute =  queryToExecute + ' AND isDeleted = false ALL ROWS ';
        }

        List<FinServ__FinancialAccount__c> financialAccounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        return HHNUtilities.transformFinancialAccounts(financialAccounts);
    }

    //These are the queries used for FinancialAccountRole, they can be introduced if needed.
    //We can not query FinancialAccountRole__c for Tasks or Events which is why they are not included in query.

    // @AuraEnabled(cacheable=false)
    // public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdFinancialAccountRoles(String householdId) {

    //     String queryToExecute = HHNConstants.FINANCIAL_ACCOUNT_ROLE_FIELDS + HHNConstants.FINANCIAL_ACCOUNT_ROLE_FROM_OBJECT + HHNConstants.FINANCIAL_ACCOUNT_ROLE_HOUSEHOLD_WHERE;

    //     List<FinancialAccountRole__c> financialAccounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
    //     if (Test.isRunningTest()) {
    //         financialAccounts = mockedFinancialAccounts;
    //     }
    //     return HHNUtilities.transformFinancialAccounts(financialAccounts);
    // }

    // @AuraEnabled(cacheable=false)
    // public static List<ActivityOutlineSObjectWrapper> getRecordsForAccountFinancialAccountRoles(String accountId) {
        
    //     String queryToExecute = HHNConstants.FINANCIAL_ACCOUNT_ROLE_FIELDS + HHNConstants.FINANCIAL_ACCOUNT_ROLE_FROM_OBJECT + HHNConstants.FINANCIAL_ACCOUNT_ROLE_WHERE;
                                                                
    //     List<FinancialAccountRole__c> financialAccounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
    //     if (Test.isRunningTest()) {
    //         financialAccounts = mockedFinancialAccounts;
    //     }
    //     return HHNUtilities.transformFinancialAccounts(financialAccounts);
    // }
}