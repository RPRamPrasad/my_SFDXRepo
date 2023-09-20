/**
 * @description handle case trigger operations test
 * @Owner CATs
 */
@isTest
(seeAllData = false)
public class CaseHandlerTest {
    
    private static Case mockNewCaseRecord = UnitTestDataUtility.buildCase(false);
   	private static Case mockCaseRecord = UnitTestDataUtility.buildCase(false);
    private static Case mockOldCaseRecord = UnitTestDataUtility.buildCase(true);
    private static Case mockCaseRecordCustomOwnerField = UnitTestDataUtility.buildCase(false, true);
    private static Case mockOldCaseRecordCustomOwnerField = UnitTestDataUtility.buildCase(true, true);
    private static List<Case> mockNewCaseList = new List<Case>();
    private static Map<Id, Case> mockOldCaseMap = new Map<Id, Case>();
    /**
     * @description testUsersSetup
     */
    @testsetup
    public static void testUsersSetup() {  
        TestUserSetupUtility.setupAgentOffice();
    }
    
    @isTest
    private static void testHandleSPI(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockNewCaseList.add(mockNewCaseRecord);
        CaseHandler.handleSPI(mockNewCaseList);
        System.assert(Limits.getQueries() == 1, 'unexpected number of queries were run');
        Test.stopTest();
    }
    
    @isTest
    private static void testSetAssignedToOnCase(){
        User agent = TestUserSetupUtility.getAgentUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        Test.startTest();
        System.runAs(agent){
            UnitTestDataUtility.isUnitTest= true;
        	CaseHandler.setAssignedToOnCase(mockNewCaseRecord, CaseHandlerConstants.CASE_STATUS_NEW);
        }
        System.assertEquals(agent.id, mockNewCaseRecord.Assigned_To__c, 'assigned to was not set');
        Test.stopTest();
    }
    
