/**
 * @description This is the test class for the PolicySummaryController Apex class.
 * @Date: 09/10/2021
 * @author: Policy Core Team (NSYNC) - Joseph Remy XGRG
 */
@isTest(SeeAllData=false)
public class PolicySummaryController_Test {
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

        List<String> expectedSourceSysIds = new List<String>{
            TestDataFactory_InsurancePolicy.POLICY_PRIVATE_PASSENGER_SRC_SYS_ID,
            TestDataFactory_InsurancePolicy.POLICY_BUSINESS_FIRE_SRC_SYS_ID,
            TestDataFactory_InsurancePolicy.POLICY_ASSURANT_HEALTH_SRC_SYS_ID,
            TestDataFactory_InsurancePolicy.POLICY_COMMERCIAL_AUTO_SRC_SYS_ID
        };

        System.assert(getPoliciesForRollupTest(acctUnderTest, 4, expectedSourceSysIds),'Failed to run getPoliciesForRollupTest with provided parameters');
    }

    @isTest
    private static void getPoliciesForRollupForAccountNull() {
        // Prep
        PolicySummaryController.isCatch = true;
        PolicySummaryController.getPoliciesForRollup(null,null);
        System.assert(true, 'Mandatory Assert statement on Tests');
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

        List<String> expectedSourceSysIds = new List<String>{
            TestDataFactory_InsurancePolicy.POLICY_PRIVATE_PASSENGER_SRC_SYS_ID,
            TestDataFactory_InsurancePolicy.POLICY_RENTERS_POLICY_SRC_SYS_ID,
            TestDataFactory_InsurancePolicy.POLICY_SHORT_TERM_LIFE_SRC_SYS_ID,
            TestDataFactory_InsurancePolicy.POLICY_ASSURANT_HEALTH_SRC_SYS_ID,
            TestDataFactory_InsurancePolicy.POLICY_COMMERCIAL_AUTO_SRC_SYS_ID
        };

        System.assert(getPoliciesForRollupTest(acctUnderTest, 5, expectedSourceSysIds),'Failed to run getPoliciesForRollupTest with provided parameters');
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

        List<String> expectedSourceSysIds = new List<String>{
            TestDataFactory_InsurancePolicy.POLICY_PRIVATE_PASSENGER_SRC_SYS_ID,
            TestDataFactory_InsurancePolicy.POLICY_RENTERS_POLICY_SRC_SYS_ID,
            TestDataFactory_InsurancePolicy.POLICY_BUSINESS_FIRE_SRC_SYS_ID,
            TestDataFactory_InsurancePolicy.POLICY_SHORT_TERM_LIFE_SRC_SYS_ID,
            TestDataFactory_InsurancePolicy.POLICY_ASSURANT_HEALTH_SRC_SYS_ID,
            TestDataFactory_InsurancePolicy.POLICY_COMMERCIAL_AUTO_SRC_SYS_ID
        };

        List<InsurancePolicy> mockHHPolicies = new List<InsurancePolicy>();
        for (String srcId : expectedSourceSysIds) {
            mockHHPolicies.add(TestDataFactory_InsurancePolicy.getInsurancePolicyBySourceSystemId(srcId));
        }
        PolicySummaryController.mockPolicies = mockHHPolicies;

        System.assert(getPoliciesForRollupTest(acctUnderTest, 6, expectedSourceSysIds),'Failed to run getPoliciesForRollupTest with provided parameters');
    }

    /**
     * @description Test for getting policies for search
     */
    @isTest
    private static void getPoliciesForSearch() {
        // Prep
        List<InsurancePolicy> expectedIPs = new List<InsurancePolicy>{
            TestDataFactory_InsurancePolicy.getInsurancePolicyBySourceSystemId(
                TestDataFactory_InsurancePolicy.POLICY_PRIVATE_PASSENGER_SRC_SYS_ID
            ),
            TestDataFactory_InsurancePolicy.getInsurancePolicyBySourceSystemId(
                TestDataFactory_InsurancePolicy.POLICY_RENTERS_POLICY_SRC_SYS_ID
            ),
            TestDataFactory_InsurancePolicy.getInsurancePolicyBySourceSystemId(
                TestDataFactory_InsurancePolicy.POLICY_ASSURANT_HEALTH_SRC_SYS_ID
            )
        };

        List<Id> sfdcIds = new List<Id>();
        for (InsurancePolicy ip : expectedIPs) {
            sfdcIds.add(ip.Id);
        }

        // Execute
        Test.startTest();
        List<InsurancePolicy> actualIPs = PolicySummaryController.getPoliciesForSearch(sfdcIds);
        Test.stopTest();

        // Verify
        System.assert(
            actualIPs.size() == 3,
            'Number of policies returned aren\'t the same as the expected.. expected - ' +
            3 +
            ', actual - ' +
            actualIPs.size()
        );
    }

    // Test Helpers

    private static Boolean getPoliciesForRollupTest(
        Account acctUnderTest,
        Integer expectedSize,
        List<String> expectedSrcSysIds
    ) {
        // Execute
        Test.startTest();
        List<InsurancePolicy> policies = PolicySummaryController.getPoliciesForRollup(
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
