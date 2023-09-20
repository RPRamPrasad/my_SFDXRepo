/****************************************************************************************
Name: UTIL_CustomSObjectIterable
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is a custom iterator class to paginate list of sObject records

Team: Choo Choo
@description UTIL Custom SObject Iterable
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                3/1/2018             2018 R2 Release

******************************************************************************************/
public with sharing class UTIL_CustomSObjectIterable implements Iterator<List<SObject>> {

	private list<SObject> innerList {get; set;}
   	private Integer i {get; set;} 
   	private Integer pageSize {get; set;}

    /**
     * @description constructor - UTIL_CustomSObjectIterable
     * @param lstAccWr
     * @param pageCount
     */
	public UTIL_CustomSObjectIterable(List<SObject> lstAccWr, Integer pageCount) {
    	innerList = new list<SObject>(); 
       	innerList = lstAccWr;
       	pageSize = pageCount;
       	i = 0; 
	}
	
    /**
     * @description Getter method of the property pageNumber
     * @return Integer
     */
	public Integer pageNumber {
        get {
        	return Integer.ValueOf(Math.ceil(decimal.valueOf(i)/decimal.valueOf(pageSize)));
        }
        set; 
    }
    
    /**
     * @description Getter method of the property totalPages
     * @return Integer
     */
    public Integer totalPages {
    	get {
    		return Integer.ValueOf(Math.ceil(decimal.valueOf(innerList.size())/decimal.valueOf(pageSize)));
    	}
    	set;
    }   

    /**
     * @description Has Next
     * @return Boolean
     */
    public Boolean hasNext() {
    	Boolean returnBoolean = true; 
		if(i >= innerList.size()) {
			returnBoolean = false; 
       	} 
        return returnBoolean;
	} 
   
    /**
     * @description Has Previous
     * @return Boolean
     */
	public Boolean hasPrevious() { 
   		Boolean returnBoolean = true;
    	if(i <= pageSize) {
        	returnBoolean = false; 
       	} 
       	return returnBoolean;
   	}
   	
    /**
     * @description Go To Last
     * @return List<SObject>
     */
   	public list<SObject> goToLast(){
   		i= (totalPages - 1)* pageSize;
   		return next();
   	}
   	
    /**
     * @description Go To First
     * @return List<SObject>
     */
   	public list<SObject> goToFirst(){
   		i= 0;
   		return next();
   	}   

    /**
     * @description Next
     * @return List<SObject>
     */
    public list<SObject> next() {       
        list<SObject> listRequested = new list<SObject>(); 
        integer startNumber;
        integer size = innerList.size();
        if(hasNext()) {  
            if(size <= (i + pageSize)) {
                startNumber = i;
                i = size;
            }
            else {
                i = (i + pageSize);
                startNumber = (i - pageSize);
            }
            for(integer start = startNumber; start < i; start++) {
                listRequested.add(innerList[start]);
            }
        } 
        return listRequested;
    } 
   
    /**
     * @description Previous
     * @return List<SObject>
     */
    public list<SObject> previous() {      
        list<SObject> listRequested = new list<SObject>(); 
        integer size = innerList.size(); 
        if(i == size) {
            if(math.mod(size, pageSize) > 0) {    
                i = size - math.mod(size, pageSize);
            }
            else {
                i = (size - pageSize);
            } 
        }
        else {
            i = (i - pageSize);
        }
        for(integer start = (i - pageSize); start < i; ++start) {
            listRequested.add(innerList[start]);
        } 
        return listRequested;
    }
}