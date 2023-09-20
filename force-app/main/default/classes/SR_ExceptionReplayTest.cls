@isTest
(seeAllData=false)
private class SR_ExceptionReplayTest {

    @testSetup
    private static void testSetUp(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            SR_TestDataUtility.createAccount();
            SR_TestDataUtility.createSecondaryAccount();
            SR_TestDataUtility.addUserToSOEDelegatePermSet(TestUserSetupUtility.getApiOnlyUser());
            SR_TestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), SR_TestDataUtility.getAccount());
            SR_TestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), SR_TestDataUtility.getSecondaryAccount());
        }
    }
    
    @isTest
    private static void batchTest(){
        SR_Payload payload1 = SR_TestDataUtility.getBasicPayload();
        SR_Payload payload2 = SR_TestDataUtility.getBasicPayload();
        SR_Payload payload3 = SR_TestDataUtility.getBasicPayload();
        Service_Request_Exception__c ex1;
        ex1 = generateServiceRequestExceptions(payload1, 0); 
        Service_Request_Exception__c ex2;
        ex2 = generateServiceRequestExceptions(payload2, 0);
        Service_Request_Exception__c ex3;
        ex3 = generateServiceRequestExceptions(payload3, 0);
        Test.startTest();
        SR_ExceptionReplay replay = new SR_ExceptionReplay();
        System.runAs(TestUserSetupUtility.getApiOnlyUser()){
            Database.executeBatch(replay, 1250); 
        }
        Test.stopTest();
        List<Service_Request_Exception__c> exceptions = [SELECT Id, isSuccessfullyReplayed__c, Retry_Count__c, SObject_Type__c FROM Service_Request_Exception__c];
       	System.assert(exceptions.size() == 3, 'Exceptions size was not expected value - Actual: ' + exceptions.size());
    }
    
    private static Service_Request_Exception__c generateServiceRequestExceptions(Object objectRecord, Integer retryCount){
        Service_Request_Exception__c ex = new Service_Request_Exception__c();
        ex.Payload__c = JSON.serialize(objectRecord, true);
        ex.ErrorMessage__c = 'Testing Batch';
        ex.SObject_Type__c = SR_Constants.SOBJECT_TYPE_SR_PAYLOAD;
        ex.Retry_Count__c = retryCount;
        ex.OwnerId = UserInfo.getUserId();
        ex.isSuccessfullyReplayed__c = false;
        ex.RecordTypeId = SR_Constants.EXCEPTION_RECORD_TYPE_AUTO_RETRY;
        insert ex;
        return ex;
    }
    
    
}