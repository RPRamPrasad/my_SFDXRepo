/****************************************************************************************
Name: VFC_CustomerRedirectController_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
Test suite for VFC_CustomerRedirectController class

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                10/23/2017             R4 Major Release
******************************************************************************************/

/**
 * @description VFC Customer Redirect Controller TEST
 */
@isTest 
private class VFC_CustomerRedirectController_TEST {
    
    @isTest
    static void testRedirectToIndividualPage() {
        Map<String, Schema.Recordtypeinfo> schemaRtMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
        Test.startTest();
        Test.setCurrentPageReference(Page.VFP_CustomerRedirect);
        String individualRecordType = ((String) schemaRtMap.get(
            UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME).RecordTypeId).subString(0, 15);
        ApexPages.currentPage().getParameters().put(UTIL_CreateCustomerConstants.RECORD_TYPE, individualRecordType);
        ApexPages.currentPage().getParameters().put(UTIL_CreateCustomerConstants.GROUP_ID, '12345678');
        ApexPages.currentPage().getParameters().put(UTIL_CreateCustomerConstants.RETURN_URL, 
                                                    UTIL_CreateCustomerConstants.CUSTOMER_LIST_PAGE);
        Account acc = new Account();
        VFC_CustomerRedirectController redirectTest = 
            new VFC_CustomerRedirectController(new Apexpages.Standardcontroller(acc));    
        PageReference nextPage = redirectTest.handleRedirect();
        System.assert(individualRecordType.equals(nextPage.getParameters().get(UTIL_CreateCustomerConstants.RECORD_TYPE)),
                        'Record type does not equals to \'UTIL_CreateCustomerConstants.RECORD_TYPE\'');
        System.assert(nextPage.getUrl().contains('vfp_individualcustomercreateedit'),
                        'URL does not contains the String \'vfp_individualcustomercreateedit\'');
        Test.stopTest();    
    }
    
    @isTest
    static void testRedirectToIndPageFromRecTypeSelect() {
        Map<String, Schema.Recordtypeinfo> schemaRtMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
        Test.startTest();
        Test.setCurrentPageReference(Page.VFP_CustomerRedirect);
        Account acc = new Account();
        VFC_CustomerRedirectController redirectTest = 
            new VFC_CustomerRedirectController(new Apexpages.Standardcontroller(acc));    
        PageReference nextPage = redirectTest.handleRedirect();
        System.assert(nextPage==null, 'PageReference object does not equals to null');
        redirectTest.getRecordTypeOptions();
        System.assertEquals(redirectTest.recordTypeId, ((String) schemaRtMap.get(
            UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME).RecordTypeId).subString(0, 15),
            'The given two record type IDs are not equal');
        nextPage = redirectTest.handleRedirect();
        System.assert(nextPage.getUrl().contains('vfp_individualcustomercreateedit'),
        'URL does not contains the String \'vfp_individualcustomercreateedit\'');
        Test.stopTest();    
    }
    
    @isTest
    static void testRedirectToOrgPage() {
        Map<String, Schema.Recordtypeinfo> schemaRtMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
        Test.startTest();
        Test.setCurrentPageReference(Page.VFP_CustomerRedirect);
        String orgRecordType = ((String) schemaRtMap.get(
            UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME).RecordTypeId).subString(0, 15);
        ApexPages.currentPage().getParameters().put(UTIL_CreateCustomerConstants.RECORD_TYPE, orgRecordType);
        ApexPages.currentPage().getParameters().put(UTIL_CreateCustomerConstants.GROUP_ID, '12345678');
        ApexPages.currentPage().getParameters().put(UTIL_CreateCustomerConstants.RETURN_URL, 
                                                    UTIL_CreateCustomerConstants.CUSTOMER_LIST_PAGE);
        Account acc = new Account();
        VFC_CustomerRedirectController redirectTest = 
            new VFC_CustomerRedirectController(new Apexpages.Standardcontroller(acc));    
        PageReference nextPage = redirectTest.handleRedirect();
        System.assert(orgRecordType.equals(nextPage.getParameters().get(UTIL_CreateCustomerConstants.RECORD_TYPE)),
        'Record type does not equals to \'UTIL_CreateCustomerConstants.RECORD_TYPE\'');
        System.assert(nextPage.getUrl().contains('vfp_organizationcustomercreateedit'),
        'URL does not contains the String \'vfp_organizationcustomercreateedit\'');
        Test.stopTest();    
    }
    
    @isTest
    static void testRedirectToOrgPageFromRecTypeSelect() {
        Map<String, Schema.Recordtypeinfo> schemaRtMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
        Test.startTest();
        Test.setCurrentPageReference(Page.VFP_CustomerRedirect);
        Account acc = new Account();
        VFC_CustomerRedirectController redirectTest = 
            new VFC_CustomerRedirectController(new Apexpages.Standardcontroller(acc));    
        PageReference nextPage = redirectTest.handleRedirect();
        System.assert(nextPage==null, 'PageReference object does not equals to null');
        redirectTest.getRecordTypeOptions();
        System.assertEquals(redirectTest.recordTypeId, ((String) schemaRtMap.get(
            UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME).RecordTypeId).subString(0, 15),
            'The given two record type IDs are not equal');
        redirectTest.recordTypeId = ((String) schemaRtMap.get(
            UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME).RecordTypeId).subString(0, 15);
        nextPage = redirectTest.handleRedirect();
        System.assert(nextPage.getUrl().contains('vfp_organizationcustomercreateedit'), 
                    'URL does not contains the String \'vfp_organizationcustomercreateedit\'');
        Test.stopTest();    
    }
    
