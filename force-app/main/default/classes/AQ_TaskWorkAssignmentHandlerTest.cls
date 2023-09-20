/**
@author Team Skynet
@name AQ_WorkAssignmentPreferencesHandlerTest
@createDate 11/11/2022
@description Handles testing for AQ_TaskWorkAssignmentHandler class
*/

@isTest
public with sharing class AQ_TaskWorkAssignmentHandlerTest {
    @TestVisible private static final String ACCOUNT_A_CLIENT_ID = '12345678915';
    @TestVisible private static final String ACCOUNT_Z_CLIENT_ID = '12345678966';
    private static Account accountRecordA {get;set;}
    private static Account accountRecordZ {get;set;}
    private static User agentUser {get;set;}
    private static User atmUser {get;set;}
    private static User sysAdmin {get;set;}
    private static User aqProcId {get;set;}

    @testSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        TestUserSetupUtility.setupApiOnlyUser();

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
            setupAgentRole(agentUser, accountRecordZ);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser, atmUser});

            sysAdmin = TestUserSetupUtility.getSysAdminUser();
            aqProcId = TestUserSetupUtility.getApiOnlyUser();

            //Setup Permission Sets
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'AgentQueue'];
            insert new PermissionSetAssignment(AssigneeId = agentUser.id, PermissionSetId = ps.Id);
            insert new PermissionSetAssignment(AssigneeId = atmUser.id, PermissionSetId = ps.Id);

            PermissionSet psProcessId = [SELECT Id FROM PermissionSet WHERE Name = 'SF_CRM_AGENTQUEUE_PermSetPID'];
            insert new PermissionSetAssignment(AssigneeId = aqProcId.id, PermissionSetId = psProcessId.Id);
        }
    }

    @TestVisible private static void saveCustomSettingConfiguration(){
        List<CS_AGENTQUEUE_Config__c> agentQueueConfigList = new List<CS_AGENTQUEUE_Config__c>();
        CS_AGENTQUEUE_Config__c agentQueueConfigHours = new CS_AGENTQUEUE_Config__c();
        agentQueueConfigHours.Name = 'BatchAgentQueueHoursBehind';
        agentQueueConfigHours.Value__c = 1;
        DateTime startTime =  DateTime.now().addHours(-4);
        agentQueueConfigHours.TaskBatchStartTime__c = startTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        agentQueueConfigList.add(agentQueueConfigHours);
        List<Database.SaveResult> csUpdateResults = Database.insert(Security.stripInaccessible(AccessType.UPDATABLE, agentQueueConfigList, true).getRecords(), false);
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
        return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE  ClientIdentifier__c =: clientId LIMIT 1];
    }

    @TestVisible private static void setupAgentRole(User userRecord, Account accountRecord){
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c = userRecord.Id;
        agentRole.Customer__c = accountRecord.Id;
        agentRole.RelationshipNature__c = 'Customer';
        insert agentRole;
    }

    @TestVisible private static AQ_WorkAssignmentRule__c createWorkAssignment(User assignUser, List<String> dataParams,boolean isAssigned) {
        AQ_WorkAssignmentRule__c workAssignment = new AQ_WorkAssignmentRule__c(
            StartAlpha__c = !String.isBlank(dataParams[0]) ? dataParams[0] : '', //A
            EndAlpha__c = !String.isBlank(dataParams[1]) ? dataParams[1] : '', //M
            LOB_Stored__c = !String.isBlank(dataParams[2]) ? dataParams[2] : '', //Auto
            Task_Subject__c = !String.isBlank(dataParams[3]) ? dataParams[3] : '', //BOD Address Change
            User__c = assignUser.Id
        );

        if(isAssigned){
            workAssignment.LastAssignedDateTime__c = DateTime.now();
        }
        insert workAssignment;
        return workAssignment;
    }

    @TestVisible private static List<Task> createTaskList(String clientId, String lob, List<String> taskSubjectList) {
        List<Task> taskList = new List<Task>();
        for (String subject : taskSubjectList) {
            Task sampleTask = new Task();
            sampleTask.WhatId = getAccount(clientId).Id;
            sampleTask.OwnerId = TestUserSetupUtility.getProxyUser().Id;
            sampleTask.Subject = subject;
            sampleTask.Status = 'Not Started';
            sampleTask.Priority = 'Low';
            sampleTask.LineofBusiness__c = lob;
            sampleTask.ActivityDate = System.today();
            taskList.add(sampleTask);
        }

        List<Id> taskIdList = new List<Id>();
        List<Database.SaveResult> results = Database.insert(taskList);

        for(Database.SaveResult result : results) {
            taskIdList.add(result.getId());
        }

        return Security.stripInaccessible(AccessType.READABLE,
                [SELECT Id, CreatedDate, Account.LastName, Subject, LineofBusiness__c, OwnerId
                FROM Task
                WHERE Id
                IN :taskIdList
                WITH SECURITY_ENFORCED]).getRecords();
    }

    @TestVisible private static List<Task> createTaskListNoWhatId(String lob, List<String> taskSubjectList) {
        List<Task> taskList = new List<Task>();
        for (String subject : taskSubjectList) {
            Task sampleTask = new Task();
            sampleTask.OwnerId = TestUserSetupUtility.getProxyUser().Id;
            sampleTask.Subject = 'BOD Address Change';
            sampleTask.Status = 'Not Started';
            sampleTask.Priority = 'Low';
            sampleTask.LineofBusiness__c = lob;
            sampleTask.ActivityDate = System.today();
            taskList.add(sampleTask);
        }

        List<Id> taskIdList = new List<Id>();
        List<Database.SaveResult> results = Database.insert(taskList);

        for(Database.SaveResult result : results) {
            taskIdList.add(result.getId());
        }

        return Security.stripInaccessible(AccessType.READABLE,
                [SELECT Id, CreatedDate, Account.LastName, Subject, LineofBusiness__c, OwnerId
                FROM Task
                WHERE Id
                IN :taskIdList
                WITH SECURITY_ENFORCED]).getRecords();
    }

    @isTest
    public static void testAssignTasksToUsersSuccessful() {
        User aq_ProcId = TestUserSetupUtility.getApiOnlyUser();
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'xyz';
        update agent_User;
        AQ_WorkAssignmentRule__c agentTestRule;
        List<Task> taskList = new List<Task>();

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            taskList = createTaskList(ACCOUNT_A_CLIENT_ID, 'Auto', subjects);
            List<String> workParams = new List<String>();
            workParams.add('A');
            workParams.add('M');
            workParams.add('Auto');
            workParams.add('BOD Address Change');
            agentTestRule = createWorkAssignment(agent_User,workParams,false);
        }

        System.runAs(sys_Admin) {
            saveCustomSettingConfiguration();
            List<CS_AGENTQUEUE_Config__c> listConfig2 = [SELECT Id,TaskBatchStartTime__c FROM CS_AGENTQUEUE_Config__c];
            DateTime compareDateTime2 = (DateTime)JSON.deserialize('"'+listConfig2[0].TaskBatchStartTime__c+'"', DateTime.class);
            System.assertEquals(1,listConfig2.size(),'only 1 config');
            System.assertEquals(true,DateTime.now().addHours(-1) > compareDateTime2,'config check2 is not working');

            AQ_TaskWorkAssignmentHandler.assignTasksToUsers(taskList);
        }
        Test.stopTest();




        List<CS_AGENTQUEUE_Config__c> listConfig = [SELECT Id,TaskBatchStartTime__c FROM CS_AGENTQUEUE_Config__c];
        DateTime compareDateTime = (DateTime)JSON.deserialize('"'+listConfig[0].TaskBatchStartTime__c+'"', DateTime.class);
        System.assertEquals(1,listConfig.size(),'only 1 config');
        System.assertEquals(false,DateTime.now().addHours(-1) > compareDateTime,'config is not working');

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c, Original_Subject__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );
        System.assertEquals(agent_User.Id, assignedTasks.get(0).AssignedTo__c, 'Unexpected AssignedTo user');
        System.assertEquals('BOD Address Change', assignedTasks.get(0).Original_Subject__c, 'Unexpected original subject');

    }

    @isTest
    public static void testAssignTasksToUsersSuccessfulMultipleTasks() {
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'xyz';
        update agent_User;
        AQ_WorkAssignmentRule__c agentTestRule;
        List<Task> taskList = new List<Task>();

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            subjects.add('BOD Premium Increase');
            taskList = createTaskList(ACCOUNT_A_CLIENT_ID, 'Auto', subjects);
            List<String> workParams = new List<String>();
            workParams.add('A');
            workParams.add('M');
            workParams.add('Auto');
            workParams.add('BOD Address Change');
            agentTestRule = createWorkAssignment(agent_User,workParams, false);
        }

        System.runAs(sys_Admin) {
            saveCustomSettingConfiguration();
            AQ_TaskWorkAssignmentHandler.assignTasksToUsers(taskList);
        }

        Test.stopTest();

        List<Task> existingTasks = [SELECT Id, AssignedTo__c, Original_Subject__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];

        System.assertEquals(2, existingTasks.size(), 'number of tasks ==2' );
        System.assertEquals(agent_User.Id, existingTasks.get(0).AssignedTo__c, 'Unexpected AssignedTo user');
        System.assertEquals(null, existingTasks.get(1).AssignedTo__c, 'BOD Premium Increase should be unassigned');
        System.assertEquals('BOD Address Change', existingTasks.get(0).Original_Subject__c, 'Unexpected original subject');
        System.assertEquals(null, existingTasks.get(1).Original_Subject__c, 'BOD Premium Increase original subject should be blank');

    }




    @isTest
    public static void testAssignTasksToUsersNoMatchingRule() {
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();
        User agent_User = TestUserSetupUtility.getAgentUser();

        List<Task> taskList = new List<Task>();

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            taskList = createTaskList(ACCOUNT_A_CLIENT_ID, 'Auto', subjects);
        }

        System.runAs(sys_Admin) {
            saveCustomSettingConfiguration();
            AQ_TaskWorkAssignmentHandler.assignTasksToUsers(taskList);
        }
        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c, Original_Subject__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );
        System.assertEquals(null, assignedTasks.get(0).AssignedTo__c, 'Unexpected AssignedTo user, value should be null when no Rule matches');
        System.assertEquals(null, assignedTasks.get(0).Original_Subject__c, 'Unexpected original subject, value should be null when no rule matches');

    }
    @isTest
    public static void testAssignTasksToUsersNotAccountTask() {
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();
        User agent_User = TestUserSetupUtility.getAgentUser();
        AQ_WorkAssignmentRule__c agentTestRule;
        List<Task> taskList = new List<Task>();

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            taskList = createTaskListNoWhatId('Auto', subjects);
            List<String> workParams = new List<String>();
            workParams.add('A');
            workParams.add('M');
            workParams.add('Auto');
            workParams.add('BOD Address Change');
            agentTestRule = createWorkAssignment(agent_User,workParams,false);
        }

        System.runAs(sys_Admin) {
            saveCustomSettingConfiguration();
            AQ_TaskWorkAssignmentHandler.assignTasksToUsers(taskList);
        }
        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c, Original_Subject__c FROM Task];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );
        System.assertEquals(null, assignedTasks.get(0).AssignedTo__c, 'Unexpected AssignedTo user');
        System.assertEquals(null, assignedTasks.get(0).Original_Subject__c, 'Unexpected original subject, value should be null when no rule matches');

    }
    @isTest
    public static void testAssignTasksToUsersPartialAlphaLastname() {
        //If only the EndAlpha is set, we treat it as no Alphas being set
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'abcd';
        update agent_User;
        // User atmUser = TestUserSetupUtility.getAtmUser();
        // atmUser.FederationIdentifier = 'Abc';
        AQ_WorkAssignmentRule__c agentTestRule;
        List<Task> taskList = new List<Task>();

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            taskList = createTaskList(ACCOUNT_A_CLIENT_ID, 'Auto', subjects);
            List<String> workParams = new List<String>();
            workParams.add(null);
            workParams.add('M');
            workParams.add('Auto');
            workParams.add('BOD Address Change');
            agentTestRule = createWorkAssignment(agent_User,workParams,false);
        }

        System.runAs(sys_Admin) {
            saveCustomSettingConfiguration();
            AQ_TaskWorkAssignmentHandler.assignTasksToUsers(taskList);
        }
        Test.stopTest();


        //MINE
        List<Task> assignedTasks = [SELECT Id, AssignedTo__c, Original_Subject__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );
        System.assertEquals('BOD Address Change', assignedTasks.get(0).Original_Subject__c, 'Unexpected subject for orignal subject field');
        System.assertEquals(agent_User.Id, assignedTasks.get(0).AssignedTo__c, 'Unexpected AssignedTo user');
    }
    @isTest
    public static void testAssignTasksToUserswithLastAssignedDateTime() {
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'xyz';
        update agent_User;
        User atm_User = TestUserSetupUtility.getAtmUser();
        atm_User.FederationIdentifier = 'abcd';
        update atm_User;
        List<Task> taskList = new List<Task>();
		AQ_WorkAssignmentRule__c agentTestRule;
        AQ_WorkAssignmentRule__c atmTestRule;
        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            subjects.add('BOD Address Change');
            subjects.add('BOD Address Change');
            taskList = createTaskList(ACCOUNT_A_CLIENT_ID, 'Auto', subjects);
            List<String> workParams = new List<String>();
            workParams.add('A');
            workParams.add('M');
            workParams.add('Auto');
            workParams.add('BOD Address Change');
            agentTestRule = createWorkAssignment(agent_User,workParams,true);
            atmTestRule = createWorkAssignment(atm_User,workParams,true);
        }

        System.runAs(sys_Admin) {
            saveCustomSettingConfiguration();
            AQ_TaskWorkAssignmentHandler.assignTasksToUsers(taskList);
        }
        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c, Original_Subject__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(3, assignedTasks.size(), 'number of tasks ==3' );
        System.assertEquals(agent_User.Id, assignedTasks.get(0).AssignedTo__c, 'Unexpected AssignedTo user, value should be Agent for RoundRobin 1');
        System.assertEquals(atm_User.Id, assignedTasks.get(1).AssignedTo__c, 'Unexpected AssignedTo user, value should be ATM for RoundRobin 2');
        System.assertEquals(agent_User.Id, assignedTasks.get(2).AssignedTo__c, 'Unexpected AssignedTo user, value should be Agent for RoundRobin 3');
        System.assertEquals('BOD Address Change', assignedTasks.get(0).Original_Subject__c, 'Unexpected subject for orignal subject field');
        System.assertEquals('BOD Address Change', assignedTasks.get(1).Original_Subject__c, 'Unexpected subject for orignal subject field');
        System.assertEquals('BOD Address Change', assignedTasks.get(2).Original_Subject__c, 'Unexpected subject for orignal subject field');
    }
    @isTest
    public static void testAssignTasksToUsersWithStartAlpha() {
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();
        User agent_User = TestUserSetupUtility.getAgentUser();
        AQ_WorkAssignmentRule__c agentTestRule;
        List<Task> taskList = new List<Task>();

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            taskList = createTaskList(ACCOUNT_A_CLIENT_ID, 'Auto', subjects);
            List<String> workParams = new List<String>();
            workParams.add('A');
            workParams.add(null);
            workParams.add(null);
            workParams.add(null);
            agentTestRule = createWorkAssignment(agent_User,workParams,false);
        }

        System.runAs(sys_Admin) {
            saveCustomSettingConfiguration();
            AQ_TaskWorkAssignmentHandler.assignTasksToUsers(taskList);
        }
        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c, Original_Subject__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );
        System.assertEquals(null, assignedTasks.get(0).AssignedTo__c, 'Unexpected AssignedTo user');
        System.assertEquals(null, assignedTasks.get(0).Original_Subject__c, 'Unexpected subject for orignal subject field');

    }

    @isTest
    public static void testAssignTasksToUsersWithSubject() {
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'xyz';
        update agent_User;
        AQ_WorkAssignmentRule__c agentTestRule;
        List<Task> taskList = new List<Task>();

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            taskList = createTaskList(ACCOUNT_A_CLIENT_ID, 'Auto', subjects);
            List<String> workParams = new List<String>();
            workParams.add(null);
            workParams.add(null);
            workParams.add(null);
            workParams.add('BOD Address Change');
            agentTestRule = createWorkAssignment(agent_User,workParams,false);
        }

        System.runAs(sys_Admin) {
            saveCustomSettingConfiguration();
            AQ_TaskWorkAssignmentHandler.assignTasksToUsers(taskList);
        }
        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c, Original_Subject__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );
        System.assertEquals(agent_User.id, assignedTasks.get(0).AssignedTo__c, 'Unexpected AssignedTo user');
        System.assertEquals('BOD Address Change', assignedTasks.get(0).Original_Subject__c, 'Unexpected subject for orignal subject field');

    }

    @isTest
    public static void testAssignTasksToUserOnlyStartAlphaEndAlpha() {
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'xyz';
        update agent_User;
        AQ_WorkAssignmentRule__c agentTestRule;
        List<Task> taskList = new List<Task>();

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            taskList = createTaskList(ACCOUNT_A_CLIENT_ID, 'Auto', subjects);
            List<String> workParams = new List<String>();
            workParams.add('A');
            workParams.add('C');
            workParams.add(null);
            workParams.add(null);
            agentTestRule = createWorkAssignment(agent_User,workParams, false);
        }

        System.runAs(sys_Admin) {
            saveCustomSettingConfiguration();
            AQ_TaskWorkAssignmentHandler.assignTasksToUsers(taskList);
        }

        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c, Original_Subject__c FROM Task WHERE WhatId =: getAccount(ACCOUNT_A_CLIENT_ID).Id];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );
        System.assertEquals(agent_User.id, assignedTasks.get(0).AssignedTo__c, 'Unexpected AssignedTo user');
        System.assertEquals('BOD Address Change', assignedTasks.get(0).Original_Subject__c, 'Unexpected subject for orignal subject field');

    }

    @isTest
    public static void testAssignTasksToUserswithNoMatchingAccount() {
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();
        User agent_User = TestUserSetupUtility.getAgentUser();
        AQ_WorkAssignmentRule__c agentTestRule;
        List<Task> taskList = new List<Task>();

        Test.startTest();
        System.runAs(agent_User) {
            List<String> subjects = new List<String>();
            subjects.add('BOD Address Change');
            tasklist = createTaskList(ACCOUNT_Z_CLIENT_ID, 'Auto', subjects);
            List<String> workParams = new List<String>();
            workParams.add('A');
            workParams.add('M');
            workParams.add('Auto');
            workParams.add('BOD Address Change');
            agentTestRule = createWorkAssignment(agent_User,workParams,false);
        }

        System.runAs(sys_Admin) {
            saveCustomSettingConfiguration();
            AQ_TaskWorkAssignmentHandler.assignTasksToUsers(taskList);
        }
        Test.stopTest();

        List<Task> assignedTasks = [SELECT Id, AssignedTo__c, Original_Subject__c FROM Task];
        System.assertEquals(1, assignedTasks.size(), 'number of tasks ==1' );
        System.assertEquals(null, assignedTasks.get(0).AssignedTo__c, 'Unexpected AssignedTo user');
        System.assertEquals(null, assignedTasks.get(0).Original_Subject__c, 'Unexpected subject for orignal subject field');

    }
}
