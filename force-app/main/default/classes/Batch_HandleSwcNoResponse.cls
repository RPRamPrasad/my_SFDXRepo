/**
Author Team ClubCar
Name - Batch_HandleSwcNoResponse
@description - Batch class to update Opportunity and SignedWrittenConsent fields when no response
               is received from customer on SWC email     
====================================================================================================================
VERSION         AUTHOR                      DATE                    DETAIL
1.0            Team ClubCar                10/20/2020              Initial Development
********************************************************************************************************************/
public with sharing class Batch_HandleSwcNoResponse implements Database.Batchable<sObject> {

    private static final String BATCH_CLASS_NAME = 'Batch_HandleSwcNoResponse';
    private static final String BATCH_EXECUTE_METHOD = 'execute';
    private static final String REQUESTED = 'Requested';
    private static final String STATUS_NORESPONSE = 'No Response';
    private static final Date TODAY = System.Today();

    /**
    * @description - start method for the batch
    * @param bc 
    * @return Database.QueryLocator
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryString = 'Select Id, InitiatedFromId__c from SignedWrittenConsent__c where Status__c =:REQUESTED AND RequestStartDate__c <:TODAY';
        return Database.getQueryLocator(queryString);
    }

    /**
    * @description - execute method for the batch
    * @param bc 
    * @param swcNotRespondedList 
    */
    public void execute(Database.BatchableContext bc, List<SignedWrittenConsent__c> swcNotRespondedList) {
        if(!swcNotRespondedList.isEmpty())  {
            processSwcNotRespondedRecords(swcNotRespondedList);
        }
    }

    /**
    * @description - Finish method will be updated post R14
    * @param bc 
    */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {

    }
    
	// helper method to mark Account and SWC field with 'No Response' Status
    private void processSwcNotRespondedRecords(List<SignedWrittenConsent__c> swcRequestedList) {
        try {
            Set<Id> opportunityIdSet = new Set<Id>();
            for (SignedWrittenConsent__c requestedSwcRecord : swcRequestedList){
                requestedSwcRecord.Status__c = STATUS_NORESPONSE;
                opportunityIdSet.add(requestedSwcRecord.InitiatedFromId__c);
            }

            List<Opportunity> oppListToUpdate = retrieveSwcOpportunities(opportunityIdSet);
            updateOpportunityAndSwcRecords(oppListToUpdate, swcRequestedList);

        } catch(Exception batchException) {
                LoggingService.logHandledException(batchException, BATCH_CLASS_NAME, BATCH_EXECUTE_METHOD, System.LoggingLevel.ERROR); 
        }
    }


    // helper method to query Opportunities related to same Account and Agent Office
    private static List<Opportunity> retrieveSwcOpportunities(Set<Id> opportunityIdSet) {
        Set<String> accountAndAgentOfficeSet = new Set<String>();
        Set<Id> swcAccountIdSet = new Set<Id>();
        Set<Id> opportunityOwnerIdSet = new Set<Id>();
        List<Opportunity> oppListToUpdate = new List<Opportunity> ();

        for (Opportunity swcOpptyRecord : [Select Id, AccountId, OwnerId from Opportunity where Id IN:opportunityIdSet]){
            swcAccountIdSet.add(swcOpptyRecord.AccountId);
            opportunityOwnerIdSet.add(swcOpptyRecord.OwnerId);
            accountAndAgentOfficeSet.add('' + swcOpptyRecord.AccountId + swcOpptyRecord.OwnerId);   
        }

        for(Opportunity oppRecordToUpdate : [Select Id, AccountId, OwnerId from Opportunity where OwnerId IN: opportunityOwnerIdSet
                                                    And AccountId IN :swcAccountIdSet AND OppSignedWrittenConsentStatus__c != null]) {
            if(accountAndAgentOfficeSet.contains(''+oppRecordToUpdate.AccountId + oppRecordToUpdate.OwnerId)) {
            oppRecordToUpdate.OppSignedWrittenConsentStatus__c = STATUS_NORESPONSE;
            oppRecordToUpdate.OppSignedWrittenConsentRequestedDate__c = null;
            oppRecordToUpdate.OppSignedWrittenConsentGrantedDate__c = null;
            oppListToUpdate.add(oppRecordToUpdate);  
            }                                               
        }
        return oppListToUpdate;
    }

    //helper method tp update sObjectList
    private void updateOpportunityAndSwcRecords(List<Opportunity> opportunityListToUpdate, List<SignedWrittenConsent__c> swcListToUpdate) {
        List<SObject> allRecordsToUpdate = new List<SObject>();
        allRecordsToUpdate.addAll((List<SObject>)opportunityListToUpdate);
        allRecordsToUpdate.addAll((List<SObject>)swcListToUpdate);
        if(!allRecordsToUpdate.isEmpty()) {
            DataBase.update(allRecordsToUpdate, false);
        }
    }
}