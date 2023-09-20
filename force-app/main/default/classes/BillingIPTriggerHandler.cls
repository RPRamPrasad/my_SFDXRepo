/**
 * @author NSYNC
 * @name BillingIPTriggerHandler
 * @date 1/25/2022
 * @description This class is responsible for managing Billing Account Shares:
 *  1) after InsurancePolicy records have been updated
 *  2) before InsurancePolicy records will be deleted.
 */
public with sharing class BillingIPTriggerHandler {

    /**
     * @name - updateBillingSharesForUpdatedPolicies
     * @description - refreshes the billing shares relating to policies that have name insured changes and returns the database results.
     * @param previousPolicies
     * @param currentPolicies
     * @return List<Database.SaveResult>
     */
    public List<Database.SaveResult> updateBillingSharesForUpdatedPolicies(Map<Id, InsurancePolicy> previousPolicies, Map<Id, InsurancePolicy> currentPolicies) {
        List<Database.SaveResult> results = new List<Database.SaveResult>();

        if (!UTIL_BillingAccountShares.isBillingSharesEnabled()) {
            return results;
        }
        
        
        // track the policies that have been updated with different named insured's
        Set<Id> updatedPolicies = new Set<Id>();

        // Loop through the newly updated policies and check if the named insured has changed
        for (Id policyId : currentPolicies.keySet()) {
            Id previousAccountId = previousPolicies.get(policyId).NameInsuredId;
            Id currentAccountId = currentPolicies.get(policyId).NameInsuredId;

            // If the named insured has changed, the billing shares related to the policy need to be re-calculated
            if (previousAccountId != currentAccountId) {
                updatedPolicies.add(policyId);
            }
        }

        if (!updatedPolicies.isEmpty()) {
            results = UTIL_BillingAccountShares.refreshBillingSharesFromPolicies(updatedPolicies);
        }

        return results;
    }

    /**
     * @name - updateBillingSharesForDeletedPolicies
     * @description - refreshes the billing shares relating to policies that have been deleted and returns the database results.
     * @param insurancePolicyIds
     * @return List<Database.SaveResult>
     */
    public List<Database.SaveResult> updateBillingSharesForDeletedPolicies(Set<Id> insurancePolicyIds) {

        List<Database.SaveResult> results = new List<Database.SaveResult>();

        if (!UTIL_BillingAccountShares.isBillingSharesEnabled()) {
            return results;
        }

        if (!insurancePolicyIds.isEmpty()) {

            results = UTIL_BillingAccountShares.refreshBillingSharesFromPolicies(insurancePolicyIds);
        }

        return results;
    }
}
