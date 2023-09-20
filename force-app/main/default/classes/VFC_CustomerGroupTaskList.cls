/****************************************************************************************
Name: VFC_CustomerGroupTaskList
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is the controller class to Customer Group open task and task history related list VF component.

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                3/1/2018             2018 R2 Release

******************************************************************************************/

/**
 * @description VFC Customer Group Task List
 */
public with sharing class VFC_CustomerGroupTaskList extends UTIL_CustomerGroupActivityList {

    private List<Id> groupCustomerIdList = new List<Id>();
    
	private static final String OPEN_TASK_TYPE = 'OpenTasks';
	private static final String QUERY_PREFIX = 'SELECT Id, WhoId, Who.Name, WhatId, What.Name, Subject, OwnerId, Owner.Name, Status, ActivityDate, Priority, LastModifiedDate FROM Task WHERE IsClosed = :isOpenTaskList AND AccountId IN :groupCustomerIdList ';
	private static final String DEFAULT_INIT_LIST_SORT_COLUMN = 'ActivityDate'; 
    
	private List<Task> taskFullList {get; set;}
	private Boolean isOpenTaskList {get; set;}   
	
	/**
	 * @description VFC Customer Group Task List
	 * Default constructor
	 */
    public VFC_CustomerGroupTaskList() {
        taskFullList = new List<Task>();
        isOpenTaskList = true;
    }  
    
	/**
	 * @description CUrrent Page Task List
	 * @return List<Task>
	 * List of task to be displayed on the UI
	 */
	public List<Task> currentPageTaskList {
		get {
			if(taskFullList.isEmpty()) {
				init();			
			}
			return this.currentPageTaskList;
    	}
    	set; 
	} 
	
	//init method
	private void init() {
		custGroup = [SELECT Id, (Select Customer__c From CustomerGroupings__r) FROM CustomerGroup__c WHERE Id = :custGroup.Id LIMIT 1];
        for(CustomerGroupMember__c groupMember : custGroup.CustomerGroupings__r) {
            groupCustomerIdList.add(groupMember.Customer__c);
        }
        if(OPEN_TASK_TYPE.equalsIgnoreCase(sObjectType)) {
        	isOpenTaskList = false;	
        }
        sortColumn = DEFAULT_INIT_LIST_SORT_COLUMN; 
    	sortColumnInPlace = DEFAULT_INIT_LIST_SORT_COLUMN;
        if(OPEN_TASK_TYPE.equalsIgnoreCase(sObjectType)) {
        	isAscendingSort = true;
        }
        else {
        	isAscendingSort = false;
        }
        if(isPaginationReqd) {
            pageCount = 25;
            queryLimit = 10000;
        }
        fetchActivityList();	
	} 
	
	//utiity method to finalize the query and fetch the records
	private void fetchActivityList() {
		String queryString = QUERY_PREFIX + SORT_BY_CLAUSE;
		if(isAscendingSort) {
			queryString += sortColumn + ASC_SORT + LIMIT_CLAUSE + queryLimit;	
		} 
		else {
			queryString += sortColumn + DESC_SORT + UTIL_CreateCustomerConstants.NULLS_LAST + UTIL_CreateCustomerConstants.BLANK_SPACE + LIMIT_CLAUSE + queryLimit;	
		}
		taskFullList = (List<Task>) Database.query(String.escapeSingleQuotes(queryString));
		iteratorUtil = new UTIL_CustomSObjectIterable(taskFullList, pageCount);
		next();
	}
	
	/**
	 * @description Next
	 */
	public void next() {
    	currentPageTaskList = fetchNext();
	}

	/**
	 * @description Previous
	 */ 
    public void previous() {
        currentPageTaskList = fetchPrevious();
    }
    
	/**
	 * @description Go To First
	 */
    public void gotoFirst() {
    	currentPageTaskList = fetchFirst();	
    }
    
	/**
	 * @description Go To Last
	 */
    public void gotoLast() {
    	currentPageTaskList = fetchLast();	
    }
}