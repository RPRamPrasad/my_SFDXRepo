/**
 * @author NSYNC
 * @name BillingIPParticipantTriggerHandler
 * @date 12/13/2021
 * @description This class is responsible for managing Billing Account Shares
 * after InsurancePolicyParticipant records have been inserted or deleted.
 */
public without sharing class BillingIPParticipantTriggerHandler {

    private static final String ACCESS_LEVEL = 'Read';
    private static final String MANUAL_ROW_CAUSE = 'Manual';

    /**
     * @name createBillingAccountSharesFromPolicyParticipants
     * @description generates Billing Account shares from the given InsurancePolicyShare records
     * @param ipShares
     * @return results
     */
    public List<Database.SaveResult> createBillingAccountSharesFromPolicyParticipants(List<InsurancePolicyShare> ipShares) {
        List<Database.SaveResult> results = new List<Database.SaveResult>();

        if (!UTIL_BillingAccountShares.isBillingSharesEnabled()) {
            return new List<Database.SaveResult>();
        }

        // build a map to hold the list of proxy IDs for each policy ID
        Map<Id,List<Id>> policyProxies = new Map<Id, List<Id>>();
        for (InsurancePolicyShare share : ipShares) {
            if (policyProxies.get(share.ParentId) == null) {
                policyProxies.put(share.ParentId, new List<Id>{share.UserOrGroupId});
            } else {
                List<Id> proxies = policyProxies.get(share.ParentId);
                proxies.add(share.UserOrGroupId);
            }
        }

        // retrieve the billing policies for the policies referenced in the received policy shares
        List<Billing_Policy__c> billingPolicies = [SELECT InsurancePolicyId__c, BillingAccountID__r.Id
                                                    FROM Billing_Policy__c
                                                    WHERE InsurancePolicyId__c IN :policyProxies.keySet()];

        // build a map of policy IDs to billing account IDs
        Map<Id, Id> policyBillingAccounts = new Map<Id, Id>();
        for (Billing_Policy__c billingPolicy : billingPolicies) {
            policyBillingAccounts.put(billingPolicy.InsurancePolicyId__c, billingPolicy.BillingAccountID__r.Id);
        }

        Set<Billing_Account__Share> billingShares = new Set<Billing_Account__Share>();

        // generate the Billing Account shares
        for (Id policyId : policyProxies.keySet()) {
            Id billingAccountId = policyBillingAccounts.get(policyId);
            if (billingAccountId != null) {
                List<Id> proxies = policyProxies.get(policyId);
                for (Id proxy : proxies) {
                    Billing_Account__Share billingShare = new Billing_Account__Share();
                    billingShare.ParentId = billingAccountId;
                    billingShare.UserOrGroupId = proxy;
                    billingShare.AccessLevel = ACCESS_LEVEL;
                    billingShare.RowCause = MANUAL_ROW_CAUSE;
                    billingShares.add(billingShare);
                }
            }
        }

        // insert the Billing Account shares
        results = UTIL_BillingAccountSharesAdd.insertBillingAccountShares(billingShares);
        return results;
    }

    /**
     * @name handleAfterDeleteInsurancePolicyParticipant
     * @description generates and inserts the Billing Account shares associated with the given InsurancePolicyParticipant records
     * @param insurancePolicyParticipants
     * @return results
     */
    public List<Database.SaveResult> handleAfterDeleteInsurancePolicyParticipant(List<InsurancePolicyParticipant> insurancePolicyParticipants) {

        if (!UTIL_BillingAccountShares.isBillingSharesEnabled()) {
            return new List<Database.SaveResult>();
        }

        // get the policies for the received IP participants
        Set<Id> policyIds = new Set<Id>();
        for (InsurancePolicyParticipant participant : insurancePolicyParticipants) {
            policyIds.add(participant.InsurancePolicyId);
        }

        return UTIL_BillingAccountShares.refreshBillingSharesFromPolicies(policyIds);
    }

   
}
