/**
 * @author Baby Yoda
 * @name SR_PNITest
 * @description Test class for SR_PNI, SR_PNIUtil, and SR_AgreementRisks
 */
@isTest
(seeAllData=false)
private class SR_PNITest {
	private static String testString = '123abc';
    private static List<SR_Payload> testPayloads = new List<SR_Payload>();
    
    @isTest
    private static void testHandlePNIForAutoWithPolicyId(){
        SR_Payload testPayload = SR_TestDataUtility.getBasicPayload();
        
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true; 
        testPayload.caseRecord.LOB__c = 'Auto';
        testPayload.caseRecord.App_Code__c = SR_Constants.CASE_APP_CODE_AUTO_CHANGE_AND_SERVICE;
        testPayload.matchParams.secondaryClientId = '';
        testPayload.matchParams.policyId = 'testpolicy';
        testPayloads.add(testPayload);

        SR_PNI srPNI = new SR_PNI(testPayloads);
        srPNI.risks.mockRisks.add(getInsurancePolicy());
        srPNI.mockString = testString;
		List<SR_Payload> payloads = srPNI.handlePNI();
        System.assert(payloads.size() == 1, 'Unexpected paylaods returned');
		SR_Payload returnedPayload =  payloads.get(0);
        System.assertEquals(SR_TestDataUtility.ACCOUNT_CLIENT_ID, returnedPayload.matchParams.secondaryClientId, 'Secondary Client Ids did not change');
        System.assertEquals(testString, returnedPayload.matchParams.clientId, 'Primary Client id did not properly update');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandlePNIForAutoWithPolicyDesc(){
        SR_Payload testPayload = SR_TestDataUtility.getBasicPayload();
        
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        testPayload.caseRecord.LOB__c = 'Auto';
        testPayload.caseRecord.App_Code__c = SR_Constants.CASE_APP_CODE_AUTO_CHANGE_AND_SERVICE;
        testPayload.matchParams.secondaryClientId = '';
        testPayload.matchParams.policyDescription = 'testpolicy';
		
        testPayloads.add(testPayload);
        SR_PNI srPNI = new SR_PNI(testPayloads);
        srPNI.risks.mockRisks.add(getInsurancePolicy());
        srPNI.mockString = testString;
		List<SR_Payload> payloads = srPNI.handlePNI();
        System.assert(payloads.size() == 1, 'Unexpected paylaods returned');
		SR_Payload returnedPayload =  payloads.get(0);
        System.assertEquals(SR_TestDataUtility.ACCOUNT_CLIENT_ID, returnedPayload.matchParams.secondaryClientId, 'Secondary Client Ids did not change');
        System.assertEquals(testString, returnedPayload.matchParams.clientId, 'Primary Client id did not properly update');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandlePNIFireLOB(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        testPayloads = SR_TestDataUtility.getBasicPayloadList(1);
        SR_PNI srPNI = new SR_PNI(testPayloads);
        srPNI.payload.caseRecord.LOB__c = 'Fire';
        srPNI.payload.caseRecord.App_Code__c = SR_Constants.CASE_APP_CODE_FIRE_PVC;
        srPNI.payload.matchParams.policyId = testString;
        
        srPNI.risks.mockRisks.add(getInsurancePolicy(testString));
        srPNI.mockString = 'abc';
        srPNI.handlePNI();
        System.assertEquals('abc', srPNI.payload.matchParams.clientId, 'Client Id was not set to AgreAccessKey');
        Test.stopTest();
    }
    
    @isTest
    private static void testSetClientIds(){
        Test.startTest();
        testPayloads = SR_TestDataUtility.getBasicPayloadList(1);
        UnitTestDataUtility.isUnitTest = true;
        SR_PNI srPNI = new SR_PNI(testPayloads);
        srPNI.setClientIds(testString);
        System.assert(!srPNI.payload.matchParams.secondaryClientId.equals(testString), 'Client Ids did not change');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsValidForPNIAuto(){
        SR_Payload testPayload = SR_TestDataUtility.getBasicPayload();
        
        Test.startTest();
        testPayloads.add(testPayload);
        UnitTestDataUtility.isUnitTest = true;
        testPayload.caseRecord.LOB__c = 'Auto';
        testPayload.caseRecord.App_Code__c = SR_Constants.CASE_APP_CODE_AUTO_CHANGE_AND_SERVICE;
        testPayload.matchParams.secondaryClientId = '';
        testPayload.matchParams.policyId = 'testpolicy';

        SR_PNI srPNI = new SR_PNI(testPayloads);
        System.assert(srPNI.util.isValidForPNI(testPayload), 'Payload is supposed to be valid');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsValidFirePayload(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        testPayloads = SR_TestDataUtility.getBasicPayloadList(1);
        testPayloads.get(0).matchParams.policyId = '42';
        SR_PNI srPNI = new SR_PNI(testPayloads);
        srPNI.payload.caseRecord.LOB__c = 'Fire';
        srPNI.payload.caseRecord.App_Code__c = SR_Constants.CASE_APP_CODE_FIRE_PVC;
        
        System.assert(srPNI.util.isValidFirePayload(srPNI.payload), 'isValidFirePayload returned false');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsValidFirePayloadFalseInvalidAppCode(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        testPayloads = SR_TestDataUtility.getBasicPayloadList(1);
        testPayloads.get(0).matchParams.policyId = '42';
        SR_PNI srPNI = new SR_PNI(testPayloads);
        srPNI.payload.caseRecord.LOB__c = 'Fire';
        srPNI.payload.caseRecord.App_Code__c = SR_Constants.CASE_APP_CODE_AUTO_CHANGE_AND_SERVICE;
        
        System.assert(!srPNI.util.isValidFirePayload(srPNI.payload), 'isValidFirePayload returned true even without appCode');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsValidFirePayloadFalseNullMatchParams(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        testPayloads = SR_TestDataUtility.getBasicPayloadList(1);
        testPayloads.get(0).matchParams.policyId = '42';
        SR_PNI srPNI = new SR_PNI(testPayloads);
        srPNI.payload.caseRecord.LOB__c = 'Fire';
        srPNI.payload.caseRecord.App_Code__c = SR_Constants.CASE_APP_CODE_FIRE_PVC;
        srPNI.payload.matchParams = null;
        
        System.assert(!srPNI.util.isValidFirePayload(srPNI.payload), 'isValidFirePayload returned true even without match params');
        Test.stopTest();
    }
    
    @isTest
    private static void testIsValidFirePayloadFalseNoPolicyId(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        testPayloads = SR_TestDataUtility.getBasicPayloadList(1);
        testPayloads.get(0).matchParams.policyId = '42';
        SR_PNI srPNI = new SR_PNI(testPayloads);
        srPNI.payload.caseRecord.LOB__c = 'Fire';
        srPNI.payload.caseRecord.App_Code__c = SR_Constants.CASE_APP_CODE_FIRE_PVC;
        srPNI.payload.matchParams.policyId = '';
        
        System.assert(!srPNI.util.isValidFirePayload(srPNI.payload), 'isValidFirePayload returned true even without policyId');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandlePNIFire(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        testPayloads = SR_TestDataUtility.getBasicPayloadList(1);
        SR_PNI srPNI = new SR_PNI(testPayloads);
        srPNI.risks.mockRisks.add(getInsurancePolicy(testString));
        srPNI.mockString = 'abc';
        srPNI.handlePNIFire();
        System.assertEquals('abc', srPNI.payload.matchParams.clientId, 'Client Id was not set to AgreAccessKey');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandlePNIFireBlankAgreAccessKey(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        testPayloads = SR_TestDataUtility.getBasicPayloadList(1);
        List<SR_Payload> originalPayloads = testPayloads;
        SR_PNI srPNI = new SR_PNI(testPayloads);
        srPNI.handlePNIFire();
        System.assertEquals(originalPayloads, testPayloads, 'Client Id was changed');
        Test.stopTest();
    }
    
    private static InsurancePolicy getInsurancePolicy(String clientId) {
        Account mockAccount = new Account(ClientIdentifier__c = clientId);
        return new InsurancePolicy(NameInsured = mockAccount);
    }
    
    private static InsurancePolicy getInsurancePolicy() {
        Account mockAccount = new Account(ClientIdentifier__c = testString);
        return new InsurancePolicy(NameInsured = mockAccount);
    }
}