    @isTest
    private static void testKeepCaseOwnerFieldsInSync(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        CaseHandler.keepCaseOwnerFieldsInSync(mockNewCaseRecord);
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockNewCaseRecord.Case_Owner__c, 'custom owner field was not kept in sync with ownerId');
        CaseHandler.keepCaseOwnerFieldsInSync(mockCaseRecordCustomOwnerField);
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockCaseRecordCustomOwnerField.OwnerId, 'ownerId field was not kept in sync with custom owner field');
        Test.stopTest();
    }
    
    @isTest
    private static void testKeepCaseOwnerFieldsInSyncOwnerFieldChangeToUser(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        CaseHandlerUtility.mockUserIsAllowedToChangeOwner = true;
        mockOldCaseRecord.OwnerId = UnitTestDataUtility.MOCK_USER_ID;
        mockNewCaseRecord.OwnerId = UnitTestDataUtility.SECONDARY_MOCK_USER_ID;
        CaseHandler.keepCaseOwnerFieldsInSync(mockNewCaseRecord, mockOldCaseRecord);
        System.assertEquals(UnitTestDataUtility.SECONDARY_MOCK_USER_ID, mockNewCaseRecord.Case_Owner__c, 'custom owner field was not kept in sync with ownerId'); 
        Test.stopTest();
    }
    
    @isTest
    private static void testKeepCaseOwnerFieldsInSyncOwnerFieldChangeToNonUser(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseRecord.OwnerId = UnitTestDataUtility.MOCK_QUEUE_ID;
        mockNewCaseRecord.OwnerId = TestUserSetupUtility.getAgentUser().id;
        CaseHandler.keepCaseOwnerFieldsInSync(mockNewCaseRecord, mockOldCaseRecord);
        System.assertEquals(null, mockNewCaseRecord.Case_Owner__c, 'custom owner field was not set to null');
        Test.stopTest();
    }
    
    @isTest
    private static void testSetOwnerToQueue(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        CaseHandler.setOwnerToQueue(mockNewCaseRecord, UnitTestDataUtility.MOCK_USER_ID);
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockNewCaseRecord.OwnerId, 'owner was not updated');
        System.assertEquals(null, mockNewCaseRecord.Case_Owner__c, 'custom owner field was not set to null');
        Test.stopTest();
    }
    @isTest
    private static void testChangeRecordTypeToCustomerServiceRequest(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        CaseHandler.changeRecordTypeToCustomerServiceRequest(mockNewCaseRecord);
        System.assertEquals(CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST, mockNewCaseRecord.RecordTypeId, 'Record type id was not set to customer service request');
        Test.stopTest();
    }
    @isTest
    private static void testGetCasesForSPICheck(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        List<Case> caseList = CaseHandler.getCasesForSPICheck(mockNewCaseRecord, mockOldCaseRecord);
        System.assert(caseList.isEmpty(), 'cases were added to the spi list without a change to an text field');
        Test.stopTest();
    }
    @isTest
    private static void testUpdateCaseOwnerCustomField(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        List<Case> caseList = new List<Case>();
        caseList.add(mockNewCaseRecord);
        caseList.add(mockOldCaseRecord);
        CaseHandler.updateCaseOwnerCustomField(caseList);
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockNewCaseRecord.Case_Owner__c, 'case owner custom field was not set');
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockOldCaseRecord.Case_Owner__c, 'case owner custom field was not set');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleCaseOwnerChange(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
		mockOldCaseRecord.OwnerId = UnitTestDataUtility.MOCK_QUEUE_ID;
        mockOldCaseMap.put(mockNewCaseRecord.Id, mockOldCaseRecord);
        mockNewCaseRecord.OwnerId = UnitTestDataUtility.MOCK_USER_ID;
        mockNewCaseList.add(mockNewCaseRecord);
        CaseHandler.handleCaseOwnerChange(mockNewCaseList, mockOldCaseMap);
        System.assertEquals(null, mockNewCaseRecord.Assigned_To__c, 'Case record assigned to was not set to null');
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockNewCaseRecord.Case_Owner__c, 'Custom field was not updated to new user');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleCaseOwnerChangeToQueue(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseRecord.OwnerId = UnitTestDataUtility.MOCK_USER_ID;
        mockOldCaseMap.put(mockNewCaseRecord.Id, mockOldCaseRecord);
        mockNewCaseRecord.OwnerId = UnitTestDataUtility.MOCK_QUEUE_ID;
        mockNewCaseList.add(mockNewCaseRecord);
        CaseHandler.handleCaseOwnerChange(mockNewCaseList, mockOldCaseMap);
        System.assertEquals(null, mockNewCaseRecord.Assigned_To__c, 'Case record assigned to was not set to null');
        Test.stopTest();
    }
    
    @isTest
    private static void testHandleCaseOwnerChangeWithAgentRoleCheck(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseRecord.OwnerId = UnitTestDataUtility.MOCK_QUEUE_ID;
        mockOldCaseMap.put(mockNewCaseRecord.Id, mockOldCaseRecord);
        mockNewCaseRecord.OwnerId = UnitTestDataUtility.MOCK_USER_ID;
        mockNewCaseList.add(mockNewCaseRecord);
        CaseHandlerUtility.mockUserRequiresAgentRoleCheck = true;
        CaseHandler.handleCaseOwnerChange(mockNewCaseList, mockOldCaseMap);
        System.assertEquals(null, mockNewCaseRecord.Assigned_To__c, 'Case record assigned to was not set to null');
        System.assertEquals(UnitTestDataUtility.MOCK_USER_ID, mockNewCaseRecord.Case_Owner__c, 'Custom field was not updated to new user');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetCaseIdsAndAssociateTasks(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        Set<Id> caseIds = new Set<Id>();
        caseIds.add(UnitTestDataUtility.MOCK_CASE_ID);
        caseIds.add(UnitTestDataUtility.SECONDARY_MOCK_CASE_ID);
        mockNewCaseList.add(mockNewCaseRecord);
        CaseHandler.mockCases = mockNewCaseList;
		Set<Id> result = CaseHandler.getCaseIdsAndAssociateTasks(caseIds);
        System.assert(result.isEmpty(), 'Result was not empty');
        Test.stopTest();
    }
}