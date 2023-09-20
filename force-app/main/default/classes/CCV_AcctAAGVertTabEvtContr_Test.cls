/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages - TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AcctAAGVertTabEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountAAGVerticalTabEventController.logClickAtAGlanceVerticalTab(),true);
        System.assert(CCV_AccountAAGVerticalTabEventController.logClickAAGVerticalTabOnAccount(),true);
        System.assert(CCV_AccountAAGVerticalTabEventController.logClickAAGVerticalTabOnCase(),true);
        System.assert(CCV_AccountAAGVerticalTabEventController.logClickAAGVerticalTabOnOpportunity(),true);
        System.assert(CCV_AccountAAGVerticalTabEventController.logClickAAGVerticalTabOnInsurancePolicy(),true);
        System.assert(CCV_AccountAAGVerticalTabEventController.logClickAAGVerticalTabOnBillingAccount(),true);
        System.assert(CCV_AccountAAGVerticalTabEventController.logClickAAGVerticalTabOnClaim(),true);
        System.assert(CCV_AccountAAGVerticalTabEventController.logClickAAGVerticalTabOnFinancialAccount(),true);
        System.assert(CCV_AccountAAGVerticalTabEventController.logClickAAGVerticalTabOnSimpleConversation(),true);
    }
}
