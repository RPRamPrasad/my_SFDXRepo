/** 
* @description LWC controller for Mark Task Complete with outcome 
* @Owner: BabyYoda
*/
@isTest
(seeAllData=false)
private class TaskOutcomeControllerTest {
    
    private static Task mockTask = UnitTestDataUtility.buildTask(true);
    private static UserPermissionAccess userPermAccess = new UserPermissionAccess();
    
    @isTest
    private static void testGetTaskInfo(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
		TaskOutcomeController.mockTaskList.add(mockTask);
    	TaskOutcomeController.getTaskInfo(UnitTestDataUtility.MOCK_TASK_ID);
        System.assertEquals(UnitTestDataUtility.MOCK_TASK_ID, mockTask.Id, 'task return was not the expected task');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetTask(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskOutcomeController.mockTaskList.add(mockTask);
        TaskOutcomeController.getTask(UnitTestDataUtility.MOCK_TASK_ID);
        System.assertEquals(UnitTestDataUtility.MOCK_TASK_ID, mockTask.Id, 'task return was not the expected task');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetOutcomeAccess(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskOutcomeController.mockUserPermList.add(userPermAccess);
        TaskOutcomeController.mockOutcomeAccess = false;
        System.assert(!TaskOutcomeController.getOutcomeAccess(mockTask), 'access to add outcome was sent back as true, expected false');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetOutcomeMaxLength(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        Integer taskDescriptionCharacterLimit = Schema.SObjectType.Task.fields.Description.getLength();
        mockTask.Description = 'test';
        Integer userEnteredDescriptionLength = (taskDescriptionCharacterLimit - mockTask.Description.length());
        Integer valueReturnedFromController = TaskOutcomeController.getOutcomeMaxLength(mockTask);
        System.assertEquals(userEnteredDescriptionLength, valueReturnedFromController, 'available description length did not match');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetAccessErrorMessageOutcomeAlreadyAdded(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTask.Outcome_Added__c = true;
        String errorMessageReturnedByController = TaskOutcomeController.getAccessErrorMessage(mockTask);
        System.assertEquals(TaskOutcomeController.ERROR_TASK_IS_ALREADY_HAS_OUTCOME, errorMessageReturnedByController, 'error message was not was expected');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetAccessErrorMessageIsClosed(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTask.Outcome_Added__c = false;
        TaskOutcomeController.mockIsClosed = true;
        String errorMessageReturnedByController = TaskOutcomeController.getAccessErrorMessage(mockTask);
        System.assertEquals(TaskOutcomeController.ERROR_TASK_IS_ALREADY_CLOSED, errorMessageReturnedByController, 'error message was not was expected');
        Test.stopTest();
    }
    @isTest
    private static void testGetAccessErrorMessageOutcomeIsRecurrance(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTask.Outcome_Added__c = false;
        TaskOutcomeController.mockIsClosed = false;
        TaskOutcomeController.mockIsRecurrance = true;
        String errorMessageReturnedByController = TaskOutcomeController.getAccessErrorMessage(mockTask);
        System.assertEquals(TaskOutcomeController.ERROR_TASK_IS_A_RECURRING_PARENT, errorMessageReturnedByController, 'error message was not was expected');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetAccessErrorMessageIsNotOwnerProxy(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskOutcomeController.mockUserPermList.add(userPermAccess);
        mockTask.Outcome_Added__c = false;
        TaskOutcomeController.mockIsClosed = false;
        TaskOutcomeController.mockIsRecurrance = false;
        String errorMessageReturnedByController = TaskOutcomeController.getAccessErrorMessage(mockTask);
        System.assertEquals(TaskOutcomeController.ERROR_TASK_IS_NOT_OWNED_BY_USERS_PROXY, errorMessageReturnedByController, 'error message was not was expected');
        Test.stopTest();
    }

    @isTest
    private static void testMarkCompleteWithOutcome(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        String outcomeEntered = 'test outcome';
        String errorMessage = '';
        try{
            TaskOutcomeController.markCompleteWithOutcome(mockTask, outcomeEntered);
        }catch(Exception ex){
            errorMessage = ex.getMessage();
        }
        Integer dmlOperationCount = Limits.getDmlStatements();
        System.assertEquals(TaskOutcomeController.ERROR_TASK_UPDATE_FAILED, errorMessage, 'error was not expected error');
        System.assert(dmlOperationCount == 1, 'just 1 DML was not executed');
        Test.stopTest();
    }
    
    @isTest
    private static void testUserCanAddOutcome(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTask.Outcome_Added__c = false;
        TaskOutcomeController.mockUserPermList.add(userPermAccess);
        TaskOutcomeController.mockModifyAllAccess = true;
        boolean returnedValueFromController = TaskOutcomeController.userCanAddOutcome(mockTask);
        System.assert(returnedValueFromController, 'user was not able to add an outcome');
        Test.stopTest();
    }
    
    @isTest
    private static void testUserCanAddOutcomeFalse(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTask.Outcome_Added__c = true;
        TaskOutcomeController.mockUserPermList.add(userPermAccess);
        TaskOutcomeController.mockModifyAllAccess = true;
        boolean returnedValueFromController = TaskOutcomeController.userCanAddOutcome(mockTask);
        System.assert(!returnedValueFromController, 'user was able to add an outcome with outcome added as true');
        Test.stopTest();
    }
    
    @isTest
    private static void testUserHasModifyAllAccess(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskOutcomeController.mockUserPermList.add(userPermAccess);
        boolean returnedValueFromController = TaskOutcomeController.userHasModifyAllAccess();
        System.assert(!returnedValueFromController, 'User has modify all access');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsNotRecurringOrClosed(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        boolean returnedValueFromController = TaskOutcomeController.taskIsNotRecurringOrClosed(mockTask);
        System.assert(returnedValueFromController, 'return value came back as a closed or recurring task');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsNotRecurringOrClosedFalse(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTask.Outcome_Added__c = true;
        boolean returnedValueFromController = TaskOutcomeController.taskIsNotRecurringOrClosed(mockTask);
        System.assert(!returnedValueFromController, 'return value came back as a open task');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskIsEditableByLoggedInUserWithModifyAllAccess(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskOutcomeController.mockUserPermList.add(userPermAccess);
        mockTask.Outcome_Added__c = false;
        TaskOutcomeController.mockModifyAllAccess = true;
        TaskOutcomeController.mockIsOwnerProxy = false;
        boolean returnedValueFromController = TaskOutcomeController.taskIsEditableByLoggedInUser(mockTask);
        System.assert(returnedValueFromController, 'task was not editable by modify all user');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskIsEditableByLoggedInUserWithProxyRelationship(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskOutcomeController.mockUserPermList.add(userPermAccess);
        mockTask.Outcome_Added__c = false;
        TaskOutcomeController.mockModifyAllAccess = false;
        TaskOutcomeController.mockIsOwnerProxy = true;
        boolean returnedValueFromController = TaskOutcomeController.taskIsEditableByLoggedInUser(mockTask);
        System.assert(returnedValueFromController, 'task was not editable by user in the same office as the task owner');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskIsEditableByLoggedInUserWithModifyAllAccessAndOutcomeAlreadyAdded(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        TaskOutcomeController.mockUserPermList.add(userPermAccess);
        mockTask.Outcome_Added__c = true;
        TaskOutcomeController.mockModifyAllAccess = true;
        TaskOutcomeController.mockIsOwnerProxy = false;
        boolean returnedValueFromController = TaskOutcomeController.taskIsEditableByLoggedInUser(mockTask);
        System.assert(!returnedValueFromController, 'task was not editable by modify all user even with an outcome already added');
        Test.stopTest();
    }
    
}