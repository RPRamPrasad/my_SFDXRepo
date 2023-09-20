@isTest
(seeAllData=false)
public class JustOneThingPolicyControllerTest {

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
    private static void testGetRecordsForHouseholdInsurancePolicies() {
        Account account;
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            List<InsurancePolicy> policies = updatePolicies();
            InsurancePolicy policy = policies.get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
        }
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = JustOneThingPolicyController.getRecordsForHouseholdInsurancePolicies(account.Primary_Household__pc);
        System.assertEquals(5, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountInsurancePolicies() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
        	account = [SELECT Id, PersonContactId, Primary_Household__pc FROM Account WHERE ClientIdentifier__c = '12345678909'];
            insertAccountInsurancePolicy(account);            
       	}
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = JustOneThingPolicyController.getRecordsForAccountInsurancePolicies(account.Id);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    private static void insertAccountInsurancePolicy(Account account){
        InsurancePolicy policyRecord = new InsurancePolicy();
        policyRecord.NameInsuredId = account.Id;
        policyRecord.Name = '12-34-5678-9';
		insert policyRecord;
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