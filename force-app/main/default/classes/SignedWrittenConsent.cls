/**
Author Team ClubCar
Name - SignedWrittenConsent
@description - This class will process Signed Written Consent Granted records.
    will update Opportunity and Create Tasks accordingly.
===========================================================================================
VERSION         AUTHOR                      DATE                    DETAIL
1.0            Team ClubCar                10/20/2020              Initial Development
*******************************************************************************************/
public with sharing class SignedWrittenConsent {

    private static map<Id, Opportunity> swcIdToOpportunityMap = new map<Id, Opportunity>();
    private static final String CLASS_NAME = 'SignedWrittenConsent';
    private static final String METHOD_NAME = 'processSwcUpdatedRecords';
    private static final String STATUS_GRANTED = 'Granted';
    private static final String STATUS_NORESPONSE = 'No Response';
    private static final String STATUS_REQUESTED = 'Requested';
    private static final String STATUS_GRANTEDAFTEROPPORTUNITY = 'Granted - After New Opportunity';

    /**
    * @description - Entry method for SignedWrittenConsent Class
    * @param signedWrittenConsentUpdatedRecords - List of SignedWrittenConsent records passed by update Trigger   
    * @param beforeUpdateSwcRecordMap - map 
    **/
    public static void processSwcUpdatedRecords(List<SignedWrittenConsent__c> signedWrittenConsentUpdatedRecords, map<Id, SignedWrittenConsent__c> beforeUpdateSwcRecordMap) {
        try {
            List<SignedWrittenConsent__c> swcGrantedList = extractSwcGrantedRecords(signedWrittenConsentUpdatedRecords, beforeUpdateSwcRecordMap);
            if(!swcGrantedList.isEmpty()) {
                updateStatusAndProcessNextSteps(swcGrantedList);
            }
        } catch (Exception swcUpdateException) {
            LoggingService.logHandledException(swcUpdateException, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);
            }
    }

    //helper method to extract related data from SignedWrittenConsent records
    private static List<SignedWrittenConsent__c> extractSwcGrantedRecords(List<SignedWrittenConsent__c> signedWrittenConsentUpdatedRecords, map<Id, SignedWrittenConsent__c> beforeUpdateSwcRecordMap) {
        List<SignedWrittenConsent__c> swcGrantedList = new List<SignedWrittenConsent__c>();
        Set<String> opportunityIdSet = new Set<String> ();
        map<Id, Opportunity> oppIdToOpportunityMap = new map<Id, Opportunity>();
        for (SignedWrittenConsent__c swcRecord : signedWrittenConsentUpdatedRecords) {
            String swcStatusBeforeUpdate = beforeUpdateSwcRecordMap.get(swcRecord.Id).Status__c;
            if (swcRecord.Status__c.equals(STATUS_GRANTED)) {
                if(swcStatusBeforeUpdate.equals(STATUS_REQUESTED)) {
                    swcGrantedList.add(swcRecord);
                    opportunityIdSet.add(swcRecord.InitiatedFromId__c);  
                } else {
                    swcRecord.Status__c = swcStatusBeforeUpdate;
                }
            }
        }        
        for (Opportunity swcOpp : [Select id, Assigned_To__c, AccountId, OwnerId,OppSignedWrittenConsentStatus__c
                                                                from Opportunity where Id IN:opportunityIdSet WITH SECURITY_ENFORCED]){
            oppIdToOpportunityMap.put(swcOpp.Id,swcOpp);
        }
        for (SignedWrittenConsent__c swcGrantedRecord : swcGrantedList) {        
            swcIdToOpportunityMap.put(swcGrantedRecord.Id, oppIdToOpportunityMap.get(swcGrantedRecord.InitiatedFromId__c));
        }
        return swcGrantedList;
    }


    // helper method to update SWC record status and call helper methods for further processing
    private static void updateStatusAndProcessNextSteps (List <SignedWrittenConsent__c> swcGrantedList) {
        Set<Id> swcAccountIdSet = new Set<Id>();
        Set<Id> opportunityOwnerIdSet = new Set<Id>();
        Set<SignedWrittenConsent__c> swcSetforOppUpdate = new Set<SignedWrittenConsent__c>();

        for (SignedWrittenConsent__c swcRecord : swcGrantedList){
            Opportunity swcOpportunity = swcIdToOpportunityMap.get(swcRecord.Id);
            // This check can be removed after batch is implemented
            if (String.isEmpty(swcOpportunity.OppSignedWrittenConsentStatus__c)){
                swcRecord.Status__c = STATUS_GRANTEDAFTEROPPORTUNITY;
            } else {
                swcAccountIdSet.add(swcOpportunity.AccountId);
                OpportunityOwnerIdSet.add(swcOpportunity.OwnerId);
                swcSetforOppUpdate.add(swcRecord);
            }
        }
        if(!(swcAccountIdSet.isEmpty() && opportunityOwnerIdSet.isEmpty())) {
            updateOpportunitySWCfields(swcSetforOppUpdate, queryOppForSameAccountAndOffice(swcAccountIdSet, opportunityOwnerIdSet));
        }
    }

    //helper method to query Opportunities under same Account and Agent Office
    private static map<Id, List<Opportunity>> queryOppForSameAccountAndOffice (Set<Id> accountIds, Set<Id> oppOwnerIds) {
        map<Id, List<Opportunity>> accountIdToOppListMap = new map<Id, List<Opportunity>>();
        for(Account swcAccount : [Select Id, (Select id,  OppSignedWrittenConsentGrantedDate__c from Opportunities where OwnerId IN: oppOwnerIds)
                                                        from Account where Id IN: accountIds WITH SECURITY_ENFORCED]){
        accountIdToOppListMap.put(swcAccount.Id,swcAccount.Opportunities);
        }
        return accountIdToOppListMap;
    }

    // helper method to build Task Record based on Account and Opportunity Details
    private static void updateOpportunitySWCfields(Set<SignedWrittenConsent__c> swcGrantedSet, map<Id, List<Opportunity>> accountIdToOppListMap) {
        List<Opportunity> oppListToUpdate = new List<Opportunity> ();
        List<Task> taskListToInsert = new List<Task> ();

        for (SignedWrittenConsent__c swcGrantedRecord : swcGrantedSet) {
            Date swcStartDate = swcGrantedRecord.RequestStartDate__c;
            for (Opportunity oppForUpdate : accountIdToOppListMap.get(swcGrantedRecord.Account__c)) {
                oppListToUpdate.add(updateSwcGrantedOnOpportunity(oppForUpdate, swcStartDate));
            }
            taskListToInsert.add(createSwcTaskOnOpportunity(swcIdToOpportunityMap.get(swcGrantedRecord.Id), swcStartDate));
        }

        if(!oppListToUpdate.isEmpty() && Schema.sObjectType.Opportunity.isUpdateable()) {
            update oppListToUpdate;
        }
        if(!taskListToInsert.isEmpty() && Schema.sObjectType.Task.isCreateable()) {
            insert taskListToInsert;
        }
    }

    // helper method to update SWC information on Opportunity
    private static Opportunity updateSwcGrantedOnOpportunity(Opportunity oppRecord, Date swcStartDate){
        if(oppRecord.OppSignedWrittenConsentGrantedDate__c != null){
            oppRecord.DateCaptured__c = oppRecord.OppSignedWrittenConsentGrantedDate__c;             
        }
        oppRecord.OppSignedWrittenConsentStatus__c = STATUS_GRANTED;
        oppRecord.OppSignedWrittenConsentGrantedDate__c = swcStartDate;
        return oppRecord;
    }

    // helper method to build Task Record based on Account and Opportunity Details
    private static Task createSwcTaskOnOpportunity(Opportunity swcOpportunity, Date swcStartDate) {
        String taskDescription = 'Beginning this due date, consent has been provided to continue marketing efforts.Depending on the state, this can be a 30 day window or a 90 day window that you are able to market to the prospect';
        Task swcTask = new Task();
        swcTask.Subject = 'Signed Written Consent Granted';
        swcTask.Description = taskDescription;
        swcTask.WhatId = swcOpportunity.Id;
        swcTask.OwnerId = swcOpportunity.OwnerId;
        swcTask.AssignedTo__c = swcOpportunity.Assigned_To__c;
        swcTask.AppCode__c = 'SFDC_MKTCLD';
        swcTask.Task_Type__c = 'Sales';
        swcTask.TaskCategory__c = 'SignedWrittenConsent';
        swcTask.ActivityDate = swcStartDate;
        return swcTask;
    }
}