@isTest
(seeAllData=false)
public class HHNBillingControllerTest {

    @testSetup
    private static void testSetup() {
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();
    }

    @isTest
    private static void testGetRecordsForHouseholdBillingAccounts() {
        Account account;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId, FinServ__Household__c FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
        	insertBillingAccounts(account, agent, policy);
        }

        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNBillingController.getRecordsForHouseholdBillingAccounts(account.Primary_Household__pc, false);

        System.assertEquals(3, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for billingAccount');
        System.assertEquals(2, results.get(1).relatedTasks.size(), 'Did not get the expected amount of related Task count for sfBillingAccount');
        System.assertEquals(2, results.get(2).relatedTasks.size(), 'Did not get the expected amount of related Task count for sfppBillingAccount');

        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountBillingAccounts() {
        Account account;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
            account = HHNUtilitiesTest.insertAccount();
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            insertBillingAccounts(account, agent, null);
       	}

        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNBillingController.getRecordsForAccountBillingAccounts(account.Id, false);

        System.assertEquals(3, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for billingAccount');
        System.assertEquals(2, results.get(1).relatedTasks.size(), 'Did not get the expected amount of related Task count for sfBillingAccount');
        System.assertEquals(2, results.get(2).relatedTasks.size(), 'Did not get the expected amount of related Task count for sfppBillingAccount');

        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForHouseholdBillingAccountsWithArchive() {
        Account account;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId, FinServ__Household__c FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
        	insertBillingAccounts(account, agent, policy);
        }

        Test.startTest();

        List<ActivityOutlineSObjectWrapper> results = HHNBillingController.getRecordsForHouseholdBillingAccounts(account.Primary_Household__pc, true);
        System.assertEquals(3, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for billingAccount');
        System.assertEquals(2, results.get(1).relatedTasks.size(), 'Did not get the expected amount of related Task count for sfBillingAccount');
        System.assertEquals(2, results.get(2).relatedTasks.size(), 'Did not get the expected amount of related Task count for sfppBillingAccount');

        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountBillingAccountsWithArchive() {
        Account account;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
            account = HHNUtilitiesTest.insertAccount();
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            insertBillingAccounts(account, agent, null);
       	}

        Test.startTest();

        List<ActivityOutlineSObjectWrapper> results = HHNBillingController.getRecordsForAccountBillingAccounts(account.Id, true);
        System.assertEquals(3, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for billingAccount');
        System.assertEquals(2, results.get(1).relatedTasks.size(), 'Did not get the expected amount of related Task count for sfBillingAccount');
        System.assertEquals(2, results.get(2).relatedTasks.size(), 'Did not get the expected amount of related Task count for sfppBillingAccount');

        Test.stopTest();
    }

    /**
     *  @description Inserts billing accounts, billing participants, and related activities for test.
     *  @param account
     *  @param agent
     *  @param policy
     */
    public static void insertBillingAccounts(Account account, User agent, InsurancePolicy policy) {
        Billing_Account__c billingAccountRecord = new Billing_Account__c(AccountNumber__c = '1234567890', SourceSystem__c = 'NONE', SourceSystemIdentifier__c = '1234567890~01');
        insert billingAccountRecord;
        Billing_Account__c sfBillingAccountRecord = new Billing_Account__c(AccountNumber__c = '1234567891', SourceSystem__c = 'SF Billing', SourceSystemIdentifier__c = '1234567891~01');
        insert sfBillingAccountRecord;
        Billing_Account__c sfppBillingAccountRecord = new Billing_Account__c(AccountNumber__c = '1234567892', SourceSystem__c = 'SFPP', SourceSystemIdentifier__c = '1234567892~01');
        insert sfppBillingAccountRecord;

        Billing_Participant__c billingParticipant = new Billing_Participant__c(BillingAccountID__c = billingAccountRecord.Id, ParticipantAccountId__c = account.Id, SourceSystemIdentifier__c = '1234567890~01~ABCDEFGHI000');
        Billing_Participant__c sfBillingParticipant = new Billing_Participant__c(BillingAccountID__c = sfBillingAccountRecord.Id, ParticipantAccountId__c = account.Id, SourceSystemIdentifier__c = '1234567891~01~ABCDEFGHI001');
        Billing_Participant__c sfppBillingParticipant = new Billing_Participant__c(BillingAccountID__c = sfppBillingAccountRecord.Id, ParticipantAccountId__c = account.Id, SourceSystemIdentifier__c = '1234567892~01~ABCDEFGHI002');

        if (account.Primary_Household__pc != null) {
            billingParticipant.Primary_Household__c = account.Primary_Household__pc;
            sfBillingParticipant.Primary_Household__c = account.Primary_Household__pc;
            sfppBillingParticipant.Primary_Household__c = account.Primary_Household__pc;
        }
        insert billingParticipant;
        insert sfBillingParticipant;
        insert sfppBillingParticipant;

        HHNUtilitiesTest.insertEventRecord(billingAccountRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertTaskRecord(billingAccountRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertRecurringTaskRecord(billingAccountRecord.Id, account.PersonContactId, agent.Id);

        HHNUtilitiesTest.insertEventRecord(sfBillingAccountRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertTaskRecord(sfBillingAccountRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertRecurringTaskRecord(sfBillingAccountRecord.Id, account.PersonContactId, agent.Id);

        HHNUtilitiesTest.insertEventRecord(sfppBillingAccountRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertTaskRecord(sfppBillingAccountRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertRecurringTaskRecord(sfppBillingAccountRecord.Id, account.PersonContactId, agent.Id);

    }
}