/**
 * @description SR_DMLHandler
 */
public without sharing class SR_DMLHandler {
    private static final String CONNECT = ' - ';
    @TestVisible CS_SR_Config__c srConfig = CS_SR_Config__c.getInstance();
    @TestVisible private Integer queueJobRetryLimit = (srConfig.Queue_Retry_Limit__c == null) ? 3 : Integer.valueOf(srConfig.Queue_Retry_Limit__c);
    private SR_Util utility = new SR_Util();
    @TestVisible private Map<SR_Key, Object> srMap = new Map<SR_Key, Object>();
    @TestVisible private List<Service_Request_Exception__c> exceptions = new List<Service_Request_Exception__c>();
    //private List<SR_Payload> exceptionPayloads = new List<SR_Payload>();
    private Map<String, SR_Payload> queMap = new Map<String, SR_Payload>();
    private Map<String, SR_Payload> originalPayloadsMap = new Map<String, SR_Payload>();
    private Map<String, Task> taskMap = new Map<String, Task>();
    private Map<String, Case> caseMap = new Map<String, Case>();
    private List<Task> tasks = new List<Task>();
    private List<Case> cases = new List<Case>();
    private List<Id> insertedCasesWithTasks = new List<Id>();
    @TestVisible private List<SR_Payload> recordLockPayloads = new List<SR_Payload>();
    @TestVisible private List<SR_Payload> initialRecordLockRecords = new List<SR_Payload>();
    
    /**
     * @description SR_DMLHandler
     * @param srMap 
     */
    public SR_DMLHandler(Map<SR_Key, Object> srMap){
        this.srMap = srMap;
        this.caseMap = (srMap.containsKey(SR_Key.CASE_MAP)) ? (Map<String, Case>)srMap.get(SR_Key.CASE_MAP) : new Map<String, Case>();
        this.taskMap = (srMap.containsKey(SR_Key.TASK_MAP)) ? (Map<String, Task>)srMap.get(SR_Key.TASK_MAP) : new Map<String, Task>();
        this.queMap = (srMap.containsKey(SR_Key.QUEUEABLE_PAYLOADS_MAP)) ? (Map<String, SR_Payload>)srMap.get(SR_Key.QUEUEABLE_PAYLOADS_MAP) : new Map<String, SR_Payload>();
        this.originalPayloadsMap = (srMap.containsKey(SR_Key.ORIGINAL_PAYLOADS_MAP)) ? (Map<String, SR_Payload>)srMap.get(SR_Key.ORIGINAL_PAYLOADS_MAP) : new Map<String, SR_Payload>();
    }
    /**
     * @description handleUpsert
     * @return  `Map<SR_Key, Object>`
     */
    public Map<SR_Key, Object> handleUpsert(){
        if(!this.caseMap.isEmpty()){
            this.cases = this.caseMap.values();
            upsertSObjects(this.cases, Case.getSObjectType());
        }
        if(!this.taskMap.isEmpty()){
            this.tasks = this.taskMap.values();
            upsertSObjects(this.tasks, Task.getSObjectType());
        }
        putExceptionsInSRMap();
        putRecordLocksInSRMap();
        return this.srMap;
    }

    private void upsertSObjects(List<SObject> sobjects, SObjectType sobjType){
        try{
            List<Database.UpsertResult> results = Database.upsert(Security.stripInaccessible(AccessType.UPSERTABLE, sobjects, true).getRecords(), false);
            handleUpsertResults(results, sobjType);
        }catch(Exception ex){
            if(sobjects.size() == 1){
                SR_Payload originalPayload = getOriginalPayload(0, sobjType);
                removeFromTaskMap(sobjType, originalPayload.eventId);
                removeFromQueueMap(originalPayload.eventId);
                handleException(originalPayload, sobjType + CONNECT + ex.getMessage());
            }else{
                this.exceptions.addAll(utility.buildExceptionsList(this.originalPayloadsMap.values(), ex.getMessage()));
            }
        }
    }
    /**
     * @description handleUpsertResults
     * @param upsertResults 
     * @param sobjType 
     */
    public void handleUpsertResults(List<Database.UpsertResult> upsertResults, SObjectType sobjType){
        for(Database.UpsertResult result : upsertResults){
            Integer matchingIndexNumber = upsertResults.indexOf(result);
            SR_Payload originalPayload = getOriginalPayload(matchingIndexNumber, sobjType);
            if(!result.isSuccess()){
                removeFromTaskMap(sobjType, originalPayload.eventId);
                removeFromQueueMap(originalPayload.eventId);
                String errorMessage = getErrors(result.getErrors(), sobjType);
                handleException(originalPayload, errorMessage);
            } else {
                checkEventForCaseInsert(sobjType, originalPayload.eventId, result);
                if(shouldResetNumberOfTimes(originalPayload, sobjType)) {
                    originalPayload.numberOfTimesThroughProcess = 0;
                    this.originalPayloadsMap.put(originalPayload.eventId, originalPayload);
                }
            }
        }
        updateTasksWithNewCaseInfo();
        if(!this.initialRecordLockRecords.isEmpty()) {
            ExceptionLog__c debugLogForRecordLockMetrics = LoggingService.buildExceptionObject('SR_DMLHandler', 'handleUpsertResults', this.initialRecordLockRecords.size() + ' Record Lock Exceptions occurred on initial processing of ' + sobjType + ' Object(s).', True, System.LoggingLevel.INFO);
            LoggingService.logException(debugLogForRecordLockMetrics);
        }
    }
    
    private void removeFromTaskMap(SObjectType sobjType, String eventId){
        if(sobjType == Case.getSObjectType() && this.taskMap.containsKey(eventId)){
            this.taskMap.remove(eventId);
        }        
    }
    
    private void removeFromQueueMap(String eventId){
        if(this.queMap.containsKey(eventId)){
            this.queMap.remove(eventId);
        }
    }

    private void checkEventForCaseInsert(SObjectType sobjType, String eventId, Database.UpsertResult saveResult) {
        if(sobjType == Case.getSObjectType() && this.taskMap.containsKey(eventId)){
            addCaseIdToListForQuery(saveResult.getId(), this.taskMap.get(eventId));
        } 
    }
    
    private void addCaseIdToListForQuery(Id caseId, Task originalTask) {
        if(originalTask.WhatId == null) {
            this.insertedCasesWithTasks.add(caseId);
        }
    }
    
    private void updateTasksWithNewCaseInfo() {
        List<Case> insertedCases = new List<Case>();
        if(this.insertedCasesWithTasks.size() > 0) {
            insertedCases = security.stripInaccessible(AccessType.READABLE, [SELECT Id, ContactId, OwnerId, Event_Id__c FROM Case WHERE Id IN :this.insertedCasesWithTasks]).getRecords();
        }
        for(Case insertedCase : insertedCases) {
            this.taskMap.get(insertedCase.Event_Id__c).WhoId = insertedCase.ContactId;
            this.taskMap.get(insertedCase.Event_Id__c).WhatId = insertedCase.Id;
            this.taskMap.get(insertedCase.Event_Id__c).OwnerID = insertedCase.OwnerId;
        }
    }
    
    @TestVisible
    private SR_Payload getOriginalPayload(Integer matchingIndexNumber, SObjectType sobjType){
        SObject failedRecord = (sobjType == Case.getSObjectType()) ? (SObject)this.cases.get(matchingIndexNumber) : (SObject)this.tasks.get(matchingIndexNumber);
        String eventId = String.valueOf(failedRecord.get('Event_Id__c'));
        return this.originalPayloadsMap.get(eventId);
    }
    
    private String getErrors(List<Database.Error> errors, SObjectType sobjType){
        String errorMessage = sobjType + CONNECT;
        for(Database.Error error : errors){
            errorMessage += (error.getStatusCode() + CONNECT + error.getFields() + CONNECT +  '\n' + error.getMessage());
        }
        return errorMessage;
    }
    
    private void putExceptionsInSRMap(){
        if(!this.exceptions.isEmpty()){
            this.srMap.put(SR_Key.SERVICE_REQUEST_EXCEPTIONS, exceptions); 
        }
    }

    @TestVisible
    private void putRecordLocksInSRMap() {
        if(!this.recordLockPayloads.isEmpty()) {
            this.srMap.put(SR_Key.RECORD_LOCK_EXCEPTIONS, recordLockPayloads);
        }
    }

    @TestVisible
    private void handleException(SR_Payload originalPayload, String errorMessage) {
        if(originalPayload.numberOfTimesThroughProcess < this.queueJobRetryLimit && errorMessage.contains('UNABLE_TO_LOCK_ROW')) {
            if(originalPayload.numberOfTimesThroughProcess == 0) {
                this.initialRecordLockRecords.add(originalPayload);
            }
            originalPayload.numberOfTimesThroughProcess = originalPayload.numberOfTimesThroughProcess + 1;
            this.recordLockPayloads.add(originalPayload);
        } else {
            this.exceptions.add(utility.buildExceptions(originalPayload, errorMessage));
        }
    }

    @TestVisible
    private boolean shouldResetNumberOfTimes(SR_Payload originalPayload, SObjectType sobjType) {
        return (sobjType == Case.getSObjectType() && originalPayload.numberOfTimesThroughProcess > 0 && this.taskMap.get(originalPayload.eventId) == null);
    }
    
}