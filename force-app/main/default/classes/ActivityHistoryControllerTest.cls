@isTest
(seeAllData=false)
public class ActivityHistoryControllerTest {

    private static final String MOCK_ACCOUNT_ID = '0012300000FakeAAAA';
    private static final String MOCK_CONTACT_ID = '0032300000FakeAAAA';
    private static final String MOCK_EVENT_ID = '00U2300000FakeAAAA';
    private static final String MOCK_HOUSEHOLD_ID = '0012300000FakeAAAA';
    private static final String MOCK_TASK_ID = '00T2300000FakeAAAA';

    private static List<Event> mockedEvents = createMockedEventRecords();
    private static List<Task> mockedTasks = createMockedTaskRecords();

    @isTest
    private static void testGetRecordsForAccountHistory() {
        Test.startTest();
        ActivityHistoryController.mockedTasks = mockedTasks;
        ActivityHistoryController.mockedEvents = mockedEvents;
        List<ActivityOutlineSObjectWrapper> results = ActivityHistoryController.getArchivedRecords(MOCK_ACCOUNT_ID);
        System.assertEquals(3, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, Limits.getQueries(), 'Unexpected SOQL executed');
        Test.stopTest();
    }
    
    @isTest
    private static void testEmptyIdPassed() {
        Test.startTest();
        ActivityHistoryController.mockedTasks = new List<Task>();
        ActivityHistoryController.mockedEvents = new List<Event>();
        List<ActivityOutlineSObjectWrapper> results = ActivityHistoryController.getArchivedRecords('');
        System.assertEquals(0, results.size(), 'Did not get the expected record count');
        System.assertEquals(0, Limits.getQueries(), 'Unexpected SOQL executed');
        Test.stopTest();
    }
    
    @isTest
    private static void testNullIdPassed() {
        Test.startTest();
        ActivityHistoryController.mockedTasks = new List<Task>();
        ActivityHistoryController.mockedEvents = new List<Event>();
        List<ActivityOutlineSObjectWrapper> results = ActivityHistoryController.getArchivedRecords(null);
        System.assertEquals(0, results.size(), 'Did not get the expected record count');
        System.assertEquals(0, Limits.getQueries(), 'Unexpected SOQL executed');
        Test.stopTest();
    }

    private static List<Event> createMockedEventRecords(){
        List<Event> eventList = new List<Event>();
        eventList.add(createMockedEventRecord());
        return eventList;
    }

    private static Event createMockedEventRecord(){
        String eventJSON = '{"attributes":{"type":"Event","url":"/services/data/v51.0/sobjects/Event/00U2300000FakeAAAA"},'
            			+'"Id":"00U2300000FakeAAAA", "CreatedDate":"2020-04-15T17:54:26.000+0000", "LastModifiedDate":"2020-04-15T17:54:26.000+0000",'
            			+'"What":{"attributes":{"type":"Name","url":"/services/data/v51.0/sobjects/Case/5001900000FAKEAAAA"},"Id":"0011900000FAKEAAAA",'
            			+'"Name": "Mock Account Name"}}';
        Event eventRecord = (Event) JSON.deserialize(eventJSON, Event.class );
        eventRecord.FinServ__Household__c = MOCK_HOUSEHOLD_ID;
        eventRecord.Id = MOCK_EVENT_ID;
        eventRecord.WhoId = MOCK_CONTACT_ID;
        eventRecord.Subject = 'Mock Subject';
        eventRecord.IsAllDayEvent = true;
        eventRecord.ActivityDate = Date.today();
        eventRecord.WhatId = MOCK_ACCOUNT_ID;
        eventRecord.description = 'Mock Event Description';
        return eventRecord;
    }

    private static Task createMockedLogRecord(){
        Task taskRecord = createMockedTaskRecord();
        taskRecord.ActivityDate = Date.today();
        taskRecord.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Log_Call').getRecordTypeId();
        return taskRecord;
    }

    private static List<Task> createMockedTaskRecords(){
        List<Task> taskList = new List<Task>();
        taskList.add(createMockedTaskRecord());
        taskList.add(createMockedLogRecord());
        return taskList;
    }

    private static Task createMockedTaskRecord(){
        String taskJSON = '{"attributes":{"type":"Task","url":"/services/data/v51.0/sobjects/Task/00T2300000FakeAAAA"},'
            			+'"Id":"00T2300000FakeAAAA", "CreatedDate":"2020-04-15T17:54:26.000+0000", "LastModifiedDate":"2020-04-15T17:54:26.000+0000",'
            			+'"What":{"attributes":{"type":"Name","url":"/services/data/v51.0/sobjects/Case/5001900000FAKEAAAA"},"Id":"0011900000FAKEAAAA",'
            			+'"Name": "Mock Account Name"},'
                        +'"Who":{"attributes":{"type":"Name","url":"/services/data/v51.0/sobjects/Account/50012300000FakeAAAA"},"Id":"0012300000FakeAAAA"},'
                        +'"Name": "Mock Account Name"}}';
        Task taskRecord = (Task) JSON.deserialize(taskJSON, Task.class );
        taskRecord.FinServ__Household__c = MOCK_HOUSEHOLD_ID;
        taskRecord.Id = MOCK_TASK_ID;
        taskRecord.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Task').getRecordTypeId();
        taskRecord.Status = 'Not Started';
        taskRecord.WhoId = MOCK_CONTACT_ID;
        taskRecord.Subject = 'Mock Subject';
        taskRecord.WhatId = MOCK_ACCOUNT_ID;
        taskRecord.description = 'Mock Description';
        return taskRecord;
    }
}