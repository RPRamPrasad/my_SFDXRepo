@IsTest(seeAllData=false)
public with sharing class HLPR_OpportunityTriggerMCJourney_Test {
    private static List<Account> accountList;
    private static List<Opportunity> opportunityRecordList;

    @TestSetup
    static void testSetupData(){                          
        List<User> userList = new List<User>();
        User agentUser = TestDataFactory_User_Wrapper.generateAgentUser('OO1A','OOOOTEST111');
        agentUser.UserExternalID__c = 'OOOOTEST111A';
        agentUser.UserType__c = 'Agent';
        agentUser.SubUserType__c = 'Agent';
        userList.add(agentUser);
                                                        
        User salesLeaderUser = TestDataFactory_User_Wrapper.generateSalesLeaderUser('OO1S','OOOOTEST111','OOOO111111T');
        salesLeaderUser.UserExternalID__c = 'OOOOTEST111S';
        userList.add(salesLeaderUser);

        User proxyUser = TestDataFactory_User_Wrapper.generateProxyUser('OO1AP','OOOOTEST111');
        proxyUser.UserExternalID__c = 'OOOOTEST111P';
        proxyUser.UserType__c = 'Agent Proxy';
        
        userList.add(proxyUser);
        insert userList;

        accountList = new List<Account>();
        for (Integer i=1;i<=3;i++){
            Account account = TestDataFactory_Account.createIndividualCustomer('TestAccName'+i);
            account.ClientIdentifier__c = 'OOCLIENTID'+i;
            account.BillingState = 'ME';
            accountList.add(account);
        } 
        TestDataFactory_Account.byPassAccountBeforeTrigger();
        accountList = TestDataFactory_Account.insertAccount(accountList);
        //createOpportunities(accountList);
    } 

    //method to build Opportunity record with Lob,Product
    private static void insertMarketingCloudTextPreferenceData(){
        CS_MarketingCloudTextPreference__c mctpref = new CS_MarketingCloudTextPreference__c();
        mctpref.Name='Maine';
        mctpref.EndTime__c=8;
        mctpref.startTime__c=21;
        mctpref.StateCode__c='ME';        
		mctpref.GMT_Difference__c=-5;
        mctpref.SkipSunday__c=false;
       // mctpref.Holiday__c=system.today().addDays(2);
        insert mctpref;
    }
    //method to build Opportunity record with Lob,Product
    private static void insertMCPreferenceData(Id accOwnerId,Boolean pref){
        List<MCPreference__c> mcPrefList = new List<MCPreference__c>();
        MCPreference__c mcpref1 = new MCPreference__c();
        mcpref1.Journey_Preference__c=pref;
        mcpref1.Agent_Office_ID__c=accOwnerId;
        mcpref1.Journey_Name__c='ILP_Journey';
        mcPrefList.add(mcpref1);
        MCPreference__c mcpref = new MCPreference__c();
        mcpref.Journey_Preference__c=TRUE;
        mcpref.Agent_Office_ID__c=accOwnerId;
        mcpref.Journey_Name__c='Allow_Texting_in_Journeys';
        mcPrefList.add(mcpref);
        insert mcPrefList;
    
    }
    /**
    * @method Test Opportunity Insert scenarios to set OptIn Value on the Opportunity.
    * @description   testOpportunityInsertSetOptIn
    */
    @isTest
    private static void testOpportunityInsertSetOptIn(){
        User proxyUser = [Select Id from User where UserExternalID__c='OOOOTEST111P'];
        accountList = [Select Id,Name,ClientIdentifier__c,Account.FirstName,Account.LastName from Account where ClientIdentifier__c IN ('OOCLIENTID1','OOCLIENTID2','OOCLIENTID3')];
        insertMCPreferenceData(proxyUser.Id,true);
        insertMarketingCloudTextPreferenceData();
        opportunityRecordList = new List<Opportunity>();
        for (Account acc: accountList){
            Opportunity opportunityRecord = TestDataFactory_Opportunity.generateOpportunity('TestMCOpp '+ acc.FirstName);
            opportunityRecord.AccountId = acc.Id;
            opportunityRecord.OwnerId = proxyUser.Id;
            opportunityRecord.StageName='Closed';
            opportunityRecord.LOB__c='Auto';
            opportunityRecord.OppClosedDateTime__c = DateTime.now();
            opportunityRecordList.add(opportunityRecord);
        }
        Test.startTest();
        insert opportunityRecordList;
        Test.stopTest();
        List<Opportunity> opportunityCreatedList = [Select Id,Text_Optin__c from Opportunity where OwnerId=:proxyUser.Id];
        List<MCPreference__c> mcPreferenceList = [Select Journey_Preference__c from MCPreference__c where Agent_Office_ID__c=:proxyUser.Id];
        for (Opportunity opportunityRecord: opportunityCreatedList){
            system.assertEquals(opportunityRecord.Text_Optin__c,TRUE,'Text Opt In match Journey preference');
        }
    } 
    /**
    * @method Test Opportunity Insert scenarios to set OptIn Value on the Opportunity as false.
    * @description   testOpportunityInsertSetOptInFalse
    */
    @isTest
    private static void testOpportunityInsertSetOptInFalse(){
        User proxyUser = [Select Id from User where UserExternalID__c='OOOOTEST111P'];
        accountList = [Select Id,Name,ClientIdentifier__c,Account.FirstName,Account.LastName from Account where ClientIdentifier__c IN ('OOCLIENTID1','OOCLIENTID2','OOCLIENTID3')];
        insertMCPreferenceData(proxyUser.Id,false);
        insertMarketingCloudTextPreferenceData();
        opportunityRecordList = new List<Opportunity>();
        for (Account acc: accountList){
            Opportunity opportunityRecord = TestDataFactory_Opportunity.generateOpportunity('TestMCOpp '+ acc.FirstName);
            opportunityRecord.AccountId = acc.Id;
            opportunityRecord.OwnerId = proxyUser.Id;
            opportunityRecord.StageName='Closed';
            opportunityRecord.LOB__c='Auto';
            opportunityRecord.OppClosedDateTime__c = DateTime.now();
            opportunityRecordList.add(opportunityRecord);
        }
        Test.startTest();
        insert opportunityRecordList;
        Test.stopTest();
        List<Opportunity> opportunityCreatedList = [Select Id,Text_Optin__c from Opportunity where OwnerId=:proxyUser.Id];
        List<MCPreference__c> mcPreferenceList = [Select Journey_Preference__c from MCPreference__c where Agent_Office_ID__c=:proxyUser.Id];
        for (Opportunity opportunityRecord: opportunityCreatedList){
            system.assertEquals(opportunityRecord.Text_Optin__c,false,'Text Opt In does not match Journey preference');
        }
    }
     /**
    * @method Test Opportunity Insert scenarios to set OptIn Value on the Opportunity.
    * @description   testOpportunityInsertSetDoNotAllowText
    */
    @isTest
    private static void testOpportunityInsertSetDoNotAllowText(){
        Boolean doNotAllowTextCheck = false;
        User proxyUser = [Select Id from User where UserExternalID__c='OOOOTEST111P'];
        accountList = [Select Id,Name,ClientIdentifier__c,Account.FirstName,Account.LastName from Account where ClientIdentifier__c IN ('OOCLIENTID1','OOCLIENTID2','OOCLIENTID3')];
        insertMCPreferenceData(proxyUser.Id,true);
        insertMarketingCloudTextPreferenceData();
        opportunityRecordList = new List<Opportunity>();
            Opportunity opportunityRecord = TestDataFactory_Opportunity.generateOpportunity('TestMCOpp '+ accountList[0].FirstName);
            opportunityRecord.AccountId = accountList[0].Id;
            opportunityRecord.OwnerId = proxyUser.Id;
            opportunityRecord.StageName='Closed';
            opportunityRecord.LOB__c='Auto';
            opportunityRecord.OppClosedDateTime__c = DateTime.now();
            opportunityRecordList.add(opportunityRecord);
          List<CS_MarketingCloudTextPreference__c> mcPreference = [Select StateCode__c,StartTime__c,Holiday__c,EndTime__c from CS_MarketingCloudTextPreference__c limit 1];
          mcPreference[0].StartTime__c = 8;
          mcPreference[0].EndTime__c = 21;
          update mcPreference;
        Test.startTest();
        insert opportunityRecordList;
        Test.stopTest();
        if(system.now().hour() < mcPreference[0].StartTime__c || system.now().hour() > mcPreference[0].EndTime__c)
        {
            doNotAllowTextCheck = true;
        }
        List<Opportunity> opportunityCreatedList = [Select Id,DONOT_ALLOW_TEXT__c from Opportunity where OwnerId=:proxyUser.Id];
        system.assertEquals(opportunityCreatedList[0].DONOT_ALLOW_TEXT__c,doNotAllowTextCheck,'Do Not Allow does not match MC preference');
    }

    /**
    * @method Test Opportunity Insert scenarios to set OptIn Value on the Opportunity.
    * @description   testOpportunityInsertSetDoNotAllowTextHoliday
    */
    @isTest
    private static void testOpportunityInsertSetDoNotAllowTextHoliday(){
        User proxyUser = [Select Id from User where UserExternalID__c='OOOOTEST111P'];
        accountList = [Select Id,Name,ClientIdentifier__c,Account.FirstName,Account.LastName from Account where ClientIdentifier__c IN ('OOCLIENTID1','OOCLIENTID2','OOCLIENTID3')];
        insertMCPreferenceData(proxyUser.Id,true);
        insertMarketingCloudTextPreferenceData();
        opportunityRecordList = new List<Opportunity>();
            Opportunity opportunityRecord = TestDataFactory_Opportunity.generateOpportunity('TestMCOpp '+ accountList[0].FirstName);
            opportunityRecord.AccountId = accountList[0].Id;
            opportunityRecord.OwnerId = proxyUser.Id;
            opportunityRecord.StageName='Closed';
            opportunityRecord.LOB__c='Auto';
            opportunityRecord.OppClosedDateTime__c = DateTime.now();
            opportunityRecordList.add(opportunityRecord);
          List<CS_MarketingCloudTextPreference__c> mcPreference = [Select StateCode__c,StartTime__c,Holiday__c,EndTime__c from CS_MarketingCloudTextPreference__c limit 1];
          mcPreference[0].StartTime__c = system.now().hour()+2;
          mcPreference[0].EndTime__c = system.now().hour()-2;
          mcPreference[0].Holiday__c = system.today();
          update mcPreference;
        
        Test.startTest();
        insert opportunityRecordList;
        Test.stopTest();
        List<Opportunity> opportunityCreatedList = [Select Id,DONOT_ALLOW_TEXT__c from Opportunity where OwnerId=:proxyUser.Id];
        system.assertEquals(opportunityCreatedList[0].DONOT_ALLOW_TEXT__c,true,'Do Not Allow does not match MC preference');
    }
}