@isTest
(seeAllData=false)
public class HHNCaseControllerTest {
    
    @testSetup
    private static void testSetup() {
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();
    }

    @isTest
    private static void testGetRecordsForHouseholdCases() {
        Account account;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId, FinServ__Household__c FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
        	insertCase(account, agent, policy);
        }
       
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNCaseController.getRecordsForHouseholdCases(account.Primary_Household__pc, false);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Case');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountCases() {
        Account account;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
            account = HHNUtilitiesTest.insertAccount();
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            insertCase(account, agent, null);
       	}
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNCaseController.getRecordsForAccountCases(account.Id, false);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Case');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForHouseholdCasesWithArchive() {
        Account account;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            InsurancePolicy policy = [SELECT Id, NameInsuredId, FinServ__Household__c FROM InsurancePolicy].get(0);
            account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
        	insertCase(account, agent, policy);
        }
       
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNCaseController.getRecordsForHouseholdCases(account.Primary_Household__pc, true);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Case');
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordsForAccountCasesWithArchive() {
        Account account;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
       	System.runAs(sysAdminUser) {
            account = HHNUtilitiesTest.insertAccount();
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            insertCase(account, agent, null);
       	}
        
        Test.startTest();
        List<ActivityOutlineSObjectWrapper> results = HHNCaseController.getRecordsForAccountCases(account.Id, true);
        System.assertEquals(1, results.size(), 'Did not get the expected record count');
        System.assertEquals(2, results.get(0).relatedTasks.size(), 'Did not get the expected amount of related Task count for Case');
        Test.stopTest();
    }

    /**
     *  @description Inserts case and related activities for test.
     *  @param account
     *  @param agent
     *  @param policy
     *  @return Case
     */
    public static Case insertCase(Account account, User agent, InsurancePolicy policy){            
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
        
        HHNUtilitiesTest.insertEventRecord(caseRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertTaskRecord(caseRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertRecurringTaskRecord(caseRecord.Id, account.PersonContactId, agent.Id);
        HHNUtilitiesTest.insertCaseNoteRecord(caseRecord.Id);
        
        return caseRecord;
    }    
}