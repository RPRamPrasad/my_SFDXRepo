@isTest
(seeAllData=false)
public class HHNClaimControllerTest {
    
    @testSetup
    private static void testSetup() {
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();
    }
    
    @isTest
    private static void testGetRecordsForHouseholdClaims() {
        Account account;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
        	insertClaim(account, agent, policy);
        }

        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNClaimController.getRecordsForHouseholdClaims(account.Primary_Household__pc, false);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Claim');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountClaims() {
        Account account;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
            account = HHNUtilitiesTest.insertAccount();
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            insertClaim(account, agent, null);
       	}
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNClaimController.getRecordsForAccountClaims(account.Id, false);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Claim');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForHouseholdClaimsWithArchive() {
        Account account;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
        	insertClaim(account, agent, policy);
        }

        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNClaimController.getRecordsForHouseholdClaims(account.Primary_Household__pc, true);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Claim');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountClaimsWithArchive() {
        Account account;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
            account = HHNUtilitiesTest.insertAccount();
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            insertClaim(account, agent, null);
       	}
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNClaimController.getRecordsForAccountClaims(account.Id, true);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Claim');
        Test.stopTest();
    }

    /**
     *  @description Inserts claim and related activities for test.
     *  @param account
     *  @param agent
     *  @param policy
     *  @return Claim
     */
    public static Claim insertClaim(Account account, User agent, InsurancePolicy policy){
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
        
        HHNUtilitiesTest.insertEventRecord(claimRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertTaskRecord(claimRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertRecurringTaskRecord(claimRecord.Id, account.PersonContactId, agent.Id);
        
        return claimRecord;
    }
}