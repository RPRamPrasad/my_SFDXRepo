/** 
* @description handle billing BIC cases
* @Owner: Mercury - SF Billing
*/
@IsTest
public with sharing class CaseBillingHandlerTest {

    @IsTest
    public static void getBillingAccountsTest() {
        String billingAccountNumber = '1234567890';
        String roCode = '00';
        Billing_Account__c account = new Billing_Account__c();
        account.AccountNumber__c = billingAccountNumber;
        account.Name = billingAccountNumber;
        account.SourceSystemIdentifier__c = billingAccountNumber + '~' + roCode;
        insert account;

        Case billingCase = new Case();

        Map<String, Case> billingCaseMap = new Map<String, Case>();
        billingCaseMap.put(billingAccountNumber, billingCase);
        Test.startTest();
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){ 
            System.assert(String.isEmpty(billingCase.Billing_Account__c), 'billingCase.Billing_Account__c is not empty');
            CaseBillingHandler.assignBillingAccount(billingCaseMap);
            System.assert(!String.isEmpty(billingCase.Billing_Account__c), 'bililngCase.Billing_Account__c is empty');
        }
        Test.stopTest();

    }

}