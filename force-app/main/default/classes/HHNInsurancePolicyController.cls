/**
* Author : Team Astro
* Date Created : 8/04/2022
* @description : Retrieves the insurance policies related to an account or household and the related activities of the insurance policies for display in HHN
* Version : 1.0
*/
public with sharing class HHNInsurancePolicyController {

    /**
     * @description - Queries for all insurance policies in the household and the tasks and events related to those insurance policies. Used on insurance policy pages that have a household id
     * @param householdId
     * @param includeArchive
     * @return List<ActivityOutlineSObjectWrapper> - returns a list that contains all record data of the insurance policies and their related tasks and events
     */
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdInsurancePolicies(String householdId, boolean includeArchive) {

        String queryToExecute = HHNConstants.INSURANCE_POLICY_FIELDS
                                + ',(' + HHNConstants.TASK_FIELDS + HHNConstants.TASK_FROM_REF_OBJECT + HHNConstants.TASK_WHERE + '), ('
                                + HHNConstants.EVENT_FIELDS + HHNConstants.EVENT_FROM_REF_OBJECT + ')'
                                + HHNConstants.INSURANCE_POLICY_FROM_OBJECT + HHNConstants.FINSERV_HOUSEHOLD_WHERE;

        if(includeArchive == true) {
            queryToExecute =  queryToExecute + ' AND isDeleted = false ALL ROWS ';
        }

        List<InsurancePolicy> policies = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        return HHNUtilities.transformInsurancePolicies(policies);
    }

    /**
     * @description - Queries for all insurance policies in the account and the tasks and events related to those insurance policies. Used on insurance policy pages that do not have a household id
     * @param accountId
     * @param includeArchive
     * @return List<ActivityOutlineSObjectWrapper> - returns a list that contains all record data of the insurance policies and their related tasks and events
     */
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForAccountInsurancePolicies(String accountId, boolean includeArchive) {

        String queryToExecute = HHNConstants.INSURANCE_POLICY_FIELDS
                                + ',(' + HHNConstants.TASK_FIELDS + HHNConstants.TASK_FROM_REF_OBJECT + HHNConstants.TASK_WHERE + '), ('
                                + HHNConstants.EVENT_FIELDS + HHNConstants.EVENT_FROM_REF_OBJECT + ')'
                                + HHNConstants.INSURANCE_POLICY_FROM_OBJECT + HHNConstants.NAMED_INSURED_WHERE;

        if(includeArchive == true) {
            queryToExecute =  queryToExecute + ' AND isDeleted = false ALL ROWS ';
        }

        List<InsurancePolicy> policies = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        return HHNUtilities.transformInsurancePolicies(policies);
    }
}