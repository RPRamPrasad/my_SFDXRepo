/** 
 * @author Team Kraken (kdcv)
 * @description IP_SharesTriggerHandler : Handles shares trigger logic for InsurancePolicy objects
 * @version 1.0
 * @dateCreated 10/29/2020
 */

public with sharing class IP_SharesTriggerHandler extends IP_SharesManager {
    private static final String CLASS_NAME = 'IP_SharesTriggerHandler';
    /**
     * @description handleAfterInsert
     * @param newPolicies 
     */
    public void handleAfterInsert(List<InsurancePolicy> newPolicies) {

        Integer startingCpuTime = Limits.getCpuTime();

        // First we build the data structures we need to hold our data
        Map<Id, Set<Id>> accountIdToAgentIdList = new Map<Id, Set<Id>>();
        List<PolicyMember> policyMembers = new List<PolicyMember>();

        for (InsurancePolicy policy : newPolicies) {
            // The primary named insured doens't exist as a participant (IPP),
            // so in order to create a share for that account's agents,
            // we need to insert those account ids into accountIdToAgentIdList manually
            accountIdToAgentIdList.put(policy.NameInsuredId, new Set<Id>());

            policyMembers.add(new PolicyMember(policy));
        }

        buildShares(policyMembers, accountIdToAgentIdList);

        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' Creating shares for [' + newPolicies.size() + 
        '] Insurance Policies took ['+ (Limits.getCpuTime() - startingCpuTime) + '] of CPU Time');
    }

    /**
     * Handle updates to InsurancePolicies for shares
     * @description handleBeforeUpdate
     * @param previousPolicies 
     * @param currentPolicies 
     */
    public void handleBeforeUpdate(Map<Id, InsurancePolicy> previousPolicies, Map<Id, InsurancePolicy> currentPolicies) {
		handleBeforeUpdate(previousPolicies, currentPolicies, false);
    }

    /**
     * Handle updates to InsurancePolicies for shares
     * @description handleBeforeUpdate
     * @param previousPolicies 
     * @param currentPolicies 
     * @param resend 
     */
    public void handleBeforeUpdate(Map<Id, InsurancePolicy> previousPolicies, Map<Id, InsurancePolicy> currentPolicies, Boolean resend) {

        Integer startingCpuTime = Limits.getCpuTime();

        List<InsurancePolicy> toDeleteShare = new List<InsurancePolicy> ();
        List<InsurancePolicy> toInsertShare = new List<InsurancePolicy> ();
        
        // Loop through the newly updated and previous InsurancePolicies
        for (Id policyId : currentPolicies.keySet()) {
            Id previousAccountId = previousPolicies.get(policyId).NameInsuredId;
            Id currentAccountId = currentPolicies.get(policyId).NameInsuredId;

            // If any of them have changed the primary insured, then we need to delete the old
            // InsurancePolicyShare and add a new one for the new account
            if (previousAccountId != currentAccountId || resend) {
                toDeleteShare.add(previousPolicies.get(policyId));
                toInsertShare.add(currentPolicies.get(policyId));
            }
        }

        // Both lists will always be the same size, so just check one
        if (toDeleteShare.size() > 0) {
            handleBeforeUpdateDelete(toDeleteShare);
            handleAfterInsert(toInsertShare);
        }

        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' Updating [' + toInsertShare.size() + 
        '] Insurance Policy Shares took ['+ (Limits.getCpuTime() - startingCpuTime) + '] of CPU Time');

    }

    private void handleBeforeUpdateDelete(List<InsurancePolicy> policiesToBeDeleted) {

        List<PolicyMember> allPolicyMembers = new List<PolicyMember>();
        List<PolicyMember> membersToRemoveSharesFor = new List<PolicyMember>();
        List<Id> insurancePolicyIds = new List<Id>();
        List<Id> allAccountIdsForDeletion = new List<Id>();
        Map<Id, Set<Id>> accountIdsToAgentIds = new Map<Id, Set<Id>>();

        for (InsurancePolicy policy : policiesToBeDeleted) {
            insurancePolicyIds.add(policy.Id);
        }

        List<InsurancePolicyParticipant> allParticipants = getAllParticipants(insurancePolicyIds);

        List<Id> accountsNotBeingDeleted = new List<Id>();

        for (InsurancePolicyParticipant participant : allParticipants) {
            accountsNotBeingDeleted.add(participant.PrimaryParticipantAccountId);
            accountIdsToAgentIds.put(participant.PrimaryParticipantAccountId, new Set<Id>());
            allPolicyMembers.add(new PolicyMember(participant));
        }

        for (InsurancePolicy policy : policiesToBeDeleted) {
            boolean shouldDeletePolicyShare = true;
            for (InsurancePolicyParticipant participant : allParticipants) {
                if (policy.NameInsuredId == participant.PrimaryParticipantAccountId && policy.Id == participant.InsurancePolicyId) {
                    shouldDeletePolicyShare = false;
                    break;
                }
            }

            if (shouldDeletePolicyShare) {
                membersToRemoveSharesFor.add(new PolicyMember(policy));
                allAccountIdsForDeletion.add(policy.NameInsuredId);
                accountIdsToAgentIds.put(policy.NameInsuredId, new Set<Id>());
                allPolicyMembers.add(new PolicyMember(policy));
            }
        }

        if (membersToRemoveSharesFor.size() > 0) {
            PolicyMembersAll policyMembersAll = new PolicyMembersAll(allPolicyMembers, accountIdsToAgentIds);
            PolicyMembersToDelete toDelete = new PolicyMembersToDelete(membersToRemoveSharesFor, allAccountIdsForDeletion);
            PolicyMembersData policyMembersData = new PolicyMembersData(policyMembersAll, toDelete, accountsNotBeingDeleted);
        
            deleteShares(policyMembersData);
        }

    }
