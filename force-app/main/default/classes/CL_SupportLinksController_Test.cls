/**
* Author : Team Kraken
* Date Created : 9/5/2018
* @description : test for class that retrieves OData for AT_Billing lightning component
* Version : 1.0
*/

@isTest
(SeeAllData=false)
public class CL_SupportLinksController_Test {

    public static String testClientId = '333';

    @isTest
    private static void testLaunchCFFDLink() {
        Test.startTest();
        Account tempAccount = new Account(FirstName = 'tst1', LastName='Ltst', ClientIdentifier__c  = 'clientIdentifier');
        List<Account> tempAccountList = new List<Account> {tempAccount};
             CL_SupportLinksController.mockedAccount = tempAccountList;
        UTIL_ReturnClientIdTest.setupTestClientIdQuery(testClientId);
        
        String returnValue = CL_SupportLinksController.launchCFFDLink('recordId');
        Test.stopTest();
        
        String expectedValue = '/c/ExternalLinkApp.app?linkId=90&clientId=333';
        System.assertEquals(expectedValue, returnValue,'Expected value is '+expectedValue+', but actual value is '+returnValue);
    }
    
    @isTest
    private static void testLaunchAPARLink() {
        Test.startTest();
        Account tempAccount = new Account(FirstName = 'tst1', LastName='Ltst', ClientIdentifier__c  = 'clientIdentifier');
        List<Account> tempAccountList = new List<Account> {tempAccount};
             CL_SupportLinksController.mockedAccount = tempAccountList;
        UTIL_ReturnClientIdTest.setupTestClientIdQuery(testClientId);
        
        String returnValue = CL_SupportLinksController.launchAPARLink('recordId');
        Test.stopTest();
        
        String expectedValue = '/c/ExternalLinkApp.app?linkId=91&clientId=333';
        System.assertEquals(expectedValue, returnValue,'Expected value is '+expectedValue+', but actual value is '+returnValue);
    }
 
}