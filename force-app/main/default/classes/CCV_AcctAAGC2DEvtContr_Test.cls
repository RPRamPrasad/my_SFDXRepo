/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages - TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AcctAAGC2DEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountAAGClickToDialEventController.logClickAAGClickToDial(),true);
        System.assert(CCV_AccountAAGClickToDialEventController.logClickAAGClickToDialOnAccount(),true);
        System.assert(CCV_AccountAAGClickToDialEventController.logClickAAGClickToDialOnCase(),true);
        System.assert(CCV_AccountAAGClickToDialEventController.logClickAAGClickToDialOnOpportunity(),true);
        System.assert(CCV_AccountAAGClickToDialEventController.logClickAAGClickToDialOnInsurancePolicy(),true);
        System.assert(CCV_AccountAAGClickToDialEventController.logClickAAGClickToDialOnBillingAccount(),true);
        System.assert(CCV_AccountAAGClickToDialEventController.logClickAAGClickToDialOnClaim(),true);
        System.assert(CCV_AccountAAGClickToDialEventController.logClickAAGClickToDialOnFinancialAccount(),true);
        System.assert(CCV_AccountAAGClickToDialEventController.logClickAAGClickToDialOnSimpleConversation(),true);
    }
}
