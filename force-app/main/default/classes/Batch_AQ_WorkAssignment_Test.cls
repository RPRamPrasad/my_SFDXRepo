/**
  * @name Batch_AQ_WorkAssignment_Test
  * @author Team Skynet
  * @createdDate 06/03/2022
  * @description Apex unit testing for Batch_NBAJoesiFeedbackReprocessor Batch class
*/
@isTest(seeAllData = false)
public class Batch_AQ_WorkAssignment_Test {

    @TestVisible private static final String ACCOUNT_CLIENT_ID_A = '12345678915';
    @TestVisible private static final String ACCOUNT_CLIENT_ID_Z = '12345678916';

    @testSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        TestUserSetupUtility.setupApiOnlyUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            Account accountRecord = createAccount('Albertson',ACCOUNT_CLIENT_ID_A);
            setupAgentRole(TestUserSetupUtility.getAgentUser(), accountRecord);

            Account accountRecord2 = createAccount('Zalbertson',ACCOUNT_CLIENT_ID_Z);
            setupAgentRole(TestUserSetupUtility.getAgentUser(), accountRecord2);

            User agentQueueProcessId = TestUserSetupUtility.getApiOnlyUser();
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SF_CRM_AGENTQUEUE_PermSetPID'];
            insert new PermissionSetAssignment(AssigneeId = agentQueueProcessId.id, PermissionSetId = ps.Id);
        }
    }

    @TestVisible private static Account createAccount(String lastName, String clientId){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName=lastName,
                                            BillingAddressType__c='US',BillingCity='Phoenix',
                                            ClientIdentifier__c=clientId);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
        return accountRecord;
    }

    @TestVisible private static User getUser(Id userId){
        return [SELECT Id, Servicing_Agent_Associate_Id__c FROM User WHERE Id = :userId];
    }

    @TestVisible private static Account getAccount(String clientId){
        return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE  ClientIdentifier__c = :clientId];
    }

    @TestVisible private static void setupAgentRole(User userRecord, Account accountRecord){
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c = userRecord.Id;
        agentRole.Customer__c = accountRecord.Id;
        agentRole.RelationshipNature__c = 'Customer';
        insert agentRole;
    }

    @TestVisible private static void createTask(Account parentId, User owner, String tSubject) {
        Task newTask = new Task(WhatId = parentId.Id,
                    OwnerId = owner.Id,
                    Subject = tSubject,
                    Status = 'Not Started',
                    Priority = 'Low',
                    LineofBusiness__c = 'Auto',
                    ActivityDate = System.today().addDays(1));
        insert newTask;
    }

    @TestVisible private static List<Task> getTasks(Account parentId) {
        return [SELECT Id,Subject,Status,AssignedTo__c,OwnerId,LineofBusiness__c FROM Task WHERE WhatId = :parentId.Id];
    }

    @TestVisible private static void createWorkAssignmentPreference(User userAssignment, String startA, String endA){
        AQ_WorkAssignmentRule__c war = new AQ_WorkAssignmentRule__c(StartAlpha__c = startA, EndAlpha__c = endA,
                                                                LOB_Stored__c = 'Auto', Task_Subject__c = 'BOD Policy Increase',
                                                                User__r = userAssignment);
        insert war;
    }

    @isTest
    public static void processTasksSuccessfulTest() {
        //Create Custom Setting
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CS_AGENTQUEUE_Config__c agentQueueConfig = new CS_AGENTQUEUE_Config__c();
            agentQueueConfig.Name = 'BatchAgentQueueHoursBehind';
            agentQueueConfig.Value__c = 1;
            agentQueueConfig.TaskBatchStartTime__c = DateTime.now().addHours(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            insert agentQueueConfig;
        }

        //Pull in User and Account records to use in the test
        User agentQueueProcessId = TestUserSetupUtility.getApiOnlyUser();
        Account accountRecordA = getAccount(ACCOUNT_CLIENT_ID_A);

        User testUser = getUser(TestUserSetupUtility.getAgentUser().Id);
        createWorkAssignmentPreference(testUser, 'A', 'B');

        createTask(accountRecordA,testUser,'BOD Policy Increase');
        List<Task> taskList = getTasks(accountRecordA);
        System.assertEquals(1, taskList.size(), 'Task list is not 1, save failed');

        System.runAs(agentQueueProcessId){
            Batch_AQ_WorkAssignment.assignTasks(taskList);
        }

        List<Task> tasks = [SELECT Id, AssignedTo__c, CreatedDate, OwnerId, Status FROM Task];

        System.assertEquals(true, !tasks.isEmpty(), 'Tasks is empty, save failed');

        Batch_AQ_WorkAssignment schedule = new Batch_AQ_WorkAssignment();

        System.runAs(agentQueueProcessId){
            Test.startTest();
            schedule.execute(null, taskList);
            Test.stopTest();
        }

        List<Task> tasksAfter = [Select Id, AssignedTo__c from Task];
        System.assertEquals(true, !tasksAfter.isEmpty(), 'Tasks After is empty, save failed');
    }

    @isTest
    public static void scheduleBatchTest(){

        User agentQueueProcessId = TestUserSetupUtility.getApiOnlyUser();
        //Create Custom Setting
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            List<CS_AGENTQUEUE_Config__c> agentQueueConfigList = new List<CS_AGENTQUEUE_Config__c>();
            CS_AGENTQUEUE_Config__c agentQueueConfigHours = new CS_AGENTQUEUE_Config__c();
            agentQueueConfigHours.Name = 'BatchAgentQueueHoursBehind';
            agentQueueConfigHours.Value__c = 1;
            agentQueueConfigHours.TaskBatchStartTime__c = DateTime.now().addHours(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            agentQueueConfigList.add(agentQueueConfigHours);
            CS_AGENTQUEUE_Config__c agentQueueConfigSoeDelegate = new CS_AGENTQUEUE_Config__c();
            agentQueueConfigSoeDelegate.Name = 'SoeDelegateUserName';
            agentQueueConfigSoeDelegate.ValueString__c = 'soedelegate@testing.com';
            agentQueueConfigSoeDelegate.TaskBatchStartTime__c = DateTime.now().addHours(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            agentQueueConfigList.add(agentQueueConfigSoeDelegate);
            CS_AGENTQUEUE_Config__c agentQueueConfigTaskApi = new CS_AGENTQUEUE_Config__c();
            agentQueueConfigTaskApi.Name = 'TaskApiUserName';
            agentQueueConfigTaskApi.ValueString__c = 'taskapi@testing.com';
            agentQueueConfigTaskApi.TaskBatchStartTime__c = DateTime.now().addHours(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            agentQueueConfigList.add(agentQueueConfigTaskApi);
            insert agentQueueConfigList;
        }

        Date todaysDate = System.today();
        Batch_AQ_WorkAssignment sched = new Batch_AQ_WorkAssignment();
        Integer nextYear = todaysDate.Year() +1;
        String cronExpr = '0 0 0 15 3 ? ' + nextYear;
        System.runAs(agentQueueProcessId){
            Test.startTest();
            String jobId = System.schedule('Batch_AQ_WorkAssignment_UnitTest', cronExpr, sched);
            sched.execute(null);
            Test.stopTest();
            System.assert(jobId != null, 'Batch Process Id returned null.');
        }

    }

    @isTest
    public static void scheduleBatchTestWithDefaults(){

        User agentQueueProcessId = TestUserSetupUtility.getApiOnlyUser();
        //Create Custom Setting
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CS_AGENTQUEUE_Config__c agentQueueConfig = new CS_AGENTQUEUE_Config__c();
            agentQueueConfig.Name = 'BatchAgentQueueHoursBehind';
            agentQueueConfig.Value__c = 1;
            agentQueueConfig.TaskBatchStartTime__c = DateTime.now().addHours(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            insert agentQueueConfig;
        }

        Date todaysDate = System.today();
        Batch_AQ_WorkAssignment sched = new Batch_AQ_WorkAssignment();
        Integer nextYear = todaysDate.Year() +1;
        String cronExpr = '0 0 0 15 3 ? ' + nextYear;
        System.runAs(agentQueueProcessId){
            Test.startTest();
            String jobId = System.schedule('Batch_AQ_WorkAssignment_UnitTest', cronExpr, sched);
            sched.execute(null);
            Test.stopTest();
            System.assert(jobId != null, 'Batch Process Id returned null.');
        }

    }

}