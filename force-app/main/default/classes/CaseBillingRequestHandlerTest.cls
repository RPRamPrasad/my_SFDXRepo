@isTest
(seeAllData=false)
public class CaseBillingRequestHandlerTest {
    private static Case mockCaseRecord = UnitTestDataUtility.buildCase(false);
    private static Case mockOldCaseRecord = UnitTestDataUtility.buildCase(true);
    private static Map<Id, Case> mockOldCaseMap = new Map<Id, Case>();    
    private static List<Case> mockCaseList;
    private static String billingAccountNumber = '1234567890';
    private static String roCode = '00';
    
    /**
     * @description setUp
     */
    @testSetup
    public static void setUp(){        
        Billing_Account__c account = new Billing_Account__c();
        account.AccountNumber__c = billingAccountNumber;
        account.Name = billingAccountNumber;
        account.SourceSystemIdentifier__c = billingAccountNumber + '~' + roCode;
        insert account;
    }

    @isTest
    private static void testHandleBillingRequestCases(){
        Test.startTest();
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
		System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            Case billingCase = testData();
            System.assert(String.isEmpty(billingCase.Billing_Account__c), 'billingCase.Billing_Account__c is not empty');
            CaseBillingRequestHandler.handleBillingRequestCases(mockCaseList,mockOldCaseMap);
            System.assert(!String.isEmpty(billingCase.Billing_Account__c), 'billingCase.Billing_Account__c is empty');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testProcessBillingRequestCases(){
        Test.startTest();
        Case billingCase = testData();
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
		System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            System.assert(String.isEmpty(billingCase.Billing_Account__c), 'billingCase.Billing_Account__c is not empty');
            CaseBillingRequestHandler.processBillingRequestCases(mockCaseList,mockOldCaseMap);
            System.assert(!String.isEmpty(billingCase.Billing_Account__c), 'billingCase.Billing_Account__c is empty');
        }
        Test.stopTest();
    }    

    private static Case testData() {
        Case billingCase = new Case();
        billingCase.PolicyNumber__c = billingAccountNumber;
        billingCase.LOB__c = CaseHandlerConstants.CASE_LOB_SFPP;
        mockCaseList = new List<Case>();
        mockCaseList.add(billingCase);
        return billingCase;
    }
}