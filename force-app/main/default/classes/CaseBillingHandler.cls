/** 
* @description handle billing BIC cases
* @Owner: Mercury - SF Billing
*/
public with sharing class CaseBillingHandler {

    /**
     * @description assignBillingAccount
     * @param billingCaseMap 
     */
    public static void assignBillingAccount(Map<String, Case> billingCaseMap){
        List<Billing_Account__c> billingAccounts = getBillingAccounts(billingCaseMap.keySet());

        for (Billing_Account__c billingAccount : billingAccounts){
            Case billingCase = billingCaseMap.get(billingAccount.Name);
            billingCase.Billing_Account__c = billingAccount.Id;
        }
    }

    @TestVisible
    private static List<Billing_Account__c> getBillingAccounts(Set<String> billingAccountNumbers) {
        List<Billing_Account__c> billingAccounts = Security.stripInaccessible(AccessType.READABLE,
            [SELECT Id, Name FROM Billing_Account__c WHERE Name IN :billingAccountNumbers ]).getRecords();
        return billingAccounts;
    }

}