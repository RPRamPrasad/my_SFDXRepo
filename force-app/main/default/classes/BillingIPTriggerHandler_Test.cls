/*
 * @author NSYNC
 * @description : Tests for BillingIPTriggerHandler
 * @version 1.0
 * @dateCreated 01/25/2022
 */
@isTest
(seeAllData = false)
public with sharing class BillingIPTriggerHandler_Test {

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
    private static void validateBillingSharesAreUpdatedForNewNameInsured() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);
        List<Billing_Account__Share> sharesBeforeUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];

        Test.startTest();     

        // Change the named insured on the policy
        Account account4 = TestDataFactory_AgencyShares.getAccount4();
        policy.NameInsuredId = account4.Id;
        update policy;

        Test.stopTest();

        List<Billing_Account__Share> sharesAfterUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(sharesBeforeUpdate.size(), sharesAfterUpdate.size(), 'The number of shares should remain the same with only a name insured change');

        List<Id> proxyIds = new List<Id>();
        for (Billing_Account__Share share : sharesAfterUpdate) {
            proxyIds.add(share.UserOrGroupId);
        }

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        System.assertEquals(false, proxyIds.contains(proxy1.Id), 'This list of shares should not contain the proxy for account1 since they are no longer on the policy');
        System.assert(proxyIds.contains(proxy4.Id), 'This list of shares should contain the proxy for account4 since they are the named insured on the policy');
    }

    @isTest
    public static void testUpdateInsurancePolicyAccountInheritance(){
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account4 = TestDataFactory_AgencyShares.getAccount4();
        List<Id> accountIds = new List<Id>{account1.Id, account4.Id};

        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);

        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        TestDataFactory_AgencyShares.insertBillingParticipant(account1.Id, billingAccount1.Id, insertBillingWrap);
        
        List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIds AND RowCause = 'Manual'];
        System.assertEquals(2, accountShares.size(), 'Account shares are not two');
       
        List<Billing_Account__Share> sharesBeforeUpdate = [SELECT ParentId, UserOrGroupId FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(1, sharesBeforeUpdate.size(), 'Billing account shares are not one');
        
        Test.startTest();

        // Change the named insured on the policy
        policy.NameInsuredId = account4.Id;
        update policy;
        
        Test.stopTest();

        List<Billing_Account__Share> sharesAfterUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(sharesBeforeUpdate.size() + 1, sharesAfterUpdate.size(), 'The number of shares should increase by one with this named insured change');

        List<Id> proxyIds = new List<Id>();
        for (Billing_Account__Share share : sharesAfterUpdate) {
            proxyIds.add(share.UserOrGroupId);
        }

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        System.assert(proxyIds.contains(proxy1.Id), 'This list of shares should contain the proxy for account1 through the billing participant relationship');
        System.assert(proxyIds.contains(proxy4.Id), 'This list of shares should contain the proxy for account4 since they are the named insured on the policy');
    }

    @isTest
    private static void validateBillingSharesNotEnabled() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);
        List<Billing_Account__Share> sharesBeforeUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(1, sharesBeforeUpdate.size(), 'One Billing Share should be created');

        Test.startTest();
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, false);

        // Change the named insured on the policy
        Account account4 = TestDataFactory_AgencyShares.getAccount4();
        policy.NameInsuredId = account4.Id;
        update policy;

        Test.stopTest();

        List<Billing_Account__Share> sharesAfterUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(sharesBeforeUpdate.size(), sharesAfterUpdate.size(), 'The number of shares should have not changed as billing share management was disabled');
        
        List<Id> proxyIds = new List<Id>();
        for (Billing_Account__Share share : sharesAfterUpdate) {
            proxyIds.add(share.UserOrGroupId);
        }

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        System.assert(proxyIds.contains(proxy1.Id), 'This list of shares should contain the proxy for account1 since share management was disabled');
        System.assertEquals(false, proxyIds.contains(proxy4.Id), 'This list of shares should not contain the proxy for account4 since share management was disabled');
    }

    @isTest
    private static void validateBillingSharesAreUpdatedWhenPolicyIsDeleted() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);
        List<Billing_Account__Share> sharesBeforeDelete = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(1, sharesBeforeDelete.size(), 'The number of billing shares should be one');

        Test.startTest();     

        delete policy;

        Test.stopTest();

        List<Billing_Account__Share> sharesAfterDelete = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(0, sharesAfterDelete.size(), 'The number of billing shares should change to zero');
    }

}
