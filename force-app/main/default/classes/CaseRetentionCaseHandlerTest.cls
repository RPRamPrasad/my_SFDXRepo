/** 
* @description handle retention cases unit tests
* @Owner: CATS
*/
@isTest
(seeAllData=false)
private class CaseRetentionCaseHandlerTest {

    private static Case mockNewCaseRecord = UnitTestDataUtility.buildCase(false);
   	private static Case mockCaseRecord = UnitTestDataUtility.buildCase(true);
    private static Case mockOldCaseRecord = UnitTestDataUtility.buildCase(true);
    private static Map<Id, Case> mockOldCaseMap = new Map<Id, Case>();
    private static List<Case> mockNewCaseList = new List<Case>();
    
    @isTest
    private static void testHandleRetentionCaseInsert(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseMap.put(mockCaseRecord.Id, mockOldCaseRecord);
        mockNewCaseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_RETENTION;
        mockNewCaseList.add(mockNewCaseRecord);
        CaseBeforeTriggerHandler.isInsert = true;
        CaseRetentionCaseHandler.handleRetentionCase(mockNewCaseList, mockOldCaseMap);
        System.assert(mockNewCaseRecord.Status == CaseHandlerConstants.CASE_STATUS_PENDING, 'Status was not changed to pending');
        System.assert(mockNewCaseRecord.Assigned_To__c == UserInfo.getUserId(), 'case assigned to was not set');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleRetentionCaseUpdate(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseRecord.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
        mockOldCaseRecord.Assigned_To__c = UnitTestDataUtility.MOCK_USER_ID;
        mockOldCaseRecord.Outcome__c = 'Outcome';
        mockOldCaseMap.put(mockCaseRecord.Id, mockOldCaseRecord);
        mockCaseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_Retention;
        mockCaseRecord.Status = CaseHandlerConstants.CASE_STATUS_NEW;
        mockNewCaseList.add(mockCaseRecord);
        CaseRetentionCaseHandler.handleRetentionCase(mockNewCaseList, mockOldCaseMap);
        System.assert(mockCaseRecord.Status == CaseHandlerConstants.CASE_STATUS_NEW,'Status was not changed to new');
        System.assert(mockCaseRecord.Assigned_To__c == null, 'case assigned to was not blanked out');
        System.assert(mockCaseRecord.Outcome__c == null, 'case outcome to was not blanked out');
        Test.stopTest();
    }
}