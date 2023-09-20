/**
 * @description This class will be used to test the UTIL_ClaimShareClaimant Class
 * @Date: 2/23/2022
 * @author: Moneyball
 */
@isTest
(seeAllData = false)
public with sharing class UTIL_ClaimShareClaimant_Test extends UTIL_AgencyShares {

    private static final String [] PROXIES = new String[] {'CCFA01', 'CCFA02'};
    private static final String PROXY_AGENT = 'CCFA03';
    private static final String CLAIM_ACCOUNT = 'ClaimAccount01';
    private static final String CLAIM_CLIENT_ID = 'CCFA5678901';
    private static final String CLAIMANT_ACCOUNT = 'ClaimantAccount01';
    private static final String CLAIMANT_CLIENT_ID = 'CCFA5678902';
    private static final String CLAIMANT_ACCOUNT2 = 'ClaimantAccount02';
    private static final String CLAIMANT_CLIENT_ID2 = 'CCFA5678903';
    private static final String POLICY = 'CCFA_TEST01';
    private static final String CLAIMANT_ROLE_CODE = 'C';
    private static final String NAMED_INSURED_ROLE_CODE = 'NI';

    /**
     * @name testSetupData
     * @description configures the custom settings to allow data to be created
     */
    @TestSetup
    public static void setup() {
        disableTriggers();
        createTestData();
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

    private static void createTestData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        for (String proxy : PROXIES) {
            TestDataFactory_Claim.createOffice(proxy);
        }
        TestDataFactory_Claim.createProxyAgent(PROXY_AGENT);
        Account claimAccount = TestDataFactory_Account.createIndividualCustomer(CLAIM_ACCOUNT, CLAIM_CLIENT_ID);
        insert claimAccount;
        TestDataFactory_Claim.createInsurancePolicy(POLICY, claimAccount);

        Account claimantAccount = TestDataFactory_Account.createIndividualCustomer(CLAIMANT_ACCOUNT, CLAIMANT_CLIENT_ID);
        insert claimantAccount;

        Account claimantAccount2 = TestDataFactory_Account.createIndividualCustomer(CLAIMANT_ACCOUNT2, CLAIMANT_CLIENT_ID2);
        insert claimantAccount2;
    }

    private static List<User> getProxies() {
        return [SELECT Id
                FROM User
                WHERE Servicing_Agent_Associate_ID__c IN :PROXIES];
    }
    
    private static User getProxyAgent(String proxy) {
        return [SELECT Id
                FROM User
                WHERE Servicing_Agent_Associate_ID__c = :proxy];
    }

    private static Account getAccount(String accountName) {
        return [SELECT Id
                FROM Account
                WHERE FirstName = :accountName];
    }

    private static InsurancePolicy getInsurancePolicy() {
        return [SELECT Id
                FROM InsurancePolicy
                WHERE Name = :POLICY];
    }

    /**
     * @name testClaimSharesCreatedFromAgentRoleData
     * @description verifies that claim share records are created when agent roles are inserted
     */
    @isTest
    private static void testClaimSharesCreatedFromAgentRoleData() {
        UTIL_ClaimShareClaimant.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIMANT_SHARES, true);

        Account account = getAccount(CLAIM_ACCOUNT);
        InsurancePolicy policy1 = getInsurancePolicy();
        List<Claim> claims = TestDataFactory_Claim.generateClaims(2, account, policy1);
        claims = TestDataFactory_Claim.insertClaims(claims);

        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        TestDataFactory_Claim.createClaimParticipants(claims, claimantAccount.Id, CLAIMANT_ROLE_CODE);
        
        List<Account> claimantAccounts = new List<Account>();
        claimantAccounts.add(claimantAccount);
        AgentRoleData agentRoleData = TestDataFactory_Claim.generateAgentRoleData(claimantAccounts, getProxies().get(0));

        Test.startTest();
        List<Database.SaveResult> results = UTIL_ClaimShareClaimant.insertClaimShares(agentRoleData);
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Should have 2 results');
        assertSaveResults(results);
    }

    /**
     * @name testClaimSharesCreatedFromAgentRoleDataToggleOff
     * @description verifies that no claim share records are created when toggled off
     */
    @isTest
    private static void testClaimSharesCreatedFromAgentRoleDataToggleOff() {
        UTIL_ClaimShareClaimant.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIMANT_SHARES, false);

        Account account = getAccount(CLAIM_ACCOUNT);
        InsurancePolicy policy2 = getInsurancePolicy();
        List<Claim> claims = TestDataFactory_Claim.generateClaims(2, account, policy2);
        claims = TestDataFactory_Claim.insertClaims(claims);

        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        TestDataFactory_Claim.createClaimParticipants(claims, claimantAccount.Id, CLAIMANT_ROLE_CODE);
        
        List<Account> claimantAccounts = new List<Account>();
        claimantAccounts.add(claimantAccount);
        AgentRoleData agentRoleData = TestDataFactory_Claim.generateAgentRoleData(claimantAccounts, getProxies().get(0));

        Test.startTest();
        List<Database.SaveResult> results = UTIL_ClaimShareClaimant.insertClaimShares(agentRoleData);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should have 0 results');
        assertSaveResults(results);
        assertClaimShareCount(claims, 0);
    }

    /**
     * @name testClaimSharesCreatedFromAgentRoleDataWithNoClaimsForClaimantAccount
     * @description verifies that no claim share records are created when agent roles does not have a claimant account
     */
    @isTest
    private static void testClaimSharesCreatedFromAgentRoleDataWithNoClaimsForClaimantAccount() {
        UTIL_ClaimShareClaimant.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIMANT_SHARES, true);

        Account claimAccount = getAccount(CLAIM_ACCOUNT);
        InsurancePolicy policy3 = getInsurancePolicy();
        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, claimAccount, policy3);
        claims = TestDataFactory_Claim.insertClaims(claims);
        TestDataFactory_Claim.createClaimParticipants(claims, claimAccount.Id, NAMED_INSURED_ROLE_CODE);

        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        Account claimantAccount2 = getAccount(CLAIMANT_ACCOUNT2);
        TestDataFactory_Claim.createClaimParticipants(claims, claimantAccount2.Id, CLAIMANT_ROLE_CODE);
        
        List<Account> accounts = new List<Account>();
        accounts.add(claimantAccount);
        AgentRoleData agentRoleData = TestDataFactory_Claim.generateAgentRoleData(accounts, getProxies().get(0));

        Test.startTest();
        List<Database.SaveResult> results = UTIL_ClaimShareClaimant.insertClaimShares(agentRoleData);
        Test.stopTest();

        System.assert(results.isEmpty(), 'Should have 0 results');
        assertClaimShareCount(claims, 0);
    }

    /**
     * @name testClaimSharesDeleteFromAgentRoleData
     * @description verifies that claim share records are deleted for the given AgentRoleData
     */
    @isTest
    private static void testClaimSharesDeleteFromAgentRoleData() {
        UTIL_ClaimShareClaimant.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIMANT_SHARES, true);

        Account account = getAccount(CLAIM_ACCOUNT);
        InsurancePolicy policy4 = getInsurancePolicy();
        List<Claim> claims = TestDataFactory_Claim.generateClaims(2, account, policy4);
        claims = TestDataFactory_Claim.insertClaims(claims);

        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        TestDataFactory_Claim.createClaimParticipants(claims, claimantAccount.Id, CLAIMANT_ROLE_CODE);
        
        List<Account> claimantAccounts = new List<Account>();
        claimantAccounts.add(claimantAccount);
        AgentRoleData agentRoleData = TestDataFactory_Claim.generateAgentRoleData(claimantAccounts, getProxies().get(0));
        List<Database.SaveResult> saveResults = UTIL_ClaimShareClaimant.insertClaimShares(agentRoleData);
        System.assertEquals(2, saveResults.size(), 'Should have 2 results');

        User deleteProxy = getProxies().get(0);
        AgentRoleData deleteAgentRoleData = TestDataFactory_Claim.generateAgentRoleData(claimantAccounts, deleteProxy);

        Test.startTest();
        List<Database.DeleteResult> results = UTIL_ClaimShareClaimant.deleteClaimShares(deleteAgentRoleData);
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Should have 2 results');
        assertDeleteResults(results);
        assertClaimShareCount(claims, 0);
    }
    
        /**
     * @name testClaimSharesDeleteFromAgentRoleData
     * @description verifies that claim share records are deleted for the given AgentRoleData
     */
    @isTest
    private static void testClaimSharesDeleteFromAgentRoleDataToggledOff() {
        UTIL_ClaimShareClaimant.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIMANT_SHARES, true);

        Account account = getAccount(CLAIM_ACCOUNT);
        InsurancePolicy policy5 = getInsurancePolicy();
        List<Claim> claims = TestDataFactory_Claim.generateClaims(2, account, policy5);
        claims = TestDataFactory_Claim.insertClaims(claims);

        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        TestDataFactory_Claim.createClaimParticipants(claims, claimantAccount.Id, CLAIMANT_ROLE_CODE);
        
        List<Account> claimantAccounts = new List<Account>();
        claimantAccounts.add(claimantAccount);
        AgentRoleData agentRoleData = TestDataFactory_Claim.generateAgentRoleData(claimantAccounts, getProxies().get(0));
        List<Database.SaveResult> saveResults = UTIL_ClaimShareClaimant.insertClaimShares(agentRoleData);
        System.assertEquals(2, saveResults.size(), 'Should have 2 results');

        UTIL_ClaimShareClaimant.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIMANT_SHARES, false);
        User deleteProxy = getProxies().get(0);
        AgentRoleData deleteAgentRoleData = TestDataFactory_Claim.generateAgentRoleData(claimantAccounts, deleteProxy);

        Test.startTest();
        List<Database.DeleteResult> results = UTIL_ClaimShareClaimant.deleteClaimShares(deleteAgentRoleData);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should have 0 results');
        assertClaimShareCount(claims, 2);
    }
    
    /**
     * @name testClaimSharesDeleteFromAgentRoleDataForOneProxy
     * @description verifies that claim share records are deleted for the one of the proxies
     */
    @isTest
    private static void testClaimSharesDeleteFromAgentRoleDataForOneProxy() {
        UTIL_ClaimShareClaimant.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIMANT_SHARES, true);

        Account account = getAccount(CLAIM_ACCOUNT);
        InsurancePolicy policy6 = getInsurancePolicy();
        List<Claim> claims = TestDataFactory_Claim.generateClaims(2, account, policy6);
        claims = TestDataFactory_Claim.insertClaims(claims);

        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        TestDataFactory_Claim.createClaimParticipants(claims, claimantAccount.Id, CLAIMANT_ROLE_CODE);
        
        List<Account> claimantAccounts = new List<Account>();
        claimantAccounts.add(claimantAccount);
        AgentRoleData agentRoleData = TestDataFactory_Claim.generateAgentRoleData(claimantAccounts, getProxies().get(0));
        List<Database.SaveResult> saveResults = UTIL_ClaimShareClaimant.insertClaimShares(agentRoleData);
        System.assertEquals(2, saveResults.size(), 'Should have 2 results');

        Account claimantAccount2 = getAccount(CLAIMANT_ACCOUNT2);
        TestDataFactory_Claim.createClaimParticipants(claims, claimantAccount2.Id, CLAIMANT_ROLE_CODE);

        List<Account> claimantAccounts2 = new List<Account>();
        claimantAccounts2.add(claimantAccount2);
        AgentRoleData agentRoleData2 = TestDataFactory_Claim.generateAgentRoleData(claimantAccounts, getProxies().get(1));
        List<Database.SaveResult> saveResults2 = UTIL_ClaimShareClaimant.insertClaimShares(agentRoleData2);
        System.assertEquals(2, saveResults2.size(), 'Should have 2 results');

        User deleteProxy = getProxies().get(0);
        AgentRoleData deleteAgentRoleData = TestDataFactory_Claim.generateAgentRoleData(claimantAccounts, deleteProxy);

        Test.startTest();
        List<Database.DeleteResult> results = UTIL_ClaimShareClaimant.deleteClaimShares(deleteAgentRoleData);
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Should have 2 results');
        assertDeleteResults(results);
        assertClaimShareCount(claims, 2);
    }

    /**
    * @name testClaimSharesDeleteFromAgentRoleDataWithNoShares
    * @description verifies that no claim share records are deletes when there are none for the AgentRole
    */
   @isTest
   private static void testClaimSharesDeleteFromAgentRoleDataWithNoShares() {
       UTIL_ClaimShareClaimant.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIMANT_SHARES, true);

       Account account = getAccount(CLAIM_ACCOUNT);
       InsurancePolicy policy7 = getInsurancePolicy();
       List<Claim> claims = TestDataFactory_Claim.generateClaims(2, account, policy7);
       claims = TestDataFactory_Claim.insertClaims(claims);

       Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
       TestDataFactory_Claim.createClaimParticipants(claims, claimantAccount.Id, CLAIMANT_ROLE_CODE);
       
       List<Account> claimantAccounts = new List<Account>();
       claimantAccounts.add(claimantAccount);
       AgentRoleData agentRoleData = TestDataFactory_Claim.generateAgentRoleData(claimantAccounts, getProxies().get(0));
       List<Database.SaveResult> saveResults = UTIL_ClaimShareClaimant.insertClaimShares(agentRoleData);
       System.assertEquals(2, saveResults.size(), 'Should have 2 results');

       User deleteProxy = getProxies().get(1);
       AgentRoleData deleteAgentRoleData = TestDataFactory_Claim.generateAgentRoleData(claimantAccounts, deleteProxy);

       Test.startTest();
       List<Database.DeleteResult> results = UTIL_ClaimShareClaimant.deleteClaimShares(deleteAgentRoleData);
       Test.stopTest();

       System.assertEquals(0, results.size(), 'Should have 0 results');
       assertClaimShareCount(claims, 2);
   }

    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static void assertSaveResults(List<Database.SaveResult> results) {
        for (Database.SaveResult result : results) {
            System.assert(result.isSuccess(), 'Save results should be successful');
        }
    }
    
    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static void assertDeleteResults(List<Database.DeleteResult> results) {
        for (Database.DeleteResult result : results) {
            System.assert(result.isSuccess(), 'Delete results should be successful');
        }
    }

    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static void assertClaimShareCount(List<Claim> claims, Integer expected) {
        List<ClaimShare> claimShares = [SELECT Id
                                        FROM ClaimShare
                                        WHERE ParentId IN :claims AND RowCause = 'Manual'];

        System.assertEquals(expected, claimShares.size(), 'The number of actual claim shares should match the expected count');
    }

    /**
     * @name testClaimSharesCreatedFromClaimParticipantData
     * @description verifies that claim share records are created when claim participants are inserted
     */
    @isTest
    private static void testClaimSharesCreatedFromClaimParticipantData() {
        Account account = getAccount(CLAIM_ACCOUNT);
        InsurancePolicy policy8 = getInsurancePolicy();
        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account, policy8);
        claims = TestDataFactory_Claim.insertClaims(claims);

        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        List<ClaimParticipant> claimParticipants = TestDataFactory_Claim.generateClaimParticipants(claims, claimantAccount.Id, CLAIMANT_ROLE_CODE);
        
        List<Account> claimantAccounts = new List<Account>();
        claimantAccounts.add(claimantAccount);
        AgentRoleData agentRoleData = TestDataFactory_Claim.generateAgentRoleData(claimantAccounts, getProxyAgent(PROXY_AGENT));
        List<AgentRole__c> agentRoles = agentRoleData.agentRoles;
        insert agentRoles;

        Test.startTest();
        List<Database.SaveResult> results = UTIL_ClaimShareClaimant.insertClaimShares(claimParticipants);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should have 1 results');
        assertSaveResults(results);
    }

    /**
     * @name testClaimSharesNotCreatedFromClaimParticipantData
     * @description verifies that claim share records are not created when claim participants are inserted
     */
    @isTest
    private static void testClaimSharesNotCreatedFromClaimParticipantData() {
        Account account = getAccount(CLAIM_ACCOUNT);
        InsurancePolicy policy9 = getInsurancePolicy();
        List<Claim> claims = TestDataFactory_Claim.generateClaims(2, account, policy9);
        claims = TestDataFactory_Claim.insertClaims(claims);

        Account claimantAccount = getAccount(CLAIMANT_ACCOUNT);
        List<ClaimParticipant> claimParticipants = TestDataFactory_Claim.createClaimParticipants(claims, claimantAccount.Id, '');
        
        AgentRoleData agentRoleData = TestDataFactory_Claim.generateAgentRoleData(new List<Account>{claimantAccount}, getProxyAgent(PROXY_AGENT));
        List<AgentRole__c> agentRoles = agentRoleData.agentRoles;
        insert agentRoles;

        Test.startTest();
        List<Database.SaveResult> results = UTIL_ClaimShareClaimant.insertClaimShares(claimParticipants);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should have 0 results');
        assertSaveResults(results);
    }
}
