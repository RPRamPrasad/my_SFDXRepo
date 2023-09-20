/**
Author Team ClubCar
Name - UTIL_AccountProcessorsSwcHandler_TEST
@description Test class written for UTIL_AccountProcessorsSwcHandler
========================================================================================================================================+
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                12/21/2020              Initial Development
******************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class UTIL_AccountProcessorsSwcHandler_TEST {

    private static User systemUser;
    private static User testAPIUser;
    private static User noAccessUser;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy2;
    private static final  String CLIENTID1 = 'BBB5S6J0O';
    private static final  String CLIENTID2 = 'BBB5S6J0N';

    //setup method to set test data
    @TestSetup
    private static void setup(){

        systemUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemUser;
        testAPIUser= UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        insert testAPIUser;
        noAccessUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert noAccessUser;
        AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(noAccessUser.id);
        insert accountOwner;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(testAPIUser);
        System.runAs(systemUser) {
            assignPermissionSet(testAPIUser);
            
            salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A'); 
            salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('B');
       
            salesRoleHierarchy2.agentOffice.firstName='Test';
            salesRoleHierarchy2.agentOffice.LastName='Test, HCKS, 59-6789-Office';
            update salesRoleHierarchy2.agentOffice;
            salesRoleHierarchy2.Agent.State_Agent_Code_List__c='59-6789';
            salesRoleHierarchy2.Agent.State_Agent_Code__c='59-6789';
            update salesRoleHierarchy2.Agent;
        }
    }

    //test method to verify swc data cleared on opportunities under separated account and swc tasks have not duplicated
    @isTest
    private static void testOppSwcDataClearedOnSeparate() {
        getUsers();
        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(CLIENTID1));
        accountList.add(createAccount(CLIENTID2));
        List<Opportunity> opportunityList = new List<Opportunity>();

        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;
            Account acct = [SELECT Id FROM Account WHERE ClientIdentifier__c = :CLIENTID1];
            opportunityList.add(createOpportunity(acct.id, salesRoleHierarchy1.Agent.id, salesRoleHierarchy1.agentOffice.id));
            opportunityList.add(createOpportunity(acct.id, salesRoleHierarchy1.Agent.id, salesRoleHierarchy1.agentOffice.id));
            Insert opportunityList;
        }

        List<Task> taskList = new List<Task>();
        String taskDescription = 'Beginning this due date, consent has been provided to continue marketing efforts.Depending on the state, this can be a 30 day window or a 90 day window that you are able to market to the prospect';
        taskList.add(new Task (WhatId=opportunityList[0].Id, OwnerId = salesRoleHierarchy1.Agent.id,ActivityDate = Date.today(),Description=taskDescription,TaskCategory__c='SignedWrittenConsent',AppCode__c = 'SFDC_MKTCLD'));
        taskList.add(new Task (WhatId=opportunityList[1].Id, OwnerId = salesRoleHierarchy1.Agent.id,ActivityDate = Date.today(),Description='Call to quote',TaskCategory__c='Application/Policy',AppCode__c = 'SFDC ILP Journey'));
        insert taskList;
        Account acct2 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c = :CLIENTID2];
        System.runAs(systemUser){//run processor
            test.startTest();
            List<StageOrchestration__c> stgOrcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = buildJsonForSeparateProcessor(CLIENTID1, CLIENTID2, '2017-10-03T09:40:58.044+0000');
            stgOrcList.add(testStageOrchestration);
            UTIL_SeparateProcessor processorTest = new UTIL_SeparateProcessor();
            processorTest.execute(stgOrcList);
            test.stopTest();
        }

        List<Task> newAcctTaskList = [Select ID from Task where accountid = :acct2.Id];
        List<Opportunity> newOpportunityList = [Select OppSignedWrittenConsentStatus__c,OppSignedWrittenConsentRequestedDate__c,
                                                OppSignedWrittenConsentGrantedDate__c,DateCaptured__c from Opportunity where AccountId = :acct2.id];

        System.assertEquals(null, newOpportunityList[0].OppSignedWrittenConsentStatus__c, 'Opportunity SWC status was not updatedto null');
        System.assertEquals(null, newOpportunityList[1].OppSignedWrittenConsentRequestedDate__c, 'Opportunity SWC GrantedDate was not updated to null');
        System.assertEquals(null, newOpportunityList[1].OppSignedWrittenConsentGrantedDate__c, 'Opportunity SWC RequestedDate was not updated to null');
        //System.assertEquals(null, newOpportunityList[0].DateCaptured__c, 'Opportunity DateCaptured was not updated to null');
        System.assertEquals(1, newAcctTaskList.size(), 'Unexpected Separated Task List Size');
    }

    //test method to verify swc data updated with winnig agent opportunities swc data, swc tasks have closed and
    // swc records status got updated to "Not Applicable" after change of agent
    @isTest
    private static void testSwcDataUpdatedOnChangeOfAgent(){
        getUsers();
        Account acct = createAccount(CLIENTID1);
        Account acctRecord;
        System.runas(systemUser){
            createCustomSettingForEnvironmentURLData ();
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert acct;
            acctRecord = [Select Id  from Account where ClientIdentifier__c=:CLIENTID1];
            List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole1 = new AgentRole__c(customer__c=acctRecord.id, agent__c=salesRoleHierarchy1.Agent.id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_ID__C+'~'+CLIENTID1);
            AgentRole__c agentRole2 = new AgentRole__c(customer__c=acctRecord.id, agent__c=salesRoleHierarchy2.Agent.id,agentroleIdentifier__c=salesRoleHierarchy2.Agent.Associate_ID__C+'~'+CLIENTID1);
            agentRoleList.add(agentRole1);
            agentRoleList.add(agentRole2);
            insert agentRoleList;

            Opportunity oppRecord = createOpportunity(acctRecord.Id, salesRoleHierarchy2.Agent.id,salesRoleHierarchy2.agentOffice.id);
            insert oppRecord;
            List<Opportunity> opptyList = new List<Opportunity>();
            Opportunity opportunity1 = createOpportunity(acctRecord.Id, salesRoleHierarchy1.Agent.id,salesRoleHierarchy1.agentOffice.id);
            opportunity1.OppSignedWrittenConsentRequestedDate__c = null;
            Opportunity opportunity2 = createOpportunity(acctRecord.Id, salesRoleHierarchy1.Agent.id,salesRoleHierarchy1.agentOffice.id);
            opportunity2.DateCaptured__c = null;
            opptyList.Add(opportunity1);
            opptyList.Add(opportunity2);
            insert opptyList;
            List<Task> taskList = new List<Task>();
            String taskDescription = 'Beginning this due date, consent has been provided to continue marketing efforts.Depending on the state, this can be a 30 day window or a 90 day window that you are able to market to the prospect';
            taskList.add(new Task (WhatId=opptyList[0].Id, OwnerId = salesRoleHierarchy1.agentOffice.id,AssignedTo__c = salesRoleHierarchy1.Agent.id,ActivityDate = Date.today(),Description=taskDescription,TaskCategory__c='SignedWrittenConsent',AppCode__c = 'SFDC_MKTCLD'));
            taskList.add(new Task (WhatId=opptyList[0].Id, OwnerId = salesRoleHierarchy1.agentOffice.id,AssignedTo__c = salesRoleHierarchy1.Agent.id,ActivityDate = Date.today(),Description='Send Mail',TaskCategory__c='Account Change',AppCode__c = 'SFDC Customer Separate'));
            insert taskList;
            SignedWrittenConsent__c signedWrittenConsentRecord = new SignedWrittenConsent__c(Account__c = acctRecord.Id,RequestStartDate__c = System.Today()+10, Status__c = 'Requested',
                                                                                             RequestEndDate__c = System.Today()+90,InitiatedFromId__c = opptyList[0].Id);
            insert signedWrittenConsentRecord;
        }
        List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
        StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
           UTIL_ChangeofAgentProcessor_Test.BuildJsonStringForSingleAgentWrapperList stringForSingleAgentWrap = new UTIL_ChangeofAgentProcessor_Test.BuildJsonStringForSingleAgentWrapperList();

                stringForSingleAgentWrap.ClientAccountId = CLIENTID1;
                stringForSingleAgentWrap.FromAssociateId = salesRoleHierarchy1.Agent.Associate_ID__C;
                stringForSingleAgentWrap.newAgentAssocId = salesRoleHierarchy2.Agent.Associate_ID__C;
                stringForSingleAgentWrap.startDate = string.valueOf(system.today());
            testStageOrchestration.Value__c = UTIL_ChangeofAgentProcessor_Test.buildJsonStringForSingleAgent(stringForSingleAgentWrap);
        stgOrchList.add(testStageOrchestration);
        system.runAs(testAPIUser){
            test.startTest();
            new UTIL_ChangeofAgentProcessor().execute(stgOrchList);
            test.stopTest();
        }

        List<Opportunity> opportunityList = [Select OppSignedWrittenConsentStatus__c,OppSignedWrittenConsentRequestedDate__c,
                                             OppSignedWrittenConsentGrantedDate__c,DateCaptured__c from Opportunity where AccountId = :acctRecord.id];
        SignedWrittenConsent__c swcRecordAfterChangeOfAgent = [Select Status__c from SignedWrittenConsent__c LIMIT 1];
        Task taskRecordAfterChangeOfAgent = [Select isClosed from Task where AccountId = :acctRecord.id AND TaskCategory__c = 'SignedWrittenConsent'];
        // System.assertEquals('Granted', opportunityList[0].OppSignedWrittenConsentStatus__c , 'Opportunity SWC status was not updatedto null');
        // System.assertEquals(System.today().addDays(-10), opportunityList[1].OppSignedWrittenConsentRequestedDate__c, 'Opportunity SWC GrantedDate was not updated to null');
        // System.assertEquals(System.today().addDays(90), opportunityList[1].OppSignedWrittenConsentGrantedDate__c, 'Opportunity SWC RequestedDate was not updated to null');
        // System.assertEquals(System.today().addDays(10), opportunityList[2].DateCaptured__c, 'Opportunity DateCaptured was not updated to null');
        System.assertEquals('Not Applicable', swcRecordAfterChangeOfAgent.Status__c, 'Signed Written Consnet Status is not as expected');
        System.assert(taskRecordAfterChangeOfAgent.isClosed, 'Task is not closed');
    }

    //test method to verify swc data cleared on opportunities if there are no opportunities on winning agent
    //and swc records status got updated to not applicable after change of agent
    @isTest
    private static void testSwcDataClearedOnChangeOfAgent(){
        getUsers();
        Account acct = createAccount(CLIENTID1);
        Account acctRecord;
        System.runas(systemUser){
            createCustomSettingForEnvironmentURLData ();
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert acct;
            acctRecord = [Select Id  from Account where ClientIdentifier__c=:CLIENTID1];

            AgentRole__c agentRole = new AgentRole__c(customer__c=acctRecord.id, agent__c=salesRoleHierarchy1.Agent.id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_ID__C+'~'+CLIENTID1);
            insert agentRole;

            Opportunity oppRecord = createOpportunity(acctRecord.Id, salesRoleHierarchy1.Agent.id,salesRoleHierarchy1.agentOffice.id);
            insert oppRecord;
            SignedWrittenConsent__c signedWrittenConsentRecord = new SignedWrittenConsent__c(Account__c = acctRecord.Id,RequestStartDate__c = System.Today()+10, Status__c = 'Requested',
                                                                                             RequestEndDate__c = System.Today()+90,InitiatedFromId__c = oppRecord.Id);
            insert signedWrittenConsentRecord;
        }
        List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
        StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        UTIL_ChangeofAgentProcessor_Test.BuildJsonStringForSingleAgentWrapperList jsonStringForSingleAgentWrap = new UTIL_ChangeofAgentProcessor_Test.BuildJsonStringForSingleAgentWrapperList();

			jsonStringForSingleAgentWrap.ClientAccountId = CLIENTID1;
			jsonStringForSingleAgentWrap.FromAssociateId = salesRoleHierarchy1.Agent.Associate_ID__C;
			jsonStringForSingleAgentWrap.newAgentAssocId = salesRoleHierarchy2.Agent.Associate_ID__C;
			jsonStringForSingleAgentWrap.startDate = string.valueOf(system.today());
		testStageOrchestration.Value__c = UTIL_ChangeofAgentProcessor_Test.buildJsonStringForSingleAgent(jsonStringForSingleAgentWrap);
        stgOrchList.add(testStageOrchestration);
        system.runAs(testAPIUser){
            test.startTest();
            new UTIL_ChangeofAgentProcessor().execute(stgOrchList);
            test.stopTest();
        }

        List<Opportunity> opportunityList = [Select OppSignedWrittenConsentStatus__c,OppSignedWrittenConsentRequestedDate__c,
                                             OppSignedWrittenConsentGrantedDate__c,DateCaptured__c from Opportunity where AccountId = :acctRecord.id];
        SignedWrittenConsent__c swcRecordAfterChangeOfAgent = [Select Status__c from SignedWrittenConsent__c LIMIT 1];
        System.assertEquals(null,opportunityList[0].OppSignedWrittenConsentStatus__c , 'Opportunity SWC status was not updatedto null');
        System.assertEquals(null, opportunityList[0].OppSignedWrittenConsentRequestedDate__c, 'Opportunity SWC GrantedDate was not updated to null');
        System.assertEquals(null, opportunityList[0].OppSignedWrittenConsentGrantedDate__c, 'Opportunity SWC RequestedDate was not updated to null');
        System.assertEquals(null, opportunityList[0].DateCaptured__c, 'Opportunity DateCaptured was not updated to null');
        System.assertEquals('Not Applicable', swcRecordAfterChangeOfAgent.Status__c, 'Signed Written Consnet Status is not as expected');
    }

    //test method to verify swc data updated on losing account opportunities, swc tasks have closed and swc records status
    //got updated to not applicable if losing account opportunities office match winning account opportunities office on combine
    @isTest
    private static void testSwcDataUpdatedOnCombine(){
        getUsers();
        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(CLIENTID1));
        accountList.add(createAccount(CLIENTID2));
        List<Opportunity> winningAcctOpptyList = new List<Opportunity>();
        Opportunity losingAcctOppty;
        System.runas(systemUser){
            CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c = true);
            insert passTriggerAll;
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;
            Account winningAcct = [SELECT Id FROM Account WHERE ClientIdentifier__c =:CLIENTID1];
            Account losingAcct = [Select Id from Account where ClientIdentifier__c=:CLIENTID2];
            winningAcctOpptyList.add(createOpportunity(winningAcct.id, salesRoleHierarchy1.Agent.id,salesRoleHierarchy1.agentOffice.id));
            winningAcctOpptyList.add(createOpportunity(winningAcct.id, salesRoleHierarchy1.Agent.id,salesRoleHierarchy1.agentOffice.id));
            Insert winningAcctOpptyList;
            losingAcctOppty = createOpportunity(losingAcct.id, salesRoleHierarchy1.Agent.id,salesRoleHierarchy1.agentOffice.id);
            losingAcctOppty.OppSignedWrittenConsentStatus__c = 'Requested';
            losingAcctOppty.OppSignedWrittenConsentRequestedDate__c = System.today().addDays(-10);
            losingAcctOppty.OppSignedWrittenConsentGrantedDate__c = null;
            losingAcctOppty.DateCaptured__c =  System.today().addDays(-10);
            insert losingAcctOppty;
            List<Task> taskList = new List<Task>();
            String taskDescription = 'Beginning this due date, consent has been provided to continue marketing efforts.Depending on the state, this can be a 30 day window or a 90 day window that you are able to market to the prospect';
            taskList.add(new Task (WhatId=winningAcctOpptyList[0].Id, OwnerId = salesRoleHierarchy1.Agent.id,ActivityDate = Date.today(),Description=taskDescription,TaskCategory__c='SignedWrittenConsent',AppCode__c = 'SFDC_MKTCLD'));
            taskList.add(new Task (WhatId=losingAcctOppty.Id, OwnerId = salesRoleHierarchy1.Agent.id,ActivityDate = Date.today(),Description=taskDescription,TaskCategory__c='SignedWrittenConsent',AppCode__c = 'SFDC_MKTCLD'));
            insert taskList;
            SignedWrittenConsent__c signedWrittenConsentRecord = new SignedWrittenConsent__c(Account__c = losingAcct.Id,RequestStartDate__c = System.Today()+10, Status__c = 'Requested',
                                                                                             RequestEndDate__c = System.Today()+90,InitiatedFromId__c = losingAcctOppty.Id);
            insert signedWrittenConsentRecord;
        }
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgOrcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = buildJSONForCombineProcessor(CLIENTID2, CLIENTID1,salesRoleHierarchy1.Agent.Associate_ID__C);
            stgOrcList.add(testStageOrchestration);
            test.startTest();
            new UTIL_CombineProcessor().execute(stgOrcList);
            test.stopTest();
        }
        Opportunity opptyRecord = [Select OppSignedWrittenConsentStatus__c,OppSignedWrittenConsentRequestedDate__c,
                                   OppSignedWrittenConsentGrantedDate__c,DateCaptured__c from Opportunity where Id = :losingAcctOppty.id];
        SignedWrittenConsent__c swcRecordAfterCombine = [Select Status__c from SignedWrittenConsent__c where InitiatedFromId__c = :losingAcctOppty.id LIMIT 1];
        Task taskRecordAfterCombine = [Select isClosed from Task where WhatId = :losingAcctOppty.id];
        System.assertEquals('Granted', opptyRecord.OppSignedWrittenConsentStatus__c , 'Opportunity SWC status is not as expected');
        System.assertEquals(System.today().addDays(-10), opptyRecord.OppSignedWrittenConsentRequestedDate__c, 'Opportunity SWC RequestedDate is not as expected');
        System.assertEquals(System.today().addDays(90), opptyRecord.OppSignedWrittenConsentGrantedDate__c, 'Opportunity SWC GrantedDate is not as expected');
        System.assertEquals(System.today().addDays(10), opptyRecord.DateCaptured__c, 'Opportunity DateCaptured is not as expected');
        System.assertEquals('Not Applicable', swcRecordAfterCombine.Status__c, 'Signed Written Consnet Status is not as expected');
        System.assert(taskRecordAfterCombine.isClosed, 'Task is not closed');
    }

    //test method to verify swc data not updated on losing account opportunities, swc tasks are not closed and swc records
    //status did not get updated if losing account opportunities office does not match winning account opportunities office
    @isTest
    private static void testSwcDataNotUpdatedOnCombine(){
        getUsers();
        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(CLIENTID1));
        accountList.add(createAccount(CLIENTID2));
        Opportunity losingAcctOppty;
        System.runas(systemUser){
            CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c = true);
            insert passTriggerAll;
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;
            Account losingAcct = [Select Id from Account where ClientIdentifier__c=:CLIENTID2];
            losingAcctOppty = createOpportunity(losingAcct.id, salesRoleHierarchy1.Agent.id,salesRoleHierarchy1.agentOffice.id);
            insert losingAcctOppty;
            String taskDescription = 'Beginning this due date, consent has been provided to continue marketing efforts.Depending on the state, this can be a 30 day window or a 90 day window that you are able to market to the prospect';
            Task taskRecord = new Task (WhatId=losingAcctOppty.Id, OwnerId = salesRoleHierarchy1.Agent.id,ActivityDate = Date.today(),Description= taskDescription, TaskCategory__c='SignedWrittenConsent',AppCode__c = 'SFDC_MKTCLD');
            insert taskRecord;
            SignedWrittenConsent__c signedWrittenConsentRecord = new SignedWrittenConsent__c(Account__c = losingAcct.Id,RequestStartDate__c = System.Today()+10, Status__c = 'Requested',
                                                                                             RequestEndDate__c = System.Today()+90,InitiatedFromId__c = losingAcctOppty.Id);
            insert signedWrittenConsentRecord;
        }
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgOrcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = buildJSONForCombineProcessor(CLIENTID2, CLIENTID1,salesRoleHierarchy1.Agent.Associate_ID__C);
            stgOrcList.add(testStageOrchestration);
            test.startTest();
            new UTIL_CombineProcessor().execute(stgOrcList);
            test.stopTest();
        }
        Opportunity opptyRecord = [Select OppSignedWrittenConsentStatus__c,OppSignedWrittenConsentRequestedDate__c,
                                   OppSignedWrittenConsentGrantedDate__c,DateCaptured__c from Opportunity where Id = :losingAcctOppty.id];
        SignedWrittenConsent__c swcRecordAfterCombine = [Select Status__c from SignedWrittenConsent__c where InitiatedFromId__c = :losingAcctOppty.id LIMIT 1];
        Task taskRecordAfterCombine = [Select isClosed from Task where WhatId = :losingAcctOppty.id];
        System.assertEquals('Granted', opptyRecord.OppSignedWrittenConsentStatus__c , 'Opportunity SWC status is not as expected');
        System.assertEquals(System.today().addDays(-10), opptyRecord.OppSignedWrittenConsentRequestedDate__c, 'Opportunity SWC RequestedDate is not as expected');
        System.assertEquals(System.today().addDays(90), opptyRecord.OppSignedWrittenConsentGrantedDate__c, 'Opportunity SWC GrantedDate is not as expected');
        System.assertEquals(System.today().addDays(10), opptyRecord.DateCaptured__c, 'Opportunity DateCaptured is not as expected');
        System.assertEquals('Requested', swcRecordAfterCombine.Status__c, 'Signed Written Consnet Status is not as expected');
        System.assert(!taskRecordAfterCombine.isClosed, 'Task is closed');
    }

    //test method to verify swc data cleared on opportunities, swc records status is updated to
    //not applicable after remove from book
    @isTest
    private static void testSwcDataClearedOnRemoveFromBook(){
        getUsers();
        Account acctRecord = createAccount(CLIENTID1);
        Opportunity opptyRecord;
        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert acctRecord;
            Account acctRec = [Select Id from Account where ClientIdentifier__c = :CLIENTID1];
            AgentRole__c agentRoleRecord = new AgentRole__c(customer__c=acctRec.id, agent__c=salesRoleHierarchy1.Agent.id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_ID__C+'~'+CLIENTID1);
            insert agentRoleRecord;
            opptyRecord = createOpportunity(acctRec.id, salesRoleHierarchy1.Agent.id,salesRoleHierarchy1.agentOffice.id);
            insert opptyRecord;
            SignedWrittenConsent__c signedWrittenConsentRecord = new SignedWrittenConsent__c(Account__c = acctRec.Id,RequestStartDate__c = System.Today()+10, Status__c = 'Requested',
                                                                                             RequestEndDate__c = System.Today()+90,InitiatedFromId__c = opptyRecord.Id);
            insert signedWrittenConsentRecord;
        }
        List<StageOrchestration__c> stgOrcList = new List<StageOrchestration__c>();
        StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        testStageOrchestration.TransactionType__c = UTIL_StageOrchestrationConstants.REMOVE_FROM_BOOK_TRANSACTION;
        testStageOrchestration.Value__c = UTIL_RemoveFromBookProcessor_Test.buildJsonString(CLIENTID1, salesRoleHierarchy1.Agent.Associate_ID__c);
        stgOrcList.add(testStageOrchestration);

        System.runAs(testAPIUser) {
            test.startTest();
            new UTIL_RemoveFromBookProcessor().execute(stgOrcList);
            test.stopTest();
        }

        Opportunity oppRecordAfterRemoveFromBook = [Select OppSignedWrittenConsentStatus__c,OppSignedWrittenConsentRequestedDate__c,
                                                    OppSignedWrittenConsentGrantedDate__c,DateCaptured__c from Opportunity where Id = :opptyRecord.id];
        SignedWrittenConsent__c swcRecordAfterRemoveFromBook = [Select Status__c from SignedWrittenConsent__c where InitiatedFromId__c = :opptyRecord.id LIMIT 1];
        System.assertEquals(null, oppRecordAfterRemoveFromBook.OppSignedWrittenConsentStatus__c , 'Opportunity SWC status is not as expected');
        System.assertEquals(null, oppRecordAfterRemoveFromBook.OppSignedWrittenConsentRequestedDate__c, 'Opportunity SWC RequestedDate is not as expected');
        System.assertEquals(null, oppRecordAfterRemoveFromBook.OppSignedWrittenConsentGrantedDate__c, 'Opportunity SWC GrantedDate is not as expected');
        System.assertEquals(null, oppRecordAfterRemoveFromBook.DateCaptured__c, 'Opportunity DateCaptured is not as expected');
        System.assertEquals('Not Applicable', swcRecordAfterRemoveFromBook.Status__c, 'Signed Written Consnet Status is not as expected');
    }

    //method to get user data
    private static void getUsers(){
        systemUser = [SELECT Id FROM User where username='systemAdminTest@statefarm.com' ];
        testAPIUser = [SELECT Id FROM User where username='apiOnly103@statefarm.com' ];
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
    }


    //method to build opportunity
    private static Opportunity createOpportunity(Id paramAccountId, Id agentId,Id ownerId){

        String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();

        Opportunity opptyRecord = new Opportunity (Name='testOppty', AccountId = paramAccountId,RecordTypeId = optyRecordTypeId,Assigned_To__c = agentId,
                                                   StageName='New', LOB__c='Auto', OwnerId = ownerId, CloseDate= System.today().addDays(10),
                                                   OppSignedWrittenConsentStatus__c = 'Granted', OppSignedWrittenConsentRequestedDate__c =
                                                   System.today().addDays(-10), OppSignedWrittenConsentGrantedDate__c = System.today().addDays(90),
                                                   DateCaptured__c = System.today().addDays(10),Opportunity_Originator__c='Agent/ATM');

        return opptyRecord;
    }

    //method to build account
    private static Account createAccount(String clientIdentifier){
        Account getAccount = new Account(FirstName = 'tst1',LastName='Ltst'+clientIdentifier, ExternalSourceSyncTime__c = DateTime.newInstance(2006, 3, 16, 23, 0, 0) , ClientIdentifier__c = clientIdentifier);
        return getAccount;
    }

    //method to build Account Owner custom setting record with the given parameter value
    private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
        return actOwnerCs;
    }

    //method used to assign a particular PermissionSet to a particular User
    private static void assignPermissionSet(User testUser){
        PermissionSet permSet = [Select Id, Name FROM PermissionSet WHERE Name=:UTIL_StageOrchestrationConstants.STAGE_ORCHESTRATION_PERMISSION_SET_NAME];
        PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = permSet.Id);
        insert permSetAssignment;
    }

    //method to create environment url custom setting
    private static void createCustomSettingForEnvironmentURLData () {
        CS_EnvironmentURLCustomSetting__c envUrlCs = new CS_EnvironmentURLCustomSetting__c();
        envUrlCs.name = 'ICP_TP_ENV';
        envUrlCs.value__c = 'unittest.statefarm.com';
        insert envUrlCs;
    }

    private static String buildJsonForSeparateProcessor(String originalClientId, String newClientId,  String externalSourceSyncTime) {
        return
            '{'+
            '   "orchestrationInfo":{'+
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+originalClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":null,'+
            '                  "Phone":0,'+
            '                  "IsNotShareable":"N",'+
            '                  "PersonMobilePhone":0,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsSubjecttoCASL":"N",'+
            '                  "ShippingState":"",'+
            '                  "IsPrivacyOptionsShared":"N",'+
            '                  "LastName":"STURZL ",'+
            '                  "PaperlessPrivacyNotice":"N",'+
            '                  "BillingState":"WI",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"54946",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"ALICE ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "IsProtectedPerson":"N",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":" ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"422 BELL AVE ",'+
            '                  "PersonBirthdate":"1926-09-26",'+
            '                  "DriversLicenseStateProvince":null,'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":"",'+
            '                  "MailingInCareOf":"",'+
            '                  "PreferredSpokenLanguage":"",'+
            '                  "PersonHomePhone":7154860544,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"KING ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":null,'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+newClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":"Valid",'+
            '                  "Phone":0,'+
            '                  "IsNotShareable":"N",'+
            '                  "PersonMobilePhone":2259070877,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsSubjecttoCASL":"N",'+
            '                  "ShippingState":"",'+
            '                  "IsPrivacyOptionsShared":"Y",'+
            '                  "LastName":"BROWN ",'+
            '                  "PaperlessPrivacyNotice":"N",'+
            '                  "BillingState":"LA",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"70769",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"BOBBY ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "IsProtectedPerson":"N",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":"3215 ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"36339 LORENA DR ",'+
            '                  "PersonBirthdate":"1971-10-14",'+
            '                  "DriversLicenseStateProvince":"LOUISIANA ",'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":" ",'+
            '                  "MailingInCareOf":"",'+
            '                  "PreferredSpokenLanguage":"",'+
            '                  "PersonHomePhone":2256738477,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"PRAIRIEVILLE ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchy1.Agent.Associate_Id__C+'~'+originalClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+originalClientId+'",'+
            '                  "RelationshipNature":"Ex-Customer",'+
            '                  "StartDate":"2006-08-08",'+
            '                  "Agent":"'+salesRoleHierarchy1.Agent.Associate_Id__C+'",'+
            '                  "HouseholdGroupId":"HouseholdA1"'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchy1.Agent.Associate_Id__C+'~'+newClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+newClientId+'",'+
            '                  "RelationshipNature":"Ex-Customer",'+
            '                  "StartDate":"2006-08-08",'+
            '                  "Agent":"'+salesRoleHierarchy1.Agent.Associate_Id__C+'",'+
            '                  "HouseholdGroupId":"HouseholdA2"'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '           "orchestrationNameDetail": {'+
            '               "dataName": "Customer2Customer",'+
            '               "dataDeleteIndicator": false,'+
            '               "dataExternalKey": "RelationshipIdentifier",'+
            '               "externalSourceSyncTime": "2017-06-07T19:17:57.182+0000",'+
            '               "dataExternalKeyValue": "'+originalClientId+'~'+newClientId+'",'+
            '               "orchestrationDataValues": {'+
            '                   "Customer": "'+originalClientId+'",'+
            '                   "RelationshipNature": "Other - Non-Relative",'+
            '                   "StartDate": "2012-01-10",'+
            '                   "RelationWith": "'+newClientId+'"'+
            '               }'+
            '           }'+
            '       },'+
            '       {'+
            '           "orchestrationNameDetail": {'+
            '               "dataName": "Customer2Customer",'+
            '               "dataDeleteIndicator": false,'+
            '               "dataExternalKey": "RelationshipIdentifier",'+
            '               "externalSourceSyncTime": "2017-06-07T19:17:57.182+0000",'+
            '               "dataExternalKeyValue": "'+newClientId+'~'+originalClientId+'",'+
            '               "orchestrationDataValues": {'+
            '                   "Customer": "'+newClientId+'",'+
            '                   "RelationshipNature": "Other - Non-Relative",'+
            '                   "StartDate": "2012-01-10",'+
            '                   "RelationWith": "'+originalClientId+'" '+
            '               }'+
            '           }'+
            '       }'+
            '      ],'+
            '      "orchestrationEventName":{'+
            '         "orchestrationEventType":"Separate Customer Record",'+
            '         "orchestrationEventDetail":{'+
            '            "orchestrationEventValues":{'+
            '               "ClientId1" : "'+originalClientId+'", '+
            '               "ClientId2":"'+newClientId+'"'+
            '            }'+
            '         }'+
            '      }'+
            '   }'+
            '}';
    }

    private static String buildJSONForCombineProcessor(String lclientId, String wcliendId,String assocId) {
        String externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
        return
            '{'+
            '  "orchestrationInfo" : {'+
            '    "jsonVersionNumber" : "1.0",'+
            '    "orchestrationDataName" : [ {'+
            '      "orchestrationNameDetail" : {'+
            '        "dataName" : "Account",'+
            '        "dataDeleteIndicator" : false,'+
            '        "dataExternalKey" : "clientId",'+
            '        "externalSourceSyncTime" : "'+externalSyncTime+'",'+
            '        "dataExternalKeyValue" : "'+wcliendId+'",'+
            '        "orchestrationDataValues" : {'+
            '          "RecordTypeId" : "Individual",'+
            '          "PersonEmailBouncedReason" : "",'+
            '          "Phone" : 3472730865,'+
            '          "IsNotShareable" : "N",'+
            '          "PersonMobilePhone" : 0,'+
            '          "HasConfirmedNoEmail" : true,'+
            '          "IsSubjecttoCASL" : "N",'+
            '          "ShippingState" : "",'+
            '          "IsPrivacyOptionsShared" : "Y",'+
            '          "LastName" : "Hkhk",'+
            '          "PaperlessPrivacyNotice" : "N",'+
            '          "BillingState" : "VA",'+
            '          "EmployerName" : "",'+
            '          "TDDPhone" : 0,'+
            '          "BillingPostalCode" : "235231223",'+
            '          "OccupationStatus" : "Full-time",'+
            '          "Occupation" : "Other",'+
            '          "ShippingCity" : "",'+
            '          "FirstName" : "GIOVAN",'+
            '          "MaritalStatus" : "Married",'+
            '          "Military" : "No",'+
            '          "IsDeathNotificationReceived" : "false",'+
            '          "IsProtectedPerson" : "N",'+
            '          "IsHearingImpaired" : "true",'+
            '          "Citizenship" : "",'+
            '          "BillingCountry" : "UNITED STATES",'+
            '          "ShippingCountry" : "",'+
            '          "BillingAddressType" : "USAddress",'+
            '          "ShippingStreet" : "",'+
            '          "SSN" : "0000",'+
            '          "Suffix" : " ",'+
            '          "BillingStreet" : "120 W BERKLEY AVE",'+
            '          "PersonBirthdate" : "1984-03-09",'+
            '          "DriversLicenseStateProvince" : "VIRGINIA",'+
            '          "ShippingAddressType" : "",'+
            '          "DriversLicenseNumber" : "6789",'+
            '          "MailingInCareOf" : "",'+
            '          "PreferredSpokenLanguage" : "",'+
            '          "PersonHomePhone" : 3472730865,'+
            '          "PreferredFirstName" : null,'+
            '          "MiddleName" : "",'+
            '          "BillingCity" : "NORFOLK",'+
            '          "MailingAttention":" ",'+
            '          "Gender" : "Female",'+
            '          "ShippingPostalCode" : "",'+
            '          "PersonEmail" : "DWRD747@AUTOFILL.COM",'+
            '          "Designation" : " "'+
            '        }'+
            '      }'+
            '    }, {'+
            '      "orchestrationNameDetail" : {'+
            '        "dataName" : "Agent Role",'+
            '        "dataDeleteIndicator" : false,'+
            '        "dataExternalKey" : "AgentRoleIdentifier",'+
            '        "externalSourceSyncTime" : "2016-09-22T04:32:55.906+0000",'+
            '        "dataExternalKeyValue" : "'+assocId+'~'+wcliendId+'", '+
            '        "orchestrationDataValues" : {'+
            '          "Customer" : "'+wcliendId+'",'+
            '          "RelationshipNature" : "Ex-Client", '+
            '          "StartDate" : "2013-09-24",'+
            '          "Agent" : "'+assocId+'",'+
            '          "HouseholdGroupId":"HouseholdA1"'+
            '        }'+
            '      }'+
            '    } ],'+
            '    "orchestrationEventName" : {'+
            '      "orchestrationEventType" : "Combine Customer Record",'+
            '      "orchestrationEventDetail" : {'+
            '        "orchestrationEventValues" : {'+
            '          "lClientId" : "'+lclientId+'", '+
            '          "wClientId" : "'+wcliendId+'" '+
            '        }'+
            '      }'+
            '    }'+
            '  }'+
            '}';
    }
}