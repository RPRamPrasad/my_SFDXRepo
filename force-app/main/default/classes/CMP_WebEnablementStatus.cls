/****************************************************************************************
Name: CMP_WebEnablementStatus
Copyright © State Farm
=========================================================================================
Purpose:
-------
@description This is the controller class to account Web enablement status lightning component.

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             kdvb		         	  1/14/2019              2019 R1 Release

******************************************************************************************/
public with sharing class CMP_WebEnablementStatus {
	
	@TestVisible public static List<WebEnablement__x> mockedWebEnablementObj = new List<WebEnablement__x>();
	@TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
	
	private static final String LINK_ID = 'LinkId';
    private static final String SETUP_ACCESS_LINK_ID = '54';
    private static final String ACCOUNT_ID_PARAM = 'accountId';
	
	private static final String NOT_STARTED_STATUS = 'NOT STARTED';
	private static final String CLASS_NAME = 'CMP_WebEnablementStatus';
	private static final String METHOD_NAME = 'fetchWebEnablementStatus';
	private static final Map<String, String> WEBENABLEDSTATUSMAP = new Map<String, String> {'NOT STARTED' => 'Not Started', 'IN PROGRESS' => 'In Progress', 
                                                                    'COMPLETE' => 'Complete'};
	
	/** 
	* @description wrapper class to store the web enablement response.
	*/
    public with sharing class WebEnablementResponse {
        @AuraEnabled
        public String status = '';
        @AuraEnabled
        public Boolean isStatusNotStarted = false;
        @AuraEnabled
        public Boolean isQuerySuccess= false;
    }
	
	/**
	* @description method to query the ODATA WebEnablement__x object and get the Web Enablement Status
	* @param  clientId
	* @return WebEnablementResponse
	*/
    @AuraEnabled
    public static WebEnablementResponse fetchWebEnablementStatus(String clientId) {
		WebEnablementResponse retObj = new WebEnablementResponse();
    	try{
	    	WebEnablement__x webEObj = retrieveWebEnablementStatus(clientId);
	    	retObj.status = WEBENABLEDSTATUSMAP.get(webEObj.webEnabledStatus__c.toUpperCase());
	    	retObj.isQuerySuccess = true;
	    	if(retObj.status.equalsIgnoreCase(NOT_STARTED_STATUS) && !UTIL_LtngProfileDataAccess.getProfileName().equalsIgnoreCase(Label.CL_SALESLDR_PROFILE) ) {
				retObj.isStatusNotStarted = true;
			}
    	}
    	catch(Exception exp){
    		LoggingService.logHandledException(exp, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
    		retObj.isQuerySuccess = false;
    	}
		return retObj;
    }
	
	/**
	* @description get redirect url
	* @param  accountId
	* @return String
	*/
    @AuraEnabled
    public static String getRedirectUrl(String accountId) {
    	PageReference redirectPage = Page.VFP_ExternalLink;
    	redirectPage.getParameters().put(LINK_ID, SETUP_ACCESS_LINK_ID);
    	redirectPage.getParameters().put(ACCOUNT_ID_PARAM, accountId);
		return redirectPage.getUrl();
    }
	
	/**
	* @description get toggle status
	* @return String
	*/
    @AuraEnabled
    public static Boolean getToggleStatus() {
    	return toggleContext.isActive(UTIL_Toggles.CUSTOMER_WEB_ENABLEMENT);
    }
    
    private static WebEnablement__x retrieveWebEnablementStatus(String clientId) {
    	List<WebEnablement__x> retObj = new List<WebEnablement__x>();
    	if(Test.isRunningTest()) {
            retObj = mockedWebEnablementObj;
        } else {
            retObj = UTIL_LtngODataAccess.retrieveWebEnablementStatus(clientId);
        }
        return retObj.get(0);
    } 

	/**
	* @description get profile name
	* @return String
	*/
	@AuraEnabled
	public static string getProfileName(){
		return UTIL_LtngProfileDataAccess.getProfileName();
	}
}
