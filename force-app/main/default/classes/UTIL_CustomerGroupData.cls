/**
 * @description UTIL_CustomerGroupData 
 */
public with sharing class UTIL_CustomerGroupData {
    @TestVisible private static CustomerGroupMember__c mockedGroupMember;
    private static final String ERROR = 'ERROR';
    private static final String CLASS_NAME = 'UTIL_CustomerGroupData';
    private UTIL_CustomerGroupData(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info(CLASS_NAME, 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }

    /**
     * @description getClientIdsForGroup
     * @param groupId 
     * @return  `Map<String,Account>`
     * @exception 
     */
    public static Map<String,Account> getClientIdsForGroup(String groupId) {
        @TestVisible List<CustomerGroupMember__c> response;
        Map<String, Account> clientIdsToNamesMap = new Map<String, Account>();
        try {
            if (Test.isRunningTest()) {
                response = new List<CustomerGroupMember__c> {mockedGroupMember};
                    if (mockedGroupMember.Customer__r.Name.equals(ERROR)) {
                        throw new DMLException('THIS IS A TEST ERROR');
                    }       
            } else {
                response = Security.stripInaccessible(AccessType.READABLE, [
                    SELECT 
                    	Customer__r.ClientIdentifier__c, 
                    	Customer__r.Name, 
                    	Customer__c
                	FROM 
                		CustomerGroupMember__c
                	WHERE 
                    	Group__c = :groupId
                ]).getRecords();
            }
            
            if (null != response) {
                for (CustomerGroupMember__c member : response) {
                    clientIdsToNamesMap.put(member.Customer__r.ClientIdentifier__c, member.Customer__r);
                }
            }
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'getClientIdsForGroup', System.LoggingLevel.ERROR);
            throw new AuraHandledException('QUERY ERROR');
        }
        return clientIdsToNamesMap;
    }
    /**
     * @description getRecordIdsForGroup
     * @param groupId 
     * @return  `Map<Id,Account>`
     * @exception 
     */
    public static Map<Id,Account> getRecordIdsForGroup(String groupId) {
        @TestVisible List<CustomerGroupMember__c> response;
        Map<Id, Account> recordIdsToNamesMap = new Map<Id, Account>();
        
        try {
            if (Test.isRunningTest()) {
                response = new List<CustomerGroupMember__c> {mockedGroupMember};
                    if (mockedGroupMember.Customer__r.Name.equals(ERROR)) {
                        throw new DMLException('THIS IS A TEST ERROR');
                    }       
            } else {
                response = Security.stripInaccessible(AccessType.READABLE, [
                    SELECT 
                        Customer__r.ClientIdentifier__c, 
                    	Customer__r.Name, 
                    	Customer__c 
                    FROM 
                    	CustomerGroupMember__c 
                    WHERE 
                    	Group__c = :groupId
                ]).getRecords();
            }
            
            if (null != response) {
                for (CustomerGroupMember__c member : response) {
                    recordIdsToNamesMap.put(member.Customer__c, member.Customer__r);
                }
            }
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'getRecordIdsForGroup', System.LoggingLevel.ERROR);
            throw new AuraHandledException('QUERY ERROR');
        }
        return recordIdsToNamesMap;
    }
    /**
     * @description getGroupMembers
     * @param recordId 
     * @return  `List<CustomerGroupMember__c>`
     * @exception 
     */
    public static List<CustomerGroupMember__c> getGroupMembers(String recordId) {
        @TestVisible List<CustomerGroupMember__c> groupMembers;
        
        try {
            if (Test.isRunningTest()) {
                groupMembers = new List<CustomerGroupMember__c> {mockedGroupMember};
                   if (mockedGroupMember.Customer__r.Name.equals(ERROR)) {
                        throw new DMLException('THIS IS A TEST ERROR');
                    }       
            } else {
                groupMembers = Security.stripInaccessible(AccessType.READABLE, [
                    SELECT 
                    	Customer__r.ClientIdentifier__c, 
                    	Customer__r.Name, 
                    	Customer__c 
                    FROM 
                    	CustomerGroupMember__c 
                    WHERE 
                    	Group__c = :recordId
                ]).getRecords();
            }
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'getClientIdsForGroup', System.LoggingLevel.ERROR);
            throw new AuraHandledException('QUERY ERROR');
        }
        return groupMembers;
    }
    
}