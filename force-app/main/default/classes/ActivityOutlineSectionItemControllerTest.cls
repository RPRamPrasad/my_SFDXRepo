@isTest
(seeAllData=false)
private class ActivityOutlineSectionItemControllerTest {
    private static ActivityOutlineSObjectWrapper mockSObject = buildSO();
    private static Task mockTask = UnitTestDataUtility.buildTask(true);
    private static User mockUser = UnitTestDataUtility.buildUser();
    private static UserPermissionAccess userPermAccess = new UserPermissionAccess();

    private static ActivityOutlineSObjectWrapper buildSO(){
        ActivityOutlineSObjectWrapper sObjectRecord = new ActivityOutlineSObjectWrapper();
        sObjectRecord.sobjectRecordId = '00Tm000FAKEbbBbBBB';
        sObjectRecord.Status = 'New';
        return sObjectRecord;
    }
	
    @isTest
    private static void testUserCanMarkCompleteWithOutcome(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        ActivityOutlineSectionItemController.mockUserPermList.add(userPermAccess);
        ActivityOutlineSectionItemController.mockOutcomeAccess = false;
        System.assert(!ActivityOutlineSectionItemController.userCanMarkCompleteWithOutcome(mockSObject), 'access to add outcome was sent back as true, expected false');
        Test.stopTest();
    }
    
    @isTest
    private static void testuserCanEdit(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        ActivityOutlineSectionItemController.mockUserPermList.add(userPermAccess);
        ActivityOutlineSectionItemController.mockOutcomeAccess = false;
        System.assert(!ActivityOutlineSectionItemController.userCanEdit(mockSObject), 'access to add outcome was sent back as true, expected false');
        Test.stopTest();
    }
	
    @isTest
    private static void testUserCanAddOutcome(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTask.Outcome_Added__c = false;
        ActivityOutlineSectionItemController.mockUserPermList.add(userPermAccess);
        ActivityOutlineSectionItemController.mockModifyAllAccess = true;
        boolean returnedValueFromController = ActivityOutlineSectionItemController.userCanAddOutcome(mockTask);
        System.assert(returnedValueFromController, 'user was not able to add an outcome');
        Test.stopTest();
    }
    
    @isTest
    private static void testUserHasModifyAllAccess(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        ActivityOutlineSectionItemController.mockUserPermList.add(userPermAccess);
        boolean returnedValueFromController = ActivityOutlineSectionItemController.userHasModifyAllAccess();
        System.assert(!returnedValueFromController, 'User has modify all access');
        Test.stopTest();
    }

    @isTest
    private static void testTaskIsEditableByLoggedInUserWithModifyAllAccess(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        ActivityOutlineSectionItemController.mockUserPermList.add(userPermAccess);
        mockTask.Outcome_Added__c = false;
        ActivityOutlineSectionItemController.mockModifyAllAccess = true;
        ActivityOutlineSectionItemController.mockIsOwnerProxy = false;
        boolean returnedValueFromController = ActivityOutlineSectionItemController.taskIsEditableByLoggedInUser(mockTask);
        System.assert(returnedValueFromController, 'task was not editable by modify all user');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskIsEditableByLoggedInUserWithModifyAllAccessAndOutcomeAlreadyAdded(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        ActivityOutlineSectionItemController.mockUserPermList.add(userPermAccess);
        mockTask.Outcome_Added__c = true;
        ActivityOutlineSectionItemController.mockModifyAllAccess = true;
        ActivityOutlineSectionItemController.mockIsOwnerProxy = false;
        boolean returnedValueFromController = ActivityOutlineSectionItemController.taskIsEditableByLoggedInUser(mockTask);
        System.assertEquals(true, returnedValueFromController, 'task was not editable by modify all user even with an outcome already added');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskIsEditableByLoggedInUserWithProxyRelationship(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        ActivityOutlineSectionItemController.mockUserPermList.add(userPermAccess);
        mockTask.Outcome_Added__c = false;
        ActivityOutlineSectionItemController.mockModifyAllAccess = false;
        ActivityOutlineSectionItemController.mockIsOwnerProxy = true;
        boolean returnedValueFromController = ActivityOutlineSectionItemController.taskIsEditableByLoggedInUser(mockTask);
        System.assert(returnedValueFromController, 'task was not editable by user in the same office as the task owner');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsNotRecurringOrClosed(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        boolean returnedValueFromController = ActivityOutlineSectionItemController.taskIsNotRecurringOrClosed(mockTask);
        System.assert(returnedValueFromController, 'return value came back as a closed or recurring task');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsNotRecurringOrClosedFalse(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockTask.Outcome_Added__c = true;
        boolean returnedValueFromController = ActivityOutlineSectionItemController.taskIsNotRecurringOrClosed(mockTask);
        System.assert(!returnedValueFromController, 'return value came back as a open task');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetAccessErrorMessageIsNotOwnerProxy(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        ActivityOutlineSectionItemController.mockUserPermList.add(userPermAccess);
        String errorMessageReturnedByController = ActivityOutlineSectionItemController.getAccessErrorMessage();
        System.assertEquals(ActivityOutlineSectionItemController.ERROR_TASK_NO_ACCESS_TO_THIS_ACTION, errorMessageReturnedByController, 'error message was not was expected');
        Test.stopTest();
    }

}