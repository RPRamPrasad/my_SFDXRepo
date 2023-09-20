@isTest
(seeAllData=false)
private class SR_DMLHandlerTest {

    @isTest
    private static void testShouldResetNumberOfTimesTrue() {
        Map<SR_Key, Object> srMap = new Map<SR_Key, Object>();
        SR_DMLHandler dmlHandler = new SR_DMLHandler(srMap);
        SR_Payload srPayload = new SR_Payload();
        srPayload.numberOfTimesThroughProcess = 1;
        srPayload.eventId = 'mockeventid';
        boolean shouldResetNumTimes = dmlHandler.shouldResetNumberOfTimes(srPayload, Case.getSObjectType());
        System.assertEquals(true, shouldResetNumTimes, 'Expected to reset number of times but did not');
    }
    
    @isTest
    private static void testShouldResetNumberOfTimesFalse() {
        Map<SR_Key, Object> srMap = new Map<SR_Key, Object>();
        SR_DMLHandler dmlHandler = new SR_DMLHandler(srMap);
        SR_Payload srPayload = new SR_Payload();
        srPayload.numberOfTimesThroughProcess = 0;
        srPayload.eventId = 'mockeventid';
        boolean shouldResetNumTimes = dmlHandler.shouldResetNumberOfTimes(srPayload, Case.getSObjectType());
        System.assertEquals(false, shouldResetNumTimes, 'Expected to reset number of times but did not');
    }
    
    @isTest
    private static void testHandleRecordLockException() {
        Map<SR_Key, Object> srMap = new Map<SR_Key, Object>();
        SR_DMLHandler dmlHandler = new SR_DMLHandler(srMap);
        SR_Payload srPayload = new SR_Payload();
        srPayload.numberOfTimesThroughProcess = 0;
        srPayload.eventId = 'mockeventid';
        String errorMessage = 'UNABLE_TO_LOCK_ROW';
        dmlHandler.handleException(srPayload, errorMessage);
        System.assertEquals(1, dmlHandler.recordLockPayloads.size(), 'Unexpected number of record lock exceptions.');
        System.assertEquals(1, dmlHandler.initialRecordLockRecords.size(), 'Unexpected number of initial record lock exceptions');
        System.assertEquals(0, dmlHandler.exceptions.size(), 'Unexpected number of SR exceptions.');
		dmlHandler.putRecordLocksInSRMap();
        List<SR_Payload> recordLocksInMap = (List<SR_Payload>)dmlHandler.srMap.get(SR_Key.RECORD_LOCK_EXCEPTIONS);
        System.assertEquals(1, recordLocksInMap.size(), 'Unexpected number of Record Lock Exceptions');
    }
    
    @isTest
    private static void testHandleQueuedRecordLockException() {
        Map<SR_Key, Object> srMap = new Map<SR_Key, Object>();
        SR_DMLHandler dmlHandler = new SR_DMLHandler(srMap);
        SR_Payload srPayload = new SR_Payload();
        srPayload.numberOfTimesThroughProcess = 1;
        srPayload.eventId = 'mockeventid';
        String errorMessage = 'UNABLE_TO_LOCK_ROW';
        dmlHandler.handleException(srPayload, errorMessage);
        System.assertEquals(1, dmlHandler.recordLockPayloads.size(), 'Unexpected number of record lock exceptions.');
        System.assertEquals(0, dmlHandler.initialRecordLockRecords.size(), 'Unexpected number of initial record lock exceptions.');
        System.assertEquals(0, dmlHandler.exceptions.size(), 'Unexpected number of SR exceptions.');
        dmlHandler.putRecordLocksInSRMap();
        List<SR_Payload> recordLocksInMap = (List<SR_Payload>)dmlHandler.srMap.get(SR_Key.RECORD_LOCK_EXCEPTIONS);
        System.assertEquals(1, recordLocksInMap.size(), 'Unexpected number of Record Lock Exceptions');
    }
    
    @isTest
    private static void testHandleSRException() {
        Map<SR_Key, Object> srMap = new Map<SR_Key, Object>();
        SR_DMLHandler dmlHandler = new SR_DMLHandler(srMap);
        SR_Payload srPayload = new SR_Payload();
        srPayload.numberOfTimesThroughProcess = 0;
        srPayload.eventId = 'mockeventid';
        String errorMessage = 'UH_OH';
        dmlHandler.handleException(srPayload, errorMessage);
        System.assertEquals(0, dmlHandler.recordLockPayloads.size(), 'Unexpected number of record lock exceptions.');
        System.assertEquals(0, dmlHandler.initialRecordLockRecords.size(), 'Unexpected number of initial record lock exceptions.');
        System.assertEquals(1, dmlHandler.exceptions.size(), 'Unexpected number of SR exceptions.');
        dmlHandler.putRecordLocksInSRMap();
        List<SR_Payload> recordLocksInMap = (List<SR_Payload>)dmlHandler.srMap.get(SR_Key.RECORD_LOCK_EXCEPTIONS);
        System.assertEquals(null, recordLocksInMap, 'Unexpected number of Record Lock Exceptions added to SR Map');
    }
}