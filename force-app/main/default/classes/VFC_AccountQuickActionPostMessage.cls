/****************************************************************************************
Name: VFC_AccountQuickActionPostMessage
Copyright © State Farm
=========================================================================================
Purpose:
-------
Controller extension for Account quick action page to do post message

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             kdvb                	  03/06/2019             CIMS Embedded Screen

******************************************************************************************/ 
/**
 * @description VFC Account QuickAction Post Message
 */
public with sharing class VFC_AccountQuickActionPostMessage {
	
	private static final String CLASS_NAME = 'VFC_AccountQuickActionPostMessage';
	private static final String METHOD_NAME = 'PostMessage_Javascript';

	/**
	 * @description getters and setters of the property targetDomains
	 * @return String
	 */
	public String targetDomains {get; set;}

	/**
	 * @description getters and setters of the property exceptionMsg
	 * @return String
	 */
	public String exceptionMsg {get; set;}
	
	/**
	 * @description VFC Account QuickAction Post Message
	 * @param stdController
	 */
	public VFC_AccountQuickActionPostMessage(Apexpages.StandardController stdController){
		targetDomains = UTIL_CreateCustomerConstants.EMPTY_STRING;
		exceptionMsg = UTIL_CreateCustomerConstants.EMPTY_STRING;    
        List<CS_EnterpriseAppsTargetDomain__c> domainList = [SELECT Id, Name, isActive__c, TargetDomain__c FROM CS_EnterpriseAppsTargetDomain__c where isActive__c = true];
        for(CS_EnterpriseAppsTargetDomain__c domain : domainList){
        	if(String.isNotBlank(targetDomains)){
        		targetDomains = targetDomains + UTIL_CreateCustomerConstants.COMMA_NO_SPACE + domain.TargetDomain__c;
        	}
        	else {
        		targetDomains = domain.TargetDomain__c;
        	}
        }
	}
	
	/**
	 * @description Log JS Exception
	 */
	public void logJSException(){
		LoggingService.logHandledException(new InvalidInputException(exceptionMsg), CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
	}
}