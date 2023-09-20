@isTest
(seeAllData=false)
public class HHNAccountControllerTest {

    @testSetup
    private static void testSetup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();

        System.runAs(sysAdminUser) {
            Account account = HHNUtilitiesTest.insertAccount();
            Account householdAccount = HHNUtilitiesTest.insertHousehold();
            account.Primary_Household__pc = householdAccount.Id;
            update account;

            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);

        }
    }

    @isTest
    private static void testGetRecordsForHouseholdAccounts() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            account = [SELECT Id, PersonContactId, Primary_Household__pc FROM Account WHERE ClientIdentifier__c = '12345678909'];
            User agent = [SELECT Id FROM User WHERE Alias = 'TEST'];
            insertActivities(account, agent);
        }

        Test.startTest();

        List<ActivityOutlineSObjectWrapper> results = HHNAccountController.getRecordsForHouseholdAccounts(account.Primary_Household__pc, false);

        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        /**
         * As of 07/26/2023:
         * 
         * Commented out due to following error on TaskRelation for recurring tasks: Shared activities does not support recurring Tasks.
         * 
         * This issue is only observed when the recurring Task is created in Apex, but not through the UI
         * Until TaskRelations for recurring Tasks may be created, this test line will remain inactive
         */
        // System.assertEquals(4, results.get(0).relatedTasks.size(), 'Did not get the expected record count');

        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccount() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            account = [SELECT Id, PersonContactId FROM Account WHERE ClientIdentifier__c = '12345678909'];
            User agent = [SELECT Id FROM User WHERE Alias = 'TEST'];
            insertActivities(account, agent);
        }

        Test.startTest();

        List<ActivityOutlineSObjectWrapper> results = HHNAccountController.getRecordsForAccount(account.Id, false);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        /**
         * As of 07/26/2023:
         * 
         * Commented out due to following error on TaskRelation for recurring tasks: Shared activities does not support recurring Tasks.
         * 
         * This issue is only observed when the recurring Task is created in Apex, but not through the UI
         * Until TaskRelations for recurring Tasks may be created, this test line will remain inactive
         */
        // System.assertEquals(4, results.get(0).relatedTasks.size(), 'Did not get the expected record count');

        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForHouseholdAccountsWithArchive() {
        Account account;
       	User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            account = [SELECT Id, PersonContactId, Primary_Household__pc FROM Account WHERE ClientIdentifier__c = '12345678909'];
            User agent = [SELECT Id FROM User WHERE Alias = 'TEST'];
            insertActivities(account, agent);
        }

        Test.startTest();

        List<ActivityOutlineSObjectWrapper> results = HHNAccountController.getRecordsForHouseholdAccounts(account.Primary_Household__pc, true);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        /**
         * As of 07/26/2023:
         * 
         * Commented out due to following error on TaskRelation for recurring tasks: Shared activities does not support recurring Tasks.
         * 
         * This issue is only observed when the recurring Task is created in Apex, but not through the UI
         * Until TaskRelations for recurring Tasks may be created, this test line will remain inactive
         */
        // System.assertEquals(4, results.get(0).relatedTasks.size(), 'Did not get the expected record count');

        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountWithArchive() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            account = [SELECT Id, PersonContactId FROM Account WHERE ClientIdentifier__c = '12345678909'];
            User agent = [SELECT Id FROM User WHERE Alias = 'TEST'];
            insertActivities(account, agent);
        }

        Test.startTest();

        List<ActivityOutlineSObjectWrapper> results = HHNAccountController.getRecordsForAccount(account.Id, true);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        /**
         * As of 07/26/2023:
         * 
         * Commented out due to following error on TaskRelation for recurring tasks: Shared activities does not support recurring Tasks.
         * 
         * This issue is only observed when the recurring Task is created in Apex, but not through the UI
         * Until TaskRelations for recurring Tasks may be created, this test line will remain inactive
         */
        // System.assertEquals(4, results.get(0).relatedTasks.size(), 'Did not get the expected record count');

        Test.stopTest();
    }

    private static void insertActivities(Account account, User agent) {
        HHNUtilitiesTest.insertEventRecord(account.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertEventRecord(null, account.PersonContactId, agent.Id);

        HHNUtilitiesTest.insertTaskRecord(account.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertRecurringTaskRecord(account.Id, account.PersonContactId, agent.Id);

        HHNUtilitiesTest.insertTaskRecord(null, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertRecurringTaskRecord(null, account.PersonContactId, agent.Id);

        HHNUtilitiesTest.insertAccountNoteRecord(account.Id);
        HHNUtilitiesTest.insertInteractionSummaryRecord(account.Id);
        HHNUtilitiesTest.insertVirtualMeetingRecord(account.Id);
    }
}