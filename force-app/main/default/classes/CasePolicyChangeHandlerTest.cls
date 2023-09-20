@isTest
(seeAllData=false)
private class CasePolicyChangeHandlerTest {

    private static Case mockCaseRecord = UnitTestDataUtility.buildCase(false);
    private static Case mockOldCaseRecord = UnitTestDataUtility.buildCase(true);
    private static Map<Id, Case> mockOldCaseMap = new Map<Id, Case>();    
    private static List<Case> mockCaseList = new List<Case>();
    
    @isTest
    private static void testHandlePolicyChangeCases(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockOldCaseMap.put(mockCaseRecord.Id, mockOldCaseRecord);
        mockCaseList.add(mockCaseRecord);
        CasePolicyChangeHandler.handlePolicyChangeCases(mockCaseList,mockOldCaseMap);
        System.assert(Limits.getDmlStatements() == 0, 'unexpected DML');
        Test.stopTest();
    }
    
    @isTest
    private static void testProcessPolicyChangeCases(){
    	 Test.startTest();
         UnitTestDataUtility.isUnitTest = true;  
         CaseBeforeTriggerHandler.isInsert = true;
         mockCaseList.add(mockCaseRecord);
         CasePolicyChangeHandler.processPolicyChangeCases(mockCaseList,null);
         System.assert( mockCaseList[0].Assigned_To__c != null ,'Assigned to cannot be null');
         Test.stopTest();    
    }    
    
}