/**
 * @description This class tests the BillingIPParticipantTriggerHandler class.
 */
@isTest
(seeAllData = false)
public with sharing class BillingIPParticipantTriggerHandlerTest {

    @TestSetup
    static void setupData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('1701A','systemUser','systemUserTest@statefarm.com'); 
        insert systemAdmin;

        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false, systemAdmin);
        insert passTriggerAll;

        CS001_ByPassTriggerAtoF__c objectBasedByPassTriggerAtoF = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemAdmin);
        objectBasedByPassTriggerAtoF.Override_BillingAccountTriggers__c = false;
        insert objectBasedByPassTriggerAtoF;

        CS001_ByPassTriggerGtoZ__c objectBasedByPassTriggerGtoZ = UTIL_ByPassTrigger_TEST.buildBypassTriggerGtoZ(systemAdmin);
        objectBasedByPassTriggerGtoZ.Override_InsurancePolicyTriggers__c = false;
        objectBasedByPassTriggerGtoZ.Override_IPParticipantTriggers__c = false;
        insert objectBasedByPassTriggerGtoZ;

        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdmin.id);            
        insert sysAdminUserIdSetting; 
        
        TestDataFactory_AgencyShares.createDataForSharesTesting();
    }

    @isTest
    private static void validateBillingSharesAreInsertedForParticipantDifferentAgentNewParticipant() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);
        List<Billing_Account__Share> sharesBeforeInsert = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];

        Test.startTest();

        Account account4 = TestDataFactory_AgencyShares.getAccount4();

        // Add a participant to the policy
        TestDataFactory_AgencyShares.insertParticipant(account4.Id, policy.Id);

        Test.stopTest();

        List<Billing_Account__Share> sharesAfterInsert = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(sharesBeforeInsert.size() + 1, sharesAfterInsert.size(), 'A participant was added that has a different agent. The number of shares should have increased by 1');

        List<Id> proxyIds = new List<Id>();
        for (Billing_Account__Share share : sharesAfterInsert) {
            proxyIds.add(share.UserOrGroupId);
        }

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        System.assert(proxyIds.contains(proxy1.Id), 'This list of shares should contain the proxy for account1 since they are the name insured on the policy');
        System.assert(proxyIds.contains(proxy4.Id), 'This list of shares should contain the proxy for account4 since they are a participant on the policy');
    }

    @isTest
    private static void validateBillingSharesAreInsertedForParticipantMultipleAgentsOnNewParticipant() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);
        List<Billing_Account__Share> sharesBeforeInsert = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];

        Test.startTest();

        Account account3 = TestDataFactory_AgencyShares.getAccount3();

        // Add a participant to the policy
        TestDataFactory_AgencyShares.insertParticipant(account3.Id, policy.Id);

        Test.stopTest();

        List<Billing_Account__Share> sharesAfterInsert = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];      
        System.assertEquals(sharesBeforeInsert.size() + 2, sharesAfterInsert.size(), 'A participant was added that has two agents. The number of shares should have increased by 2');

        List<Id> proxyIds = new List<Id>();
        for (Billing_Account__Share share : sharesAfterInsert) {
            proxyIds.add(share.UserOrGroupId);
        }

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxy2 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_TWO_EMAIL];
        User proxy4 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        System.assert(proxyIds.contains(proxy1.Id), 'This list of shares should contain the proxy for account1 since they are the name insured on the policy');
        System.assert(proxyIds.contains(proxy2.Id), 'This list of shares should contain the proxy for account2 since they are a participant on the policy');
        System.assert(proxyIds.contains(proxy4.Id), 'This list of shares should contain the proxy for account4 since they are a participant on the policy');
    }

    @isTest
    private static void validateBillingSharesAreNotInsertedForParticipantWithSameAgent() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);
        List<Billing_Account__Share> sharesBeforeInsert = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];

        Test.startTest();

        Account account2 = TestDataFactory_AgencyShares.getAccount2();

        // Add a participant to the policy
        TestDataFactory_AgencyShares.insertParticipant(account2.Id, policy.Id);

        Test.stopTest();

        List<Billing_Account__Share> sharesAfterInsert = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];      
        System.assertEquals(sharesBeforeInsert.size(), sharesAfterInsert.size(), 'A participant was added on a different account account with the same agent. The number of shares should not have increased');

        List<Id> proxyIds = new List<Id>();
        for (Billing_Account__Share share : sharesAfterInsert) {
            proxyIds.add(share.UserOrGroupId);
        }

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        System.assert(proxyIds.contains(proxy1.Id), 'This list of shares should contain the proxy for account1 and account 2');
    }

    @isTest
    private static void validateBillingSharesNotEnabled() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);
        List<Billing_Account__Share> sharesBeforeInsert = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(1, sharesBeforeInsert.size(), 'One Billing Share should be created');

        Test.startTest();
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, false);
        
        Account account4 = TestDataFactory_AgencyShares.getAccount4();

        // Add a participant to the policy
        InsurancePolicyParticipant participant = TestDataFactory_AgencyShares.insertParticipant(account4.Id, policy.Id);

        // Delete the participant
        delete participant;

        Test.stopTest();

        List<Billing_Account__Share> sharesAfterInsert = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(1, sharesAfterInsert.size(), 'No additional Billing shares should be created');
    }

    @isTest
    public static void testBeforeAndAfterDeleteInsurancePolicyParticipant(){
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        Billing_Account__c billingAccount = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');
        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount.Id);

        // Add a participant to the policy
        Account account4 = TestDataFactory_AgencyShares.getAccount4();
        InsurancePolicyParticipant insurancePolicyParticipant = TestDataFactory_AgencyShares.insertParticipant(account4.Id, policy.Id);

        List<Billing_Account__Share> billingSharesBeforeDelete = [SELECT ParentId, UserOrGroupId, UserOrGroup.email
                                                                FROM Billing_Account__Share
                                                                WHERE ParentId = :billingAccount.Id AND RowCause = 'Manual'];                                                                
        Test.startTest();
        
        // Delete the participant
        delete insurancePolicyParticipant;

        Test.stopTest();

        List<Billing_Account__Share> billingSharesAfterDelete = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount.Id AND RowCause = 'Manual'];

        System.assertEquals(2, billingSharesBeforeDelete.size(),'there should be two Billing shares before the delete');
        System.assertEquals(1, billingSharesAfterDelete.size(),'there should be one Billing share after the delete');
    }

    @isTest
    public static void testBeforeAndAfterDeleteInsurancePolicyParticipantAccountInheritance(){

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount4();
        List<Id> accountIds = new List<Id>{account1.Id, account2.Id};
       
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        List<Id> insurancePolicyIds = new List<Id>{policy.Id};

        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        TestDataFactory_AgencyShares.insertBillingPolicy(policy.Id, billingAccount1.Id);

        TestDataFactory_AgencyShares.InsertBillingParticipantWrapper insertBillingWrap = new TestDataFactory_AgencyShares.InsertBillingParticipantWrapper();
        insertBillingWrap.billingAccountNumber = 'billingacc221'; 
        insertBillingWrap.regionCode = 'rc'; 
        insertBillingWrap.clientId = 'clientId1';
        TestDataFactory_AgencyShares.insertBillingParticipant(account2.Id, billingAccount1.Id, insertBillingWrap);
        
        InsurancePolicyParticipant insurancePolicyParticipant = TestDataFactory_AgencyShares.insertParticipant(account2.Id, policy.Id);

        List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIds AND RowCause = 'Manual'];
        System.assertEquals(2,accountShares.size(),'Account shares are not two');

        List<InsurancePolicyShare> policyShares = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId IN :insurancePolicyIds AND RowCause = 'Manual'];
        System.assertEquals(2,policyShares.size(), 'Insurance Policy Shares is not two');
        
        List<Billing_Account__Share> billingShares = [SELECT ParentId, UserOrGroupId FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(2,billingShares.size(),'Billing account shares are not two');

        Test.startTest();
      
        delete insurancePolicyParticipant;
        
        Test.stopTest();

        List<Billing_Account__Share> afterDeleteBillingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];
        System.assertEquals(2,afterDeleteBillingShares.size(),'billing account shares are not two after the delete');
    }

    @isTest
    public static void testBeforeAndAfterDeleteInsurancePolicyParticipantPolicyInheritance(){

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount4();
       
        InsurancePolicy policy1 = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        InsurancePolicy policy2 = TestDataFactory_AgencyShares.insertPolicy('Policy2', account2.Id);

        Billing_Account__c billingAccount1 = TestDataFactory_AgencyShares.insertBillingAccountNoAgent('billingacc221', 'rc', 'billingacc221~rc');

        TestDataFactory_AgencyShares.insertBillingPolicy(policy1.Id, billingAccount1.Id);
        TestDataFactory_AgencyShares.insertBillingPolicy(policy2.Id, billingAccount1.Id);

        InsurancePolicyParticipant insurancePolicyParticipant = TestDataFactory_AgencyShares.insertParticipant(account2.Id, policy1.Id);

        List<Billing_Account__Share> billingShares = [SELECT ParentId, UserOrGroupId FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = 'Manual'];
        System.assertEquals(2, billingShares.size(),'Billing account shares are not two');

        Test.startTest();
      
        delete insurancePolicyParticipant;
        
        Test.stopTest();

        List<Billing_Account__Share> afterDeleteBillingShares = [SELECT ParentId, UserOrGroupId, UserOrGroup.email FROM Billing_Account__Share WHERE ParentId = :billingAccount1.Id AND RowCause = :'Manual'];
        System.assertEquals(2, afterDeleteBillingShares.size(),'Billing account shares are not two after the delete');
    }

}
