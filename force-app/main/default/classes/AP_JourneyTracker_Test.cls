/****************************************************************************************
Name: AP_JounreyTracker_TEST
Copyright © State Farm
=========================================================================================
* @description : Test class written for code coverage for AP_JourneyTracker class
Team: TrailBlazers
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Rajani Amballa (DTLA)     02/14/2018             Initial Development
2.0             ClubCar                   11/16/2018             Fixed and Added test method to cover updated MOA Design
2.0             ClubCar                   02/26/2020             Fixed PMD scan issues 
3.0 			Incognito				  08/29/2022			 Refactor fixes
******************************************************************************************/
@IsTest(SeeAllData = false)
public with sharing class AP_JourneyTracker_Test {
    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static UserRole agentTeamMemberUserRole;
    private static UserRole proxyStandardUserRoleA;
    private static UserRole agentStandardUserRoleA;
    private static UserRole agentTeamMemberUserRoleA;
    private static User agentUserA;    
    private static User atmUserA;
    private static User proxyUserA;
    private static User agentUserDupForOfficeA;
    //To get the Recordtype of opportunity
    private static Map<String, Schema.Recordtypeinfo> opportunityRecordTypeMap = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName();
    
    /**
    * @description Setup method used for building test data (must be called at beginning of test)
    * @name-  setUpTriggerAndUserData
    */
    @TestSetup
    private static void setUpTriggerAndUserData() {

        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();  
        insert systemUser;
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c(Override_All__c= false);
        insert objectBasedByPassTrigger;
        CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
        insert accountByPassTrigger;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);            
        insert sysAdminUserIdSetting;
        CS001_ByPassTriggerGtoZ__c oppByPassTrigger = new CS001_ByPassTriggerGtoZ__c(Override_OppBeforeInsert__c=false);
        insert oppByPassTrigger;
        sysAdminuser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        
        System.runAs(sysAdminuser) {
            agentStandardUserRole= new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            agentTeamMemberUserRole = new UserRole(name= 'AgentTeamMemberRole', parentRoleId = agentStandardUserRole.id);
            insert agentTeamMemberUserRole;
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentTeamMemberUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='OpportunityProxy',Username='TestProxUserForOppTst11@statefarm.com',UserExternalID__c='AVVAGENT000P',Servicing_Agent_Associate_ID__c='AVVAGENT000');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            Database.insert(proxyUser);
            User testAgentUser1 = new User(Alias='Test',LastName='OpportunityAgent',Username='TestAgtUserForOppTst11@statefarm.com',Associate_ID__c='AVVAGENT000',UserExternalID__c='AVVAGENT000_AVVAGENT000',Servicing_Agent_Associate_ID__c='AVVAGENT000');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser.SubUserType__c = 'Agent';
            agentUser.userRoleId= agentStandardUserRole.id;
            Database.insert(agentUser);
            atmUser = new User(alias = 'Alias', email='remCmpMemAgent1@statefarm.com.bad',
                               Associate_ID__c='124test', UserExternalID__c= '124test', Servicing_Agent_Associate_ID__c ='AVVAGENT000',
                               emailencodingkey='UTF-8', lastname='CmpMemProx', languagelocalekey='en_US', 
                               localesidkey='en_US', timezonesidkey='Europe/London', username= 'TestAtmUserForOppTst11@statefarm.com',userRoleId=agentTeamMemberUserRole.id);
            atmUser.ProfileId = UTIL_ProfileId_TEST.getATMProfileId();
            Database.insert(atmUser);
            setUpMOA();
        }
    }

    /**
    * @description Test data setup for MOA scenario
    *               agenttUser and agenttUserA have two seperate offices. AgentUser works for both offices
    *               agentUserDupForOfficeA is the duplicate user for agenttUser that will service agenttUserA office 
    */
    private static void setUpMOA () {
        //Setup Office 2 
        agentStandardUserRoleA= new UserRole(name='AgenttRoleA');                    
        insert agentStandardUserRoleA;
        proxyStandardUserRoleA = new UserRole(name='ProxxyRoleA', parentRoleId = agentStandardUserRoleA.id);
        insert proxyStandardUserRoleA;
        User testAgentUser1 = new User(Alias='Alia',LastName='opportunityProxyA',Username='TestAgtUserForOppTest44@statefarm.com',Associate_ID__c='RAVVAGNT000',UserExternalID__c='RAVVAGNT000_RAVVAGNT000',Servicing_Agent_Associate_ID__c='RAVVAGNT000');
        agentUserA = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        agentUserA.userRoleId= agentStandardUserRoleA.id;
        agentUserA.SubUserType__c = 'Agent';
        insert agentUserA;
        User testProxyUser1 = new User(Alias='Prob',LastName='opportunityAg',Username='TestProxUserForOppTest44@statefarm.com',UserExternalID__c='RAVVAGNT000P',Servicing_Agent_Associate_ID__c='RAVVAGNT000');
        proxyUserA = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
        proxyUserA.userRoleId= proxyStandardUserRoleA.id;
        insert proxyUserA;

        // Create Duplicate user for office 1 that will service office 2
        testAgentUser1 = new User(Alias='Alia',LastName='opportunityProxyB',Username='TestAgtUserrForOppTest49@statefarm.com',Associate_ID__c='AVVAGENT000',UserExternalID__c='AVVAGENT000_RAVVAGNT000',Servicing_Agent_Associate_ID__c='RAVVAGNT000');   
        agentUserDupForOfficeA = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        agentUserDupForOfficeA.userRoleId= agentStandardUserRoleA.id;
        agentUserDupForOfficeA.SubUserType__c = 'Agent';
        insert agentUserDupForOfficeA;
    }

    
    //method to build Account record with the given parameter value
    private static Account buildAccountRecord(String paramClientIdentifier) {
        Account act = new Account(Edit_In_VFP__c=true,FirstName = 'TESTFIRST', LastName = 'TESTLast', ClientIdentifier__c = paramClientIdentifier);
        return act;
    }
    
    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String paramAccountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = userInfo.getUserId(), Customer__c = paramAccountId);
        return agentRole;
    }

    private static Case getTestCase(Id caseId) {
        return [SELECT Id, CaseNumber, OwnerId, AccountId, Account.Name, JourneyName__c, JourneyID__c, LOB__c FROM Case WHERE id =:caseId];
    }


    private static Journey__c createTestJourney() {
        Journey__c journey = new Journey__c();
        journey.Journey_External_ID__c = 'EXTJOURNEYID';
        journey.JourneyName__c = 'Email-Text-and-Call-Journey';
        journey.JourneyNumber__c = 'JOURNEY#1';
        journey.VendorCode__c = 12345;
        journey.JourneyDescription__c= 'jnydescription';
        insert journey;
        return journey;
    }

    private static Opportunity createTestOpportunity(Account account, Journey__c journey) {
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Journey_ID__c = journey.Journey_External_ID__c;
        opportunity.Name = 'TESTOPPTRACKING';
        opportunity.LOB__c = 'AUTO';
        opportunity.Journey_Name__c = journey.JourneyName__c;
        opportunity.RecordTypeId = getDefaultOpportunityRecordTypeId();
        opportunity.StageName = 'New';
        opportunity.CloseDate = Date.today().addDays(30);
        opportunity.EventCode__c = 'P04567';
        User queryProxyUser = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com'];
        opportunity.OwnerId = queryProxyUser.Id;
        insert opportunity;    
        return opportunity;
    }
    
    private static Campaign createTestCampaign(Journey__c journey) {
        Campaign campaign = new Campaign();
        campaign.RecordTypeId = getLeadCampaignRecordTypeId();
        campaign.Name = '2018 New Auto Rates Campaign';
        campaign.Journey_ID__c = journey.Journey_External_ID__c;
        campaign.Journey_Name__c = journey.JourneyName__c;
        campaign.External_Campaign_ID__c = 'EXTCAMPAIGNID';
        User queryProxyUser = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com'];
        campaign.OwnerId = queryProxyUser.Id;
        insert campaign;
        return campaign;
    }

    private static Case createTestCase(Account account, Journey__c journey) {
        Case aCase = new Case();
        aCase.AccountId = account.Id;
        aCase.JourneyID__c = journey.Journey_External_ID__c;
        aCase.JourneyName__c = journey.JourneyName__c;
        aCase.LOB__c = 'Auto';
        User queryProxyUser = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com'];
        aCase.OwnerId = queryProxyUser.Id;
        insert aCase;
        return aCase;
    }

    private static void createBypassTriggerForCampaignAfterInsert() {               
        CS001_ByPassTriggerAtoF__c bypassTriggerAtoF = new CS001_ByPassTriggerAtoF__c();
        bypassTriggerAtoF.Override_CampaignAfterInsert__c = true;
        bypassTriggerAtoF.SetupOwnerId = agentUser.id;
        insert bypassTriggerAtoF;
    }
    
    private static ID getLeadCampaignRecordTypeId() {
        Schema.RecordTypeInfo recordType = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Lead Campaign');
        return recordType.getRecordTypeId();
    }

    private static ID getDefaultOpportunityRecordTypeId() {
        Schema.RecordTypeInfo recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity Management');
        return recordType.getRecordTypeId();
    }
       private static List<Campaign_Journey_Tracking__c> getCampaignJourneyTrackingRecord() {
        return [SELECT Id, Name, CreatedBy.name, CreatedBy.FirstName, CreatedBy.LastName, CreatedDate, AgentAlias__c, OwnerId, ActionDate__c, ActionTakenBy__c, 
                ActionType__c, Campaign__c, CampaignName__c, ExternalCampaignID__c, Agent__c, JourneyExternalID__c FROM Campaign_Journey_Tracking__c];
    }
    
    private static List<Opportunity_Journey_Tracking__c> getOpportunityJourneyTrackingRecord() {
        return [SELECT Id, Name, CreatedBy.Name, CreatedBy.FirstName, CreatedBy.LastName, CreatedDate, AgentAlias__c, OwnerId, ActionDate__c, ActionTakenBy__c, 
                ActionType__c, Opportunity__c, OpportunityName__c, JourneyExternalID__c, LOB__c, AccountName__c, Agent__c, EventCode__c 
                FROM Opportunity_Journey_Tracking__c];
    }
    
    private static List<CaseJourneyTracking__c> getCaseJourneyTrackingRecords() {
        return [SELECT Id, Name, CreatedBy.name, CreatedBy.FirstName, CreatedBy.LastName, CreatedDate, OwnerId, AccountName__c, ActionDate__c, ActionTakenBy__c,
                ActionType__c, AgentAlias__c, Agent__c, Case__c, JourneyExternalID__c, LOB__c FROM CaseJourneyTracking__c];
    }

    private static Opportunity getTestOpportunity() {
        return [SELECT Id, AccountId, Name,Credit_Status__c, Account.Name, LOB__c, Journey_Name__c, AgentAlias__c, Journey_ID__c, OwnerId, EventCode__c 
                FROM Opportunity WHERE Name = 'TESTOPPTRACKING'];    
    }
    
    private static Campaign getTestCampaign() {
        return [SELECT Id, Name, Journey_Name__c, External_Campaign_ID__c, Journey_ID__c, OwnerId FROM Campaign 
                WHERE External_Campaign_ID__c = 'EXTCAMPAIGNID'];    
    }
    /* @Refactor
    * @method- getUser
    * @date modified - 29/08/2022
    * @description -   method used for building test data to re-euse in different methods.
    * @return - User
    */
    private static User getUser(){
        
        User queryAgent = [Select id, Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'TestAgtUserForOppTst11@statefarm.com'];
        agentUser= queryAgent;
        Account testAccount;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            testAccount= buildAccountRecord('1213121');
            insert testAccount;            
        }
        return agentUser;
    }
     /* @Refactor
    * @method- getAccount
    * @date modified - 29/08/2022
    * @description -   method used for building test data to re-euse in different methods.
    * @return - Account
    */
    private static Account getAccount(id agentUser){
        Account testAccount = [select id, Name, firstname, LastName, ownerId from Account where CreatedbyId =:agentUser];    
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser);
        insert newAgentRole;
        return testAccount;
    }

    // test method to verify Opportunity Journey Tracking record is created on Start Journey operation
    @isTest
    private static void testOpportunityStartJourneyTrackingRecordCreate() {
        String startJourneyActionType = 'Journey Started';
        agentUser =  getUser();
        Account testAccount = getAccount(agentUser.id);
        System.runAs(agentUser) { 
            Journey__c journey = createTestJourney();
            Opportunity testOpportunity = createTestOpportunity(testAccount, journey);
            testOpportunity = getTestOpportunity();
            Test.starttest();         
            AP_JourneyTracker.trackOpportunityJourney(startJourneyActionType, new List<Opportunity>{testOpportunity});
            Test.stoptest();

            List<Opportunity_Journey_Tracking__c> insertedOJTRs = getOpportunityJourneyTrackingRecord();
            System.assert(insertedOJTRs.size() == 1,'Inserted Opportunity Journey Tracking Size is not equal to One');
            Opportunity_Journey_Tracking__c insertedOJTR = insertedOJTRs.get(0);
            System.assertEquals('Email-Text-and-Call-Journey', insertedOJTR.Name, 'Unexpected OpportunityJourneyTrackingName');
            System.assertEquals(insertedOJTR.CreatedBy.Name, insertedOJTR.ActionTakenBy__c, 'Unexpected User performed action');
            System.assertEquals(insertedOJTR.CreatedDate, insertedOJTR.ActionDate__c, 'Unexpected ActionDate');
            System.assertEquals(startJourneyActionType, insertedOJTR.ActionType__c, 'Unexpected ActionType');
            System.assertEquals('TESTOPPTRACKING', insertedOJTR.OpportunityName__c, 'Unexpected OpportuntiyName');
            System.assertEquals('EXTJOURNEYID', insertedOJTR.JourneyExternalID__c, 'Unexpected JourneyExternalId');
            System.assertEquals(testOpportunity.Id, insertedOJTR.Opportunity__c, 'Unexpected Opportunity Record');
            System.assertEquals('Auto', insertedOJTR.LOB__c, 'Unexpected LineofBusiness');
            System.assertEquals('P04567', insertedOJTR.EventCode__c, 'Unexpected EventCode');
            System.assertEquals(agentUser.Id, insertedOJTR.Agent__c, 'Unexpected Agent');
            System.assertEquals(testOpportunity.OwnerId, insertedOJTR.OwnerId, 'Unexpected OwnerId');
            System.assertEquals(agentUser.Alias, insertedOJTR.AgentAlias__c, 'Unexpected AgentAlias');
        }
        }

    // test method to verify Opportunity Journey Tracking record is created on Stop Journey operation
    @isTest
    private static void testOpportunityStopJourneyTrackingRecordCreate() {
        String stopJourneyActionType = 'Journey Stopped';
       agentUser =  getUser();
        Account testAccount = getAccount(agentUser.id);
        System.runAs(agentUser) { 
            Journey__c journey = createTestJourney();
            Opportunity testOpportunity = createTestOpportunity(testAccount, journey);
            testOpportunity = getTestOpportunity();
            Test.starttest();         
            AP_JourneyTracker.trackOpportunityJourney(stopJourneyActionType, new List<Opportunity>{testOpportunity});
            Test.stoptest();
                    
            List<Opportunity_Journey_Tracking__c> insertedOJTRs = getOpportunityJourneyTrackingRecord();
            System.assert(insertedOJTRs.size() == 1,'Inserted Opportunity Journey Tracking Size is not equal to One');
            Opportunity_Journey_Tracking__c insertedOJTR = insertedOJTRs.get(0);
            System.assertEquals('Email-Text-and-Call-Journey', insertedOJTR.Name, 'Unexpected OpportunityJourneyTrackingName');
            System.assertEquals(insertedOJTR.CreatedBy.Name, insertedOJTR.ActionTakenBy__c, 'Unexpected User performed action');
            System.assertEquals(insertedOJTR.CreatedDate, insertedOJTR.ActionDate__c, 'Unexpected ActionDate');
            System.assertEquals(stopJourneyActionType, insertedOJTR.ActionType__c, 'Unexpected ActionType');
            System.assertEquals('TESTOPPTRACKING', insertedOJTR.OpportunityName__c, 'Unexpected OpportuntiyName');
            System.assertEquals('EXTJOURNEYID', insertedOJTR.JourneyExternalID__c, 'Unexpected JourneyExternalId');
            System.assertEquals(testOpportunity.Id, insertedOJTR.Opportunity__c, 'Unexpected Opportunity Record');
            System.assertEquals('Auto', insertedOJTR.LOB__c, 'Unexpected LineofBusiness');
            System.assertEquals('P04567', insertedOJTR.EventCode__c, 'Unexpected EventCode');
            System.assertEquals(agentUser.Id, insertedOJTR.Agent__c, 'Unexpected Agent');
            System.assertEquals(testOpportunity.OwnerId, insertedOJTR.OwnerId, 'Unexpected OwnerId');
            System.assertEquals(agentUser.Alias, insertedOJTR.AgentAlias__c, 'Unexpected AgentAlias');
        }
    }

    // test method to verify Opportunity Journey Tracking record is created when Opportunity status changes to RFC Granted
    @isTest
    private static void testOpportunityStartJourneyTrackingRecordCreateFromTrigger() {
        agentUser =  getUser();
        Account testAccount = getAccount(agentUser.id);
        System.runAs(agentUser) { 
            Journey__c journey = createTestJourney();
            Opportunity testOpportunity = createTestOpportunity(testAccount, journey);
            testOpportunity.Credit_Status__c = 'RFC Requested';
            update testOpportunity;

            Test.starttest();
                   testOpportunity.Credit_Status__c ='RFC Granted';
            testOpportunity.Journey_ID__c = null;         
            update testOpportunity;
            Test.stoptest();
                    
            List<Opportunity_Journey_Tracking__c> insertedOJTRs = getOpportunityJourneyTrackingRecord();
            System.assert(insertedOJTRs.size() == 1,'Inserted Opportunity Journey Tracking Size is not equal to One');
            Opportunity_Journey_Tracking__c insertedOJTR = insertedOJTRs.get(0);
            System.assertEquals('Email-Text-and-Call-Journey', insertedOJTR.Name, 'Unexpected OpportunityJourneyTrackingName');
            System.assertEquals(insertedOJTR.CreatedBy.Name, insertedOJTR.ActionTakenBy__c, 'Unexpected User performed action');
            System.assertEquals(insertedOJTR.CreatedDate, insertedOJTR.ActionDate__c, 'Unexpected ActionDate');
            System.assertEquals('Journey Stopped - RFC Granted', insertedOJTR.ActionType__c, 'Unexpected ActionType');
            System.assertEquals('TESTOPPTRACKING', insertedOJTR.OpportunityName__c, 'Unexpected OpportuntiyName');
            System.assertEquals('EXTJOURNEYID', insertedOJTR.JourneyExternalID__c, 'Unexpected JourneyExternalId');
            System.assertEquals(testOpportunity.Id, insertedOJTR.Opportunity__c, 'Unexpected Opportunity Record');
            System.assertEquals('Auto', insertedOJTR.LOB__c, 'Unexpected LineofBusiness');
            System.assertEquals('P04567', insertedOJTR.EventCode__c, 'Unexpected EventCode');
            System.assertEquals(agentUser.Id, insertedOJTR.Agent__c, 'Unexpected Agent');
            System.assertEquals(testOpportunity.OwnerId, insertedOJTR.OwnerId, 'Unexpected OwnerId');
            System.assertEquals(agentUser.Alias, insertedOJTR.AgentAlias__c, 'Unexpected AgentAlias');
        }
    }

    // test method to verify Opportunity Journey Tracking exception scenario
    @isTest
    private static void testOpportunityJourneyTrackingDMLException() {
        agentUser =  getUser();
        Account testAccount = getAccount(agentUser.id);
        System.runAs(agentUser) { 
            Journey__c journey = createTestJourney();
            Opportunity testOpportunity = createTestOpportunity(testAccount, journey);
        
            Test.starttest();
            try {
                AP_JourneyTracker.trackOpportunityJourney('Invalid Action Type', new List<Opportunity>{testOpportunity});    
            } catch(DMLException e) {                
                system.assert(e.getMessage() !=null, 'Exception not occured');   
            }
            Test.stoptest();
        }
        
        List<Opportunity_Journey_Tracking__c> insertedOJTRs = getOpportunityJourneyTrackingRecord();
        System.assert(insertedOJTRs.isEmpty(), 'OpportunityJourneyTrackingList is not Empty');
    }

    // test method to verify Case Journey Tracking record is created on Start Journey operation
    @isTest
    private static void testCaseStartJourneyTrackingRecordCreate() {
        String startJourneyActionType = 'Journey Started';
        agentUser =  getUser();
        Account testAccount = getAccount(agentUser.id);
        System.runAs(agentUser) { 
            Journey__c journey = createTestJourney();
            Case testCase = createTestCase(testAccount, journey);
            testCase = getTestCase(testCase.id);
            Test.starttest();         
            AP_JourneyTracker.trackCaseJourney(startJourneyActionType, new List<Case>{testCase});
            Test.stoptest();

        List<CaseJourneyTracking__c> insertedCJTRs = getCaseJourneyTrackingRecords();
        System.assert(insertedCJTRs.size() == 1, 'Unexpected CaseJourneyTrackingListSize');
        CaseJourneyTracking__c insertedCJTR = insertedCJTRs.get(0);
        System.assertEquals('Email-Text-and-Call-Journey', insertedCJTR.Name, 'Unexpected CaseJourneyTrackingName');
        System.assertEquals(testCase.OwnerId, insertedCJTR.OwnerId, 'Unexpected OwnerId');
        System.assertEquals(insertedCJTR.CreatedDate, insertedCJTR.ActionDate__c, 'Unexpected ActionDate');
        System.assertEquals(insertedCJTR.CreatedBy.Name, insertedCJTR.ActionTakenBy__c, 'Unexpected User Performed Action');
        System.assertEquals(startJourneyActionType, insertedCJTR.ActionType__c, 'Unexpected ActionType');
        System.assertEquals(agentUser.Alias, insertedCJTR.AgentAlias__c, 'Unexpected AgentAlias');
        System.assertEquals(agentUser.Id, insertedCJTR.Agent__c, 'Unexpected Agent');
        System.assertEquals(testCase.Id, insertedCJTR.Case__c, 'Unexpected CaseId');
        System.assertEquals('EXTJOURNEYID', insertedCJTR.JourneyExternalID__c, 'Unexpected JourneyExternalId');
        System.assertEquals('Auto', insertedCJTR.LOB__c, 'Unexpected LineofBusiness');
        }
    }

    // test method to verify Case Journey Tracking record is created on Stop Journey operation
    @isTest
    private static void testCaseStopJourneyTrackingRecordCreate() {
        String stopJourneyActionType = 'Journey Stopped';
        agentUser =  getUser();
        Account testAccount = getAccount(agentUser.id);
        System.runAs(agentUser) { 
            Journey__c journey = createTestJourney();
            Case testCase = createTestCase(testAccount, journey);
            testCase = getTestCase(testCase.id);
            Test.starttest();         
            AP_JourneyTracker.trackCaseJourney(stopJourneyActionType, new List<Case>{testCase});
            Test.stoptest();

        List<CaseJourneyTracking__c> insertedCJTRs = getCaseJourneyTrackingRecords();
        System.assert(insertedCJTRs.size() == 1, 'Unexpected CaseJourneyTrackingListSize');
        CaseJourneyTracking__c insertedCJTR = insertedCJTRs.get(0);
        System.assertEquals('Email-Text-and-Call-Journey', insertedCJTR.Name, 'Unexpected CaseJourneyTrackingName');
        System.assertEquals(testCase.OwnerId, insertedCJTR.OwnerId, 'Unexpected OwnerId');
        System.assertEquals(insertedCJTR.CreatedDate, insertedCJTR.ActionDate__c, 'Unexpected ActionDate');
        System.assertEquals(insertedCJTR.CreatedBy.Name, insertedCJTR.ActionTakenBy__c, 'Unexpected User Performed Action');
        System.assertEquals(stopJourneyActionType, insertedCJTR.ActionType__c, 'Unexpected ActionType');
        System.assertEquals(agentUser.Alias, insertedCJTR.AgentAlias__c, 'Unexpected AgentAlias');
        System.assertEquals(agentUser.Id, insertedCJTR.Agent__c, 'Unexpected Agent');
        System.assertEquals(testCase.Id, insertedCJTR.Case__c, 'Unexpected CaseId');
        System.assertEquals('EXTJOURNEYID', insertedCJTR.JourneyExternalID__c, 'Unexpected JourneyExternalId');
        System.assertEquals('Auto', insertedCJTR.LOB__c, 'Unexpected LineofBusiness');
        }
    }

    // test method to verify Case Journey Tracking exception
    @isTest
    private static void testCaseJourneyTrackingDMLException() {
        agentUser =  getUser();
        Account testAccount = getAccount(agentUser.id);
        System.runAs(agentUser) { 
            Journey__c journey = createTestJourney();
            Case testCase = createTestCase(testAccount, journey);
            testCase = getTestCase(testCase.id);        
            Test.starttest();
            try {
                AP_JourneyTracker.trackCaseJourney('Invalid Action Type', new List<Case>{testCase});    
            } catch(DMLException e) {                
                system.assert(e.getMessage() !=null, 'Exception not occured');   
            }
            Test.stoptest();
        }
        
        List<CaseJourneyTracking__c> insertedCJTRs = getCaseJourneyTrackingRecords();
        System.assert(insertedCJTRs.isEmpty(), 'CaseJourneyTrackingList is not Empty');
    }
