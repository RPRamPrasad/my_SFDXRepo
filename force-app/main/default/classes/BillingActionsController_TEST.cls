/**
* Author : Team Kraken
* Date Created : 06/08/2020
* @description Provides access to custom metadata types for billingActions LWC
* Version : 1.0
*/

@IsTest
public with sharing class BillingActionsController_TEST {
    @isTest
    private static void isPayBillEnabledIllinoisTest() {
        boolean result = false;
        final String eligibleStateCode = '13-1234';

        User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678913');
        agent.State_Agent_Code__c = eligibleStateCode;
        agent = TestDataFactory_User.insertUser(agent);

        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        System.runAs(agent) {
            result = BillingActionsController.isPayBillEnabled();
        }

        Test.stopTest();

        System.assertEquals(true, result, 'Expected IL state agent code to return true');
    }

    @isTest
    private static void isLobNotEnabledForNonPilotUsersTest() {
        boolean result = false;
        final String eligibleStateCode = '13-1234';

        User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678913');
        agent.State_Agent_Code__c = eligibleStateCode;
        agent = TestDataFactory_User.insertUser(agent);

        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        System.runAs(agent) {
            result = BillingActionsController.isLOBEnabled();
        }

        Test.stopTest();

        System.assertEquals(false, result, 'Expected access to return false');
    }

    @isTest
    private static void testGetRecordIdsForCustomerGroupingHappyPath() {
        Test.startTest();
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account tempAccount = new Account(FirstName = 'myName', LastName = 'myLastName', ClientIdentifier__c  = '12345678901');
        insert tempAccount;
        Account tempAccount1 = [Select name, Clientidentifier__c, id from account where id = :tempAccount.Id];
        
        CustomerGroup__c mockCustomerGroup = new CustomerGroup__c();
        CustomerGroupMember__c mockGroupMember = new CustomerGroupMember__c(Group__r = mockCustomerGroup, Customer__c=tempAccount1.id, Customer__r=tempAccount1);
        UTIL_CustomerGroupData.mockedGroupMember = mockGroupMember;
        Map<Id, Account> groupMap = BillingActionsController.getRecordIdsForCustomerGrouping('groupId');
        Test.stopTest();
        System.assertEquals(groupMap.size(),1,'One account should exist in the map');
        System.assertEquals(tempAccount1,groupMap.get(tempAccount.id),'Account should exist in the map');
    }

    @isTest
    private static void testGetRecordIdsForHouseholdHappyPath() {
        Test.startTest();
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        ID hhId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account tempHHAccount = new Account(Name = 'myName', ClientIdentifier__c  = '123456789', RecordtypeId = hhId);
        Account tempAccount = new Account(FirstName = 'myName', LastName = 'myLastName', ClientIdentifier__c  = '12345678901',Primary_Household__pc = tempHHAccount.Id);
        insert tempAccount;
        
        Account tempAccount1 = [Select name, Clientidentifier__c, id from account where id = :tempAccount.Id];
        
        UTIL_CustomerGroupData_FSC.mockedGroupMember = tempAccount1;
        Map<Id, Account> groupMap = BillingActionsController.getRecordIdsForHousehold('groupId');
        Test.stopTest();
        System.assertEquals(groupMap.size(),1,'One account should exist in the map');
        System.assertEquals(tempAccount1,groupMap.get(tempAccount.Id),'Account should exist in the map');
    }
    @isTest
    private static void testGetRecordIdsForCustomerGroupingsException(){
        Boolean exceptionOccurred = false;
        try {
           BillingActionsController.getRecordIdsForCustomerGrouping(null);
        }catch (Exception ex){
            exceptionOccurred = true;
        }
        System.assert(exceptionOccurred, 'An Exception was thrown');
    }

    @isTest
    private static void testGetRecordIdsForHouseholdException(){
        Boolean exceptionOccurred = false;
        try {
            BillingActionsController.getRecordIdsForHousehold(null);
        }catch (Exception ex){
            exceptionOccurred = true;
        }
        System.assert(exceptionOccurred, 'An Exception was thrown');
    }

}
