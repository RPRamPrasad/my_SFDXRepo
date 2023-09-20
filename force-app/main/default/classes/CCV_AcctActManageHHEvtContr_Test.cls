/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages - TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AcctActManageHHEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountActionManageHHEventController.logClickManageHousehold(),true);
        System.assert(CCV_AccountActionManageHHEventController.logClickManageHouseholdOnAccount(),true);
        System.assert(CCV_AccountActionManageHHEventController.logClickManageHouseholdOnCase(),true);
        System.assert(CCV_AccountActionManageHHEventController.logClickManageHouseholdOnOpportunity(),true);
        System.assert(CCV_AccountActionManageHHEventController.logClickManageHouseholdOnInsurancePolicy(),true);
        System.assert(CCV_AccountActionManageHHEventController.logClickManageHouseholdOnBillingAccount(),true);
        System.assert(CCV_AccountActionManageHHEventController.logClickManageHouseholdOnClaim(),true);
        System.assert(CCV_AccountActionManageHHEventController.logClickManageHouseholdOnFinancialAccount(),true);
        System.assert(CCV_AccountActionManageHHEventController.logClickManageHouseholdOnSimpleConversation(),true);
    }
}
