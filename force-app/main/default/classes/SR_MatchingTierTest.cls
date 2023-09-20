@isTest
(seeAllData=false)
private class SR_MatchingTierTest {

    private static String testRecordTypeName = 'Policy_Change'; 
    private static String secondaryTestRecordTypeName = 'DAR_Case';
    private static String testString = 'Apex Testing';
    private static String secondaryTestString = 'Apex Testing 2';
    private static final String MOCK_CASE_ID = UnitTestDataUtility.MOCK_CASE_ID;
    private static final String SECONDARY_MOCK_CASE_ID = UnitTestDataUtility.SECONDARY_MOCK_CASE_ID;
    
    @isTest
    private static void testContructor(){
        Test.startTest(); 
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        Map<Id,Case> caseMap = new Map<Id,Case>(getCaseList(SR_MatchKey.TIER_1));
        SR_MatchingTier tier = new SR_MatchingTier(payload, caseMap);
        System.assertEquals(caseMap, tier.caseMap, 'case map was not set correctly');
        System.assertEquals(payload, tier.payload, 'payload was not set correctly');
        Test.stopTest();
    }
    
    @isTest
    private static void testContructorWithTier(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        List<Case> cases = getCaseList(SR_MatchKey.TIER_2);
        SR_MatchingTier tier = new SR_MatchingTier(payload, cases, SR_MatchKey.TIER_2);
        System.assertEquals(cases, tier.cases, 'cases was not set correctly');
        System.assertEquals(payload, tier.payload, 'payload was not set correctly');
        System.assertEquals(SR_MatchKey.TIER_2, tier.tier, 'matching tier was not set correctly');
        Test.stopTest();
    }
    
    @isTest
    private static void testhandleTier1MatchFound(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.caseId = MOCK_CASE_ID;
        Map<Id,Case> caseMap = new Map<Id,Case>(getCaseList(SR_MatchKey.TIER_1));
        SR_MatchingTier tier = new SR_MatchingTier(payload, caseMap);
        tier.handleTier1();
        System.assertEquals(caseMap, tier.caseMap, 'case map was not set correctly');
        System.assertEquals(payload, tier.payload, 'payload was not set correctly');
        System.assertEquals(caseMap.values().get(0), tier.matchingCase, 'match was not found');
        Test.stopTest();
    }
    
