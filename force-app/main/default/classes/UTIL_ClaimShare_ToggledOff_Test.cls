@isTest(seeAllData=false)
public with sharing class UTIL_ClaimShare_ToggledOff_Test {

    private static final String [] PROXIES = new String[] {'1111', '2222'};
    private static final String ACCOUNT = 'Test';
    private static final String POLICY = 'Test';

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
            createOffice(proxy);
        }
        Account testAccount = TestDataFactory_Account.createIndividualCustomer(ACCOUNT);
        insert testAccount;

        createInsurancePolicy(POLICY, testAccount);
    }

    private static List<User> getProxies() {
        return [SELECT Id
                FROM User
                WHERE Servicing_Agent_Associate_ID__c IN :PROXIES];
    }

    private static Account getAccount() {
        return [SELECT Id
                FROM Account
                WHERE FirstName = :ACCOUNT];
    }

    private static InsurancePolicy getInsurancePolicy() {
        return [SELECT Id
                FROM InsurancePolicy
                WHERE Name = :POLICY];
    }

    /**
    * @name testClaimSharesCreatedFromClaimsAsyncToggleOff
    * @description verifies that ClaimShare records are not created asynchronously
    * when the toggle is not enabled
    */
    @isTest
    private static void testClaimSharesCreatedFromClaimsAsyncToggleOff() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, false);

        Account account1 = getAccount();
        InsurancePolicy policy1 = getInsurancePolicy();
        createInsurancePolicyShares(policy1, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account1, policy1);
        claims = TestDataFactory_Claim.insertClaims(claims);
        
        Test.startTest();
        ClaimShareQueueable queueable = new ClaimShareQueueable(claims, true);
        System.enqueueJob(queueable);
        Test.stopTest();

        assertClaimShareCount(claims, 0);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimSharesUpdatedFromClaimsAsyncToggleOff
    * @description verifies that ClaimShare records are not updated asynchronously
    * when the toggle is not enabled
    */
    @isTest
    private static void testClaimSharesUpdatedFromClaimsAsyncToggleOff() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, false);

        Account account2 = getAccount();
        InsurancePolicy policy2 = getInsurancePolicy();
        createInsurancePolicyShares(policy2, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account2, policy2);
        claims = TestDataFactory_Claim.insertClaims(claims);

        List<User> newOffice = new List<User>{createOffice('NEW')};
        createInsurancePolicyShares(policy2, newOffice);
        
        Test.startTest();
        ClaimShareQueueable queueable = new ClaimShareQueueable(claims, false);
        System.enqueueJob(queueable);
        Test.stopTest();

        assertClaimShareCount(claims, 0);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimSharesCreatedFromClaimsToggleOff
    * @description verifies that ClaimShare records are not created from Claim records
    * when the toggle is not enabled
    */
    @isTest
    private static void testClaimSharesCreatedFromClaimsToggleOff() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, false);

        Account account3 = getAccount();
        InsurancePolicy policy3 = getInsurancePolicy();
        createInsurancePolicyShares(policy3, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account3, policy3);
        claims = TestDataFactory_Claim.insertClaims(claims);
        
        Test.startTest();     
        List<Database.SaveResult> results = UTIL_ClaimShare.insertClaimShares(claims);
        Test.stopTest();

        assertSaveResults(results);
        assertClaimShareCount(claims, 0);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimSharesCreatedFromPolicySharesToggleOff
    * @description verifies that ClaimShare records are not created from InsurancePolicyShare records
    * when the toggle is not enabled
    */
    @isTest
    private static void testClaimSharesCreatedFromPolicySharesToggleOff() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, false);

        Account account4 = getAccount();
        InsurancePolicy policy4 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy4, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account4, policy4);
        claims = TestDataFactory_Claim.insertClaims(claims);
        
        Test.startTest();     
        List<Database.SaveResult> results = UTIL_ClaimShare.insertClaimShares(policyShares);
        Test.stopTest();

        assertSaveResults(results);
        assertClaimShareCount(claims, 0);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimSharesCreatedFromClaimsPolicyNotAttachedToggleOff
    * @description verifies that no ClaimShare records are created if Claim records
    * are not related to InsurancePolicy records and the toggle is not enabled
    */
    @isTest
    private static void testClaimSharesCreatedFromClaimsPolicyNotAttachedToggleOff() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, false);

        Account account5 = getAccount();

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account5, null);
        claims = TestDataFactory_Claim.insertClaims(claims);
        
        Test.startTest();     
        List<Database.SaveResult> results = UTIL_ClaimShare.insertClaimShares(claims);
        Test.stopTest();

        assertSaveResults(results);
        assertClaimShareCount(claims, 0);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testNoClaimSharesCreatedWhenPolicySharesEmptyToggleOff
    * @description verifies that no ClaimShare records are created if the list of 
    * InsurancePolicyShare records is empty and the toggle is not enabled
    */
    @isTest
    private static void testNoClaimSharesCreatedWhenPolicySharesEmptyToggleOff() {    
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, false);

        Account account6 = getAccount();
		InsurancePolicy policy5 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy5, new List<User>());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account6, policy5);
        claims = TestDataFactory_Claim.insertClaims(claims);
        
        Test.startTest();     
        List<Database.SaveResult> results = UTIL_ClaimShare.insertClaimShares(policyShares);
        Test.stopTest();

        assertSaveResults(results);
        assertClaimShareCount(claims, 0);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testNoClaimSharesCreatedWhenPolicySharesMissingToggleOff
    * @description verifies that no ClaimShare records are created if the InsurancePolicyShare do not exist
    * and the toggle is not enabled
    */
    @isTest
    private static void testNoClaimSharesCreatedWhenPolicySharesMissingToggleOff() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, false);

        Account account7 = getAccount();
        InsurancePolicy policy6 = getInsurancePolicy();
        
        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account7, policy6);
        claims = TestDataFactory_Claim.insertClaims(claims);
        
        Test.startTest();     
        List<Database.SaveResult> results = UTIL_ClaimShare.insertClaimShares(claims);
        Test.stopTest();

        assertSaveResults(results);
        assertClaimShareCount(claims, 0);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimSharesUpdateNewPolicyShareAddedToggleOff
    * @description verifies that ClaimShare records are not created when new InsurancePolicyShare records are present
    * and the toggle is not enabled
    */
    @isTest
    private static void testClaimSharesUpdateNewPolicyShareAddedToggleOff() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, false);

        Account account8 = getAccount();
        InsurancePolicy policy7 = getInsurancePolicy();
        createInsurancePolicyShares(policy7, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account8, policy7);
        claims = TestDataFactory_Claim.insertClaims(claims);
        UTIL_ClaimShare.insertClaimShares(claims);

        List<User> newOffice = new List<User>{createOffice('NEW')};
        createInsurancePolicyShares(policy7, newOffice);

        Test.startTest();
        List<Object> results = UTIL_ClaimShare.updateClaimShares(claims);
        Test.stopTest();

        assertSaveResults((List<Database.SaveResult>) results[0]);
        assertDeleteResults((List<Database.DeleteResult>) results[1]);
        assertClaimShareCount(claims, 0);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimSharesUpdatePolicySharesLostToggleOff
    * @description verifies that ClaimShare records are not updated when InsurancePolicyShare records have been removed
    * and the toggle is not enabled
    */
    @isTest
    private static void testClaimSharesUpdatePolicySharesLostToggleOff() {
        Account account9 = getAccount();
        InsurancePolicy policy8 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy8, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account9, policy8);
        claims = TestDataFactory_Claim.insertClaims(claims);

        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);
        UTIL_ClaimShare.insertClaimShares(claims);

        delete policyShares[0];
        
        Test.startTest();
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, false);
        List<Object> results = UTIL_ClaimShare.updateClaimShares(claims);
        Test.stopTest();

        List<Database.SaveResult> saveResults = (List<Database.SaveResult>) results[0];
        assertSaveResults(saveResults);
        System.assertEquals(0, saveResults.size(), 'The number of save results should match the expected count');

        List<Database.DeleteResult> deleteResults = (List<Database.DeleteResult>) results[1];
        assertDeleteResults(deleteResults);
        System.assertEquals(0, deleteResults.size(), 'The number of delete results should match the expected count');
    }

    /**
    * @name testClaimSharesUpdateAllPolicySharesLostToggleOff
    * @description verifies that ClaimShare records are not removed when InsurancePolicyShare records have been removed
    * and the toggle is not enabled
    */
    @isTest
    private static void testClaimSharesUpdateAllPolicySharesLostToggleOff() {
        Account account10 = getAccount();
        InsurancePolicy policy9 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy9, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account10, policy9);
        claims = TestDataFactory_Claim.insertClaims(claims);

        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);
        UTIL_ClaimShare.insertClaimShares(claims);

        delete policyShares;

        Test.startTest();
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, false);
        List<Object> results = UTIL_ClaimShare.updateClaimShares(claims);
        Test.stopTest();

        List<Database.SaveResult> saveResults = (List<Database.SaveResult>) results[0];
        assertSaveResults(saveResults);
        System.assertEquals(0, saveResults.size(), 'The number of save results should match the expected count');

        List<Database.DeleteResult> deleteResults = (List<Database.DeleteResult>) results[1];
        assertDeleteResults(deleteResults);
        System.assertEquals(0, deleteResults.size(), 'The number of delete results should match the expected count');
    }

    /**
    * @name testClaimShareIsDeletedToggleOff
    * @description verifies that ClaimShare records are not deleted from given InsurancePolicyShare records
    * and the toggle is not enabled
    */
    @isTest
    private static void testClaimShareIsDeletedToggleOff() {
        Account account11 = getAccount();
        InsurancePolicy policy10 = getInsurancePolicy();        
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy10, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account11, policy10);
        claims = TestDataFactory_Claim.insertClaims(claims);

        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);
        List<InsurancePolicyShare> policySharesToDelete = new List<InsurancePolicyShare>();
        UTIL_ClaimShare.insertClaimShares(policyShares);
        policySharesToDelete.add(policyShares.get(0));

        Test.startTest();
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, false);
        List<Database.DeleteResult> deleteResults = UTIL_ClaimShare.deleteClaimShares(policySharesToDelete);
        Test.stopTest();

        assertDeleteResults(deleteResults);
        System.assertEquals(0, deleteResults.size(), 'The number of delete results should match the expected count');
    }

    /**
    * @name testClaimSharesMaintainedAfterClaimsUpdatedToggleOff
    * @description verifies that ClaimShare records are retained when the toggle is not enabled
    */
    @isTest
    private static void testClaimSharesMaintainedAfterClaimsUpdatedToggleOff() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

        Account account12 = getAccount();
        InsurancePolicy policy11 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy11, getProxies());
        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account12, policy11);
        claims = TestDataFactory_Claim.insertClaims(claims);

        Test.startTest();
        List<Database.SaveResult> results = UTIL_ClaimShare.insertClaimShares(claims);

        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, false);
        claims[0].Name = 'Updated claim';
        claims = TestDataFactory_Claim.updateClaims(claims);
        Test.stopTest();

        assertSaveResults(results);
        assertClaimShareCount(claims, policyShares.size() * claims.size());
        System.assert(true, 'Mandatory Assert statement on Tests');
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
        List<ClaimShare> claimShares = [SELECT Id, ParentId, UserOrGroupId
                                        FROM ClaimShare
                                        WHERE ParentId IN :claims AND RowCause = 'Manual'];

        System.assertEquals(expected, claimShares.size(), 'The number of actual claim shares should match the expected count');
    }

    private static List<InsurancePolicy> createInsurancePolicies(Integer count, Account account) {
        List<InsurancePolicy> policies = new List<InsurancePolicy>();
        for (Integer i = 0; i < count; i++) {
            InsurancePolicy policy12 = createInsurancePolicy('Policy ' + i, account);
            policies.add(policy12);
        }
        insert policies;

        return policies;
    }

    private static InsurancePolicy createInsurancePolicy(String name, Account account) {
        InsurancePolicy policy13 = new InsurancePolicy();
        policy13.NameInsuredId = account.Id;
        policy13.Name = name;
        insert policy13;

        return policy13;
    }

    private static List<InsurancePolicyShare> createInsurancePolicyShares(InsurancePolicy policy, List<User> proxies) {
        List<InsurancePolicyShare> policyShares = new List<InsurancePolicyShare>();
        for (User proxy : proxies) {
            InsurancePolicyShare policyShare = new InsurancePolicyShare();
            policyShare.ParentId = policy.Id;
            policyShare.UserOrGroupId = proxy.Id;
            policyShare.AccessLevel = 'Read';
            policyShare.RowCause = 'Manual';
            policyShares.add(policyShare);
        }
        
        insert policyShares;

        return policyShares;
    }

    private static User createOffice(String uniqueValue) {
        User testProxyUser = new User(Alias=uniqueValue,FirstName='ProxyAccOwner',LastName=uniqueValue + 'p',Associate_ID__c=uniqueValue,UserExternalID__c=uniqueValue,Territory_Associate_ID__c=uniqueValue);
        User proxy = UTIL_UserProvisioning_TEST.buildProxyUserRandomUsername(testProxyUser);
        Database.SaveResult result = Database.insert(proxy);
        proxy.Id = result.getId();
        return proxy;
    }
}
