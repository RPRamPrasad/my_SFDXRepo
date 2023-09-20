/****************************************************************************************
Name: VFC_CustomerGroupDetailController_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
Test suite for VFC_CustomerGroupDetailController class

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                1/18/2018             2018 R1 Release
******************************************************************************************/ 

/**
 * @description VFC Customer Group Detail Controller TEST
 */
@isTest
public with sharing class VFC_CustomerGroupDetailController_TEST {
    private static User agentUser{get;set;}
    private static User atmUser{get;set;}
    private static User salesleaderUser{get;set;}
    private static CustomerGroup__c custGroup{get;set;}
    
    @isTest
    static void testPopulateGroupDetailWithNoGroupMembers(){ 
        User sysAdmin = UTIL_CreateCustomerTestData.createUserWithAssoId('System Administrator', 'SysAdmin', 'SysAdmin','SysAdmin','SysAdmin');
        insert sysAdmin;
        Test.startTest();
        system.runAs(sysAdmin){
            setup(sysAdmin);
        }
        System.runAs(agentUser){
        custGroup = buildCustomerGroup();
        insert custGroup;
        Test.setCurrentPageReference(Page.VFP_CustomerGroupDetail);
        VFC_CustomerGroupDetailController groupDetailController = 
            new VFC_CustomerGroupDetailController(new Apexpages.Standardcontroller(custGroup));
         groupDetailController.init();          
         system.assertEquals(false,groupDetailController.isS1Request, 'Variable \'isS1Request\' equals to true');
         system.assertEquals(null, groupDetailController.accIdInContext, 'Variable \'accIdInContext\' not equals to null');
         system.assertNotEquals(null, groupDetailController.customergroupRecord, 'Variable \'customergroupRecord\' equals to null');
         system.assert(groupDetailController.grpMemberRelationWrapperList.isEmpty(), '\'grpMemberRelationWrapperList\' is not empty');
        }
       Test.stopTest();
    }
    
    @isTest
    static void testPopulateGroupDetailWithGroupMembersAndRelationships(){   
        User sysAdmin = UTIL_CreateCustomerTestData.createUserWithAssoId('System Administrator', 'SysAdmin', 'SysAdmin','SysAdmin','SysAdmin');
        insert sysAdmin;
        system.runAs(sysAdmin){
            setup(sysAdmin);
            insertTestData();
        }        
        Test.startTest();
        System.runAs(agentUser){        
        Test.setCurrentPageReference(Page.VFP_CustomerGroupDetail);
        Account acc = [SELECT Id, Name FROM Account WHERE FirstName = 'David' limit 1];
        ApexPages.CurrentPage().getParameters().put('accIdInContext', acc.Id); 
        VFC_CustomerGroupDetailController groupDetailController = 
            new VFC_CustomerGroupDetailController(new Apexpages.Standardcontroller(custGroup));
         groupDetailController.init();
         groupDetailController.saveGroupChanges();
         groupDetailController.resetChanges();
         system.assert(groupDetailController.isPoliciesSectionVisible, 'Variable \'isPoliciesSectionVisible\' is equals to false');
         system.assertEquals(false,groupDetailController.isS1Request, 'Variable \'isS1Request\' equals to true');         
         system.assertNotEquals(null, groupDetailController.accIdInContext, '\'accIdInContext\' equals to null');
         system.assertNotEquals(null, groupDetailController.customergroupRecord, '\'customergroupRecord\' equals to null');
         system.assert(!groupDetailController.grpMemberRelationWrapperList.isEmpty(), '\'grpMemberRelationWrapperList\' is empty');
         system.assertEquals(acc.Id, groupDetailController.accIdInContext, 'The given two parameters are not equal');
         groupDetailController.customergroupRecord.name = 'Test Change name';
         Account acc1 = [SELECT Id, Name FROM Account WHERE FirstName = 'Jeff' limit 1];
         groupDetailController.primaryContactMember = String.valueof(acc1.id);
         groupDetailController.saveGroupChanges();
         List<CustomerGroup__c> custgrp = [SELECT id, name from CustomerGroup__c where name = 'Test Change name'];
         system.assert(!custgrp.isEmpty(), 'List<CustomerGroup__c> is empty');
         List<CustomerGroupMember__c> grpMemList = [SELECT id, name, customer__r.firstname, MemberPrimaryContact__c from CustomerGroupMember__c where group__r.name = 'Test Change name'];
         for(CustomerGroupMember__c grpMem : grpMemList){
            if(grpMem.customer__r.firstname == 'Jeff') {
                system.assert(grpMem.MemberPrimaryContact__c, '\'MemberPrimaryContact__c\' equals to false');
            }
            else {
                system.assert(!grpMem.MemberPrimaryContact__c, '\'MemberPrimaryContact__c\' equals to true');
            }
         }
        }
        Test.stopTest();
    }
    
    @isTest
    static void testPopulateGroupDetailWithGroupMembersAnd1NoRelationship(){ 
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User sysAdmin = UTIL_CreateCustomerTestData.createUserWithAssoId('System Administrator', 'SysAdmin', 'SysAdmin','SysAdmin','SysAdmin');
        insert sysAdmin;
        system.runAs(sysAdmin){
            setup(sysAdmin);
            insertTestData();
            Account a4 = createIndividualWithValues('Nikhil');
            a4.clientIdentifier__c = 'TESTCLNTID4';
            insert a4;
            AccountShare acctShareToInsert4 = new AccountShare(accountId = a4.Id, AccountAccessLevel='Edit', OpportunityAccessLevel='None', CaseAccessLevel='None', UserOrGroupId=agentUser.Id );
            insert acctShareToInsert4;
            CustomerGroupMember__c c4 = buildCustomerGroupMember(a4,custGroup);
            c4.MemberPrimaryContact__c = true;
            insert c4;
            CS_FeatureToggle__c toggleSetting = new CS_FeatureToggle__c(Policy_Summary__c=true, Claim_Summary__c=true, Billing_Summary__c = true, ABS_Activities_Summary__c = true);
            insert toggleSetting;
        }        
        Test.startTest();
        System.runAs(agentUser){        
            Test.setCurrentPageReference(Page.VFP_CustomerGroupDetail);
            VFC_CustomerGroupDetailController groupDetailController = 
                new VFC_CustomerGroupDetailController(new Apexpages.Standardcontroller(custGroup));
             groupDetailController.init();          
             system.assert(!groupDetailController.isPoliciesSectionVisible, '\'isPoliciesSectionVisible\' equals to true');          
             system.assertEquals(false,groupDetailController.isS1Request, '\'isS1Request\' equals to true');
             system.assertNotEquals(null, groupDetailController.accIdInContext, '\'accIdInContext\' is equals to null');
             system.assertNotEquals(null, groupDetailController.customergroupRecord, '\'customergroupRecord\' is equals to null');
             system.assert(String.isNotBlank(groupDetailController.primaryContactMember), '\'primaryContactMember\' is blank');
             system.assert(!groupDetailController.grpMemberRelationWrapperList.isEmpty(), '\'grpMemberRelationWrapperList\' is empty');
             Account acc = [SELECT id, name from Account where firstName = 'David' LIMIT 1];
             groupDetailController.primaryContactMember = String.valueof(acc.id);
             groupDetailController.saveGroupChanges();
             List<CustomerGroupMember__c> grpMemList = [SELECT id, name, customer__r.firstname, MemberPrimaryContact__c from CustomerGroupMember__c where group__c = :groupDetailController.customergroupRecord.id];
             for(CustomerGroupMember__c grpMem : grpMemList){
                if(grpMem.customer__r.firstname == 'David') {
                    system.assert(grpMem.MemberPrimaryContact__c, '\'MemberPrimaryContact__c\' equals to false');
                }
                else {
                    system.assert(!grpMem.MemberPrimaryContact__c, '\'MemberPrimaryContact__c\' equals to true');
                }
            }
            groupDetailController.customergroupRecord.name = '';
            groupDetailController.saveGroupChanges();
            System.assert(groupDetailController.getHasErrorMessages(), 'There are no error messages');
            System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'ApexPages has no error messages');
            groupDetailController.customergroupRecord.name = 'Test Change name';
            groupDetailController.customergroupRecord.id = null;
            groupDetailController.saveGroupChanges();
            System.assert(groupDetailController.getHasErrorMessages(), 'There are no error messages');
            System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'ApexPages has no error messages');
        }
        Test.stopTest();
    }

    @isTest
    static void testPopulateGroupDetailWithSalesLeader(){   
        User sysAdmin = UTIL_CreateCustomerTestData.createUserWithAssoId('System Administrator', 'SysAdmin', 'SysAdmin','SysAdmin','SysAdmin');
        insert sysAdmin;
        system.runAs(sysAdmin){
            setup(sysAdmin);
            insertTestData();
            CustomerGroup__c cg = [Select Id, name, OwnerId from CustomerGroup__c where sfgroupidentifier__c = 'ABCD1234567' LIMIT 1];
            cg.ownerId = salesleaderUser.id;
            Database.update(cg);
        }        
        Test.startTest();
        System.runAs(salesleaderUser){        
	        Test.setCurrentPageReference(Page.VFP_CustomerGroupDetail);
	        VFC_CustomerGroupDetailController groupDetailController = 
	         new VFC_CustomerGroupDetailController(new Apexpages.Standardcontroller(custGroup));        
	        groupDetailController.init();        
	        system.assertEquals(false,groupDetailController.isS1Request, '\'isS1Request\' equals to true');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testPopulateGroupDetailWithInvalidAccountId(){ 
        User sysAdmin = UTIL_CreateCustomerTestData.createUserWithAssoId('System Administrator', 'SysAdmin', 'SysAdmin','SysAdmin','SysAdmin');
        insert sysAdmin;
        Test.startTest();
        system.runAs(sysAdmin){
            setup(sysAdmin);
        }
        System.runAs(agentUser){
        custGroup = buildCustomerGroup();
        insert custGroup;
        Test.setCurrentPageReference(Page.VFP_CustomerGroupDetail);
        ApexPages.CurrentPage().getParameters().put('accIdInContext', 'testId'); 
        VFC_CustomerGroupDetailController groupDetailController = 
            new VFC_CustomerGroupDetailController(new Apexpages.Standardcontroller(custGroup));
         groupDetailController.init();          
      	System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'ApexPages has no error messages');        }
       Test.stopTest();
    }
    
    @isTest
    static void testGroupMemberMovesPageRedirect(){ 
        User sysAdmin = UTIL_CreateCustomerTestData.createUserWithAssoId('System Administrator', 'SysAdmin', 'SysAdmin','SysAdmin','SysAdmin');
        insert sysAdmin;
        system.runAs(sysAdmin){
            setup(sysAdmin);
            insertTestData();
        }        
        Test.startTest();
        System.runAs(agentUser){        
        Test.setCurrentPageReference(Page.VFP_CustomerGroupDetail);
        Account acc = [SELECT Id, Name FROM Account WHERE FirstName = 'David' limit 1];
        ApexPages.CurrentPage().getParameters().put('accIdInContext', acc.Id);
            VFC_CustomerGroupDetailController groupDetailController = new VFC_CustomerGroupDetailController(new Apexpages.Standardcontroller(custGroup));
            PageReference pageRef = groupDetailController.redirectToHouseholdMovePage();
            system.assert(pageRef!=null, 'Instance of PageReference is null');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testredirectToCreateCustomerPage(){ 
        User sysAdmin = UTIL_CreateCustomerTestData.createUserWithAssoId('System Administrator', 'SysAdmin', 'SysAdmin','SysAdmin','SysAdmin');
        insert sysAdmin;
        system.runAs(sysAdmin){
            setup(sysAdmin);
            insertTestData();
        }        
        Test.startTest();
        System.runAs(agentUser){        
        Test.setCurrentPageReference(Page.VFP_CustomerGroupDetail);
       
            VFC_CustomerGroupDetailController groupDetailController = new VFC_CustomerGroupDetailController(new Apexpages.Standardcontroller(custGroup));
            PageReference pageRef = groupDetailController.redirectToCreateCustomerPage();
            system.assert(pageRef!=null, 'Instance of PageReference is null');
        }
        Test.stopTest();
    }
    
    private static void insertTestData()
    {
        custGroup = buildCustomerGroup();
        insert custGroup;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account a1 = createIndividualWithValues('David');
        a1.clientIdentifier__c = 'TESTCLNTID1';
        Account a2 = createIndividualWithValues('Jeff');
        a2.clientIdentifier__c = 'TESTCLNTID2';
        Account a3 = createIndividualWithValues('Shelly');
        a3.clientIdentifier__c = 'TESTCLNTID3';
        List<Account> accounts = new list<Account> { a2 , a3, a1};
        insert accounts;
        
         AccountShare acctShareToInsert1 = new AccountShare(accountId = a1.Id, AccountAccessLevel='Edit', OpportunityAccessLevel='None', CaseAccessLevel='None', UserOrGroupId=agentUser.Id );
         AccountShare acctShareToInsert2 = new AccountShare(accountId = a2.Id, AccountAccessLevel='Edit', OpportunityAccessLevel='None', CaseAccessLevel='None', UserOrGroupId=agentUser.Id );
         AccountShare acctShareToInsert3 = new AccountShare(accountId = a3.Id, AccountAccessLevel='Edit', OpportunityAccessLevel='None', CaseAccessLevel='None', UserOrGroupId=agentUser.Id );
         List<AccountShare> accountShareList = new list<AccountShare> { acctShareToInsert1 , acctShareToInsert2 , acctShareToInsert3};
         insert accountShareList;
        
        
        CustomerGroupMember__c c1 = buildCustomerGroupMember(a1,custGroup); 
        CustomerGroupMember__c c2 = buildCustomerGroupMember(a2,custGroup);
        CustomerGroupMember__c c3 = buildCustomerGroupMember(a3,custGroup);
        List<CustomerGroupMember__c> customergroupMember = new list<CustomerGroupMember__c> { c1 , c2 , c3};
        insert customergroupMember;
         
        Relationship__c r1 =  buildRelationShip(a1,a2,'Parent');
        Relationship__c r2 = buildRelationShip(a2,a3,'Child');
        Relationship__c r3 = buildRelationShip(a1,a3,'Spouse');
        Relationship__c r4 = buildRelationShip(a2,a1,'Child');
        Relationship__c r5 = buildRelationShip(a3,a1,'Spouse');
        Relationship__c r6 = buildRelationShip(a3,a2,'Parent');
        List<Relationship__c> relationshipList = new list<Relationship__c> {r1,r2,r3,r4,r5,r6};
        insert relationshipList;
    }
    
    private static CustomerGroup__c buildCustomerGroup() {
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
    
    private static Relationship__c buildRelationShip(Account one, Account two, String relType) {
        Relationship__c rel = new Relationship__c();
        rel.accountone__c = one.id;
        rel.accounttwo__c = two.id;
        rel.relationshiptype__c = relType;
        rel.RelationshipIdentifier__c = one.clientidentifier__c+ '~' + two.clientidentifier__c;
        return rel;
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
    
    private static void setup(User sysAdmin)
    {
        custGroup = null;
        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName');
        atmUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.01 Agent Team Member', 'TestName', 'TestName','TestName','TestName');
        salesleaderUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.02 Sales Leader', 'TestNam1', 'TestNam1','TestNam1','TestNam1');
        atmUser.Servicing_Agent_Associate_ID__c = agentUser.Associate_ID__c;
        insert new List<User>{agentUser, atmUser,salesleaderUser};
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true,sysAdmin);
        insert passTriggerAll;        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(agentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser, salesleaderUser});
    }
    
}