/**
 * @description handleAfterUpdate
 * @param previousPolicies 
 * @param currentPolicies 
 */
    public void handleAfterUpdate(Map<Id, InsurancePolicy> previousPolicies, Map<Id, InsurancePolicy> currentPolicies) {
        BillingIPTriggerHandler billingIPTriggerHandler = new BillingIPTriggerHandler();
        billingIPTriggerHandler.updateBillingSharesForUpdatedPolicies(previousPolicies, currentPolicies);
    }
/**
 * @description handleBeforeDelete 
 * @param policiesToBeDeleted 
 */
    public void handleBeforeDelete(List<InsurancePolicy> policiesToBeDeleted) {

        Integer startingCpuTime = Limits.getCpuTime();
    
        Set<Id> insurancePolicyIds = new Set<Id>();
        for (InsurancePolicy policy : policiesToBeDeleted) {
            insurancePolicyIds.add(policy.Id);
        }

        UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(insurancePolicyIds);

        BillingIPTriggerHandler billingIPTriggerHandler = new BillingIPTriggerHandler();
        billingIPTriggerHandler.updateBillingSharesForDeletedPolicies(insurancePolicyIds);

        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' Deleting  shares for [' + insurancePolicyIds.size() + 
        '] Insurance policies took ['+ (Limits.getCpuTime() - startingCpuTime) + '] of CPU Time');
    }

    private List<InsurancePolicyParticipant> getAllParticipants(List<Id> insurancePolicyIds) {
        String methodName = 'handleBeforeUpdateDelete';
        List<InsurancePolicyParticipant> allParticipants = new List<InsurancePolicyParticipant>();
        try {
            // Now we need to get a list of every participant on each policy
            allParticipants = [
                SELECT Id, PrimaryParticipantAccountId, InsurancePolicyId 
                FROM InsurancePolicyParticipant 
                WHERE InsurancePolicyId 
                IN :insurancePolicyIds
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        return allParticipants;
    }
}