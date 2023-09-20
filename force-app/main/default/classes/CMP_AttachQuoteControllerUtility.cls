/**
* @description  utility class to help separate out complexity of CMP_AttachQuoteController
*/
public with sharing class CMP_AttachQuoteControllerUtility {
    private static final String LINE_OF_BUSINESS = 'Auto';
    
    /**
     * @description method to validate Attach Quote button access, required parameters and LOB access for attach quote.
     * @param opportunityInfo
     * @return pageMessage
     */
    public static String validateBeforeQuoteQuery(Opportunity opportunityInfo) {
        String pageMessage = '';
        String loggedInUserSubUserType = UTIL_LtngQuoteDataAccess.performQueryOnUser();
        if(!('Agent'.equals(loggedInUserSubUserType) || 'ATM'.equals(loggedInUserSubUserType))) {
            pageMessage = Label.CL_QUOTE_NOACTIONMSG;
        } else if(String.isBlank(opportunityInfo.LOB__c) || String.isBlank(opportunityInfo.Owner.Servicing_Agent_Associate_ID__c) || String.isBlank(opportunityInfo.Account.ClientIdentifier__c)) {
            pageMessage = Label.CL_QUOTE_MISSING_PARAM;
        } else if(!((LINE_OF_BUSINESS).equals(opportunityInfo.LOB__c))) {
            pageMessage = Label.CL_QUOTE_ATTACH_NOT_AVAILABLE;
        } else if(HLPR_OppButtonController.isOppNewAndAssignedToAnotherUser(opportunityInfo.StageName,opportunityInfo.Assigned_To__c)){
            pageMessage = Label.CL_OPP_ASSIGNED_TO_ERROR;
        }
        return pageMessage;
    }
}