/** 
* @description task handler utility test
* @Owner: CATS
*/
@isTest
(seeAllData = false)
private class TaskHandlerUtilityTest {
    private static Task mockTaskRecord = UnitTestDataUtility.buildTask(false);
    private static Task mockTaskRecordWithId = UnitTestDataUtility.buildTask(true);
    private static Task mockOldTaskRecord = UnitTestDataUtility.buildTask(true);
    private static Contact mockContact = UnitTestDataUtility.buildContact();
    private static List<Contact> mockContactList = new List<Contact>();
    private static List<Task> mockTaskList = new List<Task>();
    private static Set<String> mockClientIdSet = new Set<String>();
    private static Map<Id, Task> mockOldTaskMap = new Map<Id, Task>();
    
    @isTest
    private static void testGetContact(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockContactList.add(mockContact);
        TaskHandlerUtility.mockContactList = mockContactList;
        List<Contact> returnedContacts = TaskHandlerUtility.getContacts(mockClientIdSet);
        System.assertEquals(returnedContacts, TaskHandlerUtility.mockContactList, 'Returned contacts did not match the mocked values');
        Test.stopTest();
    }
    
    @isTest
    private static void testRecordShouldBeALogFromLogCall(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Log_Call__c = true;
        boolean recordShouldBeALog = TaskHandlerUtility.recordShouldBeALog(mockTaskRecord);
        System.assert(recordShouldBeALog, 'Record was determined to not be a log based on Log Call value');
        Test.stopTest();
    }
    
    @isTest
    private static void testRecordShouldBeALogFromRecordType(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.RecordTypeId = TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID;
        boolean recordShouldBeALog = TaskHandlerUtility.recordShouldBeALog(mockTaskRecord);
        System.assert(recordShouldBeALog, 'Record was determined to not be a log based on record type ID');
        Test.stopTest();
    }
    
    @isTest
    private static void testRecordShouldBeALogFromSubtype(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.TaskSubtype = TaskHandlerConstants.TASK_SUBTYPE_CALL;
        boolean recordShouldBeALog = TaskHandlerUtility.recordShouldBeALog(mockTaskRecord);
        System.assert(recordShouldBeALog, 'Record was determined to not be a log based on task. subtype');
        Test.stopTest();
    }
    
    @isTest
    private static void testRecordShouldBeALogFromCancelledStatus(){ 
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Status = TaskHandlerConstants.TASK_STATUS_CANCELLED;
        boolean recordShouldBeALog = TaskHandlerUtility.recordShouldBeALog(mockTaskRecord);
        System.assert(!recordShouldBeALog, 'record was a log when it shouldnt be');
        Test.stopTest();
    }
    
    @isTest
    private static void testRecordShouldBeALogNegative(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        boolean recordShouldBeALog = TaskHandlerUtility.recordShouldBeALog(mockTaskRecord);
        System.assert(recordShouldBeALog == false, 'Basic task was determined to be a log');
        Test.stopTest();
    }
    
    @isTest
    private static void testtaskHasInvalidRecordTypeId(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.RecordTypeId = '012o0000000U1FAKE1';
        boolean taskHasInvalidRecordType = TaskHandlerUtility.taskHasInvalidRecordType(mockTaskRecord);
        System.assert(taskHasInvalidRecordType, 'Master record constant did not result in do not use record type');
        Test.stopTest();
    }
    
    @isTest
    private static void testtaskHasInvalidRecordTypeNullOrBlank(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.RecordTypeId = null;
        System.assert(TaskHandlerUtility.taskHasInvalidRecordType(mockTaskRecord), 'Null value did not result in do not use record type');
        Test.stopTest();
    }
    
