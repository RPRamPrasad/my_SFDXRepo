/**************************************************************************************************************************************
Name: AP_StopJourney_TEST
=========================================================================================
* @description : Test class written for AP_StopJourney.
Team: ClubCar
=========================================================================================
VERSION     AUTHOR              DATE         DETAIL
1.0                                          Initial Development
2.0         Team TGV            06/20/2017   Removed all references to Message Orchestration as per feature E-26062
3.0         Team TGV            07/18/2017   Added new Test Method to test Stop Journey on Campaigns makes a callout to TP Webservice
4.0         Team ClubCar        08/22/2019   Removed Test methods testing Cancelled Campaign Messages and callout to TP Webservice
5.0         Team Incognito      19/08/2022   Remove duplicate code/Refactor
**************************************************************************************************************************************/

@isTest(SeeAllData = false)
public class AP_StopJourney_TEST {
    
    
    
    public static User sysAdminuser;
    public static User agentUser;
    public static User atmUser;
    public static User proxyUser;
    public static UserRole proxyStandardUserRole;
    public static UserRole agentStandardUserRole;
    public static UserRole agentTeamMemberUserRole;
    public static Map<String, Schema.Recordtypeinfo> campaignRecordTypeMap = Schema.Sobjecttype.Campaign.getRecordTypeInfosByName();
    private static User agent_User;
    
