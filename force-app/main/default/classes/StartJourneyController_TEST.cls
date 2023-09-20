/**
* @name StartJourneyController_TEST
* @author Team ITIC
* @createdDate 04/08/2020
* @description Apex unit testing for StartJourneyController
*/

@isTest(seeAllData=False)

public with sharing class StartJourneyController_TEST {
@TestSetup
    static void setupTestData(){
        User agentUser = TestDataFactory_User_Wrapper.generateAgentUser('OO1A','OOOO111122B');
        agentUser.UserExternalID__c = 'OOOO111122B';
        agentUser.Servicing_Agent_Associate_ID__c = 'OOOO111122B';
        agentUser.State_Agent_Code__c = '1313';
        insert agentUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        Account account = TestDataFactory_Account.createIndividualCustomer('TestAccName');
        account.ClientIdentifier__c = 'OO111111229';    

        TestDataFactory_Account.byPassAccountBeforeTrigger();
        TestDataFactory_Account.byPassAgentRoleBeforeTrigger();
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        account = TestDataFactory_Account.insertAccount(account);

        TestDataFactory_AgentRole.createAgentRole (agentUser, account, 'Customer');
        account = [Select id,Personcontactid,ClientIdentifier__c from account where ClientIdentifier__c = 'OO111111229'];
        
        Campaign campaign;
        campaign = TestDataFactory_Campaign.generateCampaign();
        campaign.OwnerId = agentUser.Id;
        campaign.Name = 'TestCampaign_2B';
        campaign.Selected_Journey_Start_Date__c = Date.today()-1;
        campaign.RecordTypeId = [Select id from RecordType where DeveloperName='Customer_Prospect_Campaign'].id;
        campaign = TestDataFactory_Campaign.insertCampaign(campaign);

        List<Journey__c> journeyList=new List<Journey__c>();
        journeyList.add(TestDataFactory_Journey.buildCustomerProspectJourneyRecord(12345,'0'));
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
                journeyStepList.add(TestDataFactory_Journey.buildJourneyStepsRecord(journeyStringValues));
            }
        }
        insert journeyStepList; 
    }
   
// test method to query the Journeys
    @isTest
    private static void testQueryJourneysCustomerProspectType(){
        User agentUser = [Select Id,Servicing_Agent_Associate_ID__c,UserExternalID__c from User where UserExternalID__c = 'OOOO111122B'];
        List<Journey__c> journeyList;
        Test.startTest();
        System.runAs(agentUser){
            journeyList = StartJourneyController.queryJourneys(date.today(), 'Customer_Prospect_Campaign');
        }
        Test.stopTest();
        System.assertEquals(1, journeyList.size(),'Journey List Size should be 1');
    }

    @isTest
    private static void testCaculateJourneyTotalCostAndDeliveryType(){
        User agentUser = [Select Id,Servicing_Agent_Associate_ID__c,UserExternalID__c from User where UserExternalID__c = 'OOOO111122B'];
        Journey__c journeyRecord = [Select Id from Journey__c where JourneyName__c='JourneyName12345'];
        Double totalMembers = 10.0;
        Double expectedTotalCost = (0.28 * 3) * 10;
        StartJourneyController.JourneyPreviewData journeyPreviewData;
        Date calculatedStartDate = Date.today();
        Date stepDate = Date.today()+10;
        
        //StartJourneyController.JourneyStepPreviewDetails journeyStepPreviewDetail;
        Test.startTest();
        System.runAs(agentUser){
            journeyPreviewData = StartJourneyController.retrieveJourneyPreviewData(journeyRecord.Id, totalMembers, calculatedStartDate);
        }
        Test.stopTest();
        System.assertEquals(3, journeyPreviewData.journeyStepList.size(),'Journey Step List Size should be 3');
        System.assertEquals(expectedTotalCost, journeyPreviewData.totalCost,'Expected Total Cost value is'+expectedTotalCost+'but actual value is'+journeyPreviewData.totalCost);
        System.assertEquals(3, journeyPreviewData.journeyStepPreviewDetailsList.size(),'Details List size should be equal to 3');
        System.assertEquals('Mailing', journeyPreviewData.journeyStepPreviewDetailsList[1].contactMethod,'Expected Contact Method is Mailing, but actual value is'+journeyPreviewData.journeyStepPreviewDetailsList[1].contactMethod);
        System.assertEquals(stepDate, journeyPreviewData.journeyStepPreviewDetailsList[1].estimatedDate,'Expected Estimated Date is'+stepDate+'but actual value is'+journeyPreviewData.journeyStepPreviewDetailsList[1].estimatedDate);
        System.assertEquals(1.0, journeyPreviewData.journeyStepPreviewDetailsList[1].journeyStepId,'Journey Step Id should be 1.0');
        System.assertEquals('1st Class', journeyPreviewData.journeyStepPreviewDetailsList[1].deliveryType,'Expected Delivery Type is 1st Class, but actual value is'+journeyPreviewData.journeyStepPreviewDetailsList[1].deliveryType);
        System.assertEquals(0.28, journeyPreviewData.journeyStepPreviewDetailsList[1].stepCost,'Step Cost should be equal to 0.28');
        System.assertEquals(null, journeyPreviewData.journeyStepPreviewDetailsList[1].stepItemId,'Step Item Id should be empty');
        System.assertEquals(null, journeyPreviewData.journeyStepPreviewDetailsList[1].stepItemIdUrl,'Step Item Id Url should be empty');
    }
}