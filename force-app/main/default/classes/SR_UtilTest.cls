@isTest
(seeAllData=false)
private class SR_UtilTest {

    private static String requestId = '2345HKSDFISF_353L';
    private static String mockCaseId = '5001A00000MOCKMOCK';

    @isTest
    private static void testHasSupportingRecord(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Util utility = new SR_Util();
        List<SR_Payload> payloads;
        payloads = new List<SR_Payload>();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.taskRecord = SR_TestDataUtility.buildSupportingTask();
        boolean result = utility.hasSupportingRecord(payload); 
        System.assert(result, 'false was returned');
        Test.stopTest();
    }
    
    @isTest
    private static void testHasSupportingRecordFalse(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Util utility = new SR_Util();
        List<SR_Payload> payloads;
        payloads = new List<SR_Payload>();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.logRecord = null;
        payload.taskRecord = null;
        boolean result = utility.hasSupportingRecord(payload);
        System.assert(!result, 'true was returned');
        Test.stopTest();
    }
    
    @isTest
    private static void testBuildExceptions(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        String eventID = requestId + '_' + '0';
        SR_Util utility = new SR_Util();
        String errorMessage = 'Test Error. This error is over 255 characters long to' + 
            ' ensure that any error message added over 255 characters is cut down to' +
            ' 255 so that the whole message is not lost. The error message field is' + 
            ' limited to 255 characters so that it can be used to filter against in queries.  ' + 
            ' None of this sentence should be seen.';
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.eventId = eventID;
        Service_Request_Exception__c ex = utility.buildExceptions(payload, errorMessage);
        System.assert(ex.ErrorMessage__c.length() == 255, 'error message was not set');
        System.assertEquals(eventId, ex.Event_Id__c, 'event id set test');
        Test.stopTest();
    }
    
    @isTest
    private static void testBuildExceptionsList(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Util utility = new SR_Util();
        List<SR_Payload> payloads = new List<SR_Payload>();
        String errorMessage = 'test error';
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payloads.add(payload);
        List<Service_Request_Exception__c> exList = utility.buildExceptionsList(payloads, errorMessage);
        for(Service_Request_Exception__c ex : exList){
            System.assert(ex.ErrorMessage__c == errorMessage, 'error message was not set'); 
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testEmptyCasesPayloadMatch(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Util utility = new SR_Util();
        List<SR_Payload> payloads;
        payloads = new List<SR_Payload>();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        Case mockCase;
        mockCase = new Case();
        List<Case> caseList = new List<Case>();
        String eventTier = utility.handleEventMatchTiers(payload, caseList);
        System.assertEquals('No Cases Found - Create', eventTier, 'event was not pure create');
        Test.stopTest();
    }
    
    @isTest
    private static void testTier1PayloadMatch(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Util utility = new SR_Util();
        List<SR_Payload> payloads;
        payloads = new List<SR_Payload>();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.caseId = UnitTestDataUtility.MOCK_CASE_ID;
        Case mockCase = new Case(Id = mockCaseId);
        List<Case> caseList = new List<Case>{mockCase};
        String eventTier = utility.handleEventMatchTiers(payload, caseList);
        System.assertEquals('No Match Found - Tier 1', eventTier, 'event was not tier 1');
        Test.stopTest();
    }
    
    @isTest
    private static void testTier2PayloadMatch(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Util utility = new SR_Util();
        List<SR_Payload> payloads;
        payloads = new List<SR_Payload>();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyId = '1213343';
        payload.matchParams.vehicleId = '1213343';
        Case mockCase = new Case(Id = mockCaseId);
        List<Case> caseList = new List<Case>{mockCase};
        String eventTier = utility.handleEventMatchTiers(payload, caseList);
        System.assertEquals('No Match Found - Tier 2', eventTier, 'event was not tier 2');
        Test.stopTest();
    }
    
    @isTest
    private static void testTier3PayloadMatch(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Util utility = new SR_Util();
        List<SR_Payload> payloads;
        payloads = new List<SR_Payload>();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyId = '1213343';
        Case mockCase = new Case(Id = mockCaseId);
        List<Case> caseList = new List<Case>{mockCase};
        String eventTier = utility.handleEventMatchTiers(payload, caseList);
        System.assertEquals('No Match Found - Tier 3', eventTier, 'event was not tier 3');
        Test.stopTest();
    }
    
    @isTest
    private static void testTier4PayloadMatch(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Util utility = new SR_Util();
        List<SR_Payload> payloads;
        payloads = new List<SR_Payload>();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyDescription = '1213343';
        Case mockCase = new Case(Id = mockCaseId);
        List<Case> caseList = new List<Case>{mockCase};
        String eventTier = utility.handleEventMatchTiers(payload, caseList);
        System.assertEquals('No Match Found - Tier 4', eventTier, 'event was not tier 4');
        Test.stopTest();
    }
    
    @isTest
    private static void testMultiTierPayloadMatch(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Util utility = new SR_Util();
        List<SR_Payload> payloads;
        payloads = new List<SR_Payload>();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyId = '1213343';
        payload.matchParams.policyDescription = '1213343';
        Case mockCase = new Case(Id = mockCaseId);
        List<Case> caseList = new List<Case>{mockCase};
        String eventTier = utility.handleEventMatchTiers(payload, caseList);
        System.assertEquals('No Match Found - Multi Tier', eventTier, 'event was not multi tier');
        Test.stopTest();
    }
}