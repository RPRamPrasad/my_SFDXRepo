@isTest
(seeAllData=false)
private class SR_MatchTest {

    private static Map<SR_Key, Object> srMap = new Map<SR_Key, Object>();
    private static String recordTypeName = 'Policy_Change';
    
    @isTest
    private static void testConstructor(){ 
        Test.startTest();
        populateMap();
        SR_Match match = new SR_Match(srMap);
        System.assertEquals(srMap, match.srMap, 'srMap was not set properly');
        System.assertEquals(srMap.get(SR_Key.CLIENT_TO_PAYLOAD_MAP), match.clientToPayloadMap, 'client to payload map was not set properly');
        System.assertEquals(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId(), match.recordTypeId, 'record type id was not set properly');
        Test.stopTest(); 
    }
    
    private static void populateMap(){
        srMap.put(SR_Key.CLIENT_TO_PAYLOAD_MAP, SR_TestDataUtility.getClientToPayloadMap());
        srMap.put(SR_Key.RECORD_TYPE_NAME, recordTypeName);
    }
}