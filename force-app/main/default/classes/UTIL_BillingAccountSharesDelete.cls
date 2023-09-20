/**
 * @description This class will house various methods used for deleting Billing Account Shares to the Database. 
 * @Date: 10/25/21
 * @author: Stephen White YCDB, Jonathan Larkin VAASTT
 */
public without sharing class UTIL_BillingAccountSharesDelete extends UTIL_AgencyShares {

    private static final String CLASSNAME = 'UTIL_BillingAccountSharesDelete';
    private static final String MANUAL_ROW_CAUSE = 'Manual';
    private static UTIL_BillingAccountSharesDeleteWrapper utilWrap = new UTIL_BillingAccountSharesDeleteWrapper();

    @TestVisible
    private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
    private UTIL_BillingAccountSharesDelete(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info(CLASSNAME, 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
/**
 * @description deleteBillingAccountShares
 * @param agentRoleData 
 */
    public static void deleteBillingAccountShares(AgentRoleData agentRoleData){

        Integer startingCpuTime = Limits.getCpuTime();

        // For each agent role that will be deleted get all the customer accounts, billing accounts (<AccountId, Set<BillingAccountId>>)
        Map<Id, Set<Id>> customerAccountToBillingAccountIdMap = obtainCustomerAccountToBillingAccountMapForAccountIds(agentRoleData.agentRolesToAccountIds.values());

        // Get a set of all billing account Ids that are associated with the accounts in the list of agent roles being deleted.
        Set<Id> billingAccountIdsForAllAccounts = getFlatSetFromMap(customerAccountToBillingAccountIdMap);

        /* Find all customer accounts for each billing account in our set, as not all their accounts are represented in our list of Agent Roles, 
           and we need them to prevent removal of shares that are still in use.
        */
        Map<Id, Set<id>> billingAccountToCustomerIdsMap = new Map<Id, Set<Id>>();
        Set<Id> customerAccountIdsForAllBillingAccounts = getCustomerAccountIdsForAllBillingAccounts(billingAccountIdsForAllAccounts, billingAccountToCustomerIdsMap);

        updateMapWithInsurancePolicyData(billingAccountToCustomerIdsMap, billingAccountIdsForAllAccounts, customerAccountIdsForAllBillingAccounts);

        // Get All Agents for Accounts retrieved via the Billing Account Id's
        Map<Id, Set<Id>> customerAccountIdToAgentIdsMap = getAllAgentsForCustomerAccounts(customerAccountIdsForAllBillingAccounts);

        // Create a map to quickly lookup existing shares. we will manually create a unique key by combining Account ID &  Agent ID as a String.
        Map<String, Billing_Account__Share> uniqueBillingSharesMap = constructUniqueBillingSharesMapFromIdSet(billingAccountIdsForAllAccounts);

        UTIL_BillingAccountSharesDeleteData billingAccountShareData = new UTIL_BillingAccountSharesDeleteData()
            .setCustomerAccountToBillingAccountIdMap(customerAccountToBillingAccountIdMap)
            .setBillingAccountToCustomerIdsMap(billingAccountToCustomerIdsMap)
            .setCustomerAccountIdToAgentIdsMap(customerAccountIdToAgentIdsMap)
            .setUniqueBillingSharesMap(uniqueBillingSharesMap)
            .setAgentRoleData(agentRoleData);

        Set<Billing_Account__Share> billingAccountSharesToDelete = obtainSetOfBillingAccountSharesToDelete(billingAccountShareData);

        List<Database.DeleteResult> deleteResults = performBillingAccountSharesDelete(billingAccountSharesToDelete);
    
        System.debug(LoggingLevel.DEBUG, CLASSNAME + ' Deleting [' + deleteResults.size() +
            '] Billing Account Shares took ['+ (Limits.getCpuTime() - startingCpuTime) + '] of CPU Time');

    }

    
    /**
     * @description - Given a list of Account Ids, construct a Map of customer accountIds to Billing Account Ids
     * @param accountIds 
     * @return  `Map<Id, Set<Id>>`
     */
    private static Map<Id, Set<Id>> obtainCustomerAccountToBillingAccountMapForAccountIds(List<Id> accountIds) {
        Map<Id, Set<Id>> customerAccountToBillingAccountIdMap = new Map<Id, Set<Id>>();
        UTIL_BillingAccountShares.getBillingAccountsFromBillingParticipants(accountIds, customerAccountToBillingAccountIdMap);
        getBillingAccountsFromInsurancePolicy(accountIds, customerAccountToBillingAccountIdMap);
        return customerAccountToBillingAccountIdMap;
    }

    /**
     * @description - Given a list of Account Ids, construct a Map to find billing accounts via Insurance Policy (Primary Insured/Participants).
     * @param accountIds 
     * @param customerAccountToBillingAccountIdsMap 
     */
    @TestVisible
    private static void getBillingAccountsFromInsurancePolicy(List<Id> accountIds, Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap) {
        // For All Accounts in agent roles find billing accounts via Insurance Policy (Primary Insured/Participants)
        for(Billing_Policy__c billingPolicy : 
            (List<Billing_Policy__c>)Security.stripInaccessible(AccessType.READABLE,[SELECT InsurancePolicyId__r.NameInsuredId, BillingAccountID__c FROM Billing_Policy__c 
             WHERE  InsurancePolicyId__c IN (SELECT Id FROM InsurancePolicy WHERE NameInsuredID IN :accountIds)]).getRecords()){

            // Add Billing Accounts to customerAccountToBillingAccountIdsMap. 
            // If No entries exist for the customer, create a new one. 
            // If an Entry does exist add it to the existing set.
            utilWrap.getBillingAccountsFromInsurancePolicy(billingPolicy, customerAccountToBillingAccountIdsMap);
        }
    }

    /**
     *  @description - Given a flat set of Billing Account Ids associated with Customer Accounts we have located so far, and a map of Billing 
     *  Account Ids & Customer Ids, construct a flat set of Billing Account Ids associated with all related Customer Accounts.
     * @param billingAccountIdsForAllAccounts 
     * @param billingAccountToCustomerIdsMap 
     * @return  `Set<Id>`
     */
    @TestVisible
    private static Set<Id> getCustomerAccountIdsForAllBillingAccounts(Set<Id> billingAccountIdsForAllAccounts, Map<Id, Set<id>> billingAccountToCustomerIdsMap) {
        List<Billing_Participant__c> participantObjects = 
            (List<Billing_Participant__c>)Security.stripInaccessible(AccessType.READABLE,[SELECT BillingAccountID__c, ParticipantAccountId__c FROM Billing_Participant__c WHERE BillingAccountID__c IN :billingAccountIdsForAllAccounts]).getRecords();
        
        for (Billing_Participant__c participant : participantObjects) {
            if (billingAccountToCustomerIdsMap.containsKey(participant.BillingAccountID__c)) {
                billingAccountToCustomerIdsMap.get(participant.BillingAccountID__c).add(participant.ParticipantAccountId__c);
            } else {
                billingAccountToCustomerIdsMap.put(participant.BillingAccountID__c, new Set<Id>{participant.ParticipantAccountId__c});
            }
        }
                
        return getFlatSetFromMap(billingAccountToCustomerIdsMap);
    } 

    /**
     * @description - Given a set of all billingAccountIds associated with all found customer accounts,
     * query to locate all billing account Ids through Insurance Policy & Insurance Policy Participant.
     * Update the billingAccountToCustomerIdsMap and customerAccountIdsForAllBillingAccounts data structures
     * with this information.    
     * @param billingAccountToCustomerIdsMap 
     * @param billingAccountIdsForAllAccounts 
     * @param customerAccountIdsForAllBillingAccounts 
     */
    @TestVisible
    private static void updateMapWithInsurancePolicyData(Map<Id, Set<id>> billingAccountToCustomerIdsMap, Set<Id> billingAccountIdsForAllAccounts, Set<Id> customerAccountIdsForAllBillingAccounts) {
        updateMapThroughInsurancePolicyAssociation(billingAccountToCustomerIdsMap, billingAccountIdsForAllAccounts, customerAccountIdsForAllBillingAccounts);
        updateMapThroughInsurancePolicyParticipantAssociation(billingAccountToCustomerIdsMap, billingAccountIdsForAllAccounts, customerAccountIdsForAllBillingAccounts);
    }

    /**
     * @description - Query to obtain all customerAccountIdsFromInsurancePolicy and update the 
     * billingAccountToCustomerIdsMap, as well as the customerAccountIdsForAllBillingAccounts set with 
     * the information found.
     * @param billingAccountToCustomerIdsMap 
     * @param billingAccountIdsForAllAccounts 
     * @param customerAccountIdsForAllBillingAccounts 
     */
    @TestVisible
    private static void updateMapThroughInsurancePolicyAssociation(Map<Id, Set<id>> billingAccountToCustomerIdsMap, Set<Id> billingAccountIdsForAllAccounts, Set<Id> customerAccountIdsForAllBillingAccounts) {
        Set<Id> customerAccountIdsFromInsurancePolicy = getCustomerAccountIdsSetFromInsurancePolicy(billingAccountIdsForAllAccounts);

        // use the new customer ID set to link it back to the billing account Ids
        updateMapThroughAssociationQuery(customerAccountIdsFromInsurancePolicy, billingAccountToCustomerIdsMap, customerAccountIdsForAllBillingAccounts);
    }

    /**
     * @description - Given a set of billingAccountIdsForAllAccounts, query InsurancePolicyId__r.NameInsuredId FROM Billing_Policy__c
     * to locate all customer Account IDs.
     * @param billingAccountIdsForAllAccounts 
     * @return  `Set<Id>`
     */
    @TestVisible
    private static Set<Id> getCustomerAccountIdsSetFromInsurancePolicy(Set<Id> billingAccountIdsForAllAccounts) {
        Set<Id> customerAccountIdsFromInsurancePolicy = new Set<Id>();

        // place all of the customer account IDs in a set
        for(Billing_Policy__c billingPolicy : (List<Billing_Policy__c>)Security.stripInaccessible(AccessType.READABLE,[SELECT InsurancePolicyId__r.NameInsuredId FROM Billing_Policy__c WHERE InsurancePolicyId__r.NameInsuredId != NULL AND BillingAccountID__c IN :billingAccountIdsForAllAccounts]).getRecords()) {
            customerAccountIdsFromInsurancePolicy.add(billingPolicy.InsurancePolicyId__r.NameInsuredId);
        }

        return customerAccountIdsFromInsurancePolicy;
    }

    /**
     * @description - Query to obtain all customerAccountIdsFromInsurancePolicyParticipants and update the 
     * billingAccountToCustomerIdsMap, as well as the customerAccountIdsForAllBillingAccounts set with 
     * the information found.
     * @param billingAccountToCustomerIdsMap 
     * @param billingAccountIdsForAllAccounts 
     * @param customerAccountIdsForAllBillingAccounts 
     */
    @TestVisible
    private static void updateMapThroughInsurancePolicyParticipantAssociation(Map<Id, Set<id>> billingAccountToCustomerIdsMap, Set<Id> billingAccountIdsForAllAccounts, Set<Id> customerAccountIdsForAllBillingAccounts) {
        
        Set<Id> customerAccountIdsFromInsurancePolicyParticipants = getCustomerAccountIdsSetFromInsurancePolicyParticipant(billingAccountIdsForAllAccounts);

        // use the new customer ID set to link it back to the billing account Ids

        updateMapThroughAssociationQuery(customerAccountIdsFromInsurancePolicyParticipants, billingAccountToCustomerIdsMap, customerAccountIdsForAllBillingAccounts);
        }
    

    /**
     * @description - queries BillingAccountIDs and ParticipantAccountIds in the list of customer account ids provided in arg and adds participantIds to map
     * @param customerAccountIds
     * @param billingAccountToCustomerIdsMap 
     * @param customerAccountIdsForAllBillingAccounts 
     */
    @TestVisible
    private static void updateMapThroughAssociationQuery(Set<Id> customerAccountIds, Map<Id, Set<id>> billingAccountToCustomerIdsMap, Set<Id> customerAccountIdsForAllBillingAccounts) {
    for (Billing_Participant__c billingParticipant : (List<Billing_Participant__c>)Security.stripInaccessible(AccessType.READABLE,[SELECT BillingAccountID__c, ParticipantAccountId__c FROM Billing_Participant__c WHERE ParticipantAccountId__c IN :customerAccountIds]).getRecords()) {
        utilWrap.updateMapThroughAssociationQuery(billingParticipant, billingAccountToCustomerIdsMap);
        customerAccountIdsForAllBillingAccounts.add(billingParticipant.ParticipantAccountId__c);   
    }
    
    }
    /**
     * @description - Given a set of billingAccountIdsForAllAccounts, query PrimaryParticipantAccountId FROM InsurancePolicyParticipant
     * to locate all customer Account IDs.
     * @param billingAccountIdsForAllAccounts 
     * @return  `Set<Id>`
     */
    @TestVisible
    private static Set<Id> getCustomerAccountIdsSetFromInsurancePolicyParticipant(Set<Id> billingAccountIdsForAllAccounts) {
        Set<Id> customerAccountIdsFromInsurancePolicyParticipants = new Set<Id>();

        // place all of the customer account IDs in a set
        for(InsurancePolicyParticipant insurancePolicyParticipant : (List<InsurancePolicyParticipant>)Security.stripInaccessible(AccessType.READABLE,[SELECT PrimaryParticipantAccountId FROM InsurancePolicyParticipant WHERE InsurancePolicyId IN (SELECT InsurancePolicyId__c FROM Billing_Policy__c WHERE BillingAccountID__c IN :billingAccountIdsForAllAccounts)]).getRecords()) {
            customerAccountIdsFromInsurancePolicyParticipants.add(insurancePolicyParticipant.PrimaryParticipantAccountId);
        }

        return customerAccountIdsFromInsurancePolicyParticipants;
    }


    /**
     *  @description - Get all Agent Roles for the provided list of accounts and construct a map of Customer Account Ids & Agent (User) Ids.
     * @param accountIds 
     * @return  `Map<Id, Set<Id>>`
     */
    @TestVisible
    private static Map<Id, Set<Id>> getAllAgentsForCustomerAccounts(Set<Id> accountIds){

        Map<Id, Set<Id>> billingAccountIdToAgentIdsMap = new Map<Id, Set<Id>>();

        for(AgentRole__c agentRole: 
            (List<AgentRole__c>)Security.stripInaccessible(AccessType.READABLE,[SELECT Agent__c, Customer__c  FROM AgentRole__c WHERE Customer__c IN :accountIds]).getRecords()){
            billingAccountIdToAgentIdsMap = utilWrap.getAllAgentsForCustomerAccounts(billingAccountIdToAgentIdsMap, agentRole);
        }

        return billingAccountIdToAgentIdsMap;
    }

    /**
     * @description - Given a flat set of Billing Account Ids, construct a Map to quickly locate existing Billing Account Shares.
     * @param billingAccountIdsForAllAccounts 
     * @return  `Map<String, Billing_Account__Share>`
     */
    @TestVisible
    private static Map<String, Billing_Account__Share> constructUniqueBillingSharesMapFromIdSet(Set<Id> billingAccountIdsForAllAccounts) {
        Map<String, Billing_Account__Share> uniqueBillingSharesMap = new Map<String, Billing_Account__Share>();
        for( Billing_Account__Share existingBillingShare : (List<Billing_Account__Share>)Security.stripInaccessible(AccessType.READABLE,[SELECT ParentId, UserOrGroupId FROM Billing_Account__Share WHERE ParentId IN :billingAccountIdsForAllAccounts AND RowCause = :MANUAL_ROW_CAUSE]).getRecords()) {
            uniqueBillingSharesMap.put(constructUniqueKeyForBillingShareMap(existingBillingShare.ParentId, existingBillingShare.UserOrGroupId), existingBillingShare);
        }
        return uniqueBillingSharesMap;
    }

    /**
     * @description - Given an existingBillingAccountShare, form a unique key by concatening BillingAccountID (ParentID) & AgentId (UserOrGroupId)
     * @param accountId 
     * @param agentId 
     * @return  `String`
     */
    private static String constructUniqueKeyForBillingShareMap(Id accountId, Id agentId) {
        return (String)accountId + (string)agentId;
    }

    /**
     * @description - Given a map of Id and Set<Id>, flatten & combine each subset of Ids into a single set of Ids
     * @param mapContainingSets 
     * @return  `Set<Id>`
     */
    @TestVisible
    private static Set<Id> getFlatSetFromMap(Map<Id, Set<Id>> mapContainingSets) {
        Set<Id> flattenedSet = new Set<Id>();
        flattenedSet = utilWrap.getFlatSetFromMap(mapContainingSets, flattenedSet);
        return flattenedSet;
    }


    /**
     * @description - Now that we've gathered all the data we need to begin the process of the actual delete, 
     *                we want to start at the agent role level. We'll loop through each Agent Role and determine what needs to be deleted. 
     * @param billingAccountShareData 
     * @return  `Set<Billing_Account__Share>`
     */
    private static Set<Billing_Account__Share> obtainSetOfBillingAccountSharesToDelete(UTIL_BillingAccountSharesDeleteData billingAccountShareData) {
        Set<Billing_Account__Share> billingAccountSharesToDelete = new Set<Billing_Account__Share>();
    
        for(AgentRole__c agentRole: billingAccountShareData.agentRoleData.agentRoles){
            billingAccountSharesToDelete.addAll(obtainSubsetOfBillingAccountSharesToDelete(billingAccountShareData, agentRole));
        }

        return billingAccountSharesToDelete;
    }

    /**
     * @description - Iterate through Billing Account Ids belonging to each customer, and determine which billing account share is deletable
     * @param billingAccountShareData 
     * @param agentRole 
     * @return  `Set<Billing_Account__Share>`
     */
    private static Set<Billing_Account__Share> obtainSubsetOfBillingAccountSharesToDelete(UTIL_BillingAccountSharesDeleteData billingAccountShareData, AgentRole__c agentRole) {
        
        Set<Billing_Account__Share> billingAccountSharesToDelete = new Set<Billing_Account__Share>();

        for(Id billingAccountId: billingAccountShareData.getBillingAccountIdSetForAgentRoleCustomer(agentRole)) {
            UTIL_BillingAccountShareDeleteHelper deleteHelper = new UTIL_BillingAccountShareDeleteHelper()
                .setBillingAccountId(billingAccountId).setAgentRole(agentRole).setBillingAccountShareData(billingAccountShareData);

            boolean deleteShare = isBillingAccountShareDeletable(deleteHelper);

            if(deleteShare) {
                billingAccountSharesToDelete.add(billingAccountShareData.uniqueBillingSharesMap.get(constructUniqueKeyForBillingShareMap(billingAccountId, 
                    billingAccountShareData.agentRoleData.agentToProxyIds.get(agentRole.Agent__c))));
            }
        }
        return billingAccountSharesToDelete;
    }

    /**
     * @description - Perform various checks to determine if a given Billing Account Share should be deleted, and return a boolean indicating this choice.
     * @param deleteHelper 
     * @return  `boolean`
     */
    @TestVisible
    private static boolean isBillingAccountShareDeletable(UTIL_BillingAccountShareDeleteHelper deleteHelper) {
        boolean deleteShare = true;
        if(isCustomerAccountIdSetOfValidSize(deleteHelper)) {

            for(Id customerAccountId: deleteHelper.customerAccountIdsForAllBillingAccounts){

                Set<Id> agentIds = deleteHelper.getAgentIdSetFromCustomerAccountId(customerAccountId);
                
                if(isAgentIdSetEmpty(agentIds) || deleteHelper.isCustomerIdTheSameAsCustomerIdFromAgentRole(customerAccountId)){
                    continue; 
                }
                
                /*
                    We CANNOT delete the Billing Account Share associated with this Agent Id, if the following criteria is met:
                        1. The set of Agent Ids associated with the Billing Account Id in question contains the Id (Agent__c) of the Agent Role in question.
                        2. The customer account Id in question is not present in the original list of Agent Roles passed in by the Trigger. 
                */
                IsBillingAccountShareDeletableWrapper isWrap = new isBillingAccountShareDeletableWrapper();
                isWrap.agentIds = agentIds;
                isWrap.customerAccountId = customerAccountId;
                deleteShare = utilWrap.isBillingAccountShareDeletable(deleteHelper, deleteShare, isWrap);
            }                        
        }
        return deleteShare;
    }

    /**
     * @description - return a boolean indicating if the customerAccountIdsForAllBillingAccounts object is valid (not null and size > 1)
     * @param deleteHelper 
     * @return  `Boolean`
     */
    private static Boolean isCustomerAccountIdSetOfValidSize(UTIL_BillingAccountShareDeleteHelper deleteHelper) {
        if (deleteHelper.customerAccountIdsForAllBillingAccounts == null) {
            return false;
        }

        return deleteHelper.customerAccountIdsForAllBillingAccounts.size() > 1;
    }

    /**
     * @description - return a boolean indicating if the passed in agentId set contains no valid values
     * @param agentIds 
     * @return  `Boolean`
     */
    private static Boolean isAgentIdSetEmpty(Set<Id> agentIds) {
        return agentIds == null || agentIds.isEmpty();
    }

    /**
     * @description - Given a set of Billing Account Shares, convert the set to a list, perform a database delete on that list, returning the result.
     * @param billingAccountSharesToDelete 
     * @return  `List<Database.DeleteResult>`
     */
    @TestVisible
    public static List<Database.DeleteResult> performBillingAccountSharesDelete(Set<Billing_Account__Share> billingAccountSharesToDelete) {
        if(billingAccountSharesToDelete != null){
            List<Billing_Account__Share> billingAccountSharesToDeleteList = getBillingAccountSharesToDeleteListFromSet(billingAccountSharesToDelete);
            List<Database.DeleteResult> deleteResults = Database.delete(Security.stripInaccessible(AccessType.UPDATABLE, billingAccountSharesToDeleteList, true).getRecords(), false);
            LoggingService.logDatabaseResult(deleteResults, billingAccountSharesToDeleteList, CLASSNAME, 'deleteBillingAccountShares', System.LoggingLevel.ERROR);
            return deleteResults;
        }
        return new List<Database.DeleteResult>();
    }

    /**
     * @description - Given a set of Billing Shares, remove all null elements and return a List resembling the valid billing shares.
     * @param billingAccountSharesToDelete 
     * @return  `List<Billing_Account__Share>`
     */
    private static List<Billing_Account__Share> getBillingAccountSharesToDeleteListFromSet(Set<Billing_Account__Share> billingAccountSharesToDelete) {
        billingAccountSharesToDelete.remove(null);
        return new List<Billing_Account__Share>(billingAccountSharesToDelete);
    }

    private class IsBillingAccountShareDeletableWrapper{
        Set<Id> agentIds;
        Id customerAccountId;
    }

    private class UTIL_BillingAccountSharesDeleteWrapper{
        private void getBillingAccountsFromInsurancePolicy(Billing_Policy__c billingPolicy, Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap) {
                // Add Billing Accounts to customerAccountToBillingAccountIdsMap. 
                // If No entries exist for the customer, create a new one. 
                // If an Entry does exist add it to the existing set.
                if(customerAccountToBillingAccountIdsMap.containsKey(billingPolicy.InsurancePolicyId__r.NameInsuredId)){
                    customerAccountToBillingAccountIdsMap.get(billingPolicy.InsurancePolicyId__r.NameInsuredId).add(billingPolicy.BillingAccountID__c);
                } else {
                    customerAccountToBillingAccountIdsMap.put(billingPolicy.InsurancePolicyId__r.NameInsuredId, new Set<Id>{billingPolicy.BillingAccountID__c});
                }
            }

        private Set<Id> getFlatSetFromMap(Map<Id, Set<Id>> mapContainingSets, Set<Id> flattenedSet) {
            for(Set<Id> subSet: mapContainingSets.values()){
                flattenedSet.addAll(subSet);
            }
            return flattenedSet;
        }

        private boolean isBillingAccountShareDeletable(UTIL_BillingAccountShareDeleteHelper deleteHelper, boolean deleteShare, IsBillingAccountShareDeletableWrapper isBillingWrap) {
            boolean accountDeleteShares = deleteShare;
            if( deleteHelper.isAgentFromAgentRoleInAgentIdsSet(isBillingWrap.agentIds) && !deleteHelper.isCustomerIdPresentInIdSetFromAgentRole(isBillingWrap.customerAccountId)){
                accountDeleteShares = false;
        }
            return accountDeleteShares;
        }

        private Map<Id, Set<Id>> getAllAgentsForCustomerAccounts(Map<Id, Set<Id>> billingAccountIdToAgentIdsMap, AgentRole__c agentRole){
                if(billingAccountIdToAgentIdsMap.containsKey(agentRole.Customer__c)) {
                    billingAccountIdToAgentIdsMap.get(agentRole.Customer__c).add(agentRole.Agent__c);
                } else {
                    billingAccountIdToAgentIdsMap.put(agentRole.Customer__c, new Set<Id>{agentRole.Agent__c});
                }
            return billingAccountIdToAgentIdsMap;
        }

        private void updateMapThroughAssociationQuery(Billing_Participant__c billingParticipant, Map<Id, Set<id>> billingAccountToCustomerIdsMap) {
                if(billingAccountToCustomerIdsMap.containsKey(billingParticipant.BillingAccountID__c)) {
                    billingAccountToCustomerIdsMap.get(billingParticipant.BillingAccountID__c).add(billingParticipant.ParticipantAccountId__c);
                } else {
                    billingAccountToCustomerIdsMap.put(billingParticipant.BillingAccountID__c, new Set<Id>{billingParticipant.ParticipantAccountId__c});
                }
        }
    }
}