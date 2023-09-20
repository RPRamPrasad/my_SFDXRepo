@isTest(seeAllData=false)
public with sharing class UTIL_ClaimShare_Test {

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
    * @name testClaimSharesCreatedFromClaimsAsync
    * @description verifies that ClaimShare records can be created asynchronously
    */
    @isTest
    private static void testClaimSharesCreatedFromClaimsAsync() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

        Account account1 = getAccount();
        InsurancePolicy policy1 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy1, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account1, policy1);
        claims = TestDataFactory_Claim.insertClaims(claims);
        
        Test.startTest();
        ClaimShareQueueable queueable = new ClaimShareQueueable(claims, true);
        System.enqueueJob(queueable);
        Test.stopTest();

        assertClaimShareCount(claims, policyShares.size() * claims.size());
        System.assert(true, 'Mandatory Assert statement on Tests');
    }



    /**
    * @name testClaimSharesUpdatedFromClaimsAsync
    * @description verifies that ClaimShare records can be updated asynchronously
    */
    @isTest
    private static void testClaimSharesUpdatedFromClaimsAsync() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

        Account account2 = getAccount();
        InsurancePolicy policy2 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy2, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account2, policy2);
        claims = TestDataFactory_Claim.insertClaims(claims);

        List<User> newOffice = new List<User>{createOffice('NEW')};
        createInsurancePolicyShares(policy2, newOffice);
        
        Test.startTest();
        ClaimShareQueueable queueable = new ClaimShareQueueable(claims, false);
        System.enqueueJob(queueable);
        Test.stopTest();

        assertClaimShareCount(claims, (policyShares.size()+1) * claims.size());
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimSharesCreatedFromClaims
    * @description verifies that ClaimShare records can be created from Claim records
    */
    @isTest
    private static void testClaimSharesCreatedFromClaims() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

        Account account3 = getAccount();
        InsurancePolicy policy3 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy3, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account3, policy3);
        claims = TestDataFactory_Claim.insertClaims(claims);
        
        Test.startTest();     
        List<Database.SaveResult> results = UTIL_ClaimShare.insertClaimShares(claims);
        Test.stopTest();

        assertSaveResults(results);
        assertClaimShareCount(claims, policyShares.size() * claims.size());
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimSharesCreatedFromPolicyShares
    * @description verifies that ClaimShare records can be created from InsurancePolicyShare records
    */
    @isTest
    private static void testClaimSharesCreatedFromPolicyShares() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

        Account account4 = getAccount();
        InsurancePolicy policy4 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy4, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account4, policy4);
        claims = TestDataFactory_Claim.insertClaims(claims);
        
        Test.startTest();     
        List<Database.SaveResult> results = UTIL_ClaimShare.insertClaimShares(policyShares);
        Test.stopTest();

        assertSaveResults(results);
        assertClaimShareCount(claims, policyShares.size() * claims.size());
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimSharesCreatedFromClaimsPolicyNotAttached
    * @description verifies that no ClaimShare records are created if Claim records
    * are not related to InsurancePolicy records.
    */
    @isTest
    private static void testClaimSharesCreatedFromClaimsPolicyNotAttached() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

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
    * @name testNoClaimSharesCreatedWhenPolicySharesEmpty
    * @description verifies that no ClaimShare records are created if the list of 
    * InsurancePolicyShare records is empty.
    */
    @isTest
    private static void testNoClaimSharesCreatedWhenPolicySharesEmpty() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

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
    * @name testNoClaimSharesCreatedWhenPolicySharesMissing
    * @description verifies that no ClaimShare records are created if the InsurancePolicyShare do not exist.
    */
    @isTest
    private static void testNoClaimSharesCreatedWhenPolicySharesMissing() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

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
    * @name testClaimSharesUpdateNewPolicyShareAdded
    * @description verifies that ClaimShare records are created when new InsurancePolicyShare records are present
    */
    @isTest
    private static void testClaimSharesUpdateNewPolicyShareAdded() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

        Account account8 = getAccount();
        InsurancePolicy policy7 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy7, getProxies());

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
        assertClaimShareCount(claims, (policyShares.size()+1) * claims.size());
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimSharesUpdatePolicySharesLost
    * @description verifies that ClaimShare records are updated when InsurancePolicyShare records have been removed
    */
    @isTest
    private static void testClaimSharesUpdatePolicySharesLost() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

        Account account9 = getAccount();
        InsurancePolicy policy8 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy8, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account9, policy8);
        claims = TestDataFactory_Claim.insertClaims(claims);
        UTIL_ClaimShare.insertClaimShares(claims);

        delete policyShares[0];

        Test.startTest();
        List<Object> results = UTIL_ClaimShare.updateClaimShares(claims);
        Test.stopTest();

        assertSaveResults((List<Database.SaveResult>) results[0]);
        assertDeleteResults((List<Database.DeleteResult>) results[1]);
        assertClaimShareCount(claims, (policyShares.size()-1) * claims.size());
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimSharesUpdateAllPolicySharesLost
    * @description verifies that ClaimShare records are removed when InsurancePolicyShare records have been removed
    */
    @isTest
    private static void testClaimSharesUpdateAllPolicySharesLost() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

        Account account10 = getAccount();
        InsurancePolicy policy9 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy9, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account10, policy9);
        claims = TestDataFactory_Claim.insertClaims(claims);
        UTIL_ClaimShare.insertClaimShares(claims);

        delete policyShares;

        Test.startTest();
        List<Object> results = UTIL_ClaimShare.updateClaimShares(claims);
        Test.stopTest();

        assertSaveResults((List<Database.SaveResult>) results[0]);
        assertDeleteResults((List<Database.DeleteResult>) results[1]);
        assertClaimShareCount(claims, 0);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimShareIsDeleted
    * @description verifies that ClaimShare records are deleted from given InsurancePolicyShare records
    */
    @isTest
    private static void testClaimShareIsDeleted() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

        Account account11 = getAccount();
        InsurancePolicy policy10 = getInsurancePolicy();        
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy10, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account11, policy10);
        claims = TestDataFactory_Claim.insertClaims(claims);
        List<Database.SaveResult> saveResults = UTIL_ClaimShare.insertClaimShares(policyShares);

        List<InsurancePolicyShare> policySharesToDelete = new List<InsurancePolicyShare>();
        policySharesToDelete.add(policyShares.get(0));

        Test.startTest();     
        List<Database.DeleteResult> deleteResults = UTIL_ClaimShare.deleteClaimShares(policySharesToDelete);
        Test.stopTest();
        
        assertDeleteResults(deleteResults);
        assertClaimShareCount(claims, saveResults.size()-1);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @name testClaimSharesMaintainedAfterClaimsUpdated
    * @description verifies that ClaimShare records are retained after updating Claim records
    */
    @isTest
    private static void testClaimSharesMaintainedAfterClaimsUpdated() {
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

        Account account12 = getAccount();
        InsurancePolicy policy11 = getInsurancePolicy();
        List<InsurancePolicyShare> policyShares = createInsurancePolicyShares(policy11, getProxies());

        List<Claim> claims = TestDataFactory_Claim.generateClaims(1, account12, policy11);
        claims = TestDataFactory_Claim.insertClaims(claims);
        
        Test.startTest();     
        List<Database.SaveResult> results = UTIL_ClaimShare.insertClaimShares(claims);

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