/**
 * @description UTIL GroupId
 */
public with sharing class UTIL_GroupId {

    /**
     * @description Get Customer Group Details
     * @param recordId
     * @return Id
     */
    @AuraEnabled(cacheable=true)
    public static Id getCustomerGroupDetails(Id recordId) {
        String servicingAgentExternalId = UTIL_CurrentUser.retrieveServicingAgent().Servicing_Agent_External_ID__c;
        List<CustomerGroupMember__c> customerGroupMembers;
        customerGroupMembers = Security.stripInaccessible(
                                                  AccessType.READABLE,
                                                  [SELECT Id, Group__r.Agent__c, Group__c, Customer__r.FirstName, Customer__r.LastName
                                                   FROM CustomerGroupMember__c
                                                   WHERE  Group__r.Agent__r.UserExternalID__c =:servicingAgentExternalId AND Customer__c =:recordId
                                                   LIMIT 1])
                                                  .getRecords();

        Id customerGroup;

        if (!customerGroupMembers.isEmpty()){
            customerGroup =  customerGroupMembers.get(0).Group__c;
        }
        return customerGroup;
    }
}