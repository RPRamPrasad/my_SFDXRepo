/****************************************************************************************
Name: VFC_CustomerGroupEventList
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is the controller class to Customer Group open event and event history related list VF component.

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                3/5/2018             2018 R2 Release

******************************************************************************************/

/**
 * @description VFC Customer Group Event List
 */
public with sharing class VFC_CustomerGroupEventList extends UTIL_CustomerGroupActivityList {
	
	private List<Id> groupCustomerIdList = new List<Id>();
    private DateTime currentTime = System.now();
    
	private static final String OPEN_EVENT_TYPE = 'OpenEvents';
	private static final String QUERY_PREFIX = 'SELECT Id, WhoId, Who.Name, WhatId, What.Name, Subject, OwnerId, Owner.Name, ActivityDateTime, LastModifiedDate FROM Event WHERE AccountId IN :groupCustomerIdList ';
	private static final String OPEN_EVENT_CLAUSE = 'AND ActivityDateTime < :currentTime ';
	private static final String CLOSED_EVENT_CLAUSE = 'AND ActivityDateTime >= :currentTime ';
	private static final String DEFAULT_INIT_LIST_SORT_COLUMN = 'ActivityDateTime'; 
    
	private List<Event> eventFullList {get; set;}
	private Boolean isOpenEventList {get; set;}   
	
	/**
	 * @description VFC Customer Group Event List
	 *
	 * Default constructor
	 */
    public VFC_CustomerGroupEventList() {
        eventFullList = new List<Event>();
        isOpenEventList = true;
    }  
    
	/** 
	 * @description Current Page Event List
	 * @return List<Event>
	 * List of Event to be displayed on the UI
	*/    
	public List<Event> currentPageEventList {
		get {
			if(eventFullList.isEmpty()) {
				init();			
			}
			return this.currentPageEventList;
    	}
    	set; 
	} 
	
	//init method
	private void init() {
		custGroup = [SELECT Id, (Select Customer__c From CustomerGroupings__r) FROM CustomerGroup__c WHERE Id = :custGroup.Id LIMIT 1];
        for(CustomerGroupMember__c groupMember : custGroup.CustomerGroupings__r) {
            groupCustomerIdList.add(groupMember.Customer__c);
        }
        if(OPEN_EVENT_TYPE.equalsIgnoreCase(sObjectType)) {
        	isOpenEventList = false;	
        }
        sortColumn = DEFAULT_INIT_LIST_SORT_COLUMN; 
    	sortColumnInPlace = DEFAULT_INIT_LIST_SORT_COLUMN;
        if(OPEN_EVENT_TYPE.equalsIgnoreCase(sObjectType)) {
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
		String queryString = QUERY_PREFIX;
		if(isOpenEventList) {
			queryString += OPEN_EVENT_CLAUSE + SORT_BY_CLAUSE;
		}
		else {
			queryString += CLOSED_EVENT_CLAUSE + SORT_BY_CLAUSE;	
		}
		if(isAscendingSort) {
			queryString += sortColumn + ASC_SORT + LIMIT_CLAUSE + queryLimit;	
		} 
		else {
			queryString += sortColumn + DESC_SORT + UTIL_CreateCustomerConstants.NULLS_LAST + UTIL_CreateCustomerConstants.BLANK_SPACE + LIMIT_CLAUSE + queryLimit;	
		}
		eventFullList = (List<Event>) Database.query(String.escapeSingleQuotes(queryString));
		iteratorUtil = new UTIL_CustomSObjectIterable(eventFullList, pageCount);
		next();
	}
	
	/**
	 * @description Next
	 */
	public void next() {
    	currentPageEventList = fetchNext();
	}
        
	/**
	 * @description Previous
	 */
    public void previous() {
        currentPageEventList = fetchPrevious();
    }
    
	/**
	 * @description Go To First
	 */
    public void gotoFirst() {
    	currentPageEventList = fetchFirst();	
    }
    
	/**
	 * @description Go To Last
	 */
    public void gotoLast() {
    	currentPageEventList = fetchLast();	
    }
}