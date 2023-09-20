/****************************************************************************************
Name: VFC_CustomerGroupTaskList_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is the test class for the controller to Customer Group open task and task history related list VF component.

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                3/6/2018             2018 R2 Release

******************************************************************************************/

/**
 * @description VFC Customer Group Task List TEST
 */
@isTest(seeAllData = false)
public with sharing class VFC_CustomerGroupTaskList_TEST {
    
    private static User agentUser {get;set;}
    private static User atmUser {get;set;}
    private static Account acc {get;set;}
    private static CustomerGroup__c custGroup {get;set;}
    
    private static void setup(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
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
    	
    	acc = [SELECT id, name, personcontactId from Account where Id =: acc.Id];
    	Id taskRecordTypeId = [SELECT Id FROM RecordType Where SobjectType = 'Task' AND Name = 'Task' LIMIT 1].Id;
    	List<Task> tskListToInsert = new List<Task>();
    	for(Integer i=1; i<27; i++){
    		tskListToInsert.add(createOpenTask(acc, taskRecordTypeId, 'Test'+i));
    		tskListToInsert.add(createClosedTask(acc, taskRecordTypeId, 'Test'+i));
    	}
    	insert tskListToInsert;
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
    
    private static Task createOpenTask(Account acc, Id taskRecordTypeId, String subject){
    	Task testTask = new Task();
        testTask.Type =  System.Label.CL_CONTACT_TYPE;
        testTask.RecordTypeId=taskRecordTypeId;
        testTask.OwnerId = agentUser.Id;
        testTask.Subject = 'Quote '+ subject;
        testTask.Status = System.Label.CL_STATUS;
        testTask.Description = subject;
        testTask.ActivityDate = date.today();
        testTask.Priority = System.Label.CL_PRIORITY;
        testTask.WhatId = acc.Id;
        testTask.WhoId = acc.personContactid;
        testTask.TaskCategory__c = System.Label.CL_CATEGORY_CHANGE;
        return testTask;
    }
    
    private static Task createClosedTask(Account acc, Id taskRecordTypeId, String subject){
    	Task testTask = createOpenTask(acc, taskRecordTypeId, subject);
        testTask.Status = 'Completed';
        return testTask;
    }
    
	@isTest
    static void testOpenTaskRelatedListViewOnGroupDetail() {
    	setup();
    	Test.startTest();
    	System.runAs(agentUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    		insertTestData();
    		VFC_CustomerGroupTaskList ctr = new VFC_CustomerGroupTaskList();
    		ctr.custGroup = custGroup;
    		ctr.sObjectType = 'OpenTasks';
    		ctr.isSortingReqd = false;
    		ctr.isPaginationReqd = false;
    		List<Task> tskList = ctr.currentPageTaskList;
    		system.assertEquals(5, tskList.size(), 'Size of List<Task> not equals to 5');
    		system.assertEquals(1, ctr.pageNumber, 'Variable \'pageNumber\' not equals to 1');
    		system.assertEquals(2, ctr.totalPages, 'Variable \'totalPages\' not equals to 2');
    		system.assert(ctr.hasNext, 'Variable \'hasNext\' equals to false');
    		system.assert(!ctr.hasPrevious, 'Variable \'hasPrevious\' equals to true');
    		system.assert(ctr.isAscendingSort, 'Variable \'isAscendingSort\' equals to false');
    	}
    }
    
	@isTest
    static void testClosedTaskRelatedListViewOnGroupDetail() {
    	setup();
    	Test.startTest();
    	System.runAs(agentUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    		insertTestData();
    		VFC_CustomerGroupTaskList ctr = new VFC_CustomerGroupTaskList();
    		ctr.custGroup = custGroup;
    		ctr.sObjectType = 'TaskHistory';
    		ctr.isSortingReqd = false;
    		ctr.isPaginationReqd = false;
    		List<Task> tskList = ctr.currentPageTaskList;
    		system.assertEquals(5, tskList.size(), 'Size of List<Task> not equals to 5');
    		system.assertEquals(1, ctr.pageNumber, 'Variable \'pageNumber\' not equals to 1');
    		system.assertEquals(2, ctr.totalPages, 'Variable \'totalPages\' not equals to 2');
    		system.assert(ctr.hasNext, 'Variable \'hasNext\' equals to false');
    		system.assert(!ctr.hasPrevious, 'Variable \'hasPrevious\' equals to true');
    		system.assert(!ctr.isAscendingSort, 'Variable \'isAscendingSort\' equals to true');
    	}
    }
    
	@isTest
    static void testOpenTaskFullRelatedListView() {
    	setup();
    	Test.startTest();
    	System.runAs(agentUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    		insertTestData();
    		VFC_CustomerGroupTaskList ctr = new VFC_CustomerGroupTaskList();
    		ctr.custGroup = custGroup;
    		ctr.sObjectType = 'OpenTasks';
    		ctr.isSortingReqd = true;
    		ctr.isPaginationReqd = true;
    		List<Task> tskList = ctr.currentPageTaskList;
    		system.assertEquals(25, tskList.size(), 'Size of List<Task> not equals to 25');
    		system.assertEquals(1, ctr.pageNumber, 'Variable \'pageNumber\' not equals to 1');
    		system.assertEquals(2, ctr.totalPages, 'Variable \'totalPages\' not equals to 2');
    		system.assert(ctr.hasNext, 'Variable \'hasNext\' equals to false');
    		system.assert(!ctr.hasPrevious, 'Variable \'hasPrevious\' equals to true');
    		ctr.sortColumn = 'Subject';
    		ctr.sortDataByColumn();
    		system.assert(ctr.isAscendingSort, 'Variable \'isAscendingSort\' equals to false');
    		ctr.sortDataByColumn();
    		system.assert(!ctr.isAscendingSort, 'Variable \'isAscendingSort\' equals to true');
    		ctr.next();
    		system.assertEquals(2, ctr.pageNumber, 'Variable \'pageNumber\' not equals to 2');
    		tskList = ctr.currentPageTaskList;
    		system.assertEquals(1, tskList.size(), 'Size of List<Task> not equals to 1');
    		system.assert(!ctr.hasNext, 'Variable \'hasNext\' equals to true');
    		system.assert(ctr.hasPrevious, 'Variable \'hasPrevious\' equals to false');
    		ctr.previous();
    		system.assertEquals(1, ctr.pageNumber, 'Variable \'pageNumber\' not equals to 1');
    		system.assert(ctr.hasNext, 'Variable \'hasNext\' equals to false');
    		system.assert(!ctr.hasPrevious, 'Variable \'hasPrevious\' equals to true');
    		ctr.goToLast();
    		system.assertEquals(ctr.totalPages, ctr.pageNumber, 'The given two parameters are not equal');
    		system.assert(!ctr.hasNext, 'Variable \'hasNext\' equals to false');
    		system.assert(ctr.hasPrevious, 'Variable \'hasPrevious\' equals to false');
    		ctr.goToFirst();
    		system.assertEquals(1, ctr.pageNumber, 'Variable \'pageNumber\' not equals to 1');
    		system.assert(ctr.hasNext, 'Variable \'hasNext\' equals to false');
    		system.assert(!ctr.hasPrevious, 'Variable \'hasPrevious\' equals to true');
    	}
    }
    
	@isTest
    static void testClosedTaskFullRelatedListView() {
    	setup();
    	Test.startTest();
    	System.runAs(agentUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    		insertTestData();
    		VFC_CustomerGroupTaskList ctr = new VFC_CustomerGroupTaskList();
    		ctr.custGroup = custGroup;
    		ctr.sObjectType = 'TaskHistory';
    		ctr.isSortingReqd = true;
    		ctr.isPaginationReqd = true;
    		List<Task> tskList = ctr.currentPageTaskList;
    		system.assertEquals(25, tskList.size(), 'Size of List<Task> not equals to 25');
    		system.assertEquals(1, ctr.pageNumber, 'Variable \'pageNumber\' not equals to 1');
    		system.assertEquals(2, ctr.totalPages, 'Variable \'totalPages\' not equals to 2');
    		system.assert(ctr.hasNext, 'Variable \'hasNext\' equals to false');
    		system.assert(!ctr.hasPrevious, 'Variable \'hasPrevious\' equals to true');
    		ctr.sortColumn = 'Subject';
    		ctr.sortDataByColumn();
    		system.assert(ctr.isAscendingSort, 'Variable \'isAscendingSort\' equals to false');
    		ctr.sortDataByColumn();
    		system.assert(!ctr.isAscendingSort, 'Variable \'isAscendingSort\' equals to true');
    		ctr.next();
    		system.assertEquals(2, ctr.pageNumber, 'Variable \'pageNumber\' not equals to 2');
    		tskList = ctr.currentPageTaskList;
    		system.assertEquals(1, tskList.size(), 'Size of List<Task> not equals to 1');
    		system.assert(!ctr.hasNext, 'Variable \'hasNext\' equals to true');
    		system.assert(ctr.hasPrevious, 'Variable \'hasPrevious\' equals to false');
    		ctr.previous();
    		system.assertEquals(1, ctr.pageNumber, 'Variable \'pageNumber\' not equals to 1');
    		system.assert(ctr.hasNext, 'Variable \'hasNext\' equals to false');
    		system.assert(!ctr.hasPrevious, 'Variable \'hasPrevious\' equals to true');
    		ctr.goToLast();
    		system.assertEquals(ctr.totalPages, ctr.pageNumber, 'The given two parameters are not equal');
    		system.assert(!ctr.hasNext, 'Variable \'hasNext\' equals to true');
    		system.assert(ctr.hasPrevious, 'Variable \'hasPrevious\' equals to false');
    		ctr.goToFirst();
    		system.assertEquals(1, ctr.pageNumber, 'Variable \'pageNumber\' not equals to 1');
    		system.assert(ctr.hasNext, 'Variable \'hasNext\' equals to false');
    		system.assert(!ctr.hasPrevious, 'Variable \'hasPrevious\' equals to true');
    	}
    }
}