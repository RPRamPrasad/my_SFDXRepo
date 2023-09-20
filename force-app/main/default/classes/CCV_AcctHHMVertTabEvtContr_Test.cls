/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages - TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AcctHHMVertTabEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountHHMVerticalTabEventController.logClickHouseholdMembersVerticalTab(),true);
        System.assert(CCV_AccountHHMVerticalTabEventController.logClickHHMVerticalTabOnAccount(),true);
        System.assert(CCV_AccountHHMVerticalTabEventController.logClickHHMVerticalTabOnCase(),true);
        System.assert(CCV_AccountHHMVerticalTabEventController.logClickHHMVerticalTabOnOpportunity(),true);
        System.assert(CCV_AccountHHMVerticalTabEventController.logClickHHMVerticalTabOnInsurancePolicy(),true);
        System.assert(CCV_AccountHHMVerticalTabEventController.logClickHHMVerticalTabOnBillingAccount(),true);
        System.assert(CCV_AccountHHMVerticalTabEventController.logClickHHMVerticalTabOnClaim(),true);
        System.assert(CCV_AccountHHMVerticalTabEventController.logClickHHMVerticalTabOnFinancialAccount(),true);
        System.assert(CCV_AccountHHMVerticalTabEventController.logClickHHMVerticalTabOnSimpleConversation(),true);
    }
}
