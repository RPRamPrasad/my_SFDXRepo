/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages - TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AcctAAGPrimHHEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountAAGPrimaryHHEventController.logClickAAGPrimaryHousehold(),true);
        System.assert(CCV_AccountAAGPrimaryHHEventController.logClickAAGPrimaryHHOnAccount(),true);
        System.assert(CCV_AccountAAGPrimaryHHEventController.logClickAAGPrimaryHHOnCase(),true);
        System.assert(CCV_AccountAAGPrimaryHHEventController.logClickAAGPrimaryHHOnOpportunity(),true);
        System.assert(CCV_AccountAAGPrimaryHHEventController.logClickAAGPrimaryHHOnInsurancePolicy(),true);
        System.assert(CCV_AccountAAGPrimaryHHEventController.logClickAAGPrimaryHHOnBillingAccount(),true);
        System.assert(CCV_AccountAAGPrimaryHHEventController.logClickAAGPrimaryHHOnClaim(),true);
        System.assert(CCV_AccountAAGPrimaryHHEventController.logClickAAGPrimaryHHOnFinancialAccount(),true);
        System.assert(CCV_AccountAAGPrimaryHHEventController.logClickAAGPrimaryHHOnSimpleConversation(),true);
    }
}
