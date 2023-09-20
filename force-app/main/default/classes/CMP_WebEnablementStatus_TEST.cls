/****************************************************************************************
Name: CMP_WebEnablementStatus_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is the test class for controller to account Web enablement status lightning component.

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             kdvb                      1/16/2019              2019 R1 Release

******************************************************************************************/

/**
 * @description CMP Web Enablement Status TEST
 */
@isTest(seeAllData = false)
public with sharing class CMP_WebEnablementStatus_TEST {
    
    private static WebEnablement__x createWebEnablement(String clientId, String webEnabledStatus){
        WebEnablement__x getWebEnablement = new WebEnablement__x(clientId__c = clientId, webEnabledStatus__c = webEnabledStatus);
        return getWebEnablement;
    }
    
    private static Account createIndividualWithValues(string clientIdentifier) {
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
        acc.ShippingStreet = 'Test Street Test Street \n Test Street  Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.ShippingCity = 'Bloomington';
        acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '61704';
        acc.ShippingCountry = 'US';
        acc.ClientIdentifier__c  = clientIdentifier;
        return acc;
    }
    
    @isTest
    static void testFetchClientIdSuccess() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;
        
        CS_Customer_Suffix__c suffixCS = new CS_Customer_Suffix__c();
        suffixCS.Name = 'Jr';
        suffixCS.Sequence_Number__c = 1;
        insert suffixCS;
        
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
        insert agentUser;

        
        User slUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.02 Sales Leader', 'TestSL', 'TestSL','TestSL','TestSL');
        insert slUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,slUser});
        
        createWebEnablement('12345678910','Not Started');
        
        Account testAccnt = createIndividualWithValues('12345678910');
        insert testAccnt;
        AccountShare acctShareToInsert = new AccountShare(accountId = testAccnt.Id, AccountAccessLevel='Edit', OpportunityAccessLevel='None', CaseAccessLevel='None', UserOrGroupId=agentUser.Id );
        insert acctShareToInsert;
        AccountShare acctShareToInsert1 = new AccountShare(accountId = testAccnt.Id, AccountAccessLevel='Read', OpportunityAccessLevel='None', CaseAccessLevel='None', UserOrGroupId=slUser.Id );
        insert acctShareToInsert1;
        CMP_WebEnablementStatus.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMER_WEB_ENABLEMENT, true);
        Test.startTest();
         System.runAs(agentUser){
            System.assert(CMP_WebEnablementStatus.getToggleStatus(), 'Expected toggle status should be equals to the actual toggle status');
            CMP_WebEnablementStatus.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMER_WEB_ENABLEMENT, false);
            System.assert(!CMP_WebEnablementStatus.getToggleStatus(), 'Expected toggle status should not be equals to the actual toggle status');
            String clientId = '12345678910';
            CMP_WebEnablementStatus.mockedWebEnablementObj = new List<WebEnablement__x>{createWebEnablement('12345678910','Not Started')};
            
            CMP_WebEnablementStatus.WebEnablementResponse webResponse = new CMP_WebEnablementStatus.WebEnablementResponse();
            webResponse = CMP_WebEnablementStatus.fetchWebEnablementStatus(clientId);
            System.assertEquals(true, webResponse.isStatusNotStarted, 'isStatusNotStarted should be true');
            System.assertEquals('Not Started', webResponse.status, 'Status should be \'Not Started\'');
            System.assertEquals(true, webResponse.isQuerySuccess, 'isQuerySuccess should be true');
            
            CMP_WebEnablementStatus.mockedWebEnablementObj =  new List<WebEnablement__x>{createWebEnablement('12345678910','Complete')};
            webResponse = CMP_WebEnablementStatus.fetchWebEnablementStatus(clientId);
            System.assertEquals(false, webResponse.isStatusNotStarted, 'isStatusNotStarted should be false');
            System.assertEquals('Complete', webResponse.status, 'Status should be \'Complete\'');
            System.assertEquals(true, webResponse.isQuerySuccess, 'isQuerySuccess should be true');
            
            CMP_WebEnablementStatus.mockedWebEnablementObj =  new List<WebEnablement__x>();
            webResponse = CMP_WebEnablementStatus.fetchWebEnablementStatus(clientId);
            System.assertEquals(false, webResponse.isStatusNotStarted, 'isStatusNotStarted should be false');
            System.assertEquals('', webResponse.status, 'Status should be empty String');
            System.assertEquals(false, webResponse.isQuerySuccess, 'isQuerySuccess should be false');
            
            String redirectUrl = CMP_WebEnablementStatus.getRedirectUrl(testAccnt.Id);
            System.assert(redirectUrl.toLowerCase().contains('/apex/vfp_externallink?'), 'Redirect URL should contain the String \'/apex/vfp_externallink?\'');
            System.assert(redirectUrl.contains('accountId='+testAccnt.Id), 'Redirect URL should contain the givent account id parameter');
            System.assert(redirectUrl.contains('LinkId=54'), 'Redirect URL should contain the givent LinkId parameter');
         }
         
         System.runAs(slUser){
            String clientId = '12345678910';
            CMP_WebEnablementStatus.mockedWebEnablementObj =  new List<WebEnablement__x>{createWebEnablement('12345678910','Not Started')};
            
            CMP_WebEnablementStatus.WebEnablementResponse webResponse = new CMP_WebEnablementStatus.WebEnablementResponse();
            webResponse = CMP_WebEnablementStatus.fetchWebEnablementStatus(clientId);
            System.assertEquals(false, webResponse.isStatusNotStarted, 'isStatusNotStarted should be false');
            System.assertEquals('Not Started', webResponse.status, 'Status should be \'Not Started\'');
            System.assertEquals(true, webResponse.isQuerySuccess, 'isQuerySuccess should be true');
            
         }
         Test.stopTest();
    }
}