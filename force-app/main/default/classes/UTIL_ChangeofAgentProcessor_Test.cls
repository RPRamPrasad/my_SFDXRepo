/**
@Author Loco Motivated
@Name UTIL_ChangeofAgentProcessor_Test
@CreateDate 04/25/2018
@description : This class contains unit tests for UTIL_ChangeofAgentProcessor Processor
@Version 1.0
*/
@isTest(SeeAllData = false)
public class UTIL_ChangeofAgentProcessor_Test {

    private static CS_StageOrchestration_Counts__c counts;
    private static CS001_ByPassTriggerAtoF__c campTriggerBypass;
    private static Account accRecord = new account(FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c='IAMCLIENT12');
    private static List<Contact> contactRecord;
    private static AgentRole__c[] agentRoleDeletion;
    private static AccountMessage__c accountMessgaeCreation;
    private static Task[] actualTaskList=new List<Task>();
    private static Task[] expectedTaskList=new List<Task>();
    private static Case[] expectedCaseList=new List<Case>();
    private static LeadMetrics__c leadMetricsCreation;
    private static Opportunity[] actualOpportunityList=new List<Opportunity>();
    private static CampaignMember testCampaignMember;
    private static ProductsServicedByMe__c productsServicedBeMe;
    private static String unitTestSetupUrl = 'unittest.statefarm.com';
    private static UTIL_ChangeofAgentProcessor_Wrapper agentProcWrap = new UTIL_ChangeofAgentProcessor_Wrapper();

