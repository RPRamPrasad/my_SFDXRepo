/**
* Author : Team Astro
* Date Created : 08/22/2023
* @description : Retrieves account parent object data for JOT related to field
* Version : 1.0
*/ 
public with sharing class JustOneThingAccountController {

    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdAccounts(String householdId) {
        List<Account> accounts = new List<Account>();

        try{
            String queryToExecute = JOTConstants.ACCOUNT_FIELDS + JOTConstants.ACCOUNT_FROM_OBJECT + JOTConstants.PRIMARY_HOUSEHOLD_WHERE; 
            accounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return transformAccounts(accounts);
    }

    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForAccount(String accountId) {
        List<Account> accounts = new List<Account>();
        
        try{
            String queryToExecute = JOTConstants.ACCOUNT_FIELDS + JOTConstants.ACCOUNT_FROM_OBJECT + JOTConstants.ACCOUNT_WHERE;
            accounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return transformAccounts(accounts);
    }

    public static List<ActivityOutlineSObjectWrapper> transformAccounts(List<Account> accountList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Account accountRecord : accountList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = accountRecord.Id;
            soWrapper.recordSubject = accountRecord.Name;
            soWrapper.displayIconName = 'standard:person_account';

            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }
}