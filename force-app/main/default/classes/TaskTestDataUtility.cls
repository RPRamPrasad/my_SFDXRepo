/** 
* @description case test data utility 
* @Owner: Grumpycats
*/
@isTest
(seeAllData=false)
public class TaskTestDataUtility {
	
	@TestVisible private static final String OPPORTUNITY_RECORD_TYPE_ID_OPPORTUNITY_MANAGEMENT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();
    @TestVisible private static final String ACCOUNT_CLIENT_ID = '12345678915';
    @TestVisible private static final String TASK_API_NAME = 'SF_CRM_TaskAPI_PermSetPID';
    
    @TestVisible private static void createAccount(){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',BillingAddressType__c='US',BillingCity='Phoenix',ClientIdentifier__c=ACCOUNT_CLIENT_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
    }

    @TestVisible private static Account getAccount(){
        return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE  ClientIdentifier__c = :ACCOUNT_CLIENT_ID];
    }
    
    @TestVisible private static Task buildTask(Account accountRecord, Id ownerId){
        TaskFactoryTask taskTestFactory = new TaskFactoryTask();
        taskTestFactory.setActivityDate(Date.today())
        .setDescription('Test Desc')
        .setOwnerId(ownerId)
        .setPriority('Low')
        .setSubject('Test Subject')
        .setTaskType('Service')
        .setWhatId(accountRecord.Id)
        .setWhoId(accountRecord.PersonContactId)
        .setStatus(TaskHandlerConstants.TASK_STATUS_NOT_STARTED);
        return taskTestFactory.returnTask();
    }
    
    @TestVisible private static Task buildNewLog(Account accountRecord, Id ownerId){
        TaskFactoryNewLog taskTestFactory = new TaskFactoryNewLog();
        taskTestFactory.setLogTitle('Test log Title')
        .setContactType('Phone')
        .setDescription('New Log')
        .setOwnerId(ownerId)
        .setPriority('Low') 
        .setTaskType('Service')
        .setWhatId(accountRecord.Id)
        .setWhoId(accountRecord.PersonContactId);
        return taskTestFactory.returnNewLog();
    }
    @TestVisible private static Task retrieveTaskAfterInsert(Id taskId){
        return [SELECT Id, Status, OwnerId, RecordTypeId, WhatId, WhoId, Priority, Subject, Log_Title__c, Contact_Type__c, Log_Call__c, TaskSubtype, AssignedTo__c, Description, Task_Type__c, ActivityDate, Time_Due__c, LineofBusiness__c, AppCode__c, Pivoted__c FROM Task WHERE Id =: taskId LIMIT 1];
    }
    @TestVisible private static Task retrieveTaskAfterInsert(Task taskRecord){
        Id taskId = taskRecord.Id;
        return [SELECT Id, Status, OwnerId, RecordTypeId, WhatId, WhoId, Priority, Subject, Log_Title__c, Contact_Type__c, Log_Call__c, TaskSubtype, AssignedTo__c FROM Task WHERE Id =: taskId LIMIT 1];
    }
    @TestVisible private static List<Task> retrieveTaskListAfterInsert(List<Task> taskList){
        Set<Id> taskIdSet = new Set<Id>();
        for(Task taskRecord : taskList){
            taskIdSet.add(taskRecord.Id);
        }
        return [SELECT Id, Status, OwnerId, RecordTypeId, WhatId, WhoId, Priority, Subject, Log_Title__c, Contact_Type__c, Log_Call__c, TaskSubtype, AssignedTo__c FROM Task WHERE Id In: taskIdSet];
    }
    
     @TestVisible private static void setupAgentRole(User userRecord, Account accountRecord){
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c = userRecord.Id;
        agentRole.Customer__c = accountRecord.Id;
        agentRole.RelationshipNature__c = 'Customer';
        insert agentRole; 
    }
    
    @TestVisible private static void addUserToTaskAPIPermSet(User userRecord){
        PermissionSet taskAPI = [SELECT Id FROM PermissionSet WHERE Name =: TASK_API_NAME  LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userRecord.Id;
        psa.PermissionSetId = taskAPI.Id;
        insert psa;
    }
    
     @TestVisible private static void createOpportunity(Account accountRecord, User userRecord){
        Opportunity opp = new Opportunity();
        opp.AccountId = accountRecord.Id;
        opp.LOB__c = 'Auto';
        opp.ContactId = accountRecord.PersonContactId;
        opp.OwnerId = userRecord.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'New';
        opp.CloseDate = Date.today();
        opp.RecordTypeId = OPPORTUNITY_RECORD_TYPE_ID_OPPORTUNITY_MANAGEMENT;
        bypassOpporunityTriggers(true);
        insert opp;
		bypassOpporunityTriggers(false);       
    }
    
    @TestVisible private static Opportunity getOpportunity(Id accountId){
        return [SELECT Id, AccountId FROM Opportunity WHERE AccountId =: accountId LIMIT 1];
    }
    
    @TestVisible private static void bypassOpporunityTriggers(boolean bypassAll){
        CS001_ByPassTriggerGtoZ__c byPassObjectTrigger = CS001_ByPassTriggerGtoZ__c.getInstance();
        byPassObjectTrigger.Override_OppBeforeInsert__c = bypassAll;
        byPassObjectTrigger.Override_OppBeforeUpdate__c = bypassAll;
        byPassObjectTrigger.Override_OppAfterUpdate__c = bypassAll;
        byPassObjectTrigger.Override_OpportunityAfterInsert__c = bypassAll;
    }
}