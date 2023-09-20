/**
 * @name BillingParticipantTriggerHandler
 * @author Nsync
 * @description Serves as the Apex handler for Billing Participant triggers. 
 */

public with sharing class BillingParticipantTriggerHandler {

    /**
     * @name handleAfterInsertBillingParticipant
     * @description inserts BillingAccountShare records when a new Billing Participant is inserted.
     * @param billingParticipants
     * @return List<Database.SaveResult>
     */
    public List<Database.SaveResult> handleAfterInsertBillingParticipant(List<Billing_Participant__c> billingParticipants) {
        List<Database.SaveResult> results = new List<Database.SaveResult>();

        if (!UTIL_BillingAccountShares.isBillingSharesEnabled()) {
            return new List<Database.SaveResult>();
        }
        

        Set<Billing_Account__Share> billingShares = UTIL_BillingAccountShares.getBillingAccountSharesForBillingParticipants(billingParticipants);

        results = UTIL_BillingAccountSharesAdd.insertBillingAccountShares(billingShares);
        return results;

    }

     /**
     * @name handleAfterDeleteBillingParticipant
     * @description inserts back remaining Billing Shares for the related Account shares and Insurance Policy shares.
     * @param changedBillingParticipants
     * @return List<Database.SaveResult>
     */

     public List<Database.SaveResult> handleAfterDeleteBillingParticipant(List<Billing_Participant__c> changedBillingParticipants){


        if (!UTIL_BillingAccountShares.isBillingSharesEnabled()) {
            return new List<Database.SaveResult>();
        }
        

        Set<Id> billingAccountIds = new Set<Id>();
        for (Billing_Participant__c billingParticipant : changedBillingParticipants){
            billingAccountIds.add(billingParticipant.BillingAccountID__c);
        }

        return UTIL_BillingAccountShares.refreshBillingShares(billingAccountIds);
     }


     /**
     * @name handleAfterUpdateBillingParticipant
     * @description refreshes the Billing Account Share records for the related Account shares and Insurance Policy shares.
     * @param previousBillingParticipants
     * @param currentBillingParticipants
     * @return List<Database.SaveResult>
     */
     public List<Database.SaveResult> handleAfterUpdateBillingParticipant(Map<Id, Billing_Participant__c> previousBillingParticipants, Map<Id, Billing_Participant__c> currentBillingParticipants) {

        List<Database.SaveResult> results = new List<Database.SaveResult>();

        if (!UTIL_BillingAccountShares.isBillingSharesEnabled()) {
            return results;
        }
        
        
        // track the billing participants that have been updated
        Set<Id> updatedBillingParticipants = new Set<Id>();

        // Loop through the updated participants and check if the participant account Id has changed
        for (Id billingParticipantId : currentBillingParticipants.keySet()) {
            Id previousParticipantAccountId = previousBillingParticipants.get(billingParticipantId).ParticipantAccountId__c;
            Id currentParticipantAccountId = currentBillingParticipants.get(billingParticipantId).ParticipantAccountId__c;

            // If the participant account Id has changed, the billing shares related to the account need to be re-calculated
            if (previousParticipantAccountId != currentParticipantAccountId) {
                updatedBillingParticipants.add(billingParticipantId);
            }
        }

        if (!updatedBillingParticipants.isEmpty()) {
            
            results = UTIL_BillingAccountShares.refreshBillingSharesForBillingParticipants(updatedBillingParticipants);
        }

        return results;
    }

}
