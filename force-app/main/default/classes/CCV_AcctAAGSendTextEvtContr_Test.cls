/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages - TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AcctAAGSendTextEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountAAGSendTextEventController.logClickAAGSendText(),true);
        System.assert(CCV_AccountAAGSendTextEventController.logClickAAGSendTextOnAccount(),true);
        System.assert(CCV_AccountAAGSendTextEventController.logClickAAGSendTextOnCase(),true);
        System.assert(CCV_AccountAAGSendTextEventController.logClickAAGSendTextOnOpportunity(),true);
        System.assert(CCV_AccountAAGSendTextEventController.logClickAAGSendTextOnInsurancePolicy(),true);
        System.assert(CCV_AccountAAGSendTextEventController.logClickAAGSendTextOnBillingAccount(),true);
        System.assert(CCV_AccountAAGSendTextEventController.logClickAAGSendTextOnClaim(),true);
        System.assert(CCV_AccountAAGSendTextEventController.logClickAAGSendTextOnFinancialAccount(),true);
        System.assert(CCV_AccountAAGSendTextEventController.logClickAAGSendTextOnSimpleConversation(),true);
    }
}
