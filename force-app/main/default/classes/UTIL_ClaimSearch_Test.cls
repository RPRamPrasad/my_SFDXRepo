@isTest(seeAllData=false)
public with sharing class UTIL_ClaimSearch_Test {

    @TestSetup
    /**
     * @description performs setup for test data that is used in the tests
     */
    public static void  setup() {
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();
    }

    @isTest
    public static void getClaimsByInsurancePolicyTest() {
        List<Claim> actualClaimsA;
        List<Claim> actualClaimsB;

        createClaims();

        Test.startTest();
        actualClaimsA = UTIL_ClaimSearch.getClaimsByInsurancePolicyForAccount('KRKNCID000A');
        actualClaimsB = UTIL_ClaimSearch.getClaimsByInsurancePolicyForAccount('KRKNCID000B');
        Test.stopTest();

        System.assertEquals(4, actualClaimsA.size(), 'expected to find 4 claims');
        System.assertEquals(5, actualClaimsB.size(), 'expected to find 5 claims');
    }

    @isTest
    public static void getClaimsByHouseholdTest() {
        List<Claim> actualClaims;
        
        List<InsurancePolicy> policies = getPoliciesByClientId('KRKNCID000A');
        Id accountId = policies.get(0).NameInsuredId;
        Account householdId = [SELECT Primary_Household__pc FROM Account WHERE Id = :accountId];
        
        List<Claim> expectedClaims = createClaims();

        Test.startTest();
        actualClaims = UTIL_ClaimSearch.getClaimsByHousehold(householdId.Primary_Household__pc);
        Test.stopTest();

        System.assertEquals(actualClaims.size(), expectedClaims.size(), 'expected to find 6 claims');
        System.assertNotEquals(householdId.Primary_Household__pc, null, 'householdId not null');
    }

    @isTest
    public static void getClaimsByInsurancePolicyForAccountTest() {
        List<Claim> actualClaimsA;
        List<Claim> actualClaimsB;

        createClaims();

        List<InsurancePolicy> policiesA = getPoliciesByClientId('KRKNCID000A');
        List<InsurancePolicy> policiesB = getPoliciesByClientId('KRKNCID000B');

        Account accountA = getAccount(policiesA.get(0).NameInsuredId);
        createInsurancePolicyParticipants(accountA, policiesB);

        Test.startTest();
        actualClaimsA = UTIL_ClaimSearch.getClaimsByInsurancePolicyForAccount('KRKNCID000A');
        actualClaimsB = UTIL_ClaimSearch.getClaimsByInsurancePolicyForAccount('KRKNCID000B');
        Test.stopTest();

        System.assertEquals(6, actualClaimsA.size(), 'expected to find 6 claims');
        System.assertEquals(6, actualClaimsA.size(), 'expected to find 6 claims');
    }

    private static List<InsurancePolicy> getPoliciesByClientId(String clientId) {
        return [SELECT Id, NameInsuredId
                FROM InsurancePolicy
                WHERE NameInsured.ClientIdentifier__c = :clientId];
    }

    private static Account getAccount(Id accountId) {
        return [SELECT Id, Primary_Household__pc
                FROM Account
                WHERE Id = :accountId];
    }

    private static List<InsurancePolicy> getInsurancePolicies() {
        return [SELECT Id, NameInsuredId
                FROM InsurancePolicy];
    }

    private static List<InsurancePolicyParticipant> createInsurancePolicyParticipants(Account account, List<InsurancePolicy> policies) {
        List<InsurancePolicyParticipant> participants = new List<InsurancePolicyParticipant>();

        for(InsurancePolicy policy : policies) {
            InsurancePolicyParticipant participant = new InsurancePolicyParticipant();
            participant.PrimaryParticipantAccountId = account.Id;
            participant.InsurancePolicyId = policy.Id;
            participant.Role = 'Named Insured';
            participant.RoleNameCd__c = '18';
            participants.add(participant);
        }

        insert participants;

        return participants;
    }

    private static List<Claim> createClaims() {
        List<InsurancePolicy> policies = getInsurancePolicies();
        List<Claim> claims = new List<Claim>();
        for(InsurancePolicy policy : policies ) {
            Account account = getAccount(policy.NameInsuredId);
            Claim claim = TestDataFactory_Claim.generateClaim(account, policy);
            claims.add(claim);
        }

        insert claims;

        return claims;
    }

    private static void disableTriggers() {
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;

        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false, systemUser);
        insert passTriggerAll;

        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;
        insert objectBasedByPassTrigger;

        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;

        TestDataFactory_Claim.byPassClaimAfterTriggers();
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    }
}
