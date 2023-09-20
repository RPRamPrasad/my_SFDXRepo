/**
* @name OppCalJrnyStartDate_Test
* @author Team ClubCar
* @createdDate 06/01/2021
* @description Apex unit testing for OppCalJrnyStartDate
*/
/*
VERSION         AUTHOR                  DATE                DETAIL
2.0            Team Incognito          09/06/2022           Team Incognito - Remove duplicate code /Refactor*/

//
@isTest(seeAllData=false)
public with sharing class OppCalJrnyStartDate_Test {
    private static List<Account> accountList;
    private static List<Opportunity> opportunityRecordList;
    private static List<Journey__c> journeyList;
    private static final String DATETIME_FORMAT_DAYOFWEEK = 'u';
    private static DateTime currentDateTime = DateTime.now();
    private static Date currentdate = System.Today();
    private static DateTime updatedDateTime;
    private static Date toBeUpdatedDate;
    private static Integer sunday = 7;
    private static Integer saturday = 6;
    private static Integer nextSunday = 14;
    private static Integer hourOfDayTwelve = 12;
    private static Integer days180 = 180;
    private static Integer daysZero = 0;
    private static Integer addOne = 1;
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
    
    /*private static void createJourney(){
        List<Journey__c> journeyList=new List<Journey__c>();
        Journey__c jour1 = TestDataFactory_Journey.buildCustomerProspectJourneyRecord(12345,'0');
        jour1.BusinessLineCode__c = 'General';
        jour1.Categoryname__c = 'Prospect Customers';
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
        opportunityRecordList.add(addOpportunity('TestReportOpp2','Auto','Motorcycle'));
        insert opportunityRecordList;

    }

    private static Date calculateOppStartDate() {            
 
        Integer dayOfWeek = Integer.valueOf(currentDateTime.format(DATETIME_FORMAT_DAYOFWEEK));
        Integer hourOfDay = Integer.valueOf(currentDateTime.hour());            
        if(dayOfWeek < saturday || (dayOfWeek == saturday && (hourOfDay < hourOfDayTwelve))) {
           updatedDateTime = currentDateTime.addDays(sunday - dayOfWeek);   //current week
        }
        else {
            updatedDateTime = currentDateTime.addDays(nextSunday - dayOfWeek); //next week
        }
        toBeUpdatedDate = updatedDateTime.date();
        return toBeUpdatedDate;            
    }
    //
    @isTest
    public static void testCalculateJourneyStartDateTypeStandard(){
        Date journeyStartDate;
        Date expectedStartDate= calculateOppStartDate();
        Journey__c journeyRecord = [Select Id from Journey__c where JourneyName__c='JourneyName12345'];
        journeyRecord.Type__c = 'Standard';
        update journeyRecord;
        List<Opportunity> opportunity_RecordList =[Select Id,createdDate,X_Date__c from Opportunity where 
                                                      LOB__c='Auto' AND Product__c = 'Artisan and Service Contractor Policy' limit 1];
        Test.startTest();
        journeyStartDate = OppCalJrnyStartDate.calculateJourneyStartDate(opportunity_RecordList[0], journeyRecord);
        Test.stopTest();
        system.assertEquals(expectedStartDate, journeyStartDate,'date not correct');
    }
    //
    @isTest
    public static void testCalculateJourneyStartDateTypeXdateNull(){
        Date journeyStartDate;
        Journey__c journeyRecord = [Select Id from Journey__c where JourneyName__c='JourneyName12345'];
        journeyRecord.Type__c = 'Xdate';
        update journeyRecord;
        List<Opportunity> opportunityRecordList =[Select Id,createdDate,X_Date__c from Opportunity where 
                                                      LOB__c='Auto' AND Product__c = 'Artisan and Service Contractor Policy' limit 1];
        Test.startTest();
        journeyStartDate = OppCalJrnyStartDate.calculateJourneyStartDate(opportunityRecordList[0], journeyRecord);
        Test.stopTest();
        system.assertEquals(opportunityRecordList[0].CreatedDate.date(),journeyStartDate,'JourneyStartDate is not oppCreated date');
    } 
    //
    @isTest
    public static void testCalXdateOppJourneyStartDateWithNull(){
        Date journeyStartDate;
        Journey__c journeyRecord = [Select Id,Type__c from Journey__c where JourneyName__c='JourneyName12345'];
        journeyRecord.Type__c = 'Xdate';
        update journeyRecord;
        Opportunity opportunityRecord =[Select Id,createdDate,X_Date__c from Opportunity where 
                                                      LOB__c='Auto' AND Product__c = 'Artisan and Service Contractor Policy' limit 1];
        opportunityRecord.X_Date__c = System.Today(); 
        update opportunityRecord;
        Test.startTest();
        journeyStartDate = OppCalJrnyStartDate.calXdateOppJourneyStartDate(opportunityRecord, 10);
        Test.stopTest();
        system.assertEquals(opportunityRecord.CreatedDate.date(),journeyStartDate,'JourneyStartDate is not oppCreated date');
        
        opportunityRecord.X_Date__c = System.Today()-2;
        update opportunityRecord;
         opportunityRecord =[Select Id,createdDate,X_Date__c from Opportunity where 
                                                      LOB__c='Auto' AND Product__c = 'Artisan and Service Contractor Policy' limit 1];
        journeyStartDate = OppCalJrnyStartDate.calXdateOppJourneyStartDate(opportunityRecord, 10);
        system.assertEquals(opportunityRecord.X_Date__c,journeyStartDate,'JourneyStartDate is not right');

        opportunityRecord.X_Date__c = System.Today()-15;
        update opportunityRecord;
         opportunityRecord =[Select Id,createdDate,X_Date__c from Opportunity where 
                                                      LOB__c='Auto' AND Product__c = 'Artisan and Service Contractor Policy' limit 1];
        
        journeyStartDate = OppCalJrnyStartDate.calXdateOppJourneyStartDate(opportunityRecord, 10);
        system.assertEquals(opportunityRecord.X_Date__c+180,journeyStartDate,'JourneyStartDate is not right');

        opportunityRecord.X_Date__c = System.Today()-180;
        update opportunityRecord;
         opportunityRecord =[Select Id,createdDate,X_Date__c from Opportunity where 
                                                      LOB__c='Auto' AND Product__c = 'Artisan and Service Contractor Policy' limit 1];
        
        journeyStartDate = OppCalJrnyStartDate.calXdateOppJourneyStartDate(opportunityRecord, 10);
        system.assertEquals(opportunityRecord.X_Date__c+180,journeyStartDate,'JourneyStartDate is not right');
        
    }
    //
    
}