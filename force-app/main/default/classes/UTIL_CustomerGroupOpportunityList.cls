/**
  * @name UTIL_CustomerGroupOpportunityList
  * @author Poseidon
  * @createdDate 10/01/2018
  * @description Utility class to return opportunities for CustomerGroupRelatedList component
  */
public with sharing class UTIL_CustomerGroupOpportunityList {
    private static final String OBJECT_TO_QUERY = 'Opportunity';
    private static final String WHERE_CONDITION = ' WHERE Account.Id IN :groupCustomerIdList ORDER BY CloseDate DESC NULLS LAST';
    private static final Integer QUERY_LIMIT = 10;
    private static String profileName;
    private static String opportunityIcon='standard:opportunity';

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
        
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Opportunity Name', 'opportunityNameUrl', 'url', true, 'opportunityName'));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Account Name', 'accountNameUrl', 'url', true, 'accountName'));            
        
        // If logged in profile is Sales Leader (2.02), remove AssignedTo column
        profileName = retrieveProfileName();
        if (!System.Label.CL_SALESLDR_PROFILE.equalsIgnoreCase(profileName)) {
            columns.add(new CustomerGroupRelatedListController.DataTableColumns('Assigned To', 'assignedToUrl', 'url', true, 'assignedTo'));  
        }
        
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Stage', 'stageName', 'text', true));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Monthly Premium', 'monthlyPremium', 'text', true));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Close Date', 'closeDate', 'text', true));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('LOB', 'lob', 'text', true));
        
        List<Id> groupCustomerIdList = UTIL_CustomerGroupList.fetchCustomerGroupMemberIds(groupRecordId);
        if (queryLimit == 0) { queryLimit = 200;}
        List<Opportunity> opportunities = Security.stripInaccessible(
                                                  AccessType.READABLE,
                                                  [SELECT Id, Name, Account.Name, Account.Id, Assigned_To__r.Name, Assigned_To__r.Id, StageName, Monthly_Premium__c, CloseDate, LOB__c 
                                                   FROM Opportunity
                                                   WHERE Account.Id IN :groupCustomerIdList 
                                                   ORDER BY CloseDate 
                                                   DESC NULLS LAST
                                                   LIMIT :queryLimit])
                                                  .getRecords();
        List<OpportunityWrapper> opportunityWrappers = new List<OpportunityWrapper>();
        
        for (Opportunity opportunity : opportunities) {
            OpportunityWrapper opportunityWrapper = new OpportunityWrapper();
            opportunityWrapper.id = opportunity.Id;
            opportunityWrapper.opportunityName = UTIL_CustomerGroupList.handleNullString(opportunity.Name); 
            opportunityWrapper.opportunityNameUrl = UTIL_CustomerGroupList.buildLightningUrl(opportunity.Id);
            opportunityWrapper.accountName = UTIL_CustomerGroupList.handleNullString(opportunity.Account.Name);
            opportunityWrapper.accountNameUrl = UTIL_CustomerGroupList.buildLightningUrl(opportunity.AccountId);
            opportunityWrapper.assignedTo = UTIL_CustomerGroupList.handleNullString(opportunity.Assigned_To__r.Name);
           	opportunityWrapper.assignedToUrl = UTIL_CustomerGroupList.buildLightningUrl(opportunity.Assigned_To__r.Id);
            opportunityWrapper.stageName = UTIL_CustomerGroupList.handleNullString(opportunity.StageName);
            opportunityWrapper.monthlyPremium = UTIL_CustomerGroupList.handleNullDecimal(opportunity.Monthly_Premium__c);
            opportunityWrapper.closeDate = UTIL_CustomerGroupList.handleNullDate(opportunity.CloseDate);
            opportunityWrapper.lob = UTIL_CustomerGroupList.handleNullString(opportunity.LOB__c);
            opportunityWrappers.add(opportunityWrapper);
        }
        
		response.lstDataTableColumns = columns;
        response.lstDataTableData = opportunityWrappers;
        response.icon = opportunityIcon;
        
        return response;    
   	}
    
    /**
     * @description Opportunity Wrapper
     */
    public with sharing class OpportunityWrapper {

        /**
         * @description Setters and Getters of the property id
         */
        @AuraEnabled
        public String id {get; set;}

        /**
         * @description Setters and Getters of the property opportunityName
         */
        @AuraEnabled
        public String opportunityName {get; set;}

        /**
         * @description Setters and Getters of the property opportunityNameUrl
         */
        @AuraEnabled
        public String opportunityNameUrl {get; set;}

        /**
         * @description Setters and Getters of the property accountName
         */
        @AuraEnabled
        public String accountName {get; set;}

        /**
         * @description Setters and Getters of the property accountNameUrl
         */
        @AuraEnabled
        public String accountNameUrl {get; set;}

        /**
         * @description Setters and Getters of the property assignedTo
         */
        @AuraEnabled
        public String assignedTo {get; set;}

        /**
         * @description Setters and Getters of the property assignedToUrl
         */
        @AuraEnabled
        public String assignedToUrl {get; set;}

        /**
         * @description Setters and Getters of the property stageName
         */
        @AuraEnabled
        public String stageName {get; set;}

        /**
         * @description Setters and Getters of the property monthlyPremium
         */
        @AuraEnabled
        public String monthlyPremium {get; set;}

        /**
         * @description Setters and Getters of the property closeDate
         */
        @AuraEnabled
        public String closeDate {get; set;}

        /**
         * @description Setters and Getters of the property lob
         */
        @AuraEnabled
        public String lob {get; set;}
    }
    
    private static String retrieveProfileName() {
        return UTIL_LtngProfileDataAccess.getProfileName();
    }
}