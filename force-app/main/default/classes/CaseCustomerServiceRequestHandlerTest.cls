/** 
* @description handle customer service requests unit tests
* @Owner: CATS
*/
@isTest
(seeAllData=false)
private with sharing class CaseCustomerServiceRequestHandlerTest {
    
    private static Case mockCaseRecord = UnitTestDataUtility.buildCase(false);
    private static Case mockOldCaseRecord = UnitTestDataUtility.buildCase(true);
    private static Map<Id, Case> mockOldCaseMap = new Map<Id, Case>();
    private static List<Case> mockNewCaseList = new List<Case>();
    
    @isTest
    private static void testHandleCustomerServiceRequestNoAgentRoleCheckNeeded(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        CaseBeforeTriggerHandler.isInsert = true;
        CaseHandlerUtility.mockUserRequiresAgentRoleCheck = false;
        mockNewCaseList.add(mockCaseRecord);
        mockOldCaseMap.put(UnitTestDataUtility.MOCK_CASE_ID, mockOldCaseRecord);
        CaseCustomerServiceRequestHandler.handleCustomerServiceRequest(mockNewCaseList, mockOldCaseMap);
        System.assert(CaseCustomerServiceRequestHandler.checkAgentRoleForCases.size() == 0, 'unexpected - User needed an agent role check');
        System.assert(mockCaseRecord.Status == CaseHandlerConstants.CASE_STATUS_PENDING, 'Case status was not updated to pending');
        System.assert(mockCaseRecord.Assigned_To__c != null, 'Case Assigned to was not set');
        Test.stopTest();
    }
    
	@isTest
    private static void testHandleCustomerServiceRequestAgentRoleCheckNeeded(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        CaseBeforeTriggerHandler.isInsert = true;
        CaseHandlerUtility.mockUserRequiresAgentRoleCheck = true;
        mockNewCaseList.add(mockCaseRecord);
        mockOldCaseMap.put(UnitTestDataUtility.MOCK_CASE_ID, mockOldCaseRecord);
        CaseCustomerServiceRequestHandler.handleCustomerServiceRequest(mockNewCaseList, mockOldCaseMap);
        System.assert(CaseCustomerServiceRequestHandler.checkAgentRoleForCases.size() == 1, 'unexpected - User did not need an agent role check');
        System.assert(mockCaseRecord.Status == CaseHandlerConstants.CASE_STATUS_PENDING, 'Case status was not updated to pending');
        System.assert(mockCaseRecord.Assigned_To__c != null, 'Case Assigned to was not set');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleCustomerServiceRequestUpdate(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        CaseBeforeTriggerHandler.isInsert = false;
        mockOldCaseRecord.Status = CaseHandlerConstants.CASE_STATUS_PENDING;
        mockOldCaseRecord.Assigned_To__c = UnitTestDataUtility.MOCK_USER_ID;
        mockCaseRecord.Id = mockOldCaseRecord.Id;
        mockCaseRecord.Assigned_To__c = mockOldCaseRecord.Assigned_To__c;
        mockCaseRecord.Status = CaseHandlerConstants.CASE_STATUS_NEW;
        mockNewCaseList.add(mockCaseRecord);
        mockOldCaseMap.put(UnitTestDataUtility.MOCK_CASE_ID, mockOldCaseRecord);
        CaseCustomerServiceRequestHandler.handleCustomerServiceRequest(mockNewCaseList, mockOldCaseMap);
        System.assert(mockCaseRecord.Status == CaseHandlerConstants.CASE_STATUS_NEW, 'Case status was not updated to New');
        System.assert(mockCaseRecord.Assigned_To__c == null, 'Case Assigned to was not set');
        Test.stopTest();
    }
}