/**
  * @name UTIL_CustomerGroupTaskList
  * @author Poseidon
  * @createdDate 09/14/2018
  * @description Utility class to return open and closed tasks for CustomerGroupRelatedList component
  */
public with sharing class UTIL_CustomerGroupTaskList {
 	private static final String TASK_HISTORY_LIST_TYPE = 'Task History';
    private static final String OBJECT_TO_QUERY = 'Task';
    private static final String WHERE_CONDITION = ' WHERE IsClosed =:isClosed and isRecurrence <> True and AccountId IN:groupCustomerIdList ORDER BY ActivityDate DESC NULLS LAST';
    private static final Integer QUERY_LIMIT = 10;
    private static final String TASK_ICON='standard:task';
    
    /**
     * @description Fetch Data
     * @param groupRecordId
     * @param relatedListType
     * @param queryLimit
     * @return CustomerGroupRelatedListController.DataTableResponse
     */
    public static CustomerGroupRelatedListController.DataTableResponse fetchData(String groupRecordId, String relatedListType, Integer queryLimit) {
    	
        CustomerGroupRelatedListController.DataTableResponse response = new CustomerGroupRelatedListController.DataTableResponse();
      
        List<CustomerGroupRelatedListController.DataTableColumns> columns = new List<CustomerGroupRelatedListController.DataTableColumns>();
        
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Subject','taskUrl','url', true, 'subject'));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Name','accountUrl','url', true, 'accountName'));            
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Related To','relatedToUrl','url', true, 'relatedTo'));  
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Due Date','dueDate','text', true));
        
        if (TASK_HISTORY_LIST_TYPE.equals(relatedListType)) {
            columns.add(new CustomerGroupRelatedListController.DataTableColumns('Office Assigned','officeAssignedUrl','url', true, 'officeAssigned'));
            columns.add(new CustomerGroupRelatedListController.DataTableColumns('Last Modified Date/Time','lastModifiedDateTime','text', true)); 
        } else {
            columns.add(new CustomerGroupRelatedListController.DataTableColumns('Status','status','text', true));  
        	columns.add(new CustomerGroupRelatedListController.DataTableColumns('Priority','priority','text', true));  
        	columns.add(new CustomerGroupRelatedListController.DataTableColumns('Office Assigned','officeAssignedUrl','url', true, 'officeAssigned'));  
        }
        List<Id> groupCustomerIdList = UTIL_CustomerGroupList.fetchCustomerGroupMemberIds(groupRecordId);
        boolean isClosed = relatedListType.equals(TASK_HISTORY_LIST_TYPE);
        if (queryLimit == 0) { queryLimit = 200;}
        List<Task> tasks  =   Security.stripInaccessible(
                                    AccessType.READABLE,
                                    [SELECT Id, WhoId, Who.Name, WhatId, What.Name, Subject,  OwnerId, Owner.Name, Status, ActivityDate, Priority, LastModifiedDate 
                                    FROM Task
                                    WHERE IsClosed =:isClosed and isRecurrence <> True and AccountId IN:groupCustomerIdList 
                                    ORDER BY ActivityDate 
                                    DESC NULLS LAST
                                    LIMIT :queryLimit])
                                    .getRecords();
        List<TaskWrapper> taskWrappers = new List<TaskWrapper>();
        
        for (Task task : tasks) {
            TaskWrapper taskWrapper = new TaskWrapper();
            taskWrapper.id = task.Id;
            taskWrapper.taskUrl = UTIL_CustomerGroupList.buildLightningUrl(task.Id);
            taskWrapper.subject = UTIL_CustomerGroupList.handleNullString(task.Subject);
            taskWrapper.accountName = UTIL_CustomerGroupList.handleNullString(task.Who.Name);
            taskWrapper.accountUrl= UTIL_CustomerGroupList.buildLightningUrl(task.WhoId);
            taskWrapper.relatedTo = UTIL_CustomerGroupList.handleNullString(task.What.Name);
            taskWrapper.relatedToUrl=UTIL_CustomerGroupList.buildLightningUrl(task.WhatId);
            taskWrapper.dueDate = UTIL_CustomerGroupList.handleNullDate(task.ActivityDate);
            taskWrapper.status = UTIL_CustomerGroupList.handleNullString(task.Status);
            taskWrapper.priority = UTIL_CustomerGroupList.handleNullString(task.Priority);
            taskWrapper.officeAssigned = UTIL_CustomerGroupList.handleNullString(task.Owner.Name);
            taskWrapper.officeAssignedUrl = UTIL_CustomerGroupList.buildLightningUrl(task.OwnerId); 
            taskWrapper.lastModifiedDateTime = task.LastModifiedDate.format('M-dd-yyyy hh:mm:ss z');
            taskWrappers.add(taskWrapper);
        }
        
		response.lstDataTableColumns = columns;
        response.lstDataTableData = taskWrappers;
        response.icon=TASK_ICON;
        
        return response;    
   	}
    
    /** 
     * @description Task Wrapper
    */
    public with sharing class TaskWrapper {
        /**
         * @description Getters and Setters of the property id
         */
        @AuraEnabled
        public String id {get; set;}

        /**
         * @description Getters and Setters of the property subject
         */
        @AuraEnabled
        public String subject {get; set;}

        /**
         * @description Getters and Setters of the property taskUrl
         */
        @AuraEnabled
        public String taskUrl {get; set;}

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
         * @description Getters and Setters of the property status
         */
        @AuraEnabled
        public String status {get; set;}

        /**
         * @description Getters and Setters of the property priority
         */
        @AuraEnabled
        public String priority {get; set;}

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