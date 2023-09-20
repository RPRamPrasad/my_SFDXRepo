/**
* @name UTIL_CustomerGroupList_TEST
* @author Poseidon
* @createdDate 09/11/2018
* @description Test class to test utilitly class used by the CustomerGroupTaskList component to fetch tasks
*/
@isTest(seeAllData = false)
public with sharing class UTIL_CustomerGroupList_TEST {
    private static User agentUser {get;set;}
    private static User atmUser {get;set;}
    private static User noAccessUser {get;set;}
    private static Account acc {get;set;}
    private static CustomerGroup__c custGroup {get;set;}

    private static void setup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        custGroup = null;
        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName');
        atmUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.01 Agent Team Member', 'TestName', 'TestName','TestName','TestName');
        noAccessUser =  new User(alias = 'SYSA', email='noaccessTest@statefarm.com.bad',
                                 emailencodingkey='UTF-8', lastname='TestSysRecOwner', languagelocalekey='en_US',
                                 localesidkey='en_US', timezonesidkey='America/Chicago', username= 'sysAccRecOwner@test.com');
        noAccessUser.ProfileId = [select Id from Profile where name = '1.02 No Access' LIMIT 1].Id;

        atmUser.Servicing_Agent_Associate_ID__c = agentUser.Associate_ID__c;
        insert new List<User>{agentUser, atmUser, noAccessUser};
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, agentUser);
        insert passTriggerAll;
        CS001_ByPassTriggerAll__c passTriggerAllNoAccess = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, noAccessUser);
        insert passTriggerAllNoAccess;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(agentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,noAccessUser});
    }


    private static CustomerGroup__c buildCustomerGroup(User agentUser) {
        CustomerGroup__c cg = new CustomerGroup__c();
        cg.name = 'Primary Household';
        cg.sfgroupidentifier__c = 'ABCD1234567';
        cg.OwnerId = agentUser.Id;
        return cg;
    }

    private static CustomerGroupMember__c buildCustomerGroupMember(Account cust, CustomerGroup__c grp) {
        CustomerGroupMember__c custGrpMember = new CustomerGroupMember__c();
        custGrpMember.customer__c = cust.id;
        custGrpMember.group__c = grp.id;
        custGrpMember.groupmemberid__c = grp.sfgroupidentifier__c + '~' + cust.clientidentifier__c;
        return custGrpMember;
    }

    private static void setupCustomerGroupWithAccount() {
        acc = createIndividualWithValues('Alice');
        acc.clientidentifier__c = 'TESTCLNTID9';
        insert acc;
        custGroup = buildCustomerGroup(agentUser);
        insert custGroup;
        CustomerGroupMember__c c3 = buildCustomerGroupMember(acc,custGroup);
        insert c3;
        acc = [SELECT id, name, personcontactId from Account where Id =: acc.Id];
    }

    private static Account createIndividualWithValues(String firstName) {
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acc.FirstName = firstName;
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.BillingCity = 'Bloomington';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '61704';
        acc.BillingCountry = 'US';
        acc.MailingAttention__c= 'Attn';
        acc.ShippingAddressType__c = 'US';
        acc.ShippingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.ShippingCity = 'Bloomington';
        acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '61704';
        acc.ShippingCountry = 'US';
        return acc;
    }

    @isTest
    static void testFieldsAreAccessibleForQuery() {
        Test.startTest();
        setup();

        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();

            List<Id> customerGroupMemberIdList = UTIL_CustomerGroupList.fetchCustomerGroupMemberIds(custGroup.Id);
            System.assertEquals(acc.Id, customerGroupMemberIdList.get(0), 'Expected AccountId is not equals to the actual Account Id');
        }
    }

    @isTest
    static void testFieldsAreNotAccessibleForQuery() {
        Test.startTest();
        setup();

        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
        }

        System.runAs(noAccessUser) {
            try {
                UTIL_CustomerGroupList.fetchCustomerGroupMemberIds(custGroup.Id);
            } catch(NoAccessException ex) {
                System.assert(ex.getTypeName().contains('NoAccessException'), 'Method \'getTypeName\' does not contain the String \'NoAccessException\'');
            }
        }
    }

    @isTest
    static void testFieldsAreAccessibleForQueryForEvent() {
        String query = 'SELECT Id, WhoId, Who.Name, WhatId, What.Name, Subject, OwnerId, Owner.Name, ActivityDate, ActivityDateTime, LastModifiedDate FROM Event';
        Test.startTest();
        setup();

        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            List<Id> customerGroupMemberIdList = UTIL_CustomerGroupList.fetchCustomerGroupMemberIds(custGroup.Id);
            List<Event> events = UTIL_CustomerGroupList.fetchEventList(customerGroupMemberIdList, query);
            System.assertNotEquals(events, null, 'List<Event> is null');
        }
    }

    @isTest
    static void testFieldsAreNotAccessibleForQueryForEvent() {
        Test.startTest();
        setup();

        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
        }

        System.runAs(noAccessUser) {
            List<Id> testIds = new List<Id>();
            try {
                UTIL_CustomerGroupList.fetchEventList(testIds, 'Test Query');
            } catch(AuraHandledException aex) {
                System.assert(aex.getMessage().contains('Sorry, you do not have access to these fields'), 'Method \'getMessage\' does not contain the String \'Sorry, you do not have access to these fields\'');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testBuildLightningUrl() {
        Test.startTest();
        String urlId = '';
        System.assertEquals('', UTIL_CustomerGroupList.buildLightningUrl(urlId), 'String is not empty');
    }

    @isTest
    static void testBuildLightningUrlEmpty() {
        Test.startTest();
        String urlId = 'testId';
        System.assertEquals('/one/one.app#/sObject/testId', UTIL_CustomerGroupList.buildLightningUrl(urlId), 'Expected URL is not equals to the actual URL');
    }

    @isTest
    static void testHandleNullStringNull() {
        Test.startTest();
        String urlId = null;
        System.assertEquals('', UTIL_CustomerGroupList.handleNullString(urlId), 'String is not empty');
    }

    @isTest
    static void testHandleNullStringNotNull() {
        Test.startTest();
        String urlId = 'testId';
        System.assertEquals('testId', UTIL_CustomerGroupList.handleNullString(urlId), 'String is not equals to \'testId\'');
    }

    @isTest
    static void testHandleNullDateNull() {
        Test.startTest();
        Date testDate = null;
        System.assertEquals('', UTIL_CustomerGroupList.handleNullDate(testDate), 'Date is not empty');
    }

    @isTest
    static void testHandleNullDateNotNull() {
        Test.startTest();
        Date testDate = Date.newInstance(2018, 12, 25);
        System.assertEquals(testDate.format(), UTIL_CustomerGroupList.handleNullDate(testDate), 'Expected Date is not equals to the actual Date');
    }

    @isTest
    static void testHandleNullDecimalNotNull() {
        Test.startTest();
        Decimal testDecimal = 100.00;
        System.assertEquals('$' + String.valueOf(testDecimal.setScale(2)), UTIL_CustomerGroupList.handleNullDecimal(testDecimal), 'Expected Decimal value not equals to the actual Decimal value');
    }

    @isTest
    static void testHandleNullDecimalNull() {
        Test.startTest();
        Decimal testDecimal = null;
        System.assertEquals('', UTIL_CustomerGroupList.handleNullDecimal(testDecimal), 'Decimal value is not empty');
    }

    @isTest
    static void canFetchSFGroupIdentifier() {
        Test.startTest();
        setup();

        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            String sfGroupId=UTIL_CustomerGroupList.fetchSFGroupIdentifier(custGroup.Id);

            System.assertEquals(custGroup.SFGroupIdentifier__c, sfGroupId, 'Expected group id is not equals to the actual group id');
        }
    }

    @isTest
    static void fetchSFGroupIdentifierWithNonExistentIdReturnsEmptyString() {
        Test.startTest();
        setup();

        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            String sfGroupId=UTIL_CustomerGroupList.fetchSFGroupIdentifier(acc.id);

            System.assertEquals('', sfGroupId, 'Group id is not empty');
        }
    }
}