/**
* Author : Team Astro
* Date Created : 08/22/2023
* @description : Retrieves billing account parent object data for JOT related to field
* Version : 1.0
*/ 
public with sharing class JustOneThingBillingController {

    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdBillingAccounts(String householdId) {
        List<Billing_Account__c> billingAccounts = new List<Billing_Account__c>();
        try{
            String queryToExecute = JOTConstants.BILLING_ACCOUNT_FIELDS + JOTConstants.BILLING_ACCOUNT_FROM_OBJECT + JOTConstants.BILLING_HOUSEHOLD_WHERE;
            billingAccounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return transformBillingAccounts(billingAccounts);
    }

    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForAccountBillingAccounts(String accountId) {
        List<Billing_Account__c> billingAccounts = new List<Billing_Account__c>();
        try{
            String queryToExecute = JOTConstants.BILLING_ACCOUNT_FIELDS + JOTConstants.BILLING_ACCOUNT_FROM_OBJECT + JOTConstants.BILLING_ACCOUNT_WHERE;
            billingAccounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
            
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return transformBillingAccounts(billingAccounts);
    }

    public static List<ActivityOutlineSObjectWrapper> transformBillingAccounts(List<Billing_Account__c> billingAccountList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for (Billing_Account__c billingAccountRecord : billingAccountList) {
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = billingAccountRecord.Id;
            if (billingAccountRecord.SourceSystem__c != null && billingAccountRecord.SourceSystem__c == 'SFPP') {
                soWrapper.recordSubject = 'SFPP Account: ' + billingAccountRecord.Name;
            } else if (billingAccountRecord.SourceSystem__c != null && billingAccountRecord.SourceSystem__c == 'SF Billing') {
                soWrapper.recordSubject = 'SF Billing Account: ' + billingAccountRecord.Name;
            } else {
            	soWrapper.recordSubject = 'Billing Account: ' + billingAccountRecord.Name;
            }
            soWrapper.recordSubject = 'Billing Account: ' + billingAccountRecord.Name;
            soWrapper.status = billingAccountRecord.Status__c;
            soWrapper.displayIconName = 'custom:custom17';
            soWrapper.isClosed = false;

            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }
}