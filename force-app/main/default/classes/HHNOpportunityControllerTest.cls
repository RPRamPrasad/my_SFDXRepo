@isTest
(seeAllData=false)
public class HHNOpportunityControllerTest {
    
    @testSetup
    private static void testSetup() {
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();
    }

    @isTest
    private static void testGetRecordsForHouseholdOpportunities() {        
        Account account;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId, FinServ__Household__c FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
        	insertOpportunity(account, agent, policy);
        }
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNOpportunityController.getRecordsForHouseholdOpportunities(account.Primary_Household__pc, false);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Opportunity');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountOpportunities() {
        Account account;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
            account = HHNUtilitiesTest.insertAccount();
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            insertOpportunity(account, agent, null);
       	}
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNOpportunityController.getRecordsForAccountOpportunities(account.Id, false);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Opportunity');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForHouseholdOpportunitiesWithArchive() {
        Account account;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId, FinServ__Household__c FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
            policy.FinServ__Household__c = account.Primary_Household__pc;
            update policy;
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            insertOpportunity(account, agent, policy);
        }
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNOpportunityController.getRecordsForHouseholdOpportunities(account.Primary_Household__pc, true);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Opportunity');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountOpportunitiesWithArchive() {
        Account account;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
            account = HHNUtilitiesTest.insertAccount();
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            insertOpportunity(account, agent, null);
       	}
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNOpportunityController.getRecordsForAccountOpportunities(account.Id, true);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Opportunity');
        Test.stopTest();
    }

	/**
     *  @description Inserts opportunity and related activities for test.
     *  @param account
     *  @param agent
     *  @param policy
     *  @return Opportunity
     */
    public static Opportunity insertOpportunity(Account account, User agent, InsurancePolicy policy){
        Opportunity oppRecord = new Opportunity();
        oppRecord.AccountId = account.Id;
        oppRecord.LOB__c = 'A';
        oppRecord.Name = 'TEST OPPORTUNITY';
        oppRecord.StageName = 'Closed';
        oppRecord.CloseDate = Date.valueOf('2022-06-17');
        if (account.Primary_Household__pc != null) {
            oppRecord.FinServ__Household__c = account.Primary_Household__pc;
        }
        insert oppRecord;
                
        HHNUtilitiesTest.insertEventRecord(oppRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertTaskRecord(oppRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertRecurringTaskRecord(oppRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertOpportunityNoteRecord(oppRecord.Id);
        
        return oppRecord;
    }
}