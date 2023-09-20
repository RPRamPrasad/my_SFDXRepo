/** 
* @description handler adding an outcomne to task test
* @Owner: CATS
*/
@isTest
(seeAllData=false)
private class TaskOutcomeHandlerTest {

    private static Task mockTaskRecord = UnitTestDataUtility.buildTask(false);
    private static Task mockOldTaskRecord = UnitTestDataUtility.buildTask(true);
    
    @isTest
    private static void testHandleCloseTaskWithOutcome(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        String todaysDateTime = DateTime.now().format('MM/dd/yyyy');
        mockTaskRecord.Outcome_Added__c = true;
        mockOldTaskRecord.Outcome_Added__c = false;
        mockTaskRecord.Description = 'New Task Description';
        mockOldTaskRecord.Description = 'Old Task Description';
        TaskOutcomeHandler.handleCloseTaskWithOutcome(mockTaskRecord, mockOldTaskRecord);
        System.assert(mockTaskRecord.Description != 'New Task Description', 'Outcome was not appended to description');
        System.assert(mockTaskRecord.Description.contains('Old Task Description'), 'Old Task records description was not appended to description');
        System.assert(mockTaskRecord.Description.contains(UserInfo.getName()), 'Users name was not appended onto the task description');
        System.assert(mockTaskRecord.Description.contains(todaysDateTime), 'Todays date time was not appended onto the task description');
        System.assert(mockTaskRecord.Description.contains('Task Outcome:'), 'Task outcome string was not appended onto the description');
        Test.stopTest();
    }

    
}