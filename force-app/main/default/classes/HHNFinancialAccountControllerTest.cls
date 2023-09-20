@isTest
(seeAllData=false)

public class HHNFinancialAccountControllerTest {
   
    @testSetup
    private static void testSetup() {
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();
    }
    
    @isTest
    private static void testGetRecordsForHouseholdFinancialAccounts() {
        Account account;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
        	insertFinancialAccount(account, agent, policy);
        }

        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNFinancialAccountController.getRecordsForHouseholdFinancialAccounts(account.Primary_Household__pc, false);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountFinancialAccounts() {
        Account account;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            account = HHNUtilitiesTest.insertAccount();
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            insertFinancialAccount(account, agent, null);
        }
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNFinancialAccountController.getRecordsForAccountFinancialAccounts(account.Id, false);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForHouseholdFinancialAccountsWithArchive() {
        Account account;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
        	insertFinancialAccount(account, agent, policy);
        }

        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNFinancialAccountController.getRecordsForHouseholdFinancialAccounts(account.Primary_Household__pc, true);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountFinancialAccountsWithArchive() {
        Account account;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            account = HHNUtilitiesTest.insertAccount();
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            insertFinancialAccount(account, agent, null);
        }
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNFinancialAccountController.getRecordsForAccountFinancialAccounts(account.Id, true);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    private static void insertFinancialAccount(Account account, User agent, InsurancePolicy policy) {
        FinServ__FinancialAccount__c faRecord = new FinServ__FinancialAccount__c();
        faRecord.FinServ__PrimaryOwner__c = account.Id;
        if (policy != null) {
        	faRecord.FinServ__InsurancePolicy__c = policy.Id;

        }
        if (account.Primary_Household__pc != null) {
        	faRecord.FinServ__Household__c = account.Primary_Household__pc;
        }
        insert faRecord;
        
        HHNUtilitiesTest.insertEventRecord(faRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertTaskRecord(faRecord.Id, account.PersonContactId, agent.Id);    
    }
}