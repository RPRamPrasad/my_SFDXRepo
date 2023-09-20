/****************************************************************************************
Name: HLPR_CustSearchResultWrapper
Copyright © State Farm
=========================================================================================
Purpose:
-------
Helper class to store the customer search results record 

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             xxxx		         xx/xx/xxxx             Initial Development
******************************************************************************************/ 

/**
 * @description HLPR Cust Search Result Wrapper
 */
public with sharing class HLPR_CustSearchResultWrapper {

	/**
	 * @description getters and setters of the property accId
	 * @return Id
	 */
	public Id accId {get; set;}

	/**
	 * @description getters and setters of the property strictMatchType
	 * @return Boolean
	 */
	public Boolean strictMatchType {get; set;}

	/**
	 * @description getters and setters of the property custName
	 * @return String
	 */
	public String custName {get; set;}

	/**
	 * @description getters and setters of the property splHandling
	 * @return String
	 */
	public String splHandling {get; set;}

	/**
	 * @description getters and setters of the property age
	 * @return Integer
	 */
	public Integer age {get; set;}

	/**
	 * @description getters and setters of the property mailingAddress
	 * @return String
	 */
	public String mailingAddress {get; set;}

	/**
	 * @description getters and setters of the property servicingAgents
	 * @return List<User>
	 */
	public List<User> servicingAgents {get; set;}
	
	/**
	 * @description HLPR Cust Search Result Wrapper
	 */
	public HLPR_CustSearchResultWrapper() {
		if(servicingAgents==null) {
			servicingAgents = new List<User>();
		}	
	}
}