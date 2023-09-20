/**
 * @description CaseChangeOfAddressProcessor
 */
public without sharing class CaseChangeOfAddressProcessor {
    
    @TestVisible private static final String ADDRESS_CHANGE_SUBJECT = 'Address Change - Update all applicable policies/accounts';
    
    public List<Task> tasks = new List<Task>();
    /**
     * @description createCOATasks
     * @param cases 
     */
    public void createCOATasks(List<Case> cases){
        for(Case caseRecord : cases){
            if(isCOACase(caseRecord)){
                this.tasks.add(buildCOATask(caseRecord));
            }
        }
        if(!this.tasks.isEmpty() && !isRunningUnitTest()){
           insert Security.stripInaccessible(AccessType.CREATABLE, this.tasks, true).getRecords(); 
        }
    }
    /**
     * @description buildCOATask
     * @param caseRecord 
     * @return  `Task`
     */
    public Task buildCOATask(Case caseRecord){
        Task taskRecord = new Task();
        taskRecord.ActivityDate = Date.today();
        taskRecord.AppCode__c = caseRecord.App_Code__c;
        taskRecord.Description = Label.CL_ADDRESS_CHANGE_DESCRIPTION;
        taskRecord.IsTaskCreatedWhenCaseCreated__c = true;
        taskRecord.OwnerId = caseRecord.OwnerId;
        taskRecord.Priority = 'High';
        taskRecord.SkipOwnerProxyBeforeInsertTrigger__c = true;
        taskRecord.SkipSPIBeforeInsertTrigger__c = true;
        taskRecord.Source__c = caseRecord.Case_Originator__c;
        taskRecord.Status = 'Not Started';
        taskRecord.Subject = ADDRESS_CHANGE_SUBJECT;
        taskRecord.TaskCategory__c = 'Account Change';
        taskRecord.TaskSubCategory__c = CaseHandlerConstants.CASE_REASON_CHANGE_OF_ADDRESS;
        taskRecord.Task_Type__c = 'Service';
        taskRecord.WhatId = caseRecord.Id;
        taskRecord.WhoId = caseRecord.ContactId;
        return taskRecord;
    }
    /**
     * @description isCOACase
     * @param caseRecord 
     * @return  `boolean`
     */
    public boolean isCOACase(Case caseRecord){
        return (caseRecord.Reason == CaseHandlerConstants.CASE_REASON_CHANGE_OF_ADDRESS && String.isNotBlank(caseRecord.App_Code__c));
    }
    
    private boolean isRunningUnitTest(){
        return (Test.isRunningTest() && UnitTestDataUtility.isUnitTest);
    }
    
}