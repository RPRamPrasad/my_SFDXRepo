/*
* @Owner: Grumpycats
* @description case before trigger handler test class
*/
@isTest
(seeAllData = false)
private class CaseBeforeTriggerHandlerTest {
    
    private static Case mockNewCaseRecord = UnitTestDataUtility.buildCase(false);
   	private static Case mockCaseRecord = UnitTestDataUtility.buildCase(false);
    private static Case mockOldCaseRecord = UnitTestDataUtility.buildCase(true);
    private static Case mockCaseRecordCustomOwnerField = UnitTestDataUtility.buildCase(false, true);
    private static List<Case> mockNewCaseList = new List<Case>();
    private static List<Case> mockOldCaseList = new List<Case>();
    private static Map<Id, Case> mockOldCaseMap = new Map<Id, Case>();
    
    @isTest
    private static void testHandleBeforeInsertNonValidatedUser(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockNewCaseList.add(mockNewCaseRecord);
        mockNewCaseList.add(mockCaseRecordCustomOwnerField);
        mockOldCaseMap.put(UnitTestDataUtility.MOCK_CASE_ID, mockOldCaseRecord);
        CaseBeforeTriggerHandler.handleBeforeInsert(mockNewCaseList, mockOldCaseMap);
        for(Case mock_NewCase_Record : mockNewCaseList){
            System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mock_NewCase_Record.OwnerId, 'case owner is not MOCK_USER_ID');
            System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mock_NewCase_Record.Case_Owner__c, 'case custom owner is not MOCK_USER_ID');
            System.assert(mock_NewCase_Record.OwnerId == mock_NewCase_Record.Case_Owner__c, 'Owner fields were not kept in sync');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleBeforeInsertPrevalidtedUser(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        CaseBeforeTriggerHandler.mockUserData = true;
        mockNewCaseList.add(mockNewCaseRecord);
        mockNewCaseList.add(mockCaseRecordCustomOwnerField);
        mockOldCaseMap.put(UnitTestDataUtility.MOCK_CASE_ID, mockOldCaseRecord);
        CaseBeforeTriggerHandler.handleBeforeInsert(mockNewCaseList, mockOldCaseMap);
        for(Case mock_NewCase_Record : mockNewCaseList){
            System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mock_NewCase_Record.OwnerId, 'case owner is not MOCK_USER_ID');
            System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mock_NewCase_Record.Case_Owner__c, 'case custom owner is not MOCK_USER_ID');
            System.assert(mock_NewCase_Record.OwnerId == mock_NewCase_Record.Case_Owner__c, 'Owner fields were not kept in sync');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleBeforeUpdateNonValidatedUser(){
        Test.startTest(); 
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseRecord.Case_Owner__c = mockCaseRecord.OwnerId;
        mockOldCaseRecord.Status = CaseHandlerConstants.CASE_STATUS_PENDING;
        mockOldCaseRecord.Subject = 'old case subject';
        mockOldCaseMap.put(mockCaseRecord.Id, mockOldCaseRecord);
        mockCaseRecord.Case_Owner__c = mockCaseRecord.OwnerId;
        mockCaseRecord.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
        mockCaseRecord.Subject = 'new case subject';
        mockCaseRecord.IsEscalated = true;
        mockNewCaseList.add(mockCaseRecord);
        CaseBeforeTriggerHandler.handleBeforeUpdate(mockNewCaseList, mockOldCaseMap);
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockCaseRecord.OwnerId, 'case owner is not my id');
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockCaseRecord.Case_Owner__c, 'case custom owner is not my id');
        System.assert(mockCaseRecord.OwnerId == mockCaseRecord.Case_Owner__c, 'Owner fields were not kept in sync');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleBeforeUpdatePrevalidtedUser(){
        Test.startTest(); 
        UnitTestDataUtility.isUnitTest= true;
        CaseBeforeTriggerHandler.mockUserData = true;
        mockOldCaseRecord.Case_Owner__c = mockCaseRecord.OwnerId;
        mockOldCaseRecord.Status = CaseHandlerConstants.CASE_STATUS_PENDING;
        mockOldCaseRecord.Subject = 'old case subject';
        mockOldCaseMap.put(mockCaseRecord.Id, mockOldCaseRecord);
        mockCaseRecord.Case_Owner__c = mockCaseRecord.OwnerId;
        mockCaseRecord.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
        mockCaseRecord.Subject = 'new case subject';
        mockNewCaseList.add(mockCaseRecord);
        CaseBeforeTriggerHandler.handleBeforeUpdate(mockNewCaseList, mockOldCaseMap);
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockCaseRecord.OwnerId, 'case owner is not my id');
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockCaseRecord.Case_Owner__c, 'case custom owner is not my id');
        System.assert(mockCaseRecord.OwnerId == mockCaseRecord.Case_Owner__c, 'Owner fields were not kept in sync');
        Test.stopTest();
    }
}