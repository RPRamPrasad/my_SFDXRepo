/****************************************************************************************
Name: VFC_AccountQuickActionPostMessage_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
Test suite for VFC_AccountQuickActionPostMessage class

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             kdvb                	  03/06/2019             CIMS Embedded Screen

******************************************************************************************/ 

/**
 * @description VFC Account QuickAction Post Message TEST
 */
@isTest(seeAllData = false)
public with sharing class VFC_AccountQuickActionPostMessage_TEST {
	
	private static User systemUser {get; set;}
	private static User agentUser {get; set;}
	private static Account acc {get; set;}
	    
    private static Account createIndividualWithValues() {
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acc.FirstName = 'Test First Name';
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
    static void testControllerWithNoCustomSetting() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c();
        passTriggerAll.Override_All__c = true;
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AccountBeforeInsert__c = false;
        insert objectBasedByPassTrigger;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;
        
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
        insert agentUser;
        
        Account acc = createIndividualWithValues();
        insert acc;
        
        AccountShare accShare = new AccountShare();
        accShare.accountId = acc.Id;
        accShare.AccountAccessLevel = 'Edit';
        accShare.UserOrGroupId = agentUser.Id;
        accShare.OpportunityAccessLevel = 'None';
        accShare.CaseAccessLevel = 'None';
        insert accShare;
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
           Test.setCurrentPageReference(Page.VFP_AccountQuickActionPostMessage);
           VFC_AccountQuickActionPostMessage ctr = new VFC_AccountQuickActionPostMessage(new Apexpages.Standardcontroller(acc));
           system.assertEquals('', ctr.targetDomains, '\'targetDomains\' is not blank');
        }
        Test.stoptest();
	}
	
   @isTest
	static void testControllerWithOneCustomSetting() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c();
        passTriggerAll.Override_All__c = true;
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AccountBeforeInsert__c = false;
        insert objectBasedByPassTrigger;
        
        CS_EnterpriseAppsTargetDomain__c targetDomain = new CS_EnterpriseAppsTargetDomain__c(name='Localhost', isActive__c = true, targetdomain__c = 'http://localhost:8080');
        insert targetDomain;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;
        
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
        insert agentUser;
        
        Account acc = createIndividualWithValues();
        insert acc;
        
        AccountShare accShare = new AccountShare();
        accShare.accountId = acc.Id;
        accShare.AccountAccessLevel = 'Edit';
        accShare.UserOrGroupId = agentUser.Id;
        accShare.OpportunityAccessLevel = 'None';
        accShare.CaseAccessLevel = 'None';
        insert accShare;
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
           Test.setCurrentPageReference(Page.VFP_AccountQuickActionPostMessage);
           VFC_AccountQuickActionPostMessage ctr = new VFC_AccountQuickActionPostMessage(new Apexpages.Standardcontroller(acc));
           system.assertEquals('http://localhost:8080', ctr.targetDomains, 'The given two parameters are not equal');
           ctr.exceptionMsg = 'Invalid Domain';
           ctr.logJSException();
           List<ExceptionLog__c> exLog = [SELECT Id, Name, Method__c, Class__c, Exception_Message__c, Exception_Type__c FROM ExceptionLog__c];
           system.assertEquals(1, exLog.size(), 'The given two parameters are not equal');
           system.assertEquals('VFC_AccountQuickActionPostMessage', exLog.get(0).Class__c, 'The given two parameters are not equal');
           system.assertEquals('PostMessage_Javascript', exLog.get(0).Method__c, 'The given two parameters are not equal');
           system.assertEquals('Invalid Domain', exLog.get(0).Exception_Message__c, 'The given two parameters are not equal');
        }
        Test.stoptest();
	}
	
   @isTest
	static void testControllerWithMultipleCustomSetting() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c();
        passTriggerAll.Override_All__c = true;
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AccountBeforeInsert__c = false;
        insert objectBasedByPassTrigger;
        
        CS_EnterpriseAppsTargetDomain__c targetDomain = new CS_EnterpriseAppsTargetDomain__c(name='Localhost', isActive__c = true, targetdomain__c = 'http://localhost:8080');
        insert targetDomain;
        
        CS_EnterpriseAppsTargetDomain__c targetDomain2 = new CS_EnterpriseAppsTargetDomain__c(name='TestApp', isActive__c = true, targetdomain__c = 'http://testapp:8080');
        insert targetDomain2;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;
        
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
        insert agentUser;
        
        Account acc = createIndividualWithValues();
        insert acc;
        
        AccountShare accShare = new AccountShare();
        accShare.accountId = acc.Id;
        accShare.AccountAccessLevel = 'Edit';
        accShare.UserOrGroupId = agentUser.Id;
        accShare.OpportunityAccessLevel = 'None';
        accShare.CaseAccessLevel = 'None';
        insert accShare;
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
           Test.setCurrentPageReference(Page.VFP_AccountQuickActionPostMessage);
           VFC_AccountQuickActionPostMessage ctr = new VFC_AccountQuickActionPostMessage(new Apexpages.Standardcontroller(acc));
           system.assert(ctr.targetDomains.containsIgnoreCase('http://localhost:8080'), '\'targetDomains\' does not contain the String literal passed as parameter');
           system.assert(ctr.targetDomains.containsIgnoreCase('http://testapp:8080'), '\'targetDomains\' does not contain the String literal passed as parameter');
           system.assert(ctr.targetDomains.containsIgnoreCase(','), '\'targetDomains\' does not contain the String literal passed as parameter');
        }
        Test.stoptest();
	}
}