@isTest
(seeAllData=false)
public class JustOneThingCaseControllerTest {

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
    private static void testGetRecordsForHouseholdCases() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();

        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId, FinServ__Household__c FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
        	insertCase(account, policy);
        }
       
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = JustOneThingCaseController.getRecordsForHouseholdCases(account.Primary_Household__pc);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountCases() {
        Account account;
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
            account = [SELECT Id, PersonContactId, Primary_Household__pc FROM Account WHERE ClientIdentifier__c = '12345678909'];
            insertCase(account, null);
       	}
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = JustOneThingCaseController.getRecordsForAccountCases(account.Id);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        Test.stopTest();
    }

    /**
     *  @description Inserts case for test.
     *  @param account
     *  @param policy
     *  @return Case
     */
    public static Case insertCase(Account account, InsurancePolicy policy){            
        Case caseRecord = new Case();
        caseRecord.AccountId = account.Id;
        caseRecord.ContactId = account.PersonContactId;
        caseRecord.FinServ__Household__c = account.Primary_Household__pc;
        if (policy != null) {
            caseRecord.Insurance_Policy__c  = policy.Id;
            caseRecord.SourceId = policy.Id;
        }
        if (account.Primary_Household__pc != null) {
            caseRecord.FinServ__Household__c = account.Primary_Household__pc;
        }
        insert caseRecord;
        
        
        return caseRecord;
    }
}