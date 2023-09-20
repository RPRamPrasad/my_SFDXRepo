@isTest
(seeAllData=false)
public class TaskClosureModalControllerTest {
    
    @testSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            TaskTestDataUtility.createAccount();
            TaskTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), TaskTestDataUtility.getAccount());
        }
    }
    
    @isTest
    private static void testCloseTasksWithoutOutcome() {
        Test.startTest();
        Case testCase = new Case(Subject='Test Case Data');
        insert testCase;
        User agentUser = TestUserSetupUtility.getAgentUser();
        Task mockTask = new Task(Subject='Test Task', WhatId=testCase.Id, OwnerId=agentUser.Id);
        insert mockTask;
        TaskClosureModalController.closeTasks(testCase.Id);
        Integer numQueriesRun;
        numQueriesRun = Limits.getDMLStatements();
        Test.stopTest();
        Case fetchedCase = [Select Id, Status FROM Case WHERE Id =: testCase.Id];
        System.assertEquals('Closed', fetchedCase.Status, 'Case status was not updated to closed');
    }
    
    @isTest
    private static void testCloseTasksWithoutOutcomeCaseOwnerNotMatch(){
        Test.startTest();
        Case testCase = new Case(Subject='Test Case Data');
        insert testCase;
        User agentUser = TestUserSetupUtility.getAgentUser();
        User agentUser2 = TestUserSetupUtility.getSecondaryAgentUser();
        Task mockTask = new Task(Subject='Test Task', WhatId=testCase.Id, OwnerId=agentUser.Id);
        AuraHandledException auraEx = null;
        insert mockTask;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser2);
        System.runAs(agentUser2){
            try{
                TaskClosureModalController.closeTasks(testCase.Id);
            }catch(AuraHandledException e){
                auraEx = e;
            }
        }
        Test.stopTest();
        Case fetchedCase = [Select Id, Status FROM Case WHERE Id =: testCase.Id];
        System.assert(fetchedCase.Status != 'Closed', 'Case status was updated to closed');
        System.assert(auraEx != null, 'Agent can close Case and Task that belong to other agent office.');
    }
    
    @isTest
    private static void testCloseTasksWithOutcome() {
        Test.startTest();
        Case testCase = new Case(Subject='Test Case Data');
        insert testCase;
        User agentUser = TestUserSetupUtility.getAgentUser();
        Task mockTask = new Task(Subject='Test Task', WhatId=testCase.Id, OwnerId=agentUser.Id);
        insert mockTask;
        TaskClosureModalController.closeTasksWithOutcome(testCase.Id, 'Test Outcome');
        Integer numQueriesRun;
        numQueriesRun = Limits.getDMLStatements();
        Test.stopTest();
        Task updatedTask = [Select Id, Outcome_Added__c, Description FROM Task WHERE Id =: mockTask.Id];
        System.assertEquals(updatedTask.Outcome_Added__c, true, 'Outcome was not added to the task');
        System.assertEquals('Test Outcome', updatedTask.Description, 'Description was not updated to provided outcome');
    }
    
    @isTest
    private static void testCloseTasksWithOutcomeCaseOwnerNotMatch(){
        Test.startTest();
        Case testCase = new Case(Subject='Test Case Data');
        insert testCase;
        User agentUser = TestUserSetupUtility.getAgentUser();
        User agentUser2 = TestUserSetupUtility.getSecondaryAgentUser();
        Task mockTask = new Task(Subject='Test Task', WhatId=testCase.Id, OwnerId=agentUser.Id);
        AuraHandledException auraEx = null;
        insert mockTask;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser2);
        System.runAs(agentUser2){
            try{
                TaskClosureModalController.closeTasksWithOutcome(testCase.Id, 'Test Outcome');
            }catch(AuraHandledException e){
                auraEx = e;
            }
        }
        Test.stopTest();
        Case fetchedCase = [Select Id, Status FROM Case WHERE Id =: testCase.Id];
        System.assert(fetchedCase.Status != 'Closed', 'Case status was updated to closed');
        System.assert(auraEx != null, 'Agent can close Case and Task that belong to other agent office.');
    }
    
    @isTest
    private static void testFetchOpenActivitiesForCase() {
        Test.startTest();
        Case testCase = new Case(Subject='Test Case Data');
        insert testCase;
        User agentUser = TestUserSetupUtility.getAgentUser();
        Task mockTask = new Task(Subject='Test Task', WhatId=testCase.Id, OwnerId=agentUser.Id);
        insert mockTask;
        List<Task> fetchResult = TaskClosureModalController.fetchOpenActivitiesForCase(testCase.Id);
        Integer numQueriesRun;
        numQueriesRun = Limits.getDMLStatements();
        Test.stopTest();
        System.assertEquals(fetchResult.size(), 1, 'Unexpected number of tasks returned');
        Task updatedTask = fetchResult[0];
        System.assertEquals(updatedTask.Id, mockTask.Id, 'Ids for the tasks did not match');
    }
}