@isTest(seeAllData=false)
public with sharing class UTIL_ClaimantClaimSearch_Test {
    private static final String CLAIM_ACCOUNT = 'ClaimAccount01';
    private static final String CLAIM_CLIENT_ID = 'CCFA5678901';
    private static final String CLAIMANT_ACCOUNT = 'ClaimantAccount01';
    private static final String CLAIMANT_CLIENT_ID = 'CCFA5678902';
    private static final String CLAIMANT_ACCOUNT2 = 'ClaimantAccount02';
    private static final String CLAIMANT_CLIENT_ID2 = 'CCFA5678903';
    private static final String CLAIMANT_ACCOUNT3 = 'ClaimantAccount03';
    private static final String CLAIMANT_CLIENT_ID3 = 'CCFA5678904';
    private static final String HOUSEHOLD_NAME = 'Household';
    private static final String POLICY_NAME = 'CCFA_POLICY01';
    private static final String CLAIMANT_ROLE_CODE = 'C';
    private static final String NAMED_INSURED_ROLE_CODE = 'NI';

    private static Account getAccount(String accountName) {
        return [SELECT Id, Primary_Household__pc
                FROM Account
                WHERE FirstName = :accountName];
    }

    private static InsurancePolicy getInsurancePolicy() {
        return [SELECT Id
                FROM InsurancePolicy
                WHERE Name = :POLICY_NAME];
    }

    @TestSetup
    /**
     * @description Prepare claimaint search setup by disabling triggers and running createTestData()
     */
    public static void  setup() {
        disableTriggers();
        createTestData();
    }

    private static void disableTriggers() {
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        TestDataFactory_Claim.byPassClaimAfterTriggers();
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    }

    private static void createTestData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get('IndustriesHousehold').getRecordTypeId();
        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('ccfa','ccfaSystemUserTest','ccfaSystemUserTest@statefarm.com'); 
        System.RunAs(systemAdmin) {
            Account household1 = new Account(Name=HOUSEHOLD_NAME, recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
            Account household2 = new Account(Name=HOUSEHOLD_NAME, recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
            List<Account> households = new List<Account>{ household1, household2 };
            insert households;

            Account claimAccount = TestDataFactory_Account.createIndividualCustomer(CLAIM_ACCOUNT, CLAIM_CLIENT_ID);
            insert claimAccount;
            TestDataFactory_Claim.createInsurancePolicy(POLICY_NAME, claimAccount);

            Account claimantAccount = TestDataFactory_Account.createIndividualCustomer(CLAIMANT_ACCOUNT, CLAIMANT_CLIENT_ID);
            claimantAccount.Primary_Household__pc = household1.Id;
            insert claimantAccount;

            Account claimantAccount2 = TestDataFactory_Account.createIndividualCustomer(CLAIMANT_ACCOUNT2, CLAIMANT_CLIENT_ID2);
            claimantAccount2.Primary_Household__pc = household2.Id;
            insert claimantAccount2;

            Account claimantAccount3 = TestDataFactory_Account.createIndividualCustomer(CLAIMANT_ACCOUNT3, CLAIMANT_CLIENT_ID3);
            claimantAccount3.Primary_Household__pc = household1.Id;
            insert claimantAccount3;
        }
    }

    @isTest
    private static void getClaimsByClaimantAccountTest() {
        Account account = getAccount(CLAIM_ACCOUNT);
        InsurancePolicy policy = getInsurancePolicy();
        List<Claim> claims = TestDataFactory_Claim.generateClaims(10, account, policy);
        claims = TestDataFactory_Claim.insertClaims(claims);

        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        TestDataFactory_Claim.createClaimParticipants(claims, claimantAccount.Id, CLAIMANT_ROLE_CODE);
        TestDataFactory_Claim.createClaimParticipants(claims, account.Id, NAMED_INSURED_ROLE_CODE);

        Test.startTest();
        List<Claim> result = UTIL_ClaimantClaimSearch.getClaimsByClaimantAccount(claimantAccount.Id);
        Test.stopTest();

        System.assertEquals(10, result.size(), 'Should have 10 results');
    }

    @isTest
    private static void getClaimsByClaimantAccountWithHalfClaimantTest() {
        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        createTestClaimsWithHalfClaimantParticipants();

        Test.startTest();
        List<Claim> result = UTIL_ClaimantClaimSearch.getClaimsByClaimantAccount(claimantAccount.Id);
        Test.stopTest();

        System.assertEquals(5, result.size(), 'Should have 5 results');
    }

    @isTest
    private static void getClaimsByClaimantAccountSecondAccountClaimantTest() {
        Account account = getAccount(CLAIM_ACCOUNT);
        InsurancePolicy policy = getInsurancePolicy();
        Integer numberOfClaims = 100;
        List<Claim> claims = TestDataFactory_Claim.generateClaims(numberOfClaims, account, policy);
        claims = TestDataFactory_Claim.insertClaims(claims);

        Integer numberOfClaimantClaims = numberOfClaims / 2;
        List<Claim> claimantClaims1 = new List<Claim>();
        for (Integer i=0; i < numberOfClaimantClaims; i++) {
            claimantClaims1.add(claims.get(i));
        }

        Account claimantAccount1 = getAccount(CLAIMANT_ACCOUNT);
        TestDataFactory_Claim.createClaimParticipants(claimantClaims1, claimantAccount1.Id, CLAIMANT_ROLE_CODE);

        List<Claim> claimantClaims2 = new List<Claim>();
        for (Integer j=numberOfClaimantClaims; j < numberOfClaims; j++) {
            claimantClaims2.add(claims.get(j));
        }
        Account claimantAccount2 = getAccount(CLAIMANT_ACCOUNT2);
        TestDataFactory_Claim.createClaimParticipants(claimantClaims2, claimantAccount2.Id, CLAIMANT_ROLE_CODE);

        TestDataFactory_Claim.createClaimParticipants(claims, account.Id, NAMED_INSURED_ROLE_CODE);

        Test.startTest();
        List<Claim> result1 = UTIL_ClaimantClaimSearch.getClaimsByClaimantAccount(claimantAccount1.Id);
        List<Claim> result2 = UTIL_ClaimantClaimSearch.getClaimsByClaimantAccount(claimantAccount2.Id);
        Test.stopTest();

        System.assertEquals(50, result1.size(), 'Should have 50 results');
        System.assertEquals(50, result2.size(), 'Should have 50 results');
    }

    @isTest
    private static void getClaimsByClaimantAccountNoClaimantTest() {
        createTestClaimsWithHalfClaimantParticipants();

        Account claimantAccount2 = getAccount(CLAIMANT_ACCOUNT2);
        Test.startTest();
        List<Claim> result = UTIL_ClaimantClaimSearch.getClaimsByClaimantAccount(claimantAccount2.Id);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should have 0 results');
    }

    @isTest
    private static void getClaimsByClaimantHouseholdTest() {
        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        Account claimantAccount2 = getAccount(CLAIMANT_ACCOUNT2);
        Account claimantAccount3 = getAccount(CLAIMANT_ACCOUNT3);
        createTestClaimsWithHalfClaimantParticipants();

        Test.startTest();
        List<Claim> result = UTIL_ClaimantClaimSearch.getClaimsByClaimantHousehold(claimantAccount.Primary_Household__pc);
        List<Claim> result2 = UTIL_ClaimantClaimSearch.getClaimsByClaimantHousehold(claimantAccount2.Primary_Household__pc);
        List<Claim> result3 = UTIL_ClaimantClaimSearch.getClaimsByClaimantHousehold(claimantAccount3.Primary_Household__pc);
        List<Claim> result4 = UTIL_ClaimantClaimSearch.getClaimsByClaimantHousehold(null);
        Test.stopTest();

        System.assertEquals(5, result.size(), 'Should have 5 results');
        System.assertEquals(0, result2.size(), 'Should have 0 results');
        System.assertEquals(5, result3.size(), 'Should have 5 results');
        System.assertEquals(0, result4.size(), 'Should have 0 results');
    }

    @isTest
    private static void getClaimsByClaimantHouseholdMultipleHouseholdTest() {
        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        Account claimantAccount2 = getAccount(CLAIMANT_ACCOUNT2);
        Account claimantAccount3 = getAccount(CLAIMANT_ACCOUNT3);
        createTestClaimsWithHalfClaimantParticipants();

        Account account = getAccount(CLAIM_ACCOUNT);
        InsurancePolicy policy = getInsurancePolicy();
        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account, policy);
        claims = TestDataFactory_Claim.insertClaims(claims);
        List<Claim> claimantClaims2 = new List<Claim>();
        claimantClaims2.addAll(claims);
        TestDataFactory_Claim.createClaimParticipants(claimantClaims2, claimantAccount2.Id, CLAIMANT_ROLE_CODE);

        Test.startTest();
        List<Claim> result = UTIL_ClaimantClaimSearch.getClaimsByClaimantHousehold(claimantAccount.Primary_Household__pc);
        List<Claim> result2 = UTIL_ClaimantClaimSearch.getClaimsByClaimantHousehold(claimantAccount2.Primary_Household__pc);
        List<Claim> result3 = UTIL_ClaimantClaimSearch.getClaimsByClaimantHousehold(claimantAccount3.Primary_Household__pc);
        Test.stopTest();

        System.assertEquals(5, result.size(), 'Should have 5 results');
        System.assertEquals(1, result2.size(), 'Should have 1 result');
        System.assertEquals(5, result3.size(), 'Should have 5 results');
    }

    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static void createTestClaimsWithHalfClaimantParticipants() {
        Account account = getAccount(CLAIM_ACCOUNT);
        InsurancePolicy policy = getInsurancePolicy();
        Integer numberOfClaims = 10;
        List<Claim> claims = TestDataFactory_Claim.generateClaims(numberOfClaims, account, policy);
        claims = TestDataFactory_Claim.insertClaims(claims);

        Integer numberOfClaimantClaims = numberOfClaims / 2;
        List<Claim> claimantClaims = new List<Claim>();
        for (Integer i=0; i < numberOfClaimantClaims; i++) {
            claimantClaims.add(claims.get(i));
        }
        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        TestDataFactory_Claim.createClaimParticipants(claimantClaims, claimantAccount.Id, CLAIMANT_ROLE_CODE);
        TestDataFactory_Claim.createClaimParticipants(claims, account.Id, NAMED_INSURED_ROLE_CODE);
    }

}