    @TestSetup
    static void setupUserData() {
        agentProcWrap.noAccessProfileUser = UTIL_StageOrchestrationTestUtils.buildSystemRecordOwner('123e', 'RecordOwner','recowner@statefarm.com');
        agentProcWrap.noAccessProfileUser.UserExternalID__c='noAcces1';
        insert agentProcWrap.noAccessProfileUser;
        agentProcWrap.systemUser = UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');
        agentProcWrap.systemUser.UserExternalID__c='admin1';
        insert agentProcWrap.systemUser;
        agentProcWrap.testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','sf_crm_stageorch@statefarm.com');
        agentProcWrap.testAPIUser.UserExternalID__c='api1';
        insert agentProcWrap.testAPIUser;
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentProcWrap.testAPIUser.Id, 'CoreComponents_User_R');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentProcWrap.testAPIUser.Id, 'CustomerView_Support_ViewAll');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentProcWrap.testAPIUser.Id, 'CustomerView_ApexAura_Enabled');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentProcWrap.testAPIUser.Id, 'SPI_User');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentProcWrap.testAPIUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentProcWrap.testAPIUser.Id, 'SimpleConversation_Support_W');
        PermissionSetAssignment psassignment = UTIL_StageOrchestrationTestUtils.assignPSet(agentProcWrap.testAPIUser);
        insert psassignment;
        agentProcWrap.salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('C');
       
        agentProcWrap.salesRoleHierarchy1.agentOffice.LastName='Test, HCKS, 59-6789-Office';
        update agentProcWrap.salesRoleHierarchy1.agentOffice;
        agentProcWrap.salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('J');
        agentProcWrap.salesRoleHierarchy2.Agent.State_Agent_Code_List__c='59-6789';
        agentProcWrap.salesRoleHierarchy2.Agent.State_Agent_Code__c='59-6789';
        update agentProcWrap.salesRoleHierarchy2.Agent;
        agentProcWrap.salesRoleHierarchy2.agentOffice.firstName='Test';
        agentProcWrap.salesRoleHierarchy2.agentOffice.LastName='Test, HCKS, 59-6789-Office';
        update agentProcWrap.salesRoleHierarchy2.agentOffice;
        agentProcWrap.salesRoleHierarchy3 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('O');
        System.runAs(agentProcWrap.systemUser){
            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c = agentProcWrap.noAccessProfileUser.id);
            insert sysAdminUserIdSetting;
        }
    }

    private static void createCustomSettingForEnvironmentURLData () {
          CS_EnvironmentURLCustomSetting__c envCS = new CS_EnvironmentURLCustomSetting__c();
          envCS.name = 'ICP_TP_ENV';
          envCS.value__c = unitTestSetupUrl;
          insert envCS;
    }

    //get user data
    private static void getUsers(){
        List<User> usrlist = [SELECT Id, Username, Associate_ID__c,
        Proxy_External_ID__c, Servicing_Agent_Associate_ID__c,
        Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c,
        SubUserType__c FROM User where
        UserExternalID__c in('api1','admin1','noAcces1') order by UserExternalID__c ASC ];
        agentProcWrap.noAccessProfileUser = usrlist.get(2);
        agentProcWrap.systemUser = usrlist.get(0);
        agentProcWrap.testAPIUser = usrlist.get(1);
        agentProcWrap.salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        agentProcWrap.salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('J');
        agentProcWrap.salesRoleHierarchy3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('O');
    }

    @isTest
    static void testMethodforChangeofAgentProcessWithAllData(){
        getUsers();
        System.runAs(agentProcWrap.salesRoleHierarchy1.Agent)  {
            createCustomSettingForEnvironmentURLData();
            createChildRelatedData();
            createCases();
            createOpportunityTestData();
            createTasks();
            TaskBeforeTriggerHandler.isInsert = false;
            createProductServicedByMe();
        }

        insertStageOrch();

        System.runAs(agentProcWrap.salesRoleHierarchy1.Agent)  {
            account[] testAccountList=[Select id From account where id=:accRecord.Id];
            System.assert(testAccountList.isEmpty(), 'Account[] should be empty');
        }

        System.runAs(agentProcWrap.salesRoleHierarchy2.Agent)  {

            validateAccountAndOpp(accRecord);

            //Case assertion for changing the status which are not Closed to Closed
            List<Case> caseList = [select id,accountID,OwnerId,Description,status,createddate,Assigned_To__c  from Case where Id=:expectedCaseList];
            validateCases(caseList);

            //Task assertion for changing the status which are not completed to Removed From Book
            List<Task> taskList = [select id,WhatId,subject,OwnerId,Description,status,AssignedTo__c,createddate from task where WhatId=:actualOpportunityList];
            validateTasksForOpp(taskList);
        }

        validateAsSysRecOwnerExceptOpp(agentProcWrap.noAccessProfileUser);
    }

    @isTest
    static void testMethodforChangeofAgentProcessWithOutTaskData(){
        getUsers();
        createChildRelatedData();
        System.runAs(agentProcWrap.salesRoleHierarchy1.Agent)  {
            createCustomSettingForEnvironmentURLData();
            createCases();
            createOpportunityTestData();
            createProductServicedByMe();
        }

        insertStageOrch();
        validateLoosingAgentData(agentProcWrap.salesRoleHierarchy1.Agent);

        System.runAs(agentProcWrap.salesRoleHierarchy2.Agent)  {
            account[] testAccountList=[Select id From account where id=:accRecord.Id];
            System.assert(!testAccountList.isEmpty(), 'Account[] should not be empty');

            List<Case> caseList = [select id,accountID,OwnerId,Description,status,createddate,Assigned_To__c  from Case where Id=:expectedCaseList];
            validateCases(caseList);
        }

        validateAsSysRecOwnerData(agentProcWrap.noAccessProfileUser);
    }

    static void insertStageOrch(){
        StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        testStageOrchestration.TransactionType__c=UTIL_StageOrchestrationConstants.CHANGE_OF_AGENT_TRANSACTION;
        testStageOrchestration.VersionNumber__c=1.0;
        UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList buildJsonWrap = new UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList();

			buildJsonWrap.clientAccountId = 'IAMCLIENT12';
			buildJsonWrap.fromAssociateId = agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C;
			buildJsonWrap.diffAgentAssocId = agentProcWrap.salesRoleHierarchy3.Agent.Associate_ID__C;
			buildJsonWrap.newAgentAssocId = agentProcWrap.salesRoleHierarchy2.Agent.Associate_ID__C;
			buildJsonWrap.startDate1 = '2008-08-01';
			buildJsonWrap.startDate2 = string.valueOf(system.today());
		testStageOrchestration.Value__c=buildJsonString(buildJsonWrap);
        system.runAs(agentProcWrap.testAPIUser){
            test.startTest();
            insert testStageOrchestration;
            test.stopTest();
        }
    }

    @isTest
    static void testMethodforChangeofAgentProcessWithOutCaseData(){
        getUsers();
        createChildRelatedData();
        System.runAs(agentProcWrap.salesRoleHierarchy1.Agent)  {
            createCustomSettingForEnvironmentURLData();
            expectedTaskList.add(new Task (WhatId=accRecord.id, subject='Old createdDate1',Description='TASK111', status='Incomplete',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.Id));
            expectedTaskList.add(new Task (WhatId=accRecord.id, subject='Old createdDate2',Description='TASK222', status='Completed',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.Id));
            expectedTaskList.add(new Task (WhatId=accRecord.id, subject='Reassign Task1',Description='TASK333', status='InProgress',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.Id));
            expectedTaskList.add(new Task (WhatId=accRecord.id, subject='Reassign Task2',Description='TASK444', status='Completed',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.Id));
            insert expectedTaskList;
            Test.setCreatedDate(expectedTaskList.get(0).Id, system.today()-91);
            Test.setCreatedDate(expectedTaskList.get(1).Id, system.today()-98);

            createOpportunityTestData();
            createProductServicedByMe();
            TaskBeforeTriggerHandler.isInsert = false;

            System.assert(true, 'Mandatory Assert statement on Tests');
        }

        insertStageOrch();
        validateLoosingAgentData(agentProcWrap.salesRoleHierarchy1.Agent);
        System.runAs(agentProcWrap.salesRoleHierarchy2.Agent)  {
            validateAccountAndOpp(accRecord);
        }

        validateAsSysRecOwnerData(agentProcWrap.noAccessProfileUser);
    }

    @isTest
    static void testMethodforChangeofAgentProcessWithOutOpportunityData(){
        getUsers();
        createChildRelatedData();
        System.runAs(agentProcWrap.salesRoleHierarchy1.Agent)  {
            createCases();
            createTasks();
            createProductServicedByMe();
            TaskBeforeTriggerHandler.isInsert = false;
        }

        insertStageOrch();
        validateLoosingAgentData(agentProcWrap.salesRoleHierarchy1.Agent);
        System.runAs(agentProcWrap.salesRoleHierarchy2.Agent)  {
            account[] testAccountList=[Select id From account where id=:accRecord.Id];
            System.assert(!testAccountList.isEmpty(), 'Account[] should not be empty');
        }

        validateAsSysRecOwnerData(agentProcWrap.noAccessProfileUser);
    }

    @isTest
    static void testMethodforChangeofAgentProcessWithOutOtherRelatedData(){
        getUsers();
        counts= new CS_StageOrchestration_Counts__c(Retry_Count__c=3,Chunk_Size__c=5);
        System.runAs(agentProcWrap.systemUser)  {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            campTriggerBypass = new CS001_ByPassTriggerAtoF__c(Override_CampaignMemberAfterDelete__c=true,Override_CaseAfterInsert__c=true, Override_CaseBeforeInsert__c = true);
			insert campTriggerBypass;
            insert accRecord;
            insert counts;
            insert new AgentRole__c(customer__c=accRecord.id, agent__c=agentProcWrap.salesRoleHierarchy1.Agent.id,agentroleIdentifier__c=agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C+'~IAMCLIENT12');
        }

        System.runAs(agentProcWrap.salesRoleHierarchy1.Agent)  {
            createCustomSettingForEnvironmentURLData();
            createCases();
            createOpportunityTestData();
            createTasks();
            TaskBeforeTriggerHandler.isInsert = false;
        }

        insertStageOrch();
        System.runAs(agentProcWrap.salesRoleHierarchy1.Agent)  {
            account[] testAccountList=[Select id From account where id=:accRecord.Id];
            System.assert(testAccountList.isEmpty(), 'Account[] should be empty');
        }

        System.runAs(agentProcWrap.salesRoleHierarchy2.Agent)  {
            validateAccountAndOpp(accRecord);
        }
        validateAsSysRecOwnerData(agentProcWrap.noAccessProfileUser);
    }

    private static void validateAccountAndOpp(Account accRecord){
        account[] testAccountList=[Select id From account where id=:accRecord.Id];
            System.assert(!testAccountList.isEmpty(), 'Account[] should not be empty');

            opportunity[] oppForAgent2=[select State_Code__c,name,OwnerId,AccountId,StageName,description,CloseDate,Assigned_To__c,Transaction_Type__c,Transfer_Date__c from opportunity where AccountId=:accRecord.Id];
            validateOpportunities(oppForAgent2);
    }

    //method to test Planning Conversation Log Record for Change Of Agent on Different Start Date.
    @isTest
    private static void testMethodforChangeOfAgentForPlanningConversationLogForDiffStartDate() {
        getUsers();
        TestData_SalesRoleHierarchy salesRoleHierarchyForPlanConvLog1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('L');
        salesRoleHierarchyForPlanConvLog1.agentOffice.firstName='Test';
        salesRoleHierarchyForPlanConvLog1.agentOffice.LastName='Test, HCKS, 59-6789-Office';
        bypassAllTriggers();
        insertPlanningConv(salesRoleHierarchyForPlanConvLog1);

        Test.startTest();
        for(PlanningConversationLog__c planConvLogBefore: [Select id, ownerId from PlanningConversationLog__c]) {
            system.assertEquals(planConvLogBefore.ownerId, planConvLogBefore.ownerId, 'Expected owner id should be equal to the actual owner id');
        }

        System.runAs(agentProcWrap.testAPIUser) {
            List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.TransactionType__c = UTIL_StageOrchestrationConstants.CHANGE_OF_AGENT_TRANSACTION;
            testStageOrchestration.VersionNumber__c = 1.0;
            UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList buildWrap = new UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList();

			buildWrap.clientAccountId = 'IAMCLIENT12';
			buildWrap.fromAssociateId = salesRoleHierarchyForPlanConvLog1.Agent.Associate_ID__C;
			buildWrap.diffAgentAssocId = agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C;
			buildWrap.newAgentAssocId = agentProcWrap.salesRoleHierarchy2.Agent.Associate_ID__C;
			buildWrap.startDate1 = string.valueOf(system.today()-10);
			buildWrap.startDate2 = string.valueOf(system.today());
		testStageOrchestration.Value__c=buildJsonString(buildWrap);
            stgOrchList.add(testStageOrchestration);
            new UTIL_ChangeofAgentProcessor().execute(stgOrchList);
        }

        List<PlanningConversationLog__c> actualPlanConvListAfter = [Select id, ownerId from PlanningConversationLog__c];
        System.assertEquals(actualPlanConvListAfter.size(), 2, 'Size of List<PlanningConversationLog__c> should be equals to 2');

        for(PlanningConversationLog__c planConvLogRec: actualPlanConvListAfter) {
            system.assertEquals(planConvLogRec.ownerId, planConvLogRec.ownerId, 'Expected owner id should be equal to the actual owner id');
        }
        Test.stopTest();
    }

    private static void insertPlanningConv(TestData_SalesRoleHierarchy salesRoleHierarchyForPlanConvLog1){
        List<PlanningConversationLog__c> planConvLog = new List<PlanningConversationLog__c>();
        System.runAs(salesRoleHierarchyForPlanConvLog1.agent) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accRecord;
            AgentRole__c agentRole11 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchyForPlanConvLog1.Agent.Id, agentroleIdentifier__c = salesRoleHierarchyForPlanConvLog1.Agent.Associate_ID__c + '~' + accRecord.clientIdentifier__c);
            insert agentRole11;
        }

        System.runAs(agentProcWrap.systemUser) {
            planConvLog.add(new PlanningConversationLog__c (Account__c = accRecord.id, Comments__c = 'Test Comments1', Agent__c = salesRoleHierarchyForPlanConvLog1.agent.id, ownerId = salesRoleHierarchyForPlanConvLog1.agentOffice.id));
            planConvLog.add(new PlanningConversationLog__c (Account__c = accRecord.id, Comments__c = 'Test Comments2', Agent__c = salesRoleHierarchyForPlanConvLog1.agent.id, ownerId = salesRoleHierarchyForPlanConvLog1.agentOffice.id));
            insert planConvLog;
        }
    }

    private static void bypassAllTriggers(){
        System.runAs(agentProcWrap.systemUser) {
            CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
            insert passTriggerAll;
        }
    }

    //method to test Planning Conversation Log Record for Change Of Agent on Same Start Date.
    @isTest
    private static void testMethodforChangeOfAgentForPlanningConversationLogSameStartDate() {
        getUsers();
        TestData_SalesRoleHierarchy salesRoleHierarchyForPlanConvLog1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('P');
        bypassAllTriggers();

        insertPlanningConv(salesRoleHierarchyForPlanConvLog1);

        Test.startTest();
        for(PlanningConversationLog__c planConvLogBefore: [Select id, ownerId from PlanningConversationLog__c]) {
            system.assertEquals(salesRoleHierarchyForPlanConvLog1.agentOffice.id, planConvLogBefore.ownerId, 'The given two parameters are not equal');
        }

        System.runAs(agentProcWrap.testAPIUser) {
            List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.TransactionType__c = UTIL_StageOrchestrationConstants.CHANGE_OF_AGENT_TRANSACTION;
            testStageOrchestration.VersionNumber__c = 1.0;
            UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList jsonWrap = new UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList();

			jsonWrap.clientAccountId = 'IAMCLIENT12';
			jsonWrap.fromAssociateId = salesRoleHierarchyForPlanConvLog1.Agent.Associate_ID__C;
			jsonWrap.diffAgentAssocId = agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C;
			jsonWrap.newAgentAssocId = agentProcWrap.salesRoleHierarchy2.Agent.Associate_ID__C;
			jsonWrap.startDate1 = String.valueOf(system.today());
			jsonWrap.startDate2 = String.valueOf(system.today());
		testStageOrchestration.Value__c=buildJsonString(jsonWrap);
            stgOrchList.add(testStageOrchestration);
            new UTIL_ChangeofAgentProcessor().execute(stgOrchList);
        }

        List<PlanningConversationLog__c> actualPlanConvListAfter = [Select id, ownerId from PlanningConversationLog__c];
        System.assertEquals(actualPlanConvListAfter.size(), 2, 'Size of List<PlanningConversationLog__c> should be equals to 2');

        for(PlanningConversationLog__c planConvLogRec: actualPlanConvListAfter) {
            system.assertEquals(agentProcWrap.noAccessProfileUser.Id, planConvLogRec.ownerId, 'Expected id should be equals to the actual id');
        }
        Test.stopTest();
    }

    //method to test Simple Conversation Record for Change Of Agent on Different Start Date.
    @isTest
    private static void testMethodforChangeOfAgentForSimpleConversationForDiffStartDate() {
        getUsers();
        TestData_SalesRoleHierarchy salesRoleHierarchyForSimpleConv1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('K');
        salesRoleHierarchyForSimpleConv1.agentOffice.firstName='Test';
        salesRoleHierarchyForSimpleConv1.agentOffice.LastName='Test, HCKS, 59-6789-Office';
        System.runAs(agentProcWrap.systemUser) {
            CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c = true);
            insert passTriggerAll;
        }

        insertSimpConv(salesRoleHierarchyForSimpleConv1);
        Test.startTest();
        for(SimpleConversation__c simpleConvBefore: [Select id, ownerId,Account__c from SimpleConversation__c]) {
            system.assertEquals(salesRoleHierarchyForSimpleConv1.agentOffice.id, simpleConvBefore.ownerId, 'Expected id should be equals to the actual id');
        }

        System.runAs(agentProcWrap.testAPIUser) {
            List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.TransactionType__c = UTIL_StageOrchestrationConstants.CHANGE_OF_AGENT_TRANSACTION;
            testStageOrchestration.VersionNumber__c = 1.0;
            UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList jsonStringWrap = new UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList();

			jsonStringWrap.clientAccountId = 'IAMCLIENT12';
			jsonStringWrap.fromAssociateId = salesRoleHierarchyForSimpleConv1.Agent.Associate_ID__C;
			jsonStringWrap.diffAgentAssocId = agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C;
			jsonStringWrap.newAgentAssocId = agentProcWrap.salesRoleHierarchy2.Agent.Associate_ID__C;
			jsonStringWrap.startDate1 = string.valueOf(system.today()-10);
			jsonStringWrap.startDate2 = string.valueOf(system.today());
		testStageOrchestration.Value__c=buildJsonString(jsonStringWrap);
            stgOrchList.add(testStageOrchestration);
            new UTIL_ChangeofAgentProcessor().execute(stgOrchList);
        }

        List<SimpleConversation__c> actualSimpleConvListAfter = [Select id, ownerId,Account__c from SimpleConversation__c];
        System.assertEquals(actualSimpleConvListAfter.size(), 2, 'Size of List<SimpleConversation__c> should be equals to 2');

        for(SimpleConversation__c simpleConvRec: actualSimpleConvListAfter) {
            system.assertEquals(simpleConvRec.ownerId, simpleConvRec.ownerId, 'Expected owner id should be equal to the actual owner id');
        }
        Test.stopTest();
    }

    private static void insertSimpConv(TestData_SalesRoleHierarchy salesRoleHierarchyForSimpleConv1){
        List<SimpleConversation__c> simpleConv = new List<SimpleConversation__c>();
        System.runAs(salesRoleHierarchyForSimpleConv1.agent) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accRecord;
            AgentRole__c agentRole11 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchyForSimpleConv1.Agent.Id, agentroleIdentifier__c = salesRoleHierarchyForSimpleConv1.Agent.Associate_ID__c + '~' + accRecord.clientIdentifier__c);
            insert agentRole11;
        }

        System.runAs(agentProcWrap.systemUser) {
            simpleConv.add(new SimpleConversation__c(SimpleConversationName__c = 'testSimple1', Account__c = accRecord.id, Agent__c = salesRoleHierarchyForSimpleConv1.agent.id, SimpleConversationType__c = 'Simple Conversation', ownerId = salesRoleHierarchyForSimpleConv1.agentOffice.id, Status__c = 'New'));
            simpleConv.add(new SimpleConversation__c(SimpleConversationName__c = 'testSimple2', Account__c = accRecord.id, Agent__c = salesRoleHierarchyForSimpleConv1.agent.id, SimpleConversationType__c = 'Simple Conversation', ownerId = salesRoleHierarchyForSimpleConv1.agentOffice.id, Status__c = 'New'));
            insert simpleConv;
        }
    }

    //method to test Simple Conversation Record for Change Of Agent on Same Start Date.
    @isTest
    private static void testMethodForChangeOfAgentForSimpleConversationSameStartDate() {
        getUsers();
        TestData_SalesRoleHierarchy salesRoleHierarchyForSimpleConv1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('Q');
        bypassAllTriggers();

        insertSimpConv(salesRoleHierarchyForSimpleConv1);

        Test.startTest();
        for(SimpleConversation__c simpleConvBefore: [Select id, ownerId from SimpleConversation__c]) {
            system.assertEquals(salesRoleHierarchyForSimpleConv1.agentOffice.id, simpleConvBefore.ownerId, 'Expected id should be equals to the actual id');
        }

        System.runAs(agentProcWrap.testAPIUser) {
            List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.TransactionType__c = UTIL_StageOrchestrationConstants.CHANGE_OF_AGENT_TRANSACTION;
            testStageOrchestration.VersionNumber__c = 1.0;
            UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList buildJsonStringWrap = new UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList();

			buildJsonStringWrap.clientAccountId = 'IAMCLIENT12';
			buildJsonStringWrap.fromAssociateId = salesRoleHierarchyForSimpleConv1.Agent.Associate_ID__C;
			buildJsonStringWrap.diffAgentAssocId = agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C;
			buildJsonStringWrap.newAgentAssocId = agentProcWrap.salesRoleHierarchy2.Agent.Associate_ID__C;
			buildJsonStringWrap.startDate1 = String.valueOf(system.today());
			buildJsonStringWrap.startDate2 = String.valueOf(system.today());
		testStageOrchestration.Value__c=buildJsonString(buildJsonStringWrap);
            stgOrchList.add(testStageOrchestration);
            new UTIL_ChangeofAgentProcessor().execute(stgOrchList);
        }

        List<SimpleConversation__c> actualSimpleConvListAfter = [Select id, ownerId from SimpleConversation__c];
        System.assertEquals(actualSimpleConvListAfter.size(), 2, 'Size of List<SimpleConversation__c> should be equals to 2');

        for(SimpleConversation__c simpleConvRec: actualSimpleConvListAfter) {
            system.assertEquals(agentProcWrap.noAccessProfileUser.Id, simpleConvRec.ownerId, 'Expected id should be equal to the actual id');
        }
        Test.stopTest();
    }

    @isTest
    static void testMethodforRemoveFromBookSenario(){
        getUsers();
        createChildRelatedData();

        System.runAs(agentProcWrap.salesRoleHierarchy1.Agent)  {
            createCases();
            createOpportunityTestData();
            createTasks();
            createProductServicedByMe();
        }

        StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        testStageOrchestration.TransactionType__c=UTIL_StageOrchestrationConstants.CHANGE_OF_AGENT_TRANSACTION;
        testStageOrchestration.VersionNumber__c=1.0;
        UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList buildStringWrap = new UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList();

			buildStringWrap.clientAccountId = 'IAMCLIENT12';
			buildStringWrap.fromAssociateId = agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C;
			buildStringWrap.diffAgentAssocId = agentProcWrap.salesRoleHierarchy3.Agent.Associate_ID__C;
			buildStringWrap.newAgentAssocId = agentProcWrap.salesRoleHierarchy2.Agent.Associate_ID__C;
			buildStringWrap.startDate1 = string.valueOf(system.today());
			buildStringWrap.startDate2 = string.valueOf(system.today());
		testStageOrchestration.Value__c=buildJsonString(buildStringWrap);
        system.runAs(agentProcWrap.testAPIUser){
            test.startTest();
            insert testStageOrchestration;
            test.stopTest();
        }
        validateLoosingAgentData(agentProcWrap.salesRoleHierarchy1.Agent);

        //Agent will not be able to see AgentRole__c,Task,opportunity,AccountMessage__c,CampaignMember that's why asserting in system mode
        agentRoleDeletion=[Select id From AgentRole__c where Customer__c=:accRecord.Id AND AgentRoleIdentifier__c=:agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C+'~IAMCLIENT12'];
        system.assert(agentRoleDeletion.isEmpty(), 'List<AgentRole__c> should be empty');
    }

    /*Give a change of agent process,
      When the winning agent is determined as invalid and retired once,
      Then the transaction shoud not be returned as remove from book.
    */
    @isTest
    static void testChangeOfAgentFailureScenarioWithSingleRetry() {
        getUsers();
        createChildRelatedData();

        StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        testStageOrchestration.TransactionType__c=UTIL_StageOrchestrationConstants.CHANGE_OF_AGENT_TRANSACTION;
        testStageOrchestration.VersionNumber__c=1.0;
        testStageOrchestration.ReprocessCount__c=1.0;
        UTIL_ChangeofAgentProcessor_Test.BuildJsonStringForSingleAgentWrapperList singleAgentWrap = new UTIL_ChangeofAgentProcessor_Test.BuildJsonStringForSingleAgentWrapperList();

			singleAgentWrap.clientAccountId = 'IAMCLIENT12';
			singleAgentWrap.fromAssociateId = agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C;
			singleAgentWrap.newAgentAssocId = 'IAMINVALID1';
			singleAgentWrap.startDate = string.valueOf(system.today());
		testStageOrchestration.Value__c = buildJsonStringForSingleAgent(singleAgentWrap);
        system.runAs(agentProcWrap.testAPIUser){
            test.startTest();
            insert testStageOrchestration;
            test.stopTest();
        }

        StageOrchestration__c stageOrch = [select id, status__c, Error__c from stageorchestration__c where id= :testStageOrchestration.id];
        System.assertEquals(UTIL_StageOrchestrationConstants.FAILED_USER_NOT_FOUND, stageOrch.Status__c, 'The given two parameters are not equal');
        System.assertEquals(UTIL_StageOrchestrationConstants.INVALID_USER_NOT_FOUND, stageOrch.Error__c, 'The given two parameters are not equal');

        system.runAs(agentProcWrap.salesRoleHierarchy1.Agent){
            List<Account> accountList = [select id from Account where ClientIdentifier__c= :'IAMCLIENT12'];
            system.assert(!accountList.isEmpty(), 'Account List Should not be empty');
        }
    }

    /*Give a change of agent process,
      When the winning agent is determined as invalid,
      Then the transaction must be retried 3 times before it is returned as remove from book.
    */
    @isTest
    static void testChangeOfAgentFailureScenarioWithThreeRetries() {
        getUsers();
        createChildRelatedData();

        StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        testStageOrchestration.TransactionType__c=UTIL_StageOrchestrationConstants.CHANGE_OF_AGENT_TRANSACTION;
        testStageOrchestration.VersionNumber__c=1.0;
        testStageOrchestration.ReprocessCount__c=3.0;
        UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList buildStringAgentWrap = new UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList();

			buildStringAgentWrap.clientAccountId = 'IAMCLIENT12';
			buildStringAgentWrap.fromAssociateId = agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C;
			buildStringAgentWrap.diffAgentAssocId = agentProcWrap.salesRoleHierarchy3.Agent.Associate_ID__C;
			buildStringAgentWrap.newAgentAssocId = 'IAMINVALID1';
			buildStringAgentWrap.startDate1 = '2008-08-01';
			buildStringAgentWrap.startDate2 = string.valueOf(system.today());
		testStageOrchestration.Value__c=buildJsonString(buildStringAgentWrap);
        system.runAs(agentProcWrap.testAPIUser){
            test.startTest();
            insert testStageOrchestration;
            test.stopTest();
        }
        system.runAs(agentProcWrap.salesRoleHierarchy1.Agent){
            List<Account> accountList = [select id from Account where ClientIdentifier__c= :'IAMCLIENT12'];
            system.assert(accountList.isEmpty(), 'Account List Should be empty');
        }

        StageOrchestration__c stageOrch = [select status__c from stageorchestration__c where id= :testStageOrchestration.id];
        system.assertEquals(UTIL_StageOrchestrationConstants.SUCCESS_STATUS, stageOrch.Status__c, 'The given two parameters are not equal');
    }

    @isTest
    static void testMethodforChangeofAgentProcessException(){
        getUsers();
        List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();

        StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        testStageOrchestration.TransactionType__c=UTIL_StageOrchestrationConstants.CHANGE_OF_AGENT_TRANSACTION;
        testStageOrchestration.VersionNumber__c=1.0;
        testStageOrchestration.Value__c='';
        stgOrchList.add(testStageOrchestration);
        system.runAs(agentProcWrap.testAPIUser){
            test.startTest();
            try{
                new UTIL_ChangeofAgentProcessor().execute(stgOrchList);
            }
            catch(StageProcessorException exp){
                System.assert(exp.getCause() instanceof InvalidInputException, 'Cause of Exception is not an instance of InvalidInputException');
                system.assertEquals('JSON String Should not be empty or Null',exp.getmessage(), 'The given two parameters are not equal');
            }
            test.stopTest();
        }
    }

    @isTest
    static void testMethodforRemoveFromBookWithAssignedStaff(){
        getUsers();
        TestData_SalesRoleHierarchy salesRoleHierarchy0;
        AssignedStaff__c newAssignedStaff;
        counts = new CS_StageOrchestration_Counts__c(Retry_Count__c=3,Chunk_Size__c=5);
        System.runAs(agentProcWrap.systemUser)  {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accRecord;
            insert counts;

            salesRoleHierarchy0 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('S');
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=accRecord.id, agent__c=salesRoleHierarchy0.Agent.Id,agentroleIdentifier__c=salesRoleHierarchy0.Agent.Associate_ID__c + '~IAMCLIENT12');
            insert newAgentRole;
            newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accRecord.clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+salesRoleHierarchy0.AgentTeamMember.Associate_Id__c,Customer__c=accRecord.Id,Staff__c=salesRoleHierarchy0.AgentTeamMember.Id);
            insert newAssignedStaff;
        }

        StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        testStageOrchestration.TransactionType__c=UTIL_StageOrchestrationConstants.CHANGE_OF_AGENT_TRANSACTION;
        testStageOrchestration.VersionNumber__c=1.0;
        UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList buildStringAgentProcessorWrap = new UTIL_ChangeofAgentProcessor_Test.BuildJsonStringWrapperList();

			buildStringAgentProcessorWrap.clientAccountId = 'IAMCLIENT12';
			buildStringAgentProcessorWrap.fromAssociateId = salesRoleHierarchy0.Agent.Associate_ID__C;
			buildStringAgentProcessorWrap.diffAgentAssocId = agentProcWrap.salesRoleHierarchy2.Agent.Associate_ID__C;
			buildStringAgentProcessorWrap.newAgentAssocId = agentProcWrap.salesRoleHierarchy2.Agent.Associate_ID__C;
			buildStringAgentProcessorWrap.startDate1 = '2008-08-01';
			buildStringAgentProcessorWrap.startDate2 = string.valueOf(system.today());
		testStageOrchestration.Value__c = buildJsonString(buildStringAgentProcessorWrap);
        system.runAs(agentProcWrap.testAPIUser){
            test.startTest();
            insert testStageOrchestration;
            test.stopTest();
        }
        System.runAs(salesRoleHierarchy0.Agent)  {
            account[] testAccountList=[Select id From account where id=:accRecord.Id];
            System.assert(testAccountList.isEmpty(), 'Account[] should be empty');
        }

        //Agent will not be able to see AgentRole__c,Task,opportunity,AccountMessage__c,CampaignMember that's why asserting in system mode
        agentRoleDeletion=[Select id From AgentRole__c where Customer__c=:accRecord.Id AND AgentRoleIdentifier__c=:agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C+'~IAMCLIENT12'];
        system.assert(agentRoleDeletion.isEmpty(), 'List<AgentRole__c> should be empty');

        List<AssignedStaff__c> assignedStaffList = [Select id from AssignedStaff__c where Customer__c=:accRecord.Id];
        system.assert(assignedStaffList.isEmpty(), 'List<AssignedStaff__c> should be empty');
    }

    Private static void createChildRelatedData(){
        counts = new CS_StageOrchestration_Counts__c(Retry_Count__c=3,Chunk_Size__c=5);
        agentProcWrap.systemUser = [SELECT Id FROM User where  UserExternalID__c ='admin1'];
        System.runAs(agentProcWrap.systemUser)  {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

            campTriggerBypass = new CS001_ByPassTriggerAtoF__c(Override_CampaignMemberAfterDelete__c=true,Override_CaseAfterInsert__c=true, Override_CaseBeforeInsert__c = true);
			insert campTriggerBypass;
            insert accRecord;
            contactRecord = [SELECT Id from Contact where AccountId =: accRecord.Id limit 1];
            insert counts;
            insert new AgentRole__c(customer__c=accRecord.id, agent__c=agentProcWrap.salesRoleHierarchy1.Agent.id,agentroleIdentifier__c=agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C+'~IAMCLIENT12');
            insert new AgentRole__c(customer__c=accRecord.id, agent__c=agentProcWrap.salesRoleHierarchy2.Agent.id,agentroleIdentifier__c=agentProcWrap.salesRoleHierarchy2.Agent.Associate_ID__C+'~IAMCLIENT12');

            accountMessgaeCreation = new AccountMessage__c(AssociateID__c = agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__c, Account__c = accRecord.Id, Status__c = 'Scheduled');
            insert accountMessgaeCreation;

            Campaign testCampaign = new Campaign(Name ='testCampaign', Type = 'Lead',OwnerId=agentProcWrap.salesRoleHierarchy1.agentOffice.id);
            insert testCampaign;

            Lead refLead = new Lead(LastName = 'TestReferralLd-1', CustomerReferrer__c = accRecord.id, ownerId = agentProcWrap.salesRoleHierarchy1.agentOffice.id,
            recordtypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName().get('SF_Referral').getRecordTypeId());
            insert refLead;

            leadMetricsCreation = new LeadMetrics__c(LeadName__c = 'TestReferralLd-1', CustomerReferrer__c = accRecord.id, ownerId = agentProcWrap.salesRoleHierarchy1.agentOffice.id);
            insert leadMetricsCreation;

            Account testcontact = [Select PersonContactId from Account Where id=:accRecord.id];
            testCampaignMember = new CampaignMember (CampaignId=testCampaign.Id,Status='Sent',ContactId=testcontact.PersonContactId);
            insert testCampaignMember;
        }
    }

    private static void createOpportunityTestData(){

        actualOpportunityList.add(new Opportunity(AccountId=accRecord.Id ,Name = 'LessThan 30Days',LOB__c='Auto', CloseDate=Date.today(), StageName='New',description='testDescription1',Opportunity_Originator__c='Agent/ATM',
                                                  Assigned_To__c=agentProcWrap.salesRoleHierarchy1.Agent.id,OwnerId=agentProcWrap.salesRoleHierarchy1.agentOffice.id));
        actualOpportunityList.add(new Opportunity(AccountId=accRecord.Id ,Name = 'GreaterThan 30Days',LOB__c='Auto', CloseDate=Date.today(), StageName='New',description='testDescription2',Opportunity_Originator__c='Agent/ATM'
                                                  ,Assigned_To__c=agentProcWrap.salesRoleHierarchy1.Agent.id,OwnerId=agentProcWrap.salesRoleHierarchy1.agentOffice.id));
        Map<String, ID> oppRecordTypeMap = new Map<String, ID>();
        Map<String, Schema.Recordtypeinfo> schemaRtMap = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName();
        for(String s: schemaRtMap.keySet()){
            oppRecordTypeMap.put(s, schemaRtMap.get(s).RecordTypeId);
        }
        Id oppRecordtype= oppRecordTypeMap.get('Opportunity Management');
        actualOpportunityList.add(new Opportunity(AccountId=accRecord.Id ,Name = 'Opportuntity Management Claimed',LOB__c='Auto', CloseDate=Date.today(), StageName='New',description='testDescription3',Opportunity_Originator__c='Internet Lead Provider',credit_status__c='RFC Granted'
                                                  ,Assigned_To__c=agentProcWrap.salesRoleHierarchy1.Agent.id,OwnerId=agentProcWrap.salesRoleHierarchy1.agentOffice.id,RecordTypeId=oppRecordtype));
        insert actualOpportunityList;
        Test.setCreatedDate(actualOpportunityList.get(1).Id, system.today()-32);
        List<Task> taskListForOpp=new List<Task>();
        taskListForOpp.add(new Task (WhatId=actualOpportunityList.get(0).Id, subject='Task Under Opp To be Reassigned',Description='TASKForGivenOpp1', status='InProgress',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.id));
        taskListForOpp.add(new Task (WhatId=actualOpportunityList.get(1).Id, subject='Task Under Opp Closed Reassign',Description='TASKForGivenOpp2', status='Incomplete',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.id));
        taskListForOpp.add(new Task (WhatId=actualOpportunityList.get(2).Id, subject='Task Under Opp Sys Rec Owner',Description='TASKForGivenOpp3', status='Incomplete',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.id));
        insert taskListForOpp;
    }

    private static void createProductServicedByMe(){
        productsServicedBeMe = new ProductsServicedByMe__c(Agent__c=agentProcWrap.salesRoleHierarchy1.Agent.Id,ProductLine__c='Auto',
                                                           ProductType__c='ATV',CarrierName__c='Assigned Risk/JUA',Customer__c = accRecord.Id);
        insert productsServicedBeMe;
    }

    private static void createCases(){
        expectedCaseList.add(new Case (accountid=accRecord.Id,Description='GreaterThan 90', Case_Originator__c = 'CCC Sales', status='Closed',OwnerId=agentProcWrap.salesRoleHierarchy1.agentOffice.id));
        expectedCaseList.add(new Case (accountid=accRecord.Id,Description='Cases2', Case_Originator__c = 'CCC Sales', status='onhold',OwnerId=agentProcWrap.salesRoleHierarchy1.agentOffice.id));
        expectedCaseList.add(new Case (accountid=accRecord.Id,Description='LessThan 90', Case_Originator__c = 'CCC Sales', status='new',OwnerId=agentProcWrap.salesRoleHierarchy1.agentOffice.id));
        expectedCaseList.add(new Case (accountid=accRecord.Id,Description='Cases4', Case_Originator__c = 'CCC Sales', status='new',OwnerId=agentProcWrap.noAccessProfileUser.Id));
        expectedCaseList.add(new Case (accountid=accRecord.Id,Description='System Owner Case', Case_Originator__c = 'CCC Sales', status='new',OwnerId=agentProcWrap.noAccessProfileUser.Id));
        insert expectedCaseList;
        Test.setCreatedDate(expectedCaseList.get(0).Id, system.today()-91);
        Test.setCreatedDate(expectedCaseList.get(1).Id, system.today()-98);
        Test.setCreatedDate(expectedCaseList.get(4).Id, system.today()-94);
        List<Task> taskListForCase=new List<Task>();
        taskListForCase.add(new Task (WhatId=expectedCaseList.get(1).Id, subject='Task Under case To be closed',Description='TASKForGivenCase1', status='InProgress',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.id));
        taskListForCase.add(new Task (WhatId=expectedCaseList.get(2).Id, subject='Task Under case For Reassign',Description='TASKForGivenCase2', status='Incomplete',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.id));
        insert taskListForCase;
    }

    private static void createTasks(){
        List<Task> taskListForTask=new List<Task>();
        contactRecord = [SELECT Id from Contact where AccountId =: accRecord.Id limit 1];
        taskListForTask.add(new Task (WhatId=accRecord.Id, subject='Old createdDate1',Description='TASK111', status='Incomplete',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.id, OwnerId=agentProcWrap.salesRoleHierarchy1.Agent.id));
        taskListForTask.add(new Task (WhatId=accRecord.Id, subject='Old createdDate2',Description='TASK222', status='Completed',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.id, OwnerId=agentProcWrap.salesRoleHierarchy1.Agent.id));
        taskListForTask.add(new Task (WhatId=accRecord.Id, subject='Reassign Task1',Description='TASK333', status='InProgress',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.id, OwnerId=agentProcWrap.salesRoleHierarchy1.Agent.id));
        taskListForTask.add(new Task (WhatId=accRecord.Id, subject='Reassign Task2',Description='TASK444', status='Completed',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.id, OwnerId=agentProcWrap.salesRoleHierarchy1.Agent.id));
        taskListForTask.add(new Task (WhoId = contactRecord.get(0).Id, subject='Reassign Task3',Description='TASK555', status='Incomplete',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.id, OwnerId=agentProcWrap.salesRoleHierarchy1.Agent.id));
        taskListForTask.add(new Task (WhoId = contactRecord.get(0).Id, subject='Reassign Task4',Description='TASK666', status='Completed',AssignedTo__c=agentProcWrap.salesRoleHierarchy1.Agent.id, OwnerId=agentProcWrap.salesRoleHierarchy1.Agent.id));
        insert taskListForTask;
        Test.setCreatedDate(taskListForTask.get(0).Id, system.today()-91);
        Test.setCreatedDate(taskListForTask.get(1).Id, system.today()-98);
    }

    private static void validateLoosingAgentData(user oldAgent){
        System.runAs(oldAgent)  {
            account[] testAccountList=[Select id From account where id=:accRecord.Id];
            System.assert(testAccountList.isEmpty(), 'Account[] should be empty');
            AccountMessage__c[] accountMessgae = [select id from AccountMessage__c where id=:accountMessgaeCreation.id];
            system.assert(accountMessgae.isEmpty(), 'AccountMessage__c[] should be empty');

            //CampaignMember assertion weather it is removed from his book
            CampaignMember[] campaignMemberAfterInsert =[select id from CampaignMember where id=:testCampaignMember.Id];
            system.assert(campaignMemberAfterInsert.isEmpty(),'CampaignMember[] should be empty' );

            List<Lead> delLead = [Select Id FROM Lead Where CustomerReferrer__c =: accRecord.Id];
            system.assertEquals(0, delLead.size(), 'Size of List<Lead> should be equals to 0');

            LeadMetrics__c ldMetricRecordAfterUpdate = [Select Id,LeadDeletedBy__r.profile.name, Status__c, LeadDeletedBy__c, LeadDeletionDate__c from LeadMetrics__c where id=:leadMetricsCreation.id limit 1];
            System.assertEquals('Deleted', ldMetricRecordAfterUpdate.Status__c, 'Status is Incorrect');
            User userIn;
            userIn = [select id,profile.name from user where id=:agentProcWrap.testAPIUser.Id];
            System.assertEquals(agentProcWrap.testAPIUser.Id, ldMetricRecordAfterUpdate.LeadDeletedBy__c, 'Lead Metric Deleted By is Incorrect');
            System.assert(ldMetricRecordAfterUpdate.LeadDeletionDate__c != null, 'Lead Metric DeletedDate is Incorrect');

            List<ProductsServicedByMe__c> actualProductsServicedByMeList = [Select id from ProductsServicedByMe__c where Id=:productsServicedBeMe.Id];
            system.assert(actualProductsServicedByMeList.isEmpty(), 'List<ProductsServicedByMe__c> should be empty');
        }
    }

    private static void validateAsSysRecOwnerData(user sysOwner){
        validateAsSysRecOwnerExceptOpp(sysOwner);
            System.runAs(sysOwner)  {
            List<Opportunity> oppList = [select State_Code__c,name,OwnerId,AccountId,StageName,description,CloseDate,Assigned_To__c from Opportunity where id=:actualOpportunityList];
            validateOpportunities(oppList);
            //Task under Opportunities Assertions
            List<Task> taskListForOppToAssert = [select id,WhatId,subject,OwnerId,Description,status,AssignedTo__c,createddate from task where WhatId IN :oppList];
            validateTasksForOpp(taskListForOppToAssert);
        }
    }

    private static void validateAsSysRecOwnerExceptOpp(user sysOwner){
        System.runAs(sysOwner)  {
            //Agent will not be able to see AgentRole__c,Task,opportunity,AccountMessage__c,CampaignMember that's why asserting in system mode
            agentRoleDeletion=[Select id From AgentRole__c where Customer__c=:accRecord.Id AND AgentRoleIdentifier__c=:agentProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C+'~IAMCLIENT12'];
            system.assert(agentRoleDeletion.isEmpty(), 'List<AgentRole__c> should be empty');

            //Case assertion for changing the status which are not Closed to Closed
            Map<Id, Case> caseMap = new Map<Id, Case>([select id,accountID,OwnerId,Description,status,createddate,Assigned_To__c  from Case where Id=:expectedCaseList]);
            validateCases(caseMap.values());

            List<Id> whatIds = new List<Id>();
            whatIds.add(accRecord.Id);
            whatIds.addAll(caseMap.keySet());

            //Task assertion for changing the status which are not completed to Removed From Book
            List<Task> taskList = [select id,WhatId,subject,OwnerId,Description,status,AssignedTo__c,createddate from task where WhatId=:whatIds or WhoId=:contactRecord.get(0).Id];
            validateTasks(taskList);
        }
    }

    private static void validateTasks(List<Task> taskList){
        for(Task taskAssertion : taskList){
            if(taskAssertion.OwnerId==agentProcWrap.noAccessProfileUser.Id){
                system.assertEquals(agentProcWrap.noAccessProfileUser.id, taskAssertion.OwnerId, 'The given two parameters are not equal');
                system.assertEquals(agentProcWrap.salesRoleHierarchy1.agentOffice.id, taskAssertion.AssignedTo__c, 'The given two parameters are not equal');
            }else{
                system.assertEquals(agentProcWrap.salesRoleHierarchy2.agentOffice.id, taskAssertion.OwnerId, 'The given two parameters are not equal');
                system.assertEquals(agentProcWrap.salesRoleHierarchy2.Agent.id, taskAssertion.AssignedTo__c, 'The given two parameters are not equal');
            }
        }
    }

    private static void validateTasksForOpp(List<Task> taskList){
        for(Task taskAssertion : taskList){
            if(taskAssertion.OwnerId==agentProcWrap.noAccessProfileUser.Id){
                system.assertEquals(agentProcWrap.noAccessProfileUser.id, taskAssertion.OwnerId, 'The given two parameters are not equal');
                system.assertEquals(agentProcWrap.salesRoleHierarchy1.agentOffice.id, taskAssertion.AssignedTo__c, 'The given two parameters are not equal');
            }else{
                system.assertEquals(agentProcWrap.salesRoleHierarchy2.agentOffice.id, taskAssertion.OwnerId, 'The given two parameters are not equal');
                system.assertEquals(null, taskAssertion.AssignedTo__c, 'AssignedTo__c should be null');
            }
        }
    }

    private static void validateOpportunities(List<Opportunity> oppList){
        for(Opportunity actualOpportunity: oppList){
            if(actualOpportunity.name == 'LessThan 30Days'){
                system.assertEquals(null, actualOpportunity.Assigned_To__c, 'AssignedTo__c should be null');
                system.assertEquals(agentProcWrap.salesRoleHierarchy2.AgentOffice.id, actualOpportunity.OwnerId, 'Expected owner id should be equals to the actual owner id');
                system.assertEquals('New' , actualOpportunity.StageName, 'Opportunity stage name should be \'New\'');
            }else if(actualOpportunity.name == 'GreaterThan 30Days'){
                system.assertEquals(null, actualOpportunity.Assigned_To__c, 'AssignedTo__c should be null');
                system.assertEquals(agentProcWrap.salesRoleHierarchy2.AgentOffice.id, actualOpportunity.OwnerId, 'Expected owner id should be equals to the actual owner id');
                system.assertEquals(UTIL_StageOrchestrationConstants.OPPORTUNITY_CLOSED_STAGE_NAME , actualOpportunity.StageName, 'The given two parameters are not equal');
            }else if(actualOpportunity.name == 'Opportuntity Management Claimed'){
                system.assertEquals(agentProcWrap.salesRoleHierarchy1.AgentOffice.id, actualOpportunity.Assigned_To__c, 'The given two parameters are not equal');
                system.assertEquals(agentProcWrap.noAccessProfileUser.id, actualOpportunity.OwnerId, 'Expected owner id should be equals to the actual owner id');
                system.assertEquals(UTIL_StageOrchestrationConstants.OPPORTUNITY_CLOSED_STAGE_NAME , actualOpportunity.StageName, 'The given two parameters are not equal');
            }
        }
    }

    private static void validateCases(List<Case> caseListAssert){
        for(Case actualCase: caseListAssert){
            if(actualCase.Description == 'GreaterThan 90'){
                system.assertEquals(agentProcWrap.noAccessProfileUser.id, actualCase.OwnerId, 'Expected owner id should be equal to the actual owner id');
                system.assertEquals('Closed' , actualCase.Status, 'Case status should be closed');
            }else if(actualCase.Description == 'LessThan 90'){
                system.assertEquals(agentProcWrap.salesRoleHierarchy2.AgentOffice.id, actualCase.OwnerId, 'Expected parameter is not equals to the actual parameter');
                system.assertEquals('Pending' , actualCase.Status, 'Case status should be pending');
            }else if(actualCase.Description == 'System Owner Case'){
                system.assertEquals(agentProcWrap.noAccessProfileUser.id, actualCase.OwnerId, 'Expected owner id should be equal to the actual owner id');
                system.assertEquals('New' , actualCase.Status, 'Case status should be new');
            }
        }
    }

    /**
     * @description test method for build json string
     * @param jsonStringWrapper
     * @return  `String`
     */
    public static String buildJsonString(BuildJsonStringWrapperList jsonStringWrapper) {
        String clientAccountId = jsonStringWrapper.clientAccountId;
	    string fromAssociateId = jsonStringWrapper.fromAssociateId;
	    string diffAgentAssocId;
        diffAgentAssocId = jsonStringWrapper.diffAgentAssocId;
	    string newAgentAssocId = jsonStringWrapper.newAgentAssocId;
	    string startDate1 = jsonStringWrapper.startDate1;
	    string startDate2 = jsonStringWrapper.startDate2;
        String json= '{ '+
            '"orchestrationInfo" : { '+
            '"jsonVersionNumber" : "1.0", '+
            '"orchestrationDataName" : [  { '+
            '"orchestrationNameDetail" : { '+
            '"dataName" : "Agent Role", '+
            '"dataDeleteIndicator" : false, '+
            '"dataExternalKey" : "AgentRoleIdentifier", '+
            '"orchestrationDataValues" : { '+
            '"RelationshipNature" : "Client", '+
            '"StartDate" : "'+startDate1+'", '+
            '"Customer" : "'+clientAccountId+'", '+
            '"Agent" : "'+newAgentAssocId+'", '+
            '"HouseholdGroupId" : "XYZV74NZP0H" '+
            '} '+
            '} '+
            '} ,{ '+
            '"orchestrationNameDetail" : { '+
            '"dataName" : "Agent Role", '+
            '"dataDeleteIndicator" : false, '+
            '"dataExternalKey" : "AgentRoleIdentifier", '+
            '"orchestrationDataValues" : { '+
            '"RelationshipNature" : "Client", '+
            '"StartDate" : "'+startDate2+'", '+
            '"Customer" : "'+clientAccountId+'", '+
            '"Agent" : "'+newAgentAssocId+'", '+
            '"HouseholdGroupId" : "X9HV74NZP0H" '+
            '} '+
            '} '+
            '}], '+
            '"orchestrationEventName" : { '+
            '"orchestrationEventType" : "Change of Agent",'+
            '"orchestrationEventDetail" : { '+
            '"orchestrationEventValues" : { '+
            '"ClientId" : "'+clientAccountId+'", '+
            '"fromAssociateId" : "'+fromAssociateId+'" '+
            '} '+
            '} '+
            '} '+
            '} '+
            '}';
        return json;
    }

    /**
     * @description wrapper list for build json string
     */
    public class BuildJsonStringWrapperList{
        public String clientAccountId;
        public string fromAssociateId;
        public string diffAgentAssocId;
        public string newAgentAssocId;
		public string startDate1;
		public string startDate2;
    }

    /**
     * @description test method for json string for single agent
     * @param jsonStringForSingleAgentWrapper
     * @return  `String`
     */
    public static String buildJsonStringForSingleAgent(BuildJsonStringForSingleAgentWrapperList jsonStringForSingleAgentWrapper) {
        String clientAccountId = jsonStringForSingleAgentWrapper.clientAccountId;
	    string fromAssociateId = jsonStringForSingleAgentWrapper.fromAssociateId;
	    string newAgentAssocId = jsonStringForSingleAgentWrapper.newAgentAssocId;
	    string startDate = jsonStringForSingleAgentWrapper.startDate;
        String json= '{ '+
            '"orchestrationInfo" : { '+
            '"jsonVersionNumber" : "1.0", '+
            '"orchestrationDataName" : [  { '+
            '"orchestrationNameDetail" : { '+
            '"dataName" : "Agent Role", '+
            '"dataDeleteIndicator" : false, '+
            '"dataExternalKey" : "AgentRoleIdentifier", '+
            '"orchestrationDataValues" : { '+
            '"RelationshipNature" : "Client", '+
            '"StartDate" : "'+startDate+'", '+
            '"Customer" : "'+clientAccountId+'", '+
            '"Agent" : "'+newAgentAssocId+'", '+
            '"HouseholdGroupId" : "XYZV74NZP0H" '+
            '} '+
            '} '+
            '}], '+
            '"orchestrationEventName" : { '+
            '"orchestrationEventType" : "Change of Agent",'+
            '"orchestrationEventDetail" : { '+
            '"orchestrationEventValues" : { '+
            '"ClientId" : "'+clientAccountId+'", '+
            '"fromAssociateId" : "'+fromAssociateId+'" '+
            '} '+
            '} '+
            '} '+
            '} '+
            '}';
        return json;
    }

    /**
     * @description wrapper class for json string for single agent wrapper list
     */
    public class BuildJsonStringForSingleAgentWrapperList{
        public String clientAccountId;
        public string fromAssociateId;
        public string newAgentAssocId;
		public string startDate;
    }

    private class UTIL_ChangeofAgentProcessor_Wrapper{
        private User systemUser;
        private User testAPIUser;
        private User noAccessProfileUser;
        private TestData_SalesRoleHierarchy salesRoleHierarchy1;
        private TestData_SalesRoleHierarchy salesRoleHierarchy2;
        private TestData_SalesRoleHierarchy salesRoleHierarchy3;
    }
}