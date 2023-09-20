/*
 * @author Team Nsync
 * @description : Tests for BillingPolicyTriggerHandler
 * @version 1.0
 * @dateCreated 11/10/2021
 */

@isTest
(seeAllData = false)
public with sharing class BillingPolicyTriggerHandler_Test {
    
    @TestSetup
    private static void setupData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('1701A','systemUser','systemUserTest@statefarm.com'); 
        insert systemAdmin;

        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false, systemAdmin);
        insert passTriggerAll;

        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemAdmin);
        objectBasedByPassTrigger.Override_BillingAccountTriggers__c = false;
        insert objectBasedByPassTrigger;

        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdmin.id);            
        insert sysAdminUserIdSetting; 
        
        TestDataFactory_AgencyShares.createDataForSharesTesting();
    }

    @isTest
    private static void testBillingSharesCreatedFromPolicyShares() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        Test.startTest(); 
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
       
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);

        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);

        List<InsurancePolicyShare> policyShares = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.id AND RowCause = 'Manual'];
     
        List<Billing_Account__Share> billingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        
        Test.stopTest();

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];

        List<String> proxyIds1 = new List<String>();
        for (InsurancePolicyShare share : policyShares) { 
            proxyIds1.add(share.UserOrGroupId);
        }

        // Find the share that is tied to new billing policy and get its associated proxy id
        List<String> proxyIds = new List<String>();
        for (Billing_Account__Share share : billingShares) { 
            proxyIds.add(share.UserOrGroupId);
        }

        System.assert(proxyIds1.contains(proxy1.Id), 'Insurance Policy Share is not mapped to the correct Proxy Id');
        System.assert(proxyIds.contains(proxy1.Id), 'Billing_Account__Share is not mapped to the correct Proxy Id');
        System.assertEquals(1,billingShares.size(),'One billing account share was not created');
        System.assertEquals(billingShares.size(),policyShares.size(), 'billing and policy shares do not match');
    }

    @isTest
    private static void testBillingSharesCreatedFromPolicySharesToggledOff() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, false);
        
        Test.startTest(); 
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);
        List<Billing_Account__Share> billingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        
        Test.stopTest();

        System.assertEquals(0, billingShares.size(),'No billing shares should have been created since the billing shares toggle is disabled');
    }

    @isTest
    private static void testBillingSharesCreatedFromPolicySharesWithMultipleBillingPolicies() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        Test.startTest(); 
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount4();
       
        InsurancePolicy policy1 = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        InsurancePolicy policy2 = TestDataFactory_AgencyShares.insertPolicy('Policy2', account1.Id);
        InsurancePolicy policy3 = TestDataFactory_AgencyShares.insertPolicy('Policy3', account2.Id);
        List<Id> insurancePolicyIds = new List<Id>{policy1.Id, policy2.Id, policy3.Id};

        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        Billing_Policy__c billingPolicy1 = TestDataFactory_AgencyShares.generateBillingPolicy(policy1.Id, billingAccount1.Id);
        Billing_Policy__c billingPolicy2 = TestDataFactory_AgencyShares.generateBillingPolicy(policy2.Id, billingAccount1.Id);
        Billing_Policy__c billingPolicy3 = TestDataFactory_AgencyShares.generateBillingPolicy(policy3.Id, billingAccount1.Id);
        List<Billing_Policy__c> billingPolicies  = new List<Billing_Policy__c>{billingPolicy1,billingPolicy2,billingPolicy3};
        insert billingPolicies;


        List<InsurancePolicyShare> policyShares = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId IN :insurancePolicyIds AND RowCause = 'Manual'];
     
        List<Billing_Account__Share> billingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        
        Test.stopTest();
        System.assertEquals(3,policyShares.size(), 'Insurance Policy Shares are not three');
        System.assertEquals(2,billingShares.size(),'Two billing account shares were not created');
    }

    @isTest
    private static void testBillingSharesAfterUpdateWithDifferentPolicy() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount4();
       
        InsurancePolicy policy1 = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        InsurancePolicy policy2 = TestDataFactory_AgencyShares.insertPolicy('Policy2', account2.Id);

        Billing_Account__c billingAccount = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        Billing_Policy__c billingPolicy = TestDataFactory_AgencyShares.generateBillingPolicy(policy1.Id, billingAccount.Id);
        insert billingPolicy;

        List<Billing_Account__Share> sharesBeforeUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount.Id AND RowCause = 'Manual'];
        System.assertEquals(1, sharesBeforeUpdate.size(), 'One Billing Share should be created');
        System.assertEquals(proxy1.Id, sharesBeforeUpdate[0].UserOrGroupId, 'Billing share should be for the first account');

        Test.startTest();

        // change the policy on the billing policy
        billingPolicy.InsurancePolicyId__c = policy2.Id;
        update billingPolicy;
        
        Test.stopTest();

        List<Billing_Account__Share> sharesAfterUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount.Id AND RowCause = 'Manual'];
        System.assertEquals(1, sharesAfterUpdate.size(), 'Only one Billing Share should exist');
        System.assertEquals(proxy4.Id, sharesAfterUpdate[0].UserOrGroupId, 'Billing share should be for the second account');       
    }

    @isTest
    private static void testBillingSharesAfterUpdateWithDifferentPolicyToggledOff() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount4();
       
        InsurancePolicy policy1 = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        InsurancePolicy policy2 = TestDataFactory_AgencyShares.insertPolicy('Policy2', account2.Id);

        Billing_Account__c billingAccount = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        Billing_Policy__c billingPolicy = TestDataFactory_AgencyShares.generateBillingPolicy(policy1.Id, billingAccount.Id);
        insert billingPolicy;

        List<Billing_Account__Share> sharesBeforeUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount.Id AND RowCause = 'Manual'];
        System.assertEquals(1, sharesBeforeUpdate.size(), 'One Billing Share should be created');
        System.assertEquals(proxy1.Id, sharesBeforeUpdate[0].UserOrGroupId, 'Billing share should be for the first account');

        Test.startTest();

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, false);

        // change the policy on the billing policy
        billingPolicy.InsurancePolicyId__c = policy2.Id;
        update billingPolicy;
        
        Test.stopTest();

        List<Billing_Account__Share> sharesAfterUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount.Id AND RowCause = 'Manual'];
        System.assertEquals(1, sharesAfterUpdate.size(), 'Only one Billing Share should exist');
        System.assertEquals(proxy1.Id, sharesAfterUpdate[0].UserOrGroupId, 'Billing Share should not have changed as the billing shares toggle is disabled');
    }

    @isTest
    public static void testAfterDeleteBillingPolicyForPolicyInheritance(){

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        
        Test.startTest();
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount4();
        List<Id> accountIds = new List<Id>{account1.Id, account2.Id};
       
        InsurancePolicy policy1 = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        InsurancePolicy policy2 = TestDataFactory_AgencyShares.insertPolicy('Policy2', account2.Id);
        List<Id> insurancePolicyIds = new List<Id>{policy1.Id, policy2.Id};

        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        Billing_Policy__c billingPolicy1 = TestDataFactory_AgencyShares.insertBillingPolicy(policy1.Id, billingAccount1.Id);
        TestDataFactory_AgencyShares.insertBillingPolicy(policy2.Id, billingAccount1.Id);

        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        TestDataFactory_AgencyShares.insertBillingParticipant(account1.Id, billingAccount1.Id,insertBillingWrap);

        List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIds AND RowCause = 'Manual'];

        List<InsurancePolicyShare> policyShares = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId IN :insurancePolicyIds AND RowCause = 'Manual'];
        
        List<Billing_Account__Share> billingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        
        delete billingPolicy1;
        
        Test.stopTest();

        List<Billing_Account__Share> afterDeleteBillingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];
        
        System.assertEquals(2,accountShares.size(),'Account shares are not two');
        System.assertEquals(2,policyShares.size(), 'Insurance Policy Shares are not two');
        System.assertEquals(2,billingShares.size(),'Billing account shares are not two');
        System.assertEquals(2,afterDeleteBillingShares.size(),'billing account shares are not two after the delete');

    }

    @isTest
    public static void testAfterDeleteBillingPolicyToggledOff(){

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        Account account = TestDataFactory_AgencyShares.getAccount1();    
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account.Id);
        Billing_Account__c billingAccount = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        Billing_Policy__c billingPolicy = TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount.Id);

        List<Billing_Account__Share> beforeDeleteBillingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount.Id AND RowCause = 'Manual'];       
        System.assertEquals(1, beforeDeleteBillingShares.size(),'Billing account shares are not one');

        Test.startTest();

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, false);

        delete billingPolicy;
        
        Test.stopTest();

        List<Billing_Account__Share> afterDeleteBillingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount.Id AND RowCause = :'Manual'];        
        System.assertEquals(1, afterDeleteBillingShares.size(),'Billing shares count changed despite disabled billing shares toggle');
        System.assertEquals(beforeDeleteBillingShares[0], afterDeleteBillingShares[0], 'Billing share has changed despite disabled billing shares toggle');
    }

    @isTest
    public static void testAfterDeleteBillingPolicyForAccountInheritance(){

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        
        Test.startTest();
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount4();

        InsurancePolicy policy1 = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        InsurancePolicy policy2 = TestDataFactory_AgencyShares.insertPolicy('Policy2', account2.Id);
        
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        Billing_Policy__c billingPolicy1 = TestDataFactory_AgencyShares.insertBillingPolicy(policy1.Id, billingAccount1.Id);

        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        TestDataFactory_AgencyShares.insertBillingParticipant(account1.Id, billingAccount1.Id,insertBillingWrap);
        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap1 = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap1.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap1.regionCode = 'rc'; 
        insertBillingWrap1.clientId = 'clientId2';
        TestDataFactory_AgencyShares.insertBillingParticipant(account2.Id, billingAccount1.Id,insertBillingWrap1);
         
        List<Id> accountIds = new List<Id>{account1.Id, account2.Id};
        List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIds AND RowCause = :'Manual'];

        List<Id> insurancePolicyIds = new List<Id>{policy1.Id, policy2.Id};
        List<InsurancePolicyShare> policyShares = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId IN :insurancePolicyIds AND RowCause = :'Manual'];

        List<Billing_Account__Share> billingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];

        delete billingPolicy1;
        
        Test.stopTest();

        List<Billing_Account__Share> afterDeleteBillingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];
        
        System.assertEquals(2,accountShares.size(),'Account shares are not two');
        System.assertEquals(2,policyShares.size(), 'Insurance Policy Shares are not two');
        System.assertEquals(2,billingShares.size(),'Billing account shares are not two ');
        System.assertEquals(2,afterDeleteBillingShares.size(),'billing account shares are not two after the delete');

    }

    @isTest
    public static void testBeforeAndAfterDeleteBillingPolicyForMultipleBillingPolicies(){

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        
        Test.startTest();
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount4();
        Account account3 = TestDataFactory_AgencyShares.getAccount5();

        InsurancePolicy policy1 = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        InsurancePolicy policy2 = TestDataFactory_AgencyShares.insertPolicy('Policy2', account1.Id);
        InsurancePolicy policy3 = TestDataFactory_AgencyShares.insertPolicy('Policy3', account2.Id);
        InsurancePolicy policy4 = TestDataFactory_AgencyShares.insertPolicy('Policy4', account2.Id);
        
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc111', 'rc', 'billingacc111~rc');

        Billing_Policy__c billingPolicy1 = TestDataFactory_AgencyShares.generateBillingPolicy(policy1.Id, billingAccount1.Id);
        Billing_Policy__c billingPolicy2 = TestDataFactory_AgencyShares.generateBillingPolicy(policy2.Id, billingAccount1.Id);
        Billing_Policy__c billingPolicy3 = TestDataFactory_AgencyShares.generateBillingPolicy(policy3.Id, billingAccount1.Id);
        Billing_Policy__c billingPolicy4 = TestDataFactory_AgencyShares.generateBillingPolicy(policy4.Id, billingAccount1.Id);
        List<Billing_Policy__c> billingPolicies  = new List<Billing_Policy__c>{billingPolicy1,billingPolicy2,billingPolicy3,billingPolicy4};
        insert billingPolicies;

        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc111'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        TestDataFactory_AgencyShares.insertBillingParticipant(account3.Id, billingAccount1.Id,insertBillingWrap);

        List<Id> accountIds = new List<Id>{account1.Id, account2.Id};
        List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIds AND RowCause = :'Manual'];

        List<Id> insurancePolicyIds = new List<Id>{policy1.Id, policy2.Id, policy3.Id, policy4.Id};
        List<InsurancePolicyShare> policyShares = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId IN :insurancePolicyIds AND RowCause = :'Manual'];

        List<Billing_Account__Share> billingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];

        delete billingPolicy1;
        
        Test.stopTest();

        List<Billing_Account__Share> afterDeleteBillingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];
        
        System.assertEquals(2,accountShares.size(),'Account shares are not two');
        System.assertEquals(4,policyShares.size(), 'Insurance Policy Shares are not four');
        System.assertEquals(3,billingShares.size(),'Billing account shares are not three');
        System.assertEquals(3,afterDeleteBillingShares.size(),'billing account shares are not three after the delete');

    }

   
}
