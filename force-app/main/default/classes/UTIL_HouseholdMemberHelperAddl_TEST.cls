/**
* @author Team Stark
* @owner Team Stark
* @name UTIL_HouseholdMemberHelperAddl_TEST
* @createDate 10/27/2021
* @description Common class to access various Household related operations for testing add, move and remove members.
* @version 1.0
*/
@isTest(seeAllData=false)
public with sharing class UTIL_HouseholdMemberHelperAddl_TEST {
    private static User systemAdmin;
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    
    @testsetup
    static void testSetupData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,SystemUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;
        
        insert objectBasedByPassTrigger;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;
  
        TestDataFactory_CustomSetting.createDeleteRecordConfig('System Administrator', 'Account'); 
    }

    //Setup the executing user
    private static User setupRunAsUser() {
        return UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
    }

    @isTest static void testGetAllMembersFromHousehold() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Account householdAccount = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account individualAccountOne = new Account(FirstName='Individual',LastName='AccountOne',BillingAddressType__c='US',BillingStreet='1234 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP81LZYX');
        System.runAs(systemAdmin) {
            insert householdAccount;
            insert individualAccountOne;
        }
        Contact conRecord = [SELECT id from Contact where AccountId=:individualAccountOne.Id];
        AccountContactRelation acrRecord = new AccountContactRelation(AccountId=householdAccount.Id,ContactId=conRecord.Id,FinServ__PrimaryGroup__c=true);
        insert acrRecord;
        Test.startTest();
            List<AccountContactRelation> allActivelAcrList = UTIL_HouseholdMemberHelper_Additional.getAllActiveMembersFromHousehold(householdAccount.Id);
        Test.stopTest();
        System.assert(!allActivelAcrList.isEmpty(),'All active ACR list should not be empty');
    }

    @isTest static void testGetAllActiveMembersFromContactId() {
        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Account householdAccount = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account individualAccountOne = new Account(FirstName='Individual',LastName='AccountOne',BillingAddressType__c='US',BillingStreet='1234 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP81LZYX');
        System.runAs(systemAdmin) {
            insert householdAccount;
            insert individualAccountOne;
        }
        Contact conRecord = [SELECT id from Contact where AccountId=:individualAccountOne.Id];
        AccountContactRelation acrRecord = new AccountContactRelation(AccountId=householdAccount.Id,ContactId=conRecord.Id,FinServ__PrimaryGroup__c=true);
        insert acrRecord;
        Test.startTest();
        	List<AccountContactRelation> allActivelAcrList = UTIL_HouseholdMemberHelper_Additional.getAllActiveMembersFromContactId(String.valueOf(conRecord.Id));
        Test.stopTest();
        System.assert(!allActivelAcrList.isEmpty(),'All active ACR list should not be empty');
    }
}
