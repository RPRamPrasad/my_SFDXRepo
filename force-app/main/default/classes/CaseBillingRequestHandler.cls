/** 
* @description handle billing request cases
* @Owner: Mercury - SF Billing
*/
public with sharing class CaseBillingRequestHandler {

    @TestVisible private static Map<String, Case> billingRequestCaseMap = new Map<String, Case>();

    /**
     * @description : Handles Billing Request Case insert and updates
     * @param billingRequestCases 
     * @param oldCaseMap
     */
    
    public static void handleBillingRequestCases(List<Case> billingRequestCases, Map<Id,Case> oldCaseMap){
        processbillingRequestCases(billingRequestCases, oldCaseMap);
    }
    
    @TestVisible private static void processBillingRequestCases(List<Case> billingRequestCases, Map<Id,Case> oldCaseMap){
        
		for(Case caseRecord : billingRequestCases){
            if (String.isNotBlank(caseRecord.PolicyNumber__c)) {
                billingRequestCaseMap.put(caseRecord.PolicyNumber__c, caseRecord);
            }
        }

        if(!billingRequestCaseMap.isEmpty()){
            CaseBillingHandler.assignBillingAccount(billingRequestCaseMap);
        }
    }
}