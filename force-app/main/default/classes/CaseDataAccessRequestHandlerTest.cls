/** 
* @description handle data access request cases unit tests
* @Owner: CATS
*/
@isTest
(seeAllData=false)
private class CaseDataAccessRequestHandlerTest {

    private static Case mockNewCaseRecord = UnitTestDataUtility.buildCase(false);
   	private static Case mockCaseRecord = UnitTestDataUtility.buildCase(true);
    private static Case mockOldCaseRecord = UnitTestDataUtility.buildCase(true);
    private static Map<Id, Case> mockOldCaseMap = new Map<Id, Case>();
    private static List<Case> mockNewCaseList = new List<Case>();
    
    @isTest
    private static void testHandleDataAccessRequestInsert(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        CaseBeforeTriggerHandler.isInsert = true;
        mockNewCaseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_DATA_ACCESS_REQUEST;
        mockNewCaseList.add(mockNewCaseRecord);
        mockOldCaseMap.put(UnitTestDataUtility.MOCK_CASE_ID, mockOldCaseRecord);
        CaseDataAccessRequestHandler.handleDataAccessRequest(mockNewCaseList, mockOldCaseMap);
        System.assert(mockNewCaseRecord.OwnerId == CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID, 'owner Id was not updated to the DAR Queue');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleDataAccessRequestUpdateNotClosed(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        CaseBeforeTriggerHandler.isInsert = false;
        mockCaseRecord.Status = CaseHandlerConstants.CASE_STATUS_PROCESSING;
        mockCaseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_DATA_ACCESS_REQUEST;
        mockNewCaseList.add(mockCaseRecord);
        mockOldCaseMap.put(UnitTestDataUtility.MOCK_CASE_ID, mockOldCaseRecord);
        CaseDataAccessRequestHandler.handleDataAccessRequest(mockNewCaseList, mockOldCaseMap);
        System.assert(mockCaseRecord.OwnerId == UnitTestDataUtility.MOCK_USER_ID, 'owner Id was updated to the DAR Queue');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleDataAccessRequestUpdateClosed(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        CaseBeforeTriggerHandler.isInsert = false;
        mockCaseRecord.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
        mockCaseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_DATA_ACCESS_REQUEST;
        mockNewCaseList.add(mockCaseRecord);
        mockOldCaseMap.put(UnitTestDataUtility.MOCK_CASE_ID, mockOldCaseRecord);
        CaseDataAccessRequestHandler.handleDataAccessRequest(mockNewCaseList, mockOldCaseMap);
        System.assert(mockCaseRecord.OwnerId == CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID, 'owner Id was not updated to the DAR Queue');
        Test.stopTest();
    }
}