/**
* @name CustomerGroupRelatedListController
* @author  Poseidon
* @createdDate 09/10/2018
* @description Controller used by the CustomerGroupRelatedList component to fetch different objects
*/
public with sharing class CustomerGroupRelatedListController {

    /**
     * @description Fetch Data
     * @param groupRecordId 
     * @param relatedListType 
     * @param accountId 
     * @param queryLimit 
     * @param isHHOnAccountPage
     * @return DataTableResponse
     */
    @AuraEnabled(cacheable=true)
    public static DataTableResponse fetchData(String groupRecordId, String relatedListType, String accountId, Integer queryLimit, boolean isHHOnAccountPage) {
        
        DataTableResponse response = null;
        Boolean isResponseAssigned = false;

        accountId = String.escapeSingleQuotes(accountId);

        /*
            The accountId will be null if fetchData is called from the account page (instead the groupRecordId is actually the accountId).
            If this is the case we retrieve the groupRecordId based on the accountId that was sent in the groupRecordId parameter.
        */
        if(isHHOnAccountPage){
            accountId = String.escapeSingleQuotes(groupRecordId);
            Id newAccountId = Id.valueOf(String.escapeSingleQuotes(accountId));
            groupRecordId =	UTIL_GroupId.getCustomerGroupDetails(newAccountId);
        }
        
        // Return list of Open or Closed Tasks from UTIL class
        if ('Open Tasks'.equals(relatedListType) || 'Task History'.equals(relatedListType)) {
            response = UTIL_CustomerGroupTaskList.fetchData(String.escapeSingleQuotes(groupRecordId), relatedListType, queryLimit);
            isResponseAssigned = true;
        }else if(isResponseAssigned == false){
            FetchDataWrapper dataWrapper = new FetchDataWrapper();
            dataWrapper.groupRecordId  = groupRecordId;
            dataWrapper.relatedListType = relatedListType;
            dataWrapper.accountId = accountId;
            dataWrapper.queryLimit = queryLimit;

            response = evaluateRelatedListType(dataWrapper);
        }

        return response;
    }    

    /**
     * @description Evaluate RelatedList Type
     * @param dataWrapper
     * @return DataTableResponse
     */
    public static DataTableResponse evaluateRelatedListType(FetchDataWrapper dataWrapper){

        String groupRecordId = dataWrapper.groupRecordId;
        String relatedListType = dataWrapper.relatedListType;
        String accountId = dataWrapper.accountId;
        Integer queryLimit = dataWrapper.queryLimit;
        DataTableResponse response = null;

        if ('Open Events'.equals(relatedListType) || 'Event History'.equals(relatedListType)) {
            response = UTIL_CustomerGroupEventList.fetchData(String.escapeSingleQuotes(groupRecordId), relatedListType, queryLimit);
        } else if ('Cases'.equals(relatedListType)){
            response = UTIL_CustomerGroupCaseList.fetchData(String.escapeSingleQuotes(groupRecordId), relatedListType, queryLimit);
        } else if ('Opportunities'.equals(relatedListType)) {
            response = UTIL_CustomerGroupOpportunityList.fetchData(String.escapeSingleQuotes(groupRecordId), relatedListType, queryLimit);
        } else if('Agent'.equals(relatedListType)) {
            UTIL_CustomerGroupAgentList.FetchDataWrapper dataWrap = new UTIL_CustomerGroupAgentList.FetchDataWrapper();
            dataWrap.groupRecordId = String.escapeSingleQuotes(groupRecordId);
            dataWrap.relatedListType = relatedListType;
            dataWrap.accountId = accountId;
            dataWrap.queryLimit = queryLimit;

            response = UTIL_CustomerGroupAgentList.fetchData(dataWrap);
        } else if ('Account Notes'.equals(relatedListType)) {
            response = UTIL_CustomerGroupAccountNoteList.fetchData(String.escapeSingleQuotes(groupRecordId), relatedListType, queryLimit);
        } else if ('Group Members'.equals(relatedListType)) {
            UTIL_CustomerGroupMemberDetail.FetchDataWrapper dataWrap = new UTIL_CustomerGroupMemberDetail.FetchDataWrapper();
            dataWrap.groupRecordId = String.escapeSingleQuotes(groupRecordId);
            dataWrap.relatedListType = relatedListType;
            dataWrap.accountId = accountId;
            dataWrap.queryLimit = queryLimit;

            response = UTIL_CustomerGroupMemberDetail.fetchData(dataWrap);
        }

        return response;
    }    

    /**
     * @description Group Member Update
     * @param primaryContact 
     * @param requestedMember 
     * @param groupRecordId 
     * @param queryLimit
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean groupMemberUpdate(String primaryContact, String requestedMember, String groupRecordId, Integer queryLimit) {        

        Boolean result = false;
        UTIL_CustomerGroupMemberDetail.PrimaryContactWrapper wrap = new UTIL_CustomerGroupMemberDetail.PrimaryContactWrapper();
        wrap.primaryContact = primaryContact;
        wrap.requestedMember = requestedMember;
        wrap.groupRecordId = String.escapeSingleQuotes(groupRecordId);
        wrap.queryLimit = queryLimit;

        result = UTIL_CustomerGroupMemberDetail.updatePrimaryContact(wrap);
        return result;
    }
   
    /**
     * @description Data Table Columns
     */
    // Wrapper class to hold Columns with headers
    public with sharing class DataTableColumns {

        /**
         * @description getters and setters for label 
         */
        @AuraEnabled
        public String label {get;set;}

        /**
         * @description getters and setters for fieldName 
         */
        @AuraEnabled       
        public String fieldName {get;set;}

        /**
         * @description getters and setters for type 
         */
        @AuraEnabled
        public String type {get;set;}

        /**
         * @description getters and setters for sortable
         */
        @AuraEnabled
        public boolean sortable {get; set;}

        /**
         * @description getters and setters for typeAttributes
         */
        @AuraEnabled
        public TypeAttributes typeAttributes {get; set;}
        
        // Create and set three variables label, fieldname and type as required by the lightning:datatable
        /**
         * @description Constructor DataTableColumns
         * @param label
         * @param fieldName
         * @param type
         * @param sortable
         */
        public DataTableColumns(String label, String fieldName, String type, boolean sortable) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.sortable = sortable;
            
        }
        
        /**
         * @description Constructor DataTableColumns
         * @param label
         * @param fieldName
         * @param type
         * @param sortable
         * @param urlFieldName
         */
        public DataTableColumns(String label, String fieldName, String type, boolean sortable, String urlFieldName) {
            this(label, fieldName, type, sortable);
            if (null != urlFieldName) {
                this.typeAttributes = new TypeAttributes(new Label(urlFieldName), '_self');
            }
        }
        
        /**
         * @description Constructor DataTableColumns
         * @param label
         * @param type
         * @param name
         */
        public DataTableColumns(String label, String type, String name) {
            if ('action'.equals(type)) {
                this.type = type;
                List<RowActions> rowActionsList = new List<RowActions>();
                RowActions rowActions = new RowActions(label, name);
                rowActionsList.add(rowActions);
                this.typeAttributes = new TypeAttributes(rowActionsList);
            }
        }
    }
    
    /**
     * @description Type Attributes
     */
    public with sharing class TypeAttributes {

        /**
         * @description Getters and Setters of property label
         */
        @AuraEnabled
        public Label label {get;set;}

        /**
         * @description Getters and Setters of property target
         */
        @AuraEnabled
        public String target{get; set;}

        /**
         * @description Getters and Setters of property rowActions
         */
        @AuraEnabled
        public List<RowActions> rowActions {get; set;}
        
        /**
         * @description Constructor TypeAttributes
         * @param newLabel
         * @param newTarget
         */
        public TypeAttributes(Label newLabel, String newTarget) {
            this.label = newLabel;
            this.target = newTarget;
        }
        
        /**
         * @description Constructor TypeAttributes
         * @param rowActions
         */
        public TypeAttributes(List<RowActions> rowActions) {
            this.rowActions = rowActions;
        }
    }
    
    /**
     * @description Label
     */
    public with sharing class Label {

        /**
         * @description Getters and Setters of property fieldName
         */
        @AuraEnabled
        public String fieldName {get; set;}
        
        /**
         * @description Constructor Label
         * @param fieldName
         */
        public Label(String fieldName) {
            this.fieldName = fieldName;
        }
    }
    
    /**
     * @description RowActions
     */
    public with sharing class RowActions {
        /**
         * @description Getters and Setters of property label
         */
        @AuraEnabled
        public String label {get; set;}

        /**
         * @description Getters and Setters of property name
         */
        @AuraEnabled
        public String name {get; set;}
        
        /**
         * @description Constructor RowActions
         * @param label
         * @param name
         */
        public RowActions(String label, String name) {
            this.label = label;
            this.name = name;
        }
    }
    
    //Wrapper class to hold response - This response is used in the lightning:datatable component
    /**
     * @description Data Table Response
     */
    public with sharing class DataTableResponse {

        /**
         * @description Getters and Setters of property lstDataTableColumns
         */
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}

        /**
         * @description Getters and Setters of property lstDataTableData
         */
        @AuraEnabled
        public List<Object> lstDataTableData {get;set;}

        /**
         * @description Getters and Setters of property icon
         */
        @AuraEnabled
        public String icon {get;set;}

        /**
         * @description Getters and Setters of property externalId
         */
        @AuraEnabled
        public String externalId {get; set;}

        /**
         * @description Getters and Setters of property primaryContact
         */
        @AuraEnabled
        public String primaryContact {get; set;}

        /**
         * @description Getters and Setters of property customerGroupId
         */
        @AuraEnabled
        public String customerGroupId {get; set;}

        /**
         * @description Getters and Setters of property currentUser
         */
        @AuraEnabled
        public User currentUser {get; set;}
        
        /**
         * @description Data Table Response
         */
        public DataTableResponse() {
            lstDataTableColumns = new List<DataTableColumns>();
            lstDataTableData = new List<Object>();
        }
    }

    /**
     * @description Group Member Update Wrapper
     */
    public class GroupMemberUpdateWrapper{
        public String primaryContact;
        public String requestedMember;
        public String groupRecordId;
        public Integer queryLimit;
    }

        /**
     * @description Fetch Data Wrapper
     */
    public class FetchDataWrapper{
        public String groupRecordId;
        public String relatedListType;
        public String accountId;
        public Integer queryLimit;
        public boolean isHHOnAccountPage;
    }
}