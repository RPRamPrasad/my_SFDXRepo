/*
 * @author Team Nsync
 * @description : Tests for UTIL_SyncBillingAccountShares
 * @version 1.0
 * @dateCreated 03/25/2022
 */

@isTest
(seeAllData = false)

public with sharing class UTIL_SyncBillingAccountSharesTest {

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
    private static void resyncBillingSharesTest() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);

        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);
        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        TestDataFactory_AgencyShares.insertBillingParticipant(account1.Id, billingAccount1.Id,insertBillingWrap);

        List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId = :account1.Id AND RowCause = 'Manual'];
        List<InsurancePolicyShare> policyShares = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.id AND RowCause = 'Manual'];
        List<Billing_Account__Share> billingSharesBeforeSync = UTIL_SyncBillingAccountShares.getBillingAccountShares(billingAccount1.Id);
        UTIL_SyncBillingAccountShares.getAllBillingPolicies(billingAccount1.Id);
        UTIL_SyncBillingAccountShares.getAllBillingParticipants(billingAccount1.Id);
        delete billingSharesBeforeSync;

        Test.startTest(); 

        List<Billing_Account__Share> billingSharesAfterSync = UTIL_SyncBillingAccountShares.resyncBillingShares((billingAccount1.Id));


        Test.stopTest();

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];

        List<String> proxyIds1 = new List<String>();
        for (AccountShare share : accountShares) { 
            proxyIds1.add(share.UserOrGroupId);
        }

        List<String> proxyIds2 = new List<String>();
        for (InsurancePolicyShare policyShare : policyShares) { 
            proxyIds2.add(policyShare.UserOrGroupId);
        }

        List<String> proxyIds = new List<String>();
        for (Billing_Account__Share share : billingSharesAfterSync) { 
            proxyIds.add(share.UserOrGroupId);
        }

        System.assert(proxyIds2.contains(proxy1.Id), 'Insurance Policy Share is mapped to the correct Proxy Id');
        System.assert(proxyIds1.contains(proxy1.Id), 'Account Share is mapped to the correct Proxy Id');
        System.assert(proxyIds.contains(proxy1.Id), 'Billing Account Share is mapped to the correct Proxy Id');
        System.assertEquals(1,billingSharesBeforeSync.size(),'One billing account share was created');
        System.assertEquals(1,billingSharesAfterSync.size(),'One billing account share was synced');
        System.assertEquals(billingSharesAfterSync.size(),accountShares.size(), 'billing and account shares match');
        System.assertEquals(billingSharesAfterSync.size(),policyShares.size(), 'billing and policy shares match');


    }

    @isTest
    public static void testGetCurrentBillingShares() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);

        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);
        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        TestDataFactory_AgencyShares.insertBillingParticipant(account1.Id, billingAccount1.Id,insertBillingWrap);
        Test.startTest();
        UTIL_SyncBillingAccountShares.getCurrentBillingSharesForQuery(billingAccount1.Id);
        List<UTIL_SyncBillingAccountShares.ReturnObject> returnObjects = UTIL_SyncBillingAccountShares.getCurrentBillingSharesForQuery(billingAccount1.Id);
        Test.stopTest();
        
        User proxy1 = [SELECT Id, Name FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        
        System.assert(!returnObjects.isEmpty(), 'shares should be returned');
        System.assertEquals(1, returnObjects.size(), 'shares should be 1');
        System.assert(returnObjects.get(0).name.equals(proxy1.Name), 'Shares should match');
    }

    @isTest
    public static void testGetExpectedBillingShares() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        Account account3 = TestDataFactory_AgencyShares.getAccount3();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account3.Id);

        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);
        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        TestDataFactory_AgencyShares.insertBillingParticipant(account3.Id, billingAccount1.Id,insertBillingWrap);
        
        Test.startTest();
        UTIL_SyncBillingAccountShares.getExpectedBillingSharesForQuery(billingAccount1.Id);
        List<UTIL_SyncBillingAccountShares.ReturnObject> returnObjects = UTIL_SyncBillingAccountShares.getExpectedBillingSharesForQuery(billingAccount1.Id);
        Test.stopTest();
        
        User proxy1 = [SELECT Id, Name FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        User proxy2 = [SELECT Id, Name FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_TWO_EMAIL];
        
        System.assert(!returnObjects.isEmpty(), 'shares should be returned');
        System.assert(returnObjects.get(0).name.equals(proxy1.Name), 'Shares should match policy');
        System.assert(returnObjects.get(1).name.equals(proxy2.Name), 'Shares should match customer');
    }

}

