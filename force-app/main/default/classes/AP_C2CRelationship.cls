/**
* @author: Stark
* @owner: Stark
* @name: AP_C2CRelationship
* @createdDate: 09/02/2020
* @description  The class will extract all Group memebers and Customer2Customer relationships of Customer for FSC household
* @version 1.0
*/
public with sharing class AP_C2CRelationship {
    private static final String CLASS_NAME='AP_C2CRelationship';
    private static final String FSC_RELATIONSHIP_MANAGEMENT = 'Agency_User';

/**
* @description This method determines if recordId is for an Account or Household
* @name : determineAccountOrhousehold
* @param recordId : Account Id or Household Id
* @return String : value from Primary_Household__pc
*/ 
    @AuraEnabled(cacheable=true)
    public static String determineAccountOrhousehold(String recordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', recordId, Account.class);
        List<Account> primaryHHId = Security.stripInaccessible(AccessType.READABLE, [Select Primary_Household__pc from Account where id =:recordId limit 1]).getRecords();
        return primaryHHId.get(0).Primary_Household__pc;
    }
    
/**
* @description This method gets household members from the household Id passed
* @name : findHouseholdMembers
* @param hhId : household Id
* @return List<Contact> : list of household members
*/
    @AuraEnabled(cacheable=true)
    public static List<Contact> findHouseholdMembers(String hhId) {
        List <Contact> hhContacts;
        List <Contact> orderedconts = new List<Contact>();
        Map <Id, Contact> mapIdToContacts = new Map<Id, Contact>();
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhId, Account.class);
  
        try{
            hhContacts = Security.stripInaccessible(AccessType.READABLE,[
                                                                         SELECT Id, Name, Account.Name, Gender__c, AccountId
                                                                         FROM Contact
                                                                         WHERE
                                                                                Id IN (
                                                                                    SELECT ContactId
                                                                                    FROM AccountContactRelation
                                                                                    WHERE AccountId = :String.escapeSingleQuotes(hhId) AND IsActive = true AND FinServ__PrimaryGroup__c = true
                                                                                )
                                                                        ]).getRecords();
            // If Default Session Cache has a value for this HH then that is 
            // the person that was searched for so put that person as the first in the list            
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.household');
            String custId = (String)sessionPart.get(hhId);

            if (custId != null && !hhContacts.isEmpty()){
                for(Contact singleContact : hhContacts){
                    mapIdToContacts.put(singleContact.AccountId, singleContact);
                }
                Contact cont = mapIdToContacts.remove(custId);
                orderedconts.add(cont);
                orderedconts.addAll(mapIdToContacts.values());
            }
            else if (!hhContacts.isEmpty()) {
                orderedconts = hhContacts.clone(); 
            }
                           
        }catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME,'findHouseholdMembers', System.LoggingLevel.ERROR);
        }  
        return orderedconts;
    }  
    
/**
* @description This method is used to get relationship record
* @name : findHouseholdC2C
* @param accId
* @param hhId
* @return List<Relationship__c> : list of relationship records of household members
*/

    @AuraEnabled(cacheable=true)
    public static List<Relationship__c> findHouseholdC2C(String accId, String hhId) {
        List<Relationship__c> c2cRelatioship = new List<Relationship__c>();
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', accId, Account.class);
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhId, Account.class);
        
        try{
            c2cRelatioship =  Security.stripInaccessible(AccessType.READABLE,
                                                         [
                                                             SELECT Id, AccountTwo__r.Name,AccountOne__r.IsNotShareable__pc,AccountOne__r.Name, RelationshipType__c, 
                                                                    Gender__c
                                                             FROM Relationship__c
                                                             WHERE AccountTwo__r.id = :String.escapeSingleQuotes(accId) AND AccountOne__r.Primary_Household__pc =:String.escapeSingleQuotes(hhId)
                                                         ]
                                                        ).getRecords();
        }catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME,'findHouseholdC2C', System.LoggingLevel.ERROR);
        }  
        return c2cRelatioship;
    }
    
    /**
     *   @description Determine User Context
     *   @return boolean
     */
    @AuraEnabled(cacheable=true)
    public static boolean determineUserContext(){
        if(FeatureManagement.checkPermission(FSC_RELATIONSHIP_MANAGEMENT)) {           
            return true;
        }else{
            return false;           
        }
    }
}