/**
* Author : Team Astro
* Date Created : 7/11/2022
* @description : Retrieves the claims related to an account or household and the related activities of the claims for display in HHN
* Version : 1.0
*/
public with sharing class HHNClaimController {

    /**
     * @description - Queries for all claims in the household and the tasks and events related to those claims. Used on claim pages that have a household id
     * @param householdId
     * @param includeArchive
     * @return List<ActivityOutlineSObjectWrapper> - returns a list that contains all record data of the claim and their related tasks and events
     */
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdClaims(String householdId, boolean includeArchive) {

        String queryToExecute = HHNConstants.CLAIM_FIELDS
                                + ',(' + HHNConstants.TASK_FIELDS + HHNConstants.TASK_FROM_REF_OBJECT + HHNConstants.TASK_WHERE + '), ('
                                + HHNConstants.EVENT_FIELDS + HHNConstants.EVENT_FROM_REF_OBJECT + ')'
                                + HHNConstants.CLAIM_FROM_OBJECT + HHNConstants.FINSERV_HOUSEHOLD_WHERE;

        if(includeArchive == true) {
            queryToExecute =  queryToExecute + ' AND isDeleted = false ALL ROWS ';
        }

        List<Claim> claims = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        return HHNUtilities.transformClaims(claims);
    }

    /**
     * @description - Queries for all claims in the account and the tasks and events related to those claims. Used on claim pages that do not have a household id
     * @param accountId
     * @param includeArchive
     * @return List<ActivityOutlineSObjectWrapper> - returns a list that contains all record data of the claim and their related tasks and events
     */
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForAccountClaims(String accountId, boolean includeArchive) {

        String queryToExecute = HHNConstants.CLAIM_FIELDS
                                + ',(' + HHNConstants.TASK_FIELDS + HHNConstants.TASK_FROM_REF_OBJECT + HHNConstants.TASK_WHERE + '), ('
                                + HHNConstants.EVENT_FIELDS + HHNConstants.EVENT_FROM_REF_OBJECT + ')'
                                + HHNConstants.CLAIM_FROM_OBJECT + HHNConstants.ACCOUNT_ID_WHERE;

        if(includeArchive == true) {
            queryToExecute =  queryToExecute + ' AND isDeleted = false ALL ROWS ';
        }

        List<Claim> claims = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        return HHNUtilities.transformClaims(claims);
    }
}