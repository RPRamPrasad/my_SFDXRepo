@isTest
(seeAllData=false)
public class JustOneThingClaimControllerTest {

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
    private static void testGetRecordsForHouseholdClaims() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();

        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
        	insertClaim(account, policy);
        }

        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = JustOneThingClaimController.getRecordsForHouseholdClaims(account.Primary_Household__pc);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountClaims() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
            account = [SELECT Id, PersonContactId, Primary_Household__pc FROM Account WHERE ClientIdentifier__c = '12345678909'];
            insertClaim(account, null);
       	}
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = JustOneThingClaimController.getRecordsForAccountClaims(account.Id);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    /**
     *  @description Inserts claim for test.
     *  @param policy
     *  @return Claim
    */
    public static Claim insertClaim(Account account, InsurancePolicy policy){
        Claim claimRecord = new Claim();
        claimRecord.AccountId = account.Id;
        claimRecord.Name = 'TEST CLAIM';
        if (policy != null) {
            claimRecord.PolicyNumberId = policy.Id;
        }
        if (account.Primary_Household__pc != null) {
            claimRecord.FinServ__Household__c = account.Primary_Household__pc;
        }
        insert claimRecord;
    
        return claimRecord;
    }
}