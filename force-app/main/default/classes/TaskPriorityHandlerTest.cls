/** 
* @description handler for task priority
* @Owner: CATS
*/
@isTest
(seeAllData=false)
private class TaskPriorityHandlerTest {

    private static Task mockTaskRecord = UnitTestDataUtility.buildTask(false);
    private static Task mockOldTaskRecord = UnitTestDataUtility.buildTask(true);
    
        
    @isTest
    private static void testHandlePriorityHigh(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Priority = 'Yes';
        TaskPriorityHandler.handlePriority(mockTaskRecord);
        System.assertEquals(TaskHandlerConstants.TASK_PRIORITY_HIGH, mockTaskRecord.Priority, 'Priority was not set to high');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandlePriorityNone(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Priority = 'No';
        TaskPriorityHandler.handlePriority(mockTaskRecord);
        System.assertEquals(TaskHandlerConstants.TASK_PRIORITY_NONE, mockTaskRecord.Priority, 'Priority was not set to none');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandlePriorityOther(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTaskRecord.Priority = 'Test';
        TaskPriorityHandler.handlePriority(mockTaskRecord);
        System.assertEquals('Test', mockTaskRecord.Priority, 'Priority was changed when it should not have been');
        Test.stopTest();
    }
}