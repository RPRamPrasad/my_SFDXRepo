/**
  * @name UTIL_CustomerGroupList
  * @author Poseidon
  * @createdDate 09/07/2018
  * @description Common class to access various Customer Group Object related operations.
  */
public with sharing class UTIL_CustomerGroupList {
	public static final String LIGHTNING_SOBJECT_URL='/one/one.app#/sObject/';
    private static final Integer QUERY_LIMIT = 1;
    private static final String WHERE_CONDITION = ' WHERE Id =:customerGroupRecordId';

    /**
     * @description Fetch Customer Group Member Ids
     * @param customerGroupRecordId
     * @return List<Id>
     */
    public static List<Id> fetchCustomerGroupMemberIds(String customerGroupRecordId) {
        
        String customerGroupAccessField = 'Id';
        String customerGroupingAccessField = 'Customer__c';
                                                               
        // Obtain the field name/token map for the CustomerGroup__c, CustomerGroupMember__c object
        Map<String,Schema.SObjectField> custGroupMap = Schema.SObjectType.CustomerGroup__c.fields.getMap();
        Map<String,Schema.SObjectField> custGroupMemberMap = Schema.SObjectType.CustomerGroupMember__c.fields.getMap();
    
        // Check if the user has access to view field
        if (!custGroupMap.get(customerGroupAccessField).getDescribe().isAccessible() || !custGroupMemberMap.get(customerGroupingAccessField).getDescribe().isAccessible()) {
            // Pass error to client
            throw new System.NoAccessException();
        }
        
        // Query the object safely  
        List<CustomerGroup__c> customerGroupList = Security.stripInaccessible(
                                                  AccessType.READABLE,
                                                  [SELECT Id, (Select Customer__c From CustomerGroupings__r)
                                                   FROM CustomerGroup__c
                                                   WHERE  Id = :customerGroupRecordId
                                                   LIMIT 1])
                                                  .getRecords();


		List<Id> groupCustomerIdList = new List<Id>();
        for(CustomerGroup__c customerGroup : customerGroupList) {
            for(CustomerGroupMember__c groupMember : customerGroup.CustomerGroupings__r) {
                groupCustomerIdList.add(groupMember.Customer__c);
           }
        }
        
        return groupCustomerIdList;
    }
    
    /**
     * @description Fetch Event List
     * @param groupCustomerIdList
     * @param query
     * @return List<Event>
     */
    public static List<Event> fetchEventList(List<Id> groupCustomerIdList, String query) {
        DateTime currentTime = System.now();
        String[] eventAccessFields = new String[] {'Id',
            									   'WhoId',
            									   'WhatId',
            									   'Subject',
            									   'OwnerId',
            									   'ActivityDate',
            									   'ActivityDateTime',
            									   'LastModifiedDate'
            									  };
                                                               
        // Obtain the field name/token map for the Event object
        Map<String,Schema.SObjectField> eventFieldMap = Schema.SObjectType.Event.fields.getMap();
    	
        for (String eventField : eventAccessFields) {
            // Check if the user has access to view fields
            if (!eventFieldMap.get(eventField).getDescribe().isAccessible()) {
                // Pass error to client
                AuraHandledException ahe = new AuraHandledException('Cannot access fields');
                ahe.setMessage('Sorry, you do not have access to these fields: ' + eventFieldMap.get(eventField).getDescribe().getName());
                throw ahe;
            }
        }
        
        // Query the object safely
        return Database.query(query);
    }

    /**
     * @description Fetch SF Group Identifier
     * @param customerGroupRecordId
     * @return String
     */
    public static String fetchSFGroupIdentifier(String customerGroupRecordId){
        
        List<CustomerGroup__c> customerGroups  = Security.stripInaccessible(
                                                  AccessType.READABLE,
                                                  [SELECT SFGroupIdentifier__c
                                                   FROM CustomerGroup__c
                                                   WHERE  Id =:customerGroupRecordId
                                                   LIMIT 1])
                                                  .getRecords();
        if (customerGroups==null || customerGroups.size() !=1){
            return '';
        } else {
            return customerGroups.get(0).SFGroupIdentifier__c;
        }
    }

    /**
     * @description Build Lightning Url
     * @param id
     * @return String
     */
    public static String buildLightningUrl(String id) {
        if (String.isBlank(id)) {
            return '';
        } else {
            return LIGHTNING_SOBJECT_URL + id;
        }
    }
    
    /**
     * @description Handle Null String
     * @param str
     * @return String
     */
    public static String handleNullString(String str) {
        if (String.isBlank(str)) {
            return '';
        } else {
            return str;
        }
    }
    
    /**
     * @description Handle Null Date
     * @param dateValue
     * @return String
     */
    public static String handleNullDate(Date dateValue) {
        if (null == dateValue) {
            return '';
        } else {
            return dateValue.format();
        }
    }
    
    /**
     * @description Handle Null Decimal
     * @param dec
     * @return String
     */
    public static String handleNullDecimal(Decimal dec) {
        if (null == dec) {
            return '';
        } else {
            return '$' + String.valueOf(dec.setScale(2));
        }
    }
}