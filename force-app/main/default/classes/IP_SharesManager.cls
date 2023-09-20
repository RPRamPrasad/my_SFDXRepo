/**
 *@description IP_SharesManager
 */
public with sharing abstract class IP_SharesManager extends IP_SharesClasses {
    /**
     * @name buildShares
     * @description Generates and inserts the IP shares, returning the generated shares.
     * @param policyMembers List<PolicyMember> 
     * @param accountIdsToAgentIds Map<Id, Set<Id>> 
     * @return shares
     */
    public List<InsurancePolicyShare> buildShares(List<PolicyMember> policyMembers, Map<Id, Set<Id>> accountIdsToAgentIds) {
        AccountAndAgentData accountAndAgentData = populateAccountAndAgentData(accountIdsToAgentIds);
        
        Map<Id, Set<Id>> accountIdToAgentIdList = accountAndAgentData.accountIdToAgentIdList;
        Set<Id> allAgentIds = accountAndAgentData.agents;

        List<InsurancePolicyShare> shares = new List<InsurancePolicyShare>();

        Map<Id, Id> agentIdToProxyIds = UTIL_AgencyShares.getAgentProxyMap(allAgentIds);

        // We have to loop through the members one more time, so that we can
        // match the participant's agents to their corresponding insurance policy
        // since our InsurancePolicyShares are mapped from an InsurancePolicy to a 
        // an agent proxy (aka team members/agents tied to one id)        
        for (PolicyMember member : policyMembers) {
            Set<Id> agents = accountIdToAgentIdList.get(member.accountId);
            
            for (Id agentId : agents) {
                Id proxyId = agentIdToProxyIds.get(agentId);

                InsurancePolicyShare insurancePolicyShare = new InsurancePolicyShare();
                insurancePolicyShare.ParentId = member.policyId;
                insurancePolicyShare.UserOrGroupId = proxyId;
                insurancePolicyShare.AccessLevel = 'Read';
                insurancePolicyShare.RowCause = 'Manual';
                shares.add(insurancePolicyShare);
            }
        }

        // Finally, we call this util to insert all of our shares
        UTIL_InsurancePolicyShares.insertInsurancePolicyShares(shares);
        return shares;
    }
/**
 * @description deleteShares
 * @param policyMembersData 
 */
    public void deleteShares(PolicyMembersData policyMembersData) {

        AccountAndAgentData accountAndAgentData = populateAccountAndAgentData(policyMembersData.allMembers.accountIdsToListAgentIds);

        Map<Id, Map<Id, Set<Id>>> policyIdsToAccountAgents = new Map<Id, Map<Id, Set<Id>>>();
        Map<Id, Set<Id>> insurancePoliciesToAgentIdsToRemove = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> accountIdToAgentIdList = accountAndAgentData.accountIdToAgentIdList;
        Set<Id> allAgentIds = accountAndAgentData.agents;

        Map<Id, Id> allAgentProxyMap = UTIL_AgencyShares.getAgentProxyMap(allAgentIds); 

        // Now we need to loop through the policy members and put each participants
        // list of agents into the map of account to agents that is on the highest level map
        // containing the insurance policy as a key
        for (PolicyMember member : policyMembersData.allMembers.allPolicyMembers) {
            Set<Id> agentsForThisAccount = accountIdToAgentIdList.get(member.accountId);

            Map<Id, Set<Id>> accountsToAgents = policyIdsToAccountAgents.get(member.policyId);
            if (accountsToAgents == null) {
                accountsToAgents = new Map<Id, Set<Id>>();
            }
            
            accountsToAgents.put(member.accountId, agentsForThisAccount);

            policyIdsToAccountAgents.put(member.policyId, accountsToAgents);

            // Let's also build our mapping of all policies to their set of all account's agents
            Set<Id> uniqueSetOfAgents = insurancePoliciesToAgentIdsToRemove.get(member.policyId);
            if (uniqueSetOfAgents == null) {
                uniqueSetOfAgents = new Set<Id>();
            }
            uniqueSetOfAgents.addAll(agentsForThisAccount);
            insurancePoliciesToAgentIdsToRemove.put(member.policyId, uniqueSetOfAgents);
        }

        // We need these sets in order to query all of the 
        // InsurancePolicyShares objects. 
        Set<Id> insurancePolicyIds = new Set<Id>();
        Set<Id> agentProxyIds = new Set<Id>();

        // Our previous two sets will include more shares than we may actually
        // want to delete, so we will build a unique key to tie policy id and agent proxy
        // together in order to grab the correct shares while still having a performant 
        // query. Those unique keys (policyId + & + proxyId) will be stored in this list
        List<String> uniqueKeyPolicyIdAndAgentProxy = new List<String>();

        // Now let's do our final overview to determine which 
        // policy ids and agents need to be removed
        for (PolicyMember member : policyMembersData.toDelete.members) {
            Map<Id, Set<Id>> accountsToAgents = policyIdsToAccountAgents.get(member.policyId);
            insurancePolicyIds.add(member.policyId);

            // If the member to be removed is the only account on the policy
            // we can add their policy id and agents to be removed right away
            if (accountsToAgents.size() <= 1) {
                List<Id> proxyIds = getProxyIdsForAgentIds(allAgentProxyMap, accountsToAgents.get(member.accountId));

                uniqueKeyPolicyIdAndAgentProxy.addAll(insertPolicyIdAndAgentsToUniqueList(member.policyId, proxyIds));

                agentProxyIds.addAll(proxyIds);
            } else {
                Set<Id> agentIdsToDelete = removeDuplicateAgents(member.accountId, accountsToAgents, policyMembersData);

                if (agentIdsToDelete.size() >= 1) {
                    List<Id> proxyIds = getProxyIdsForAgentIds(allAgentProxyMap, agentIdsToDelete);

                    uniqueKeyPolicyIdAndAgentProxy.addAll(insertPolicyIdAndAgentsToUniqueList(member.policyId, proxyIds));

                    agentProxyIds.addAll(proxyIds);
                }
            }
        }

        processDeleteShares(insurancePolicyIds, uniqueKeyPolicyIdAndAgentProxy);
    }

    private void processDeleteShares(Set<Id> insurancePolicyIds, List<String> uniqueKeyPolicyIdAndAgentProxy) {
        // This share map overselects which shares we might want to delete
        Map<String, InsurancePolicyShare> shareMap = UTIL_InsurancePolicyShares.buildInsurancePolicyAndProxyToSharesMap(insurancePolicyIds);
        Set<InsurancePolicyShare> sharesToDelete = new Set<InsurancePolicyShare>();
    
        // Now we pull out the correct shares using our list of unique keys which we inserted
        // when determining which shares to remove
        for (String uniqueKey : uniqueKeyPolicyIdAndAgentProxy) {
            InsurancePolicyShare share = shareMap.get(uniqueKey);

            // if share is null, then it was already deleted by another process (probably agent role trigger)
            if (share != null) {
                sharesToDelete.add(share);
            }
        }

        List<InsurancePolicyShare> listFromSet = new List<InsurancePolicyShare>();
        listFromSet.addAll(sharesToDelete);
        UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(listFromSet);
    }

    private List<String> insertPolicyIdAndAgentsToUniqueList(Id policyId, List<Id> agentProxyIds) {
        List<String> uniqueListOfPolicyIdAndAgentProxy = new List<String>();
        for (Id agentProxy : agentProxyIds) {
            uniqueListOfPolicyIdAndAgentProxy.add(policyId + '&' + agentProxy);
        }

        return uniqueListOfPolicyIdAndAgentProxy;
    }

    private Set<Id> removeDuplicateAgents(Id accountToRemove, Map<Id, Set<Id>> accountsToAgents, PolicyMembersData policyMembersData) {
        // If we have more than one account on a policy, we need to compare their agents
        // and then be sure to only add the agents for accounts being removed
        Set<Id> allAgents = new Set<Id>();
        Set<Id> agentsToDelete = new Set<Id>();
        Map<Id, Set<Id>> agentToAccount = new Map<Id, Set<Id>>();

        for (Id accountId : accountsToAgents.keySet()) {
            Set<Id> agents = accountsToAgents.get(accountId);
            Boolean thisAccountIsBeingDeleted = false;
            
            if (accountId == accountToRemove) {
                thisAccountIsBeingDeleted = true;
            }

            for (Id agentId : agents) {
                AccountData accountData = new AccountData(thisAccountIsBeingDeleted, policyMembersData);
                AgentData agentData = new AgentData(agentToAccount, agentsToDelete, accountData);

                if (allAgents.contains(agentId)) {

                    processSeenAgent(agentId, agentData);
                } else {

                    allAgents.add(agentId);
                    processAgentForFirstTime(accountId, agentId, agentData);
                }
            }
        }

        return agentsToDelete;
    }

    private void processAgentForFirstTime(Id accountId, Id agentId, AgentData agentData) {
        Map<Id, Set<Id>> agentToAccount = agentData.agentToAccount;
        Set<Id> agentsToDelete = agentData.agentsToDelete;
        Boolean thisAccountIsBeingDeleted = agentData.accountData.thisAccountIsBeingDeleted;

        Set<Id> accounts = agentToAccount.get(agentId);
        if (accounts == null) {
            accounts = new Set<Id>();
        }
        accounts.add(accountId);
        agentToAccount.put(agentId, accounts);

        if (thisAccountIsBeingDeleted) {
            agentsToDelete.add(agentId);
        }
    }

    private void processSeenAgent(Id agentId, AgentData agentData) {
        Map<Id, Set<Id>> agentToAccount = agentData.agentToAccount;
        Set<Id> agentsToDelete = agentData.agentsToDelete;
        List<Id> accountIdsBeingDeleted = agentData.accountData.policyMembersData.toDelete.accountIds;
        Boolean thisAccountIsBeingDeleted = agentData.accountData.thisAccountIsBeingDeleted;

        Set<Id> accountsWhichInserted = agentToAccount.get(agentId);
        Boolean allAccountsWithThisAgentAreGoingToBeDeleted = true;
        
        for (Id accountWhichInsertedAgent : accountsWhichInserted) {
            if (!accountIdsBeingDeleted.contains(accountWhichInsertedAgent)) {
                allAccountsWithThisAgentAreGoingToBeDeleted = false;
                break;
            }
        }

        if (!agentsToDelete.contains(agentId) && thisAccountIsBeingDeleted && allAccountsWithThisAgentAreGoingToBeDeleted) {

            agentsToDelete.add(agentId);
        } else if (!thisAccountIsBeingDeleted) {

            agentsToDelete.remove(agentId);
        }
    }

    private List<Id> getProxyIdsForAgentIds(Map<Id, Id> agentIdToProxyId, Set<Id> agents) {
        List<Id> proxyIds = new List<Id>();

        for (Id agentId : agents) {
            Id proxyId = agentIdToProxyId.get(agentId);
            proxyIds.add(proxyId);
        }

        return proxyIds;
    }
/**
 * @description populateAccountAndAgentData
 * @param accountIdToAgentIdList 
 * @return  `AccountAndAgentData`
 */
    public AccountAndAgentData populateAccountAndAgentData(Map<Id, Set<Id>> accountIdToAgentIdList) {

        Set<Id> agentIds = new Set<Id>(); 

        // Get all of the AgentRole__c per account (aka get all the agents that each account has)
        List<AgentRole__c> participantsAgents = Security.stripInaccessible(AccessType.READABLE, 
        [
            SELECT Id, Agent__c, Customer__c 
            FROM AgentRole__c 
            WHERE Customer__c 
            IN :accountIdToAgentIdList.keySet()
        ]).getRecords();

        // Now that we have all the agents for each account, let's add them
        // to our map, so that we can get them efficiently when we build our final output
        for (AgentRole__c agentRole : participantsAgents) {
            Set<Id> agents = accountIdToAgentIdList.get(agentRole.Customer__c);
            agents.add(agentRole.Agent__c);
            accountIdToAgentIdList.put(agentRole.Customer__c, agents);

            agentIds.add(agentRole.Agent__c);
        }

        return new AccountAndAgentData(accountIdToAgentIdList, agentIds);
    }
}
