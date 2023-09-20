@isTest
(seeAllData=false)
private class CaseMergingRulesTest {
    
    
    @testSetup
    private static void testSetUp(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CaseTestDataUtility.createAccount();
            CaseTestDataUtility.createSecondaryAccount();
            CaseTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), CaseTestDataUtility.getAccount());
            CaseTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), CaseTestDataUtility.getSecondaryAccount());
        }
    }

    @isTest
    private static void testCaseMergingRuleDifferentRecordType(){
        Account acct = CaseTestDataUtility.getAccount();
        User proxy = TestUserSetupUtility.getProxyUser();
        User agent = TestUserSetupUtility.getAgentUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        Test.startTest();
        Case csrCase = new Case();
        Case onboardingCase = new Case();
        System.runAs(agent){
            onboardingCase = CaseTestDataUtility.buildCustomerOnboarding(acct, proxy.Id);
            csrCase = CaseTestDataUtility.buildCustomerServiceRequest(acct, proxy.Id);
            insert csrCase;
            insert onboardingCase;
        }
        Case csrResult = CaseTestDataUtility.retrieveCaseAfterInsert(csrCase);
        Case onboardingResult = CaseTestDataUtility.retrieveCaseAfterInsert(onboardingCase);
        String errorMessage = '';
        System.runAs(agent){  
            try{
                Database.MergeResult result;
                result = Database.merge(csrResult, onboardingResult);
            }catch(Exception ex){
                errorMessage = ex.getMessage();
            }
        }
        //System.assert(errorMessage.contains(CaseMergingRules.ERROR_MERGE_BLOCK), 'unexpected error message Actual: ' + errorMessage);
        System.assert(errorMessage != '', 'unexpected error message Actual: ' + errorMessage);
        Test.stopTest();
    }
}