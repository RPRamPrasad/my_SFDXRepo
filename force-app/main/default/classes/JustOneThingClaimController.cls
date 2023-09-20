/**
* Author : Team Astro
* Date Created : 08/22/2023
* @description : Retrieves claim parent object data for JOT related to field
* Version : 1.0
*/ 
public with sharing class JustOneThingClaimController {

    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForHouseholdClaims(String householdId) {
        List<Claim> claims = new List<Claim>();
        try{
            String queryToExecute = JOTConstants.CLAIM_FIELDS + JOTConstants.CLAIM_FROM_OBJECT + JOTConstants.FINSERV_HOUSEHOLD_WHERE;
            claims = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return transformClaims(claims);
    }

    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getRecordsForAccountClaims(String accountId) {
        List<Claim> claims = new List<Claim>();
        try{
            String queryToExecute = JOTConstants.CLAIM_FIELDS + JOTConstants.CLAIM_FROM_OBJECT + JOTConstants.ACCOUNT_ID_WHERE;
            claims = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return transformClaims(claims);
    }

    public static List<ActivityOutlineSObjectWrapper> transformClaims(List<Claim> claimList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Claim claimRecord : claimList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = claimRecord.Id;
            soWrapper.status = claimRecord.Status;
            soWrapper.sobjectType = String.valueOf(claimRecord.getSObjectType());

            String claimSubject = claimRecord.ClaimDescription__c;
            if(String.isBlank(claimSubject)) {
                claimSubject = '[No Subject]';
            }
            soWrapper.recordSubject = 'Claim: ' + claimRecord.Name + ' - ' + claimSubject;
            soWrapper.displayIconName = 'standard:partner_fund_claim';
            soWrapper.isClosed = claimRecord.IsClosed;

            if(!soWrapper.isClosed){
                sobjectList.add(soWrapper);
            }
            
        }
        return sobjectList;
    }
}