@isTest
(seeAllData=false)
private class SR_ValidationTest {
    

    @isTest
    private static void testIsSalesforceIdEmptyId(){ 
        Test.startTest(); 
        UnitTestDataUtility.isUnitTest = true;
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.caseId = '';
        SR_Validation validation = new SR_Validation(payload);
        System.assert(validation.isSalesforceId(), 'msg');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsSalesforceIdInstanceOfId(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.caseId = UnitTestDataUtility.MOCK_CASE_ID;
        SR_Validation validation = new SR_Validation(payload);
        System.assert(validation.isSalesforceId(), 'msg');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsSalesforceIdFalse(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.caseId = 'AGHGFDSFGFD';
        SR_Validation validation = new SR_Validation(payload);
        System.assert(!validation.isSalesforceId(), 'msg');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsValidPolicyId(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyId = '';
        SR_Validation validation = new SR_Validation(payload);
        System.assert(validation.isValidPolicyId(), 'msg');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsValidPolicyIdLessThan20(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyId = '123456789';
        SR_Validation validation = new SR_Validation(payload);
        System.assert(validation.isValidPolicyId(), 'msg');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsValidPolicyIdFalse(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyId = 'AGHGFDSFGFD12345678987654323456789876543';
        SR_Validation validation = new SR_Validation(payload);
        System.assert(!validation.isValidPolicyId(), 'msg');
        Test.stopTest();
    }
    
     @isTest
    private static void testIsValidPolicyDesc(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyDescription = '';
        SR_Validation validation = new SR_Validation(payload);
        System.assert(validation.isValidProductDesc(), 'msg');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsValidPolicyDESCLessThan255(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyDescription = 'Test Desc';
        SR_Validation validation = new SR_Validation(payload);
        System.assert(validation.isValidProductDesc(), 'msg');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsValidPolicyDescFalse(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyDescription = UnitTestDataUtility.generateRandomString(256);
        SR_Validation validation = new SR_Validation(payload);
        System.assert(!validation.isValidProductDesc(), 'msg');
        Test.stopTest();
    }
    
    @isTest
    private static void testHasValidRecordTypeTrue(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.recordTypeName = 'Policy_Change';
        SR_Validation validation = new SR_Validation(payload);
        System.assert(validation.hasValidRecordType(), 'msg');
        Test.stopTest();
    }
    
    @isTest
    private static void testHasValidRecordTypeFalse(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.recordTypeName = 'Policy_Change2';
        SR_Validation validation = new SR_Validation(payload);
        System.assert(!validation.hasValidRecordType(), 'msg');
        Test.stopTest();
    }

}