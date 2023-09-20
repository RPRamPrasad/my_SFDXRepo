@isTest
(seeAllData=false)
private class TemplateTriggerTest {

    private static final String ASSERT_FAILURE_RECORD_NOT_INSERTED = 'Record was not inserted';
    private static final String ASSERT_FAILURE_RECORD_NOT_UPDATED = 'Record was not updated';
    private static final String ASSERT_FAILURE_OWNER_NOT_PROXY = 'Owner was not changed to proxy';

    @testSetup
    private static void testSetUp(){
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSecondaryAgentOffice();
    }
    
    @isTest
    private static void testInsertTemplate(){
        User agent = TestUserSetupUtility.getAgentUser();
        User proxy = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Template__c result = TemplateTestScenarios.insertTemplate(agent);
        System.assert(result != null, ASSERT_FAILURE_RECORD_NOT_INSERTED);
        System.assertEquals(proxy.Id, result.OwnerId, ASSERT_FAILURE_OWNER_NOT_PROXY);
        Test.stopTest();    
    }
    
    @isTest
    private static void testUpdateTemplate(){
        User agent = TestUserSetupUtility.getAgentUser();
        User agent2 = TestUserSetupUtility.getSecondaryAgentUser();
        User proxy2 = TestUserSetupUtility.getSecondaryProxyUser();
        Test.startTest();
        Template__c result = TemplateTestScenarios.insertTemplate(agent);
        System.assert(result != null, ASSERT_FAILURE_RECORD_NOT_INSERTED);
        result.OwnerId = agent2.Id; //Changing the owner before the update
        Template__c updateTemplate = TemplateTestScenarios.updateTemplate(agent, result);
        System.assert(updateTemplate != null, ASSERT_FAILURE_RECORD_NOT_UPDATED);
        System.assertEquals(proxy2.Id, updateTemplate.OwnerId, ASSERT_FAILURE_OWNER_NOT_PROXY);
        Test.stopTest();    
    }
    
    @isTest
    private static void testLimit(){
        User agent = TestUserSetupUtility.getAgentUser();
        Test.startTest(); 
        List<Template__c> templates = TemplateTestScenarios.insertTemplateList(agent, 50);
        System.assertEquals(50, templates.size(), 'number of inserted template check');
        try{
            TemplateTestScenarios.insertTemplate(agent);
        }catch(Exception ex){
            System.assert(ex.getMessage() != null, 'error message check');
        }
        Test.stopTest();
    }
    
}