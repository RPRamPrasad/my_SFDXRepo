/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages - TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AcctAAGSendEmailEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountAAGSendEmailEventController.logClickAAGSendEmail(),true);
        System.assert(CCV_AccountAAGSendEmailEventController.logClickAAGSendEmailOnAccount(),true);
        System.assert(CCV_AccountAAGSendEmailEventController.logClickAAGSendEmailOnCase(),true);
        System.assert(CCV_AccountAAGSendEmailEventController.logClickAAGSendEmailOnOpportunity(),true);
        System.assert(CCV_AccountAAGSendEmailEventController.logClickAAGSendEmailOnInsurancePolicy(),true);
        System.assert(CCV_AccountAAGSendEmailEventController.logClickAAGSendEmailOnBillingAccount(),true);
        System.assert(CCV_AccountAAGSendEmailEventController.logClickAAGSendEmailOnClaim(),true);
        System.assert(CCV_AccountAAGSendEmailEventController.logClickAAGSendEmailOnFinancialAccount(),true);
        System.assert(CCV_AccountAAGSendEmailEventController.logClickAAGSendEmailOnSimpleConversation(),true);
    }
}
