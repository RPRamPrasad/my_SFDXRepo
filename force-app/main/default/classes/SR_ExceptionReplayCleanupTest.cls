@isTest
(seeAllData=false)
public class SR_ExceptionReplayCleanupTest {
    
    @testSetup
    private static void testSetUp(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            SR_TestDataUtility.createAccount();
            SR_TestDataUtility.createSecondaryAccount();            
            SR_TestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), SR_TestDataUtility.getAccount());
            SR_TestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), SR_TestDataUtility.getSecondaryAccount());
        }
    }
    
    @isTest
    private static void cleanupBatchTest() {
        SR_Payload payload1 = SR_TestDataUtility.getBasicPayload();
        SR_Payload payload2 = SR_TestDataUtility.getBasicPayload();
        SR_Payload payload3 = SR_TestDataUtility.getBasicPayload();
        
        Service_Request_Exception__c ex1;
        ex1 = generateServiceRequestExceptions(payload1); 
        Service_Request_Exception__c ex2;
        ex2 = generateServiceRequestExceptions(payload2);
        Service_Request_Exception__c ex3;
        ex3 = generateServiceRequestExceptions(payload3);
        
        
        List<Service_Request_Exception__c> exceptions = [SELECT Id, isSuccessfullyReplayed__c, Retry_Count__c, SObject_Type__c FROM Service_Request_Exception__c];
        System.assert(exceptions.size() == 3, 'Exceptions size was not expected value - Actual: ' + exceptions.size());        
        
        Test.startTest();        
        SR_ExceptionReplayCleanup cleanup = new SR_ExceptionReplayCleanup();
        cleanup.daysOlderThan = 0;
        System.runAs(TestUserSetupUtility.getApiOnlyUser()){
            Database.executeBatch(cleanup, 1250); 
        }        
        Test.stopTest();
        
        exceptions = [SELECT Id, isSuccessfullyReplayed__c, Retry_Count__c, SObject_Type__c FROM Service_Request_Exception__c];
        System.assert(exceptions.isEmpty(), 'Exceptions size was not expected value - Actual: ' + exceptions.size());
    }
    
    private static Service_Request_Exception__c generateServiceRequestExceptions(Object objectRecord){
        Service_Request_Exception__c ex = new Service_Request_Exception__c();
        ex.Payload__c = JSON.serialize(objectRecord, true);
        ex.ErrorMessage__c = 'Testing Cleanup Batch';
        ex.SObject_Type__c = SR_Constants.SOBJECT_TYPE_SR_PAYLOAD;
        ex.Retry_Count__c = 0;
        ex.OwnerId = UserInfo.getUserId();
        ex.isSuccessfullyReplayed__c = true;
        ex.RecordTypeId = SR_Constants.EXCEPTION_RECORD_TYPE_AUTO_RETRY;
        insert ex;
        return ex;
    }
    
      @isTest
      private static void scheduleBatchTest(){
        SR_ExceptionReplayCleanup jobToSchedule = new SR_ExceptionReplayCleanup();
        String cronExpression = '0 0 0 11 1 ?';
        Test.startTest();
        String jobId = System.schedule('srExCleanupTest', cronExpression, jobToSchedule);
        jobToSchedule.execute(null);
        Test.stopTest();
        System.assert(jobId != null, 'Batch Process Id returned null.');
     }
}