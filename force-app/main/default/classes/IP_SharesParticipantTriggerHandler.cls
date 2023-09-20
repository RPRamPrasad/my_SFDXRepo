/**
 * @name IP_SharesParticipantTriggerHandler
 * @author Team Kraken (kdcv)
 * @description Handles shares trigger logic for InsurancePolicyParticipant objects
 * @version 1.0
 * @dateCreated 11/06/2020
 */
public with sharing class IP_SharesParticipantTriggerHandler extends IP_SharesManager {
    private static final String CLASS_NAME = 'IP_SharesParticipantTriggerHandler';

    /**
     * @name handleAfterInsert
     * @description Performs initialization activities, such as inserting InsurancePolicy shares.
     * @param newParticipants
     */
    public void handleAfterInsert(List<InsurancePolicyParticipant> newParticipants) {

        // First we build the data structures we need to hold our data
        Map<Id, Set<Id>> accountIdToAgentIdList = new Map<Id, Set<Id>>();
        List<PolicyMember> policyMembers = new List<PolicyMember>();

        for (InsurancePolicyParticipant participant : newParticipants) {
            // The primary named insured doens't exist as a participant (IPP),
            // so in order to create a share for that account's agents,
            // we need to insert those account ids into accountIdToAgentIdList manually
            accountIdToAgentIdList.put(participant.PrimaryParticipantAccountId, new Set<Id>());

            policyMembers.add(new PolicyMember(participant));
        }

        List<InsurancePolicyShare> ipShares = buildShares(policyMembers, accountIdToAgentIdList);
        BillingIPParticipantTriggerHandler billingIPParticipantTriggerHandler = new BillingIPParticipantTriggerHandler();
        billingIPParticipantTriggerHandler.createBillingAccountSharesFromPolicyParticipants(ipShares);
   }

    /**
     * @name handleBeforeDelete
     * @description Performs clean-up activities, such as deleting InsurancePolicy shares.
     * @param participantsToBeDeleted
     */
    public void handleBeforeDelete(List<InsurancePolicyParticipant> participantsToBeDeleted) {

        List<Id> insurancePolicyIds = new List<Id>();
        List<Id> participantIdsToBeDeleted = new List<Id>();
        Map<Id, Set<Id>> accountIdsToAgentIds = new Map<Id, Set<Id>>();
        List<Id> accountsNotBeingDeleted = new List<Id>();

        for (InsurancePolicyParticipant participant : participantsToBeDeleted) {
            insurancePolicyIds.add(participant.InsurancePolicyId);
            participantIdsToBeDeleted.add(participant.Id);
        }

        // We also need to get all the other accounts on the policy
        List<PolicyMember> allPolicyMembers = getAllPolicyMembers(insurancePolicyIds, participantIdsToBeDeleted);

        for (PolicyMember otherMember : allPolicyMembers) {
            accountsNotBeingDeleted.add(otherMember.accountId);
            accountIdsToAgentIds.put(otherMember.accountId, new Set<Id>());
        }

        List<Id> allAccountIdsForDeletion = new List<Id>();
        List<PolicyMember> membersToRemoveSharesFor = new List<PolicyMember>();

        // Filter out the participants which are also the primary insured on the 
        // InsurancePolicy. This way we don't accidentally delete a share for the participant
        // when it needs to be kept.
        for (InsurancePolicyParticipant participant : participantsToBeDeleted) {
            boolean shouldBeConsideredForDelete = true;
            for (PolicyMember otherMember : allPolicyMembers) {
                if (participant.PrimaryParticipantAccountId == otherMember.accountId && participant.InsurancePolicyId == otherMember.policyId) {
                    shouldBeConsideredForDelete = false; 
                    break;
                }
            }

            if (shouldBeConsideredForDelete) {
                accountIdsToAgentIds.put(participant.PrimaryParticipantAccountId, new Set<Id>());
                allPolicyMembers.add(new PolicyMember(participant));
                membersToRemoveSharesFor.add(new PolicyMember(participant));
                allAccountIdsForDeletion.add(participant.PrimaryParticipantAccountId);
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
     * @name handleAfterDelete
     * @description Performs activities after the InsurancePolicyParticipant records have been deleted
     * @param participantsToBeDeleted
     */
    public void handleAfterDelete(List<InsurancePolicyParticipant> participantsToBeDeleted) {
        BillingIPParticipantTriggerHandler billingIPParticipantTriggerHandler = new BillingIPParticipantTriggerHandler();
        billingIPParticipantTriggerHandler.handleAfterDeleteInsurancePolicyParticipant(participantsToBeDeleted);
    }

    private List<PolicyMember> getAllPolicyMembers(List<Id> insurancePolicyIds, List<Id> participantIdsToBeDeleted) {
        List<InsurancePolicy> insurancePolicies = getPolicies(insurancePolicyIds);
        List<InsurancePolicyParticipant> allOtherParticipants = getOtherParticipants(insurancePolicyIds, participantIdsToBeDeleted);
        List<PolicyMember> members = new List<PolicyMember>();

        for (InsurancePolicy policy : insurancePolicies) {
            members.add(new PolicyMember(policy));
        }

        for (insurancePolicyParticipant participant : allOtherParticipants) {
            members.add(new PolicyMember(participant));
        }

        return members;
    }

    private List<InsurancePolicy> getPolicies(List<Id> insurancePolicyIds) {
        String methodName = 'getPolicies';
        List<InsurancePolicy> insurancePolicies = new List<InsurancePolicy>();
    
        try {
            insurancePolicies = [
                SELECT Id, NameInsuredId
                FROM InsurancePolicy 
                WHERE Id 
                IN :insurancePolicyIds
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        return insurancePolicies;
    }

    private List<InsurancePolicyParticipant> getOtherParticipants(List<Id> insurancePolicyIds, List<Id> participantIdsToBeDeleted) {
        String methodName = 'getOtherParticipants';
        List<InsurancePolicyParticipant> allOtherParticipants = new List<InsurancePolicyParticipant>();

        try {
            allOtherParticipants = [
                SELECT Id, PrimaryParticipantAccountId, InsurancePolicyId 
                FROM InsurancePolicyParticipant 
                WHERE InsurancePolicyId 
                IN :insurancePolicyIds
                AND Id NOT IN :participantIdsToBeDeleted
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        return allOtherParticipants;
    }
}
