@isTest
public class UTIL_GroupId_TEST {    
    
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
    static void testGetCustomerGroupDetails() {
    	Test.startTest();
        setup();
		
        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            Id groupId = UTIL_GroupId.getCustomerGroupDetails(acc.id);
        	System.assert(custGroup.id == groupId, 'Expected Id not equals to the actual Id');
        }
        Test.stopTest();
    }
}