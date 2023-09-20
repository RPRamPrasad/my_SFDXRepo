/**
 * @Author: Team Stark
 * @owner: Team Targaryen
 * @description : This class will add Household Id into AccountNotes object on Account Notes before insert.
 * @createdDate: 05/11/2020
 * @version 1.0
 */

public with sharing class AP_AccountNotesHandler {
    /**
      * @description : This method will get the Household Id from Account and add into AccountNotes object 
      * @param accNotes
      */
    public static void updateAccount(List<Account_Note__c> accNotes) {
         Map<Id, String> customerToHouseholdIdMap = new Map<Id, String>();
         List<Id> customerIds = getCustomerIds(accNotes);
         List<Account> accountList =  Security.stripInaccessible(AccessType.READABLE,
                                                                [SELECT Id, Primary_Household__pc FROM Account where id IN :customerIds]).getRecords();
        
        buildCustomerToHouseholdIdMap(accountList,customerToHouseholdIdMap);
        for(Account_Note__c accNote:accNotes){
            accNote.Primary_Household__c = customerToHouseholdIdMap.get(accNote.Account__c);
        }
    }
    
    /**
    * @description The method will execute to get list of customer ids
    * @author Targaryen.SFDoc | 05-11-2020
    * @param accNotes 
    * @return List<Id> 
    **/
    private static List<Id> getCustomerIds(List<Account_Note__c> accNotes){
        List<ID> accIds = new List<Id>();
        for(Account_Note__c accNote:accNotes){
            accIds.add(accNote.Account__c);
        }
        return accIds;
    }
    
    /**
    * @description The method will execute to generate map with Customer to FSC Household
    * @author Targaryen.SFDoc | 05-11-2020
    * @param accountList 
    * @param customerToHouseholdIdMap 
    **/
    private static void buildCustomerToHouseholdIdMap(List<Account> accountList, Map<Id, Id> customerToHouseholdIdMap) {
        for(Account account : accountList) {
            string primaryHouseholdIdonAccount = account.Primary_Household__pc;
            if(String.isNotEmpty(primaryHouseholdIdonAccount)){
                customerToHouseholdIdMap.put(account.Id, account.Primary_Household__pc);
            }
        }
    }
}