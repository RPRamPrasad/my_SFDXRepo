/**
@author Team Skynet
@name AQ_OpportunityDAOTest
@createDate 12/7/2022
@description Handles testing for AQ_OpportunityDAO class
*/
@isTest
public with sharing class AQ_OpportunityDAOTest {

    @testSetup
    private static void testSetup(){
        
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            AQ_TestDataUtility.createAccount();
            Account accountRecord = AQ_TestDataUtility.getAccount();
            User proxyUser = TestUserSetupUtility.getProxyUser();
            AQ_TestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), accountRecord);
            AQ_TestDataUtility.createOpportunity(accountRecord, proxyUser);
            Opportunity opp = AQ_TestDataUtility.getOpportunity();
            AQ_TestDataUtility.createTask(proxyUser.Id,  accountRecord.PersonContactId, opp.Id);
        }
    }
    
    @isTest
    private static void testGetWorkItems(){
        
        User agentUser = TestUserSetupUtility.getAgentUser();
        List<AQ_WorkItem> oppWorkItems = new LIst<AQ_WorkItem>();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
	           oppWorkItems = AQ_WorkItemController.getOpportunities(agentUser.id);
        }
        Test.stopTest();
        System.assertEquals(1, oppWorkItems.size(), 'Number of Opportunity work items did not match');
    }

}