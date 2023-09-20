/**
 * @name - UTIL_BillingAccountShareDeleteHelper
 * @description - A class which is used to house multiple pieces of data 
 *                in order to reduce the complexity of passing multiple parameters 
 *                in the UTIL_BillingAccountSharesDelete class.
 * @author Stephen White (YCDB)                
 */
public without sharing class UTIL_BillingAccountShareDeleteHelper {
    
    /**
     * @description - the billing account ID
     */
    public Id billingAccountId { get; private set; }

    /**
     * @description - the agent role
     */
    public AgentRole__c agentRole { get; private set; }

    /**
     * @description - the 
     */
    public UTIL_BillingAccountSharesDeleteData billingAccountShareData { get; private set; }

    /**
     * @description - Stores the billing accounts for each customer account.
     */
    public Set<Id> customerAccountIdsForAllBillingAccounts { get; private set; }

    /**
     * @name - setBillingAccountId
     * @param billingAccountId
     * @description - Use builder pattern to set the property and return this object. 
     *                NOTE: THIS MUST BE SET FIRST IN ORDER TO PROPERLY SET UTIL_BillingAccountSharesDeleteData
     * @return UTIL_BillingAccountShareDeleteHelper
     * 
     */
    public UTIL_BillingAccountShareDeleteHelper setBillingAccountId(Id billingAccountId) {
        this.billingAccountId = billingAccountId;
        return this;
    }

    /**
     * @name - setAgentRole
     * @param agentRole
     * @description - Use builder pattern to set the property and return this object
     * @return UTIL_BillingAccountShareDeleteHelper
     */
    public UTIL_BillingAccountShareDeleteHelper setAgentRole(AgentRole__c agentRole) {
        this.agentRole = agentRole;
        return this;
    }

    /**
     * @name - setBillingAccountShareData
     * @param billingAccountShareData
     * @description - Use builder pattern to set the property and return this object
     * @return UTIL_BillingAccountShareDeleteHelper
     */
    public UTIL_BillingAccountShareDeleteHelper setBillingAccountShareData(UTIL_BillingAccountSharesDeleteData billingAccountShareData) {
        this.billingAccountShareData = billingAccountShareData;
        this.customerAccountIdsForAllBillingAccounts = billingAccountShareData.billingAccountToCustomerIdsMap.get(this.billingAccountId);
        return this;
    }

    /**
     * @name - getAgentIdSetFromCustomerAccountId
     * @param customerAccountId
     * @description - Given a Customer Account Id, return the Set of associated Agent Ids.
     * @return Set<Id>
     */
    public Set<Id> getAgentIdSetFromCustomerAccountId(Id customerAccountId) {
        return this.billingAccountShareData.customerAccountIdToAgentIdsMap.get(customerAccountId);
    }

    /**
     * @name - getCustomerFromAgentRole
     * @description - Return the Customer Id associated with the Agent Role Object
     * @return Id
     */
    public Id getCustomerFromAgentRole() {
        return this.agentRole.Customer__c;
    }

    /**
     * @name - getAgentFromAgentRole
     * @description - Return the Agent ID assoicated with the Agent Role Object
     * @return Id
     */
    public Id getAgentFromAgentRole() {
        return this.agentRole.Agent__c;
    }

    /**
     * @name - getCustomerAccountIdSetFromAgentRole
     * @description - Use the Agent Id from Agent Role to lookup and return the 
     *                Customer Account Set Associated with that Agent Id
     * @return Set<Id>
     */
    public Set<Id> getCustomerAccountIdSetFromAgentRole() {
        return this.billingAccountShareData.agentRoleData.agentToAccountsAgentRoleMap.get(this.getAgentFromAgentRole());
    }
    /**
     * @name - isCustomerIdTheSameAsCustomerIdFromAgentRole
     * @param customerAccountId
     * @description - return a boolean indicating if a customer account id in question matches that of the customer belonging to the agent role object
     * @return Boolean
     */
    public Boolean isCustomerIdTheSameAsCustomerIdFromAgentRole(Id customerAccountId) {
        return customerAccountId == this.getCustomerFromAgentRole();
    }

    /**
     * @name - isAgentFromAgentRoleInAgentIdsSet
     * @param agentIds
     * @description - Validate that a set of Agent Ids associated with a 
     *                given account contains the Agent Id provided by the Agent Role, returns a boolean result.
     * @return Boolean
     */
    public Boolean isAgentFromAgentRoleInAgentIdsSet(Set<Id> agentIds) {
        return agentIds.contains(this.getAgentFromAgentRole());
    }

    /**
     * @name - isCustomerIdPresentInIdSetFromAgentRole
     * @param customerAccountId
     * @description - Validate that a set of Account Ids associated with 
     *                the Agent Role which was passed in contains the account ID in question, and returns a boolean result.
     * @return Boolean
     */
    public Boolean isCustomerIdPresentInIdSetFromAgentRole(Id customerAccountId) {
        return this.getCustomerAccountIdSetFromAgentRole().contains(customerAccountId);
    }
}
