@isTest
(seeAllData=false)
public class JustOneThingBillingControllerTest {

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
    private static void testGetRecordsForHouseholdBillingAccounts() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();

        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId, FinServ__Household__c FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
        	insertBillingAccounts(account);
        }

        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = JustOneThingBillingController.getRecordsForHouseholdBillingAccounts(account.Primary_Household__pc);
        System.assertEquals(3, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountBillingAccounts() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();

       	System.runAs(sysAdminUser) {
            account = [SELECT Id, PersonContactId, Primary_Household__pc FROM Account WHERE ClientIdentifier__c = '12345678909'];
        	insertBillingAccounts(account);
       	}

        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = JustOneThingBillingController.getRecordsForAccountBillingAccounts(account.Id);
        System.assertEquals(3, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    /**
     *  @description Inserts billing accounts and billing participants for test.
     *  @param account
     */
    public static void insertBillingAccounts(Account account) {
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
    }
}