    @isTest
    private static void testhandleTier1NoMatchFound(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.caseId = SECONDARY_MOCK_CASE_ID;
        Map<Id,Case> caseMap = new Map<Id,Case>(getCaseList(SR_MatchKey.TIER_1));
        SR_MatchingTier tier = new SR_MatchingTier(payload, caseMap);
        tier.handleTier1();
        System.assertEquals(caseMap, tier.caseMap, 'case map was not set correctly');
        System.assertEquals(payload, tier.payload, 'payload was not set correctly');
        System.assertEquals(null, tier.matchingCase, 'match was found');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleTier2MatchFound(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyId = testString;
        payload.matchParams.vehicleId = testString;
        List<Case> cases = getCaseList(SR_MatchKey.TIER_2);
        SR_MatchingTier tier = new SR_MatchingTier(payload, cases, SR_MatchKey.TIER_2);
        tier.util.mockOwnerIsAMatch = true;
        tier.handleTier();
        System.assertEquals(cases, tier.cases, 'cases was not set correctly');
        System.assertEquals(payload, tier.payload, 'payload was not set correctly');
        System.assertEquals(cases.get(0), tier.matchingCase, 'match was not found');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleTier2NoMatchRecordType(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyId = testString;
        payload.matchParams.vehicleId = testString;
        payload.matchParams.recordTypeName = 'Billing';
        List<Case> cases = getCaseList(SR_MatchKey.TIER_2);
        SR_MatchingTier tier = new SR_MatchingTier(payload, cases, SR_MatchKey.TIER_2);
        tier.util.mockOwnerIsAMatch = true;
        tier.handleTier();
        System.assertEquals(cases, tier.cases, 'cases was not set correctly');
        System.assertEquals(payload, tier.payload, 'payload was not set correctly');
        System.assertEquals(null, tier.matchingCase, 'match was found');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleTier2NoMatchFound(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyId = secondaryTestString;
        payload.matchParams.vehicleId = secondaryTestString;
        List<Case> cases = getCaseList(SR_MatchKey.TIER_2);
        SR_MatchingTier tier = new SR_MatchingTier(payload, cases, SR_MatchKey.TIER_2);
        tier.util.mockOwnerIsAMatch = true;
        tier.handleTier();
        System.assertEquals(cases, tier.cases, 'cases was not set correctly');
        System.assertEquals(payload, tier.payload, 'payload was not set correctly');
        System.assertEquals(null, tier.matchingCase, 'match was found');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleTier3MatchFound(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyId = testString;
        List<Case> cases = getCaseList(SR_MatchKey.TIER_3);
        SR_MatchingTier tier = new SR_MatchingTier(payload, cases, SR_MatchKey.TIER_3);
        tier.util.mockOwnerIsAMatch = true;
        tier.handleTier();
        System.assertEquals(cases, tier.cases, 'cases was not set correctly');
        System.assertEquals(payload, tier.payload, 'payload was not set correctly');
        System.assertEquals(cases.get(0), tier.matchingCase, 'match was not found');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleTier3NoMatchRecordType(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyId = testString;
        payload.matchParams.recordTypeName = 'Billing';
        List<Case> cases = getCaseList(SR_MatchKey.TIER_3);
        SR_MatchingTier tier = new SR_MatchingTier(payload, cases, SR_MatchKey.TIER_3);
        tier.util.mockOwnerIsAMatch = true;
        tier.handleTier();
        System.assertEquals(cases, tier.cases, 'cases was not set correctly');
        System.assertEquals(payload, tier.payload, 'payload was not set correctly');
        System.assertEquals(null, tier.matchingCase, 'match was found');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleTier3NoMatchFound(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyId = secondaryTestString;
        List<Case> cases = getCaseList(SR_MatchKey.TIER_3);
        SR_MatchingTier tier = new SR_MatchingTier(payload, cases, SR_MatchKey.TIER_3);
        tier.util.mockOwnerIsAMatch = true;
        tier.handleTier();
        System.assertEquals(cases, tier.cases, 'cases was not set correctly');
        System.assertEquals(payload, tier.payload, 'payload was not set correctly');
        System.assertEquals(null, tier.matchingCase, 'match was found');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleTier4MatchFound(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyDescription = testString;
        List<Case> cases = getCaseList(SR_MatchKey.TIER_4);
        SR_MatchingTier tier = new SR_MatchingTier(payload, cases, SR_MatchKey.TIER_4);
        tier.util.mockOwnerIsAMatch = true;
        tier.handleTier();
        System.assertEquals(cases, tier.cases, 'cases was not set correctly');
        System.assertEquals(payload, tier.payload, 'payload was not set correctly');
        System.assertEquals(cases.get(0), tier.matchingCase, 'match was not found');
        Test.stopTest();
    }
    
    
    @isTest
    private static void testHandleTier4NoMatchFound(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        payload.matchParams.policyDescription = secondaryTestString;
        List<Case> cases = getCaseList(SR_MatchKey.TIER_4);
        SR_MatchingTier tier = new SR_MatchingTier(payload, cases, SR_MatchKey.TIER_4);
        tier.util.mockOwnerIsAMatch = true;
        tier.handleTier();
        System.assertEquals(cases, tier.cases, 'cases was not set correctly');
        System.assertEquals(payload, tier.payload, 'payload was not set correctly');
        System.assertEquals(cases.get(0), tier.matchingCase, 'match was not found');
        Test.stopTest();
    }
    
    
    private static List<Case> getCaseList(SR_MatchKey tier){
        List<Case> cases = new List<Case>();
        Case caseRecord = UnitTestDataUtility.buildCase(true);
        switch on tier{
            when TIER_1{
                caseRecord.Id = MOCK_CASE_ID;
            }
            when TIER_2{
                caseRecord.Policy_Identifier__c = testString;
				caseRecord.Vehicle_Identifier__c = testString;
            }
			when TIER_3{
                caseRecord.Policy_Identifier__c = testString;
            }
            when TIER_4{
                caseRecord.ProductDescription__c = testString;
            }
        }
        caseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE; 
        cases.add(caseRecord);
        return cases;
    }
    
}