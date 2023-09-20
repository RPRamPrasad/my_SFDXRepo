/** 
* @description task trigger handler
* @Owner: CATS
*/
public with sharing class TaskHandler {
    public static final String CLASS_NAME = 'TaskHandler';
    @TestVisible private static boolean mockBoolean = false;
    private static Map<String, Id> clientIdContactMap;
    private static Map<String, Id> clientIdAccountMap;

    /**
     * @name handleLogs
     * @description handleLogs
     * @param taskRecord
     */
    public static void handleLogs(Task taskRecord){
        if(TaskHandlerUtility.recordShouldBeALog(taskRecord)){
            transformRecordToLog(taskRecord);
        }
    }
    
    @TestVisible private static void transformRecordToLog(Task taskRecord){
        taskRecord.CreatedClosed__c = true;
        taskRecord.Log_Call__c = true;
        taskRecord.Status = TaskHandlerConstants.TASK_STATUS_COMPLETED;
        taskRecord.TaskSubtype = TaskHandlerConstants.TASK_SUBTYPE_CALL;
        taskRecord.RecordTypeId = TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID;
        if(String.isNotBlank(taskRecord.Log_Title__c)){ //Should this check be subject populated?
            setupLogSubject(taskRecord);
        }
    }
    
    @TestVisible private static void setupLogSubject(Task taskRecord){
        if(taskRecord.Contact_Type__c == null){
            taskRecord.Subject = taskRecord.Log_Title__c;
        }else{
            taskRecord.Subject = (taskRecord.Contact_Type__c + ' : ' + taskRecord.Log_Title__c);
        }
    }
    
    /**
     * @name handlePrimaryClientId
     * @description handlePrimaryClientId
     * @param newTaskList
     * @param primaryClientIds
     */
    public static void handlePrimaryClientId(List<Task> newTaskList, Set<String> primaryClientIds){
        List<Contact> contacts = TaskHandlerUtility.getContacts(primaryClientIds);
        populateClientIdMaps(contacts);
        for(Task taskRecord : newTaskList){
            TaskHandlerUtility.setWhoIDToPrimaryClientId(clientIdContactMap.get(taskRecord.PrimaryClientId__c), taskRecord);
            TaskHandlerUtility.setWhatIDToPrimaryClientId(clientIdAccountMap.get(taskRecord.PrimaryClientId__c), taskRecord);
        }          
    }
    
    /**
     * @name populateClientIdMaps
     * @description populateClientIdMaps
     * @param contactList
     */
    private static void populateClientIdMaps(List<Contact> contactList) {
        clientIdContactMap = new Map<String, Id>();
        clientIdAccountMap = new Map<String, Id>();
        for(Contact contactRecord : contactList){
            clientIdContactMap.put(contactRecord.ClientIdentifier__c, contactRecord.Id);
            clientIdAccountMap.put(contactRecord.ClientIdentifier__c, contactRecord.AccountId);
        }
    }
    
    /**
     * @name handleSPI
     * @description handleSPI
     * @param newTaskList
     */
    public static void handleSPI(List<Task> newTaskList){ //Handle SPI scrub
        if(!newTaskList.isEmpty()){
            AP_SPISecurityManager spiSecurity = new AP_SPISecurityManager();
            spiSecurity.handle(newTaskList);  // call for SPI scrubbing
        }
    } 
    
    /**
     * @name handleInvalidRecordType
     * @description handleInvalidRecordType
     * @param taskRecord
     */
    public static void handleInvalidRecordType(Task taskRecord) {
        if(TaskHandlerUtility.taskHasInvalidRecordType(taskRecord)) {
            taskRecord.RecordTypeId = TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID;
        }
    }
    
    /**
     * @name handleAgentRoleCheck
     * @description handleAgentRoleCheck
     * @param newTaskList
     */
    public static void handleAgentRoleCheck(List<Task> newTaskList){
        if (TaskHandlerUtility.userRequiresAgentRoleCheck()){
            checkAgentRole(newTaskList);
        }
    }
    
    /**
     * @name handleTaskOwnerChange
     * @description handleTaskOwnerChange
     * @param newTaskList
     * @param oldTaskMap
     */
    public static void handleTaskOwnerChange(List<Task> newTaskList, Map<Id,Task> oldTaskMap){
        List<Task> tasksWithOwnerChange = new List<Task>();
        for(Task taskRecord : newTaskList){
            Task oldTask = oldTaskMap.get(taskRecord.Id);
            if(TaskHandlerUtility.taskOwnerWasChanged(taskRecord, oldTask) && TaskHandlerUtility.taskAssignedToWasChanged(taskRecord, oldTask)){
                tasksWithOwnerChange.add(taskRecord); //Check Agent Role if the new owner is a user and not a queue
            }else if(TaskHandlerUtility.taskOwnerWasChanged(taskRecord, oldTask)){
                taskRecord.AssignedTo__c = null;//Blank Assigned To if the Office is changed
                tasksWithOwnerChange.add(taskRecord); //Check Agent Role if the new owner is a user and not a queue
            }
        }
        
        if(!tasksWithOwnerChange.isEmpty()){
            handleAgentRoleCheck(tasksWithOwnerChange);
            setTaskOwnerToProxy(tasksWithOwnerChange);
        }  
    }
    
    /**
     * @name setTaskOwnerToProxy
     * @description setTaskOwnerToProxy
     * @param taskList
     */
    public static void setTaskOwnerToProxy(List<Task> taskList){
    	SObjectOwnershipUtility.setObjectOwnerToProxy(taskList, false);    
    }
    
    /**
     * @name checkAgentRole
     * @description checkAgentRole
     * @param newTaskList
     */
    private static void checkAgentRole(List<Task> newTaskList){
        List<Task> taskOwnerIdCheckList = new List<Task>();
        Set<Id> ownerIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Task taskRecord : newTaskList){
            if (taskRecord.WhoId != null || TaskHandlerUtility.taskHasAccountWhatType(taskRecord)) {
                contactIdSet.add(taskRecord.WhoId != null ? taskRecord.WhoId : taskRecord.WhatId);
                taskOwnerIdCheckList.add(taskRecord);
                ownerIdSet.add(taskRecord.OwnerId);
            }
        }
        
        if(!contactIdSet.isEmpty()){
            AgentRoleValidationUtility.checkAgentRoleForSObjectOwner(taskOwnerIdCheckList, contactIdSet, ownerIdSet);
        }
    }
    
    /**
     * @name handleTaskDelete
     * @description handleTaskDelete
     * @param taskList
     */
    public static void handleTaskDelete(List<Task> taskList) {
        for(Task taskRecord : taskList) {
            TaskHandlerUtility.preventTaskDelete(taskRecord);
        }
    }
    
    /**
     * @name handleAgencySubjectChange
     * @description handleAgencySubjectChange
     * @param taskRecord
     * @param oldTask
     */
    public static void handleAgencySubjectChange(Task taskRecord, Task oldTask){
        boolean taskSubjectWasUpdatedByAgencyUser = TaskHandlerUtility.taskSubjectWasUpdatedByAgencyUser(taskRecord, oldTask);
        if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest) {
           taskSubjectWasUpdatedByAgencyUser = mockBoolean; 
        }
        if(taskSubjectWasUpdatedByAgencyUser) {
            taskRecord.SubjectModifiedByAgentOffice__c = true;
        }
    }
}