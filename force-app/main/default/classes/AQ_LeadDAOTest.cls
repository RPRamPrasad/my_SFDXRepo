/**
@author Team Skynet
@name AQ_LeadDAOTest
@createDate 12/7/2022
@description Handles testing for AQ_LeadDAO class
*/
@isTest
public with sharing class AQ_LeadDAOTest {

    @testSetup
    private static void testSetup(){
        
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            AQ_TestDataUtility.createAccount();
            Account accountRecord = AQ_TestDataUtility.getAccount();
            User proxyUser = TestUserSetupUtility.getProxyUser();
            AQ_TestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), accountRecord);
            
            AQ_TestDataUtility.createLead(proxyUser.Id);
            Lead leadRecord = AQ_TestDataUtility.getLead(proxyUser.Id);
            AQ_TestDataUtility.createTask(proxyUser.Id,  leadRecord.Id, null);
        }
    }
    
    @isTest
    private static void testGetWorkItems(){
        User agentUser = TestUserSetupUtility.getAgentUser();
        List<AQ_WorkItem> leadWorkItems = new LIst<AQ_WorkItem>();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
	           leadWorkItems = AQ_WorkItemController.getLeads(agentUser.id);
        }
        Test.stopTest();
        System.assertEquals(1, leadWorkItems.size(), 'Number of lead work items did not match');
    }
}