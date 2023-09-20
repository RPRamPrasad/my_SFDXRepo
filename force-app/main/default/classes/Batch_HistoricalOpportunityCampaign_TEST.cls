/**
* Author : Team ITIC
* Date Created : 6/10/2019
* Name: Test class for Batch_HistoricalOpportunityCampaign.
* @description Batch_HistoricalOpportunityCampaign_TEST
*/

@isTest(seeAllData=false)

public class Batch_HistoricalOpportunityCampaign_TEST {
    
 @TestSetup
    static void testSetupData(){
        
       TestData_SalesRoleHierarchy roleHierarchy = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('');

       List<Account> accountList = new List<Account>();
        for (Integer i=1;i<=2;i++){
            Account account = TestDataFactory_Account.createIndividualCustomer('TestAccName'+i);
            account.ClientIdentifier__c = 'OO11111111'+i;
            accountList.add(account);
        } 
        TestDataFactory_Account.byPassAccountBeforeTrigger();
        TestDataFactory_Account.insertAccount(accountList);
        createOpportunities(accountList, roleHierarchy.AgentOffice, roleHierarchy.Agent);
    }
    private static void createOpportunities(List<Account> accountList, User proxyUser, User agentUser){
        List<Opportunity> opportunityRecordList = new List<Opportunity>();
        for (Account acc: accountList){
            Opportunity opportunityRecord = TestDataFactory_Opportunity.generateOpportunity('TestReportOpp '+ acc.FirstName);
    	    opportunityRecord.AccountId = acc.Id;
    	    opportunityRecord.OwnerId = proxyUser.Id;
            opportunityRecord.StageName='New';
            opportunityRecord.LOB__c='Auto';
            opportunityRecord.Company__c='Mutual';
            //opportunityRecord.OppClosedDateTime__c = DateTime.now().addDays(-45);
            opportunityRecordList.add(opportunityRecord);
        }
        insert opportunityRecordList;
        for (Opportunity opp: opportunityRecordList){
            createActivityTasks(opp.Id,agentUser.Id);
            Test.setCreatedDate(opp.Id, DateTime.now().addMonths(-2));
        }
    }
    private static void createActivityTasks(String opportunityId,String userId){
        List<Task> taskList = new List<Task>();
        Task taskRecordInclude = new Task(WhatId=opportunityId,OwnerId=userId,ActivityDate=System.today().addDays(-3));
        taskList.add(taskRecordInclude);
        Task taskRecordExclude = new Task(WhatId=opportunityId,OwnerId=userId,ActivityDate=System.today().addDays(+3));
        taskList.add(taskRecordExclude);
        insert taskList;
    }
    private static AP_BatchReportRequest retrieveReportData(){
		AP_RetrieveBatchReportFieldData  reportFieldValue = new AP_RetrieveBatchReportFieldData();
        return reportFieldValue.setBatchReportRequest('Batch_NeglectedAbandonedAutoOpportunity');
	}
    @isTest
    private static void testNonDuplicateCampaignCreation(){
        User batchUser = TestDataFactory_User_Wrapper.generateApiOnlyUser('PROCID','OOOHISTPROC');
        insert batchUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(batchUser);
        PermissionSetAssignment assignPermissionSet = TestDataFactory_PermissionSetAssignment.assignPermissionToUser(batchUser,'SF_CRM_HistoricalReportCampaign_PermSetPID');
        insert assignPermissionSet;
        System.runAs(batchUser){
            Test.StartTest();
            Database.executeBatch(new Batch_HistoricalOpportunityCampaign(retrieveReportData()), 2);
            Test.stopTest();
        }
        List<Campaign> campaignList = [Select Id, Name from Campaign where startdate = TODAY AND Source__c='Report'];
        system.assert(campaignList.size()==1,'Campaign records not created');
    }
}