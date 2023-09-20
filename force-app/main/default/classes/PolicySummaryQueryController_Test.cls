/**
* @description This is the test class for the PolicySummaryQueryController Apex class.
* @Date: 09/26/2022
* @author: Team NSYNC - Wong Soon CIWA 
*/
@isTest(SeeAllData=false)
public class PolicySummaryQueryController_Test {
    @TestSetup
    static void makeData() {
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();
    }
    
    // getPolicies Tests
    
    /**
* @description Test for Single Account (Account 1)
*/
    @isTest
    private static void getPoliciesForRollupForAccount1() {
        // Prep
        Account acctUnderTest = TestDataFactory_InsurancePolicy.getAccountByClientId(
            TestDataFactory_InsurancePolicy.ACCOUNT_ONE_CLIENT_ID
        );
        User actInsHealthUser = TestDataFactory_User_Wrapper.generateActiveInsuranceandHealthUser('TEST', '12345678916');
        actInsHealthUser = TestDataFactory_User.insertUser(actInsHealthUser);
        List<String> expectedSourceSysIds = new List<String>{
            TestDataFactory_InsurancePolicy.POLICY_PRIVATE_PASSENGER_SRC_SYS_ID,
                TestDataFactory_InsurancePolicy.POLICY_BUSINESS_FIRE_SRC_SYS_ID,
                TestDataFactory_InsurancePolicy.POLICY_ASSURANT_HEALTH_SRC_SYS_ID,
                TestDataFactory_InsurancePolicy.POLICY_COMMERCIAL_AUTO_SRC_SYS_ID
                };
                System.runAs(actInsHealthUser){  
                    List<InsurancePolicy> mockHHPolicies = new List<InsurancePolicy>();
        for (String srcId : expectedSourceSysIds) {
            mockHHPolicies.add(TestDataFactory_InsurancePolicy.getInsurancePolicyBySourceSystemId(srcId));
        }
        PolicySummaryQueryController.mockPolicies = mockHHPolicies;
    }
        System.assert(getPoliciesForRollupTest(acctUnderTest, 4, expectedSourceSysIds),'Failed to run getPoliciesForRollupTest with provided parameters');
        
    }

    
    /**
* @description Test for Single Account (Account 2)
*/
    @isTest
    private static void getPoliciesForRollupForAccount2() {
        // Prep
        Account acctUnderTest = TestDataFactory_InsurancePolicy.getAccountByClientId(
            TestDataFactory_InsurancePolicy.ACCOUNT_TWO_CLIENT_ID
        );
        User actInsHealthUser = TestDataFactory_User_Wrapper.generateActiveInsuranceandHealthUser('TEST', '12345678916');
        actInsHealthUser = TestDataFactory_User.insertUser(actInsHealthUser);
        List<String> expectedSourceSysIds = new List<String>{
            TestDataFactory_InsurancePolicy.POLICY_PRIVATE_PASSENGER_SRC_SYS_ID,
                TestDataFactory_InsurancePolicy.POLICY_RENTERS_POLICY_SRC_SYS_ID,
                TestDataFactory_InsurancePolicy.POLICY_SHORT_TERM_LIFE_SRC_SYS_ID,
                TestDataFactory_InsurancePolicy.POLICY_ASSURANT_HEALTH_SRC_SYS_ID,
                TestDataFactory_InsurancePolicy.POLICY_COMMERCIAL_AUTO_SRC_SYS_ID
                };
                System.runAs(actInsHealthUser){ 
                    List<InsurancePolicy> mockHHPolicies = new List<InsurancePolicy>();
        for (String srcId : expectedSourceSysIds) {
            mockHHPolicies.add(TestDataFactory_InsurancePolicy.getInsurancePolicyBySourceSystemId(srcId));
        }
        PolicySummaryQueryController.mockPolicies = mockHHPolicies;
    }
        System.assert(getPoliciesForRollupTest(acctUnderTest, 5, expectedSourceSysIds),'Failed to run getPoliciesForRollupTest with provided parameters');
    }
    /**
* @description Test for Single Account (Account 2) Error
*/
    @isTest
    private static void getPoliciesForRollupForAccount2Fail() {
        // Prep
        Account acctUnderTest = TestDataFactory_InsurancePolicy.getAccountByClientId(
            TestDataFactory_InsurancePolicy.ACCOUNT_TWO_CLIENT_ID
        );
        User actInsHealthUser = TestDataFactory_User_Wrapper.generateActiveInsuranceandHealthUser('TEST', '12345678916');
        actInsHealthUser = TestDataFactory_User.insertUser(actInsHealthUser);
        
                    PolicySummaryQueryController.mockPolicies = null;
        try {
         Test.startTest();
            System.runAs(actInsHealthUser){
            PolicySummaryQueryController.fetchAllPolicies(
                acctUnderTest.Id,
                acctUnderTest.RecordTypeId
            );
            }
            Test.stopTest();
            
        }
        catch (AuraHandledException e) {
            System.assert('Script-thrown exception'.equals(e.getmessage()), 'The error message is not expected:' + e.getMessage());
        }
    
    }
    
