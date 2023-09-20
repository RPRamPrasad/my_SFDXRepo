/**
  * @author: Targaryen
  * @owner: Targaryen
  * @name: AP_C2CRelationshipTrigger
  * @createdDate: 07/30/2020
  * @description The class will execute business logics when C2CRelationship trigger fires.
  * @version 1.0
  */


public with sharing class AP_C2CRelationshipTrigger {
    
    /**
    * @description 
    * @author Targaryen.SFDoc | 07-30-2020
    * @param newC2CRelationshipList 
    **/
    public static void processC2CRelationship(List<Relationship__c> newC2CRelationshipList){
       List<Id> customerIds = new List<Id>();
       Map<Id,Id> customerIdToHouseholdIdMap = new Map<Id,Id>();
        
       customerIds = getCustomerIds(newC2CRelationshipList);
       List<Account> accountList = Security.stripInaccessible(AccessType.READABLE,
                                                              [SELECT Id, Primary_Household__pc FROM Account where id IN :customerIds]).getRecords();
      
       buildCustomerToHouseholdIdMap(accountList,customerIdToHouseholdIdMap);
        
        for(Relationship__c singleRelationship:newC2CRelationshipList){
            singleRelationship.Primary_Household__c = customerIdToHouseholdIdMap.get(singleRelationship.AccountTwo__c);
        } 
    }
    
    /**
    * @description The method will execute to get list of customer ids
    * @author Targaryen.SFDoc | 07-30-2020 
    * @param c2cRelationshipList 
    * @return List<Id> 
    **/
    private static List<Id> getCustomerIds(List<Relationship__c> c2cRelationshipList){
        List<Id> customerIdsOnRelationship = new List<Id>();
        for (Relationship__c rel : c2cRelationshipList){
            customerIdsOnRelationship.add(rel.AccountTwo__c);
        }
        return customerIdsOnRelationship;
    }
    
    /**
    * @description The method will execute to generate map with Customer to FSC Household
    * @author Targaryen.SFDoc | 07-30-2020
    * @param accountList 
    * @param customerIdToHouseholdIdMap 
    **/
    private static void buildCustomerToHouseholdIdMap(List<Account> accountList, Map<Id, Id> customerIdToHouseholdIdMap) {
        for(Account account : accountList) {
            string primaryHouseholdIdonAccount = account.Primary_Household__pc;
            if(String.isNotEmpty(primaryHouseholdIdonAccount)){
                customerIdToHouseholdIdMap.put(account.Id, account.Primary_Household__pc);
            }
        }
    }
}