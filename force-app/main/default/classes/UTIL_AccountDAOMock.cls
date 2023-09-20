/**
@author Team STARK
@name UTIL_AccountDAOMock 
@createDate 07/08/20120
@description This is mock class for UTIL_AccountIDAO
@version 1.0
*/
@isTest(seeAllData=false)
public with sharing class UTIL_AccountDAOMock implements UTIL_AccountIDAO {
    private Integer fakeIdCounter = 0;
    public Map<String, Id> clntIdToAcctIdMap = new Map<String, Id>();
    public Map<String, Object> argCapture = new Map<String, Object>();

    /**
    * @description This method is used to upsert Account created or edited through Account page in Test class
    * @name : upsertCustomerRec
    * @param customer
    */
    public void upsertCustomerRec(Account customer) {
        String fakeIdValue = String.valueOf(fakeIdCounter++);
        if(clntIdToAcctIdMap.get(customer.clientIdentifier__c) == null) {
            customer.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(12 - fakeIdValue.length()) + fakeIdValue;
        } else {
            customer.id = clntIdToAcctIdMap.get(customer.clientIdentifier__c);
        }
        argCapture.put('upsertCustomerRec', customer);
    }
    
    /**
    * @description his method is used to update Account edited through Account page in Test class
    * @name : updateCustomerRec
    * @param customer
    */
    public void updateCustomerRec(Account customer) {
        customer.id = clntIdToAcctIdMap.get(customer.clientIdentifier__c);
        argCapture.put('updateCustomerRec', customer);
    }

    /**
    * @description This method is used to upsert  Agent roles in Test class
    * @name : upsertAgentRoles
    * @param agentRoles
    * @return Database.UpsertResult[]
    */
    public Database.UpsertResult[] upsertAgentRoles(List<AgentRole__c> agentRoles) {
        return UTIL_BuildRecordsWithChildRel_TEST.buildUpsertResult(Schema.AgentRole__c.SObjectType, agentRoles.size());
    }

    /**
    * @description This method is used to upsert Custlmer Group in Test class
    * @name : upsertCustomerGroupMembers
    * @param customerGroups
    * @return Database.UpsertResult[]
    */
    public Database.UpsertResult[] upsertCustomerGroups(List<CustomerGroup__c> customerGroups) {
        return UTIL_BuildRecordsWithChildRel_TEST.buildUpsertResult(Schema.CustomerGroup__c.SObjectType, customerGroups.size());
    }

    /**
    * @description This method is used to upsert Custlmer Group Member in Test class
    * @name : upsertCustomerRec
    * @param customerGroupMembers
    * @return Database.UpsertResult[]
    */
    public Database.UpsertResult[] upsertCustomerGroupMembers(List<CustomerGroupMember__c> customerGroupMembers) {
        return UTIL_BuildRecordsWithChildRel_TEST.buildUpsertResult(Schema.CustomerGroupMember__c.SObjectType, customerGroupMembers.size());
    }
}