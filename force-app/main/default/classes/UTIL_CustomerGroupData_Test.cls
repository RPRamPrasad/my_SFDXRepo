/*** Author : Team Kraken
* Date Created : 9/5/2018
* @description : test for class that retrieves OData for AT_Billing lightning component
* Version : 1.0
*/
@isTest
(SeeAllData=false)
public class UTIL_CustomerGroupData_Test {
    
    public static String testClientName = 'myName';
    
    @isTest
    private static void testGetClientIdsForGroupHappyPath() {
        Test.startTest();
        Account tempAccount = new Account(Name = 'myName', ClientIdentifier__c  = '12345678901');
        CustomerGroup__c mockCustomerGroup = new CustomerGroup__c();
        CustomerGroupMember__c mockGroupMember = new CustomerGroupMember__c(Group__r = mockCustomerGroup, Customer__r=tempAccount);
        UTIL_CustomerGroupData.mockedGroupMember = mockGroupMember;
        Map<String, Account> groupMap = UTIL_CustomerGroupData.getClientIdsForGroup('groupId');
        Test.stopTest();
        System.assertEquals(groupMap.size(),1,'Expected value is'+groupMap.size()+', but actual value is 1');
        System.assertEquals(tempAccount,groupMap.get('12345678901'),'Expected value is'+tempAccount+', but actual value is'+groupMap.get('12345678901'));
    }
    
    @isTest
    private static void testGetClientIdsForGroupError() {
        Test.startTest();
        try { 
        Account tempAccount = new Account(Name = 'ERROR', ClientIdentifier__c  = '12345678901');
        CustomerGroup__c mockCustomerGroup = new CustomerGroup__c();
        CustomerGroupMember__c mockGroupMember = new CustomerGroupMember__c(Group__r = mockCustomerGroup, Customer__r=tempAccount);
        UTIL_CustomerGroupData.mockedGroupMember = mockGroupMember;
        UTIL_CustomerGroupData.getClientIdsForGroup('groupId');
        System.assertNotEquals('should not get to this line', 'should not get to this line','Given two parameters must not to be equal');
        }
        catch(Exception e) {
            System.AssertEquals('Script-thrown exception', e.getMessage(),'Expected value is Script-thrown exception, but actual value is'+e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testGetRecordIdsForGroupHappyPath() {
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
        Map<Id, Account> groupMap = UTIL_CustomerGroupData.getRecordIdsForGroup('groupId');
        Test.stopTest();
        System.assertEquals(groupMap.size(),1,'Expected value is'+groupMap.size()+', but actual value is 1');
        System.assertEquals(tempAccount1,groupMap.get(tempAccount.id),'Expected value is'+tempAccount1+', but actual value is'+groupMap.get(tempAccount.id));
    }
    
    @isTest
    private static void testGetRecordIdsForGroupError() {
        Test.startTest();
        try { 
        Account tempAccount = new Account(FirstName = 'ERROR', LastName = '', ClientIdentifier__c  = '12345678901');
        CustomerGroup__c mockCustomerGroup = new CustomerGroup__c();
        CustomerGroupMember__c mockGroupMember = new CustomerGroupMember__c(Group__r = mockCustomerGroup, Customer__r=tempAccount, Customer__c=tempAccount.Id);
        UTIL_CustomerGroupData.mockedGroupMember = mockGroupMember;
        UTIL_CustomerGroupData.getRecordIdsForGroup('groupId');
        System.assertNotEquals('should not get to this line', 'should not get to this line','Given two parameters must not to be equal');
        }
        catch(Exception e) {
            System.AssertEquals('Script-thrown exception', e.getMessage(),'Expected value is Script-thrown exception, but actual value is'+e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testGetGroupMembersHappyPath() {
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
        List<CustomerGroupMember__c> groupMembers = UTIL_CustomerGroupData.getGroupMembers('groupId');
        Test.stopTest();
        System.assertEquals(groupMembers.size(),1,'Expected value is'+groupMembers.size()+', but actual value is 1');
        System.assertEquals(mockGroupMember,groupMembers.get(0),'Expected value is'+mockGroupMember+', but actual value is'+groupMembers.get(0));
    }
    
    @isTest
    private static void testGetGroupMembersForGroupError() {
        Test.startTest();
        try { 
        Account tempAccount = new Account(FirstName = 'ERROR', LastName = '', ClientIdentifier__c  = '12345678901');
        CustomerGroup__c mockCustomerGroup = new CustomerGroup__c();
        CustomerGroupMember__c mockGroupMember = new CustomerGroupMember__c(Group__r = mockCustomerGroup, Customer__r=tempAccount, Customer__c=tempAccount.Id);
        UTIL_CustomerGroupData.mockedGroupMember = mockGroupMember;
        UTIL_CustomerGroupData.getGroupMembers('groupId');
        System.assertNotEquals('should not get to this line', 'should not get to this line','Given two parameters must not to be equal');
        }
        catch(Exception e) {
            System.AssertEquals('Script-thrown exception', e.getMessage(),'Expected value is Script-thrown exception, but actual value is'+e.getMessage());
        }
        Test.stopTest();
    }
}