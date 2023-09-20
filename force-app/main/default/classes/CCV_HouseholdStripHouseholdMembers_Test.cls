/**
* @description This class is used to cover apex CCV_HouseholdStripHouseholdMembers
* @Date: 5/3/2023
* @author: Team Atlas
*/

@isTest(SeeAllData=false)
public with sharing class CCV_HouseholdStripHouseholdMembers_Test {
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    
    @TestSetup
    static void makeTestData(){
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
    private static void testFetchHouseholdMembersDetailsThreeOrMore() {
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
        CCV_HouseholdMembersWrapper wrapper = new CCV_HouseholdMembersWrapper();
        Test.startTest();
        wrapper = CCV_HouseholdStripHouseholdMembers.fetchHouseholdMembersDetails(String.valueOf(hhRecord.Id));
        Test.stopTest();
        System.assertEquals(true, wrapper.members != null, 'group members should not be null');
        System.assertEquals(3, Integer.valueOf(wrapper.count), 'count should be 3');
    }

    @isTest
    private static void testFetchHouseholdMembersDetailsError() {
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
        CCV_HouseholdMembersWrapper wrapper = new CCV_HouseholdMembersWrapper();
        Test.startTest();
        try {
            wrapper = CCV_HouseholdStripHouseholdMembers.fetchHouseholdMembersDetails('Account');
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Exception thrown');
        }
        Test.stopTest();
        System.assertEquals(false, wrapper.members != null, 'group members should not be null');   
    }
}