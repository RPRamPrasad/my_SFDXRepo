/** 
* @description task handler utility
* @Owner: CATS
*/
public with sharing class TaskHandlerUtility {

    @TestVisible private static boolean mockBoolean = false;
    @TestVisible private static List<Contact> mockContactList = new List<Contact>();
    
    /**
     * @name getContacts
     * @description getContacts
     * @param clientIds
     * @return List<Contact>
     */
    public static List<Contact> getContacts(Set<String> clientIds){
        try{
            SObjectAccessDecision clientIdAccessDecision = Security.stripInaccessible(System.AccessType.READABLE, 
                                       [Select Id, ClientIdentifier__c, AccountId from Contact where ClientIdentifier__c In :clientIds], 
                                       true);
           
            List<Contact> contactList = clientIdAccessDecision.getRecords();
            if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest) {
                contactList = mockContactList;
            }
            return contactList;
        }catch(Exception ex){
            AP_LogHolder logHolder = new AP_LogHolder();
              logHolder.info('TaskHandlerUtility', ex.getMessage() + System.now());
              logHolder.writeToLogExceptionObject();
            throw ex;
        }
    }
    
    /**
     * @name taskNeedsSPICheckOnUpdate
     * @description taskNeedsSPICheckOnUpdate
     * @param taskRecord
     * @param oldTask
     * @param spiCheckList
     * @return List<Task>
     */
    public static List<Task> taskNeedsSPICheckOnUpdate(Task taskRecord, Task oldTask, List<Task> spiCheckList){
        if(!taskRecord.SkipSPIBeforeUpdateTrigger__c 
           &&((taskRecord.Description != oldTask.Description) || (taskRecord.Subject != oldTask.Subject) )){
               spiCheckList.add(taskRecord);
           }
		return spiCheckList;       	
    }
    
    /**
     * @name buildTaskOutcomeHeader
     * @description buildTaskOutcomeHeader
     * @param taskRecord
     * @return String
     */
    public static String buildTaskOutcomeHeader(Task taskRecord){
        String todaysDateTime = DateTime.now().format('MM/dd/yyyy hh:mm:ss a zzz');
        String newLine = '\n';
        String commentMadeBy = '';
        if(UserInfo.getName()!=null){
            commentMadeBy = UserInfo.getName();  
        }
        return (todaysDateTime+' - '+ commentMadeBy + ' - Task Outcome:'+ newLine + taskRecord.Description + newLine + newLine + 'Comments:');
    }
    
    /**
     * @name preventTaskDelete
     * @description preventTaskDelete
     * @param taskRecord
     */
    public static void preventTaskDelete(Task taskRecord){
        if(TaskHandlerUtility.taskIsNotOpenRecurringTask(taskRecord)){
            taskRecord.addError(Label.CL_TaskPreventDeleteMsg); 
        }
    }
    
    /**
     * @name setWhoIDToPrimaryClientId
     * @description setWhoIDToPrimaryClientId
     * @param contactId
     * @param taskRecord
     */
    public static void setWhoIDToPrimaryClientId(Id contactId, Task taskRecord){
        if(contactId != null){
            taskRecord.WhoId = contactId;  
        }else{
            taskRecord.addError('Record Not Found for: ' + task.PrimaryClientId__c + ' Owner ID: ' + task.OwnerId);
        }
    }
    
    /**
     * @name setWhatIDToPrimaryClientId
     * @description setWhatIDToPrimaryClientId
     * @param accountId
     * @param taskRecord
     */
    public static void setWhatIDToPrimaryClientId(Id accountId, Task taskRecord){
        if(accountId != null && taskRecord.WhatId == null){
            taskRecord.WhatId = accountId;
        }
    }
    
    /**
     * @name recordShouldBeALog
     * @description recordShouldBeALog
     * @param taskRecord
     * @return boolean
     */
    public static boolean recordShouldBeALog(Task taskRecord){
        return (taskRecord.Log_Call__c == true 
                || taskRecord.RecordTypeId == TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID
                || taskRecord.TaskSubtype == TaskHandlerConstants.TASK_SUBTYPE_CALL);
    }
    
    /**
     * @name taskHasInvalidRecordType
     * @description taskHasInvalidRecordType
     * @param taskRecord
     * @return boolean
     */
    public static boolean taskHasInvalidRecordType(Task taskRecord){
        boolean invalidRecordType = false;
        
        if(String.isBlank(taskRecord.recordTypeId) || taskRecord.recordTypeId == null){
            invalidRecordType = true;
        }else if(!TaskHandlerConstants.VALID_TASK_RECORD_TYPE_IDS.contains(taskRecord.RecordTypeId) || isTaskRecordTypeMaster(taskRecord)){
            invalidRecordType = true;
        }
        
        return invalidRecordType;
    }
    /**
     * @name isTaskRecordTypeMaster
     * @description isTaskRecordTypeMaster
     * @param taskRecord
     * @return boolean
     */
    public static boolean isTaskRecordTypeMaster(Task taskRecord){
        Schema.DescribeSObjectResult taskObject = Schema.SObjectType.Task; 
        Map<Id,Schema.RecordTypeInfo> recordTypeInfoMap = taskObject.getRecordTypeInfosById();
        Schema.RecordTypeInfo thisTaskRecordTypeInfo =  recordTypeInfoMap.get(taskRecord.recordTypeId);
        boolean isMaster = false;
        if(thisTaskRecordTypeInfo != null){
            isMaster = thisTaskRecordTypeInfo.isMaster();
        }
        return isMaster;
    }
    /**
     * @name taskHasAccountWhatType
     * @description taskHasAccountWhatType
     * @param taskRecord
     * @return boolean
     */
    public static boolean taskHasAccountWhatType(Task taskRecord){
        return (taskRecord.WhatId != null && taskRecord.WhatId.getSobjectType() == Schema.SObjectType.Account.getSObjectType());
    }
    /**
     * @name taskIsNotOpenRecurringTask
     * @description taskIsNotOpenRecurringTask
     * @param taskRecord
     * @return boolean
     */
    public static boolean taskIsNotOpenRecurringTask(Task taskRecord){
        boolean taskIsNotOpenRecurringTask = taskRecord.RecurrenceActivityId==null || taskRecord.IsClosed || taskRecord.IsArchived;
        if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
            taskIsNotOpenRecurringTask = mockBoolean;
        }
        return taskIsNotOpenRecurringTask;
    }
    /**
     * @name taskHasAClosedStatus
     * @description taskHasAClosedStatus
     * @param taskRecord
     * @return boolean
     */
    public static boolean taskHasAClosedStatus(Task taskRecord){
        return (taskRecord.Status == TaskHandlerConstants.TASK_STATUS_CANCELLED 
                || taskRecord.Status == TaskHandlerConstants.TASK_STATUS_COMPLETED
                || taskRecord.IsClosed);
    }
    /**
     * @name taskOwnerWasChanged
     * @description taskOwnerWasChanged
     * @param taskRecord
     * @param oldTask
     * @return boolean
     */
    public static boolean taskOwnerWasChanged(Task taskRecord, Task oldTask){
        return (taskRecord.OwnerId != oldTask.OwnerId);
    }
    /**
     * @name outcomeWasAddedToTask
     * @description outcomeWasAddedToTask
     * @param taskRecord
     * @param oldTask
     * @return boolean
     */
    public static boolean outcomeWasAddedToTask(Task taskRecord, Task oldTask){
        return (taskRecord.Outcome_Added__c==true && oldTask.Outcome_Added__c ==false);
    }
    /**
     * @name taskSubjectWasUpdatedByAgencyUser
     * @description taskSubjectWasUpdatedByAgencyUser
     * @param taskRecord
     * @param oldTask
     * @return boolean
     */
    public static boolean taskSubjectWasUpdatedByAgencyUser(Task taskRecord, Task oldTask){
        return (taskRecord.Subject != oldTask.Subject && taskRecord.IsOwnerProxyofCurrentUser__c);
    }
    /**
     * @name userRequiresAgentRoleCheck
     * @description userRequiresAgentRoleCheck
     * @return boolean
     */
    public static boolean userRequiresAgentRoleCheck(){
        boolean userRequiresAgentRoleCheck = FeatureManagement.checkPermission(TaskHandlerConstants.AGENT_ROLE_CHECK_FEATURE_CUSTOM_PERMISSION);
        if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
            userRequiresAgentRoleCheck = mockBoolean;
        }
        return userRequiresAgentRoleCheck;
    }
    /**
     * @name userHasPrevalidatedData
     * @description userHasPrevalidatedData
     * @return boolean
     */
    public static boolean userHasPrevalidatedData(){
        return FeatureManagement.checkPermission(TaskHandlerConstants.ALLOW_DML_BYPASS_FOR_PREVALIDATED_DATA);
    }
    
    /**
     * @name taskAssignedToWasChanged
     * @description taskAssignedToWasChanged
     * @param taskRecord
     * @param oldTask
     * @return boolean
     */
    public static boolean taskAssignedToWasChanged(Task taskRecord, Task oldTask){
        return (taskRecord.AssignedTo__c != oldTask.AssignedTo__c);
    }
}