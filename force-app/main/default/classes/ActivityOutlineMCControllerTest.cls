/**
 * @description controller used to quickly mark a task complete or cancelled
 * @Owner CATS
 */
@isTest
(seeAllData=false)
private class ActivityOutlineMCControllerTest {

    private static Task mockTask = UnitTestDataUtility.buildTask(true);
    private static Case mockCase = UnitTestDataUtility.buildCase(false);

    @isTest
    private static void testMarkCompleteCloseTask(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
       	ActivityOutlineMCController.mockLastList.add(mockTask);
       	ActivityOutlineMCController.closeTask(UnitTestDataUtility.MOCK_TASK_ID, TaskHandlerConstants.TASK_STATUS_COMPLETED);
        Task updatedTask = ActivityOutlineMCController.mockLastList.get(0);
        System.assert(updatedTask.Status == TaskHandlerConstants.TASK_STATUS_COMPLETED, 'Status was not updated to completed');
        System.assert(Limits.getDmlStatements() == 0, 'unexpected DML statements occured');
        System.assert(Limits.getQueries() == 2, 'unexpected number of SOQL statements occured');
        Test.stopTest();
    }
    
    @isTest
    private static void testMarkCompleteWithOutcomeCloseTask(){
        Test.startTest();
        String taskOutcome = 'Testing task outcome';
        UnitTestDataUtility.isUnitTest = true;
       	ActivityOutlineMCController.mockLastList.add(mockTask);
       	ActivityOutlineMCController.closeTaskWithOutcome(UnitTestDataUtility.MOCK_TASK_ID, TaskHandlerConstants.TASK_STATUS_COMPLETED, taskOutcome);
        Task updatedTask = ActivityOutlineMCController.mockLastList.get(0);
        System.assert(updatedTask.Status == TaskHandlerConstants.TASK_STATUS_COMPLETED, 'Status was not updated to completed');
        System.assert(updatedTask.Outcome_Added__c, 'Outcome added was not checked');
        System.assert(Limits.getDmlStatements() == 0, 'unexpected DML statements occured');
        System.assert(Limits.getQueries() == 2, 'unexpected number of SOQL statements occured');
        Test.stopTest();
    }
    
    @isTest
    private static void testPromptToCloseCase(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
       	ActivityOutlineMCController.mockLastList.add(mockTask);
		mockCase.reason = '';
		mockCase.Status = CaseHandlerConstants.CASE_STATUS_REQUEST_SUBMITTED;
		ActivityOutlineMCController.mockCaseList.add(mockCase);
        Boolean showPrompt = ActivityOutlineMCController.closePromptOnCase(mockTask.WhatId);
        system.assert(showPrompt == true, 'Did not show prompt as expected');
        Test.stopTest();
    }

}