/**
  * @name UTIL_CustomerGroupMoveMemberRequest
  * @author Poseidon
  * @createdDate 12/04/2018
  * @description Request object payload to pass to HouseholdManagement service.
  */
public with sharing class UTIL_CustomerGroupMoveMemberRequest {
    @AuraEnabled
    public CustomerGroupPayloadData data;
    @AuraEnabled
    public CustomerGroupMemberMeta meta;
	
    /**
     * @description Customer Group Member Meta
     */
    public with sharing class CustomerGroupMemberMeta {
        @AuraEnabled
        public String callingApplication;
        @AuraEnabled
        public String callingArea;
        @AuraEnabled
        public Requester requester;
    }
    
    /**
     * @description Requester
     */
    public with sharing class Requester {
        @AuraEnabled
        public String requesterReferenceId;
        @AuraEnabled
        public String requesterReferenceType;
    }
    
    /**
     * @description Customer Group Modification
     */
    public with sharing class CustomerGroupModification {
        @AuraEnabled
        public String customer;
        @AuraEnabled
        public String oldGroup;
        @AuraEnabled
        public String newGroup;
    }
    
    /**
     * @description Customer Group Payload Data
     */
    public with sharing class CustomerGroupPayloadData {
        @AuraEnabled
        public String agent;
        @AuraEnabled
        public List<CustomerGroupModification> groups;
    }    
}