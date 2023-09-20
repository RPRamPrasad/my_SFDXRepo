@isTest
(seeAllData=false)
private class CaseChangeOfAddressProcessorTest {

    
    @isTest
    private static void testCreateCOATasks(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        Case caseRecord = UnitTestDataUtility.buildCase(true);
        caseRecord.App_Code__c = 'SFDC - Account UI';
        caseRecord.Reason = CaseHandlerConstants.CASE_REASON_CHANGE_OF_ADDRESS;
        List<Case> cases = new List<Case>();
        cases.add(caseRecord);
        CaseChangeOfAddressProcessor processor = new CaseChangeOfAddressProcessor();
        processor.createCOATasks(cases);
        System.assert(!processor.tasks.isEmpty(), 'task was not added to the list');
        Test.stopTest();
    }
    
}