/**
 * @name - UTIL_BillingAccountSharesDeleteData
 * @description - A class which is used to house multiple pieces of data in order to 
   reduce the complexity of passing multiple parameters in the UTIL_BillingAccountSharesDelete class.
 * @author Stephen White (YCDB)                
 */
public without sharing class UTIL_BillingAccountSharesDeleteData extends UTIL_AgencySharesModels {

    /**
     * @description - Stores the billing accounts for each customer account.
     */
    public Map<Id, Set<Id>> customerAccountToBillingAccountIdMap{ get; private set; }

    /**
     * @description - Stores account IDs by billing account.
     */
    public Map<Id, Set<Id>> billingAccountToCustomerIdsMap{ get; private set; }

    /**
     * @description - Stores agent IDs for each account ID.
     */
    public Map<Id, Set<Id>> customerAccountIdToAgentIdsMap{ get; private set; }

    /**
     * @description - Stores billing shares for an account/agent unique key.
     */
    public Map<String, Billing_Account__Share> uniqueBillingSharesMap{ get; private set; }

    /**
     * @description - Stores agent role information.
     */
    public AgentRoleData agentRoleData{ get; private set; }

    /**
     * @name - setCustomerAccountToBillingAccountIdMap
     * @param customerAccountToBillingAccountIdMap
     * @description - Use builder pattern to set the property and return this object
     * @return UTIL_BillingAccountSharesDeleteData
     */
    public UTIL_BillingAccountSharesDeleteData setCustomerAccountToBillingAccountIdMap(Map<Id, Set<Id>> customerAccountToBillingAccountIdMap) {
        this.customerAccountToBillingAccountIdMap = customerAccountToBillingAccountIdMap;
        return this;
    }

    /**
     * @name - setBillingAccountToCustomerIdsMap
     * @param billingAccountToCustomerIdsMap
     * @description - Use builder pattern to set the property and return this object
     * @return UTIL_BillingAccountSharesDeleteData
     */
    public UTIL_BillingAccountSharesDeleteData setBillingAccountToCustomerIdsMap(Map<Id, Set<Id>> billingAccountToCustomerIdsMap) {
        this.billingAccountToCustomerIdsMap = billingAccountToCustomerIdsMap;
        return this;
    }

    /**
     * @name - setCustomerAccountIdToAgentIdsMap
     * @param customerAccountIdToAgentIdsMap
     * @description - Use builder pattern to set the property and return this object
     * @return UTIL_BillingAccountSharesDeleteData
     */
    public UTIL_BillingAccountSharesDeleteData setCustomerAccountIdToAgentIdsMap(Map<Id, Set<Id>> customerAccountIdToAgentIdsMap) {
        this.customerAccountIdToAgentIdsMap = customerAccountIdToAgentIdsMap;
        return this;
    }


    /**
     * @name - setUniqueBillingSharesMap
     * @param uniqueBillingSharesMap
     * @description - Use builder pattern to set the property and return this object
     * @return UTIL_BillingAccountSharesDeleteData
     */
    public UTIL_BillingAccountSharesDeleteData setUniqueBillingSharesMap(Map<String, Billing_Account__Share> uniqueBillingSharesMap) {
        this.uniqueBillingSharesMap = uniqueBillingSharesMap;
        return this;
    }

    /**
     * @name - setAgentRoleData
     * @param agentRoleData
     * @description - Use builder pattern to set the property and return this object
     * @return UTIL_BillingAccountSharesDeleteData
     */
    public UTIL_BillingAccountSharesDeleteData setAgentRoleData(AgentRoleData agentRoleData) {
        this.agentRoleData = agentRoleData;
        return this;
    }

    /**
     * @name - getBillingAccountIdSetForAgentRoleCustomer
     * @param agentRole
     * @description - Retrieves the billing accounts for the account in the given agent role
     * @return Set<Id>
     */
    public Set<Id> getBillingAccountIdSetForAgentRoleCustomer(AgentRole__c agentRole) {
        Set<Id> billingAccountIdSet = this.customerAccountToBillingAccountIdMap.get(agentRole.Customer__c);
        return billingAccountIdSet == null ? new Set<Id>() : billingAccountIdSet;        
    }
}
