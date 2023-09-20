/** 
* @description case test data utility 
* @Owner: Grumpycats
*/
public with sharing class TaskFactoryNewLog extends TaskFactory {

    private String logTitle;
    private String contactType;
    
    /**
     * @name setLogTitle
     * @description setLogTitle
     * @param logTitle
     * @return TaskFactoryNewLog
     */
    public TaskFactoryNewLog setLogTitle(String logTitle){
        this.logTitle = logTitle;
        return this;
    }
    /**
     * @name setContactType
     * @description setContactType
     * @param contactType
     * @return TaskFactoryNewLog
     */
    public TaskFactoryNewLog setContactType(String contactType){
        this.contactType = contactType;
        return this;
    }
    
    /**
     * @name returnNewLog
     * @description returnNewLog
     * @return Task
     */
    public Task returnNewLog(){
        Task taskRecord = new Task();
        taskRecord.Log_Title__c = logTitle;
        taskRecord.Contact_Type__c = contactType;
        taskRecord.ActivityDate = Date.today();
        taskRecord.Priority = priority;
        taskRecord.Description = description;
        taskRecord.AppCode__c = appCode;
        taskRecord.TaskCategory__c = taskCategory;
        taskRecord.TaskSubCategory__c = taskSubCategory;
        taskRecord.Task_Type__c = taskType;
        taskRecord.WhoId = whoId;
        taskRecord.WhatId = whatId;
        taskRecord.OwnerId = ownerId;
        taskRecord.LineofBusiness__c = lineOfBusiness;
        taskRecord.AssignedTo__c = assignedTo;
        taskRecord.RecordTypeId = TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID;
        taskRecord.Log_Call__c = true;
        taskRecord.TaskSubtype = TaskHandlerConstants.TASK_SUBTYPE_CALL;
        taskRecord.Status = TaskHandlerConstants.TASK_STATUS_COMPLETED;
        return taskRecord;
    }
}
