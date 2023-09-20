/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages _ TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AcctActViewEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountActionViewEventController.logClickViewDetails(),true);
        System.assert(CCV_AccountActionViewEventController.logClickViewDetailsOnAccount(),true);
        System.assert(CCV_AccountActionViewEventController.logClickViewDetailsOnCase(),true);
        System.assert(CCV_AccountActionViewEventController.logClickViewDetailsOnOpportunity(),true);
        System.assert(CCV_AccountActionViewEventController.logClickViewDetailsOnInsurancePolicy(),true);
        System.assert(CCV_AccountActionViewEventController.logClickViewDetailsOnBillingAccount(),true);
        System.assert(CCV_AccountActionViewEventController.logClickViewDetailsOnClaim(),true);
        System.assert(CCV_AccountActionViewEventController.logClickViewDetailsOnFinancialAccount(),true);
        System.assert(CCV_AccountActionViewEventController.logClickViewDetailsOnSimpleConversation(),true);
    }
}
