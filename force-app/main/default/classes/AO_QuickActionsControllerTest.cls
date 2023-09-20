@isTest(seeAllData=false)
private class AO_QuickActionsControllerTest {
	@isTest
	private static void testControllerTrue() {
		Test.startTest();
		UnitTestDataUtility.isUnitTest = true;
		AO_QuickActionsController.mockEventAccess = true;
		Map<String, Boolean> userAccess = AO_QuickActionsController.getUserAccess();
		System.assert(userAccess.get('eventAccess'), 'was not true');
		Test.stopTest();
	}

	@isTest
	private static void testControllerFalse() {
		Test.startTest();
		UnitTestDataUtility.isUnitTest = true;
		Map<String, Boolean> userAccess = AO_QuickActionsController.getUserAccess();
		System.assert(!userAccess.get('eventAccess'), 'was not false');
		Test.stopTest();
	}

	@isTest
	private static void testGetUserAccessOnTaskTrue() {
		Test.startTest();
		UnitTestDataUtility.isUnitTest = true;
		AO_QuickActionsController.mockTaskAccess = true;
		Map<String, Boolean> userAccess = AO_QuickActionsController.getUserAccess();
		System.assert(userAccess.get('taskAccess'), 'was not true');
		Test.stopTest();
	}

	@isTest
	private static void testGetUserAccessOnTaskFalse() {
		Test.startTest();
		UnitTestDataUtility.isUnitTest = true;
		Map<String, Boolean> userAccess = AO_QuickActionsController.getUserAccess();
		System.assert(!userAccess.get('taskAccess'), 'Task Create Access is true');
		Test.stopTest();
	}

	@isTest
	private static void testGetUserAccessError() {
		Test.startTest();
		UnitTestDataUtility.isUnitTest = true;
		try {
			AO_QuickActionsController.isCatch = true;
			Map<String, Boolean> userAccess = AO_QuickActionsController.getUserAccess();
		} catch (Exception e) {
			System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception to match.');
		}
		Test.stopTest();
	}
}
