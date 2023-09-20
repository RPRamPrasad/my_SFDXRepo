/**
 * @author Team Hydra
 * @description Apex Controller for Repair Assistant Provider Search
 */
public with sharing class AT_ClaimProviderSearchController {
    
    /**
     * @name: fetchStates
     * @description Queries provider information from CM_US_Canada_State__mdt
     * @param country
     * @return List<String>
     */
    @AuraEnabled(cacheable=true)
    public static List <String> fetchStates(String country) {
        SObjectAccessDecision securityDecision =  Security.stripInaccessible(AccessType.READABLE, 
            [SELECT DeveloperName, Is_State__c, Address_Type__c, Sequence_Number__c
            FROM CM_US_Canada_State__mdt 
            WHERE Is_State__c = true AND Address_Type__c = :country 
            ORDER BY Sequence_Number__c ASC
            LIMIT 100]);

        List<CM_US_Canada_State__mdt> listStates = securityDecision.getRecords();

        List<String> listOfStates = new List<String>();
        for (Integer i = 0; i < listStates.size(); i++) {
            listOfStates.add(listStates.get(i).DeveloperName);
        }
        return listOfStates;
    }
}