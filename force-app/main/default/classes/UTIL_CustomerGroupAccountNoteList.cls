/**
* @name UTIL_CustomerGroupAccountNoteList
* @author Poseidon
* @createdDate 10/07/2018
* @description Utility class to return account notes for CustomerGroupRelatedList component
*/
public with sharing class UTIL_CustomerGroupAccountNoteList {
    
    public static final String OBJECT_TO_QUERY = 'Account_Note__c';
    public static final String WHERE_CONDITION = ' WHERE Account__r.id IN:groupCustomerIdList ORDER BY Account__r.id DESC NULLS LAST';
    public static final Integer QUERY_LIMIT = 10;
    private static final String	NOTE_ICON='standard:note';

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
        
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Account','accountUrl','url', true, 'accountName'));       
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Created By','createdByUrl','url', true, 'createdByName'));  
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Created Date','createdDate','text', true));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Comments','comments','text', true));
        
        List<Id> groupCustomerIdList = UTIL_CustomerGroupList.fetchCustomerGroupMemberIds(groupRecordId);  
        if (queryLimit == 0) { queryLimit = 200;}
        List<Account_Note__c> acctNotes = Security.stripInaccessible(
                                                  AccessType.READABLE,
                                                  [SELECT Account__r.Name, Comments__c, Alert__c, CreatedBy.Id, CreatedBy.Name, CreatedDate
                                                   FROM Account_Note__c
                                                   WHERE Account__r.id IN:groupCustomerIdList 
                                                   ORDER BY Account__r.id 
                                                   DESC NULLS LAST
                                                   LIMIT :queryLimit])
                                                  .getRecords();
        
        List<AccountNoteWrapper> acctNoteWrappers = new List<AccountNoteWrapper>();
        
        for (Account_Note__C acctNote : acctNotes) {
            AccountNoteWrapper acctNoteWrapper = new AccountNoteWrapper();
            acctNoteWrapper.id = acctNote.Id;
             acctNoteWrapper.accountName = UTIL_CustomerGroupList.handleNullString(acctNote.Account__r.Name);
            acctNoteWrapper.accountUrl = UTIL_CustomerGroupList.buildLightningUrl(acctNote.Id);
            acctNoteWrapper.createdByName = UTIL_CustomerGroupList.handleNullString(acctNote.CreatedBy.Name);
            acctNoteWrapper.createdByUrl = UTIL_CustomerGroupList.buildLightningUrl(acctNote.CreatedBy.Id);    
            acctNoteWrapper.createdDate = acctNote.CreatedDate.format('M-dd-yyyy hh:mm:ss z'); 
            acctNoteWrapper.comments = UTIL_CustomerGroupList.handleNullString(acctNote.Comments__c);            
            
            
            acctNoteWrappers.add(acctNoteWrapper);
        }
        
        response.lstDataTableColumns = columns;
        response.lstDataTableData = acctNoteWrappers;
        response.icon=NOTE_ICON;
        
        return response; 
    }
    
    /**
     * @description Account Note Wrapper
     */
    public with sharing class AccountNoteWrapper {

        /**
         * @description Getters and Setters for the property id
         */
        @AuraEnabled
        public String id {get; set;}

        /**
         * @description Getters and Setters for the property accountUrl
         */
        @AuraEnabled
        public String accountUrl {get; set;}

        /**
         * @description Getters and Setters for the property createdByUrl
         */
        @AuraEnabled
        public String createdByUrl {get; set;}

        /**
         * @description Getters and Setters for the property createdByName
         */
        @AuraEnabled
        public String createdByName {get; set;}

        /**
         * @description Getters and Setters for the property createdDate
         */
        @AuraEnabled
        public String createdDate {get; set;}

        /**
         * @description Getters and Setters for the property comments
         */
        @AuraEnabled
        public String comments {get; set;}

        /**
         * @description Getters and Setters for the property accountName
         */
        @AuraEnabled
        public String accountName {get; set;}       
    }
    
}
