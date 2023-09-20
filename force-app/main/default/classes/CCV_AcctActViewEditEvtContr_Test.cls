/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages _ TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AcctActViewEditEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountActionViewEditEventController.logClickViewDetailsEdit(),true);
        System.assert(CCV_AccountActionViewEditEventController.logClickViewDetailsEditOnAccount(),true);
        System.assert(CCV_AccountActionViewEditEventController.logClickViewDetailsEditOnCase(),true);
        System.assert(CCV_AccountActionViewEditEventController.logClickViewDetailsEditOnOpportunity(),true);
        System.assert(CCV_AccountActionViewEditEventController.logClickViewDetailsEditOnInsurancePolicy(),true);
        System.assert(CCV_AccountActionViewEditEventController.logClickViewDetailsEditOnBillingAccount(),true);
        System.assert(CCV_AccountActionViewEditEventController.logClickViewDetailsEditOnClaim(),true);
        System.assert(CCV_AccountActionViewEditEventController.logClickViewDetailsEditOnFinancialAccount(),true);
        System.assert(CCV_AccountActionViewEditEventController.logClickViewDetailsEditOnSimpleConversation(),true);
    }
}
