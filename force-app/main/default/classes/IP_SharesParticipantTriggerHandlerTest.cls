/*
 * @author Team Kraken (kdcv)
 * @description : Tests for IP_SharesParticipantTriggerHandler
 * @version 1.0
 * @dateCreated 11/06/2020
 */
@isTest
(seeAllData = false)
public with sharing class IP_SharesParticipantTriggerHandlerTest {
    
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
    private static void validateIPSharesAreInsertedForParticipantWithMultipleAgents() {
        // Get the accounts we need to create a participant
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account3 = TestDataFactory_AgencyShares.getAccount3();

        Test.startTest();
        // Assign that account to an insurance policy and insert it
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('PolicyOneTest', account1.Id);

        List<InsurancePolicyShare> sharesBeforeInsert = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];

        // Add a participant to the policy
        TestDataFactory_AgencyShares.insertParticipant(account3.Id, policy.Id);

        Test.stopTest();

        List<InsurancePolicyShare> sharesAfterInsert = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];
        System.assertEquals(sharesBeforeInsert.size() + 2, sharesAfterInsert.size(), 'A participant was added that has two agents. The number of shares should have increased by 2');

        List<Id> proxyIds = new List<Id>();
        for (InsurancePolicyShare share : sharesAfterInsert) {
            proxyIds.add(share.UserOrGroupId);
        }

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy2 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_TWO_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        System.assert(proxyIds.contains(proxy1.Id), 'This list of shares should contain the proxy for account1 since they are the name insured on the policy');
        System.assert(proxyIds.contains(proxy2.Id), 'This list of shares should contain the proxy for account2 since they are a participant on the policy');
        System.assert(proxyIds.contains(proxy4.Id), 'This list of shares should contain the proxy for account2 since they are a participant on the policy');
    }

    @isTest
    private static void validateIPShareIsRetainedForParticipantsWhichShareAgent() {
        // Get the accounts we need to create a participant
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount2();

        Test.startTest();
        // Assign that account to an insurance policy and insert it
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('PolicyOneTest', account1.Id);

        // Add a participant to the policy
        InsurancePolicyParticipant participant = TestDataFactory_AgencyShares.insertParticipant(account2.Id, policy.Id);

        List<InsurancePolicyShare> sharesAfterInsert = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];

        // Now we delete the participant and this should check to see if there are any other 
        // policy members (in this case name insured on the policy) that exist with the same agent
        // (account 1 and account 2 share an agent) so in this scenario the share from the policy to this agent
        // should NOT be deleted
        delete participant;
        Test.stopTest();

        List<InsurancePolicyShare> sharesAfterParticipantDelete = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];
        System.assertEquals(sharesAfterInsert.size(), sharesAfterParticipantDelete.size(), 'An InsurancePolicyShare was deleted when it shouldnt have been. The number of shares should be the same');

        List<Id> proxyIds = new List<Id>();
        for (InsurancePolicyShare share : sharesAfterParticipantDelete) {
            proxyIds.add(share.UserOrGroupId);
        }

        User proxyForAccount1And2 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        System.assert(proxyIds.contains(proxyForAccount1And2.Id), 'This list of shares should contain the proxy for account1/account2');
    }

    @isTest
    private static void validateIPShareIsDeletedForParticipantNotSharingAgent() {
        // Get the accounts we need to create a participant
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account4 = TestDataFactory_AgencyShares.getAccount4();

        Test.startTest();
        // Assign that account to an insurance policy and insert it
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('PolicyOneTest', account1.Id);

        // Add a participant to the policy
        InsurancePolicyParticipant participant = TestDataFactory_AgencyShares.insertParticipant(account4.Id, policy.Id);

        List<InsurancePolicyShare> sharesAfterInsert = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];

        // Now we delete the participant and this should check to see if there are any other 
        // policy members (in this case name insured on the policy) that exist with the same agent
        // (account 1 and account 2 share an agent) so in this scenario the share from the policy to this agent
        // should NOT be deleted
        delete participant;
        Test.stopTest();

        List<InsurancePolicyShare> sharesAfterParticipantDelete = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];
        System.assertEquals(sharesAfterInsert.size() - 1, sharesAfterParticipantDelete.size(), 'The InsurancePolicyShare for Account 4 should have been deleted, but wasnt');

        List<Id> proxyIds = new List<Id>();
        for (InsurancePolicyShare share : sharesAfterParticipantDelete) {
            proxyIds.add(share.UserOrGroupId);
        }

        User proxyForAccount4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        System.assert(!proxyIds.contains(proxyForAccount4.Id), 'This list of shares should NOT contain the proxy for account4');
    }

    @isTest
    private static void validateIPSharesAreDeletedForParticipantWithMultipleAgents() {
        // Get the accounts we need to create a participant
        Account account1 = TestDataFactory_AgencyShares.getAccount1(); // agent 1
        Account account3 = TestDataFactory_AgencyShares.getAccount3(); // agent 2 & 4
        Account account4 = TestDataFactory_AgencyShares.getAccount4(); // agent 4

        // shares:
        // policy 1 - agent 1
        // policy 1 - agent 2
        // policy 1 - agent 4

        Test.startTest();
        // Assign that account to an insurance policy and insert it
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('PolicyOneTest', account1.Id);

        InsurancePolicyParticipant participant = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account3.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant2 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account4.Id, InsurancePolicyId = policy.Id, Role='Insured');
        List<InsurancePolicyParticipant> participants = new List<InsurancePolicyParticipant> { participant, participant2 };

        // Now we insert our participant in order to test delete
        insert participants;


        // Now we delete them all, only account 1 agent should have shares
        delete participants;
        Test.stopTest();

        List<InsurancePolicyShare> sharesAfterParticipantDelete = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];
        
        //System.assertEquals(sharesAfterInsert.size() - 3, sharesAfterParticipantDelete.size(), 'The InsurancePolicyShare for Account 3 and Account 4 should have been deleted, but wasnt');

        List<Id> proxyIds = new List<Id>();
        for (InsurancePolicyShare share : sharesAfterParticipantDelete) {
            proxyIds.add(share.UserOrGroupId);
        }

        User proxyForAccount3 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_TWO_EMAIL];
        User proxyForAccount3And4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        System.assert(!proxyIds.contains(proxyForAccount3.Id), 'This list of shares should NOT contain the Agent Proxy 2 (assigned to account3)');
        System.assert(!proxyIds.contains(proxyForAccount3And4.Id), 'This list of shares should NOT contain the Agent Proxy 4 (assigned to account3 & account4)');
    }

    @isTest
    private static void validateIPSharesAreNotDeletedForParticipantWithSharedAgents() {
        // Get the accounts we need to create a participant
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account3 = TestDataFactory_AgencyShares.getAccount3();
        Account account4 = TestDataFactory_AgencyShares.getAccount4();

        List<InsurancePolicyShare> sharesAfterInsertPolicy1 = new List<InsurancePolicyShare>();
        List<InsurancePolicyShare> sharesAfterInsertPolicy2 = new List<InsurancePolicyShare>();
        Test.startTest();
        // We are mocking already having a policy created with its own shares existing already
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('PolicyOneTest', account1.Id);
        InsurancePolicy policy2 = TestDataFactory_AgencyShares.insertPolicy('PolicyTwoTest', account4.Id);
        List<Id> policyIds = new List<Id> { policy.Id, policy2.Id };

        InsurancePolicyParticipant participant = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account4.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant2 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy2.Id, Role='Insured');
        InsurancePolicyParticipant participant3 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account3.Id, InsurancePolicyId = policy2.Id, Role='Insured');
        List<InsurancePolicyParticipant> participants = new List<InsurancePolicyParticipant> { participant, participant2, participant3 };
        List<InsurancePolicyParticipant> participantsToDelete = new List<InsurancePolicyParticipant> { participant, participant2 };

        // Now we insert our participant in order to test delete
        insert participants;

        sharesAfterInsertPolicy1 = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];
        sharesAfterInsertPolicy2 = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy2.Id];

        // Now we delete them all, only account 1 agent should have shares
        delete participantsToDelete;
        Test.stopTest();

        System.assert(sharesAfterInsertPolicy1.size() == 3, 'There should only be 3 shares (1 is auto generated)');
        System.assert(sharesAfterInsertPolicy2.size() == 4, 'There should only be 5 shares (1 is auto generated)');

        List<InsurancePolicyShare> sharesAfterParticipantsDelete = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId IN :policyIds];

        Map<Id, List<Id>> shares = new Map<Id, List<Id>>();
        for (InsurancePolicyShare share : sharesAfterParticipantsDelete) {
            List<Id> proxies = shares.get(share.ParentId);

            if (proxies == null) {
                proxies = new List<Id>();
            }
            proxies.add(share.UserOrGroupId);

            shares.put(share.ParentId, proxies);
        }

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy2 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_TWO_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        
        System.assert(shares.get(policy.Id) != null, 'There should be a share for policy 1');
        System.assert(shares.get(policy.Id).contains(proxy1.Id), 'The list of shares should have contained a share tied to policy 1 and account 1 proxy');
        System.assert(!shares.get(policy.Id).contains(proxy4.Id), 'The list of shares should NOT contain a share tied to policy 1 and account 4 proxy');

        System.assert(shares.get(policy2.Id) != null, 'There should be shares for policy 2');
        System.assert(!shares.get(policy2.Id).contains(proxy1.Id), 'The list of shares should NOT contain a share tied to policy 2 and account 1 proxy');
        System.assert(shares.get(policy2.Id).contains(proxy4.Id), 'The list of shares should have contained a share tied to policy 2 and account 4 proxy');
        System.assert(shares.get(policy2.Id).contains(proxy2.Id), 'The list of shares should have contained a share tied to policy 2 and account 2 proxy');
    }

    @isTest
    private static void validateIPSharesAreDeletedForPolicyWithSameParticipantWithSharedAgents() {
        // Get the accounts we need to create a participant
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account4 = TestDataFactory_AgencyShares.getAccount4();

        List<InsurancePolicyShare> sharesAfterInsertPolicy = new List<InsurancePolicyShare>();
    
        Test.startTest();
        // We are mocking already having a policy created with its own shares existing already
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('PolicyOneTest', account1.Id);

        InsurancePolicyParticipant participant = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant2 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account4.Id, InsurancePolicyId = policy.Id, Role='Insured');
        List<InsurancePolicyParticipant> participants = new List<InsurancePolicyParticipant> { participant, participant2 };

        // Now we insert our participant in order to test delete
        insert participants;

        sharesAfterInsertPolicy = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];

        // Now we delete them all, only account 1 agent should have shares
        delete participant2;
        Test.stopTest();

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];

        System.assert(sharesAfterInsertPolicy.size() == 3, 'Before participant delete, there should only be 3 shares (1 is auto generated) Acct1 has 1 agent, Acct4 has 1 agent');

        List<InsurancePolicyShare> sharesAfterParticipantDelete = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];

        List<Id> proxyIds = new List<Id>();
        for (InsurancePolicyShare share : sharesAfterParticipantDelete) {
            proxyIds.add(share.UserOrGroupId);
        }

        System.assert(sharesAfterParticipantDelete.size() == 2, 'There should be 3 shares for policy 1, after delete (deleted acct1 participant). 1 for policy/participant, 1 auto gen');
        System.assert(proxyIds.contains(proxy1.Id), 'The list of shares should have contained a share tied to policy 1 and account 1 proxy (policy nameinsured)');
        System.assert(!proxyIds.contains(proxy4.Id), 'The list of shares should have contained a share tied to policy 1 and account 4 proxy (participant)');
    }

    @isTest
    private static void validateIPSharesAreNotDeletedForSharedPolicyWhenParticipantIsDeletedWithSharedAgents() {
        // Get the accounts we need to create a participant
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account4 = TestDataFactory_AgencyShares.getAccount4();

        List<InsurancePolicyShare> sharesAfterInsertPolicy = new List<InsurancePolicyShare>();
    
        Test.startTest();
        // We are mocking already having a policy created with its own shares existing already
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('PolicyOneTest', account1.Id);

        InsurancePolicyParticipant participant = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant2 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account4.Id, InsurancePolicyId = policy.Id, Role='Insured');
        List<InsurancePolicyParticipant> participants = new List<InsurancePolicyParticipant> { participant, participant2 };

        // Now we insert our participant in order to test delete
        insert participants;

        sharesAfterInsertPolicy = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];

        // Now we delete them all, only account 1 agent should have shares
        delete participant;
        Test.stopTest();

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];

         System.assert(sharesAfterInsertPolicy.size() == 3, 'Before participant delete, there should only be 3 shares (1 is auto generated) Acct1 has 1 agent, Acct4 has 1 agent');

        List<InsurancePolicyShare> sharesAfterParticipantDelete = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];

        List<Id> proxyIds = new List<Id>();
        for (InsurancePolicyShare share : sharesAfterParticipantDelete) {
            proxyIds.add(share.UserOrGroupId);
        }

        System.assert(sharesAfterParticipantDelete.size() == 3, 'There should be 3 shares for policy 1, after delete (deleted acct1 participant). 1 for policy/participant, 1 auto gen');
        System.assert(proxyIds.contains(proxy1.Id), 'The list of shares should have contained a share tied to policy 1 and account 1 proxy (policy nameinsured)');
        System.assert(proxyIds.contains(proxy4.Id), 'The list of shares should have contained a share tied to policy 1 and account 4 proxy (participant)');
    }

    @isTest
    private static void validateIPSharesAreNotDeletedForMultipleSameParticipantAndSamePolicyAccount() {
        // Get the accounts we need to create a participant
        Account account1 = TestDataFactory_AgencyShares.getAccount1();

        List<InsurancePolicyShare> sharesAfterInsertPolicy = new List<InsurancePolicyShare>();
    
        Test.startTest();
        // We are mocking already having a policy created with its own shares existing already
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('PolicyOneTest', account1.Id);

        InsurancePolicyParticipant participant = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant2 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant3 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant4 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        List<InsurancePolicyParticipant> participants = new List<InsurancePolicyParticipant> { participant, participant2, participant3, participant4 };
        List<InsurancePolicyParticipant> toDeleteParticipants = new List<InsurancePolicyParticipant> { participant, participant2 };

        // Now we insert our participant in order to test delete
        insert participants;

        sharesAfterInsertPolicy = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];

        // Now we delete them all, only account 1 agent should have shares
        delete toDeleteParticipants;
        Test.stopTest();

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];

        List<InsurancePolicyShare> sharesAfterParticipantDelete = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];

        List<Id> proxyIds = new List<Id>();
        for (InsurancePolicyShare share : sharesAfterParticipantDelete) {
            proxyIds.add(share.UserOrGroupId);
        }

        System.assert(sharesAfterParticipantDelete.size() == 2, 'There should be 2 shares for policy 1, after delete - 1 for policy/participants, 1 auto gen');
        System.assert(proxyIds.contains(proxy1.Id), 'The list of shares should have contained a share tied to policy 1 and account1');
    }

    @isTest
    private static void validateIPSharesAreNotDeletedForMultipleSameParticipantAndDifferentPolicyAccount() {
        // Get the accounts we need to create a participant
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account4 = TestDataFactory_AgencyShares.getAccount4();

        List<InsurancePolicyShare> sharesAfterInsert = new List<InsurancePolicyShare>();
    
        Test.startTest();
        // We are mocking already having a policy created with its own shares existing already
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('PolicyASDF', account4.Id);

        InsurancePolicyParticipant participant = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant2 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant3 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        InsurancePolicyParticipant participant4 = new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Insured');
        List<InsurancePolicyParticipant> participants = new List<InsurancePolicyParticipant> { participant, participant2, participant3, participant4 };
        List<InsurancePolicyParticipant> toDeleteParticipants = new List<InsurancePolicyParticipant> { participant, participant2 };

        // Now we insert our participant in order to test delete
        insert participants;

        sharesAfterInsert = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];

        // Now we delete them all, only account 1 agent should have shares
        delete toDeleteParticipants;
        Test.stopTest();

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];

        List<Id> proxyIdsAfterInsert = new List<Id>();
        for (InsurancePolicyShare share : sharesAfterInsert) {
            proxyIdsAfterInsert.add(share.UserOrGroupId);
        }

        System.assert(proxyIdsAfterInsert.contains(proxy1.Id), 'The list of shares should have contained a share after Insert tied to policy 1 and account1');
        System.assert(proxyIdsAfterInsert.contains(proxy4.Id), 'The list of shares should have contained a share after Insert tied to policy 1 and account4');
        

        List<InsurancePolicyShare> sharesAfterParticipantDelete = [SELECT Id, ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.Id];
        List<Id> proxyIds = new List<Id>();
        for (InsurancePolicyShare share : sharesAfterParticipantDelete) {
            proxyIds.add(share.UserOrGroupId);
        }

        System.assert(sharesAfterParticipantDelete.size() == 3, 'There should be 3 shares for policy 1, after delete - 2 for policy/participants, 1 auto gen');
        System.assert(proxyIds.contains(proxy1.Id), 'The list of shares should have contained a share after Delete tied to policy 1 and account1');
        System.assert(proxyIds.contains(proxy4.Id), 'The list of shares should have contained a share after Delete tied to policy 1 and account4');
    }
}
