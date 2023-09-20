/**
 Author Team Clubcar
 Name - LWC_OpportunityStartJourney_Test
 @description - Apex unit testing for LWC_OpportunityStartJourney
=========================================================================================================================================
History
-------
VERSION         AUTHOR                  DATE                DETAIL
1.0            Team Clubcar            06/01/2021           Initial Development
2.0            Team Incognito          09/06/2022           Team Incognito - Remove duplicate code /Refactor 
*****************************************************************************************************************************************/

@isTest(seeAllData=false)
public with sharing class LWC_OpportunityStartJourney_Test {
    private static List<Account> accountList;
    private static List<Opportunity> opportunityRecordList;
    private static List<Journey__c> journeyList;
    //
    @TestSetup
    static void testSetupData(){
        List<User> userList = new List<User>();
        User agentUser = TestDataFactory_User_Wrapper.generateAgentUser('OOXA','OOOO111XXXX');
        agentUser.UserExternalID__c = 'OOOO11111XXA';
        userList.add(agentUser);

        User salesLeaderUser = TestDataFactory_User_Wrapper.generateSalesLeaderUser('OO1S','OOOO111XXXX','OOOO111111T');
        salesLeaderUser.UserExternalID__c = 'OOOO111XXXXS';
        userList.add(salesLeaderUser);

        User proxyUser = TestDataFactory_User_Wrapper.generateProxyUser('OO1AP','OOOO111XXXX');
        proxyUser.UserExternalID__c = 'OOOO111XXXXP';
        userList.add(proxyUser);
        insert userList; 
        accountList = new List<Account>(); 
        Account account = TestDataFactory_Account.createIndividualCustomer('TestAccName- 1');
        account.ClientIdentifier__c = 'OO111111121';
        account.BillingState = 'IL';
        accountList.add(account); 
        byPassTrigger();
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestDataFactory_Account.byPassAccountBeforeTrigger(); 
        TestDataFactory_Account.insertAccount(accountList);
        TestDataFactory_Opportunity.byPassOpportunityBeforeTrigger(); 
        createOpportunities(accountList);
        TestDataFactory_Journey.createJourney(); // Used Refactor method createJourney from TestDataFactory_Journey
    }
    //
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }
    //
    /*private static void createJourney(){
        List<Journey__c> journeyList=new List<Journey__c>();
        Journey__c jour1 = TestDataFactory_Journey.buildCustomerProspectJourneyRecord(12345,'0');
        jour1.BusinessLineCode__c = 'General';
        jour1.Categoryname__c = 'Prospect Customers';
        jour1.MasterJourneyId__c = '12345';
        journeyList.add(jour1);
        journeyList.add(TestDataFactory_Journey.buildLeadJourneyRecord(4567,'1'));
        insert journeyList;

        List<Journey_Step__c> journeyStepList = new List<Journey_Step__c>();
        Map<String, Object> journeyStringValues = new Map<String, Object>();

        for(Journey__c journeyRecord:journeyList){
            for(Integer i=0;i<=2;i++){
                journeyStringValues.put('paramJourneyId',journeyRecord.id);
                journeyStringValues.put('paramJourneyStepID',i);
                journeyStringValues.put('paramJourneyNumber',String.valueOf(i));
                journeyStringValues.put('paramVendorCode',1111+i);
                journeyStringValues.put('paramDaysNum',i * 10);
                journeyStringValues.put('paramMailClassCode',String.valueOf(i));
                if(i==3){
                    journeyStringValues.put('paramContactMethodName','Call');
                   
                }else{
                    journeyStringValues.put('paramContactMethodName','Mailing'); 
                }
                Journey_Step__c journey = TestDataFactory_Journey.buildJourneyStepsRecord(journeyStringValues);
                journey.BusinessLineCode__c = 'General';
                journey.StateCode__c = 'IL';
                journey.Categoryname__c = 'Prospect Customers';
                journeyStepList.add(journey);
            }
        }
        insert journeyStepList;
    }*/
    
    private static Opportunity addOpportunity(String name,String lob,String product)
    {
        User proxyUser = [Select Id from User where UserExternalID__c='OOOO111XXXXP'];
        Opportunity opportunityRecord = TestDataFactory_Opportunity.generateOpportunity(name+ accountList[0].FirstName);
            opportunityRecord.AccountId = accountList[0].Id;
            opportunityRecord.OwnerId = proxyUser.Id;
            opportunityRecord.StageName='Closed';
            opportunityRecord.LOB__c=lob;
            opportunityRecord.Company__c='Mutual';
            opportunityRecord.Product__c = Product;
            opportunityRecord.OppClosedDateTime__c = DateTime.now().addDays(-30);
            return opportunityRecord;
    }
    
    private static void createOpportunities(List<Account> accountList){
        opportunityRecordList = new List<Opportunity>(); 
        opportunityRecordList.add(addOpportunity('TestReportOpp','Fire','Artisan and Service Contractor Policy'));
        opportunityRecordList.add(addOpportunity('TestReportOpp1','Auto','Artisan and Service Contractor Policy'));
        opportunityRecordList.add(addOpportunity('TestReportOpp2','Fire','Motorcycle'));
        insert opportunityRecordList; 
    }
    
    @isTest
    public static void testRetrieveJourneyDetailsWithOpportunityMutual(){
        List<Journey__c> journeyResultList = new List<Journey__c>();
        List<Opportunity> opportunity_RecordList =[Select Id from Opportunity where Company__c = 'Mutual' limit 1];
        Test.startTest();
         journeyResultList = LWC_OpportunityStartJourney.retrieveJourneyDetails(opportunity_RecordList[0].Id);
        Test.stopTest(); 
        system.assert(journeyResultList.size()>0, 'Journey list count does not match');
    }
    
    @isTest
    public static void testRetrieveJourneyDetailsWithProductMotorcycle(){
        List<Journey__c> journeyResultList = new List<Journey__c>();
        List<Opportunity> opportunityRecordList =[Select Id from Opportunity where Product__c = 'Motorcycle' limit 1];
        Test.startTest();
        journeyResultList = LWC_OpportunityStartJourney.retrieveJourneyDetails(opportunityRecordList[0].Id);
        Test.stopTest();
        system.assert(journeyResultList.size()>0,'Journey list count does not match');
    }
    
    @isTest
    public static void testRetrieveJourneyDetailsWithOpportunityAuto(){
        List<Journey__c> journeyResultList = new List<Journey__c>();
        List<Opportunity> opportunityRecordList =[Select Id from Opportunity where 
                                                      LOB__c='Auto' AND Product__c = 'Artisan and Service Contractor Policy' limit 1];
        Test.startTest();
        journeyResultList = LWC_OpportunityStartJourney.retrieveJourneyDetails(opportunityRecordList[0].Id);
        Test.stopTest();
        system.assert(journeyResultList.size()>0, 'Journey list count does not match');
    }
    
    @isTest
    public static void testJourneyStepPreviewData(){
        StartJourneyController.JourneyPreviewData journeyPreviewData;
        Journey__c journeyRecord = [Select Id,Type__c from Journey__c where JourneyName__c='JourneyName12345'];
        journeyRecord.Type__c = 'Xdate';
        update journeyRecord;
        List<Opportunity> opportunityRecordList =[Select Id,createdDate,X_Date__c from Opportunity where 
                                                      LOB__c='Auto' AND Product__c = 'Artisan and Service Contractor Policy' limit 1];
        Test.startTest();
        journeyPreviewData = LWC_OpportunityStartJourney.journeyStepPreviewData(opportunityRecordList[0], journeyRecord);
        Test.stopTest();
        System.assertEquals(3, journeyPreviewData.journeyStepList.size(), 'Journey preview data size does not match');
    }    
}