@isTest
(seeAllData=false)
private class SR_SetupTest {
    
    private static Map<SR_Key, Object> srMap = new Map<SR_Key, Object>();
    private static String requestId = '2345HKSDFISF_353L';

    @isTest
    private static void testConstructor(){ 
        Test.startTest();
        List<SR_Payload> payloads = SR_TestDataUtility.getBasicPayloadList(2);
        srMap.put(SR_Key.REQUEST_ID, requestId);
        SR_Setup setup = new SR_Setup(payloads, srMap);
        System.assertEquals(payloads, setup.payloads, 'the payloads variable was not setup correctly');
        System.assertEquals(srMap, setup.srMap, 'the srMap variable was not setup correctly');
        Test.stopTest();
    }
    
    @isTest
    private static void testPreparePayloadsForProcessing(){
        Test.startTest();
        List<SR_Payload> payloads = SR_TestDataUtility.getBasicPayloadList(1);
        srMap.put(SR_Key.REQUEST_ID, requestId);
        SR_Setup setup = new SR_Setup(payloads, srMap);
        srMap = setup.preparePayloadsForProcessing();
        System.assert(srMap.containsKey(SR_Key.ORIGINAL_PAYLOADS_MAP), 'Original payloads were not added to the map');
        System.assert(srMap.containsKey(SR_Key.VALID_PAYLOADS), 'Valid payloads were not added to the map');
        System.assert(srMap.containsKey(SR_Key.RECORD_TYPE_NAME), 'Record type name was not added to the map');
        System.assert(srMap.containsKey(SR_Key.CLIENT_TO_PAYLOAD_MAP), 'Client Map was not added to the map');
        Test.stopTest(); 
    }
    
    @isTest
    private static void testPreparePayloadsForProcessingMixedPayloads(){
        Test.startTest();
        List<SR_Payload> payloads = getMixedPayloadList();
        srMap.put(SR_Key.REQUEST_ID, requestId);
        SR_Setup setup = new SR_Setup(payloads, srMap);
        srMap = setup.preparePayloadsForProcessing();
        System.assert(srMap.containsKey(SR_Key.ORIGINAL_PAYLOADS_MAP), 'Original payloads were not added to the map');
        System.assert(srMap.containsKey(SR_Key.VALID_PAYLOADS), 'Valid payloads were not added to the map');
        System.assert(srMap.containsKey(SR_Key.INVALID_PAYLOADS), 'Invalid payloads were not added to the map');
        System.assert(srMap.containsKey(SR_Key.RECORD_TYPE_NAME), 'Record type name was not added to the map');
        System.assert(srMap.containsKey(SR_Key.QUEUEABLE_PAYLOADS_MAP), 'Queueable payloads were not added to the map');
        System.assert(srMap.containsKey(SR_Key.CLIENT_TO_PAYLOAD_MAP), 'Client Map was not added to the map');
        Test.stopTest(); 
    }
    
    
    private static List<SR_Payload> getMixedPayloadList(){
        List<SR_Payload> payloads = new List<SR_Payload>();
        payloads.add(SR_TestDataUtility.getBasicPayload());
        payloads.add(SR_TestDataUtility.getBasicPayload('DAR_Case'));
        payloads.add(SR_TestDataUtility.getInvalidPayload());
        return payloads;
    }
    
}