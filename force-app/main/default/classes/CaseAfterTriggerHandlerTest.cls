/**
 * @description handle case after trigger operations test
 * @Owner CATs
 */ 
@isTest
(seeAllData = false)
private class CaseAfterTriggerHandlerTest {
    
    private static Case mockNewCaseRecord = UnitTestDataUtility.buildCase(false);
    private static Case mockOldCaseRecord = UnitTestDataUtility.buildCase(true);
    private static Case mockOldMergedCaseRecord = UnitTestDataUtility.buildCase(false);
    private static List<Case> mockNewCaseList = new List<Case>();
    private static List<Case> mockOldCaseList = new List<Case>();
    private static Map<Id, Case> mockOldCaseMap = new Map<Id, Case>();
    
    @isTest
    private static void testHandleAfterInsert(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockNewCaseRecord.contactID = UnitTestDataUtility.MOCK_CONTACT_ID;
        mockNewCaseList.add(mockNewCaseRecord);
        CaseAfterTriggerHandler.handleAfterInsert(mockNewCaseList);
        Integer dmlCount = Limits.getDmlStatements();
        Test.stopTest();
        System.assertEquals(0, dmlCount, 'DML Count was not zero');
    }
    
    @isTest
    private static void testHandleAfterUpdateInsertBlock(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseMap.put(mockNewCaseRecord.Id, mockOldCaseRecord);
        mockNewCaseList.add(mockNewCaseRecord);
        CaseBeforeTriggerHandler.isInsert = true;
        CaseAfterTriggerHandler.handleAfterUpdate(mockNewCaseList, mockOldCaseMap);
        System.assert(!CaseBeforeTriggerHandler.isInsert, 'isInsert boolean was not set back to true');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleAfterUpdate(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseRecord.OwnerId = UnitTestDataUtility.MOCK_USER_ID;
        mockOldCaseMap.put(mockNewCaseRecord.Id, mockOldCaseRecord);
        mockNewCaseRecord.OwnerId = UnitTestDataUtility.SECONDARY_MOCK_USER_ID;
        mockNewCaseList.add(mockNewCaseRecord);
        CaseAfterTriggerHandler.handleAfterUpdate(mockNewCaseList, mockOldCaseMap);
        Integer dmlCount = Limits.getDmlStatements();
        Test.stopTest();
        System.assertEquals(0, dmlCount, 'DML Count was not zero');
    }
    
    @isTest
    private static void testHandleAfterDelete(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldMergedCaseRecord.Id = UnitTestDataUtility.SECONDARY_MOCK_CASE_ID;
        mockOldMergedCaseRecord.Status = 'Merged';
        mockOldCaseList.add(mockOldCaseRecord);
        mockOldCaseList.add(mockOldMergedCaseRecord);
        CaseAfterTriggerHandler.handleAfterDelete(mockOldCaseList);
        Integer dmlCount = Limits.getDmlStatements();
        Test.stopTest();
        System.assertEquals(0, dmlCount, 'dml count was not one');
    }
}