    /**
* @description Test for a Household
*/
    @isTest
    private static void getPoliciesForRollupForHousehold() {
        // Prep
        Account acctUnderTest = TestDataFactory_InsurancePolicy.getPrimaryHouseholdByMemberClientId(
            TestDataFactory_InsurancePolicy.ACCOUNT_ONE_CLIENT_ID
        );
        User actInsHealthUser = TestDataFactory_User_Wrapper.generateActiveInsuranceandHealthUser('TEST', '12345678916');
        actInsHealthUser = TestDataFactory_User.insertUser(actInsHealthUser);
  List<String> expectedSourceSysIds = new List<String>{
            TestDataFactory_InsurancePolicy.POLICY_PRIVATE_PASSENGER_SRC_SYS_ID,
                TestDataFactory_InsurancePolicy.POLICY_RENTERS_POLICY_SRC_SYS_ID,
                TestDataFactory_InsurancePolicy.POLICY_BUSINESS_FIRE_SRC_SYS_ID,
                TestDataFactory_InsurancePolicy.POLICY_SHORT_TERM_LIFE_SRC_SYS_ID,
                TestDataFactory_InsurancePolicy.POLICY_ASSURANT_HEALTH_SRC_SYS_ID,
                TestDataFactory_InsurancePolicy.POLICY_COMMERCIAL_AUTO_SRC_SYS_ID
                };
                System.runAs(actInsHealthUser){
                    List<InsurancePolicy> mockHHPolicies = new List<InsurancePolicy>();
        for (String srcId : expectedSourceSysIds) {
            mockHHPolicies.add(TestDataFactory_InsurancePolicy.getInsurancePolicyBySourceSystemId(srcId));
        }
        PolicySummaryQueryController.mockPolicies = mockHHPolicies;
    }
        System.assert(getPoliciesForRollupTest(acctUnderTest, 6, expectedSourceSysIds),'Failed to run getPoliciesForRollupTest with provided parameters');
    }
    
    /**
* @description Test for a Household Fail
*/
    @isTest
    private static void getPoliciesForRollupForHouseholdFail() {
        // Prep
        Account acctUnderTest = TestDataFactory_InsurancePolicy.getPrimaryHouseholdByMemberClientId(
            TestDataFactory_InsurancePolicy.ACCOUNT_ONE_CLIENT_ID
        );
        User actInsHealthUser = TestDataFactory_User_Wrapper.generateActiveInsuranceandHealthUser('TEST', '12345678916');
        actInsHealthUser = TestDataFactory_User.insertUser(actInsHealthUser);
          
                    PolicySummaryQueryController.mockPolicies = null;
        try {
           Test.startTest();
            System.runAs(actInsHealthUser){
            PolicySummaryQueryController.fetchAllPolicies(
                acctUnderTest.Id,
                acctUnderTest.RecordTypeId
            );
            }
            Test.stopTest();
            
        }
        catch (AuraHandledException e) {
            System.assert('Script-thrown exception'.equals(e.getmessage()), 'The error message is not expected:' + e.getMessage());
        }
    
    }
    // Test Helpers
    
    private static Boolean getPoliciesForRollupTest(
        Account acctUnderTest,
        Integer expectedSize,
        List<String> expectedSrcSysIds
    ) {
        // Execute
        Test.startTest();
        List<InsurancePolicy> policies = PolicySummaryQueryController.fetchAllPolicies(
            acctUnderTest.Id,
            acctUnderTest.RecordTypeId
        );
        Test.stopTest();
        
        // Verify
        System.assert(
            policies.size() == expectedSize,
            'Number of policies returned aren\'t the same as the expected.. expected - ' +
            expectedSize +
            ', actual - ' +
            policies.size()
        );
        
        Map<String, InsurancePolicy> policyMap = new Map<String, InsurancePolicy>();
        for (InsurancePolicy p : policies) {
            policyMap.put(p.SourceSystemIdentifier, p);
        }
        
        for (String expectedSrcSysId : expectedSrcSysIds) {
            System.assert(
                policyMap.containsKey(expectedSrcSysId),
                'Id does not exist in list returned - expected missing: ' + expectedSrcSysId
            );
        }
        
        return true;
    }
}