// test method to verify Campaign Journey Tracking record is created with MOA setup
@isTest
private static void testMOA() {
    String stopJourneyActionType = 'Journey Stopped';
    //   setUpMOA();
        User queryAgent = [Select id, Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'TestAgtUserForOppTst11@statefarm.com'];
        agentUser= queryAgent;
        Campaign testCampaign;
        Journey__c journey;
        agentUserA = [select Id from User where Username='TestAgtUserForOppTest44@statefarm.com'];
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUserA);
        System.runAs(agentUserA) {
        createBypassTriggerForCampaignAfterInsert();
        journey = createTestJourney();
        testCampaign = createTestCampaign(journey);
        testCampaign = getTestCampaign();
        }

       //Perform Stop Journey as office 1's  Duplicate user for office 1     
       agentUserDupForOfficeA = [select Id from User where Username='TestAgtUserrForOppTest49@statefarm.com'];
       TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUserDupForOfficeA);
        System.runAs(agentUserDupForOfficeA) {
            Test.starttest();
            AP_JourneyTracker.trackCampaignJourney(stopJourneyActionType, new List<Campaign>{testCampaign});
            Test.stoptest();
        }         
        List<Campaign_Journey_Tracking__c> insertedCJTRs = [SELECT Id, Name, CreatedById, CreatedDate, AgentAlias__c, OwnerId, ActionDate__c, ActionTakenBy__c, ActionType__c, Campaign__c, 
                                                            CampaignName__c, ExternalCampaignID__c, Agent__c, JourneyExternalID__c FROM Campaign_Journey_Tracking__c where ActionType__c =: stopJourneyActionType];
        System.assert(insertedCJTRs.size() == 1, 'Unexpected CampaignJourneyTrackingListSize');
        Campaign_Journey_Tracking__c insertedCJTR = insertedCJTRs.get(0);
        System.AssertEquals('Email-Text-and-Call-Journey', insertedCJTR.Name, 'Unexpected CampaignJourneyTrackingName');
        System.AssertEquals(insertedCJTR.CreatedDate, insertedCJTR.ActionDate__c, 'Unexpected ActionDate');
        System.AssertEquals(stopJourneyActionType, insertedCJTR.ActionType__c, 'Unexpected Action Type');
        System.AssertEquals('2018 New Auto Rates Campaign', insertedCJTR.CampaignName__c, 'Unexpected Campaign Name');
        System.assertEquals('EXTCAMPAIGNID', insertedCJTR.ExternalCampaignID__c, 'Unexpected External CampaignId');
        System.assertEquals('EXTJOURNEYID', insertedCJTR.JourneyExternalID__c, 'Unexpected Journey External Id');
        System.assertEquals(testCampaign.Id, insertedCJTR.Campaign__c, 'Unexpected Campaign Id');
        System.assertEquals(testCampaign.OwnerId, insertedCJTR.OwnerId, 'Unexpected Owner Id');
        System.assertEquals(agentUserDupForOfficeA.Id, insertedCJTR.createdByid, 'Unexpected AgentId');
        //Agent Id should be office 2's Agent Id. since the stop Journey was performed for office 2
        System.assertEquals(agentUserA.Id, insertedCJTR.Agent__c, 'Unexpected AgentId');
    }
    
    //method to test campaign start journey tracking record creation after campaign start journey operation
    @isTest
    private static void testCampaignStartJourneyTrackingRecordCreate() {
        String startJourneyActionType = 'Journey Started';
        agentUser =  getUser();
        Campaign testCampaign;
        Journey__c journey;        
        System.runAs(agentUser) {
            createBypassTriggerForCampaignAfterInsert();
            journey = createTestJourney();
            testCampaign = createTestCampaign(journey);
            testCampaign = getTestCampaign();
            Test.starttest();
            AP_JourneyTracker.trackCampaignJourney(startJourneyActionType, new List<Campaign>{testCampaign});
            Test.stoptest();            
            
            List<Campaign_Journey_Tracking__c> insertedCJTRs = getCampaignJourneyTrackingRecord();
            System.assert(insertedCJTRs.size() == 1, 'Unexpected CampaignJourneyTrackingListSize');
            Campaign_Journey_Tracking__c insertedCJTR = insertedCJTRs.get(0);
            System.assertEquals('Email-Text-and-Call-Journey', insertedCJTR.Name, 'Unexpected CampaignJourneyTrackingName');
            System.assertEquals(insertedCJTR.CreatedBy.name, insertedCJTR.ActionTakenBy__c, 'Unexpected User Performed Action');
            System.assertEquals(insertedCJTR.CreatedDate, insertedCJTR.ActionDate__c, 'Unexpected ActionDate');
            System.assertEquals(startJourneyActionType, insertedCJTR.ActionType__c, 'Unexpected ActionType');
            System.assertEquals('2018 New Auto Rates Campaign', insertedCJTR.CampaignName__c, 'Unexpected CampaignName');
            System.assertEquals('EXTCAMPAIGNID', insertedCJTR.ExternalCampaignID__c, 'Unexpected ExternalCampaignId');
            System.assertEquals('EXTJOURNEYID', insertedCJTR.JourneyExternalID__c, 'Unexpected JourneyExternalId');
            System.assertEquals(testCampaign.Id, insertedCJTR.Campaign__c, 'Unexpected CampaignId');
            System.assertEquals(agentUser.Id, insertedCJTR.Agent__c, 'Unexpected Agent');
            System.assertEquals(testCampaign.OwnerId, insertedCJTR.OwnerId, 'Unexpected OwnerId');
            System.assertEquals(agentUser.Alias, insertedCJTR.AgentAlias__c, 'Unexpected AgentAlias');
        }
    }
    
    //method to test campaign stop journey tracking record creation after campaign stop journey operation
    @isTest
    private static void testCampaignStopJourneyTrackingRecordCreate() {
        String stopJourneyActionType = 'Journey Stopped';
       agentUser =  getUser();
        Campaign testCampaign;
        Journey__c journey;        
        System.runAs(agentUser) {
            createBypassTriggerForCampaignAfterInsert();
            journey = createTestJourney();
            testCampaign = createTestCampaign(journey);
            testCampaign = getTestCampaign();
            Test.starttest();
            AP_JourneyTracker.trackCampaignJourney(stopJourneyActionType, new List<Campaign>{testCampaign});
            Test.stoptest();
            List<Campaign_Journey_Tracking__c> insertedCJTRs = getCampaignJourneyTrackingRecord();
            System.assert(insertedCJTRs.size() == 1, 'Unexpected CampaignJourneyTrackingListSize');
            Campaign_Journey_Tracking__c insertedCJTR = insertedCJTRs.get(0);
            System.assertEquals('Email-Text-and-Call-Journey', insertedCJTR.Name, 'Unexpected CampaignJourneyTrackingName');
            System.assertEquals(insertedCJTR.CreatedBy.name, insertedCJTR.ActionTakenBy__c, 'Unexpected User Performed Action');
            System.assertEquals(insertedCJTR.CreatedDate, insertedCJTR.ActionDate__c, 'Unexpected ActionDate');
            System.assertEquals(stopJourneyActionType, insertedCJTR.ActionType__c, 'Unexpected ActionType');
            System.assertEquals('2018 New Auto Rates Campaign', insertedCJTR.CampaignName__c, 'Unexpected CampaignName');
            System.assertEquals('EXTCAMPAIGNID', insertedCJTR.ExternalCampaignID__c, 'Unexpected ExternalCampaignId');
            System.assertEquals('EXTJOURNEYID', insertedCJTR.JourneyExternalID__c, 'Unexpected JourneyExternalId');
            System.assertEquals(testCampaign.Id, insertedCJTR.Campaign__c, 'Unexpected CampaignId');
            System.assertEquals(agentUser.Id, insertedCJTR.Agent__c, 'Unexpected Agent');
            System.assertEquals(testCampaign.OwnerId, insertedCJTR.OwnerId, 'Unexpected OwnerId');
            System.assertEquals(agentUser.Alias, insertedCJTR.AgentAlias__c, 'Unexpected AgentAlias');
        }
    }
    
    //method to test campaign start journey tracking record creation from campaign insert trigger
    @isTest
    private static void testCampaignStartJourneyTrackingRecordCreateFromTrigger() {
        String startJourneyActionType = 'Journey Started';
          agentUser =  getUser();
        Campaign testCampaign;
        Journey__c journey;  
        System.runAs(agentUser) {
            journey = createTestJourney();            
            Test.starttest();
            testCampaign = createTestCampaign(journey);                    
            Test.stoptest();
            testCampaign = getTestCampaign(); 
            List<Campaign_Journey_Tracking__c> insertedCJTRs = getCampaignJourneyTrackingRecord();
            System.assert(insertedCJTRs.size() == 1, 'Unexpected CampaignJourneyTrackingListSize');
            Campaign_Journey_Tracking__c insertedCJTR = insertedCJTRs.get(0);
            System.assertEquals('Email-Text-and-Call-Journey', insertedCJTR.Name, 'Unexpected CampaignJourneyTrackingName');
            System.assertEquals(insertedCJTR.CreatedBy.name, insertedCJTR.ActionTakenBy__c, 'Unexpected User Performed Action');
            System.assertEquals(insertedCJTR.CreatedDate, insertedCJTR.ActionDate__c, 'Unexpected ActionDate');
            System.assertEquals(startJourneyActionType, insertedCJTR.ActionType__c, 'Unexpected ActionType');
            System.assertEquals('2018 New Auto Rates Campaign', insertedCJTR.CampaignName__c, 'Unexpected CampaignName');
            System.assertEquals('EXTCAMPAIGNID', insertedCJTR.ExternalCampaignID__c, 'Unexpected ExternalCampaignId');
            System.assertEquals('EXTJOURNEYID', insertedCJTR.JourneyExternalID__c, 'Unexpected JourneyExternalId');
            System.assertEquals(testCampaign.Id, insertedCJTR.Campaign__c, 'Unexpected CampaignId');
            System.assertEquals(agentUser.Id, insertedCJTR.Agent__c, 'Unexpected Agent');
            System.assertEquals(testCampaign.OwnerId, insertedCJTR.OwnerId, 'Unexpected OwnerId');
            System.assertEquals(agentUser.Alias, insertedCJTR.AgentAlias__c, 'Unexpected AgentAlias');
        }
    }
    
    //method to test exception when an invalid action type is passed 
    @isTest
    private static void testCampaignJourneyTrackingDMLException() {
        agentUser =  getUser();
        getAccount(agentUser.id);
        Campaign testCampaign;
        Journey__c journey;
        System.runAs(agentUser) {
            createBypassTriggerForCampaignAfterInsert();
            journey = createTestJourney();
            testCampaign = createTestCampaign(journey);
            testCampaign = getTestCampaign();           
            Test.starttest();
            try {
                AP_JourneyTracker.trackCampaignJourney('Invalid Action Type', new List<Campaign>{testCampaign});    
            } catch(DMLException e) {                
                system.assert(e.getMessage() !=null, 'Exception not occured');   
            }
            Test.stoptest();           
            
            List<Campaign_Journey_Tracking__c> insertedCJTRs = getCampaignJourneyTrackingRecord();
            System.assert(insertedCJTRs.isEmpty(), 'CampaignJourneyTrackingList is not Empty');
        }
    }
}
