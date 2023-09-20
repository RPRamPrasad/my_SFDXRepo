/**
  * @name UTIL_CustomerGroupMemberDetail
  * @author Poseidon
  * @createdDate 10/08/2018
  * @description Utility class to return list of group members for the CustomerGroupMemberDetail component
  */
public with sharing class UTIL_CustomerGroupMemberDetail {
	private static final String OBJECT_TO_QUERY = 'CustomerGroupMember__c';
    private static final String WHERE_CONDITION = ' WHERE Group__c = :groupRecordId';
    private static final Integer QUERY_LIMIT = 10;
    private static String groupMemberIcon ='standard:household';
    private static String self = 'Self';
    private static final String DEATH_NOTIFICATION = 'DECEASED';
    
    private static Map<Id, CustomerGroupMember__c> groupMemberAccIdMap {get; set;}
    private static Map<Id, String> relationshipMap {get; set;}
    
    /**
     * @description Fetch Data Wrapper
     */
    public class FetchDataWrapper{
        public String groupRecordId;
        public String relatedListType;
        public String accountId;
        public Integer queryLimit;
    }

    /**
     * @description Fetch Data
     * @param dataWrap
     * @return CustomerGroupRelatedListController.DataTableResponse
     */
    public static CustomerGroupRelatedListController.DataTableResponse fetchData(FetchDataWrapper dataWrap) {
    	
        String groupRecordId = dataWrap.groupRecordId;
        String accountId = dataWrap.accountId;
        Integer queryLimit = dataWrap.queryLimit;

        CustomerGroupRelatedListController.DataTableResponse response = new CustomerGroupRelatedListController.DataTableResponse();
        
        List<CustomerGroupRelatedListController.DataTableColumns> columns = buildColumns();
        List<CustomerGroupMember__c> groupMembers = retrieveGroupMembers(groupRecordId, queryLimit);
        List<GroupMemberWrapper> groupMemberWrappers = new List<GroupMemberWrapper>();
        
        groupMemberAccIdMap = new Map<Id, CustomerGroupMember__c>();
        
        String primaryContactToFind = '';
        if(!(null == groupMembers || groupMembers.isEmpty())) {

            /*
                The same loop is done twice due to the populateRelationshipMap being written to run a query, which should not be in a for loop.
                Thus, we go through the groupMembers and add them to the map that is used in the query, and then go through the loop again to
                finish the processing.
            */
            for (CustomerGroupMember__c groupMember : groupMembers) {
                // Populate relationship map to get Relationship__c fields
                groupMemberAccIdMap.put(groupMember.Customer__c, groupMember);
            }

            populateRelationshipMap(accountId, groupMemberAccIdMap, queryLimit);

            for (CustomerGroupMember__c groupMember : groupMembers) {
                
                GroupMemberWrapper groupMemberWrapper = new GroupMemberWrapper();
                groupMemberWrapper.id = groupMember.id;
                groupMemberWrapper.customerId = UTIL_CustomerGroupList.handleNullString(groupMember.Customer__c);
                groupMemberWrapper.accountName = UTIL_CustomerGroupList.handleNullString(groupMember.Customer__r.Name);
                groupMemberWrapper.accountNameUrl = UTIL_CustomerGroupList.buildLightningUrl(groupMember.Customer__c);
                try{
                    groupMemberWrapper.gender = UTIL_CustomerGroupList.handleNullString(groupMember.Customer__r.Gender__pc);
                } catch(Exception ex){
					system.debug(LoggingLevel.INFO, '**** User does not have access to  Gender__pc '+ex);
                }
                groupMemberWrapper.birthDate = UTIL_CustomerGroupList.handleNullDate(groupMember.Customer__r.PersonBirthDate);
                groupMemberWrapper.isPrimaryContact = groupMember.MemberPrimaryContact__c;
                
                evaluateDeathNotification(groupMember, groupMemberWrapper);
                
                primaryContactToFind = evaluatePrimaryContact(groupMember, primaryContactToFind);
                
                evaluateCustomerRelatioship(groupMember, groupMemberWrapper, accountId);
                
                groupMemberWrappers.add(groupMemberWrapper);
            }
        }
        
        response.lstDataTableData = groupMemberWrappers;
        response.lstDataTableColumns = columns;
        response.icon = groupMemberIcon;
        response.externalId=UTIL_CustomerGroupList.fetchSFGroupIdentifier(groupRecordId);
        response.primaryContact = primaryContactToFind;
        response.customerGroupId = groupRecordId;
        response.currentUser = UTIL_CurrentUser.retrieveCurrentUser();
        return response;
    }
    
    static void evaluateDeathNotification(CustomerGroupMember__c groupMember, GroupMemberWrapper groupMemberWrapper){
        
        // To set death notification
        if (groupMember.Customer__r.IsDeathNotificationReceived__pc == true){
            groupMemberWrapper.deathNotification = DEATH_NOTIFICATION;
        }
    }

    static String evaluatePrimaryContact(CustomerGroupMember__c groupMember, String primaryContactToFind){        
        
        // Group member is current primary contact
        if (groupMember.MemberPrimaryContact__c == true) {
            primaryContactToFind = groupMember.Customer__c;
        }
        return primaryContactToFind;
    }

    static void evaluateCustomerRelatioship(CustomerGroupMember__c groupMember, GroupMemberWrapper groupMemberWrapper, String accountId){
        
        // Set Relationship to Self if accountID context matches
        if (accountId.equals(groupMember.Customer__c)) {
            groupMemberWrapper.customerRelationship = UTIL_CustomerGroupList.handleNullString(SELF);
        } else {
            groupMemberWrapper.customerRelationship = UTIL_CustomerGroupList.handleNullString(relationshipMap.get(groupMember.Customer__c));
        }
    }

    /**
     * @description Primary Contact Wrapper
     */
    public class PrimaryContactWrapper{
        public String primaryContact;
        public String requestedMember;
        public String groupRecordId;
        public Integer queryLimit;
    }

    /**
     * @description Update Primary Contact
     * @param prConWrap
     * @return Boolean
     */
    public static Boolean updatePrimaryContact(PrimaryContactWrapper prConWrap) {

        String primaryContact = prConWrap.primaryContact;
        String requestedMember = prConWrap.requestedMember;
        String groupRecordId = prConWrap.groupRecordId;
        Integer queryLimit = prConWrap.queryLimit;

        List<SObject> primaryContactsToUpdate = new List<SObject>();
        Boolean isUpdated = false;
  
        // Get list of CustomerGroupMember__c
        List<CustomerGroupMember__c> groupMembers = retrieveGroupMembers(groupRecordId, queryLimit);
        Map<Id, CustomerGroupMember__c> groupMemberMap = new Map<Id, CustomerGroupMember__c>();
        
        if(!(null == groupMembers || groupMembers.isEmpty())) {
            for (CustomerGroupMember__c groupMember : groupMembers) {
                // Populate map to query each group member with id
                groupMemberMap.put(groupMember.Customer__c, groupMember);
            }
        }
        
        // Get current group member who is primary contact
        if (!String.isBlank(primaryContact)) {
            CustomerGroupMember__c currentPrimaryContactMember = groupMemberMap.get(primaryContact);
            if (null != currentPrimaryContactMember) {               
                // Set current primary contact to false
                currentPrimaryContactMember.MemberPrimaryContact__c = false;
                primaryContactsToUpdate.add(currentPrimaryContactMember);
            }
        }      
               
        // Set requested group member to primary contact
        CustomerGroupMember__c requestedPrimaryContactMember = groupMemberMap.get(requestedMember);
        requestedPrimaryContactMember.MemberPrimaryContact__c = true;
        primaryContactsToUpdate.add(requestedPrimaryContactMember);
        
        // Update record with new primary contact
        update Security.stripInaccessible(AccessType.UPDATABLE, primaryContactsToUpdate).getRecords();


        isUpdated = true;
        return isUpdated;
    }
    
    /**
     * @description Group Member Wrapper
     */
    public with sharing class GroupMemberWrapper {

        /**
         * @description Getters and Setters of the parameter Id
         */
        @AuraEnabled
        public String id {get; set;}

        /**
         * @description Getters and Setters of the parameter accountName
         */
        @AuraEnabled
        public String accountName {get; set;}

        /**
         * @description Getters and Setters of the parameter accountNameUrl
         */
        @AuraEnabled
        public String accountNameUrl {get; set;}

        /**
         * @description Getters and Setters of the parameter customerId
         */
        @AuraEnabled
        public String customerId {get; set;}

        /**
         * @description Getters and Setters of the parameter gender
         */
        @AuraEnabled
        public String gender {get; set;}

        /**
         * @description Getters and Setters of the parameter birthDate
         */
        @AuraEnabled
        public String birthDate {get; set;}

        /**
         * @description Getters and Setters of the parameter customerRelationship
         */
        @AuraEnabled
        public String customerRelationship {get; set;}

        /**
         * @description Getters and Setters of the parameter isPriamryContact
         */
        @AuraEnabled
        public Boolean isPrimaryContact {get; set;}

        /**
         * @description Getters and Setters of the parameter deathNotification
         */
        @AuraEnabled
        public String deathNotification {get; set;}
        
    }
    
    private static List<CustomerGroupMember__c> retrieveGroupMembers(String groupRecordId, Integer queryLimit) {
        if (queryLimit == 0) { queryLimit = 200;}
        List<CustomerGroupMember__c> groupMembers = Security.stripInaccessible(
                                                  AccessType.READABLE,
                                                  [SELECT Id, Customer__c, Customer__r.Name, Customer__r.PersonBirthDate, Customer__r.Gender__pc, MemberPrimaryContact__c, Customer__r.IsDeathNotificationReceived__pc
                                                   FROM CustomerGroupMember__c
                                                   WHERE Group__c = :groupRecordId
                                                   LIMIT :queryLimit])
                                                  .getRecords();
		System.debug(LoggingLevel.INFO, groupMembers.size() + ' - group members length');
        return groupMembers;        
    }
    
	
    private static void populateRelationshipMap(String accountId, Map<Id, CustomerGroupMember__c> groupMemberAccIdMap, Integer queryLimit) {
        
       	List<Id> groupMemberIdList = new List<Id>();
        relationshipMap = new Map<Id, String>();
        // Converting group member map to list for query
        for (Id aId : groupMemberAccIdMap.keySet()) {
            groupMemberIdList.add(aId);
        }
        
        List<Relationship__c> relationshipsToAccount = Security.stripInaccessible(
                                                  AccessType.READABLE,
                                                  [SELECT Id, AccountOne__c, AccountTwo__c, RelationshipType__c
                                                   FROM Relationship__c
                                                   WHERE AccountTwo__c = :accountId and AccountOne__c IN :groupMemberIdList
                                                   LIMIT :queryLimit])
                                                  .getRecords();
        
        if(!(null == relationshipsToAccount || relationshipsToAccount.isEmpty())) {
            for (Relationship__c relationship : relationshipsToAccount) {
                relationshipMap.put(relationship.AccountOne__c, relationship.RelationshipType__c);
            }
        }
    }
    
    private static List<CustomerGroupRelatedListController.DataTableColumns> buildColumns(){
        List<CustomerGroupRelatedListController.DataTableColumns> columns = new List<CustomerGroupRelatedListController.DataTableColumns>();
        
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Account Name', 'accountNameUrl', 'url', true, 'accountName'));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Gender', 'gender', 'text', true));            
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Birthdate', 'birthDate', 'text', true));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Relationship to Customer', 'customerRelationship', 'text', true));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Primary Contact', 'isPrimaryContact', 'boolean', true));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Death Notification', 'deathNotification', 'text', true));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Make Primary Contact', 'action', 'make_primary_contact'));
        return columns;
        
    }
}