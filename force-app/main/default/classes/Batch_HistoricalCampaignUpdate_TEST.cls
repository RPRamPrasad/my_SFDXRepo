/**
* Author : Team ITIC
* Date Created : 09/06/2019
* Name : Test class for Batch_HistoricalCampaignUpdate.
* @description Batch_HistoricalCampaignUpdate_TEST
*/

@isTest(seeAllData=false)

public class Batch_HistoricalCampaignUpdate_TEST {
    
 @TestSetup
    static void testSetupData(){
        User batchUser = [Select id from User where Username like 'sf_crm_historicalreportca@statefarm.com%'];
        TestData_SalesRoleHierarchy roleHierarchy = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('');

       List<Account> accountList = new List<Account>();
        for (Integer i=1;i<=2;i++){
            Account account = TestDataFactory_Account.createIndividualCustomer('TestAccName'+i);
            account.ClientIdentifier__c = 'OO11111111'+i;
            accountList.add(account);
        } 
        TestDataFactory_Account.byPassAccountBeforeTrigger();
        TestDataFactory_Account.insertAccount(accountList);
        createOpportunities(accountList, roleHierarchy.AgentOffice);    
        
        List<Opportunity> oppList = [SELECT Id, OwnerId, Owner.Alias,Owner.SubUserType__c,Owner.UserType__c, AccountId, Account.PersonContactId, Account.IsDeathNotificationReceived__pc FROM Opportunity
                                     WHERE StageName='Closed' AND LOB__c='Auto' AND IsAccountHealthSourced__c=false AND Company__c!='Standard' AND Closed_Reason__c 
                                     NOT IN ('Invalid Contact Information','Ineligible','Error','Duplicate Opportunity','Returned for Credit','Deleted') AND 
                                     CreatedDate = LAST_N_MONTHS:3 AND CreatedDate < LAST_N_MONTHS:2];
        System.runAs(batchUser){
        AP_HistoricalOpportunityCampaign historicalOpportunityCampaign = new AP_HistoricalOpportunityCampaign();
        historicalOpportunityCampaign.processOpportunityCampaign(oppList, retrieveReportData());
    }
    }
    private static void createOpportunities(List<Account> accountList, User proxyUser){
        List<Opportunity> opportunityRecordList = new List<Opportunity>();
        proxyUser.UserType__c = 'Agent Proxy';
        update proxyUser;
        for (Account acc: accountList){
            Opportunity opportunityRecord = TestDataFactory_Opportunity.generateOpportunity('TestReportOpp '+ acc.FirstName);
    	    opportunityRecord.AccountId = acc.Id;
    	    opportunityRecord.OwnerId = proxyUser.Id;
            opportunityRecord.StageName='Closed';
            opportunityRecord.LOB__c='Auto';
            opportunityRecord.Company__c='Mutual';
            opportunityRecord.OppClosedDateTime__c = DateTime.now().addDays(-30);
            opportunityRecordList.add(opportunityRecord);
        }
        insert opportunityRecordList;
        for (Opportunity opp: opportunityRecordList){
            Test.setCreatedDate(opp.Id, DateTime.now().addMonths(-3));
        }
    }
    private static AP_BatchReportRequest retrieveReportData(){
		AP_RetrieveBatchReportFieldData  reportFieldValue = new AP_RetrieveBatchReportFieldData();
		return reportFieldValue.setBatchReportRequest('Batch_NeglectedAbandonedAutoOpportunity');
	}
    @isTest
    private static void testCampaignCreation(){
        User batchUser = TestDataFactory_User_Wrapper.generateApiOnlyUser('PROCID','OOOHISTPROC');
        insert batchUser;
        PermissionSetAssignment assignPermissionSet = TestDataFactory_PermissionSetAssignment.assignPermissionToUser(batchUser,'SF_CRM_HistoricalReportCampaign_PermSetPID');
        insert assignPermissionSet;
        //System.runAs(TestDataFactory_User.getSysAdminUser()){
        System.runAs(batchUser){
            Test.StartTest();
            Database.executeBatch(new Batch_HistoricalCampaignUpdate(), 200);
            Test.stopTest();
        }
        List<Campaign> campaignList = [Select Id, Name, Status, Original_Campaign_Count__c, Submitted_Campaign_Count__c from Campaign where startdate = TODAY AND Source__c='Report'];
        system.assert(campaignList.size()==1,'Campaign List Size should be equal to 1');
        system.assertEquals('Fulfillment Completed', campaignList[0].Status,'Expected Status of Campaign List is Fulfillment Completed but actual value is'+campaignList[0].Status);
        system.assertEquals(2, campaignList[0].Original_Campaign_Count__c,'Campaign Count should be 2');
        system.assertEquals(2, campaignList[0].Submitted_Campaign_Count__c,'Campaign Count should be 2');
    }
}
