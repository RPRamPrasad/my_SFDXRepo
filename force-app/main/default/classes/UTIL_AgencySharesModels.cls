/**
 * @description This class will house various methods used for logic shared across different types of agency shares.
 * This class hold the wrapper class
 * @Date: 04/04/2021
 * @author: Stark
 * @owner Kraken
 */
public without sharing abstract class UTIL_AgencySharesModels {
    /**
     * @description This object will be used for passing formatted Agent Role Data.
    */
    public without sharing class AgentRoleData {
        /** @description list of all agent roles */
        public List<AgentRole__c> agentRoles { get; set; }
        /** @description map of agent role to agent */
        public Map<id,id> agentRolesToAgentIds { get; set; }
        /** @description map of agent role to account */
        public Map<id,id> agentRolesToAccountIds { get; set; }
        /** @description map of agent role to household*/
        public Map<id,id> agentRolesToHouseholdIds { get; set; }
        /** @description map of agent to proxy */
        public Map<Id,Id> agentToProxyIds { get; set; }
        /** @description map of agent to set of accounts */
        public Map<Id, Set<Id>> agentToAccountsAgentRoleMap { get; set; }
        /** @description map of household to set of agents */
        public Map<Id, Set<Id>> householdToAgentsAgentRoleMap { get; set; }
    }

    /**
     * @description This object will be used for passing formatted Agent Role Data.
     */
    public without sharing class DeleteShareLoopData {
        /** @description set of policies */
        public Set<Id> policyIds { get; set; }
        /** @description map of string key to sObject */
        public Map<String, sObject>  shareMap { get; set; }
        /** @description single agent role */
        public AgentRole__c agentRole { get; set; }
        /** @description all policy account information */
        public Map<id, Map<id, Set<Id>>> allPolicyAccountInformation { get; set; }
    }

    /**
     * @description This object will be used for passing formatted agent role data used in for deleting shares.
     */
    public without sharing class DeleteAgentRoleData {

        public Map<Id, Map<Id, Set<Id>>> allPolicyAccountInformation;
        public Map<Id, Set<Id>> agentToAccountsAgentRoleMap;
        public AgentRole__c agentRole;
        public Id policyId;
        
        /** 
         * @description constructor
         * @param agentToAccountsAgentRoleMap
         * @param agentRole
         * @param policyId 
         */
        public DeleteAgentRoleData(Map<Id,Set<Id>> agentToAccountsAgentRoleMap, AgentRole__c agentRole, Id policyId) {
            this.agentToAccountsAgentRoleMap = agentToAccountsAgentRoleMap;
            this.agentRole = agentRole;
            this.policyId = policyId;
        }
    }
}
