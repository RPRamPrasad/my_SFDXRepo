/****************************************************************************************
Name: HLPR_SignedWrittenConsent
@description : Updates Opportunity SWC and DateCaptured fields and Cancels SWC granted Tasks
Team: ClubCar
=========================================================================================
VERSION     AUTHOR             DATE             DETAIL
1.0        Team ClubCar        10/20/2020       Initial Development
2.0        Team ClubCar        04/12/2021       Added logic to restrict Organization Accounts
2.0        Team ClubCar        08/12/2021       Removed state specific logic
******************************************************************************************/ 
public with sharing class HLPR_SignedWrittenConsent {
    
    private static final String CLASS_NAME = 'HLPR_SignedWrittenConsent';
    private static final String TASK_STATUS_CANCELLED  = 'Cancelled';
    private static final String STATUS_REQUESTED = 'Requested';
    private static final String METHOD_NAME1 = 'processConsentOnOpportunityCreate';
    private static final String METHOD_NAME2 = 'processSwcRequestedRecords';
    public static Boolean byPassOpportunityBeforeUpdate = false;
    
    /**
    * @method- Invoked by OpportunityAfterInsert Trigger           
    * @description  This method will help us to Clear SWC Date Field Values on Opportunity's Account, Update Date Captured Value with Opportunity's Createddate in all the Opportunities related to
    *               the Opportunity's Account and Create a Signed Written Consent Record related to the Opportunity's Account
    * @name  processConsentOnOpportunityCreate
    * @param  opportunityList - Opportunities List
    */    
    public static void processConsentOnOpportunityCreate(List<Opportunity> opportunityList) {
        try{
            if(!isSignedWrittenConsentToggleOn()) {
                processSwcUpdatesOnOpportunityAndTask(opportunityList);
            }
        }
        catch(Exception opptyAfterInsertException){
            LoggingService.logHandledException(opptyAfterInsertException, CLASS_NAME, METHOD_NAME1, LoggingLevel.ERROR);
        }
    }
    
    //Helper method to get account id set, opportunity owner id set and process updates
    private static void processSwcUpdatesOnOpportunityAndTask(List<Opportunity> opportunityList){
        Set<String> accountAndAgentOfficeSet = new Set<String>();
        Set<String> opportunityStageSet = new Set<String>{'Closed', 'Closed Won'};
        List<Opportunity> oppListToUpdate = new List<Opportunity> ();        
        Set<Id> swcAccountIdSet = new Set<Id>();
        Set<Id> opportunityOwnerIdSet = new Set<Id>();
        for(Opportunity opptyRecord : opportunityList){
            swcAccountIdSet.add(opptyRecord.AccountId);
            opportunityOwnerIdSet.add(opptyRecord.OwnerId);
            accountAndAgentOfficeSet.add('' + opptyRecord.AccountId + opptyRecord.OwnerId);           
        }        
        // Closed and Closed won should be handled only for Date Captured
        for(Opportunity oppRecordToUpdate : [Select id, AccountId, OwnerId from Opportunity where StageName Not IN: opportunityStageSet AND OwnerId IN: opportunityOwnerIdSet
                                            AND AccountId IN :swcAccountIdSet AND Opportunity.Account.Recordtype.Name = 'Individual' WITH SECURITY_ENFORCED]) {
            if(accountAndAgentOfficeSet.contains(''+oppRecordToUpdate.AccountId + oppRecordToUpdate.OwnerId)) {
                oppRecordToUpdate = updateOppSwcAndDateCapturedFields(oppRecordToUpdate);
                oppListToUpdate.add(oppRecordToUpdate);  
            }                                               
        }
        updateOpportunityList(oppListToUpdate);
        cancelSwcGrantedTask(swcAccountIdSet, opportunityOwnerIdSet, accountAndAgentOfficeSet);
    }    
    
    // helper method to update Opportunity Date Captured and SWC fields
    private static Opportunity updateOppSwcAndDateCapturedFields(Opportunity oppRecord){
        oppRecord.DateCaptured__c = System.Now();
        oppRecord.OppSignedWrittenConsentGrantedDate__c = null;
        oppRecord.OppSignedWrittenConsentRequestedDate__c = null;
        oppRecord.OppSignedWrittenConsentStatus__c = null;
        return oppRecord;
    }

    //Helper method to cancel existng SWC tasks on Accounts
    private static void cancelSwcGrantedTask(Set<Id> swcAccountIdSet, Set<Id> opportunityOwnerIdSet, Set <String> accountAndAgentOfficeSet){        
        List<Task> taskToCancelList = new List<Task>();
        for(Task taskToCancel : [Select Id, AccountId, OwnerId from Task where AccountID IN: swcAccountIdSet AND Isclosed = false
                                 AND AppCode__c = 'SFDC_MKTCLD' AND Subject = 'Signed Written Consent Granted' WITH SECURITY_ENFORCED]){
            if(accountAndAgentOfficeSet.contains(''+taskToCancel.AccountId + taskToCancel.OwnerId)) {
                taskToCancel.Status = TASK_STATUS_CANCELLED;                         
                taskToCancelList.add(taskToCancel);
            }
        }
        // using below helper class to update in system mode        
        UTIL_TaskDAO.updateTasks(taskToCancelList);
    }

    //helper method to update Opportunities
    private static void updateOpportunityList(List<Opportunity> opportunityList) {
        if(!opportunityList.isEmpty() && Schema.sObjectType.Opportunity.isUpdateable()){
            byPassOpportunityBeforeUpdate = true;
            update opportunityList;
        }
    }

    /**
    * @method- Invoked by SignedWrittenConsentAfterInsert Trigger
    * @description  - This method will scan incoming Swc records with Requested Status and dismiss any active duplicate swc records in db that match same Account and Agent Office criteria
    * @name processSwcRequestedRecords
    * @param signedWrittenConsentRequestedRecords - swc records inserted list
    */
    public static void processSwcRequestedRecords (List<SignedWrittenConsent__c> signedWrittenConsentRequestedRecords) {
       try{
        querySwcDataAndDismissDupSwcRecords(signedWrittenConsentRequestedRecords);
        }
        catch(Exception swcException){
            LoggingService.logHandledException(swcException, CLASS_NAME, METHOD_NAME2, LoggingLevel.ERROR);
        }
    }

    // helper method to query Account and Agent office details related to current inserted swc records
    private static void querySwcDataAndDismissDupSwcRecords (List<SignedWrittenConsent__c> signedWrittenConsentRequestedRecords){
        Map<Id, String> swcIdToAccountOfficeMap = new Map<Id, String> (); 
        List<SignedWrittenConsent__c> swcRequestedList = new List<SignedWrittenConsent__c>();

        Set<String> swcAccountIdSet = new Set<String> ();
        Map<String,Id> oppIdToCurrentSwcIdMap = new Map<String, Id> ();
        for (SignedWrittenConsent__c swc : signedWrittenConsentRequestedRecords) {
            if(swc.Status__c.equals(STATUS_REQUESTED)) {
                swcRequestedList.add(swc);
                swcAccountIdSet.add(swc.Account__c);
                oppIdToCurrentSwcIdMap.put(swc.InitiatedFromId__c, swc.id);
            }
        }
        for (Opportunity swcOpp : [Select Id, AccountId, OwnerId from Opportunity where Id IN:oppIdToCurrentSwcIdMap.keyset()]){
            swcIdToAccountOfficeMap.put(oppIdToCurrentSwcIdMap.get(swcOpp.id), '' + swcOpp.AccountId + swcOpp.OwnerId);
        }
        dismissDupSwcRecordsForAccountAgentOffice(swcIdToAccountOfficeMap, swcRequestedList, swcAccountIdSet);
    }

    // helper method to query and process stale swc records from db that are in 'Requested' Status for same Account and Agent Office
    private static void dismissDupSwcRecordsForAccountAgentOffice (Map<Id, String> swcIdToAccountOfficeMap, List<SignedWrittenConsent__c> swcRequestedList, Set<String> swcAccountIdSet){

        List<SignedWrittenConsent__c> swcListToUpdate = new List<SignedWrittenConsent__c> ();
        Set<String> accountToAgentOfficeSet = new Set<String> ();
        Map<String, SignedWrittenConsent__c> accAndOfficeToOldSwcRecordMap = new Map <String, SignedWrittenConsent__c> ();
        Map<Id,SignedWrittenConsent__c> oppIdToDuplicateSwcId = new Map<Id, SignedWrittenConsent__c> ();

        for (SignedWrittenConsent__c swcRecordsInDb : [Select Id, InitiatedFromId__c, Account__c from SignedWrittenConsent__c where
                                                      Status__c =: STATUS_REQUESTED And Account__c IN: swcAccountIdSet AND ID NOT IN: swcRequestedList WITH SECURITY_ENFORCED]) {
            oppIdToDuplicateSwcId.put(swcRecordsInDb.InitiatedFromId__c, swcRecordsInDb);
        }

        for (Opportunity swcOpp : [Select Id, AccountId, OwnerId from Opportunity where Id IN:oppIdToDuplicateSwcId.keyset()]){
            String accountAndOfficeIdUniqueCheck = '' + swcOpp.AccountId+ swcOpp.OwnerId;
            accountToAgentOfficeSet.add(accountAndOfficeIdUniqueCheck);
            accAndOfficeToOldSwcRecordMap.put(accountAndOfficeIdUniqueCheck, oppIdToDuplicateSwcId.get(swcOpp.Id));
        }
        for (SignedWrittenConsent__c swc : swcRequestedList) {
            String accountToAgentOfficeCheck = swcIdToAccountOfficeMap.get(swc.Id);
            // verifying if we have a old swc record with same Account and Agent office combination
            if(accountToAgentOfficeSet.contains(accountToAgentOfficeCheck)) {
                SignedWrittenConsent__c duplicateSwcToDismiss = accAndOfficeToOldSwcRecordMap.get(accountToAgentOfficeCheck);
                duplicateSwcToDismiss.Status__c = 'Not Applicable';
                swcListToUpdate.add(duplicateSwcToDismiss);
            }
        }
        updateSwcRecords(swcListToUpdate);
    }

    // helper method to update Swc records
    private static void updateSwcRecords(List<SignedWrittenConsent__c> swcList) {
        if(!swcList.isEmpty() && Schema.sObjectType.SignedWrittenConsent__c.isUpdateable()){
            update swcList;
        }
    }

    /**
    * @method- Invoked by SignedWrittenConsentBeforeUpdate Trigger and used in Opportunity Create Swc flow
    * @description  helper method to verify SWC Toggle Status
    * @name isSignedWrittenConsentToggleOn
    * @return Boolean - returns the booelan value based on signed written consent toggle
    */
    public static Boolean isSignedWrittenConsentToggleOn(){
        Boolean isToggleOn = false;
        List<Toggle__c> toggleList = Security.stripInaccessible(AccessType.READABLE,[Select Status__c from Toggle__c 
                                                                                     where FeatureName__c = 'SignedWrittenConsent' LIMIT 1]).getRecords();
        if(!toggleList.isEmpty()){
            isToggleOn = toggleList[0].Status__c;
        }
        return isToggleOn;
    }
}