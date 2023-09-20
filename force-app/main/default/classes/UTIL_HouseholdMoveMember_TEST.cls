/**
* @author Team Targaryen
* @owner Team Targaryen
* @name UTIL_HouseholdMoveMember_TEST
* @createDate 09/20/2021
* @description Controller class to access  household move members methods.
* @version 1.0
*/

@isTest(seeAllData=false)
public with sharing class UTIL_HouseholdMoveMember_TEST {
    
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
        List<AccountContactRelation> allActiveAcrList = UTIL_HouseholdMoveMember.fetchHouseholdMembers(householdAccount.Id);
        List<AccountContactRelation> allActiveMembers = UTIL_HouseholdMoveMember.getAllActiveMembersInHousehold(householdAccount.Id);
        Test.stopTest();
        System.assert(!allActiveAcrList.isEmpty(),'All active ACR list should not be empty');
        System.assert(!allActiveMembers.isEmpty(),'All active ACR list should not be empty');
    }
    
    @isTest static void testMoveMemberWithNewHouseholdOnlyOne() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Account hhAcctLeft = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account indAcctOne = new Account(FirstName='FName1',LastName='AccountOne',BillingAddressType__c='US',BillingStreet='1234 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP81LZYX');
        Account indAcctTwo = new Account(FirstName='FName2',LastName='AccountTwo',BillingAddressType__c='US',BillingStreet='1256 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP82LZYX');
        System.runAs(systemAdmin) {
            insert hhAcctLeft;
            indAcctOne.Primary_Household__pc = hhAcctLeft.Id;
            insert indAcctOne;
            indAcctTwo.Primary_Household__pc = hhAcctLeft.Id;
            insert indAcctTwo;
        }
        Contact conRecordOne = [SELECT id from Contact where AccountId =: indAcctOne.Id];
        Contact conRecordTwo = [SELECT id from Contact where AccountId =: indAcctTwo.Id];
        AccountContactRelation acrRecord1 = new AccountContactRelation(AccountId=hhAcctLeft.Id,ContactId=conRecordOne.Id,FinServ__PrimaryGroup__c=true, IsActive=true, FinServ__RollUps__c = 'All');
        AccountContactRelation acrRecord2 = new AccountContactRelation(AccountId=hhAcctLeft.Id,ContactId=conRecordTwo.Id,FinServ__PrimaryGroup__c=true, IsActive=true, FinServ__RollUps__c = 'All');
        List<AccountContactRelation> insAcrRecords = new List<AccountContactRelation>{acrRecord1, acrRecord2};
        insert insAcrRecords;
        String oldHHActId = String.valueOf(hhAcctLeft.Id);
        String newHHActId = null;
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        acrList.add(acrRecord2);
        Test.startTest();
        UTIL_HouseholdMoveMember.moveMembersBetweenHousehold(oldHHActId, newHHActId, acrList);
        Test.stopTest();
        List<AccountContactRelation> newAcrRec = [SELECT Id, AccountId, IsActive FROM AccountContactRelation WHERE ContactId=:conRecordTwo.Id ];
        System.assertEquals(0, newAcrRec.size(),'List should contains only 0 record');
    }

    @isTest static void testMoveMemberWithNewHousehold() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Account hhAcctLeft = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account indAcctOne = new Account(FirstName='FName1',LastName='AccountOne',BillingAddressType__c='US',BillingStreet='1234 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP81LZYX');
        Account indAcctTwo = new Account(FirstName='FName2',LastName='AccountTwo',BillingAddressType__c='US',BillingStreet='1256 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP82LZYX');
        Account indAcctThree = new Account(FirstName='FName3',LastName='AccountThree',BillingAddressType__c='US',BillingStreet='1257 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP83LZYX');
        System.runAs(systemAdmin) {
            insert hhAcctLeft;
            indAcctOne.Primary_Household__pc = hhAcctLeft.Id;
            insert indAcctOne;
            indAcctTwo.Primary_Household__pc = hhAcctLeft.Id;
            insert indAcctTwo;
            indAcctThree.Primary_Household__pc = hhAcctLeft.Id;
            insert indAcctThree;
        }
        Contact conRecordOne = [SELECT id from Contact where AccountId =: indAcctOne.Id];
        Contact conRecordTwo = [SELECT id from Contact where AccountId =: indAcctTwo.Id];
        Contact conRecordThree = [SELECT id from Contact where AccountId =: indAcctThree.Id];
        AccountContactRelation acrRecord1 = new AccountContactRelation(AccountId=hhAcctLeft.Id,ContactId=conRecordOne.Id,FinServ__PrimaryGroup__c=true, IsActive=true, FinServ__RollUps__c = 'All');
        AccountContactRelation acrRecord2 = new AccountContactRelation(AccountId=hhAcctLeft.Id,ContactId=conRecordTwo.Id,FinServ__PrimaryGroup__c=true, IsActive=true, FinServ__RollUps__c = 'All');
        AccountContactRelation acrRecord3 = new AccountContactRelation(AccountId=hhAcctLeft.Id,ContactId=conRecordThree.Id,FinServ__PrimaryGroup__c=true, IsActive=true, FinServ__RollUps__c = 'All');
        List<AccountContactRelation> insAcrRecords = new List<AccountContactRelation>{acrRecord1, acrRecord2,acrRecord3};
        insert insAcrRecords;
        String oldHHActId = String.valueOf(hhAcctLeft.Id);
        String newHHActId = null;
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        acrList.add(acrRecord2);
        acrList.add(acrRecord3);
        Test.startTest();
        UTIL_HouseholdMoveMember.moveMembersBetweenHousehold(oldHHActId, newHHActId, acrList);
        Test.stopTest();
        List<AccountContactRelation> newAcrRec = [SELECT Id, AccountId FROM AccountContactRelation WHERE ContactId=:conRecordTwo.Id ];
        System.assertEquals(1, newAcrRec.size(),'List should contains 1 records');
        System.assert(hhAcctLeft.Id != newAcrRec[0].AccountId,'Move Account should align with new Household Id');
    }

    @isTest static void testMoveMemberFromLeftToRightHousehold() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Account hhAcctLeft = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account hhAcctRight = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account indAcctOne = new Account(FirstName='FName1',LastName='AccountOne',BillingAddressType__c='US',BillingStreet='1234 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP81LZYX');
        Account indAcctTwo = new Account(FirstName='FName2',LastName='AccountTwo',BillingAddressType__c='US',BillingStreet='1256 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP82LZYX');
        Account indAcctThree = new Account(FirstName='FName3',LastName='AccountThree',BillingAddressType__c='US',BillingStreet='1258 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP83LZYX');
        System.runAs(systemAdmin) {
            insert hhAcctLeft;
            indAcctOne.Primary_Household__pc = hhAcctLeft.Id;
            insert indAcctOne;
            indAcctTwo.Primary_Household__pc = hhAcctLeft.Id;
            insert indAcctTwo;
            indAcctThree.Primary_Household__pc = hhAcctLeft.Id;
            insert indAcctThree;
            insert hhAcctRight;
        }
        Contact conRecordOne = [SELECT id from Contact where AccountId =: indAcctOne.Id];
        Contact conRecordTwo = [SELECT id from Contact where AccountId =: indAcctTwo.Id];
        Contact conRecordThree = [SELECT id from Contact where AccountId =: indAcctThree.Id];
        AccountContactRelation acrRecord1 = new AccountContactRelation(AccountId=hhAcctLeft.Id,ContactId=conRecordOne.Id,FinServ__PrimaryGroup__c=true, IsActive=true, FinServ__RollUps__c = 'All');
        AccountContactRelation acrRecord2 = new AccountContactRelation(AccountId=hhAcctLeft.Id,ContactId=conRecordTwo.Id,FinServ__PrimaryGroup__c=true, IsActive=true, FinServ__RollUps__c = 'All');
        AccountContactRelation acrRecord3 = new AccountContactRelation(AccountId=hhAcctLeft.Id,ContactId=conRecordThree.Id,FinServ__PrimaryGroup__c=true, IsActive=true, FinServ__RollUps__c = 'All');
        List<AccountContactRelation> insAcrRecords = new List<AccountContactRelation>{acrRecord1, acrRecord2, acrRecord3};
        insert insAcrRecords;
        String oldHHActId = String.valueOf(hhAcctLeft.Id);
        String newHHActId = String.valueOf(hhAcctRight.Id);
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        acrList.add(acrRecord2);
        acrList.add(acrRecord3);
        Test.startTest();
        UTIL_HouseholdMoveMember.moveMembersBetweenHousehold(oldHHActId, newHHActId, acrList);
        Test.stopTest();
        List<AccountContactRelation> newAcrRec = [SELECT Id, AccountId FROM AccountContactRelation WHERE ContactId=:conRecordTwo.Id ];
        System.assertEquals(1, newAcrRec.size(),'List should contains 1 records');
        System.assertEquals(hhAcctRight.Id,newAcrRec[0].AccountId,'Move Account should align with new Right Household Id');
    }


}