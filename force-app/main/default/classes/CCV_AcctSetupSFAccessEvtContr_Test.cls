/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages - TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

 @isTest(SeeAllData=false)
public with sharing class CCV_AcctSetupSFAccessEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountSetupSFAccessEventController.logClickSetupSFComAccess(),true);
        System.assert(CCV_AccountSetupSFAccessEventController.logClickSetupSFComAccessOnAccount(),true);
        System.assert(CCV_AccountSetupSFAccessEventController.logClickSetupSFComAccessOnCase(),true);
        System.assert(CCV_AccountSetupSFAccessEventController.logClickSetupSFComAccessOnOpportunity(),true);
        System.assert(CCV_AccountSetupSFAccessEventController.logClickSetupSFComAccessOnInsurancePolicy(),true);
        System.assert(CCV_AccountSetupSFAccessEventController.logClickSetupSFComAccessOnBillingAccount(),true);
        System.assert(CCV_AccountSetupSFAccessEventController.logClickSetupSFComAccessOnClaim(),true);
        System.assert(CCV_AccountSetupSFAccessEventController.logClickSetupSFComAccessOnFinancialAccount(),true);
        System.assert(CCV_AccountSetupSFAccessEventController.logClickSetupSFComAccessOnSimpleConversation(),true);
    }
}
