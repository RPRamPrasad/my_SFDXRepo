/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages - TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AcctActEditEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountActionEditEventController.logClickEdit(),true);
        System.assert(CCV_AccountActionEditEventController.logClickEditOnAccount(),true);
        System.assert(CCV_AccountActionEditEventController.logClickEditOnCase(),true);
        System.assert(CCV_AccountActionEditEventController.logClickEditOnOpportunity(),true);
        System.assert(CCV_AccountActionEditEventController.logClickEditOnInsurancePolicy(),true);
        System.assert(CCV_AccountActionEditEventController.logClickEditOnBillingAccount(),true);
        System.assert(CCV_AccountActionEditEventController.logClickEditOnClaim(),true);
        System.assert(CCV_AccountActionEditEventController.logClickEditOnFinancialAccount(),true);
        System.assert(CCV_AccountActionEditEventController.logClickEditOnSimpleConversation(),true);
    }
}
