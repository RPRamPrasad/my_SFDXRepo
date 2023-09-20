/** 
* @description task handler test
* @Owner: CATS
*/
@isTest
(seeAllData = false)
private class TaskHandlerTest {
    
    private static Task mockTaskRecord = UnitTestDataUtility.buildTask(false);
    private static Task mockTaskRecordWithId = UnitTestDataUtility.buildTask(true);
    private static Task mockOldTaskRecord = UnitTestDataUtility.buildTask(true);
    private static Contact mockContact = UnitTestDataUtility.buildContact();
    private static List<Contact> mockContactList = new List<Contact>();
    private static List<Task> mockTaskList = new List<Task>();
    private static Set<String> mockClientIdSet = new Set<String>();
    private static Map<Id, Task> mockOldTaskMap = new Map<Id, Task>();
    
    @isTest
    private static void testHandleLogs(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Log_Title__c = 'Not blank';
        mockTaskRecord.Log_Call__c = true;
        TaskHandler.handleLogs(mockTaskRecord);
        System.assertEquals(true, mockTaskRecord.CreatedClosed__c, 'Created closed was not set to true');
        System.assertEquals(TaskHandlerConstants.TASK_STATUS_COMPLETED, mockTaskRecord.Status, 'Status was not set to completed');
        System.assertEquals(TaskHandlerConstants.TASK_SUBTYPE_CALL, mockTaskRecord.TaskSubtype, 'Subtype was not set to call');
        System.assertEquals(TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID, mockTaskRecord.RecordTypeId, 'Record type ID was not set to Log Call');
        System.assertEquals(mockTaskRecord.Log_Title__c, mockTaskRecord.Subject, 'Subject was not set to the Log Title Field');
        Test.stopTest();
    }

    @isTest
    private static void testSetupLogSubject(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        String logTitle = 'Log Title';
        mockTaskRecord.Contact_Type__c = null;
        mockTaskRecord.Log_Title__c = logTitle;
        TaskHandler.setupLogSubject(mockTaskRecord);
        System.assertEquals(logTitle, mockTaskRecord.Subject, 'Subject was not set to the log title');
        Test.stopTest();
    }
    
    @isTest
    private static void testSetupLogSubjectWithContactType(){
        Test.startTest();
        String logTitle = 'Log Title';
        mockTaskRecord.Contact_Type__c = logTitle;
        mockTaskRecord.Log_Title__c = logTitle;
        TaskHandler.setupLogSubject(mockTaskRecord);
        System.assertEquals(logTitle + ' : ' + logTitle, mockTaskRecord.Subject, 'Subject was not set to the constructed log title string');
        Test.stopTest();
    }
    
   
    @isTest
    private static void testHandleAgencySubjectChangeModifiedByOffice(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskHandler.mockBoolean = true;
        TaskHandler.handleAgencySubjectChange(mockTaskRecord, mockOldTaskRecord);
        System.assert(mockTaskRecord.SubjectModifiedByAgentOffice__c, 'Subject was not modified by agent office');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleAgencySubjectChangeNotModifiedByOffice(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskHandler.mockBoolean = false;
        TaskHandler.handleAgencySubjectChange(mockTaskRecord, mockOldTaskRecord);
        System.assert(!mockTaskRecord.SubjectModifiedByAgentOffice__c, 'Subject modified by agent office was set to true');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandlePrimaryClientId(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockContact.Id = UnitTestDataUtility.MOCK_CONTACT_ID;
        mockContact.ClientIdentifier__c = UnitTestDataUtility.MOCK_CLIENT_ID;
        mockContactList.add(mockContact);
        mockTaskRecord.PrimaryClientId__c = UnitTestDataUtility.MOCK_CLIENT_ID;
        mockTaskList.add(mockTaskRecord);
        mockClientIdSet.add(UnitTestDataUtility.MOCK_CLIENT_ID);
		TaskHandler.handlePrimaryClientId(mockTaskList, mockClientIdSet);
        System.assert(Limits.getQueries() == 1, 'unexpected number of queries');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandlePrimaryClientIdWithError(){
        mockContact.ClientIdentifier__c = UnitTestDataUtility.MOCK_CLIENT_ID;
        mockContactList.add(mockContact);
        mockTaskList.add(mockTaskRecord);
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockClientIdSet.add(UnitTestDataUtility.MOCK_CLIENT_ID);
		TaskHandler.handlePrimaryClientId(mockTaskList, mockClientIdSet);
        List<ApexPages.Message> errors = ApexPages.getMessages();
        Test.stopTest();
        System.assertEquals('Record Not Found for: PrimaryClientId__c Owner ID: OwnerId', errors.get(0).getDetail(), 'Error message did not print what was expected');
       
    }
    
    @isTest
    private static void testHandleSPI(){
        mockTaskList.add(mockTaskRecord);
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskHandler.handleSPI(mockTaskList);
        Integer queryCount = Limits.getQueries();
        Test.stopTest();
        System.assertEquals(1, queryCount, 'Query for SPI scrubbing was not made');
    }
    
    @isTest
    private static void testhandleInvalidRecordType(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskHandler.handleInvalidRecordType(mockTaskRecord);
        System.assertEquals(TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, mockTaskRecord.RecordTypeId, 'Record Type ID was not updated to default');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleTaskOwnerChange(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecordWithId.AssignedTo__c = UnitTestDataUtility.MOCK_USER_ID;
        mockTaskList.add(mockTaskRecordWithId);
        mockOldTaskRecord.AssignedTo__c = UnitTestDataUtility.MOCK_USER_ID;
        mockOldTaskRecord.OwnerId = UnitTestDataUtility.SECONDARY_MOCK_USER_ID;
        mockOldTaskMap.put(UnitTestDataUtility.MOCK_TASK_ID, mockOldTaskRecord);
        TaskHandler.handleTaskOwnerChange(mockTaskList, mockOldTaskMap);
        Integer queryCount = Limits.getQueries();
        Test.stopTest();
        System.assertEquals(null, mockTaskRecordWithId.AssignedTo__c, 'Assigned to was not reset back to null');
        System.assertEquals(1, queryCount, 'Query for agent role check was not made');
    }
    
    @isTest
    private static void testHandleTaskOwnerChangeForStageOrchestration(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecordWithId.AssignedTo__c = UnitTestDataUtility.MOCK_USER_ID;
        mockTaskList.add(mockTaskRecordWithId);
        mockOldTaskRecord.OwnerId = UnitTestDataUtility.SECONDARY_MOCK_USER_ID;
        mockOldTaskMap.put(UnitTestDataUtility.MOCK_TASK_ID, mockOldTaskRecord);
        TaskHandler.handleTaskOwnerChange(mockTaskList, mockOldTaskMap);
        Integer queryCount = Limits.getQueries();
        Test.stopTest();
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockTaskRecordWithId.AssignedTo__c, 'Assigned to was set to null');
        System.assertEquals(1, queryCount, 'Query for agent role check was not made');
    }
    
    @isTest
    private static void testHandleTaskDelete(){
        TaskHandlerUtility.mockBoolean = true;
        mockTaskList.add(mockTaskRecord);
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskHandler.handleTaskDelete(mockTaskList);
        List<ApexPages.Message> errors = ApexPages.getMessages();
        Test.stopTest();
        System.assertEquals(1, errors.size(), 'One error was not in the error list');
        System.assertEquals(Label.CL_TaskPreventDeleteMsg, errors.get(0).getDetail(), 'Error received did not match the expected text');
    }
}