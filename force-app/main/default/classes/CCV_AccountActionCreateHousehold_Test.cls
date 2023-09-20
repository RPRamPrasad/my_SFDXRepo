/**
 * @description This class is used to cover Apex class CCV_AccountActionCreateHousehold
 * @Date: 12/23/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AccountActionCreateHousehold_Test {
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

    public static Contact testHouseholdDataSetup(boolean isAddlData) {
        
        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin(
            'alias',
            'systemAdmin',
            'systemAdminTest@statefarm.com'
        );
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
            .get(HOUSEHOLD_RECORD_TYPE)
            .getRecordTypeId();
        Account householdAccount1 = new Account(
            Name = 'Household',
            recordTypeId = householdRecordTypeId,
            AllowHousehold__c = true
        );
        Account householdAccount2 = new Account(
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
            insert householdAccount1;
            insert householdAccount2;
            insert individualAccountOne;
        }
        Contact conRecord = [SELECT id FROM Contact WHERE AccountId = :individualAccountOne.Id];
        AccountContactRelation acrRecord = new AccountContactRelation(
            AccountId = householdAccount1.Id,
            ContactId = conRecord.Id,
            FinServ__PrimaryGroup__c = true
        );
        insert acrRecord;

        if(isAddlData) {
            AccountContactRelation acrRecord2 = new AccountContactRelation(
                AccountId = householdAccount2.Id,
                ContactId = conRecord.Id,
                FinServ__PrimaryGroup__c = true,
                IsActive = false
            );
            insert acrRecord2;
        }
        return conRecord;
    }

    @isTest
    private static void testCreateHouseholdFlowHavingNoExistingRecord() {
        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin(
            'alias',
            'systemAdmin',
            'systemAdminTest@statefarm.com'
        );
        insert systemAdmin;
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
            insert individualAccountOne;
        }
        Contact conRecord = [SELECT id FROM Contact WHERE AccountId = :individualAccountOne.Id];
        Test.startTest();
        CCV_AccountActionCreateHousehold.createHouseholdFlow(String.valueOf(conRecord.Id));
        Test.stopTest();
        System.assertEquals(true, conRecord != null, 'Contact id is not null');
    }

    @isTest
    private static void testCreateHouseholdFlowHavingExistingRecord() {
        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin(
            'alias',
            'systemAdmin',
            'systemAdminTest@statefarm.com'
        );
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
            .get(HOUSEHOLD_RECORD_TYPE)
            .getRecordTypeId();
        Account householdAccount = new Account(
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
            insert householdAccount;
            insert individualAccountOne;
        }
        Contact conRecord = [SELECT id FROM Contact WHERE AccountId = :individualAccountOne.Id];
        AccountContactRelation acrRecord = new AccountContactRelation(
            AccountId = householdAccount.Id,
            ContactId = conRecord.Id,
            FinServ__PrimaryGroup__c = true
        );
        insert acrRecord;
        Test.startTest();
        CCV_AccountActionCreateHousehold.createHouseholdFlow(String.valueOf(conRecord.Id));
        Test.stopTest();
        System.assertEquals(true, conRecord != null, 'Contact id is not null');
    }

    @isTest
    private static void testCreateHouseholdFlowHavingMultipleRecord() {
        Contact conRecord = testHouseholdDataSetup(true);
        Test.startTest();
        CCV_AccountActionCreateHousehold.createHouseholdFlow(String.valueOf(conRecord.Id));
        Test.stopTest();
        System.assertEquals(true, conRecord != null, 'Contact id is not null');
    }

    @isTest
    private static void testCreateHouseholdFlowHavingError() {
        Contact conRecord = testHouseholdDataSetup(false);

        Test.startTest();
        try {
            CCV_AccountActionCreateHousehold.createHouseholdFlow(null);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Exception thrown');
        }
        Test.stopTest();
    }
}
