@isTest
(seeAllData=false)
public class CaseTestSetup {
   
    
    @TestVisible
    private static void setupTest(User dmlUser){
        User admin = TestUserSetupUtility.getSysAdminUser();
        User agent = TestUserSetupUtility.getAgentUser();
        System.runAs(admin){
            CaseTestDataUtility.createAccount();
            CaseTestDataUtility.setupAgentRole(agent, CaseTestDataUtility.getAccount());
        }
        runAsDML(dmlUser, buildAssortmentOfCases());
    }

   
    @TestVisible
    private static List<Task> buildTasks(List<Case> cases){
        List<Task> tasks = new List<Task>();
        for(Case caseRecord : cases){
            tasks.add(buildTask(caseRecord));
        }
        return tasks;
    }
    
    @TestVisible
    private static List<Task> buildLogs(List<Case> cases){
        List<Task> tasks = new List<Task>();
        for(Case caseRecord : cases){
            tasks.add(buildLog(caseRecord));
        }
        return tasks;
    }

    @TestVisible
    private static Case buildCase(Id recordTypeId){
        Case record = new Case();
        record.Subject = ('Test Case');
        record.OwnerId = TestUserSetupUtility.getProxyUser().Id;
        record.AccountId = CaseTestDataUtility.getAccount().Id;
        record.ContactId = CaseTestDataUtility.getAccount().PersonContactId;
        record.LOB__c = 'Auto';
        record.RecordTypeId = recordTypeId;
        return record;
    }
    
    @TestVisible
    private static Task buildTask(Case caseRecord){
        Task taskRecord = new Task();
        taskRecord.Subject = caseRecord.Subject;
        taskRecord.OwnerId = caseRecord.OwnerId;
        taskRecord.WhoId = caseRecord.ContactId;
        taskRecord.WhatId = caseRecord.Id;
        taskRecord.Task_Type__c = 'Service';
        taskRecord.ActivityDate = Date.today();
        taskRecord.RecordTypeId = TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID;
        return taskRecord;
    }
    
    @TestVisible
    private static Task buildLog(Case caseRecord){
        Task taskRecord = new Task();
        taskRecord.Subject = caseRecord.Subject;
        taskRecord.OwnerId = caseRecord.OwnerId;
        taskRecord.WhoId = caseRecord.ContactId;
        taskRecord.WhatId = caseRecord.Id;
        taskRecord.Task_Type__c = 'Service';
        taskRecord.ActivityDate = Date.today();
        taskRecord.CreatedClosed__c = true;
        taskRecord.Log_Call__c = true;
        taskRecord.Status = TaskHandlerConstants.TASK_STATUS_COMPLETED;
        taskRecord.TaskSubtype = TaskHandlerConstants.TASK_SUBTYPE_CALL;
        taskRecord.RecordTypeId = TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID;
        return taskRecord;
    }
    
    @TestVisible
    private static List<Case> buildAssortmentOfCases(){
        List<Case> cases = new List<Case>();
        Case csr = buildCase(CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
        Case csr2 = csr.clone();
        cases.add(csr);
        cases.add(csr2);
        Case pc = buildCase(CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE);
        Case pc2 = pc.clone();
        cases.add(pc);
        cases.add(pc2);
        Case billing = buildCase(CaseHandlerConstants.CASE_RECORDTYPE_ID_BILLING);
        Case billing2 = billing.clone();
        cases.add(billing);
        cases.add(billing2);
        Case ret = buildCase(CaseHandlerConstants.CASE_RECORDTYPE_ID_RETENTION);
        Case ret2 = ret.clone();
        cases.add(ret);
        cases.add(ret2);
        return cases;
    }
	
	@TestVisible    
    private static Case getCaseResults(Id createdById){
        return [SELECT Id, Subject, OwnerId, ContactId, isEscalated, RecordTypeId, Follow_up_date__c, Status, Request_Type__c, 
                (SELECT Id, WhatId, Subject, OwnerId, ActivityDate FROM Tasks) 
                FROM Case WHERE CreatedById =: createdById];
    }
    
    @TestVisible
    private static Task getTaskResults(Id taskId){
        return [SELECT Id, WhatId, Subject, OwnerId, ActivityDate FROM Task WHERE ID =: taskId];
    }
    
    @TestVisible
    private static Id runAsDML(User runAs, SObject sobj){
        List<Database.UpsertResult> results;
        List<SObject> sobjects = new List<SObject>();
        sobjects.add(sobj);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(runAs);
        System.runAs(runAs){
            results = upsertSObjects(sobjects);
        }
        List<Id> recordIds = getIdList(getSuccessfulRecordIdsFromDMLOpertions(results));
        return recordIds.get(0);
    }
    
    @TestVisible
    private static List<Id> runAsDML(User runAs, List<SObject> sobjects){
        List<Database.UpsertResult> results;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(runAs);
        System.runAs(runAs){
            results = upsertSObjects(sobjects);
        }
        return getIdList(getSuccessfulRecordIdsFromDMLOpertions(results));
    }
    
    @TestVisible
    private static List<Database.UpsertResult> upsertSObjects(List<SObject> sobjects){
        SObjectAccessDecision access = Security.stripInaccessible(AccessType.UPSERTABLE, sobjects, true);
        Map<String, Set<String>> removedFieldMap = access.getRemovedFields();
        if(removedFieldMap != null && !removedFieldMap.isEmpty()){
            for(String key : removedFieldMap.keySet()){
                System.debug(LoggingLevel.INFO, 'Field Name = ' + key); 
                System.debug(LoggingLevel.INFO, 'Values = ' + removedFieldMap.get(key)); 
            }
        } 
        return Database.upsert(access.getRecords());
    }
    
    @TestVisible                     
    private static Set<Id> getSuccessfulRecordIdsFromDMLOpertions(List<Database.UpsertResult> results){
        Set<Id> recordIds = new Set<Id>();
        for(Database.UpsertResult result : results){
            if(result.isSuccess()){
                recordIds.add(result.getId());
            }
        }
        return recordIds;
    }
    
    @TestVisible
    private static List<Id> getIdList(Set<Id> myset){
        List<Id> objs = new List<Id>();
        objs.addAll(myset);
        return objs;
    }

}