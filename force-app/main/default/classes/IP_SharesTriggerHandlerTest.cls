/*
 * @author Team Kraken (kdcv)
 * @description : Tests for IP_SharesTriggerHandler
 * @version 1.0
 * @dateCreated 11/02/2020
 */
@isTest
(seeAllData = false)
public with sharing class IP_SharesTriggerHandlerTest {
    
    @TestSetup
    static void setupData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('1701A','systemUser','systemUserTest@statefarm.com'); 
        insert systemAdmin;

        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false, systemAdmin);
        insert passTriggerAll;

        CS001_ByPassTriggerGtoZ__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerGtoZ(systemAdmin);
        objectBasedByPassTrigger.Override_InsurancePolicyTriggers__c = false;
        objectBasedByPassTrigger.Override_IPParticipantTriggers__c = false;
        insert objectBasedByPassTrigger;

        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdmin.id);            
        insert sysAdminUserIdSetting; 
        
        TestDataFactory_AgencyShares.createDataForSharesTesting();
    }

    @isTest
    private static void validateIPShareIsCreatedForNamedInsured() {
        // Get one of the accounts we inserted during setup
        Account account1 = TestDataFactory_AgencyShares.getAccount1();

        Test.startTest();
        // Assign that account to an insurance policy and insert it
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        
        Test.stopTest();

        // Now get the shares that should be inserted
        List<InsurancePolicyShare> sharesAfter = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.id];

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        
        // Find the share that is tied to our new policy and get it's associated proxy id
        List<String> proxyIds = new List<String>();
        for (InsurancePolicyShare share : sharesAfter) { 
            proxyIds.add(share.UserOrGroupId);
        }

        System.assert(proxyIds.size() > 0, 'No share found tied to inserted InsurancePolicy');
        System.assert(proxyIds.contains(proxy1.Id), 'InsurancePolicyShare is not mapped to the correct Proxy Id');
    }

    @isTest
    private static void validateIPShareIsCreatedForMultiplePolicies() {
        // Get one of the accounts we inserted during setup
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        TestDataFactory_AgencyShares.getAccount3();
        Account account4 = TestDataFactory_AgencyShares.getAccount4();

    // Assign that account to an insurance policy
        InsurancePolicy policy = new InsurancePolicy(Name = 'Policy1', NameInsuredId = account1.Id);
        InsurancePolicy policy2 = new InsurancePolicy(Name = 'Policy2', NameInsuredId = account4.Id);
    
        List<InsurancePolicy> policies = new List<InsurancePolicy> { policy, policy2 };

        Test.startTest();
        insert policies;
        policy = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = :'Policy1'];
        policy2 = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = :'Policy2'];
        Test.stopTest();

        // Now get the shares that should be inserted
        List<InsurancePolicyShare> policy1SharesAfter = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.id];
        List<InsurancePolicyShare> policy2SharesAfter = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy2.id];
        
        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];

        List<String> policy1ProxyIds = new List<String>();
        for (InsurancePolicyShare share : policy1SharesAfter) { 
            policy1ProxyIds.add(share.UserOrGroupId);
        }
        
        System.assert(policy1ProxyIds.size() > 0, 'No share found tied to inserted InsurancePolicy 1');
        System.assert(policy1ProxyIds.contains(proxy1.Id), 'InsurancePolicyShare is not mapped to the correct Proxy Id');

        List<String> policy2ProxyIds = new List<String>();
        for (InsurancePolicyShare share : policy2SharesAfter) { 
            policy2ProxyIds.add(share.UserOrGroupId);
        }

        System.assert(policy2ProxyIds.size() > 0, 'No share found tied to inserted InsurancePolicy 2');
        System.assert(policy2ProxyIds.contains(proxy4.Id), 'InsurancePolicyShare is not mapped to the correct Proxy Id');
    }

    @isTest
    private static void validateIPShareIsCreatedForMultipleAgentsOnMultiplePolicies() {
        // Get some of the accounts we inserted during setup
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        
        // Account 3 has two agents so we should see two shares created for his policy
        Account account3 = TestDataFactory_AgencyShares.getAccount3();

        // Assign that account to an insurance policy and insert it
        InsurancePolicy policy = new InsurancePolicy(Name = 'Policy1', NameInsuredId = account1.Id);
        InsurancePolicy policy2 = new InsurancePolicy(Name = 'Policy2', NameInsuredId = account3.Id);

        List<InsurancePolicy> policies = new List<InsurancePolicy> { policy, policy2 };

        Test.startTest();
        insert policies;
        policy = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = :'Policy1'];
        policy2 = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = :'Policy2'];
        Test.stopTest();

        // Now get the shares that should be inserted
        List<InsurancePolicyShare> policy1SharesAfter = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.id];
        List<InsurancePolicyShare> policy2SharesAfter = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy2.id];
        
        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy2 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_TWO_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];

        List<String> policy1ProxyIds = new List<String>();
        for (InsurancePolicyShare share : policy1SharesAfter) { 
            policy1ProxyIds.add(share.UserOrGroupId);
        }

        List<String> policy2ProxyIds = new List<String>();
        for (InsurancePolicyShare share : policy2SharesAfter) { 
            policy2ProxyIds.add(share.UserOrGroupId);
        }
        
        System.assert(policy1ProxyIds.size() > 0, 'No share found tied to inserted InsurancePolicy 1');
        System.assert(policy1ProxyIds.contains(proxy1.Id), 'InsurancePolicyShare is not mapped to the correct Proxy Id');

        System.assert(policy2ProxyIds.size() > 0, 'No share found tied to inserted InsurancePolicy 2');
        System.assert(policy2ProxyIds.contains(proxy2.Id), 'InsurancePolicyShare is missing proxy 2');
        System.assert(policy2ProxyIds.contains(proxy4.Id), 'InsurancePolicyShare is missing proxy 4');
    }

    @isTest
    private static void validateSharesAreDeletedAndInsertedForPolicyUpdate() {
        // Get one of the accounts we inserted during setup
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account3 = TestDataFactory_AgencyShares.getAccount3();
        Account account4 = TestDataFactory_AgencyShares.getAccount4();

        // Assign that account to an insurance policy and insert it
        InsurancePolicy policy = new InsurancePolicy(Name = 'Policy1', NameInsuredId = account1.Id);
        InsurancePolicy policy2 = new InsurancePolicy(Name = 'Policy2', NameInsuredId = account3.Id);
       
        // We must first create the "previous" policies that are going to be updated
        List<Id> previousPolicyIds = new List<Id> { policy.Id, policy2.Id };
        List<InsurancePolicy> previousPolicies = new List<InsurancePolicy> { policy, policy2 };

        List<InsurancePolicyShare> sharesBeforeUpdate = new List<InsurancePolicyShare>();
        Test.startTest();
        // IP_SharesTriggerHandler handler = new IP_SharesTriggerHandler();
        // // First let's insert the shares, so that the shares are created which will be
        // // removed after we do an update
        // handler.handleAfterInsert(previousPolicies.values());
        insert previousPolicies;
        policy = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = :'Policy1'];
        policy2 = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = :'Policy2'];

        List<InsurancePolicyShare> existingSharesForPolicy2 = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy2.Id];

        sharesBeforeUpdate = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId IN :previousPolicyIds];

        InsurancePolicy policyToUpdate = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = 'Policy1'];
        policyToUpdate.NameInsuredId = account4.Id;
        
        InsurancePolicy policyToUpdate2 = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = 'Policy2'];
        policyToUpdate2.Description__c = 'Test 123';
        policyToUpdate2.AgreDisplayPartyName__c = 'Jordan Leeper';

        List<InsurancePolicy> updatedPolicies = new List<InsurancePolicy> { policyToUpdate, policyToUpdate2 };
        update updatedPolicies;

        policyToUpdate = [SELECT Id, NameInsuredId FROM InsurancePolicy WHERE Name = 'Policy1'];
        policyToUpdate2 = [SELECT Id, NameInsuredId FROM InsurancePolicy WHERE Name = 'Policy2'];

        Test.stopTest();

        List<InsurancePolicyShare> sharesAfterUpdate = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId IN :previousPolicyIds];
        System.assertEquals(sharesBeforeUpdate.size(), sharesAfterUpdate.size(), 'The number of shares before should equal the number of shares after in this scenario (both accounts have only 1 agent)');

        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL]; 
        InsurancePolicyShare newlyInsertedShare = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE UserOrGroupId = :proxy4.Id AND ParentId = :policy.Id];
        System.assert(newlyInsertedShare != null, 'Correct InsurancePolicyShare not found for updated policy');

        User proxy1 = [SELECT Id, Email FROM User WHERE Email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        List<InsurancePolicyShare> shouldBeEmpty = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE UserOrGroupId = :proxy1.Id];
        System.assertEquals(0, shouldBeEmpty.size(), 'The InsurancePolicyShare object should have been deleted for proxy1');

        List<InsurancePolicyShare> unchangedShares = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy2.Id];
        System.assertEquals(existingSharesForPolicy2.size(), unchangedShares.size(), 'InsurancePolicyShares for policy2 / account 3 should have remained the same');
    }

    @isTest
    private static void validateIPShareIsRetainedForSharedAgentDuringUpdate() {
        // Get one of the accounts we inserted during setup
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount2();
        Account account4 = TestDataFactory_AgencyShares.getAccount4();

        // Account 1 and Account 2 share an agent - this means that when the 
        // policy is updated, the share should remain.
        // This is because Account 2 is a participant and has the same agent as Account 1

        Test.startTest();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);

        TestDataFactory_AgencyShares.insertParticipant(account2.Id, policy.Id);

        // Lets change the name insured so that we trigger the update/insert/delete code
        InsurancePolicy policyToUpdate = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = 'Policy1'];
        policyToUpdate.NameInsuredId = account4.Id;
        update policyToUpdate;
        policyToUpdate = [SELECT Id, NameInsuredId FROM InsurancePolicy WHERE Name = 'Policy1'];
        
        Test.stopTest();

        List<InsurancePolicyShare> currentShares = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];
        User proxyForAccount1And2 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxyForAccount4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];

        List<Id> proxies = new List<Id>();
        for (InsurancePolicyShare share : currentShares) {
            proxies.add(share.UserOrGroupId);
        }

        System.assert(proxies.contains(proxyForAccount1And2.Id), 'InsurancePolicyShare was improperly deleted when it should have been kept. Account 3 should have retained the share as a participant.');
        System.assert(proxies.contains(proxyForAccount4.Id), 'InsurancePolicyShare should exist for account 4 proxy since we changed the NameInsuredId to Account 4.');
    }

    @isTest
    private static void validateIPShareIsNotDeletedForSharedAgentOnSeparatePolicy() {

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

        // Get one of the accounts we inserted during setup
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account3 = TestDataFactory_AgencyShares.getAccount3();

        // Assign that account to an insurance policy and insert it
        
        InsurancePolicy policy1 = new InsurancePolicy(Name = 'Policy1', NameInsuredId = account1.Id);
        InsurancePolicy policy2 = new InsurancePolicy(Name = 'Policy2', NameInsuredId = account3.Id);
        InsurancePolicy policy3 = new InsurancePolicy(Name = 'Policy3', NameInsuredId = account3.Id);        

        List<InsurancePolicy> policiesToAdd = new List<InsurancePolicy> { policy1, policy2, policy3 };
        List<InsurancePolicy> policiesToDelete = new List<InsurancePolicy> { policy1, policy2 };

        List<InsurancePolicyShare> policy1Shares = new List<InsurancePolicyShare>();
        List<InsurancePolicyShare> policy2Shares = new List<InsurancePolicyShare>();
        List<InsurancePolicyShare> policy3Shares = new List<InsurancePolicyShare>();
        Test.startTest();
        insert policiesToAdd;


        policy1Shares = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy1.Id];
        policy2Shares = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy2.Id];
        policy3Shares = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy3.Id];

        delete policiesToDelete;
        Test.stopTest();

        // Always add a share for the system user that inserted it
        System.assertEquals(2, policy1Shares.size(), 'Shares not inserted for Policy1');
        System.assertEquals(3, policy2Shares.size(), 'Shares not inserted for Policy2');
        System.assertEquals(3, policy3Shares.size(), 'Shares not inserted for Policy3');

        List<InsurancePolicyShare> policy1SharesPostDelete = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy1.Id];
        List<InsurancePolicyShare> policy2SharesPostDelete = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy2.Id];
        List<InsurancePolicyShare> policy3SharesPostDelete = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy3.Id];
       
        // System share is not deleted
        System.assertEquals(1, policy1SharesPostDelete.size(), 'Shares not deleted for Policy1');
        System.assertEquals(1, policy2SharesPostDelete.size(), 'Shares not deleted for Policy2');
        System.assertEquals(3, policy3SharesPostDelete.size(), 'Shares should not have been deleted for Policy3');
    }

    @isTest
    private static void validateIPSharesAreNotDeletedForMultipleSameParticipantAndSamePolicyAccountOnUpdate() {
        // Get the accounts we need to create a participant
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account4 = TestDataFactory_AgencyShares.getAccount4();

        List<InsurancePolicyShare> sharesAfterInsert = new List<InsurancePolicyShare>();
    
        Test.startTest();
        // We are mocking already having a policy created with its own shares existing already
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('PolicyASDF', account1.Id);

        InsurancePolicyParticipant participant = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant2 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant3 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant4 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        List<InsurancePolicyParticipant> participants = new List<InsurancePolicyParticipant> { participant, participant2, participant3, participant4 };

        // Now we insert our participant in order to test delete
        insert participants;

        sharesAfterInsert = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];

        // Now we delete them all, only account 1 agent should have shares
        policy.NameInsuredId = account4.Id;
        update policy;
        Test.stopTest();

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];

        List<Id> proxyIdsAfterInsert = new List<Id>();
        for (InsurancePolicyShare share : sharesAfterInsert) {
            proxyIdsAfterInsert.add(share.UserOrGroupId);
        }

        System.assert(proxyIdsAfterInsert.contains(proxy1.Id), 'The list of shares should have contained a share after Insert tied to policy 1 and account1');
        System.assert(!proxyIdsAfterInsert.contains(proxy4.Id), 'The list of shares should NOT have contained a share after Insert tied to policy 1 and account4');
        
        List<InsurancePolicyShare> sharesAfterUpdate = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];
        List<Id> proxyIds = new List<Id>();
        for (InsurancePolicyShare share : sharesAfterUpdate) {
            proxyIds.add(share.UserOrGroupId);
        }

        System.assert(sharesAfterUpdate.size() == 3, 'There should be 3 shares for policy 1, after delete - 2 for policy/participants, 1 auto gen');
        System.assert(proxyIds.contains(proxy1.Id), 'The list of shares should have contained a share after update tied to policy 1 and account1');
        System.assert(proxyIds.contains(proxy4.Id), 'The list of shares should have contained a share after update tied to policy 1 and account4');
    }
}
