/****************************************************************************************
Name: VFC_CustomerGroupFullRelatedList_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is the test class of the controller to Customer Group Full Related List VF page.

Team: Choo Choo
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo		         2/15/2018             2018 R2 Release

******************************************************************************************/
/**
 * @description VFC_CustomerGroupFullRelatedList_TEST
 */
@isTest(seeAllData = false)
public with sharing class VFC_CustomerGroupFullRelatedList_TEST {

    private static User agentUser {get;set;}
    private static CustomerGroup__c custGroup {get;set;}
    private static Account acc {get;set;}

    @isTest
    static void testOpportunitiesRelatedList() {
    	setup();
        Test.startTest();
        System.runAs(agentUser){
        	insertTestData();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupFullRelatedList);
            ApexPages.currentPage().getParameters().put('sObjectType', 'Opportunity');
            ApexPages.currentPage().getParameters().put('groupId', custGroup.Id);
            ApexPages.currentPage().getParameters().put('customerId', acc.Id);
            VFC_CustomerGroupFullRelatedList ctr = new VFC_CustomerGroupFullRelatedList();
            ctr.init();
            system.assertEquals('Opportunities',ctr.relatedListName, '\'relatedListName\' is not equals to \'Opportunities\'');
        }
        Test.stopTest();
    }

    @isTest
	static void testCaseRelatedList() {
		setup();
        Test.startTest();
        System.runAs(agentUser){
        	insertTestData();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupFullRelatedList);
            ApexPages.currentPage().getParameters().put('sObjectType', 'Case');
            ApexPages.currentPage().getParameters().put('groupId', custGroup.Id);
            VFC_CustomerGroupFullRelatedList ctr = new VFC_CustomerGroupFullRelatedList();
            ctr.init();
            system.assertEquals('Cases',ctr.relatedListName, '\'relatedListName\' is not equals to \'Cases\'');
        }
        Test.stopTest();
    }

    @isTest
    static void testAccountNoteRelatedList() {
    	setup();
        Test.startTest();
        System.runAs(agentUser){
        	insertTestData();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupFullRelatedList);
            ApexPages.currentPage().getParameters().put('sObjectType', 'Account_Note__c');
            ApexPages.currentPage().getParameters().put('groupId', custGroup.Id);
            VFC_CustomerGroupFullRelatedList ctr = new VFC_CustomerGroupFullRelatedList();
            ctr.init();
            system.assertEquals('Account Notes',ctr.relatedListName, '\'relatedListName\' is not equals to \'Account Notes\'');
        }
        Test.stopTest();
    }

    @isTest
    static void testAgentRoleRelatedList() {
    	setup();
        Test.startTest();
        System.runAs(agentUser){
        	insertTestData();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupFullRelatedList);
            ApexPages.currentPage().getParameters().put('sObjectType', 'AgentRole__c');
            ApexPages.currentPage().getParameters().put('groupId', custGroup.Id);
            VFC_CustomerGroupFullRelatedList ctr = new VFC_CustomerGroupFullRelatedList();
            ctr.init();
            system.assertEquals('Agent',ctr.relatedListName, '\'relatedListName\' is not equals to \'Agent\'');
        }
        Test.stopTest();
    }

    @isTest
    static void testOpenTasksRelatedList() {
    	setup();
        Test.startTest();
        System.runAs(agentUser){
        	insertTestData();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupFullRelatedList);
            ApexPages.currentPage().getParameters().put('sObjectType', 'openTasks');
            ApexPages.currentPage().getParameters().put('groupId', custGroup.Id);
            VFC_CustomerGroupFullRelatedList ctr = new VFC_CustomerGroupFullRelatedList();
            ctr.init();
            system.assertEquals(System.Label.CL_OpenTasks,ctr.relatedListName, '\'relatedListName\' is not equals to \'Label.CL_OpenTasks\'');
        }
        Test.stopTest();
    }

    @isTest
    static void testTaskHistoryRelatedList() {
    	setup();
        Test.startTest();
        System.runAs(agentUser){
        	insertTestData();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupFullRelatedList);
            ApexPages.currentPage().getParameters().put('sObjectType', 'TaskHistory');
            ApexPages.currentPage().getParameters().put('groupId', custGroup.Id);
            VFC_CustomerGroupFullRelatedList ctr = new VFC_CustomerGroupFullRelatedList();
            ctr.init();
            system.assertEquals(System.Label.CL_TaskHistory,ctr.relatedListName, '\'relatedListName\' is not equals to \'Label.CL_TaskHistory\'');
        }
        Test.stopTest();
    }

    @isTest
    static void testOpenEventsRelatedList() {
    	setup();
        Test.startTest();
        System.runAs(agentUser){
        	insertTestData();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupFullRelatedList);
            ApexPages.currentPage().getParameters().put('sObjectType', 'openEvents');
            ApexPages.currentPage().getParameters().put('groupId', custGroup.Id);
            VFC_CustomerGroupFullRelatedList ctr = new VFC_CustomerGroupFullRelatedList();
            ctr.init();
            system.assertEquals(System.Label.CL_OpenEvents,ctr.relatedListName, '\'relatedListName\' is not equals to \'Label.CL_OpenEvents\'');
        }
        Test.stopTest();
    }

    @isTest
    static void testEventHistoryRelatedList() {
    	setup();
        Test.startTest();
        System.runAs(agentUser){
        	insertTestData();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupFullRelatedList);
            ApexPages.currentPage().getParameters().put('sObjectType', 'EventHistory');
            ApexPages.currentPage().getParameters().put('groupId', custGroup.Id);
            VFC_CustomerGroupFullRelatedList ctr = new VFC_CustomerGroupFullRelatedList();
            ctr.init();
            system.assertEquals(System.Label.CL_EventHistory,ctr.relatedListName, '\'relatedListName\' is not equals to \'Label.CL_EventHistory\'');
        }
        Test.stopTest();
    }

    @isTest
    static void testPoliciesRelatedList() {
    	setup();
        Test.startTest();
        System.runAs(agentUser){
        	insertTestData();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupFullRelatedList);
            ApexPages.currentPage().getParameters().put('sObjectType', 'policies');
            ApexPages.currentPage().getParameters().put('groupId', custGroup.Id);
            VFC_CustomerGroupFullRelatedList ctr = new VFC_CustomerGroupFullRelatedList();
            ctr.init();
            system.assertEquals(System.Label.CL_PoliciesBillingTabName,ctr.relatedListName, '\'relatedListName\' is not equals to \'Label.CL_PoliciesBillingTabName\'');
        }
        Test.stopTest();
    }

    @isTest
    static void testBillingRelatedList() {
    	setup();
        Test.startTest();
        System.runAs(agentUser){
        	insertTestData();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupFullRelatedList);
            ApexPages.currentPage().getParameters().put('sObjectType', 'billings');
            ApexPages.currentPage().getParameters().put('groupId', custGroup.Id);
            VFC_CustomerGroupFullRelatedList ctr = new VFC_CustomerGroupFullRelatedList();
            ctr.init();
            system.assertEquals(System.Label.CL_PoliciesBillingTabName,ctr.relatedListName, '\'relatedListName\' is not equals to \'Label.CL_PoliciesBillingTabName\'');
        }
        Test.stopTest();
    }

    @isTest
    static void testClaimsRelatedList() {
    	setup();
        Test.startTest();
        System.runAs(agentUser){
        	insertTestData();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupFullRelatedList);
            ApexPages.currentPage().getParameters().put('sObjectType', 'claims');
            ApexPages.currentPage().getParameters().put('groupId', custGroup.Id);
            VFC_CustomerGroupFullRelatedList ctr = new VFC_CustomerGroupFullRelatedList();
            ctr.init();
            system.assertEquals(System.Label.CL_PoliciesBillingTabName,ctr.relatedListName, '\'relatedListName\' is not equals to \'Label.CL_PoliciesBillingTabName\'');
        }
        Test.stopTest();
    }

    @isTest
    static void testActivitiesRelatedList() {
    	setup();
        Test.startTest();
        System.runAs(agentUser){
        	insertTestData();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupFullRelatedList);
            ApexPages.currentPage().getParameters().put('sObjectType', 'activities');
            ApexPages.currentPage().getParameters().put('groupId', custGroup.Id);
            VFC_CustomerGroupFullRelatedList ctr = new VFC_CustomerGroupFullRelatedList();
            ctr.init();
            system.assertEquals(System.Label.CL_PoliciesBillingTabName,ctr.relatedListName, '\'relatedListName\' is not equals to \'Label.CL_PoliciesBillingTabName\'');
        }
        Test.stopTest();
    }

    private static void setup()
    {
        custGroup = null;
        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName');
        insert agentUser;
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true,agentUser);
        insert passTriggerAll;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(agentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
    }

    private static void insertTestData(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    	acc = createIndividualWithValues('John');
        acc.clientidentifier__c = 'TESTCLNTID9';
        insert acc;
        custGroup = buildCustomerGroup(agentUser);
    	insert custGroup;
    	CustomerGroupMember__c c3 = buildCustomerGroupMember(acc,custGroup);
    	insert c3;
    }

    private static CustomerGroup__c buildCustomerGroup(User agentUser) {
        CustomerGroup__c cg = new CustomerGroup__c();
        cg.name = 'Primary Household';
        cg.sfgroupidentifier__c = 'ABCD1234567';
        cg.OwnerId = agentUser.Id;
        return cg;
    }

    private static CustomerGroupMember__c buildCustomerGroupMember(Account cust, CustomerGroup__c grp){
        CustomerGroupMember__c custGrpMember = new CustomerGroupMember__c();
        custGrpMember.customer__c = cust.id;
        custGrpMember.group__c = grp.id;
        custGrpMember.groupmemberid__c = grp.sfgroupidentifier__c + '~' + cust.clientidentifier__c;
        return custGrpMember;
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
}