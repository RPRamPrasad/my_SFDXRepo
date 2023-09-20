/*
 * @author Team Nsync
 * @description : Tests for BillingParticipantTriggerHandler
 * @version 1.0
 * @dateCreated 12/09/2021
 */

@isTest
(seeAllData = false)
public with sharing class BillingParticipantTriggerHandler_Test {

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
    private static void testBillingSharesCreatedFromAccountShares() {

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        Test.startTest(); 
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();

        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        TestDataFactory_AgencyShares.insertBillingParticipant(account1.Id, billingAccount1.Id, insertBillingWrap);

        List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId = :account1.Id AND RowCause = 'Manual'];
     
        List<Billing_Account__Share> billingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        
        Test.stopTest();

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];

        List<String> proxyIds1 = new List<String>();
        for (AccountShare share : accountShares) { 
            proxyIds1.add(share.UserOrGroupId);
        }

        List<String> proxyIds = new List<String>();
        for (Billing_Account__Share share : billingShares) { 
            proxyIds.add(share.UserOrGroupId);
        }

        System.assert(proxyIds1.contains(proxy1.Id), 'Account Share is not mapped to the correct Proxy Id');
        System.assert(proxyIds.contains(proxy1.Id), 'Billing Account Share is not mapped to the correct Proxy Id');
        System.assertEquals(1,billingShares.size(),'One billing account share was not created');
        System.assertEquals(billingShares.size(),accountShares.size(), 'billing and account shares do not match');

    }

    @isTest
    private static void testBillingSharesCreatedFromAccountSharesWithMultipleBillingParticipants() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        Test.startTest(); 
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount4();
        List<Id> accountIds = new List<Id>{account1.Id,account2.Id};

        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper generateBillingWrap = new TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper();
        generateBillingWrap.billingAccountNumber = 'billingacc221'; 
        generateBillingWrap.regionCode = 'rc'; 
        generateBillingWrap.clientId = 'clientId1';
        Billing_Participant__c billingParticipant1 = TestDataFactory_AgencyShares.generateBillingParticipant(account1.Id, billingAccount1.Id,generateBillingWrap);
        TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper generateBillingWrap1 = new TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper();
        generateBillingWrap1.billingAccountNumber = 'billingacc221'; 
        generateBillingWrap1.regionCode = 'rc'; 
        generateBillingWrap1.clientId = 'clientId2';
        Billing_Participant__c billingParticipant2 = TestDataFactory_AgencyShares.generateBillingParticipant(account1.Id, billingAccount1.Id,generateBillingWrap1);
        TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper generateBillingWrap2 = new TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper();
        generateBillingWrap2.billingAccountNumber = 'billingacc221'; 
        generateBillingWrap2.regionCode = 'rc'; 
        generateBillingWrap2.clientId = 'clientId3';
        Billing_Participant__c billingParticipant3 = TestDataFactory_AgencyShares.generateBillingParticipant(account2.Id, billingAccount1.Id,generateBillingWrap2);
        List<Billing_Participant__c> billingParticipants  = new List<Billing_Participant__c>{billingParticipant1,billingParticipant2,billingParticipant3};
        insert billingParticipants;

        List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIds AND RowCause = 'Manual'];
     
        List<Billing_Account__Share> billingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        
        Test.stopTest();
        System.assertEquals(2,accountShares.size(), 'Account Shares are not two');
        System.assertEquals(2,billingShares.size(),'Two billing account shares were not created');
    }

    @isTest
    private static void testBillingSharesNotCreatedForToggleDisabled() {

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, false);
        Test.startTest(); 
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        TestDataFactory_AgencyShares.insertBillingParticipant(account1.Id, billingAccount1.Id,insertBillingWrap);

        Test.stopTest();

        List<Billing_Account__Share> billingSharesAfter = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];

         System.assert(billingSharesAfter.isEmpty(), 'Billing shares should be disabled');

    }

    @isTest
    public static void testBeforeAndAfterDeleteBillingParticipantForAccountInheritance(){

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount4();
        
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        Billing_Participant__c billingParticipant1 = TestDataFactory_AgencyShares.insertBillingParticipant(account1.Id, billingAccount1.Id,insertBillingWrap);
        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap1 = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap1.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap1.regionCode = 'rc'; 
        insertBillingWrap1.clientId = 'clientId2';
        TestDataFactory_AgencyShares.insertBillingParticipant(account2.Id, billingAccount1.Id,insertBillingWrap1);
         
        List<Id> accountIds = new List<Id>{account1.Id, account2.Id};
        List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIds AND RowCause = :'Manual'];

        List<Billing_Account__Share> billingSharesBeforeDelete = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];

        Test.startTest();

        delete billingParticipant1;

        Test.stopTest();

        List<Billing_Account__Share> billingSharesAfterDelete = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];
        
        System.assertEquals(2,accountShares.size(),'there should be two customer account shares');
        System.assertEquals(2,billingSharesBeforeDelete.size(),'there should be two Billing account shares before delete ');
        System.assertEquals(1,billingSharesAfterDelete.size(),'there should be one billing account share after the delete');

    }

    @isTest
    public static void testBeforeAndAfterDeleteBillingParticipantForSameAgent(){

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper generateBillingWrap = new TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper();
        generateBillingWrap.billingAccountNumber = 'billingacc221'; 
        generateBillingWrap.regionCode = 'rc'; 
        generateBillingWrap.clientId = 'clientId1';
        Billing_Participant__c billingParticipant1 = TestDataFactory_AgencyShares.generateBillingParticipant(account1.Id, billingAccount1.Id,generateBillingWrap);
        TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper generateBillingWrap1 = new TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper();
        generateBillingWrap1.billingAccountNumber = 'billingacc221'; 
        generateBillingWrap1.regionCode = 'rc'; 
        generateBillingWrap1.clientId = 'clientId2';
        Billing_Participant__c billingParticipant2 = TestDataFactory_AgencyShares.generateBillingParticipant(account1.Id, billingAccount1.Id,generateBillingWrap1);
        List<Billing_Participant__c> billingParticipants  = new List<Billing_Participant__c>{billingParticipant1,billingParticipant2};
        insert billingParticipants;
        
        List<Billing_Account__Share> billingSharesBeforeDelete = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];

        Test.startTest();

        delete billingParticipant1;

        Test.stopTest();

        List<Billing_Account__Share> billingSharesAfterDelete = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];
        
        System.assertEquals(1,billingSharesBeforeDelete.size(),'there should be one Billing account shares before delete as the participants have the same agent ');
        System.assertEquals(1,billingSharesAfterDelete.size(),'there should be one billing account share after the delete as the participants have the same agent');

    }

    @isTest
    public static void testBeforeAndAfterDeleteBillingParticipantForPolicyInheritance(){

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount4();
       
        InsurancePolicy policy1 = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);

        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        Billing_Participant__c billingParticipant1 = TestDataFactory_AgencyShares.insertBillingParticipant(account1.Id, billingAccount1.Id,insertBillingWrap);
        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap1 = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap1.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap1.regionCode = 'rc'; 
        insertBillingWrap1.clientId = 'clientId2';
        TestDataFactory_AgencyShares.insertBillingParticipant(account2.Id, billingAccount1.Id,insertBillingWrap1);

        TestDataFactory_AgencyShares.insertBillingPolicy(policy1.Id, billingAccount1.Id);
        
        List<Billing_Account__Share> billingSharesBeforeDelete = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        
        Test.startTest();

        delete billingParticipant1;
        
        Test.stopTest();

        List<Billing_Account__Share> billingSharesAfterDelete = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];
        
        System.assertEquals(2,billingSharesBeforeDelete.size(),'there ahould be two billing account shares before delete');
        System.assertEquals(2,billingSharesAfterDelete.size(),'there ahould be two billing account shares after delete since billing participant1 and billing policy have the same agent');

    }

    @isTest
    private static void validateBillingSharesAreUpdatedForNewAccountAssociation() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
       
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        Billing_Participant__c billingParticipant = TestDataFactory_AgencyShares.insertBillingParticipant(account1.Id, billingAccount1.Id,insertBillingWrap);
        List<Billing_Account__Share> sharesBeforeUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];
          
        // Change the associated account on the billing participant
        Account account4 = TestDataFactory_AgencyShares.getAccount4();
        billingParticipant.ParticipantAccountId__c = account4.Id;
        
        Test.startTest();
        update billingParticipant;
        Test.stopTest();

        List<Billing_Account__Share> sharesAfterUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(sharesBeforeUpdate.size(), sharesAfterUpdate.size(), 'The number of shares should remain the same with only an account association change');

        List<Id> proxyIds = new List<Id>();
        for (Billing_Account__Share share : sharesAfterUpdate) {
            proxyIds.add(share.UserOrGroupId);
        }

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        System.assertEquals(false, proxyIds.contains(proxy1.Id), 'This list of shares should not contain proxy1 for account1 since its no longer on the participant');
        System.assert(proxyIds.contains(proxy4.Id), 'This list of shares should contain proxy4 for account4 since its on the participant after update');
    }

    @isTest
    private static void validateBillingSharesAreUpdatedForNewAccountAssociationforTwoParticipants() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper generateBillingWrap = new TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper();
        generateBillingWrap.billingAccountNumber = 'billingacc221'; 
        generateBillingWrap.regionCode = 'rc'; 
        generateBillingWrap.clientId = 'clientId1';
        Billing_Participant__c billingParticipant1 = TestDataFactory_AgencyShares.generateBillingParticipant(account1.Id, billingAccount1.Id,generateBillingWrap);
        TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper generateBillingWrap1 = new TestDataFactory_AgencyShares.GenerateBillingParticipantWrapper();
        generateBillingWrap1.billingAccountNumber = 'billingacc221'; 
        generateBillingWrap1.regionCode = 'rc'; 
        generateBillingWrap1.clientId = 'clientId2';
        Billing_Participant__c billingParticipant2 = TestDataFactory_AgencyShares.generateBillingParticipant(account1.Id, billingAccount1.Id,generateBillingWrap1);
        List<Billing_Participant__c> billingParticipants  = new List<Billing_Participant__c>{billingParticipant1,billingParticipant2};
        insert billingParticipants;
        List<Billing_Account__Share> sharesBeforeUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];
        System.assertEquals(1,sharesBeforeUpdate.size(),'there should be one billing account shares before update');

        // Change the associated account on the billing participant1
        Account account4 = TestDataFactory_AgencyShares.getAccount4();
        billingParticipant1.ParticipantAccountId__c = account4.Id;

        Test.startTest();
        update billingParticipant1;
        Test.stopTest();

        List<Billing_Account__Share> sharesAfterUpdate = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(2,sharesAfterUpdate.size(),'there should be two billing shares after update');

        List<Id> proxyIds = new List<Id>();
        for (Billing_Account__Share share : sharesAfterUpdate) {
            proxyIds.add(share.UserOrGroupId);
        }

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        System.assert(proxyIds.contains(proxy1.Id), 'This list of shares should contain proxy1 for account1 since its on participant2');
        System.assert(proxyIds.contains(proxy4.Id), 'This list of shares should contain the proxy4 for account4 since its on participant1');
    }
}
