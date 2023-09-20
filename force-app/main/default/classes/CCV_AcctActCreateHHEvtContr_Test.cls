/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages - TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AcctActCreateHHEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountActionCreateHHEventController.logClickCreateHousehold(),true);
        System.assert(CCV_AccountActionCreateHHEventController.logClickCreateHouseholdOnAccount(),true);
        System.assert(CCV_AccountActionCreateHHEventController.logClickCreateHouseholdOnCase(),true);
        System.assert(CCV_AccountActionCreateHHEventController.logClickCreateHouseholdOnOpportunity(),true);
        System.assert(CCV_AccountActionCreateHHEventController.logClickCreateHouseholdOnInsurancePolicy(),true);
        System.assert(CCV_AccountActionCreateHHEventController.logClickCreateHouseholdOnBillingAccount(),true);
        System.assert(CCV_AccountActionCreateHHEventController.logClickCreateHouseholdOnClaim(),true);
        System.assert(CCV_AccountActionCreateHHEventController.logClickCreateHouseholdOnFinancialAccount(),true);
        System.assert(CCV_AccountActionCreateHHEventController.logClickCreateHouseholdOnSimpleConversation(),true);
    }
}
