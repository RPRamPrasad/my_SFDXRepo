@isTest(seeAllData=false)
private class JustOneThingSaveEventControllerTest {

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

    private static List<EventRelation> retrieveEventRelationsAfterInsert(Id eventId) {
        return [SELECT IsWhat, RelationId, EventId FROM EventRelation WHERE EventId =: eventId AND isWhat = false];
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
    private static void testSaveEventSuccess() {
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

        Map<String, Object> paramMap = setupParamMapUtility(idMap, 'Event');

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            String resultData = (String) JustOneThingSaveEventController.saveEvent(paramMap, account.Id).get('data');

            System.assert(resultData.startsWith('00U'), 'ASSERT_FAILED: Event failed to create');

            DateTime startTime = (DateTime)JSON.deserialize('"' + '2021-10-30T15:00:00.000Z' + '"', DateTime.class); 
            DateTime endTime = (DateTime)JSON.deserialize('"' + '2021-10-30T16:00:00.000Z' + '"', DateTime.class); 

            Event insertedEvent = [SELECT StartDateTime, EndDateTime, Subject, WhoId, OwnerId, WhatId, AssignedTo__c, Location, Description FROM Event Where Id =: resultData];
            System.assertEquals(startTime, insertedEvent.StartDateTime, 'ASSERT_FAILED: Start Date Time does not match expected value');
            System.assertEquals(endTime, insertedEvent.EndDateTime, 'ASSERT_FAILED: End Date Time does not match expected value');
            System.assert(String.isNotEmpty(insertedEvent.Subject), 'ASSERT_FAILED: Subject does not match expected value');
            System.assertEquals('Test Description', insertedEvent.Description, 'ASSERT_FAILED: Description does not match expected value');
            System.assertEquals(whoId, insertedEvent.WhoId, 'ASSERT_FAILED: Who Id does not match expected value');
            System.assertEquals(ownerId, insertedEvent.OwnerId, 'ASSERT_FAILED: Owner Id does not match expected value');
            System.assertEquals(account.Id, insertedEvent.WhatId, 'ASSERT_FAILED: What Id does not match expected value');
            System.assertEquals(assignedTo, insertedEvent.AssignedTo__c, 'ASSERT_FAILED: AssignedTo__c does not match expected value');
            System.assert(String.isNotEmpty(insertedEvent.Location), 'ASSERT_FAILED: Location does not match expected value');
        }

        Test.stopTest();
    }


    @isTest
    private static void testSaveEventRelatedContacts() {
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

        Map<String, Object> paramMap = setupParamMapUtility(idMap, 'Event');

        System.runAs(sysAdminUser) {
            String resultData = (String) JustOneThingSaveEventController.saveEvent(paramMap, account.Id).get('data');

            List<EventRelation> insertedEventRelations = retrieveEventRelationsAfterInsert(resultData);
            List<String> insertedEventRelationsIds = new List<String>();
            for (EventRelation eventRelation : insertedEventRelations) {
                insertedEventRelationsIds.add(eventRelation.RelationId);   
            }
            System.assert(insertedEventRelationsIds.contains(String.valueOf(householdMemberPersonContactId)), 'ASSERT_FAILED: Inserted Event Relation Ids does not contain the Household Member');
        }

        Test.stopTest();
    }

    @isTest
    private static void testSaveEventFailure() {
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

        Map<String, Object> paramMap = setupParamMapUtility(idMap, 'Event');

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            String resultData = (String) JustOneThingSaveEventController.saveEvent(paramMap, UnitTestDataUtility.MOCK_CASE_ID).get('error');

            System.assert(resultData.contains('MALFORMED_ID'), 'ASSERT_FAILED: Unexpected successful result with mock id');

        }

        Test.stopTest();
    }
}