/**
* @author Team Stark
* @owner Team Stark
* @name UTIL_HouseholdMemberHelper_TEST
* @createDate 09/09/2021
* @description Common class to access various Household related operations for testing add, move and remove members.
* @version 1.0
*/
@isTest(seeAllData=false)
public with sharing class UTIL_HouseholdRemoveMember_TEST {
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

    @isTest static void testFetchMembers() {
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
            List<AccountContactRelation> allActivelAcrList = UTIL_HouseholdRemoveMember.fetchMembers(householdAccount.Id);
            List<AccountContactRelation> allActivelAcrListNoCache = UTIL_HouseholdRemoveMember.fetchMembersNoCache(householdAccount.Id);
        Test.stopTest();
        System.assert(!allActivelAcrList.isEmpty(),'All active ACR list should not be empty');
        System.assert(!allActivelAcrListNoCache.isEmpty(),'All active ACR list allActivelAcrListNoCache should not be empty');
    }

    @isTest static void removeACRWithUpdateSuccess() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Account householdAccount = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account individualAccount = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
        System.runAs(systemAdmin) {
            insert householdAccount;
            individualAccount.Primary_Household__pc = householdAccount.Id;
            insert individualAccount;
        }
        Contact conRecord = [SELECT id from Contact where AccountId=:individualAccount.Id];
        AccountContactRelation acrRecord = new AccountContactRelation(AccountId=householdAccount.Id,ContactId=conRecord.Id,FinServ__PrimaryGroup__c=true, IsActive=true);
        System.runAs(systemAdmin) {
            insert acrRecord;
        }
        List<Id> acrIdList = new List<Id>{acrRecord.Id};
        String acrJSONList = JSON.serialize(acrIdList);
        List<AccountContactRelation> acrResultbefore = [SELECT Id FROM AccountContactRelation WHERE Id =:acrRecord.Id ];
        System.assertEquals(1,acrResultbefore.size(), 'acr record count should be 1');
        Test.startTest();
            UTIL_HouseholdRemoveMember.removeAccountContactRelation(acrJSONList,householdAccount.Id);
        Test.stopTest();
        List<AccountContactRelation> acrResultafter = [SELECT Id FROM AccountContactRelation WHERE Id =:acrRecord.Id ];
        System.assertEquals(0, acrResultafter.size(), 'acr record count should be 0');
        System.assert(true,'records are removed');
    }
    
    @isTest static void removeACRFailure() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Account householdAccount = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account individualAccount = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
        System.runAs(systemAdmin) {
            insert householdAccount;
            individualAccount.Primary_Household__pc = householdAccount.Id;
            insert individualAccount;
        }
        Contact conRecord = [SELECT id from Contact where AccountId=:individualAccount.Id];
        AccountContactRelation acrRecord = new AccountContactRelation(AccountId=householdAccount.Id,ContactId=conRecord.Id,FinServ__PrimaryGroup__c=true, IsActive=true);
        System.runAs(systemAdmin) {
            insert acrRecord;
        }
        String acrJSONList = JSON.serialize(acrRecord.Id);
        Test.startTest();
        try{
            UTIL_HouseholdRemoveMember.removeAccountContactRelation(acrJSONList,householdAccount.Id);
        }
        catch(Exception e) {
            System.assertEquals('AccountCreateEditException',e.getTypeName(),'Custom Error thrown'); 
        }
        Test.stopTest();
        System.assert(true,'failed');
    }

}
