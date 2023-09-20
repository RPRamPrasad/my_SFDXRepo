/****************************************************************************************
Name: UTIL_LtngODataAccess
Copyright © State Farm
=========================================================================================
Purpose:
-------
Apex Class to perform query on external objects (without FLS/Object access check) accessed by ligthning components.

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             kdvb		         	  1/15/2019              2019 R1 Release

******************************************************************************************/
/**
 * @description UTIL_LtngODataAccess
 */
public with sharing class UTIL_LtngODataAccess {
	/**
     * Description: Retrieve web enablement status from the external object
     * @description retrieveWebEnablementStatus  
     * @param clientId
     * @return List
     */
	  public static List<WebEnablement__x> retrieveWebEnablementStatus(String clientId) {
      String strClientId = String.escapeSingleQuotes(clientId);
      return Security.stripInaccessible(AccessType.READABLE, 
          [SELECT clientId__c, webEnabledStatus__c 
            FROM WebEnablement__x 
            WHERE clientId__c = :strClientId ])
          .getRecords();
    }
    
    
}