/**
 * @description This is the Apex controller for the AO_QuickActions Aura component
 */
public with sharing class AO_QuickActionsController {
	@TestVisible
	private static boolean mockEventAccess = false;
	@TestVisible
	private static boolean mockTaskAccess = false;
	@TestVisible
	private static Boolean isCatch = false;

	/**
	 * @description Retrieves the access the currently logged in User has to Task and Event
	 * @return A map of accesses the currently logged in user does/does not have
	 */
	@AuraEnabled(cacheable=true)
	public static Map<String, Boolean> getUserAccess() {
		try {
			boolean eventAccess = Event.getSObjectType().getDescribe().isCreateable();
			boolean taskAccess = Task.getSObjectType().getDescribe().isCreateable();
			if (Test.isRunningTest() && UnitTestDataUtility.isUnitTest) {
				eventAccess = mockEventAccess;
			}

			if (Test.isRunningTest() && UnitTestDataUtility.isUnitTest) {
				taskAccess = mockTaskAccess;
			}
			Map<String, Boolean> userAccess = new Map<String, Boolean>();
			userAccess.put('taskAccess', taskAccess);
			userAccess.put('eventAccess', eventAccess);
			if (isCatch) {
				throw new DMLException();
			}
			return userAccess;
		} catch (Exception e) {
			throw new AuraHandledException('Failed to get user access, getUserAccess');
		}
	}
}
