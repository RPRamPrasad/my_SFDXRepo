/**
@author Team Skynet
@name AQ_WorkAutoCloseHandlerTest
@createDate 4/12/2023
@description Handles testing for AQ_WorkAutoCloseHandler class
*/
@isTest
public with sharing class AQ_WorkAutoCloseHandlerTest {
    @TestVisible private static final String ACCOUNT_A_CLIENT_ID = '12345678915';
    @TestVisible private static final String ACCOUNT_Z_CLIENT_ID = '12345678966';
    private static Account accountRecordA {get;set;}
    private static Account accountRecordZ {get;set;}
    private static User agentUser {get;set;}
    private static User atmUser {get;set;}
    private static User sysAdmin {get;set;}

    @testSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();

        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            //Setup Configuration - Bypass Triggers
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,TestUserSetupUtility.getSysAdminUser());
            insert passTriggerAll;
            CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(TestUserSetupUtility.getSysAdminUser());

            insert objectBasedByPassTrigger;

            //Setup Users + Accounts
            accountRecordA = createAccount(ACCOUNT_A_CLIENT_ID,'A');
            accountRecordZ = createAccount(ACCOUNT_Z_CLIENT_ID,'Z');
            agentUser = TestUserSetupUtility.getAgentUser();
            atmUser = TestUserSetupUtility.getAtmUser();
            setupAgentRole(agentUser, accountRecordA);
            setupAgentRole(atmUser, accountRecordZ);

            sysAdmin = TestUserSetupUtility.getSysAdminUser();
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

            //Setup Permission Sets
            //!!Temporary perm set used for development, should be AgentQueue
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'AgentQueue_Support_W'];
            insert new PermissionSetAssignment(AssigneeId = agentUser.id, PermissionSetId = ps.Id);
            insert new PermissionSetAssignment(AssigneeId = atmUser.id, PermissionSetId = ps.Id);
            insert new PermissionSetAssignment(AssigneeId = sysAdmin.id, PermissionSetId = ps.Id);
        }
    }

    @TestVisible private static Account createAccount(String clientId, String lastNamePrefix){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='AstName',LastName=lastNamePrefix+'lstName',
                                            BillingAddressType__c='US',BillingCity='Phoenix',
                                            ClientIdentifier__c=clientId);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
        return accountRecord;
    }

    @TestVisible private static Account getAccount(String clientId){
        return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE  ClientIdentifier__c =: clientId];
    }

    @TestVisible private static void setupAgentRole(User userRecord, Account accountRecord){
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c = userRecord.Id;
        agentRole.Customer__c = accountRecord.Id;
        agentRole.RelationshipNature__c = 'Customer';
        insert agentRole;
    }

    @TestVisible private static AQ_AutoCompletionRule__c createAutoCompletion(User assignUser, List<String> dataParams) {
        AQ_AutoCompletionRule__c autoCompletion = new AQ_AutoCompletionRule__c(
            Subject_Stored__c = !String.isBlank(dataParams[0]) ? dataParams[0] : 'BOD Address Change',
            User__c = assignUser.Id,
            Active__c = true
        );
        insert autoCompletion;
        return autoCompletion;
    }
    @TestVisible private static List<SObject> createSObjectList(String clientId, List<String> taskSubjectList) {
        List<SObject> objList = new List<SObject>();
        for (String subject : taskSubjectList) {
            Task sampleTask = new Task();
            sampleTask.WhatId = getAccount(clientId).Id;
            sampleTask.OwnerId = TestUserSetupUtility.getProxyUser().Id;
            sampleTask.Subject = subject;
            sampleTask.Status = 'Not Started';
            sampleTask.CreatedClosed__c = false;
            sampleTask.Priority = 'Low';
            sampleTask.LineofBusiness__c = 'Auto';
            sampleTask.ActivityDate = System.today();
            objList.add(sampleTask);
        }


        List<Id> objIdList = new List<Id>();
        List<Database.SaveResult> results = Database.insert(objList);

        for(Database.SaveResult result : results) {
            objIdList.add(result.getId());
        }
        List<SObject> tasksToComplete = Security.stripInaccessible(AccessType.READABLE,
                                                                    [SELECT Id, Subject, Status, OwnerId, CreatedClosed__c
                                                                    FROM Task
                                                                    WHERE Id
                                                                    IN :objIdList
                                                                    WITH SECURITY_ENFORCED]).getRecords();

        List<SObject> sObjList = new List<SObject>();
        sObjList.addAll(tasksToComplete);

        return sObjList;
    }
    @isTest
    public static void testCompleteTasksSuccessful() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'xyz';
        update agent_User;
        AQ_AutoCompletionRule__c agentTestRule;
        List<SObject> objList = new List<SObject>();
        List<SObject> objsReturned;

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            objList = createSObjectList(ACCOUNT_A_CLIENT_ID, subjects);
            List<String> workParams = new List<String>();
            workParams.add('BOD Address Change');
            agentTestRule = createAutoCompletion(agent_User,workParams);
            objsReturned = AQ_WorkAutoCloseHandler.completeRulesForUsers(objList);
        }

        for (SObject record : objsReturned) {
            Schema.SObjectType sObjectType = record.getSObjectType();
            if (sObjectType == Task.getSObjectType()) {
                Task taskFound = (Task) record;
                System.assertEquals('Not Started', taskFound.Status, 'Unexepected Status');
                System.assertEquals(false, taskFound.CreatedClosed__c, 'Unexepected CreatedClosed__c Status');
            }
        }
        System.assertEquals(objList.size(), objsReturned.size(), 'List of objects sizes do not match');
    }
        @isTest
    public static void testAutoCloseTaskSuccessfully() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'xyz';
        update agent_User;
        AQ_AutoCompletionRule__c agentTestRule;
        List<SObject> objList = new List<SObject>();
        List<SObject> objsReturned;

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            objList = createSObjectList(ACCOUNT_A_CLIENT_ID, subjects);
            List<String> workParams = new List<String>();
            workParams.add('BOD Address Change');
            agentTestRule = createAutoCompletion(agent_User,workParams);
            objsReturned = AQ_WorkAutoCloseHandler.completeRulesForUsers(objList);
        }

        System.assertEquals(0, objsReturned.size(), 'List of objects sizes do not match');
    }

    @isTest
    public static void testCompleteTasksNoMatchingRule() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        List<SObject> objList = new List<SObject>();
        List<SObject> objsReturned;
        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            objList = createSObjectList(ACCOUNT_A_CLIENT_ID, subjects);
            objsReturned = AQ_WorkAutoCloseHandler.completeRulesForUsers(objList);
        }
        Test.stopTest();

        List<Task> completedTasks = [SELECT Id, Status, CreatedClosed__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(1, completedTasks.size(), 'number of tasks ==1' );
        System.assertEquals('Not Started', completedTasks.get(0).Status, 'Unexpected Status, value should be Not Started when no Rule matches');
        System.assertEquals(objList.size(), objsReturned.size(), 'List of objects sizes do not match');

    }

    @isTest
    private static void testConstructor(){
        AQ_WorkAutoCloseHandler aqInstance = new AQ_WorkAutoCloseHandler();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

}