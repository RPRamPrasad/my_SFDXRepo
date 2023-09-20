/**
* @Author Choo_Choo
* @Owner Team Stark
* @Name UTIL_AssignedStaffDAO_TEST
* @CreateDate 04/26/2018 
* @description Common class to access various AssignedStaff related operations for various Processor.
* @Version 1.0
*/
@isTest(seeAllData=false)
public with sharing class UTIL_AssignedStaffDAO_Test {
    
    private static String class_Name = 'UTIL_AssignedStaffDAO_Test';
    private static Integer assigned_Staff_Test_Batch_Size=8;
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static User systemAdminUser;
    
    //test setup
    private static User setUpTestData() {
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        User systemAdminUser1 = [SELECT Id, username from User where Username=:SYSADMIN_USER_ID];
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdminUser1.id);            
        insert sysAdminUserIdSetting;
        
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, systemAdminUser);
        insert passTriggerAll;
        
        return systemAdminUser;
    }
    
    //insert AssignedStaff
    @isTest
    private static void testInsertAssignedStaffSuccess() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestData_SalesRoleHierarchy salesRoleHierarchy1;
        Account acc;
        systemAdminUser = setUpTestData();
        System.runAs(systemAdminUser) {
            salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
            
            acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Jackson');
            acc.clientIdentifier__c = '12345678901';
            insert acc;
            
        }
        System.runAs(systemAdminUser)
        {
            List<AssignedStaff__c> assignedStaffList = new List<AssignedStaff__c>();
            for (Integer assignedStaffCount=0;assignedStaffCount<assigned_Staff_Test_Batch_Size;assignedStaffCount++){
                String temp = salesRoleHierarchy1.AgentTeamMember.Associate_Id__c + assignedStaffCount;
                AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, AssignedStaffIdentifier__c =acc.clientIdentifier__c+'~'+salesRoleHierarchy1.Agent.Associate_ID__c+'~'+ temp,Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
                assignedStaffList.add(newAssignedStaff);
            }
            Test.startTest();           
            UTIL_AssignedStaffDAO.insertAssignedStaff(assignedStaffList);
            Test.stopTest();
            Integer actualAssignedStaff = [SELECT count() FROM AssignedStaff__c];
            System.assertEquals(assigned_Staff_Test_Batch_Size, actualAssignedStaff, 'Assigned Staff Test Batch Size: '+assigned_Staff_Test_Batch_Size);
        }   
    }
    
    //upsert AssignedStaff
    @isTest
    private static void testUpsertAssignedStaffSuccess() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestData_SalesRoleHierarchy salesRoleHierarchy1;
        Account acc;
        systemAdminUser = setUpTestData();
        List<AssignedStaff__c> assignedStaffList = new List<AssignedStaff__c>();
        System.runAs(systemAdminUser) {
            salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
            
            acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Jackson');
            acc.clientIdentifier__c = '12345678901';
            insert acc;
            
            for (Integer assignedStaffCount=0;assignedStaffCount<assigned_Staff_Test_Batch_Size;assignedStaffCount++){
                String temp = salesRoleHierarchy1.AgentTeamMember.Associate_Id__c + assignedStaffCount;
                AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, AssignedStaffIdentifier__c =acc.clientIdentifier__c+'~'+salesRoleHierarchy1.Agent.Associate_ID__c+'~'+ temp,Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
                assignedStaffList.add(newAssignedStaff);
            }
        }
        
        System.runAs(systemAdminUser)
        {
            
            Test.startTest();           
            UTIL_AssignedStaffDAO.upsertAssignedStaff(assignedStaffList, 'AssignedStaffIdentifier__c');
            Test.stopTest();
            Integer actualAssignedStaff = [SELECT count() FROM AssignedStaff__c];
            System.assertEquals(assigned_Staff_Test_Batch_Size, actualAssignedStaff, 'Assigned Staff Test Batch Size: '+assigned_Staff_Test_Batch_Size);
        }   
    }
    
    //update AssignedStaff
    @isTest
    private static void testUpdateAssignedStaffSuccess() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestData_SalesRoleHierarchy salesRoleHierarchy1;
        Account acc;
        Account acc1;
        systemAdminUser = setUpTestData();
        System.runAs(systemAdminUser) {
            salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
            
            acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Jackson');
            acc.clientIdentifier__c = '12345678901';
            insert acc;
            acc1 = UTIL_CreateCustomerTestData.createIndividualCustomer('Sheldon');
            acc1.clientIdentifier__c = '12345678902';
            insert acc1;   
            List<AssignedStaff__c> assignedStaffList = new List<AssignedStaff__c>();
            for (Integer assignedStaffCount=0;assignedStaffCount<assigned_Staff_Test_Batch_Size;assignedStaffCount++){
                String temp = salesRoleHierarchy1.AgentTeamMember.Associate_Id__c + assignedStaffCount;
                AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, AssignedStaffIdentifier__c =acc.clientIdentifier__c+'~'+salesRoleHierarchy1.Agent.Associate_ID__c+'~'+ temp,Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
                assignedStaffList.add(newAssignedStaff);
            }
            
            Test.startTest();
            insert assignedStaffList;
            List<AssignedStaff__c> listToUpdate = new List<AssignedStaff__c>();
            for(AssignedStaff__c assignStaff : assignedStaffList){
                assignStaff.customer__c = acc1.Id;
                listToUpdate.add(assignStaff);
            }
            UTIL_AssignedStaffDAO.updateAssignedStaff(listToUpdate);
            Test.stopTest();
            
            for(AssignedStaff__c assignStaffRetrieved :[SELECT OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, Customer__c, Staff__c, AssignedStaffIdentifier__c, Agent__c FROM AssignedStaff__c WHERE  Customer__r.clientIdentifier__c = :acc.clientIdentifier__c]){
                System.assertEquals(acc1.clientIdentifier__c, assignStaffRetrieved.Customer__r.clientidentifier__c, 'Client Identifier');
            }     
        }   
    }
    
    // delete AssignedStaff
    @isTest
    private static void testDeleteAssignedStaffSuccess() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestData_SalesRoleHierarchy salesRoleHierarchy1;
        Account acc;
        systemAdminUser = setUpTestData();
        System.runAs(systemAdminUser) {
            salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
            
            acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Jackson');
            acc.clientIdentifier__c = '12345678901';
            insert acc;
            
            List<AssignedStaff__c> assignedStaffList = new List<AssignedStaff__c>();
            for (Integer assignedStaffCount=0;assignedStaffCount<assigned_Staff_Test_Batch_Size;assignedStaffCount++){
                String temp = salesRoleHierarchy1.AgentTeamMember.Associate_Id__c + assignedStaffCount;
                AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, AssignedStaffIdentifier__c =acc.clientIdentifier__c+'~'+salesRoleHierarchy1.Agent.Associate_ID__c+'~'+ temp,Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
                assignedStaffList.add(newAssignedStaff);
            }
            Test.startTest();
            insert assignedStaffList;
            UTIL_AssignedStaffDAO.deleteAssignedStaff(assignedStaffList);
            Test.stopTest();
            Integer actualAssignedStaff = [SELECT count() FROM AssignedStaff__c];
            System.assertEquals(0, actualAssignedStaff, 'Actual Assigned Staff: 0');
        }   
    }
}