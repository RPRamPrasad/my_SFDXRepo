/**
* Author : Team Astro
* Date Created : 08/22/2023
* @description : Retrieves opportunity parent object data for JOT related to field
* Version : 1.0
*/ 
public with sharing class JustOneThingOpportunityController {

    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdOpportunities(String householdId) {
        List<Opportunity> opportunities = new List<Opportunity>();
        try{
            String queryToExecute = JOTConstants.OPPORTUNITY_FIELDS + JOTConstants.OPPORTUNITY_FROM_OBJECT + JOTConstants.FINSERV_HOUSEHOLD_WHERE;
            opportunities = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return transformOpportunities(opportunities);
    }

    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForAccountOpportunities(String accountId) {
        List<Opportunity> opportunities = new List<Opportunity>();
        try{
            String queryToExecute = JOTConstants.OPPORTUNITY_FIELDS + JOTConstants.OPPORTUNITY_FROM_OBJECT + JOTConstants.ACCOUNT_ID_WHERE;
            opportunities = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return transformOpportunities(opportunities);
    }

    public static List<ActivityOutlineSObjectWrapper> transformOpportunities(List<Opportunity> opportunityList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Opportunity oppRecord : opportunityList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = oppRecord.Id;
            soWrapper.status = oppRecord.Status__c;
            soWrapper.sobjectType = String.valueOf(oppRecord.getSObjectType());
            soWrapper.recordSubject = oppRecord.Name;
            soWrapper.displayIconName = 'standard:opportunity';
            soWrapper.isClosed = oppRecord.IsClosed;

            if(!soWrapper.isClosed){
                sobjectList.add(soWrapper);
            }
            
        }
        return sobjectList;
    }
}