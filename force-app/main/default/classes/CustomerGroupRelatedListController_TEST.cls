/**
* @name CustomerGroupRelatedListController_TEST
* @author Poseidon
* @createdDate 09/18/2018
* @description Test class to test controller class CustomerGroupRelatedList component 
*/
@isTest(seeAllData = false)
public with sharing class CustomerGroupRelatedListController_TEST {
    
	private static final String RECORD_ID = 'recordId';
    private static final String OPEN_TASKS = 'Open Tasks';
    private static final String TASK_HISTORY = 'Task History';
    private static final String CAZE = 'Cases';
    private static final String OPEN_EVENTS = 'Open Events';
    private static final String EVENT_HISTORY = 'Event History';
    private static final String OPPORTUNITIES = 'Opportunities';
    private static final String ACCOUNT_NOTES = 'Account Notes';
    private static final String AGENT = 'Agent';
    private static final String GROUP_MEMBERS = 'Group Members';
    private static final String COLUMN_LABEL = 'Test Label';
    private static final String LABEL_FIELD_NAME = 'Label Field Name';
    private static final String TYPE_TARGET = 'Type Target';
    private static final String COLUMN_FIELD_NAME = 'Column Test Field';
    private static final String COLUMN_TYPE = 'Column Test Type';
    private static final Boolean IS_SORTABLE = true;
    private static final String URL_FIELD_NAME = '_self';
    private static final String ACTION_TYPE = 'action';

    private static CustomerGroupRelatedListController.DataTableColumns columns;
    private static CustomerGroupRelatedListController.Label label;
    private static CustomerGroupRelatedListController.TypeAttributes typeAttributes;
    private static CustomerGroupRelatedListController.RowActions rowActions;
    
    private static User agentUser {get;set;}
    private static Account acc {get;set;}
    private static Account acc2 {get;set;}
    private static CustomerGroup__c custGroup {get;set;}
    
    private static void setup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    	custGroup = null;
        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');
        
        insert new List<User>{agentUser};
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, agentUser);
        insert passTriggerAll;   
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(agentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;  
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
 
        
        columns = new CustomerGroupRelatedListController.DataTableColumns(COLUMN_FIELD_NAME, COLUMN_LABEL, COLUMN_TYPE, IS_SORTABLE);
        label = new CustomerGroupRelatedListController.Label(LABEL_FIELD_NAME);
        typeAttributes = new CustomerGroupRelatedListController.TypeAttributes(label, TYPE_TARGET);
    }
    
    private static CustomerGroup__c buildCustomerGroup(User agentUser) {
        CustomerGroup__c cg = new CustomerGroup__c();
        cg.name = 'Primary Household';
        cg.sfgroupidentifier__c = 'ABCD1234567';
        cg.OwnerId = agentUser.Id;
        cg.Agent__c = agentUser.Id;
        return cg;
    }
    
    private static CustomerGroupMember__c buildCustomerGroupMember(Account cust, CustomerGroup__c grp, boolean isPrimaryContact) {
        CustomerGroupMember__c custGrpMember = new CustomerGroupMember__c();
        custGrpMember.customer__c = cust.id;
        custGrpMember.group__c = grp.id;
        custGrpMember.groupmemberid__c = grp.sfgroupidentifier__c + '~' + cust.clientidentifier__c;
        custGrpMember.MemberPrimaryContact__c = isPrimaryContact;
        return custGrpMember;
    }
    
    private static void setupCustomerGroupWithAccount() {
        acc = createIndividualWithValues('Alice');
        acc.clientidentifier__c = 'TESTCLNTID9';
        insert acc;
        custGroup = buildCustomerGroup(agentUser);
        insert custGroup;
        CustomerGroupMember__c c3 = buildCustomerGroupMember(acc,custGroup, true);
        insert c3;
        acc = [SELECT id, name, personcontactId from Account where Id =: acc.Id];
    }
    
    private static void setupCustomerGroupWithSecondAccount() {
        acc = createIndividualWithValues('Alice');
        acc.clientidentifier__c = 'TESTCLNTID8';
        insert acc;
        acc2 = createSecondIndividualWithValues('Bob');
        acc2.clientidentifier__c = 'TESTCLNTID9';
        insert acc2;
        custGroup = buildCustomerGroup(agentUser);
        insert custGroup;
        CustomerGroupMember__c c3 = buildCustomerGroupMember(acc, custGroup, true);       
        insert c3; 
        CustomerGroupMember__c c4 = buildCustomerGroupMember(acc2, custGroup, false);       
        insert c4;
        acc = [SELECT id, name, personcontactId from Account where Id =: acc.Id];
        acc2 = [SELECT id, name, personcontactId from Account where Id =: acc2.Id];
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
    
    private static Account createSecondIndividualWithValues(String firstName) {
        Account acc2 = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acc2.FirstName = firstName;
        acc2.BillingAddressType__c = 'US';
        acc2.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc2.BillingCity = 'Bloomington';
        acc2.BillingState = 'IL';
        acc2.BillingPostalCode = '61704';
        acc2.BillingCountry = 'US';
        acc2.MailingAttention__c= 'Attn';
        acc2.ShippingAddressType__c = 'US';
        acc2.ShippingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc2.ShippingCity = 'Bloomington';
        acc2.ShippingState = 'IL';
        acc2.ShippingPostalCode = '61704';
        acc2.ShippingCountry = 'US';
        acc2.Gender__pc = 'Male';
        acc2.PersonBirthdate = Date.parse('7/14/1986');
        
        return acc2;
    }
    
    @isTest
    static void testfetchDataIsCalledForOpenTasks() {
    	Test.startTest();
        setup();
		
        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            CustomerGroupRelatedListController.DataTableResponse actualResponse = CustomerGroupRelatedListController.fetchData(custGroup.Id, OPEN_TASKS, acc.Id, 10, false);
        	System.assert((Object)actualResponse instanceof CustomerGroupRelatedListController.DataTableResponse, 'Return value of method \'fetchData\' should be instance of \'CustomerGroupRelatedListController.DataTableResponse\'');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testfetchDataIsCalledForTaskHistory() {
    	Test.startTest();
        setup();
		
        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            CustomerGroupRelatedListController.DataTableResponse actualResponse = CustomerGroupRelatedListController.fetchData(custGroup.Id, TASK_HISTORY,acc.Id,10, false);
        	System.assert((Object)actualResponse instanceof CustomerGroupRelatedListController.DataTableResponse, 'Return value of method \'fetchData\' should be instance of \'CustomerGroupRelatedListController.DataTableResponse\'');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testfetchDataIsCalledForOpenEvents() {
    	Test.startTest();
        setup();
		
        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            CustomerGroupRelatedListController.DataTableResponse actualResponse = CustomerGroupRelatedListController.fetchData(custGroup.Id, OPEN_EVENTS,acc.Id,10, false);
        	System.assert((Object)actualResponse instanceof CustomerGroupRelatedListController.DataTableResponse, 'Return value of method \'fetchData\' should be instance of \'CustomerGroupRelatedListController.DataTableResponse\'');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testfetchDataIsCalledForEventHistory() {
    	Test.startTest();
        setup();
		
        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            CustomerGroupRelatedListController.DataTableResponse actualResponse = CustomerGroupRelatedListController.fetchData(custGroup.Id, EVENT_HISTORY,acc.Id,10, false);
        	System.assert((Object)actualResponse instanceof CustomerGroupRelatedListController.DataTableResponse, 'Return value of method \'fetchData\' should be instance of \'CustomerGroupRelatedListController.DataTableResponse\'');
        }
        Test.stopTest();
    }
    
        @isTest
       static void testfetchDataIsCaseRecType() {
    	Test.startTest();
        setup();
		
        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            CustomerGroupRelatedListController.DataTableResponse actualResponse = CustomerGroupRelatedListController.fetchData(custGroup.Id, CAZE,acc.Id,10, false);
        	System.assert((Object)actualResponse instanceof CustomerGroupRelatedListController.DataTableResponse, 'Return value of method \'fetchData\' should be instance of \'CustomerGroupRelatedListController.DataTableResponse\'');
        }
        Test.stopTest();
    }
    
    @isTest
   static void testfetchDataIsAccountNoteRecType() {
        Test.startTest();
        setup();
        
        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            CustomerGroupRelatedListController.DataTableResponse actualResponse = CustomerGroupRelatedListController.fetchData(custGroup.Id, ACCOUNT_NOTES,acc.Id,10, false);
            System.assert((Object)actualResponse instanceof CustomerGroupRelatedListController.DataTableResponse, 'Return value of method \'fetchData\' should be instance of \'CustomerGroupRelatedListController.DataTableResponse\'');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testfetchDataIsCalledForOpportunities() {
    	Test.startTest();
        setup();
		
        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            CustomerGroupRelatedListController.DataTableResponse actualResponse = CustomerGroupRelatedListController.fetchData(custGroup.Id, OPPORTUNITIES,acc.Id,10, false);
        	System.assert((Object)actualResponse instanceof CustomerGroupRelatedListController.DataTableResponse, 'Return value of method \'fetchData\' should be instance of \'CustomerGroupRelatedListController.DataTableResponse\'');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testfetchDataIsCalledForAgents(){
        Test.startTest();
        setup();
        System.runAs(agentUser){
        setupCustomerGroupWithAccount();
            CustomerGroupRelatedListController.DataTableResponse actualResponse = CustomerGroupRelatedListController.fetchData(custGroup.Id, AGENT, acc.Id,10, false);
        	System.assert((Object)actualResponse instanceof CustomerGroupRelatedListController.DataTableResponse, 'Return value of method \'fetchData\' should be instance of \'CustomerGroupRelatedListController.DataTableResponse\'');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testfetchDataIsCalledForGroupMembers(){
        Test.startTest();
        setup();
        System.runAs(agentUser){
            setupCustomerGroupWithAccount();
            CustomerGroupRelatedListController.DataTableResponse actualResponse = CustomerGroupRelatedListController.fetchData(acc.Id, GROUP_MEMBERS, acc.Id,10, true);
            System.assert((Object)actualResponse instanceof CustomerGroupRelatedListController.DataTableResponse, 'Return value of method \'fetchData\' should be instance of \'CustomerGroupRelatedListController.DataTableResponse\'');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testfetchDataIsNotCalled() {
    	Test.startTest();
        setup();
		
        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            CustomerGroupRelatedListController.DataTableResponse actualResponse = CustomerGroupRelatedListController.fetchData(custGroup.Id, null,acc.Id,10, true);
        	System.assertEquals(null, actualResponse, 'CustomerGroupRelatedListController.DataTableResponse should be null');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGroupMemberUpdateCalled() {
    	Test.startTest();
        setup();
		
        System.runAs(agentUser) {
            setupCustomerGroupWithSecondAccount();
            String primaryContact = acc.Id;
            String requestedMember = acc2.Id;

            Boolean result = CustomerGroupRelatedListController.groupMemberUpdate(primaryContact, requestedMember, custGroup.Id,10);
        	System.assert(result, 'Method \'groupMemberUpdate\' should return true');
        }
        Test.stopTest();
    }
    
}