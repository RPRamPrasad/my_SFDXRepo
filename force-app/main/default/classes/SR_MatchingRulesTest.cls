@isTest
(seeAllData=false)
private class SR_MatchingRulesTest {
    
    private static String testString = 'Apex Testing';
	private static String testStateFarmId = 'STATEFARM12';
    
    
    @isTest
    private static void testConstructor(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        List<Case> cases = getCases(1);
        SR_MatchingRules rules = new SR_MatchingRules(payload, cases);
        System.assertEquals(payload, rules.payload, 'payload was not set correctly');
        System.assertEquals(cases, rules.caseMap.values(), 'payload was not set correctly');
        System.assert(rules.caseMap.containsKey(cases.get(0).Id), 'case map was not setup correctly');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleMatchingTier1(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        List<Case> cases = getCases(1);
		payload.matchParams.caseId = cases.get(0).Id;
        SR_MatchingRules rules = new SR_MatchingRules(payload, cases);
        Case matchingCase = rules.handleMatching();
        System.assertEquals(matchingCase, cases.get(0), 'match was not found');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleMatchingMulitTierTier3(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        Case caseRecord = UnitTestDataUtility.buildCase(true);
        List<Case> cases = new List<Case>();
        caseRecord.Policy_Identifier__c = testString;
        caseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE; 
        cases.add(caseRecord);
		payload.matchParams.policyId = testString;
        payload.matchParams.policyDescription = testString;
        SR_MatchingRules rules = new SR_MatchingRules(payload, cases);
        rules.mockOwnerIsAMatch = true;
        Case matchingCase = rules.handleMatching();
        System.assertEquals(matchingCase, caseRecord , 'match was not found');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleMatchingMulitTierTier4(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        Case caseRecord = UnitTestDataUtility.buildCase(true);
        List<Case> cases = new List<Case>();
        caseRecord.ProductDescription__c = testString;
        caseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE; 
        cases.add(caseRecord);
		payload.matchParams.policyId = testString;
        payload.matchParams.policyDescription = testString;
        SR_MatchingRules rules = new SR_MatchingRules(payload, cases);
        rules.mockOwnerIsAMatch = true;
        Case matchingCase = rules.handleMatching();
        System.assertEquals(matchingCase, caseRecord, 'match was not found');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleMatchingTier2(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        Case caseRecord = UnitTestDataUtility.buildCase(true);
        List<Case> cases = new List<Case>();
        caseRecord.Policy_Identifier__c = testString;
        caseRecord.Vehicle_Identifier__c = testString;
        caseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE; 
        cases.add(caseRecord);
		payload.matchParams.policyId = testString;
        payload.matchParams.vehicleId = testString;
        SR_MatchingRules rules = new SR_MatchingRules(payload, cases);
        rules.mockOwnerIsAMatch = true;
        Case matchingCase = rules.handleMatching();
        System.assertEquals(matchingCase, caseRecord, 'match was found');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleMatchingTier3(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        Case caseRecord = UnitTestDataUtility.buildCase(true);
        List<Case> cases = new List<Case>();
        caseRecord.Policy_Identifier__c = testString;
        caseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE; 
        cases.add(caseRecord);
		payload.matchParams.policyId = testString;
        SR_MatchingRules rules = new SR_MatchingRules(payload, cases);
        rules.mockOwnerIsAMatch = true;
        Case matchingCase = rules.handleMatching();
        System.assertEquals(matchingCase, caseRecord, 'match was found');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleMatchingTier4(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        Case caseRecord = UnitTestDataUtility.buildCase(true);
        List<Case> cases = new List<Case>();
        caseRecord.ProductDescription__c = testString;
        caseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE; 
        cases.add(caseRecord);
        payload.matchParams.policyDescription = testString;
        SR_MatchingRules rules = new SR_MatchingRules(payload, cases);
        rules.mockOwnerIsAMatch = true;
        Case matchingCase = rules.handleMatching();
        System.assertEquals(matchingCase, caseRecord, 'match was found');
        Test.stopTest();
    }
    
   
    @isTest
    private static void testSortCasesTier2(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        List<Case> cases = getCases(1);
        cases.get(0).Policy_Identifier__c = testStateFarmId;
        cases.get(0).Vehicle_Identifier__c = testStateFarmId;
        SR_MatchingRules rules = new SR_MatchingRules(payload, cases);
        SR_MatchKey key = SR_MatchKey.TIER_2;
        System.assert(rules.tierMap.containsKey(key), 'tierMap did not contain tier 2');
        Test.stopTest();
    }
    
    @isTest
    private static void testSortCasesTier3(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        List<Case> cases = getCases(1);
        cases.get(0).Policy_Identifier__c = testStateFarmId;
        SR_MatchingRules rules = new SR_MatchingRules(payload, cases);
        SR_MatchKey key = SR_MatchKey.TIER_3;
        System.assert(rules.tierMap.containsKey(key), 'tierMap did not contain tier 3');
        Test.stopTest();
    }
    
    @isTest 
    private static void testSortCasesTier4(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        List<Case> cases = getCases(1);
        cases.get(0).ProductDescription__c = testStateFarmId;
        SR_MatchingRules rules = new SR_MatchingRules(payload, cases);
        SR_MatchKey key = SR_MatchKey.TIER_4;
        System.assert(rules.tierMap.containsKey(key), 'tierMap did not contain tier 4');
        Test.stopTest();
    }
    
    @isTest
    private static void testMapTierIsPopulatedTrue(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        SR_MatchingRules rules = new SR_MatchingRules(payload, getCases(1));
        SR_MatchKey key = SR_MatchKey.TIER_2;
        rules.tierMap.put(key, getCases(1));
        boolean result = rules.mapTierIsPopulated(key);
        System.assert(result, 'map did not have key');
        Test.stopTest();
    }
    
    @isTest
    private static void testMapTierIsPopulatedfalse(){
        Test.startTest();
        SR_Payload payload = SR_TestDataUtility.getBasicPayload();
        SR_MatchingRules rules = new SR_MatchingRules(payload, getCases(1));
        SR_MatchKey tier2_key = SR_MatchKey.TIER_2;
        SR_MatchKey tier3_key = SR_MatchKey.TIER_3;
        rules.tierMap.put(tier2_key, getCases(1));
        boolean result = rules.mapTierIsPopulated(tier3_key);
        System.assert(!result, 'map had the key');
        Test.stopTest();
    }
    
	private static List<Case> getCases(Integer caseCount){
        List<Case> cases = new List<Case>();
        for(Integer i=0; i<caseCount; i++){
            cases.add(UnitTestDataUtility.buildCase(true));
        }
        return cases;
    }

}