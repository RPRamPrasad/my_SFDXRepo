@isTest
(seeAllData=false)
private class TaskStepTriggerTest {

    private static final String ASSERT_FAILURE_RECORD_NOT_INSERTED = 'Record was not inserted';
    private static final String ASSERT_FAILURE_RECORD_NOT_UPDATED = 'Record was not updated';
    private static final String ASSERT_FAILURE_OWNER_NOT_PROXY = 'Owner was not changed to proxy';

    
    @testSetup
    private static void testSetUp(){
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSecondaryAgentOffice();
    }
    
    @isTest
    private static void testInsertTaskStep(){
        User agent = TestUserSetupUtility.getAgentUser();
        User proxy = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Task_Step__c step = TaskStepTestScenarios.insertStep(agent);
        System.assert(step != null, ASSERT_FAILURE_RECORD_NOT_INSERTED);
        System.assertEquals(proxy.Id, step.Template__r.Ownerid, ASSERT_FAILURE_OWNER_NOT_PROXY);
        Test.stopTest();    
    }
    
    @isTest
    private static void testUpdateTaskStep(){
        User agent = TestUserSetupUtility.getAgentUser();
        User proxy = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Task_Step__c step = TaskStepTestScenarios.insertStep(agent);
        System.assert(step != null, ASSERT_FAILURE_RECORD_NOT_INSERTED);
        Task_Step__c updatedStep = TaskStepTestScenarios.updateSteps(agent, step);
        System.assert(updatedStep != null, ASSERT_FAILURE_RECORD_NOT_UPDATED);
        System.assertEquals(proxy.Id, updatedStep.Template__r.OwnerId, ASSERT_FAILURE_OWNER_NOT_PROXY);
        Test.stopTest();
    }
    
}