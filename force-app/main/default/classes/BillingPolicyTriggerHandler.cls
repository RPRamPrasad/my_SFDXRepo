/**
 * @name BillingPolicyTriggerHandler
 * @author Nsync
 * @description Serves as the Apex handler for Billing Policy triggers. 
 */

public with sharing class BillingPolicyTriggerHandler {
  
    /**
     * @name handleAfterInsertBillingPolicy
     * @description inserts BillingAccountShare records when a new Billing Policy is inserted.
     * @param billingPolicies
     * @return List<Database.SaveResult>
     */
    public List<Database.SaveResult> handleAfterInsertBillingPolicy(List<Billing_Policy__c> billingPolicies) {
        List<Database.SaveResult> results = new List<Database.SaveResult>();

        if (!UTIL_BillingAccountShares.isBillingSharesEnabled()) {
            return new List<Database.SaveResult>();
        }
        

        Set<Billing_Account__Share> billingShares = UTIL_BillingAccountShares.getBillingAccountSharesForBillingPolicies(billingPolicies);

        results = UTIL_BillingAccountSharesAdd.insertBillingAccountShares(billingShares);
        return results;
    }

     /**
     * @name handleAfterUpdateBillingPolicy
     * @description refreshes the Billing Account Share records for the related Insurance Policy shares and Account shares.
     * @param previousBillingPolicies
     * @param currentBillingPolicies
     * @return List<Database.SaveResult>
     */
    public List<Database.SaveResult> handleAfterUpdateBillingPolicy(Map<Id, Billing_Policy__c> previousBillingPolicies, Map<Id, Billing_Policy__c> currentBillingPolicies){


        List<Database.SaveResult> results = new List<Database.SaveResult>();

        if (!UTIL_BillingAccountShares.isBillingSharesEnabled()) {
            return results;
        }
        
        // track the billling policies that have been updated with different policies
        Set<Id> updatedBillingPolicies = new Set<Id>();

        // Loop through the newly updated billing policies and check if their policies have changed
        for (Id billingPolicyId : currentBillingPolicies.keySet()) {
            Id previousInsurancePolicyId = previousBillingPolicies.get(billingPolicyId).InsurancePolicyId__c;
            Id currentInsurancePolicyId = currentBillingPolicies.get(billingPolicyId).InsurancePolicyId__c;

            // If the policy has changed, the billing shares related to the policy need to be re-calculated
            if (previousInsurancePolicyId != currentInsurancePolicyId) {
                updatedBillingPolicies.add(billingPolicyId);
            }
        }

        if (!updatedBillingPolicies.isEmpty()) {
            results = UTIL_BillingAccountShares.refreshBillingSharesForBillingPolicies(updatedBillingPolicies);
        }

        return results;
    }

     /**
     * @name handleAfterDeleteBillingPolicy
     * @description inserts Billing Account Share records for the related Insurance Policy shares and Account shares.
     * @param changedBillingPolicies
     * @return List<Database.SaveResult>
     */

     public List<Database.SaveResult> handleAfterDeleteBillingPolicy(List<Billing_Policy__c> changedBillingPolicies){


        if (!UTIL_BillingAccountShares.isBillingSharesEnabled()) {
            return new List<Database.SaveResult>();
        }
        

        Set<Id> billingAccountIds = new Set<Id>();
        for(Billing_Policy__c billingPolicy : changedBillingPolicies){
            billingAccountIds.add(billingPolicy.BillingAccountID__c);
        }

        return UTIL_BillingAccountShares.refreshBillingShares(billingAccountIds);
     }
}
