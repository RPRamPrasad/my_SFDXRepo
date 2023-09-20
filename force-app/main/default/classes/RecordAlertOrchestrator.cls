/**
 * @description Orchestrator for creating/updating/deleting Record Alerts
 * @Owner Team Skynet
 */
public with sharing class RecordAlertOrchestrator {

    private static final String CLASS_NAME = 'RecordAlertOrchestrator';
    private static final String PLATFORMEVENT_ACTION_CREATE = 'CREATE';
    private static final String PLATFORMEVENT_ACTION_DELETE = 'DELETE';
    private static final String PLATFORMEVENT_ACTION_UPDATE = 'UPDATE';

    /**
     * @description Handles Platform Events coming in from the Record_Alert__e trigger
     * 		ex: BillPastDue, Simple Convo, Total Loss
     * @param newRecordAlertEventList
     * @return saveResults
     */
    public List<Database.UpsertResult> handleRecordAlertEvent(List<Record_Alert__e> newRecordAlertEventList){
        //Setup Logging variables
        String methodName = 'handleRecordAlertEvent';

        // System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' ' + methodName + ' (RecordAlertEvent) count: ' + newRecordAlertEventList.size());
        //LoggingService.logHandledException(CLASS_NAME + ' ' + methodName + ' (RecordAlertEvent) count: ' + newRecordAlertEventList.size(),
        // CLASS_NAME, methodName, LoggingLevel.INFO);

        //Map<ParentId,List<RecordAlerts for the ParentId>>
        Map<String,List<RecordAlert>> existingRecordAlertMap = mapExistingRecordAlertsForAccounts(newRecordAlertEventList);
        List<RecordAlert> recordAlertsToUpsertList = new List<RecordAlert>();
        List<RecordAlert> recordAlertsToDeleteList = new List<RecordAlert>();

        for (Record_Alert__e event : newRecordAlertEventList) {
            List<String> eventTypeList = event.Event_Types__c.split(',');

            for (String eventType : eventTypeList) {
                // This is also where we have Business Logic for the different Alert Categories
                // This will be changed to calling the RecordAlertBuilder class
                // Create RecordAlert based on this Event data.
                switch on (eventType) {
                	when 'Simple Conversation' {
                        try{
                            HandleRecordAlertEvent2WrapperClass handleRecordAlertEvent2Wrapp = new HandleRecordAlertEvent2WrapperClass();
                            handleRecordAlertEvent2Wrapp.event = event;
                            handleRecordAlertEvent2Wrapp.existingRecordAlertMap = existingRecordAlertMap;
                            handleRecordAlertEvent2Wrapp.recordAlertsToUpsertList = recordAlertsToUpsertList;
                            handleRecordAlertEvent2Wrapp.recordAlertsToDeleteList = recordAlertsToDeleteList;
                            handleRecordAlertEvent2(handleRecordAlertEvent2Wrapp);
                        } catch (RAO_RecordAlertHandler.RAOException ex) {
                            LoggingService.logHandledException(ex, CLASS_NAME, methodName, LoggingLevel.ERROR);
                        }
                	}
                    // when 'Total Loss' {
                    //     RecordAlert thisRecordAlert = new RecordAlert(
                    //         IsActive=true,
                    //         Subject='Total Loss',
                    //         Severity='Error',
                    //         RecordAlertCategoryId = '0qX550000000006EAA',
                    //         ParentId=event.ParentId__c,
                    //         OwnerId=event.CreatedById,
                    //         ValidUntilDate=event.ValidUntilDate__c,
                    //         EffectiveDate=event.CreatedDate,
                    //         WhatId=event.WhatId__c,
                    //         Household__c=event.Household__c);

                    //     recordAlertsToUpsertList.add(thisRecordAlert);
                    // }

                }
            }


        }
        // Upsert all Record Alerts corresponding to events received.
        List<Database.UpsertResult> saveResults = Database.upsert(Security.stripInaccessible(AccessType.UPSERTABLE, recordAlertsToUpsertList, true).getRecords(), false);
        
        if (Schema.sObjectType.RecordAlert.isAccessible()) {
            List<Database.DeleteResult> deletionResults;
            deletionResults = Database.delete(Security.stripInaccessible(AccessType.UPDATABLE, recordAlertsToDeleteList, true).getRecords(), false);
            LoggingService.logDatabaseResult(deletionResults, recordAlertsToDeleteList, CLASS_NAME, 'handleRecordAlertEvent', LoggingLevel.ERROR);
        }

        return saveResults;
    }

    private void handleRecordAlertEvent2(HandleRecordAlertEvent2WrapperClass handleRecordAlertEvent2Wrap)
    {
        Record_Alert__e event = handleRecordAlertEvent2Wrap.event;
        Map<String,List<RecordAlert>> existingRecordAlertMap = handleRecordAlertEvent2Wrap.existingRecordAlertMap;
        List<RecordAlert> recordAlertsToUpsertList = handleRecordAlertEvent2Wrap.recordAlertsToUpsertList;
        List<RecordAlert> recordAlertsToDeleteList = handleRecordAlertEvent2Wrap.recordAlertsToDeleteList;

         if(PLATFORMEVENT_ACTION_CREATE.Equals(event.Action__c) || PLATFORMEVENT_ACTION_UPDATE.Equals(event.Action__c)) {
                                RecordAlert thisRecordAlert = RAO_RecordAlertHandler.simpleConversationHandler(event,existingRecordAlertMap);
                                recordAlertsToUpsertList.add(thisRecordAlert);
                            } else if(PLATFORMEVENT_ACTION_DELETE.Equals(event.Action__c)) {
                                RecordAlert thisRecordAlert = RAO_RecordAlertHandler.simpleConversationDeleteHandler(event,existingRecordAlertMap);
                                recordAlertsToDeleteList.add(thisRecordAlert);
                            }
    }
    private class HandleRecordAlertEvent2WrapperClass
    {
        private  Record_Alert__e event;
        private Map<String,List<RecordAlert>> existingRecordAlertMap;
        private List<RecordAlert> recordAlertsToUpsertList;
        private List<RecordAlert> recordAlertsToDeleteList;
    }
    /**
     * @description Handles manual/bulk/batch calls
     * 		ex: Propensity to Defect, Data Load
     * @param newRecordAlertList
     */
    // public static void handleRecordAlert(List<RecordAlert> newRecordAlertList) {

    // }
    /**
     * @description This method will process the mapExistingRecordAlertsForAccounts
     * @param newRecordAlertEventList
     * @return  `Map<String, List<RecordAlert>>`
     */
    public Map<String, List<RecordAlert>> mapExistingRecordAlertsForAccounts(List<Record_Alert__e> newRecordAlertEventList) {
        Map<String, List<RecordAlert>> existingRecordAlertMap = new Map<String, List<RecordAlert>>();
        List<RecordAlert> recordAlerts = new List<RecordAlert>();

        // Get a list of the ParentIds to limit our RecordAlert query
        List<ID> parentIdList = new List<String>();
        for (Record_Alert__e event : newRecordAlertEventList) {
            if(!parentIdList.contains(event.ParentId__c)) {
                parentIdList.add(ID.valueOf(event.ParentId__c));
                existingRecordAlertMap.put(event.ParentId__c, new List<RecordAlert>());
            }
        }

        if(!parentIdList.isEmpty()) {
            recordAlerts = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT Id, SourceSystemIdentifier, ParentId, WhatId, OwnerId, EffectiveDate, ValidUntilDate, Severity, RecordAlertCategoryId, IsActive
                 FROM RecordAlert
                 WHERE IsActive =: true
                 AND ParentId IN :parentIdList
                 LIMIT 200]) //TO-DO: Should be a Custom Setting variable
                .getRecords();
        }

        //Return map of ParentId, List of Record Alerts with that ParentId
        for(RecordAlert ralert : recordAlerts) {
            existingRecordAlertMap.get(ralert.ParentId).add(ralert);
        }
        return existingRecordAlertMap;
    }


}
