/**
* @author : Team Sparky
* @date : 9/6/2018
* @description : test for class that retrieves OData for AT_Claims lightning component
* @version : 1.0
*/
@isTest
(SeeAllData=false)
public class AT_ClaimsControllerTest {

    private static final String AGENT_ASSOCIATE_ID = '12345678913';
    private static final String CCC_LICENSED_ASSOCIATE_ID = '12345678914';

    @TestSetup
    public static void  setup() {
        User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', AGENT_ASSOCIATE_ID);
        User cccUser = TestDataFactory_User_Wrapper.generateCCCLicensedUser('TEST', CCC_LICENSED_ASSOCIATE_ID);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agent, cccUser});

        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();
    }

    @isTest
    public static void testGetClaimsByInsurancePolicyForAccount() {
        List<Claim> actualClaimsA;
        List<Claim> actualClaimsB;

        createClaims();

        Test.startTest();
        actualClaimsA = AT_ClaimsController.getClaimsByInsurancePolicyForAccount('KRKNCID000A');
        actualClaimsB = AT_ClaimsController.getClaimsByInsurancePolicyForAccount('KRKNCID000B');
        Test.stopTest();

        System.assertEquals(4, actualClaimsA.size(), 'expected to find 4 claims');
        System.assertEquals(5, actualClaimsB.size(), 'expected to find 5 claims');
    }

    @isTest
    public static void testGetClaimsByHousehold() {
        List<Claim> actualClaims;

        List<InsurancePolicy> policies = getPoliciesByClientId('KRKNCID000A');
        Id accountId = policies.get(0).NameInsuredId;
        Account householdId = [SELECT Primary_Household__pc FROM Account WHERE Id = :accountId];

        List<Claim> expectedClaims = createClaims();

        Test.startTest();
        actualClaims = AT_ClaimsController.getClaimsByHousehold(householdId.Primary_Household__pc);
        Test.stopTest();

        System.assertEquals(actualClaims.size(), expectedClaims.size(), 'expected to find 6 claims');
        System.assertNotEquals(householdId.Primary_Household__pc, null, 'householdId not null');
    }

    @isTest
    private static void testCheckIfisCCCRepFalse() {
        AT_ClaimsController.subUserType = UTIL_Constants.USER_TYPE_AGENT;
        Test.startTest();
        Boolean resultValue = AT_ClaimsController.isCCCRep();
        Test.stopTest();
        System.assertEquals(false,resultValue, 'ResultValue is not false');
    }

    @isTest
    private static void testCheckIfisCCCRepTrue() {
        AT_ClaimsController.subUserType = UTIL_Constants.CCC_SALES;
        Test.startTest();
        Boolean resultValue = AT_ClaimsController.isCCCRep();
        Test.stopTest();
        System.assertEquals(true, resultValue, 'ResultValue is not true');
    }

    @isTest
    private static void isELRVisibleTrue() {
        boolean resultValue = false;
        User agent = [SELECT Id FROM User WHERE Associate_ID__c = :AGENT_ASSOCIATE_ID];
        Test.startTest();
            System.runAs(agent) {
                resultValue = AT_ClaimsController.isELRVisible();
            }
        Test.stopTest();
        System.assertEquals(true, resultValue, 'should have returned true for an agent');
    }

    @isTest
    private static void isELRVisibleFalse() {
        boolean resultValue = true;
        User cccUser = [SELECT Id FROM User WHERE Associate_ID__c = :CCC_LICENSED_ASSOCIATE_ID];
        Test.startTest();

        System.runAs(cccUser) {
            resultValue = AT_ClaimsController.isELRVisible();
        }

        Test.stopTest();
        System.assertEquals(false, resultValue, 'should have returned false for a CCC user');
    }

    @isTest
    private static void testIsLossHistoryIframeToggleOn() {
        AT_ClaimsController.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_LOSS_HISTORY_IFRAME, true);

        Test.startTest();
        Boolean resultValue = AT_ClaimsController.isLossHistoryIframe();
        Test.stopTest();
        System.assertEquals(true, resultValue, 'HOUSEHOLD_LOSS_HISTORY_IFRAME toggle should be on');
    }

    @isTest
    private static void testIsLossHistoryIframeToggleOff() {
        AT_ClaimsController.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_LOSS_HISTORY_IFRAME, false);

        Test.startTest();
        Boolean resultValue = AT_ClaimsController.isLossHistoryIframe();
        Test.stopTest();
        System.assertEquals(false, resultValue, 'HOUSEHOLD_LOSS_HISTORY_IFRAME toggle should be off');
    }

    @isTest
    private static void isSupportEnabledFalse() {
        boolean resultValue = true;
        User cccUser = [SELECT Id FROM User WHERE Associate_ID__c = :CCC_LICENSED_ASSOCIATE_ID];
        Test.startTest();

        System.runAs(cccUser) {
            resultValue = AT_ClaimsController.isSupportEnabled();
        }

        Test.stopTest();
        System.assertEquals(false, resultValue, 'should have returned false for a CCC user');
    }

    @isTest
    private static void isSupportEnabledTrue() {
        boolean resultValue = true;
        TestUserSetupUtility.setupSystemAdminUser();
        User adminUser=TestUserSetupUtility.getSysAdminUser();
        assignPermissionSet(adminUser,'ECRM_Claims_Support');

        Test.startTest();

        System.runAs(adminUser) {
            resultValue = AT_ClaimsController.isSupportEnabled();
        }

        Test.stopTest();
        System.assertEquals( true , resultValue, 'should have returned true for a user with support custom permission');
    }

    private static void assignPermissionSet(User user, String name) {
        PermissionSet permissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = :name];
        PermissionSetAssignment psAssignment = new PermissionSetAssignment(PermissionSetId = permissionSet.Id, AssigneeId = user.Id);
        insert psAssignment;
    }

    private static List<InsurancePolicy> getPoliciesByClientId(String clientId) {
        return [SELECT Id, NameInsuredId
                FROM InsurancePolicy
                WHERE NameInsured.ClientIdentifier__c = :clientId];
    }

    private static List<InsurancePolicy> getInsurancePolicies() {
        return [SELECT Id, NameInsuredId
                FROM InsurancePolicy];
    }

    private static List<Id> getNamedInsuredAccountIds(List<InsurancePolicy> policies) {
        List<Id> ids = new List<Id>();
        for (InsurancePolicy policy : policies) {
            ids.add(policy.NameInsuredId);
        }
        return ids;
    }

    private static Map<Id, Account> getNameInsureds(List<InsurancePolicy> policies) {
        List<Id> accountIds = getNamedInsuredAccountIds(policies);
        List<Account> accounts = [SELECT Id, Primary_Household__pc
                                  FROM Account
                                  WHERE Id IN :accountIds];
        Map<Id, Account> accountsById = new Map<Id, Account>();
        for (Account account : accounts) { 
            accountsById.put(account.Id, account);
        }
        return accountsById;
    }

    private static List<Claim> createClaims() {
        List<InsurancePolicy> policies = getInsurancePolicies();
        Map<Id, Account> accountsById = getNameInsureds(policies);

        List<Claim> claims = new List<Claim>();
        for (InsurancePolicy policy : policies) {
            Account account = accountsById.get(policy.NameInsuredId);
            Claim claim = TestDataFactory_Claim.generateClaim(account, policy);
            claims.add(claim);
        }
        insert claims;
        return claims;
    }
}