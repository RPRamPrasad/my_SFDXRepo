@isTest(seeAllData=false)
private class JustOneThingSaveTaskControllerTest {

    private static Map<String, Object> setupParamMapUtility(Map<String, Object> idMap, String activityType) {
        Map<String, Object> paramMap = new Map<String, Object>();

        paramMap.put('Subject', 'Test Subject');
        paramMap.put('OwnerId', idMap.get('OwnerId'));
        paramMap.put('WhoId', idMap.get('WhoId'));
        paramMap.put('RelatedContactIds', idMap.get('RelatedContactIds'));
        paramMap.put('Description', 'Test Description');

        if (activityType == 'Task') {
            paramMap.put('ActivityDate', '2021-08-10');
            paramMap.put('AssignedTo', idMap.get('AssignedTo'));
        } else if (activityType == 'Event') {
            paramMap.put('AssignedTo', idMap.get('AssignedTo'));
            paramMap.put('Location', 'Test Location');
            paramMap.put('EventStartDateTime', '2021-10-30T15:00:00.000Z');
            paramMap.put('EventEndDateTime', '2021-10-30T16:00:00.000Z');
        }

        return paramMap;
    }

    private static List<TaskRelation> retrieveTaskRelationsAfterInsert(Id taskId) {
        return [SELECT IsWhat, RelationId, TaskId FROM TaskRelation WHERE TaskId =: taskId AND isWhat = false];
    }

    @testSetup
    private static void testSetup() {
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()) {
            TaskTestDataUtility.createAccount();
            TaskTestDataUtility.createOpportunity(TaskTestDataUtility.getAccount(),
                                                  TestUserSetupUtility.getProxyUser());
            TaskTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(),
                                               TaskTestDataUtility.getAccount());
        }
    }

    @isTest
    private static void testSaveTaskSuccess() {
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account account = TaskTestDataUtility.getAccount();

        Test.startTest();

        Id ownerId = proxyUser.Id;
        Id whoId = account.PersonContactId;
        Id assignedTo = agentUser.Id;

        Map<String, Object> idMap = new Map<String, Object>();
        idMap.put('OwnerId', ownerId);
        idMap.put('WhoId', whoId);
        idMap.put('AssignedTo', assignedTo);

        Map<String, Object> paramMap = setupParamMapUtility(idMap, 'Task');

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            String resultData = (String) JustOneThingSaveTaskController.saveTask(paramMap, account.Id).get('data');

            System.assert(resultData.startsWith('00T'), 'ASSERT_FAILED: Task failed to create');

            Task insertedTask = TaskTestDataUtility.retrieveTaskAfterInsert(resultData);
            System.assertEquals(whoId, insertedTask.WhoId, 'ASSERT_FAILED: Who Id does not match expected value');
            System.assertEquals(ownerId, insertedTask.OwnerId, 'ASSERT_FAILED: Owner Id does not match expected value');
            System.assertEquals(account.Id, insertedTask.WhatId, 'ASSERT_FAILED: What Id does not match expected value');
            System.assertEquals('Medium', insertedTask.Priority, 'ASSERT_FAILED: Priority does not match expected value');
            System.assertEquals('Test Description', insertedTask.Description, 'ASSERT_FAILED: Description does not match expected value');
            System.assert(String.isNotEmpty(insertedTask.Subject), 'ASSERT_FAILED: Subject does not match expected value');
            System.assert(insertedTask.AppCode__c.contains('Account'), 'ASSERT_FAILED: App code does not match expected value');
            System.assertEquals(Date.valueOf('2021-08-10'), insertedTask.ActivityDate, 'ASSERT_FAILED: Activity Date does not match expected value');
            System.assertEquals('Not Started', insertedTask.Status, 'ASSERT_FAILED: Status does not match expected value');
            System.assertEquals(assignedTo, insertedTask.AssignedTo__c, 'ASSERT_FAILED: AssignedTo__c does not match expected value');
            System.assertEquals(TaskHandlerConstants.TASK_TYPE_SERVICE, insertedTask.Task_Type__c, 'ASSERT_FAILED: Task_Type__c does not match expected value');
        }

        Test.stopTest();
    }

    @isTest
    private static void testSaveTaskRelatedContacts() {
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        Account account = TaskTestDataUtility.getAccount();
        Account householdMemberAccount = TestDataFactory_Account.createIndividualCustomer('TEST ACCOUNT');

        System.runAs(sysAdminUser){
            TestDataFactory_Account.byPassAccountBeforeTrigger();
            householdMemberAccount = TestDataFactory_Account.insertAccount(householdMemberAccount);
        }
        Id householdMemberPersonContactId = ([SELECT Id, PersonContactId FROM Account WHERE  Id =: householdMemberAccount.Id])[0].PersonContactId;
        
        Test.startTest();

        Id ownerId = proxyUser.Id;
        Id whoId = account.PersonContactId;
        Id assignedTo = agentUser.Id;
        List<String> relatedContactIds = new List<String>{String.valueOf(householdMemberPersonContactId)};

        Map<String, Object> idMap = new Map<String, Object>();
        idMap.put('OwnerId', ownerId);
        idMap.put('WhoId', whoId);
        idMap.put('AssignedTo', assignedTo);
        idMap.put('RelatedContactIds', relatedContactIds);

        Map<String, Object> paramMap = setupParamMapUtility(idMap, 'Task');

        System.runAs(sysAdminUser) {
            String resultData = (String) JustOneThingSaveTaskController.saveTask(paramMap, account.Id).get('data');

            Task insertedTask = TaskTestDataUtility.retrieveTaskAfterInsert(resultData);
            List<TaskRelation> insertedTaskRelations = retrieveTaskRelationsAfterInsert(insertedTask.Id);
            List<String> insertedTaskRelationIds = new List<String>();
            for (TaskRelation taskRelation : insertedTaskRelations) {
                insertedTaskRelationIds.add(taskRelation.RelationId);   
            }
            System.assert(insertedTaskRelationids.contains(String.valueOf(householdMemberPersonContactId)), 'ASSERT_FAILED: Inserted Task Relation Ids does not contain the Household Member');
        }

        Test.stopTest();
    }

    @isTest
    private static void testSaveTaskFailure() {
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account account = TaskTestDataUtility.getAccount();

        Test.startTest();

        Id ownerId = proxyUser.Id;
        Id whoId = account.PersonContactId;
        Id assignedTo = agentUser.Id;

        Map<String, Object> idMap = new Map<String, Object>();
        idMap.put('OwnerId', ownerId);
        idMap.put('WhoId', whoId);
        idMap.put('AssignedTo', assignedTo);

        Map<String, Object> paramMap = setupParamMapUtility(idMap, 'Task');

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            String resultData = (String) JustOneThingSaveTaskController.saveTask(paramMap, UnitTestDataUtility.MOCK_CASE_ID).get('error');

            System.assert(resultData.contains('MALFORMED_ID'), 'ASSERT_FAILED: Unexpected successful result with mock id');

        }

        Test.stopTest();
    }
}