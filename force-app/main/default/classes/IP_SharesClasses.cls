/**
 * @description IP_SharesClasses
 */
public with sharing virtual class IP_SharesClasses {
/**
 * @description PolicyMember
 */
    public with sharing class PolicyMember {
        public Id policyId;
        public Id accountId;
/**
 * @description PolicyMember
 * @param policy 
 */
        public PolicyMember(InsurancePolicy policy) {
            policyId = policy.Id;
            accountId = policy.NameInsuredId;
        }
/**
 * @description PolicyMember
 * @param participant 
 */
        public PolicyMember(InsurancePolicyParticipant participant) {
            policyId = participant.InsurancePolicyId;
            accountId = participant.PrimaryParticipantAccountId;
        }
    }
/**
 * @description PolicyMembersData
 */
    public with sharing class PolicyMembersData {
        public PolicyMembersAll allMembers;
        public PolicyMembersToDelete toDelete;
        public List<Id> accountsNotToDelete;
/**
 * @description PolicyMembersData
 * @param allMembers 
 * @param toDelete 
 * @param accountsNotToDelete 
 */
        public PolicyMembersData(PolicyMembersAll allMembers, PolicyMembersToDelete toDelete, List<Id> accountsNotToDelete) {
            this.allMembers = allMembers;
            this.toDelete = toDelete;
            this.accountsNotToDelete = accountsNotToDelete;            
        }
    }
/**
 * @description PolicyMembersToDelete
 */
    public with sharing class PolicyMembersToDelete {
        public List<PolicyMember> members;
        public List<Id> accountIds;
/**
 * @description PolicyMembersToDelete
 * @param members 
 * @param accountIds 
 */
        public PolicyMembersToDelete(List<PolicyMember> members, List<Id> accountIds) {
            this.members = members;
            this.accountIds = accountIds;
        }
    }
/**
 * @description PolicyMembersAll
 */
    public with sharing class PolicyMembersAll {
        public List<PolicyMember> allPolicyMembers;
        public Map<Id, Set<Id>> accountIdsToListAgentIds;
/**
 * @description PolicyMembersAll
 * @param allPolicyMembers 
 * @param accountIdsToListAgentIds 
 */
        public PolicyMembersAll(List<PolicyMember> allPolicyMembers, Map<Id, Set<Id>> accountIdsToListAgentIds) {
            this.allPolicyMembers = allPolicyMembers;
            this.accountIdsToListAgentIds = accountIdsToListAgentIds;
        }
    }
/**
 * @description AccountData
 */
    public with sharing class AccountData {
        public Boolean thisAccountIsBeingDeleted;
        public PolicyMembersData policyMembersData;
/**
 * @description AccountData
 * @param thisAccountIsBeingDeleted 
 * @param policyMembersData 
 */
        public AccountData(Boolean thisAccountIsBeingDeleted, PolicyMembersData policyMembersData) {
            this.thisAccountIsBeingDeleted = thisAccountIsBeingDeleted;
            this.policyMembersData = policyMembersData;
        }
    }
/**
 * @description AgentData
 */
    public with sharing class AgentData {
        public Map<Id, Set<Id>> agentToAccount;
        public Set<Id> agentsToDelete;
        public AccountData accountData;
/**
 * @description AgentData
 * @param agentToAccount 
 * @param agentsToDelete 
 * @param accountData 
 */
        public AgentData(Map<Id, Set<Id>> agentToAccount, Set<Id> agentsToDelete, AccountData accountData) {
            this.agentToAccount = agentToAccount;
            this.agentsToDelete = agentsToDelete;
            this.accountData = accountData;
        }
    }
/**
 * @description AccountAndAgentData
 */
    public with sharing class AccountAndAgentData {
        public Map<Id, Set<Id>> accountIdToAgentIdList;
        public Set<Id> agents;
/**
 * @description AccountAndAgentData
 * @param accountIdToAgentIdList 
 * @param agents 
 */
        public AccountAndAgentData(Map<Id, Set<Id>> accountIdToAgentIdList, Set<Id> agents) {
            this.accountIdToAgentIdList = accountIdToAgentIdList;
            this.agents = agents;
        }
    }
}
