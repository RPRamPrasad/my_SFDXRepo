/****************************************************************************************
Name: VFC_CustomerGroupRelatedList_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is the test class for the controller to Customer Group Related List VF component.

Team: Choo Choo
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                2/13/2018             2018 R2 Release

******************************************************************************************/
/**
 * @description VFC_CustomerGroupRelatedList_TEST
 */
@isTest(seeAllData = false)
public with sharing class VFC_CustomerGroupRelatedList_TEST {

	private static User agentUser {get;set;}
    private static User atmUser {get;set;}
    private static Account acc {get;set;}
    private static CustomerGroup__c custGroup {get;set;}

    private static void setup()
    {
        custGroup = null;
        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName');
        atmUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.01 Agent Team Member', 'TestName', 'TestName','TestName','TestName');
        atmUser.Servicing_Agent_Associate_ID__c = agentUser.Associate_ID__c;
        insert new List<User>{agentUser, atmUser};
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true,agentUser);
        insert passTriggerAll;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(agentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
    }

    private static void insertTestData(){
    	acc = createIndividualWithValues('John');
        acc.clientidentifier__c = 'TESTCLNTID9';
        insert acc;
        custGroup = buildCustomerGroup(agentUser);
    	insert custGroup;
    	CustomerGroupMember__c c3 = buildCustomerGroupMember(acc,custGroup);
    	insert c3;
    }

    @isTest
     static void testCaseRelatedListViewOnGroupDetail() {
        Test.startTest();
        setup();
        System.runAs(agentUser){
        	insertTestData();
        	case newCase= new Case(Status = 'New', Case_Originator__c='Agent Office', AgentAssociateId__c = null, AccountId = acc.Id);
        	insert newCase;
            VFC_CustomerGroupRelatedList ctr = new VFC_CustomerGroupRelatedList();
            ctr.sObjectType = 'Case';
            ctr.custGroup = custGroup;
            ctr.isSortingReqd = false;
            ctr.isPaginationReqd = true;
            system.assertEquals(null, ctr.pageNumber, '\'pageNumber\' is not null');
            system.assert(!ctr.relatedLists.isEmpty(), '\'relatedLists\' is empty');
            system.assert(String.valueOf(ctr.relatedLists[0].id).startsWith(Schema.Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix()), 'Given String not starts with the given prefix');
            system.assertEquals(1, ctr.stdSetCtr.getResultSize(), 'Return value of the method \'getResultSize\' not equals to  1');
            system.assertEquals(1, ctr.pageNumber, '\'pageNumber\' is not equals to 1');
            ctr.sortColumn = 'Status';
            ctr.sortDataByColumn();
            system.assert(ctr.isAscendingSort, '\'isAscendingSort\' is false');
        }
        Test.stopTest();
    }

    @isTest
    static void testOppRelatedListViewOnGroupDetail() {
        Test.startTest();
        setup();
        System.runAs(agentUser){
        	insertTestData();
        	Opportunity opty = new Opportunity (Name = 'Tst Opty', AccountId = acc.Id,
                            CloseDate = Date.today(), LOB__c = 'Auto', stageName='New');
        	insert opty;
            VFC_CustomerGroupRelatedList ctr = new VFC_CustomerGroupRelatedList();
            ctr.sObjectType = 'Opportunity';
            ctr.custGroup = custGroup;
            ctr.isSortingReqd = true;
            ctr.isPaginationReqd = false;
            system.assertEquals(null, ctr.pageNumber, '\'pageNumber\' is not null');
            system.assert(!ctr.relatedLists.isEmpty(), '\'relatedLists\' is empty');
            system.assert(String.valueOf(ctr.relatedLists[0].id).startsWith(Schema.Opportunity.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix()), 'Given String not starts with the given prefix');
            system.assertEquals(1, ctr.stdSetCtr.getResultSize(), 'Return value of the method \'getResultSize\' not equals to  1');
            system.assertEquals(1, ctr.pageNumber, '\'pageNumber\' is not equals to 1');
            ctr.sortColumn = 'Amount';
            ctr.sortDataByColumn();
            system.assert(ctr.isAscendingSort, '\'isAscendingSort\' is false');
            ctr.sortDataByColumn();
            system.assert(!ctr.isAscendingSort, '\'isAscendingSort\' is true');
        }
        Test.stopTest();
    }

    @isTest
	static void testAccNotesRelatedListViewOnGroupDetail() {
        Test.startTest();
        setup();
        System.runAs(agentUser){
            insertTestData();
            Account_Note__c note = new Account_Note__c(Comments__c= 'the comment',
                                                   Account__c=acc.Id);
        	insert note;
            VFC_CustomerGroupRelatedList ctr = new VFC_CustomerGroupRelatedList();
            ctr.sObjectType = 'Account_Note__c';
            ctr.custGroup = custGroup;
            ctr.isSortingReqd = true;
            ctr.isPaginationReqd = false;
            system.assertEquals(null, ctr.pageNumber, '\'pageNumber\' is not null');
            system.assert(!ctr.relatedLists.isEmpty(), '\'relatedLists\' is empty');
            system.assert(String.valueOf(ctr.relatedLists[0].id).startsWith(Schema.Account_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix()), 'Given String not starts with the given prefix');
            system.assertEquals(1, ctr.stdSetCtr.getResultSize(), 'Return value of the method \'getResultSize\' not equals to  1');
            system.assertEquals(1, ctr.pageNumber, '\'pageNumber\' is not equals to 1');
            ctr.sortDataByColumn();
            system.assert(ctr.isAscendingSort, '\'isAscendingSort\' is false');
            ctr.sortDataByColumn();
            system.assert(!ctr.isAscendingSort, '\'isAscendingSort\' is true');
        }
        Test.stopTest();
    }

    @isTest
	static void testAgentRoleRelatedListViewOnGroupDetail() {
        Test.startTest();
        setup();
        System.runAs(agentUser){
        	insertTestData();
        	AgentRole__c newAgentRole = new AgentRole__c(customer__c=acc.id, Agent__c=agentUser.id);
        	insert newAgentRole;
            VFC_CustomerGroupRelatedList ctr = new VFC_CustomerGroupRelatedList();
            ctr.sObjectType = 'AgentRole__c';
            ctr.custGroup = custGroup;
            ctr.isSortingReqd = true;
            ctr.isPaginationReqd = false;
            system.assertEquals(null, ctr.pageNumber, '\'pageNumber\' is not null');
            system.assert(!ctr.relatedLists.isEmpty(), '\'relatedLists\' is empty');
            system.assert(String.valueOf(ctr.relatedLists[0].id).startsWith(Schema.AgentRole__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix()), 'Given String not starts with the given prefix');
            system.assertEquals(1, ctr.stdSetCtr.getResultSize(), 'Return value of the method \'getResultSize\' not equals to  1');
            system.assertEquals(1, ctr.pageNumber, '\'pageNumber\' is not equals to 1');
            ctr.sortColumn = 'RelationshipNature__c';
            ctr.sortDataByColumn();
            system.assert(ctr.isAscendingSort, '\'isAscendingSort\' is false');
            ctr.sortDataByColumn();
            system.assert(!ctr.isAscendingSort, '\'isAscendingSort\' is true');
        }
        Test.stopTest();
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
