/****************************************************************************************
Name: UTIL_CustomerGroupActivityList
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is a utility class to Customer Group open activities and activity history related list VF components.

Team: Choo Choo
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                3/5/2018             2018 R2 Release

******************************************************************************************/
/**
 * @description UTIL Customer Group Activity List
 */
public with sharing abstract class UTIL_CustomerGroupActivityList {

    public Integer pageCount = 5;
    public Integer queryLimit = 6;
    
    private static final String S1_THEME = 'Theme4t';
    public static final String SORT_BY_CLAUSE = 'ORDER BY ';
	public static final String ASC_SORT = ' ASC ';
	public static final String DESC_SORT = ' DESC ';
	public static final String LIMIT_CLAUSE = 'LIMIT ';
    
    /**
     * @description Getters and Setters for the property sObjectType
     */
    public String sObjectType {get; set;}

    /**
     * @description Getters and Setters for the property isSortingReqd
     */
    public Boolean isSortingReqd {get; set;}

    /**
     * @description Getters and Setters for the property isPaginationReqd
     */
    public Boolean isPaginationReqd {get; set;}

    /**
     * @description Getters and Setters for the property custGroup
     */
    public CustomerGroup__c custGroup {get; set;}

    /**
     * @description Getters and Setters for the property isS1Request
     */
    public Boolean isS1Request {get; set;}

    /**
     * @description Getters and Setters for the property sortColumn
     */
    public String sortColumn {get; set;}

    /**
     * @description Getters and Setters for the property isAscendingSort
     */
    public Boolean isAscendingSort {get; set;}

    /**
     * @description Getters and Setters for the property sortColumnInPlace
     */
    public String sortColumnInPlace {get; set;}

    /**
     * @description Getters and Setters for the property custInContext
     */
    public Id custInContext {get; set;}

    /**
     * @description Getters and Setters for the property iteratorUtil
     */
    public UTIL_CustomSObjectIterable iteratorUtil {get; set;}
	
    /**
     * @description UTIL_CustomerGroupActivityList
     */
    //Default constructor
	public UTIL_CustomerGroupActivityList() {
		isS1Request = false;
        if(S1_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())) {
            isS1Request = true;
        }
	}
	
	//To get the current Page Number displayed
    /**
     * @description Getter of the property pageNumber
     */
    public Integer pageNumber {
        get {
        	Integer pageNum = 1;
        	if(iteratorUtil != null) {
        		pageNum	= iteratorUtil.pageNumber;
        	}
        	return pageNum;
        }
        set; 
    }
    
    //To get the current Page Number displayed
    /**
     * @description Getter of the property totalPages
     */
    public Integer totalPages {
        get {
        	Integer totalPageNum = 1;
        	if(iteratorUtil != null) {
        		totalPageNum	= iteratorUtil.totalPages;
        	}
        	return totalPageNum;
        }
        set; 
    }
	
	//Method to Sort by Column
    /**
     * @description Getter of the property sortDataByColumn
     */
    public void sortDataByColumn() {
        if(String.isNotEmpty(sortColumnInPlace) && sortColumn.equals(sortColumnInPlace)) {
            isAscendingSort = !isAscendingSort;
        }
        else {
            isAscendingSort = true;
        }
        sortColumnInPlace = sortColumn;
        fetchActivityList();
    }
    
    private abstract void fetchActivityList();
    
    /**
     * @description Getter of the property hasNext
     */
    public Boolean hasNext {
		get {
			return iteratorUtil.hasNext();
		}
	    set;
	}
        
    /**
     * @description Getter of the property hasPrevious
     */
	public Boolean hasPrevious {
		get {
			return iteratorUtil.hasPrevious();
        }
        set;
    }
	
    /**
     * @description Fetch Next
     * @return List<SObject>
     */
	public List<SObject> fetchNext() {
    	return iteratorUtil.next();
	}

    /**
     * @description Fetch Previous
     * @return List<SObject>
     */ 
    public List<SObject> fetchPrevious() {
        return iteratorUtil.previous();
    }
    
    /**
     * @description Fetch First
     * @return List<SObject>
     */
    public List<SObject> fetchFirst() {
    	return iteratorUtil.goToFirst();	
    }
    
    /**
     * @description Fetch Last
     * @return List<SObject>
     */
    public List<SObject> fetchLast() {
    	return iteratorUtil.goToLast();	
    }
}