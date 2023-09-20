/**
* Author : Team Astro
* Date Created : 08/22/2023
* @description : Retrieves case parent object data for JOT related to field
* Version : 1.0
*/ 
public with sharing class JustOneThingCaseController {

    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdCases(String householdId) {
        List<Case> cases = new List<Case>();
        try{
            String queryToExecute = JOTConstants.CASE_FIELDS + JOTConstants.CASE_FROM_OBJECT + JOTConstants.FINSERV_HOUSEHOLD_WHERE;
            cases = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return transformCases(cases);
    }
 
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForAccountCases(String accountId) {
        List<Case> cases = new List<Case>();
        try{
            String queryToExecute = JOTConstants.CASE_FIELDS + JOTConstants.CASE_FROM_OBJECT + JOTConstants.ACCOUNT_ID_WHERE;
            cases = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return transformCases(cases);
    }

    public static List<ActivityOutlineSObjectWrapper> transformCases(List<Case> caseList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Case caseRecord : caseList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = caseRecord.Id;
            soWrapper.status = caseRecord.Status;
            soWrapper.sobjectType = String.valueOf(caseRecord.getSObjectType());
            String caseMapSubject = caseRecord.Subject;
            if(String.isBlank(caseMapSubject)) {
                caseMapSubject = '[No Subject]';
            }
            soWrapper.recordSubject = caseRecord.CaseNumber + ' - ' + caseMapSubject;
            soWrapper.displayIconName = 'standard:case';
            soWrapper.isClosed = caseRecord.IsClosed;

            if(!soWrapper.isClosed){
                sobjectList.add(soWrapper);
            }
            
        }
        return sobjectList;
    }
}