    @isTest
    private static void testtaskHasInvalidRecordTypeMockedId(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.RecordTypeId = UnitTestDataUtility.MOCK_RECORD_TYPE_ID;
        System.assert(TaskHandlerUtility.taskHasInvalidRecordType(mockTaskRecord), 'Non master record type ID resulted in do not use record type');
        mockTaskRecord.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Master').getRecordTypeId();
        System.assert(TaskHandlerUtility.taskHasInvalidRecordType(mockTaskRecord), 'Master record type ID was allowed through record type check');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsTaskRecordTypeMaster(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Master').getRecordTypeId();
        System.assert(TaskHandlerUtility.isTaskRecordTypeMaster(mockTaskRecord), 'Master record type ID was allowed through record type check');
        mockTaskRecord.RecordTypeId = UnitTestDataUtility.MOCK_RECORD_TYPE_ID;
        System.assert(!TaskHandlerUtility.isTaskRecordTypeMaster(mockTaskRecord), 'Non master record type was marked as master');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskHasAccountWhatTypeForNull(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.WhatId = null;
        boolean taskHasAccountWhatType = TaskHandlerUtility.taskHasAccountWhatType(mockTaskRecord);
        System.assert(taskHasAccountWhatType == false, 'Null Value for WhatId resulted in account type');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskHasNotAccountWhatType(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.WhatId = UnitTestDataUtility.MOCK_CASE_ID;
        boolean taskHasAccountWhatType = TaskHandlerUtility.taskHasAccountWhatType(mockTaskRecord);
        System.assert(taskHasAccountWhatType == false, 'Case ID for WhatId resulted in account type');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskHasAccountWhatType(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.WhatId = UnitTestDataUtility.MOCK_ACCOUNT_ID;
        boolean taskHasAccountWhatType = TaskHandlerUtility.taskHasAccountWhatType(mockTaskRecord);
        System.assert(taskHasAccountWhatType, 'Account ID for WhatId resulted in a type that was not account');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskHasACancelledStatus(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Status = TaskHandlerConstants.TASK_STATUS_CANCELLED;
        boolean taskHasAClosedStatus = TaskHandlerUtility.taskHasAClosedStatus(mockTaskRecord);
        System.assert(taskHasAClosedStatus, 'Task did not have a closed status from cancelled constant');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskHasAClosedStatus(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Status = TaskHandlerConstants.TASK_STATUS_COMPLETED;
        boolean taskHasAClosedStatus = TaskHandlerUtility.taskHasAClosedStatus(mockTaskRecord);
        System.assert(taskHasAClosedStatus, 'Task did not have a closed status from completed constant');
        Test.stopTest();
    }
    
    @isTest    
    private static void testTaskOwnerWasChanged(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.OwnerId = UnitTestDataUtility.MOCK_USER_ID;
        mockOldTaskRecord.OwnerId = UnitTestDataUtility.SECONDARY_MOCK_USER_ID;
        boolean taskOwnerHasChanged = TaskHandlerUtility.taskOwnerWasChanged(mockTaskRecord, mockOldTaskRecord);
        System.assert(taskOwnerHasChanged, 'Task owner did not change');
        Test.stopTest();
    }
    
    @isTest    
    private static void testTaskOwnerWasNotChanged(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.OwnerId = UnitTestDataUtility.MOCK_USER_ID;
        mockOldTaskRecord.OwnerId = UnitTestDataUtility.MOCK_USER_ID;
        boolean taskOwnerHasChanged = TaskHandlerUtility.taskOwnerWasChanged(mockTaskRecord, mockOldTaskRecord);
        System.assert(taskOwnerHasChanged == false, 'Task owner was changed');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskNeedsNoSPICheckOnNoUpdate(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.SkipSPIBeforeUpdateTrigger__c = false;
        mockTaskList = TaskHandlerUtility.taskNeedsSPICheckOnUpdate(mockTaskRecord, mockOldTaskRecord, mockTaskList);
        System.assertEquals(0, mockTaskList.size(), 'Unchanged task was added that needed SPI to be checked');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskNeedsSPICheckOnSubjectUpdate(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.SkipSPIBeforeUpdateTrigger__c = false;
        mockTaskRecord.Subject = 'New Task';
        mockOldTaskRecord.Subject = 'Old Task';
        mockTaskList = TaskHandlerUtility.taskNeedsSPICheckOnUpdate(mockTaskRecord, mockOldTaskRecord, mockTaskList);
        System.assertEquals(1, mockTaskList.size(), 'Changed task was not added that needed SPI to be checked on Subject field');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskNeedsSPICheckOnDescriptionUpdate(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.SkipSPIBeforeUpdateTrigger__c = false;
        mockTaskRecord.Description = 'New Task';
        mockOldTaskRecord.Description = 'Old Task';
        mockTaskList = TaskHandlerUtility.taskNeedsSPICheckOnUpdate(mockTaskRecord, mockOldTaskRecord, mockTaskList);
        System.assertEquals(1, mockTaskList.size(), 'Changed task was not added that needed SPI to be checked on description field');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskNeedsNoSPICheckOnTriggerSkipUpdate(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.SkipSPIBeforeUpdateTrigger__c = true;
        mockTaskRecord.Subject = 'New Task';
        mockOldTaskRecord.Subject = 'Old Task';
        mockTaskList = TaskHandlerUtility.taskNeedsSPICheckOnUpdate(mockTaskRecord, mockOldTaskRecord, mockTaskList);
        System.assertEquals(0, mockTaskList.size(), 'Changed task was added with skip trigger set to true');
        Test.stopTest();
    }
    
    @isTest
    private static void testOutcomeWasAddedToTask(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Outcome_Added__c = true;
        mockOldTaskRecord.Outcome_Added__c = false;
        boolean outcomeWasAddedToTask = TaskHandlerUtility.outcomeWasAddedToTask(mockTaskRecord, mockOldTaskRecord);
        System.assert(outcomeWasAddedToTask, 'Returned false with change in outcome value between tasks');
        Test.stopTest();
    }
    
    @isTest
    private static void testOutcomeWasNotAddedToTask(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Outcome_Added__c = true;
        mockOldTaskRecord.Outcome_Added__c = true;
        boolean outcomeWasAddedToTask = TaskHandlerUtility.outcomeWasAddedToTask(mockTaskRecord, mockOldTaskRecord);
        System.assert(!outcomeWasAddedToTask, 'Returned true with no change in outcome value between tasks');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskAssignedToWasChanged(){
        Test.startTest();
        mockTaskRecord.AssignedTo__c = UnitTestDataUtility.MOCK_USER_ID;
        mockOldTaskRecord.AssignedTo__c = UnitTestDataUtility.SECONDARY_MOCK_USER_ID;
        boolean returnResult = TaskHandlerUtility.taskAssignedToWasChanged(mockTaskRecord, mockOldTaskRecord);
        System.assert(returnResult, 'returned result was assigned to did not change');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskAssignedToWasChangedFalse(){
        Test.startTest();
        mockTaskRecord.AssignedTo__c = UnitTestDataUtility.MOCK_USER_ID;
        mockOldTaskRecord.AssignedTo__c = UnitTestDataUtility.MOCK_USER_ID;
        boolean returnResult = TaskHandlerUtility.taskAssignedToWasChanged(mockTaskRecord, mockOldTaskRecord);
        System.assert(!returnResult, 'returned result was assigned to did change');
        Test.stopTest();
    }
    
    @isTest
    private static void testSetWhoIDToPrimaryClientId(){
        Test.startTest();
        Id contactID = UnitTestDataUtility.MOCK_CONTACT_ID;
        TaskHandlerUtility.setWhoIDToPrimaryClientId(contactId, mockTaskRecord);
        System.assertEquals(contactId, mockTaskRecord.WhoId, 'Who Id is not set with Primary contact Id');
        Test.stopTest();
    }
    
    @isTest
    private static void testSetWhatIDToPrimaryClientId(){
        Test.startTest();
        Id accountID = UnitTestDataUtility.MOCK_ACCOUNT_ID;
        TaskHandlerUtility.setWhatIDToPrimaryClientId(accountID, mockTaskRecord);
        System.assertEquals(accountID, mockTaskRecord.WhatId, 'What Id is not set with Primary contact Id');
        Test.stopTest();
    }
}