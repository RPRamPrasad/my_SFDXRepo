/**
* @name UTIL_CustomerGroupEventList_TEST
* @author Poseidon
* @createdDate 09/19/2018
* @description Test class to test utilitly class used by the ustomerGroupEventList component to fetch events 
*/
@isTest(seeAllData = false)
public with sharing class UTIL_CustomerGroupEventList_TEST {
    
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
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);  
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
    
    private static event createFutureEvent(){
        Event event = new Event();
        event.whatId = acc.Id;
        event.WhoId = agentUser.Name;
        event.subject = 'Event Subject';
        event.description = 'Event Description';
        event.OwnerId = agentUser.Id;
        Date todayDate = System.today() + 5;
        event.ActivityDate = todayDate;
        event.DurationInMinutes = 120;
        DateTime todayDateTime = System.now().addDays(5);
        event.ActivityDateTime = todayDateTime;
        insert event;
        return event;
    }
    
    private static event createPastEvent(){
        Event event = new Event();
        event.whatId = acc.Id;
        event.WhoId = agentUser.Name;
        event.subject = 'Event Subject';
        event.description = 'Event Description';
        event.OwnerId = agentUser.Id;
        event.ActivityDate = Date.newInstance(2017, 12, 25);
        event.DurationInMinutes = 120;
        event.ActivityDateTime = DateTime.newInstance(2017, 12, 25);
        insert event;
        return event;
    }
    
    @isTest
    static void testFetchDataOpenEvents() {
        Test.startTest();
        setup();
        
        System.runAs(agentUser) {
            UTIL_CustomerGroupEventList.EventWrapper eventWrapper = new UTIL_CustomerGroupEventList.EventWrapper();
            setupCustomerGroupWithAccount();
            Event localEvent = createFutureEvent();
            Date localDate = System.today();
            CustomerGroupRelatedListController.DataTableResponse customerGroupRelatedResponse = UTIL_CustomerGroupEventList.fetchData(custGroup.Id, 'Open Events',10);
            List<Object> dataRespList = customerGroupRelatedResponse.lstDataTableData;
            
            eventWrapper = (UTIL_CustomerGroupEventList.EventWrapper) dataRespList[0];
            System.assertEquals('/one/one.app#/sObject/'+localEvent.Id, eventWrapper.eventUrl, 'Expected URL is not equals to the actual URL');
            System.assertEquals('Event Subject', eventWrapper.subject, 'Expected subject is not equals to the actual subject');
            System.assertEquals('', eventWrapper.accountName, 'Account name is not an empty String');
            System.assertEquals('', eventWrapper.accountUrl, 'Account URL is not an empty String');
            System.assertEquals('Alice Test Last Name', eventWrapper.relatedTo, 'It is an empty String');
            System.assertEquals('/one/one.app#/sObject/'+localEvent.WhatId, eventWrapper.relatedToUrl, 'Expected URL is not equals to the actual URL');
            System.assert(localDate <= Date.parse(eventWrapper.dueDate), 'Expected Date is not lesser than or equals to the actual Date');
            System.assertEquals('userLastName', eventWrapper.officeAssigned, 'Expected String is not equals to the actual String');
            System.assertEquals('/one/one.app#/sObject/'+localEvent.OwnerId, eventWrapper.officeAssignedUrl, 'Expected URL is not equals to the actual URL');
            System.assertNotEquals(null, eventWrapper.lastModifiedDateTime, 'LastModifiedDateTime is null');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testFetchDataEventHistory() {
        Test.startTest();
        setup();
        
        System.runAs(agentUser) {
            UTIL_CustomerGroupEventList.EventWrapper eventWrapper = new UTIL_CustomerGroupEventList.EventWrapper();
            setupCustomerGroupWithAccount();
            Event localEvent = createPastEvent();
            CustomerGroupRelatedListController.DataTableResponse customerGroupRelatedResponse = UTIL_CustomerGroupEventList.fetchData(custGroup.Id, 'Event History',10);
            List<Object> dataRespList = customerGroupRelatedResponse.lstDataTableData;
            
            eventWrapper = (UTIL_CustomerGroupEventList.EventWrapper) dataRespList[0];
            System.assertEquals('/one/one.app#/sObject/'+localEvent.Id, eventWrapper.eventUrl, 'Expected URL is not equals to the actual URL');
            System.assertEquals('Event Subject', eventWrapper.subject, 'Expected subject is not equals to the actual subject');
            System.assertEquals('', eventWrapper.accountName, 'AccountName is not empty String');
            System.assertEquals('', eventWrapper.accountUrl, 'Account URL is not an empty String');
            System.assertEquals('Alice Test Last Name', eventWrapper.relatedTo, 'It is an empty String');
            System.assertEquals('/one/one.app#/sObject/'+localEvent.WhatId, eventWrapper.relatedToUrl, 'Expected URL is not equals to the actual URL');       
            System.assertEquals('12/25/2017', eventWrapper.dueDate, 'Expected Date is not equals to the actual Date');
            System.assertEquals('userLastName', eventWrapper.officeAssigned, 'Expected String is not equals to the actual String');
            System.assertEquals('/one/one.app#/sObject/'+localEvent.OwnerId, eventWrapper.officeAssignedUrl, 'Expected URL is not equals to the actual URL');
            System.assertNotEquals(null, eventWrapper.lastModifiedDateTime, 'LastModifiedDateTime is null');
            Test.stopTest();
        }
    }
 
}