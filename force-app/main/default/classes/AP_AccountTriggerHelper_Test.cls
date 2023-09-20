/**
 * @Author: Targaryen
 * @description : Account Trigger helper class for updating Org Account Leads 
 * Accounts inserted to always be assigned/owned by StateFarm System User.
 * Account owners cannot be updated to any other user than StateFarm System user.
 */

@isTest
(seeAllData = false)
public with sharing class AP_AccountTriggerHelper_Test {
   /**
    * @description test account after updates  
    * Method name   handleAccountsAfterUpdateTest
    */
    @isTest
    public static void handleAccountsAfterUpdateTest() {
        
        AP_AccountTrigger accountTrigger = new AP_AccountTrigger();
        BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();

        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        

        List<Account> newAccounts = new List<Account>();
        Map<Id,Account> oldAccounts = new Map<Id,Account>();
        userStepDefinitions.givenAnUserSalesHierarchy();
        userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '7', true);
        
        
        Campaign campaign;
        CampaignMember campaignMember;
        
        Account account = TestDataFactory_Account.createIndividualCustomer('Alex Cat');
        TestDataFactory_Account.byPassAccountBeforeTrigger();
        account = TestDataFactory_Account.insertAccount(account);
   
        
        campaign = TestDataFactory_Campaign.generateCampaign();
        campaign.OwnerId = userStepDefinitions.SalesUserHierarchy.AgentOffice.Id;
        campaign = TestDataFactory_Campaign.insertCampaign(campaign);
        
        Contact contact = [Select id from Contact where accountId = :account.id];

        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;

        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = CS001_ByPassTriggerAtoF__c.getInstance();
        objectBasedByPassTrigger.Override_CampaignMemberBeforeInsert__c = true;
        update objectBasedByPassTrigger;

        campaignMember = TestDataFactory_CampaignMember.generateCampaignMember(campaign,contact);
        campaignMember = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember);
        campaignMember = [select Id,Status__c from CampaignMember where Id=:campaignMember.Id];
        List<Account> accounts = [SELECT id, personcontactid,personhomephone,personmobilephone from account where id= :account.id];
        accounts.get(0).PersonHomePhone = '1234567890';
        accounts.get(0).PersonMobilePhone = '1234567890';
        newAccounts.add(accounts.get(0));
        update newAccounts;
        Account priorAccount = new Account();
        priorAccount.Id =account.id;
        oldAccounts.put(priorAccount.Id, priorAccount);
        accountTrigger.handleAccountsAfterUpdate(newAccounts,oldAccounts);

         
        campaignMember = [select Id,Status__c from CampaignMember where Id=:campaignMember.Id];
        system.assertEquals('Not Contacted',campaignMember.Status__c,'CampaignMember status is not matched');
    }
    /**
     * @description test account update for Leads 
     */ 
     @isTest
    public static void testAccountUpdateForLead() {
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;

        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,systemUser);
        insert passTriggerAll;

        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AccountBeforeInsert__c = false;
        insert objectBasedByPassTrigger;

        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;

        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        Account account  = new Account(
            firstname ='FNAMEHOLDINGCODE', lastname='LNAMEHOLDINGCODE', ClientIdentifier__c = 'LEAD1NGC0D3',
            IsSourcedFromLead__c = true, 
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME).getRecordTypeId()
        );
        insert account;

        Test.startTest();
        Account savedAccount = [select id, Edit_In_VFP__c, firstName, ownerId, ClientIdentifier__c, IsSourcedFromLead__c from Account where id = :account.id];     
        system.assertEquals(systemUser.Id,savedAccount.ownerId,'Accounts can only be owned by State Farm User');
        system.assert(String.isNotBlank(savedAccount.firstName), 'Organization Account First Name is blank');

        savedAccount.Edit_In_VFP__c = true;
        savedAccount.IsSourcedFromLead__c = true;
        update savedAccount;
        Account accountAfterUpdate = [select id, firstName, ownerId, ClientIdentifier__c, IsSourcedFromLead__c from Account where id = :account.id];
        system.assert(String.isBlank(accountAfterUpdate.firstName), 'Organization Account First Name is not blank');
    }
}
