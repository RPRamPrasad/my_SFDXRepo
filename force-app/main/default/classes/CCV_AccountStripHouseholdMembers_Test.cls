/**
 * @description This class is used to cover apex class CCV_AccountStripHouseholdMembers
 * @Date: 12/23/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AccountStripHouseholdMembers_Test {
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';

    @testsetup
    static void testSetupData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;

        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(
            false,
            SystemUser
        );
        insert passTriggerAll;

        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(
            systemUser
        );
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;

        insert objectBasedByPassTrigger;

        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(
            systemUser.id
        );
        insert sysAdminUserIdSetting;

        TestDataFactory_CustomSetting.createDeleteRecordConfig('System Administrator', 'Account');
    }

    @isTest
    private static void testfetchHouseholdMembersDetailsOneOnly() {
        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin(
            'alias',
            'systemAdmin',
            'systemAdminTest@statefarm.com'
        );
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
            .get(HOUSEHOLD_RECORD_TYPE)
            .getRecordTypeId();
        Account hhRecord = new Account(
            Name = 'Household',
            recordTypeId = householdRecordTypeId,
            AllowHousehold__c = true
        );
        Account individualAccountOne = new Account(
            FirstName = 'Individual',
            LastName = 'AccountOne',
            BillingAddressType__c = 'US',
            BillingStreet = '1234 Main St',
            BillingCity = 'Bloomington',
            BillingState = 'IL',
            BillingPostalCode = '61704',
            BillingCountry = 'UNITED STATES',
            ClientIdentifier__c = 'SFFSP81LZYX'
        );
        System.runAs(systemAdmin) {
            insert hhRecord;
            insert individualAccountOne;
        }
        Contact conRecord = [SELECT id FROM Contact WHERE AccountId = :individualAccountOne.Id];
        AccountContactRelation acrRecord = new AccountContactRelation(
            AccountId = hhRecord.Id,
            ContactId = conRecord.Id,
            FinServ__PrimaryGroup__c = true
        );
        insert acrRecord;
        CCV_AccountStripHouseholdMembers.HouseholdMembersWrapper wrapper = new CCV_AccountStripHouseholdMembers.HouseholdMembersWrapper();
        Test.startTest();
        wrapper = CCV_AccountStripHouseholdMembers.fetchHouseholdMembersDetails(
            String.valueOf(hhRecord.Id),
            String.valueOf(individualAccountOne.Id)
        );
        Test.stopTest();
        System.assertEquals(true, wrapper.members != null, 'group members should not be null');
        System.assertEquals(1, Integer.valueOf(wrapper.count), 'count should be 1');
    }

    @isTest
    private static void testfetchHouseholdMembersDetailsTwo() {
        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin(
            'alias',
            'systemAdmin',
            'systemAdminTest@statefarm.com'
        );
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
            .get(HOUSEHOLD_RECORD_TYPE)
            .getRecordTypeId();
        Account hhRecord = new Account(
            Name = 'Household',
            recordTypeId = householdRecordTypeId,
            AllowHousehold__c = true
        );
        Account individualAccountOne = new Account(
            FirstName = 'Individual',
            LastName = 'AccountOne',
            BillingAddressType__c = 'US',
            BillingStreet = '1234 Main St',
            BillingCity = 'Bloomington',
            BillingState = 'IL',
            BillingPostalCode = '61704',
            BillingCountry = 'UNITED STATES',
            ClientIdentifier__c = 'SFFSP81LZYX'
        );
        Account individualAccountTwo = new Account(
            FirstName = 'Individual',
            LastName = 'AccountTwo',
            BillingAddressType__c = 'US',
            BillingStreet = '1234 Main St',
            BillingCity = 'Bloomington',
            BillingState = 'IL',
            BillingPostalCode = '61704',
            BillingCountry = 'UNITED STATES',
            ClientIdentifier__c = 'SFFSP82LZYX'
        );
        List<Account> lstAccounts = new List<Account>{ individualAccountOne, individualAccountTwo };
        System.runAs(systemAdmin) {
            insert hhRecord;
            insert lstAccounts;
        }
        List<Contact> lstConRecord = [SELECT id FROM Contact WHERE AccountId IN :lstAccounts];
        AccountContactRelation acrRecord1 = new AccountContactRelation(
            AccountId = hhRecord.Id,
            ContactId = lstConRecord[0].Id,
            FinServ__PrimaryGroup__c = true
        );
        AccountContactRelation acrRecord2 = new AccountContactRelation(
            AccountId = hhRecord.Id,
            ContactId = lstConRecord[1].Id,
            FinServ__PrimaryGroup__c = true
        );
        List<AccountContactRelation> lstAcr = new List<AccountContactRelation>{ acrRecord1, acrRecord2 };
        insert lstAcr;
        Relationship__c oneWayRelation = new Relationship__c(
            AccountTwo__c = individualAccountTwo.Id,
            RelationshipType__c = 'Spouse',
            AccountOne__c = individualAccountOne.Id,
            RelationshipIdentifier__c = 'SFFSP81LZYX~SFFSP82LZYX'
        );
        Relationship__c twoWayRelation = new Relationship__c(
            AccountTwo__c = individualAccountOne.Id,
            RelationshipType__c = 'Spouse',
            AccountOne__c = individualAccountTwo.Id,
            RelationshipIdentifier__c = 'SFFSP82LZYX~SFFSP81LZYX'
        );
        List<Relationship__c> relationshipList = new List<Relationship__c>{ oneWayRelation, twoWayRelation };
        insert relationshipList;
        CCV_AccountStripHouseholdMembers.HouseholdMembersWrapper wrapper = new CCV_AccountStripHouseholdMembers.HouseholdMembersWrapper();
        Test.startTest();
        wrapper = CCV_AccountStripHouseholdMembers.fetchHouseholdMembersDetails(
            String.valueOf(hhRecord.Id),
            String.valueOf(individualAccountOne.Id)
        );
        Test.stopTest();
        System.assertEquals(true, wrapper.members != null, 'group members should not be null');
        System.assertEquals(2, Integer.valueOf(wrapper.count), 'count should be 2');
    }

    @isTest
    private static void testfetchHouseholdMembersDetailsError() {
        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin(
            'alias',
            'systemAdmin',
            'systemAdminTest@statefarm.com'
        );
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
            .get(HOUSEHOLD_RECORD_TYPE)
            .getRecordTypeId();
        Account hhRecord = new Account(
            Name = 'Household',
            recordTypeId = householdRecordTypeId,
            AllowHousehold__c = true
        );
        Account individualAccountOne = new Account(
            FirstName = 'Individual',
            LastName = 'AccountOne',
            BillingAddressType__c = 'US',
            BillingStreet = '1234 Main St',
            BillingCity = 'Bloomington',
            BillingState = 'IL',
            BillingPostalCode = '61704',
            BillingCountry = 'UNITED STATES',
            ClientIdentifier__c = 'SFFSP81LZYX'
        );
        System.runAs(systemAdmin) {
            insert hhRecord;
            insert individualAccountOne;
        }
        Contact conRecord = [SELECT id FROM Contact WHERE AccountId = :individualAccountOne.Id];
        AccountContactRelation acrRecord = new AccountContactRelation(
            AccountId = hhRecord.Id,
            ContactId = conRecord.Id,
            FinServ__PrimaryGroup__c = true
        );
        insert acrRecord;
        CCV_AccountStripHouseholdMembers.HouseholdMembersWrapper wrapper = new CCV_AccountStripHouseholdMembers.HouseholdMembersWrapper();
        Test.startTest();
        try {
            wrapper = CCV_AccountStripHouseholdMembers.fetchHouseholdMembersDetails(
                null,
                String.valueOf(individualAccountOne.Id)
            );
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Exception thrown');
        }
        Test.stopTest();
        System.assertEquals(false, wrapper.members != null, 'group members should not be null');
    }

    @isTest
    private static void testfetchHouseholdMembersDetailsThreeOrMore() {
        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin(
            'alias',
            'systemAdmin',
            'systemAdminTest@statefarm.com'
        );
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
            .get(HOUSEHOLD_RECORD_TYPE)
            .getRecordTypeId();
        Account hhRecord = new Account(
            Name = 'Household',
            recordTypeId = householdRecordTypeId,
            AllowHousehold__c = true
        );
        Account individualAccountOne = new Account(
            FirstName = 'Individual',
            LastName = 'AccountOne',
            BillingAddressType__c = 'US',
            BillingStreet = '1234 Main St',
            BillingCity = 'Bloomington',
            BillingState = 'IL',
            BillingPostalCode = '61704',
            BillingCountry = 'UNITED STATES',
            ClientIdentifier__c = 'SFFSP81LZYX'
        );
        Account individualAccountTwo = new Account(
            FirstName = 'Individual',
            LastName = 'AccountTwo',
            BillingAddressType__c = 'US',
            BillingStreet = '1234 Main St',
            BillingCity = 'Bloomington',
            BillingState = 'IL',
            BillingPostalCode = '61704',
            BillingCountry = 'UNITED STATES',
            ClientIdentifier__c = 'SFFSP82LZYX'
        );
        Account individualAccountThree = new Account(
            FirstName = 'Individual',
            LastName = 'AccountThree',
            BillingAddressType__c = 'US',
            BillingStreet = '1234 Main St',
            BillingCity = 'Bloomington',
            BillingState = 'IL',
            BillingPostalCode = '61704',
            BillingCountry = 'UNITED STATES',
            ClientIdentifier__c = 'SFFSP83LZYX'
        );
        List<Account> lstAccounts = new List<Account>{
            individualAccountOne,
            individualAccountTwo,
            individualAccountThree
        };
        System.runAs(systemAdmin) {
            insert hhRecord;
            insert lstAccounts;
        }
        List<Contact> lstConRecord = [SELECT id FROM Contact WHERE AccountId IN :lstAccounts];
        AccountContactRelation acrRecord1 = new AccountContactRelation(
            AccountId = hhRecord.Id,
            ContactId = lstConRecord[0].Id,
            FinServ__PrimaryGroup__c = true
        );
        AccountContactRelation acrRecord2 = new AccountContactRelation(
            AccountId = hhRecord.Id,
            ContactId = lstConRecord[1].Id,
            FinServ__PrimaryGroup__c = true
        );
        AccountContactRelation acrRecord3 = new AccountContactRelation(
            AccountId = hhRecord.Id,
            ContactId = lstConRecord[2].Id,
            FinServ__PrimaryGroup__c = true
        );
        List<AccountContactRelation> lstAcr = new List<AccountContactRelation>{ acrRecord1, acrRecord2, acrRecord3 };
        insert lstAcr;
        CCV_AccountStripHouseholdMembers.HouseholdMembersWrapper wrapper = new CCV_AccountStripHouseholdMembers.HouseholdMembersWrapper();
        Test.startTest();
        wrapper = CCV_AccountStripHouseholdMembers.fetchHouseholdMembersDetails(
            String.valueOf(hhRecord.Id),
            String.valueOf(individualAccountThree.Id)
        );
        Test.stopTest();
        System.assertEquals(true, wrapper.members != null, 'group members should not be null');
        System.assertEquals(3, Integer.valueOf(wrapper.count), 'count should be 3');
    }
}