    /**
    * @method- setUpTriggerAndUserData
    * @description -  Setup method used for building test data
    */
    @testSetup
    private static void setUpTriggerAndUserData() {
        
        sysAdminuser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        System.runAs(sysAdminuser) {
            agentStandardUserRole= new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            agentTeamMemberUserRole = new UserRole(name= 'AgentTeamMemberRole', parentRoleId = agentStandardUserRole.id);
            insert agentTeamMemberUserRole;
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentTeamMemberUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='opportunityAg',Username='TestProxUserForOppTst11@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            Database.insert(proxyUser);
            User testAgentUser1 = new User(Alias='Alia',LastName='opportunityProxy',Username='TestAgtUserForOppTst11@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            agentUser.UserPermissionsMarketingUser = true;
            Database.insert(agentUser);
            atmUser = new User(alias = 'Alias', email='remCmpMemAgent1@statefarm.com.bad',
                               Associate_ID__c='124test', UserExternalID__c= '124test', Servicing_Agent_Associate_ID__c ='123test',
                               emailencodingkey='UTF-8', lastname='CmpMemProx', languagelocalekey='en_US', 
                               localesidkey='en_US', timezonesidkey='Europe/London', username= 'TestAtmUserForOppTst11@statefarm.com',userRoleId=agentTeamMemberUserRole.id);
            atmUser.ProfileId = UTIL_ProfileId_TEST.getATMProfileId();
            Database.insert(atmUser);
        }
    }
    
    /* @Refactor
    * @method- retriveUserData
    * @date modified - 19/08/2022
    * @description -   method used for building test data to re-euse in different methods.
    * @return - User
    */
    private static User retriveUserData(){
   
        agent_User = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'TestAgtUserForOppTst11@statefarm.com'];
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent_User);
        return  agent_User;
    }
    
    /**
    * @description -  test method to stop journey on campaign as an Agent User and check journey fields on campaign are updated to blank
    */
    @isTest
    private static void testStopJourneyOnCampaign(){
        Journey__c jny = new Journey__c();
        jny.JourneyName__c='TESTJRNY';
        jny.JourneyNumber__c ='1';
        jny.Journey_External_ID__c ='12345';
        jny.JourneyFundingID__c ='12345';
        Journey__c appliedJourney = buildJourneyRecord(jny);
        insert appliedJourney;        
        /* calling retriveUserData();
         * @Refactor
         */
        agentUser= retriveUserData();
        System.runas(agentUser){
            Campaign campaignBeforeStopJourney = buildCampaignRecord('CmpTestStartJourney', campaignRecordTypeMap.get('Lead Campaign').RecordTypeId);        
            insert campaignBeforeStopJourney;
            CampaignMessage__c  cmpMessage = new CampaignMessage__c (Campaign__c = campaignBeforeStopJourney.id, JourneyNumber__c = '1234',ContactMethodName__c = 'Mailing', Status__c = 'Scheduled', CampaignId__c = 'EXTCAMPAIGNID#2');
            insert cmpMessage;
            Task campJourneyTask = new Task (subject = 'campTask', WhatId = campaignBeforeStopJourney.id, ActivityDate = System.Today(), JourneyID__c = appliedJourney.id);
            insert campJourneyTask;
            List<Id> campaignIds = new List<Id>();
            campaignIds.add(campaignBeforeStopJourney.id);       
            Test.startTest();
            AP_StopJourney.stopJourneyFromlWC(campaignBeforeStopJourney.id);
            Test.stopTest();
            
            Campaign campaignAfterStopJourney = [select id, Journey_ID__c, Journey_Description__c, Journey_Name__c , Journey_Start_Date__c from Campaign where Id = :campaignBeforeStopJourney.id limit 1];
            Task taskAfterStopJourney = [Select id, Status from Task where JourneyId__c =:appliedJourney.id and Whatid =:campaignBeforeStopJourney.Id]; 
            //Verifying Journey fields on Campaign are updated as null
            System.assertEquals(null, campaignAfterStopJourney.Journey_ID__c, 'Journey Id was not erased');
            System.assertEquals(null, campaignAfterStopJourney.Journey_Description__c,'Journey desc was not erased');
            System.assertEquals(null, campaignAfterStopJourney.Journey_Name__c,'Journey Name was not erased');
            System.assertEquals(null, campaignAfterStopJourney.Journey_Start_Date__c,'Journey StartDate was not erased');
            System.assertEquals('Cancelled', taskAfterStopJourney.Status, 'Campaign task was not cancelled');
        }
    }

    
    /**
    * @description -  test method to stop journey on campaign as an Agent User and check journey fields on campaign are updated to blank from LWC Component.
    */
   @isTest
    private static void testStopJourneyOnCampaignFromLWC(){
        Journey__c jny = new Journey__c();
        jny.JourneyName__c='TESTJRNY';
        jny.JourneyNumber__c ='1';
        jny.Journey_External_ID__c ='12345';
        jny.JourneyFundingID__c ='12345';
        Journey__c appliedJourney = buildJourneyRecord(jny);
        insert appliedJourney;
        /* calling retriveUserData();
         * @Refactor
         */
        agentUser= retriveUserData();
        System.runas(agentUser){
            Campaign campaignBeforeStopJourney = buildCampaignRecord('CmpTestStartJourney', campaignRecordTypeMap.get('Lead Campaign').RecordTypeId);        
            insert campaignBeforeStopJourney;
            CampaignMessage__c  cmpMessage = new CampaignMessage__c (Campaign__c = campaignBeforeStopJourney.id, JourneyNumber__c = '1234', ContactMethodName__c = 'Mailing', Status__c = 'Scheduled', CampaignId__c = 'EXTCAMPAIGNID#2');
            insert cmpMessage;
            Task campJourneyTask = new Task (subject = 'campTask', WhatId = campaignBeforeStopJourney.id, ActivityDate = System.Today(), JourneyID__c = appliedJourney.id);
            insert campJourneyTask;   
            Test.startTest();
            AP_StopJourney.stopJourneyFromlWC(campaignBeforeStopJourney.id);
            Test.stopTest();
            
            Campaign campaignAfterStopJourney = [select id, Journey_ID__c, Journey_Description__c, Journey_Name__c , Journey_Start_Date__c from Campaign where Id = :campaignBeforeStopJourney.id limit 1];
            Task taskAfterStopJourney = [Select id, Status from Task where JourneyId__c =:appliedJourney.id and Whatid =:campaignBeforeStopJourney.Id]; 
            //Verifying Journey fields on Campaign are updated as null
            System.assertEquals(null, campaignAfterStopJourney.Journey_ID__c, 'Journey Id was not erased');
            System.assertEquals(null, campaignAfterStopJourney.Journey_Description__c,'Journey desc was not erased');
            System.assertEquals(null, campaignAfterStopJourney.Journey_Name__c,'Journey Name was not erased');
            System.assertEquals(null, campaignAfterStopJourney.Journey_Start_Date__c,'Journey StartDate was not erased');
            System.assertEquals('Cancelled', taskAfterStopJourney.Status, 'Campaign task was not cancelled');
       }
    }

    /**
    * @description -  test method to generate stop journey exception
    */
   @isTest
    private static void testStopJourneyOnCampaignForException(){
        /* calling retriveUserData();
         * @Refactor
         */
        agentUser= retriveUserData();
        
        System.runas(agentUser){
            Journey__c jny = new Journey__c(JourneyName__c='jny1',JourneyDescription__c='Jnydescription');
            insert jny;
            List<Id> campaignIds = new List<Id>();
            campaignIds.add(jny.Id);       
            Test.startTest();
            AP_StopJourney.stopJourneyFromlWC(jny.id);
            Test.stopTest();

            List<ExceptionLog__c> exceptionLogList = [Select Class__c,Exception_Message__c from ExceptionLog__c where Class__c='AP_StopJourney' order by createdDate desc limit 1];
            System.assert(exceptionLogList.get(0).Exception_Message__c != null,'No Exception Message');
        }
    }

    /**
    * @description -  test method to generate stop journey exception From LWC component.
    */
   @isTest
    private static void testStopJourneyOnCampaignForExceptionFromLWC(){
       /* calling retriveUserData();
         * @Refactor
         */
        agentUser= retriveUserData();
        
        System.runas(agentUser){
            Journey__c jny = new Journey__c(JourneyName__c='jny1',JourneyDescription__c='Jnydescription');
            insert jny;                  
            Test.startTest();
            AP_StopJourney.stopJourneyFromlWC(null);
            Test.stopTest();
            List<ExceptionLog__c> exceptionLogList = [Select Class__c,Exception_Message__c from ExceptionLog__c where Class__c='AP_StopJourney' order by createdDate desc limit 1];
            System.assert(exceptionLogList.get(0).Exception_Message__c != null,'No Exception Message');
        }
    }

    /**
    * @method - buildCampaignRecord
    * @description - method to build Campaign record with required parameters
    * @param campName : Campaign Name
    * @param campRecordTypeId : Campiagn Record Type Id
    * @return Campaign
    */
    private static Campaign buildCampaignRecord(String campName, Id campRecordTypeId) {
        Campaign campRecord = new Campaign(Name = campName, RecordTypeId = campRecordTypeId, Journey_ID__c = '12345', Journey_Description__c ='TESTDESC',
                                           Journey_Name__c = 'TESTJRNY', Journey_Start_Date__c = System.Today());
        return campRecord;
    }

    /**
    * @method   buildJourneyRecord  
    * @description - method used to build Journey record with required parameters
    * @param sampleJny
    * @return Journey__c  
    */
    private static Journey__c buildJourneyRecord(Journey__c sampleJny) {
        Journey__c jny = new Journey__c(JourneyName__c=sampleJny.JourneyName__c, Journey_External_ID__c =sampleJny.Journey_External_ID__c,BusinessLineCode__c = 'Auto',CategoryName__c = 'prospect customers',
                                        JourneyDescription__c='Jnydescription', VendorCode__c= 0, JourneyNumber__c = sampleJny.JourneyNumber__c, 
                                        CreatorRoleCode__c = 'C', CustomDemographicsInd__c = true, JourneyFundingID__c = sampleJny.JourneyFundingID__c);
        return jny;
    }
}