@isTest
(seeAllData=false)
public class JustOneThingAccountControllerTest {

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
        }

        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = JustOneThingAccountController.getRecordsForHouseholdAccounts(account.Primary_Household__pc);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccount() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            account = [SELECT Id, PersonContactId FROM Account WHERE ClientIdentifier__c = '12345678909'];
        }

        Test.startTest();

        List<ActivityOutlineSObjectWrapper> results = JustOneThingAccountController.getRecordsForAccount(account.Id);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    @isTest
    private static void testFailureGetRecordsForAccount() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            account = [SELECT Id, PersonContactId FROM Account WHERE ClientIdentifier__c = '12345678909'];
        }

        Test.startTest();

        List<ActivityOutlineSObjectWrapper> results = JustOneThingAccountController.getRecordsForAccount(null);
        System.assertEquals(0, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }
}