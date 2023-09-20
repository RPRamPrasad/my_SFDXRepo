/**
* @name UTIL_CustomerGroupCaseList
* @author Poseidon
* @createdDate 10/01/2018
* @description Utility class to return cases for CustomerGroupRelatedList component
*/
public with sharing class UTIL_CustomerGroupCaseList {
    
    public static final String OBJECT_TO_QUERY = 'Case';
    public static final String WHERE_CONDITION = ' WHERE AccountId IN:groupCustomerIdList ORDER BY CaseNumber	 DESC NULLS LAST';
    public static final Integer QUERY_LIMIT = 10;
    private static final String	CASE_ICON='standard:case';
     
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
        
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Case','caseUrl','url', true, 'caseNumber'));     
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Case Owner','contactUrl','url', true, 'contactName'));     
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Subject','subject','text', true, 'subject'));  
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Priority','priority','text', true));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Date/Time Opened','createdDate','date', true));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Status','status','text', true));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Owner','ownerUrl','url', true, 'ownerName'));
        
        List<Id> groupCustomerIdList = UTIL_CustomerGroupList.fetchCustomerGroupMemberIds(groupRecordId);
        if (queryLimit == 0) { queryLimit = 200;}
        List<Case> cases = Security.stripInaccessible(
                                                  AccessType.READABLE,
                                                  [SELECT CaseNumber, ContactId, Contact.Name, Subject, Priority, CreatedDate, Status, Owner.Name
                                                   FROM Case
                                                   WHERE AccountId IN:groupCustomerIdList 
                                                   ORDER BY CaseNumber	 
                                                   DESC NULLS LAST
                                                   LIMIT :queryLimit])
                                                  .getRecords();

        List<CaseWrapper> caseWrappers = new List<CaseWrapper>();
        
        for (Case caze : cases) {
            CaseWrapper caseWrapper = new CaseWrapper();
            caseWrapper.id = caze.Id;
            caseWrapper.caseUrl = UTIL_CustomerGroupList.buildLightningUrl(caze.Id);
            caseWrapper.contactUrl = UTIL_CustomerGroupList.buildLightningUrl(caze.contactId);    
            caseWrapper.contactName = UTIL_CustomerGroupList.handleNullString(caze.Contact.Name);  
            caseWrapper.subject = UTIL_CustomerGroupList.handleNullString(caze.Subject);            
            caseWrapper.priority = UTIL_CustomerGroupList.handleNullString(caze.Priority);            
            caseWrapper.createdDate = caze.CreatedDate.format('M-dd-yyyy hh:mm:ss z');            
            caseWrapper.status = UTIL_CustomerGroupList.handleNullString(caze.Status);
            caseWrapper.ownerUrl = UTIL_CustomerGroupList.buildLightningUrl(caze.OwnerId);    
            caseWrapper.ownerName = UTIL_CustomerGroupList.handleNullString(caze.Owner.Name);            
            caseWrapper.caseNumber = UTIL_CustomerGroupList.handleNullString(caze.CaseNumber);
            
            caseWrappers.add(caseWrapper);
        }
        
        response.lstDataTableColumns = columns;
        response.lstDataTableData = caseWrappers;
        response.icon=CASE_ICON;
        
        return response;   
    } 

    /**
     * @description Case Wrapper
     */
    public with sharing class CaseWrapper {
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
         * @description Getters and Setters of the property caseUrl
         */
        @AuraEnabled
        public String caseUrl {get; set;}

        /**
         * @description Getters and Setters of the property caseNumber
         */
        @AuraEnabled
        public String caseNumber {get; set;}

        /**
         * @description Getters and Setters of the property contactName
         */
        @AuraEnabled
        public String contactName {get; set;}

        /**
         * @description Getters and Setters of the property contactUrl
         */
        @AuraEnabled
        public String contactUrl {get; set;}

        /**
         * @description Getters and Setters of the property createdDate
         */
        @AuraEnabled
        public String createdDate {get; set;}

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
         * @description Getters and Setters of the property ownerUrl
         */
        @AuraEnabled
        public String ownerUrl {get; set;}

        /**
         * @description Getters and Setters of the property ownerName
         */
        @AuraEnabled
        public String ownerName {get; set;}
    }
    
}