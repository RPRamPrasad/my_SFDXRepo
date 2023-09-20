/**
* @author Team Stark
* @owner Team Stark
* @name UTIL_HouseholdAddMember_Test
* @createDate 06/09/2021
* @description Common class to access various Household Add member related Agent and CCC operations TEST.
* @version 1.0
*/
@isTest(seeAllData=false)
private with sharing class UTIL_HouseholdAddMember_Test {

    private static DAOMock_AccountCreateEditHelper daoMockHelperInstance = new DAOMock_AccountCreateEditHelper();
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    @TestSetup
    static void makeData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,SystemUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        insert objectBasedByPassTrigger;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting; 

    }

    @isTest static void testGetData() {
        CS_Household_Role__c roleCS = new CS_Household_Role__c();
        roleCS.Name = 'Decision Maker';
        roleCS.Sequence_Number__c = 1;
        insert roleCS;
        List<String> roleList = new List<String>();
		Test.startTest();
        	roleList = UTIL_HouseholdAddMember.getHouseholdRoleOptions();
        Test.stopTest();
        System.assertEquals(1, roleList.size(),'Household data');
    }
    
    @isTest static void createACRWithInsertSuccess() {
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
        
        String acrJSONList = '[{"accountId":"'+householdAccount.Id+'","contactId":"'+conRecord.Id+'","roles":"Decision Maker"}]';
        
        Object records;
        Test.startTest();
        	records = UTIL_HouseholdAddMember.createAccountContactRelation(acrJSONList);
        Test.stopTest();
        System.assertEquals(true,records!=null,'failed records list is not null');
        System.assertEquals(new Set<Id>(),records,'failed records set is empty');
    }

    @isTest static void createACRWithUpdateSuccess() {
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
        AccountContactRelation acrRecord = new AccountContactRelation(AccountId=householdAccount.Id,ContactId=conRecord.Id,FinServ__PrimaryGroup__c=true, IsActive=false);
        System.runAs(systemAdmin) {
            insert acrRecord;
        }
        String acrJSONList = '[{"accountId":"'+householdAccount.Id+'","contactId":"'+conRecord.Id+'","roles":"Decision Maker"}]';
        
        Object records;
        Test.startTest();
        	records = UTIL_HouseholdAddMember.createAccountContactRelation(acrJSONList);
        Test.stopTest();
        System.assertEquals(true,records!=null,'failed records list is not null');
        System.assertEquals(new Set<Id>(),records,'failed records set is empty');
    }
    
    @isTest static void createACRFailure() {
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
        AccountContactRelation acrRecord = new AccountContactRelation();
        acrRecord.AccountId = householdAccount.Id;
        acrRecord.ContactId = conRecord.Id;
        acrRecord.Roles = 'Decision Maker';
        String acrJSON = JSON.serialize(acrRecord);
        Object acrException;
        Test.startTest();
        try {
        	acrException = UTIL_HouseholdAddMember.createAccountContactRelation(acrJSON);
        }
        catch (Exception e) {
            System.assertEquals('AccountCreateEditException',e.getTypeName(),'Custom Error thrown'); 
        }
        Test.stopTest();
    }

    @isTest static void testFetchMailingAddressesWithOneMember() {
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
        String expectedMailingAddress = individualAccountOne.BillingCountry+','+ individualAccountOne.BillingStreet+','+individualAccountOne.BillingCity+','+individualAccountOne.BillingState+','+individualAccountOne.BillingPostalCode+','+individualAccountOne.BillingAddressType__c;
        Account actualAccount = UTIL_HouseholdAddMember.fetchMailingAddresses(householdAccount.Id).get(0);
        String actualMailingAddress = actualAccount.BillingCountry+','+ actualAccount.BillingStreet+','+actualAccount.BillingCity+','+actualAccount.BillingState+','+actualAccount.BillingPostalCode+','+actualAccount.BillingAddressType__c;
        Test.startTest();
            System.assertEquals(expectedMailingAddress,actualMailingAddress,'Mailing address mismatches'); 
        Test.stopTest();
    }
    
    @isTest static void testFetchMailingAddressesWithTwoMembers() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Account householdAccount = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account individualAccountOne = new Account(FirstName='Individual',LastName='AccountOne',BillingAddressType__c='US',BillingStreet='1234 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP81LZYX');
        Account individualAccountTwo = new Account(FirstName='Individual',LastName='AccountTwo',BillingAddressType__c='US',BillingStreet='5678 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP81LABC');
        System.runAs(systemAdmin) {
            insert householdAccount;
            insert individualAccountOne;
            insert individualAccountTwo;
        }
        Contact conRecord1 = [SELECT id from Contact where AccountId=:individualAccountOne.Id];
        AccountContactRelation acrRecord1 = new AccountContactRelation(AccountId=householdAccount.Id,ContactId=conRecord1.Id,FinServ__PrimaryGroup__c=true);
        insert acrRecord1;
        Contact conRecord2 = [SELECT id from Contact where AccountId=:individualAccountTwo.Id];
        AccountContactRelation acrRecord2 = new AccountContactRelation(AccountId=householdAccount.Id,ContactId=conRecord2.Id,FinServ__PrimaryGroup__c=true);
        insert acrRecord2;
        List<String> expectedMailingAddress = new List<String>();
        expectedMailingAddress.add(individualAccountOne.BillingCountry+','+ individualAccountOne.BillingStreet+','+individualAccountOne.BillingCity+','+individualAccountOne.BillingState+','+individualAccountOne.BillingPostalCode+','+individualAccountOne.BillingAddressType__c);
        Account actualAccount1 = UTIL_HouseholdAddMember.fetchMailingAddresses(householdAccount.Id).get(0);
        String actualMailingAddress1 = actualAccount1.BillingCountry+','+ actualAccount1.BillingStreet+','+actualAccount1.BillingCity+','+actualAccount1.BillingState+','+actualAccount1.BillingPostalCode+','+actualAccount1.BillingAddressType__c;
        expectedMailingAddress.add(individualAccountTwo.BillingCountry+','+ individualAccountTwo.BillingStreet+','+individualAccountTwo.BillingCity+','+individualAccountTwo.BillingState+','+individualAccountTwo.BillingPostalCode+','+individualAccountTwo.BillingAddressType__c);
        Account actualAccount2 = UTIL_HouseholdAddMember.fetchMailingAddresses(householdAccount.Id).get(1);
        String actualMailingAddress2 = actualAccount2.BillingCountry+','+ actualAccount2.BillingStreet+','+actualAccount2.BillingCity+','+actualAccount2.BillingState+','+actualAccount2.BillingPostalCode+','+actualAccount2.BillingAddressType__c;
        Test.startTest();
            System.Assert(expectedMailingAddress.contains(actualMailingAddress1),'Mailing address mismatchesfor first member');
            System.Assert(expectedMailingAddress.contains(actualMailingAddress2),'Mailing address mismatches for second member'); 
        Test.stopTest();
    }

    @isTest static void testFetchAccountRecord() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        Account individualAccount = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
        System.runAs(systemAdmin) {
            insert individualAccount;
        }
        
        Test.startTest();
            daoMockHelperInstance.acct = new Account(Id=individualAccount.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(individualAccount.Id);
            Account getAccount = UTIL_HouseholdAddMember.fetchAccountRecord(individualAccount.Id);
            System.assert(getAccount==null, 'return null value');
        Test.stopTest();
        Account insertedAccount = [SELECT Id, Name FROM Account WHERE Id = :individualAccount.Id LIMIT 1]; 
        System.assertEquals('FaccountForAgentRole LaccountForAgentRole', insertedAccount.Name,'get the account details');
    }
    
}