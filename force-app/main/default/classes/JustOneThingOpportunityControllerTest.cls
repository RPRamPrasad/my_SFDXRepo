@isTest
(seeAllData=false)
public class JustOneThingOpportunityControllerTest {

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
    private static void testGetRecordsForHouseholdOpportunities() {        
        Account account;
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId, FinServ__Household__c FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
        	insertOpportunity(account);
        }
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = JustOneThingOpportunityController.getRecordsForHouseholdOpportunities(account.Primary_Household__pc);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountOpportunities() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
            account = [SELECT Id, PersonContactId, Primary_Household__pc FROM Account WHERE ClientIdentifier__c = '12345678909'];
            insertOpportunity(account);
       	}
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = JustOneThingOpportunityController.getRecordsForAccountOpportunities(account.Id);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    /**
     *  @description Inserts opportunity
     *  @param account
     *  @return Opportunity
     */
    public static Opportunity insertOpportunity(Account account){
        Opportunity oppRecord = new Opportunity();
        oppRecord.AccountId = account.Id;
        oppRecord.LOB__c = 'A';
        oppRecord.Name = 'TEST OPPORTUNITY';
        oppRecord.StageName = 'New';
        oppRecord.CloseDate = Date.valueOf('2022-06-17');
        if (account.Primary_Household__pc != null) {
            oppRecord.FinServ__Household__c = account.Primary_Household__pc;
        }
        insert oppRecord;

        return oppRecord;
    }
    
}