/** 
* @description task after trigger handler utility test
* @Owner: CATS
*/
@isTest
(seeAllData = false)
private class TaskBeforeTriggerHandlerTest {
    
    private static Task mockTaskRecord = UnitTestDataUtility.buildTask(false);
    private static Task mockTaskRecordWithId = UnitTestDataUtility.buildTask(true);
    private static Task mockOldTaskRecord = UnitTestDataUtility.buildTask(true);
    private static Contact mockContact = UnitTestDataUtility.buildContact();
    private static List<Contact> mockContactList = new List<Contact>();
    private static List<Task> mockTaskList = new List<Task>();
    private static Set<String> mockClientIdSet = new Set<String>();
    private static Map<Id, Task> mockOldTaskMap = new Map<Id, Task>();
    private static String invalidRecordTypeId = '012o0000000U1FAKE1';
    
    @isTest
    private static void testHandleBeforeInsert(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Priority = 'Yes';
        mockTaskList.add(mockTaskRecord);
        TaskBeforeTriggerHandler.handleBeforeInsert(mockTaskList);
        System.assertEquals(TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, mockTaskRecord.RecordTypeId, 'Record Type ID did not match the constants');
        System.assertEquals(TaskHandlerConstants.TASK_PRIORITY_HIGH, mockTaskRecord.Priority, 'Priority was not updated');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleBeforeInsertWithPrevalidatedData(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Priority = 'No';
        mockTaskRecord.PrimaryClientId__c = UnitTestDataUtility.MOCK_CLIENT_ID;
        mockTaskRecord.OwnerId = UserInfo.getUserId();
        mockTaskRecord.AssignedTO__c = UnitTestDataUtility.MOCK_USER_ID;
        mockTaskList.add(mockTaskRecord);
        mockContactList.add(mockContact);
        TaskBeforeTriggerHandler.mockUserHasPrevalidatedData = true;
        TaskBeforeTriggerHandler.handleBeforeInsert(mockTaskList);
        System.assertEquals(TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, mockTaskRecord.RecordTypeId, 'Record Type ID did not match the constants');
        System.assertEquals(TaskHandlerConstants.TASK_PRIORITY_NONE, mockTaskRecord.Priority, 'Priority was not updated');
        System.assertEquals(null, mockTaskRecord.AssignedTo__c, 'Assigned TO is not reset');
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockTaskRecord.OwnerId, 'Owner Id is not set');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleNonValidatedTaskInsert() {
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Log_Call__c = true;
        mockTaskList.add(mockTaskRecord);
        TaskBeforeTriggerHandler.handleNonValidatedTaskInsert(mockTaskList);
        System.assertEquals(TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID, mockTaskRecord.RecordTypeId, 'Record Type was not a log');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleBeforeUpdate(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskBeforeTriggerHandler.isInsert = false;
        mockOldTaskRecord.RecordTypeId = TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID;
        mockTaskRecordWithId.RecordTypeId = invalidRecordTypeId;
		mockTaskList.add(mockTaskRecordWithId);
        mockOldTaskMap.put(UnitTestDataUtility.MOCK_TASK_ID, mockOldTaskRecord);
        TaskBeforeTriggerHandler.handleBeforeUpdate(mockTaskList, mockOldTaskMap);
        System.assertEquals(TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, mockTaskRecordWithId.RecordTypeId, 'Record type was not default');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleBeforeUpdateWithTextFieldChange(){
        TaskBeforeTriggerHandler.isInsert = false;
        mockOldTaskRecord.Description = 'Test description';
        mockTaskRecordWithId.Description = 'This has changed';
		mockTaskList.add(mockTaskRecordWithId);
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockOldTaskMap.put(UnitTestDataUtility.MOCK_TASK_ID, mockOldTaskRecord);
        TaskBeforeTriggerHandler.handleBeforeUpdate(mockTaskList, mockOldTaskMap);
        Test.stopTest();
        System.assertEquals(TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, mockTaskRecordWithId.RecordTypeId, 'Record type was not default');
    }
    
    @isTest
    private static void testHandleBeforeDelete(){
        mockTaskList.add(mockTaskRecordWithId);
        TaskHandlerUtility.mockBoolean = true;
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskBeforeTriggerHandler.handleBeforeDelete(mockTaskList);
        List<ApexPages.Message> errors = ApexPages.getMessages();
        Test.stopTest();
        System.assert(!errors.isEmpty(), 'No errors were added to the Task object');
        System.assertEquals(Label.CL_TaskPreventDeleteMsg, errors.get(0).getDetail(), 'Error message did not match the message passed in through constant');
    }
}