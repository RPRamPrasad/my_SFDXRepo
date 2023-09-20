/** 
* @description CaseRecordTypeSortingUtility Unit tests 
* @Owner: CATS
*/
@isTest
(seeAllData=false)
private class CaseRecordTypeSortingUtilityTest {
    
    private static Case mockCaseRecord = UnitTestDataUtility.buildCase(true);
    private static Case mockOldCaseRecord = UnitTestDataUtility.buildCase(true);
    private static Map<Id, Case> mockOldCaseMap = new Map<Id, Case>();
    private static List<Case> mockNewCaseList = new List<Case>();
    
    @isTest
    private static void testHandleRecordTypeSortingTempCase(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseMap.put(mockCaseRecord.Id, mockOldCaseRecord);
        mockCaseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_TEMP_CASE;
        mockNewCaseList.add(mockCaseRecord);
        CaseRecordTypeSortingUtility.handleRecordTypeSorting(mockNewCaseList, mockOldCaseMap);
        System.assert(CaseRecordTypeSortingUtility.customerServiceRequestCases.size() == 1, 'temp record type was not switched to CSR');
        System.assert(CaseRecordTypeSortingUtility.customerServiceRequestCases.contains(mockCaseRecord), 'temp record type was not switched to CSR');
        Test.stopTest();
    }

    @isTest
    private static void testHandleRecordTypeSortingCustomerServiceRequest(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseMap.put(mockCaseRecord.Id, mockOldCaseRecord);
        mockCaseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST;
        mockNewCaseList.add(mockCaseRecord);
        CaseRecordTypeSortingUtility.handleRecordTypeSorting(mockNewCaseList, mockOldCaseMap);
        System.assert(CaseRecordTypeSortingUtility.customerServiceRequestCases.size() == 1, 'csr record type was not put in the CSR List');
        System.assert(CaseRecordTypeSortingUtility.customerServiceRequestCases.contains(mockCaseRecord), 'csr record type was not put in the CSR List');
        System.assert(CaseRecordTypeSortingUtility.ownerCheckCases.size() == 1, 'csr record type was not put in the owner check List');
        System.assert(CaseRecordTypeSortingUtility.ownerCheckCases.contains(mockCaseRecord), 'csr record type was not put in the owner check List');
        Test.stopTest();
    }
    @isTest
    private static void testHandleRecordTypeSortingDataAccessRequest(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseMap.put(mockCaseRecord.Id, mockOldCaseRecord);
        mockCaseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_DATA_ACCESS_REQUEST;
        mockNewCaseList.add(mockCaseRecord);
        CaseRecordTypeSortingUtility.handleRecordTypeSorting(mockNewCaseList, mockOldCaseMap);
        System.assert(CaseRecordTypeSortingUtility.dataAccessRequestCases.size() == 1, 'dar record type was not put in the dar List');
        System.assert(CaseRecordTypeSortingUtility.dataAccessRequestCases.contains(mockCaseRecord), 'dar record type was not put in the dar List');
        System.assert(CaseRecordTypeSortingUtility.ownerCheckCases.size() == 0, 'dar record type was put in the owner check List');
        Test.stopTest();
        
    }
    @isTest
    private static void testHandleRecordTypeSortingRetentionCase(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseMap.put(mockCaseRecord.Id, mockOldCaseRecord);
        mockCaseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_RETENTION;
        mockNewCaseList.add(mockCaseRecord);
        CaseRecordTypeSortingUtility.handleRecordTypeSorting(mockNewCaseList, mockOldCaseMap);
        System.assert(CaseRecordTypeSortingUtility.retentionCases.size() == 1, 'retention record type was not put in the retention List');
        System.assert(CaseRecordTypeSortingUtility.retentionCases.contains(mockCaseRecord), 'retention record type was not put in the retention List');
        System.assert(CaseRecordTypeSortingUtility.ownerCheckCases.size() == 1, 'retention record type was not put in the owner check List');
        System.assert(CaseRecordTypeSortingUtility.ownerCheckCases.contains(mockCaseRecord), 'retention record type was not put in the owner check List');
        Test.stopTest();
    }
    @isTest
    private static void testHandleRecordTypeSortingPolicyChangeCase(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseMap.put(mockCaseRecord.Id, mockOldCaseRecord);
        mockCaseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE;
        mockNewCaseList.add(mockCaseRecord);
        CaseRecordTypeSortingUtility.handleRecordTypeSorting(mockNewCaseList, mockOldCaseMap);
        System.assert(CaseRecordTypeSortingUtility.policyChangeCases.size() == 1, 'policy change record type was not put in the policyChange List');
        System.assert(CaseRecordTypeSortingUtility.policyChangeCases.contains(mockCaseRecord), 'policy change record type was not put in the policyChange List');
        System.assert(CaseRecordTypeSortingUtility.ownerCheckCases.size() == 1, 'policy change record type was not put in the owner check List');
        System.assert(CaseRecordTypeSortingUtility.ownerCheckCases.contains(mockCaseRecord), 'policy change record type was not put in the owner check List');
        Test.stopTest();
    }
    @isTest
    private static void testHandleRecordTypeSortingBillingRequestCase(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest= true;
        mockOldCaseMap.put(mockCaseRecord.Id, mockOldCaseRecord);
        mockCaseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_BILLING_REQUEST;
        mockNewCaseList.add(mockCaseRecord);
        CaseRecordTypeSortingUtility.handleRecordTypeSorting(mockNewCaseList, mockOldCaseMap);
        System.assert(CaseRecordTypeSortingUtility.billingRequestCases.size() == 1, 'Billing Request record type was not put in the billingRequest List');
        System.assert(CaseRecordTypeSortingUtility.billingRequestCases.contains(mockCaseRecord), 'Billing Request record type was not put in the billingRequest List');
        System.assert(CaseRecordTypeSortingUtility.ownerCheckCases.size() == 1, 'Billing Request record type was not put in the owner check List');
        System.assert(CaseRecordTypeSortingUtility.ownerCheckCases.contains(mockCaseRecord), 'Billing Request record type was not put in the owner check List');
        Test.stopTest();
    }
    
}