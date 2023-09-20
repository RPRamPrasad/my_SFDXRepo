/**
@author Team Skynet
@name AQ_WorkAssignmentHandlerTest
@createDate 2/10/2023
@description Handles testing for AQ_TaskWorkAssignmentHandler class
*/

@isTest
public with sharing class AQ_WorkAssignmentHandlerTest {
    private static AQ_WorkAssignmentHandlerTestWrapper aqw = new AQ_WorkAssignmentHandlerTestWrapper();
    @TestVisible private static final String ACCOUNT_A_CLIENT_ID = '12345678915';
    @TestVisible private static final String ACCOUNT_Z_CLIENT_ID = '12345678966';
    @TestVisible private static final String OPPORTUNITY_RECORD_TYPE_ID_OPPORTUNITY_MANAGEMENT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();
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
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser, atmUser});
            //Setup Permission Sets
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'AgentQueue'];
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

    @TestVisible private static Opportunity createOpportunity(Account accountRecord, User userRecord){
        Opportunity opp = new Opportunity();
        opp.AccountId = accountRecord.Id;
        opp.LOB__c = 'Auto';
        opp.ContactId = accountRecord.PersonContactId;
        opp.OwnerId = userRecord.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'New';
        opp.CloseDate = Date.today();
        opp.RecordTypeId = OPPORTUNITY_RECORD_TYPE_ID_OPPORTUNITY_MANAGEMENT;

        return opp;
    }
    @TestVisible private static Lead createLead(User userRecord){
        Lead lead = new Lead();
        lead.OwnerId = userRecord.Id;
        lead.LastName = 'Turner';
        lead.NonCustomerReferrer__c= 'Billy';


        return lead;
    }

    @TestVisible private static AQ_WorkAssignmentRule__c createWorkAssignmentAssigned(User assignUser, List<String> dataParams) {
        AQ_WorkAssignmentRule__c workAssignment = new AQ_WorkAssignmentRule__c(
            StartAlpha__c = !String.isBlank(dataParams[0]) ? dataParams[0] : 'A',
            EndAlpha__c = !String.isBlank(dataParams[1]) ? dataParams[1] : 'M',
            LOB_Stored__c = !String.isBlank(dataParams[2]) ? dataParams[2] : 'Auto',
            Task_Subject__c = !String.isBlank(dataParams[3]) ? dataParams[3] : 'BOD Address Change',
            User__c = assignUser.Id,
            LastAssignedDateTime__c = DateTime.now()
        );
        insert workAssignment;
        return workAssignment;
    }
    @TestVisible private static AQ_WorkAssignmentRule__c createWorkAssignmentMissingFields(User assignUser,List<String> dataParams) {
        AQ_WorkAssignmentRule__c workAssignment = new AQ_WorkAssignmentRule__c(
            StartAlpha__c = !String.isBlank(dataParams[0]) ? dataParams[0] : '',
            EndAlpha__c = !String.isBlank(dataParams[1]) ? dataParams[1] : '',
            LOB_Stored__c = !String.isBlank(dataParams[2]) ? dataParams[2] : '',
            Task_Subject__c = !String.isBlank(dataParams[3]) ? dataParams[3] : '',
            User__c = assignUser.Id
        );
        insert workAssignment;
        return workAssignment;
    }

    @TestVisible private static List<Task> createTaskListNoWhatId(List<String> taskSubjectList) {
        List<Task> taskList = new List<Task>();
        aqw.createTaskListNoWhatIdtaskSubjectList(taskSubjectList, taskList);
        List<Id> taskIdList = new List<Id>();
        List<Database.SaveResult> results = Database.insert(taskList);
        aqw.createTaskListNoWhatIdSaveResult(taskIdList, results);
        /*List<Task> tasksToAssign = Security.stripInaccessible(AccessType.READABLE,
                                                                    [SELECT Id, Account.LastName, Subject, LineofBusiness__c, OwnerId
                                                                    FROM Task
                                                                    WHERE Id
                                                                    IN :taskIdList
                                                                    WITH SECURITY_ENFORCED]).getRecords();*/

        return Security.stripInaccessible(AccessType.READABLE,
                [SELECT Id, Account.LastName, Subject, LineofBusiness__c, OwnerId
                FROM Task
                WHERE Id
                IN :taskIdList
                WITH SECURITY_ENFORCED]).getRecords();
    }

    @TestVisible private static List<SObject> createSObjectList(String clientId, List<String> taskSubjectList) {
        List<SObject> objList = new List<SObject>();
        aqw.createSObjectListTaskSubjectList(taskSubjectList, objList, clientId);
        Opportunity opp = createOpportunity(getAccount(clientId), TestUserSetupUtility.getProxyUser());
        objList.add(opp);

        Lead lead = createLead(TestUserSetupUtility.getProxyUser());
        objList.add(lead);

        List<Id> objIdList = new List<Id>();
        List<Database.SaveResult> results = Database.insert(objList);
        aqw.createSObjectListSaveResult(objIdList, results);
        List<SObject> tasksToAssign = Security.stripInaccessible(AccessType.READABLE,
                                                                    [SELECT Id, Account.LastName, Subject, LineofBusiness__c, OwnerId, AssignedTo__c
                                                                    FROM Task
                                                                    WHERE Id
                                                                    IN :objIdList
                                                                    WITH SECURITY_ENFORCED]).getRecords();

        List<SObject> opportunitiesToAssign = Security.stripInaccessible(AccessType.READABLE,
                                                                    [SELECT Id, Account.LastName, StageName, OwnerId
                                                                    FROM Opportunity
                                                                    WHERE Id
                                                                    IN :objIdList
                                                                    WITH SECURITY_ENFORCED]).getRecords();
        List<SObject> leadsToAssign = Security.stripInaccessible(AccessType.READABLE,
                                                                    [SELECT Id, LastName, OwnerId, AssignedTo__c
                                                                    FROM Lead
                                                                    WHERE Id
                                                                    IN :objIdList
                                                                    WITH SECURITY_ENFORCED]).getRecords();


        List<SObject> sObjList = new List<SObject>();
        sObjList.addAll(tasksToAssign);
        sObjList.addAll(opportunitiesToAssign);
        sObjList.addAll(leadsToAssign);

        return sObjList;
    }

    @isTest
    public static void testAssignTasksToUsersSuccessful() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'xyz';
        update agent_User;
        AQ_WorkAssignmentRule__c agentTestRule;
        List<SObject> objList = new List<SObject>();
        List<SObject> objsReturned;

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            objList = createSObjectList(ACCOUNT_A_CLIENT_ID, subjects);
            List<String> workParams = new List<String>();
            workParams.add('A');
            workParams.add('M');
            workParams.add('Auto');
            workParams.add('BOD Address Change');
            agentTestRule = aqw.createWorkAssignment(agent_User,workParams);
            objsReturned = AQ_WorkAssignmentHandler.assignWorkToUsers(objList);
        }

        for (SObject record : objsReturned) {
            Schema.SObjectType sObjectType = record.getSObjectType();
            if (sObjectType == Task.getSObjectType()) {
                Task taskFound = (Task) record;
                System.assertEquals(agent_User.Id, taskFound.AssignedTo__c, 'Unexepected AssignedTo user');
            }
        }
        System.assertEquals(objList.size(), objsReturned.size(), 'List of objects sizes do not match');
    }

    @isTest
    public static void testAssignTasksToUsersNoMatchingRule() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        List<SObject> objList = new List<SObject>();
        List<SObject> objsReturned;
        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            objList = createSObjectList(ACCOUNT_A_CLIENT_ID, subjects);
            objsReturned = AQ_WorkAssignmentHandler.assignWorkToUsers(objList);
        }
        Test.stopTest();

       List<Task> assignedTasks = [SELECT Id, AssignedTo__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );
        System.assertEquals(null, assignedTasks.get(0).AssignedTo__c, 'Unexpected AssignedTo user, value should be null when no Rule matches');
        System.assertEquals(objList.size(), objsReturned.size(), 'List of objects sizes do not match');

    }
    @isTest
    public static void testAssignTasksToUsersNotAccountTask() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        AQ_WorkAssignmentRule__c agentTestRule;
        List<Task> taskList = new List<Task>();

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            taskList = createTaskListNoWhatId(subjects);
            List<String> workParams = new List<String>();
            workParams.add('A');
            workParams.add('M');
            workParams.add('Auto');
            workParams.add('BOD Address Change');
            agentTestRule = aqw.createWorkAssignment(agent_User,workParams);
            AQ_WorkAssignmentHandler.assignWorkToUsers(taskList);
        }
        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c FROM Task];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );
        System.assertEquals(null, assignedTasks.get(0).AssignedTo__c, 'Unexpected AssignedTo user');

    }
    @isTest
    public static void testAssignTasksToUsersPartialAlphaLastname() {
        //If only the EndAlpha is set, we treat it as no Alphas being set
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'abcd';
        User atm_User = TestUserSetupUtility.getAtmUser();
        atm_User.FederationIdentifier = 'Abc';
        AQ_WorkAssignmentRule__c agentTestRule;
        List<SObject> objList = new List<SObject>();
        List<SObject> objsReturned;

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            objList = createSObjectList(ACCOUNT_A_CLIENT_ID, subjects);
            List<String> workParams = new List<String>();
            workParams.add(null);
            workParams.add('M');
            workParams.add('Auto');
            workParams.add('BOD Address Change');
            agentTestRule = aqw.createWorkAssignment(atm_User,workParams);
            objsReturned = AQ_WorkAssignmentHandler.assignWorkToUsers(objList);
        }
        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );

        for (SObject record : objsReturned) {
            Schema.SObjectType sObjectType = record.getSObjectType();
            if (sObjectType == Task.getSObjectType()) {
                Task taskFound = (Task) record;
                System.assertEquals(null, taskFound.AssignedTo__c, 'Unexpected AssignedTo user, value should be null when no Rule matches');
            }
        }
        System.assertEquals(objList.size(), objsReturned.size(), 'List of objects sizes do not match');

    }
    @isTest
    public static void testAssignTasksToUserswithLastAssignedDateTime() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'xyz';
        update agent_User;
        User atm_User = TestUserSetupUtility.getAtmUser();
		AQ_WorkAssignmentRule__c agentTestRule;
        AQ_WorkAssignmentRule__c agentTestRule1;
        List<SObject> objList = new List<SObject>();
        List<SObject> objsReturned;
        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            objList = createSObjectList(ACCOUNT_A_CLIENT_ID, subjects);
            List<String> workParams = new List<String>();
            workParams.add('A');
            workParams.add('M');
            workParams.add('Auto');
            workParams.add('BOD Address Change');
            agentTestRule = createWorkAssignmentAssigned(agent_User,workParams);
            agentTestRule1 = createWorkAssignmentAssigned(atm_User,workParams);
            objsReturned = AQ_WorkAssignmentHandler.assignWorkToUsers(objList);
        }
        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );

        for (SObject record : objsReturned) {
            Schema.SObjectType sObjectType = record.getSObjectType();
            if (sObjectType == Task.getSObjectType()) {
                Task taskFound = (Task) record;
                System.assertEquals(agent_User.Id, taskFound.AssignedTo__c, 'Unexpected AssignedTo user');
            }
        }
        System.assertEquals(objList.size(), objsReturned.size(), 'List of objects sizes do not match');
    }

    @isTest
    public static void testAssignTasksToUsersWithStartAlpha() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        AQ_WorkAssignmentRule__c agentTestRule;
        List<SObject> objList = new List<SObject>();
        List<SObject> objsReturned;
        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            objList = createSObjectList(ACCOUNT_A_CLIENT_ID, subjects);
            List<String> workParams = new List<String>();
            workParams.add('A');
            workParams.add(null);
            workParams.add(null);
            workParams.add(null);
            agentTestRule = createWorkAssignmentMissingFields(agent_User,workParams);
            objsReturned = AQ_WorkAssignmentHandler.assignWorkToUsers(objList);
        }
        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );

        for (SObject record : objsReturned) {
            Schema.SObjectType sObjectType = record.getSObjectType();
            if (sObjectType == Task.getSObjectType()) {
                Task taskFound = (Task) record;
                System.assertEquals(null, taskFound.AssignedTo__c, 'Unexpected AssignedTo user');
            }
        }
        System.assertEquals(objList.size(), objsReturned.size(), 'List of objects sizes do not match');

    }
    @isTest
    public static void testAssignTasksToUsersWithSubject() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'xyz';
        update agent_User;
        AQ_WorkAssignmentRule__c agentTestRule;
        List<SObject> objList = new List<SObject>();
        List<SObject> objsReturned;

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            objList = createSObjectList(ACCOUNT_A_CLIENT_ID, subjects);
            List<String> workParams = new List<String>();
            workParams.add(null);
            workParams.add(null);
            workParams.add(null);
            workParams.add('BOD Address Change');
            agentTestRule = createWorkAssignmentMissingFields(agent_User,workParams);
            objsReturned = AQ_WorkAssignmentHandler.assignWorkToUsers(objList);
        }
        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );

        for (SObject record : objsReturned) {
            Schema.SObjectType sObjectType = record.getSObjectType();
            if (sObjectType == Task.getSObjectType()) {
                Task taskFound = (Task) record;
                System.assertEquals(agent_User.id, taskFound.AssignedTo__c, 'Unexpected AssignedTo user');
            }
        }
        System.assertEquals(objList.size(), objsReturned.size(), 'List of objects sizes do not match');
    }

    @isTest
    public static void testAssignTasksToUserswithNoMatchingAccount() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        AQ_WorkAssignmentRule__c agentTestRule;
        List<SObject> objList = new List<SObject>();
        List<SObject> objsReturned;
        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            objList = createSObjectList(ACCOUNT_Z_CLIENT_ID, subjects);
            List<String> workParams = new List<String>();
            workParams.add('A');
            workParams.add('M');
            workParams.add('Auto');
            workParams.add('BOD Address Change');
            agentTestRule = aqw.createWorkAssignment(agent_User,workParams);
            objsReturned = AQ_WorkAssignmentHandler.assignWorkToUsers(objList);
        }
        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c FROM Task];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );

        for (SObject record : objsReturned) {
            Schema.SObjectType sObjectType = record.getSObjectType();
            if (sObjectType == Task.getSObjectType()) {
                Task taskFound = (Task) record;
                System.assertEquals(null, taskFound.AssignedTo__c, 'Unexpected AssignedTo user');
            }
        }
        System.assertEquals(objList.size(), objsReturned.size(), 'List of objects sizes do not match');

    }
    private class AQ_WorkAssignmentHandlerTestWrapper{
        private void createTaskListNoWhatIdtaskSubjectList(List<String> taskSubjectList, List<Task> taskList)
        {
            for (String subject : taskSubjectList) {
                Task sampleTask = new Task();
                sampleTask.OwnerId = TestUserSetupUtility.getProxyUser().Id;
                sampleTask.Subject = 'BOD Address Change';
                sampleTask.Status = 'Not Started';
                sampleTask.Priority = 'Low';
                sampleTask.LineofBusiness__c = 'Auto';
                sampleTask.ActivityDate = System.today();
                taskList.add(sampleTask);
            }
        }
        private void createTaskListNoWhatIdSaveResult(List<Id> taskIdList, List<Database.SaveResult> results)
        {
            for(Database.SaveResult result : results) {
                taskIdList.add(result.getId());
            }
        }
        private void createSObjectListTaskSubjectList(List<String> taskSubjectList, List<SObject> objList, String clientId)
        {
            for (String subject : taskSubjectList) {
                 Task sampleTask = new Task();
                 sampleTask.WhatId = getAccount(clientId).Id;
                 sampleTask.OwnerId = TestUserSetupUtility.getProxyUser().Id;
                 sampleTask.Subject = subject;
                 sampleTask.Status = 'Not Started';
                 sampleTask.Priority = 'Low';
                 sampleTask.LineofBusiness__c = 'Auto';
                 sampleTask.ActivityDate = System.today();
                 objList.add(sampleTask);
             }
        }
        private void createSObjectListSaveResult(List<Id> objIdList,  List<Database.SaveResult> results)
        {
            for(Database.SaveResult result : results) {
                objIdList.add(result.getId());
            }
        }

        @TestVisible private AQ_WorkAssignmentRule__c createWorkAssignment(User assignUser, List<String> dataParams) {
            AQ_WorkAssignmentRule__c workAssignment = new AQ_WorkAssignmentRule__c(
                StartAlpha__c = !String.isBlank(dataParams[0]) ? dataParams[0] : 'A',
                EndAlpha__c = !String.isBlank(dataParams[1]) ? dataParams[1] : 'M',
                LOB_Stored__c = !String.isBlank(dataParams[2]) ? dataParams[2] : 'Auto',
                Task_Subject__c = !String.isBlank(dataParams[3]) ? dataParams[3] : 'BOD Address Change',
                User__c = assignUser.Id
            );
            insert workAssignment;
            return workAssignment;
        }

    }

}