    @isTest
    static void testRedirectToIndividualEditPage() {
    	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,systemUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AccountBeforeInsert__c = false;
        insert objectBasedByPassTrigger;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;
        
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acc.ClientIdentifier__c = 'SGGSP81L8XB';
        insert acc;
        
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
        insert agentUser;
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Test.setCurrentPageReference(Page.VFP_CustomerRedirect);
            VFC_CustomerRedirectController redirectTest = 
                new VFC_CustomerRedirectController(new Apexpages.Standardcontroller(acc));    
            PageReference nextPage = redirectTest.handleRedirect();
            String customerId = nextPage.getParameters().get(UTIL_CreateCustomerConstants.ID);
            System.assert(nextPage.getUrl().contains('vfp_individualcustomercreateedit'),
            'URL does not contains the String \'vfp_individualcustomercreateedit\'');
            System.assertEquals(customerId, acc.Id, 'The given two IDs are not equal');    
        }
        Test.stopTest();    
    }
    
    @isTest
    static void testRedirectToOrgEditPage() {
    	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,systemUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AccountBeforeInsert__c = false;
        insert objectBasedByPassTrigger;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;
        
        Account acc = UTIL_CreateCustomerTestData.createOrganizationCustomer('Test Account Name');
        acc.ClientIdentifier__c = 'SGGSP81L8XB';
        insert acc;
        Test.startTest();
        Test.setCurrentPageReference(Page.VFP_CustomerRedirect);
        VFC_CustomerRedirectController redirectTest = 
            new VFC_CustomerRedirectController(new Apexpages.Standardcontroller(acc));    
        PageReference nextPage = redirectTest.handleRedirect();
        String customerId = nextPage.getParameters().get(UTIL_CreateCustomerConstants.ID);
        System.assert(nextPage.getUrl().contains('vfp_organizationcustomercreateedit'),
        'URL does not contains the String \'vfp_organizationcustomercreateedit\'');
        System.assertEquals(customerId, acc.Id, 'The given two IDs are not equal');
        Test.stopTest();    
    }
    
    @isTest
    static void testRedirectToRightPageForLeadConversionToInd() {
        
        Map<String, Schema.Recordtypeinfo> schemaRtMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=false);
        insert passTriggerAll;
        passTriggerAll = [select Override_All__c from CS001_ByPassTriggerAll__c];
        passTriggerAll.Override_All__c = true;
        update passTriggerAll;         
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
        insert agentUser;
        Test.startTest(); 
        String individualRecordType = ((String) schemaRtMap.get(
            UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME).RecordTypeId).subString(0, 15);
        Lead objLead = new Lead(LastName = 'Test',LeadSource = 'Web', Status='Open' );
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            insert objLead; 
            ApexPages.currentPage().getParameters().put(UTIL_CreateCustomerConstants.LEAD_ID, objLead.Id);
            ApexPages.currentPage().getParameters().put(UTIL_CreateCustomerConstants.LOB, 'A-F');            
            Account acc = new Account();
            VFC_CustomerRedirectController objCont = new VFC_CustomerRedirectController(new ApexPages.StandardController(acc));                   
            PageReference nextPage = objCont.handleRedirect();
            System.assert(nextPage.getUrl().contains('vfp_individualcustomercreateedit'),
            'URL does not contains the String \'vfp_individualcustomercreateedit\'');
            System.assert(individualRecordType.equals(nextPage.getParameters().get(UTIL_CreateCustomerConstants.RECORD_TYPE)),
            'Record type does not equals to \'UTIL_CreateCustomerConstants.RECORD_TYPE\'');
            System.assertEquals(objLead.Id, nextPage.getParameters().get(UTIL_CreateCustomerConstants.LEAD_ID),
            'The given two IDs are not equal');
        }
        Test.stopTest();      
    }
    
    @isTest
    static void testRedirectToRightPageForLeadConversionToOrg() {
        
        Map<String, Schema.Recordtypeinfo> schemaRtMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();       
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=false);
        insert passTriggerAll;
        passTriggerAll = [select Override_All__c from CS001_ByPassTriggerAll__c];
        passTriggerAll.Override_All__c = true;
        update passTriggerAll;         
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
        insert agentUser;
        Test.startTest();
        String orgRecordType = ((String) schemaRtMap.get(
            UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME).RecordTypeId).subString(0, 15);
        Lead objLead = new Lead(LastName = 'Test',LeadSource = 'Web', Status='Open', Company = 'Test' );
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            insert objLead; 
            ApexPages.currentPage().getParameters().put(UTIL_CreateCustomerConstants.LEAD_ID, objLead.Id);
            ApexPages.currentPage().getParameters().put(UTIL_CreateCustomerConstants.LOB, 'A');
            Account acc = new Account();
            VFC_CustomerRedirectController objCont = new VFC_CustomerRedirectController(new ApexPages.StandardController(acc));                   
            PageReference nextPage = objCont.handleRedirect(); 
            System.assert(nextPage.getUrl().contains('vfp_organizationcustomercreateedit'),
            'URL does not contains the String \'vfp_organizationcustomercreateedit\'');
            System.assert(orgRecordType.equals(nextPage.getParameters().get(UTIL_CreateCustomerConstants.RECORD_TYPE)),
            'Record type does not equals to \'UTIL_CreateCustomerConstants.RECORD_TYPE\'');
            System.assertEquals(objLead.Id, nextPage.getParameters().get(UTIL_CreateCustomerConstants.LEAD_ID),
            'The given two IDs are not equal');
        }
        Test.stopTest();       
    }
    
}