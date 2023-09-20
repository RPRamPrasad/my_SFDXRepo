@isTest
(seeAllData=false)

public class HHNInsurancePolicyControllerTest {
    
    @testSetup
    private static void testSetup() {
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();
    }
    
    @isTest
    private static void testGetRecordsForHouseholdInsurancePolicies() {
        Account account;
   		TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            List<InsurancePolicy> policies = updatePolicies();
            InsurancePolicy policy = policies.get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
        	agent = TestDataFactory_User.insertUser(agent);
            insertActivities(policy, account, agent);
        }
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNInsurancePolicyController.getRecordsForHouseholdInsurancePolicies(account.Primary_Household__pc, false);
        System.assertEquals(6, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Policy');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountInsurancePolicies() {
        Account account;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
        	account = HHNUtilitiesTest.insertAccount();
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
        	agent = TestDataFactory_User.insertUser(agent);
            insertAccountInsurancePolicy(account, agent);            
       	}
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNInsurancePolicyController.getRecordsForAccountInsurancePolicies(account.Id, false);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Policy');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForHouseholdInsurancePoliciesWithArchive() {
        Account account;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            List<InsurancePolicy> policies = updatePolicies();
            InsurancePolicy policy = policies.get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
        	agent = TestDataFactory_User.insertUser(agent);
            insertActivities(policy, account, agent);
        }
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNInsurancePolicyController.getRecordsForHouseholdInsurancePolicies(account.Primary_Household__pc, true);
        System.assertEquals(6, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Policy');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountInsurancePoliciesWithArchive() {
        Account account;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
        	account = HHNUtilitiesTest.insertAccount();
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
        	agent = TestDataFactory_User.insertUser(agent);
            insertAccountInsurancePolicy(account, agent);
        }
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNInsurancePolicyController.getRecordsForAccountInsurancePolicies(account.Id, true);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Policy');
        Test.stopTest();
    }

    private static void insertAccountInsurancePolicy(Account account, User agent){
        InsurancePolicy policyRecord = new InsurancePolicy();
        policyRecord.NameInsuredId = account.Id;
        policyRecord.Name = '12-34-5678-9';
		insert policyRecord;
        
        insertActivities(policyRecord, account, agent);
    }
    
    private static void insertActivities(InsurancePolicy policy, Account account, User agent) {
        HHNUtilitiesTest.insertEventRecord(policy.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertTaskRecord(policy.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertRecurringTaskRecord(policy.Id, account.PersonContactId, agent.Id);
    }
    
    private static List<InsurancePolicy> updatePolicies() {
        List<InsurancePolicy> policies = [SELECT Id, NameInsuredId, FinServ__Household__c FROM InsurancePolicy];
        InsurancePolicy policy = policies.get(0);
        Account account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
        for (InsurancePolicy ip : policies) {
            ip.FinServ__Household__c = account.Primary_Household__pc;
        }
        update policies;
        policies = [SELECT Id, NameInsuredId, FinServ__Household__c FROM InsurancePolicy];
        return policies;
    }
}