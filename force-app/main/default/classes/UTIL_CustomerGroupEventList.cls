/**
* @name UTIL_CustomerGroupEventList
* @author Poseidon
* @createdDate 09/19/2018
* @description Utility class to return open and closed events for CustomerGroupRelatedList component
*/

public with sharing class UTIL_CustomerGroupEventList {
    private static final String QUERY_PREFIX = 'SELECT Id, WhoId, Who.Name, WhatId, What.Name, Subject, OwnerId, Owner.Name, ActivityDate, ActivityDateTime, LastModifiedDate FROM ';
    private static final String EVENT_HISTORY_LIST_TYPE = 'Event History';
    private static final String OBJECT_TO_QUERY = 'EVENT';
    private static final String OPEN_EVENT_CLAUSE = 'ActivityDateTime >= :currentTime '; 
    private static final String CLOSED_EVENT_CLAUSE = 'ActivityDateTime < :currentTime '; 
    private static final String SPACE = ' ';
    private static final String LIMIT_CLAUSE = 'LIMIT';
    private static final String	EVENT_ICON='standard:event';

    /**
     * @description Fetch Data
     * @param groupRecordId
     * @param relatedListType
     * @param queryLimit
     * @return CustomerGroupRelatedListController.DataTableResponse
     */
    public static CustomerGroupRelatedListController.DataTableResponse fetchData(String groupRecordId, String relatedListType, Integer queryLimit) {
        DateTime currentTime = System.now();
        String whereCondition = ' WHERE AccountId IN :groupCustomerIdList AND CLOSEDOPEN ORDER BY ActivityDateTime DESC NULLS LAST';
        CustomerGroupRelatedListController.DataTableResponse response = new CustomerGroupRelatedListController.DataTableResponse();
        
        List<CustomerGroupRelatedListController.DataTableColumns> columns = new List<CustomerGroupRelatedListController.DataTableColumns>();
        
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Subject','eventUrl','url', true, 'subject'));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Name','accountUrl','url', true, 'accountName'));            
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Related To','relatedToUrl','url', true, 'relatedTo'));  
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Due Date','dueDate','text', true));
        
        if (EVENT_HISTORY_LIST_TYPE.equals(relatedListType)) {
            whereCondition = whereCondition.replace('CLOSEDOPEN', CLOSED_EVENT_CLAUSE);
            columns.add(new CustomerGroupRelatedListController.DataTableColumns('Office Assigned','officeAssignedUrl','url', true, 'officeAssigned'));
        } else {
            whereCondition = whereCondition.replace('CLOSEDOPEN', OPEN_EVENT_CLAUSE);
            columns.add(new CustomerGroupRelatedListController.DataTableColumns('Office Assigned','officeAssignedUrl','url', true, 'officeAssigned'));
            columns.add(new CustomerGroupRelatedListController.DataTableColumns('Last Modified Date/Time','lastModifiedDateTime','text', true)); 
        }
        
        List<Id> groupCustomerIdList = UTIL_CustomerGroupList.fetchCustomerGroupMemberIds(groupRecordId);
        
        String queryString = QUERY_PREFIX;
        queryString += OBJECT_TO_QUERY + whereCondition + SPACE + LIMIT_CLAUSE + SPACE + queryLimit;
        
        List<Event> events = UTIL_CustomerGroupList.fetchEventList(groupCustomerIdList, queryString);
        
        List<EventWrapper> eventWrappers = new List<EventWrapper>();
        
        for (Event event : events) {
            eventWrapper eventWrapper = new eventWrapper();
            eventWrapper.id = event.Id;
            eventWrapper.eventUrl = UTIL_CustomerGroupList.buildLightningUrl(event.Id);
            eventWrapper.subject = UTIL_CustomerGroupList.handleNullString(event.Subject);
            eventWrapper.accountName = UTIL_CustomerGroupList.handleNullString(event.Who.Name);
            eventWrapper.accountUrl= UTIL_CustomerGroupList.buildLightningUrl(event.WhoId);
            eventWrapper.relatedTo = UTIL_CustomerGroupList.handleNullString(event.What.Name);
            eventWrapper.relatedToUrl=UTIL_CustomerGroupList.buildLightningUrl(event.WhatId);
            eventWrapper.dueDate = UTIL_CustomerGroupList.handleNullDate(event.ActivityDate);
            eventWrapper.officeAssigned = UTIL_CustomerGroupList.handleNullString(event.Owner.Name);
            eventWrapper.officeAssignedUrl = UTIL_CustomerGroupList.buildLightningUrl(event.OwnerId); 
            eventWrapper.lastModifiedDateTime = event.LastModifiedDate.format('M-dd-yyyy hh:mm:ss z');
            eventWrappers.add(eventWrapper);
        }
	
        response.lstDataTableColumns = columns;
        response.lstDataTableData = eventWrappers;
        response.icon=EVENT_ICON;
        
        return response;     
    }
        
    /**
     * @description Event Wrapper
     */
    public with sharing class EventWrapper {

        /**
         * @description Getters and Setters of the property Id
         */
        @AuraEnabled
        public String id {get; set;}

        /**
         * @description Getters and Setters of the property subject
         */
        @AuraEnabled
        public String subject {get; set;}

        /**
         * @description Getters and Setters of the property eventUrl
         */
        @AuraEnabled
        public String eventUrl {get; set;}

        /**
         * @description Getters and Setters of the property accountName
         */
        @AuraEnabled
        public String accountName {get; set;}

        /**
         * @description Getters and Setters of the property accountUrl
         */
        @AuraEnabled
        public String accountUrl {get; set;}

        /**
         * @description Getters and Setters of the property relatedTo
         */
        @AuraEnabled
        public String relatedTo {get; set;}

        /**
         * @description Getters and Setters of the property relatedToUrl
         */
        @AuraEnabled
        public String relatedToUrl {get; set;}

        /**
         * @description Getters and Setters of the property dueDate
         */
        @AuraEnabled
        public String dueDate {get; set;}

        /**
         * @description Getters and Setters of the property officeAssigned
         */
        @AuraEnabled
        public String officeAssigned {get; set;}

        /**
         * @description Getters and Setters of the property officeAssignedUrl
         */
        @AuraEnabled
        public String officeAssignedUrl {get; set;}

        /**
         * @description Getters and Setters of the property lastModifiedDateTime
         */
        @AuraEnabled
        public String lastModifiedDateTime {get; set;}
    }  
}
