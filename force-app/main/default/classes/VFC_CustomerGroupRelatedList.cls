/****************************************************************************************
Name: VFC_CustomerGroupRelatedList
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is the controller class to Customer Group Related List VF component.

Team: Choo Choo
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                2/13/2018             2018 R4 Release

******************************************************************************************/
/**
 * @description VFC_CustomerGroupRelatedList
 */
public with sharing class VFC_CustomerGroupRelatedList {

    private List<Id> groupCustomerIdList = new List<Id>();
    private Integer pageCount = 5;
    private static final String S1_THEME = 'Theme4t';
    private static final String SELECT_QUERY_STRING = 'SELECT ';
    private static final String COMMA = ', ';
    private static final String BLANK_SPACE = '';
    private static final String EMPTY_SPACE = ' ';
    private static final String FROM_QUERY_STRING = 'FROM ';
    private static final String LIMIT_QUERY_STRING = 'LIMIT ';
    private static final String WHERE_QUERY_STRING = 'WHERE ';
    private static final String IN_CLAUSE = 'In :groupCustomerIdList ';
    private static final String CASE_TYPE = 'Case';
    private static final String OPP_TYPE = 'Opportunity';
    private static final String ACC_NOTES_TYPE = 'Account_Note__c';
    private static final String ORDER_BY = 'ORDER BY ';
    private static final String CASE_DEFAULT_SORT_FIELD = 'CreatedDate';
    private static final String DESC_SORT = ' DESC ';
    private static final String ASC_SORT = ' ASC ';
    private static final String OPP_ASSIGNED_TO = 'Assigned_To__r.Name';

    /**
     * @description sObjectType
     */
    public String sObjectType {get; set;}

    /**
     * @description isSortingReqd
     */
    public Boolean isSortingReqd {get; set;}

    /**
     * @description isPaginationReqd
     */
    public Boolean isPaginationReqd {get; set;}

    /**
     * @description stdSetCtr
     */
    public ApexPages.StandardSetController stdSetCtr {get; set;}

    /**
     * @description custGroup
     */
    public CustomerGroup__c custGroup {get; set;}

    /**
     * @description columnMdtList
     */
    public List<CustomerGroupRelatedListColumn__mdt> columnMdtList {get; set;}

    /**
     * @description totalPages
     */
    public Integer totalPages {get; set;}

    private Integer setPageNumberTo {get; set;}
    private String queryPrefix {get; set;}
    private String querySuffix {get; set;}

    /**
     * @description isS1Request
     */
    public Boolean isS1Request {get; set;}

    /**
     * @description sortColumn
     */
    public String sortColumn {get; set;}

    /**
     * @description isAscendingSort
     */
    public Boolean isAscendingSort {get; set;}
    private String sortColumnInPlace {get; set;}
    
    /**
     * @description custInContext
     */
    public Id custInContext {get; set;}

    private String accountColumnName {get; set;}
    private String logggdInProfileName {get; set;}

    //Default constructor
    /**
     * @description VFC_CustomerGroupRelatedList
     */
    public VFC_CustomerGroupRelatedList() {
        columnMdtList = new List<CustomerGroupRelatedListColumn__mdt>();
        isS1Request = false;
        if(S1_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())) {
            isS1Request = true;
        }
        totalPages = 1;
        setPageNumberTo = 1;
        logggdInProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Profile.Name;
    }

    //List of related records to be displayed in the component
    /**
     * @description relatedLists
     */
    public List<SObject> relatedLists {
        get {
            if(stdSetCtr == null) {
            	init();
            }
            return (List<SObject>) stdSetCtr.getRecords();
        }
        set;
    }

    //To get the current Page Number displayed
    /**
     * @description pageNumber
     */
    public Integer pageNumber {
        get {
            if(stdSetCtr!=null) {
                return Integer.valueOf(stdSetCtr.getPageNumber());
            }
            else {
                return null;
            }
        }
        set;
    }

    //init method to set page context and initialize instance variables with values
    private void init() {

        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, (Select Customer__c From CustomerGroupings__r) FROM CustomerGroup__c WHERE Id = :custGroup.Id LIMIT 1]);
        custGroup = (CustomerGroup__c)securityDecision.getRecords()[0];
        for(CustomerGroupMember__c groupMember : custGroup.CustomerGroupings__r) {
            groupCustomerIdList.add(groupMember.Customer__c);
        }
        if(isPaginationReqd) {
            pageCount = 25;
        }
        initializeQueryString();
        initializeDefaultSorting();
        getRelatedListToDisplay();
    }

    //Initializing default sorting
    private void initializeDefaultSorting() {
    	isSortingReqd = true;
    	if(ACC_NOTES_TYPE.equalsIgnoreCase(sObjectType) || CASE_TYPE.equalsIgnoreCase(sObjectType)) {
    		sortColumn = CASE_DEFAULT_SORT_FIELD;
    		sortColumnInPlace = CASE_DEFAULT_SORT_FIELD;
    		isAscendingSort = false;
    	}
    	else {
    		sortColumn = accountColumnName;
    		sortColumnInPlace = accountColumnName;
    		isAscendingSort = true;
    	}
    }

    //Method to Sort by Column
    /**
     * @description sortDataByColumn
     */
    public void sortDataByColumn() {
        setPageNumberTo = 1;
        if(String.isNotEmpty(sortColumnInPlace) && sortColumn.equals(sortColumnInPlace)){
            isAscendingSort = !isAscendingSort;
        }
        else {
            isAscendingSort = true;
        }
        getRelatedListToDisplay();
    }

    //Forming retreive SOQL
    private void initializeQueryString() {
        isAscendingSort=true;
        sortColumn=UTIL_CreateCustomerConstants.EMPTY_STRING;
        queryPrefix = SELECT_QUERY_STRING;
        String accountApiName = BLANK_SPACE;
        columnMdtList = [SELECT ColumnLabel__c, ColumnAPIName__c, ColumnLinkAPIName__c, IsColumnLink__c, ColumnIndex__c, IsAccountNameColumn__c FROM CustomerGroupRelatedListColumn__mdt WHERE SObjectType__c = :sObjectType WITH SECURITY_ENFORCED ORDER BY ColumnIndex__c ASC];
        removeOppAssignedToForSalesLeader();
        for(CustomerGroupRelatedListColumn__mdt columnMdt : columnMdtList) {
			queryPrefix += columnMdt.ColumnAPIName__c + COMMA;
            if(columnMdt.IsColumnLink__c) {
                queryPrefix += columnMdt.ColumnLinkAPIName__c + COMMA;
            }
            if(columnMdt.IsAccountNameColumn__c) {
                accountApiName = columnMdt.ColumnLinkAPIName__c;
                accountColumnName = columnMdt.ColumnAPIName__c;
            }
    	}
        queryPrefix = queryPrefix.removeEnd(COMMA);
        queryPrefix += EMPTY_SPACE + FROM_QUERY_STRING + sObjectType + EMPTY_SPACE + WHERE_QUERY_STRING + accountApiName + EMPTY_SPACE + IN_CLAUSE;
    }

    private void removeOppAssignedToForSalesLeader() {
    	Set<CustomerGroupRelatedListColumn__mdt> columnMdtSet = new Set<CustomerGroupRelatedListColumn__mdt>(columnMdtList);
    	for(CustomerGroupRelatedListColumn__mdt columnMdt : columnMdtSet) {
    		if(System.Label.CL_SALESLDR_PROFILE.equalsIgnoreCase(logggdInProfileName) && OPP_TYPE.equalsIgnoreCase(sObjectType)
            	&& OPP_ASSIGNED_TO.equalsIgnoreCase(columnMdt.ColumnAPIName__c)) {
            		columnMdtSet.remove(columnMdt);
            	}
    	}
    	columnMdtList = new List<CustomerGroupRelatedListColumn__mdt>(columnMdtSet);
    }

    //Method to query the required related list records according the page selection(s)
    private void getRelatedListToDisplay() {
        populateSortQuerySuffix();
        stdSetCtr = new ApexPages.StandardSetController(Database.getQueryLocator(String.escapeSingleQuotes(queryPrefix + querySuffix)));
        stdSetCtr.setPageSize(pageCount);
        stdSetCtr.setPageNumber(setPageNumberTo);
        decimal totalDecimalPage = (decimal.valueOf(stdSetCtr.getResultSize())/pageCount).setScale(2);
        totalPages = Integer.valueOf(totalDecimalPage.round(system.RoundingMode.CEILING));
    }

    //Utility method to populate query suffix with order by clause on soql
    private void populateSortQuerySuffix() {
        querySuffix = BLANK_SPACE;
        if(!isSortingReqd) {
            if(CASE_TYPE.equalsIgnoreCase(sObjectType) || ACC_NOTES_TYPE.equalsIgnoreCase(sObjectType)) {
                querySuffix = ORDER_BY + CASE_DEFAULT_SORT_FIELD + DESC_SORT + LIMIT_QUERY_STRING + pageCount;
            }
            else {
            	querySuffix = ORDER_BY + accountColumnName + ASC_SORT + LIMIT_QUERY_STRING + pageCount;
            }
        }
        else {
            if(isAscendingSort && String.isNotBlank(sortColumn)) {
                querySuffix = ORDER_BY + sortColumn + ASC_SORT + UTIL_CreateCustomerConstants.BLANK_SPACE + LIMIT_QUERY_STRING + 10000;
            }
            else if(!isAscendingSort && String.isNotBlank(sortColumn)) {
                querySuffix = ORDER_BY + sortColumn + DESC_SORT + UTIL_CreateCustomerConstants.NULLS_LAST + UTIL_CreateCustomerConstants.BLANK_SPACE + LIMIT_QUERY_STRING + 10000;
            }
            sortColumnInPlace = sortColumn;
        }
    }

}