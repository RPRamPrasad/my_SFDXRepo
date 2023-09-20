/**
* @name UTIL_CustomerGroupAccountNoteList
* @author Poseidon
* @createdDate 10/08/2018
* @description Test class to test utilitly class used by the UTIL_CustomerGroupAccountNoteList component to fetch tasks 
*/
@isTest(seeAllData = false)
public with sharing class UTIL_CustomerGroupAccountNoteList_TEST {
    
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
        agentUser.FirstName = 'Test';
        agentUser.LastName = 'Name';
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
    
    private static Account_Note__c createAccountNote(){
        Account_Note__c acctNote = new Account_Note__c();
        acctNote.Comments__c = 'Test Account Note Comment';       
        acctNote.Account__c = acc.Id;
        insert acctNote;
        return acctNote;        
    }
    
    @isTest
    static void testFetchData() {
        Test.startTest();
        setup();
        
        System.runAs(agentUser) {
            UTIL_CustomerGroupAccountNoteList.AccountNoteWrapper  acctWrapper = new UTIL_CustomerGroupAccountNoteList.AccountNoteWrapper();
            setupCustomerGroupWithAccount();
            Account_Note__c localAcctNote = createAccountNote();
            CustomerGroupRelatedListController.DataTableResponse customerGroupRelatedRespone = UTIL_CustomerGroupAccountNoteList.fetchData(custGroup.Id, 'Account Notes',10);
            List<Object> dataRespList = customerGroupRelatedRespone.lstDataTableData;
            
                       
            acctWrapper = (UTIL_CustomerGroupAccountNoteList.AccountNoteWrapper) dataRespList[0];
            System.assertEquals('/one/one.app#/sObject/'+localAcctNote.Id, acctWrapper.accountUrl, 'Expected URL is not equals to the actual URL');
            System.assertEquals('/one/one.app#/sObject/'+agentUser.id , acctWrapper.createdByUrl, 'Expected URL is not equals to the actual URL');
            System.assertEquals('Test Account Note Comment', acctWrapper.comments, 'Expected comment is not equals to the actual comment');
            System.assertNotEquals(null,  acctWrapper.createdDate, 'CreatedDate is null');
            System.assertEquals(acc.Name, acctWrapper.accountName, 'Expected account name is equals to the actual account name');
            System.assertEquals(agentUser.FirstName + ' ' + agentUser.LastName, acctWrapper.createdByName, 'Expected name is not equals to the actual name');
            Test.stopTest(); 
        }
    }
    
    
}
