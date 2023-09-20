/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages _ TEST
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AcctActManRelnEvtContr_Test {
    @isTest
    private static void testAllClickEvents() {
        System.assert(CCV_AccountActionManRelnEventController.logClickManageRelationships(),true);
        System.assert(CCV_AccountActionManRelnEventController.logClickManageRelshipsOnAccount(),true);
        System.assert(CCV_AccountActionManRelnEventController.logClickManageRelshipsOnCase(),true);
        System.assert(CCV_AccountActionManRelnEventController.logClickManageRelshipsOnOpportunity(),true);
        System.assert(CCV_AccountActionManRelnEventController.logClickManageRelshipsOnInsurancePolicy(),true);
        System.assert(CCV_AccountActionManRelnEventController.logClickManageRelshipsOnBillingAccount(),true);
        System.assert(CCV_AccountActionManRelnEventController.logClickManageRelshipsOnClaim(),true);
        System.assert(CCV_AccountActionManRelnEventController.logClickManageRelshipsOnFinancialAccount(),true);
        System.assert(CCV_AccountActionManRelnEventController.logClickManageRelshipsOnSimpleConversation(),true);
    }
}
