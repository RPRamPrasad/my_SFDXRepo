/****************************************************************************************
Name: VFC_CustomerGroupMemberController_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
Test suite for VFC_CustomerGroupMemberController class

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                1/18/2018             2018 R1 Release
******************************************************************************************/ 

/**
 * @description VFC Customer Group Member Controller TEST
 */
@isTest
public with sharing class VFC_CustomerGroupMemberController_TEST {
   
   private static User agentUser{get;set;}
   private static User atmUser{get;set;}
   private static CustomerGroupMember__c customergroupMember{get; set;}
    
    @isTest
   static void testMethodOne(){
    UTIL_SetFSCCustomSettings_TEST.setFSCSettings();   
    User sysAdmin = UTIL_CreateCustomerTestData.createUserWithAssoId('System Administrator', 'SysAdmin', 'SysAdmin','SysAdmin','SysAdmin');
        insert sysAdmin;
        system.runAs(sysAdmin){
            setup(sysAdmin);
            insertTestData();
        }   
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
             Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberDetail);
             VFC_CustomerGroupMemberController ctr = new VFC_CustomerGroupMemberController(new Apexpages.StandardController(customergroupMember));
             system.assertNotEquals(null, ctr.custGrpMemberRecord, 'Variable \'custGrpMemberRecord\' equals to null');
             Account acc = [SELECT ID, Name FROM Account where FirstName = 'David' limit 1];
             System.AssertEquals(ctr.custGrpMemberRecord.Customer__C, acc.Id, 'The two given paramters are not equal');
             PageReference returnPage = ctr.init();
             system.assert(returnPage.getUrl().containsIgnoreCase('VFP_CustomerGroupDetail'), 
             'The given URL does not contain the String \'VFP_CustomerGroupDetail\'');
             system.assert(returnPage.getRedirect(), 'Method getRedirect() returns false');
             system.assert(returnPage.getParameters().get('Id') != null, 'Parameter \'Id\' equals to null');
             system.assert(returnPage.getParameters().get('accIdInContext') != null, 'Parameter \'accIdInContext\' equals to null');
             system.assert(returnPage.getParameters().get('retUrl') != null, 'Parameter \'retUrl\' equals to null');
             system.assertEquals(returnPage.getUrl(),ctr.redirectUrl, 'The given two parameters are not equal');
        }     
         Test.stopTest();
   }
   
    private static void setup(User sysAdmin)
    {
    	UTIL_SetFSCCustomSettings_TEST.setFSCSettings(); 
        customergroupMember = null;
        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName');
        insert agentUser;
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true,sysAdmin);
        insert passTriggerAll;        
    }
    
    
    private static void insertTestData()
    {
        CustomerGroup__c custGroup = buildCustomerGroup();
        insert custGroup;
        
        Account a1 = createIndividualWithValues('David');
        a1.clientIdentifier__c = 'TESTCLNTID1';
        insert a1;
        
        AccountShare acctShareToInsert1 = new AccountShare(accountId = a1.Id, AccountAccessLevel='Edit', OpportunityAccessLevel='None', CaseAccessLevel='None', UserOrGroupId=agentUser.Id );
        insert acctShareToInsert1;
        
        customergroupMember = buildCustomerGroupMember(a1, custGroup); 
        insert customergroupMember;
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