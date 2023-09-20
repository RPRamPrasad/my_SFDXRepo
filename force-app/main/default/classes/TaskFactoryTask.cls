/** 
* @description case test data utility 
* @Owner: Grumpycats
*/
public with sharing class TaskFactoryTask extends TaskFactory{
    
    public String customTemplateId;
    private boolean createdFromTemplate = false;
    /**
     * @name setCustomTemplateId
     * @description setCustomTemplateId
     * @param customTemplateId
     * @return TaskFactoryTask
     */
    public TaskFactoryTask setCustomTemplateId(String customTemplateId){
        this.customTemplateId = customTemplateId;
        return this;
    }
    /**
     * @name setCreatedFromTemplate
     * @description setCreatedFromTemplate
     * @param createdFromTemplate
     * @return TaskFactoryTask
     */
    public TaskFactoryTask setCreatedFromTemplate(boolean createdFromTemplate){
        this.createdFromTemplate = createdFromTemplate;
        return this;
    }
    /**
     * @name createTask
     * @description createTask
     */
    public void createTask(){
        List<Task> taskList = new List<Task>();
        taskList.add(returnTask());
        insert Security.stripInaccessible(System.AccessType.CREATABLE, taskList, true).getRecords();
     }
    /**
     * @name returnTask
     * @description returnTask
     * @return Task
     */
    public Task returnTask(){
            Task taskRecord = new Task();
            taskRecord.Subject = subject;
            taskRecord.ActivityDate = activityDate;
            taskRecord.Priority = priority;
            taskRecord.Status = status;
            taskRecord.Description = description;
            taskRecord.AppCode__c = appCode;
            taskRecord.TaskCategory__c = taskCategory;
            taskRecord.TaskSubCategory__c = taskSubCategory;
            taskRecord.Task_Type__c = taskType;
            taskRecord.WhoId = whoId;
            taskRecord.WhatId = whatId;
            taskRecord.OwnerId = ownerId;
            taskRecord.CreatedFromTemplate__c = createdFromTemplate;
            taskRecord.Custom_Template_Id__c = customTemplateId;
            taskRecord.LineofBusiness__c = lineOfBusiness;
            taskRecord.AssignedTo__c = assignedTo;
            return taskRecord;
    }
    
}