/**
* @Author Team Data Blazers
* @owner Team Data Blazers
* @description This class will add Household Id into InteractionSummary object 
* @createdDate 01/11/2022
* @version 1.0
*/

public with sharing class InteractionSummaryHandler {
    /**
    * @description The method will execute while ISPH Insert Trigger will be invoked to update FSC Household Id
    * @param intsums 
    */ 
    public static void interactionSummaryUpdateHHId(List<InteractionSummary__c> intsums) { 
        Map<Id, Id> customerToHouseholdIdMap = new Map<Id, Id>(); 
        List<Id> customerIds = getCustomerIds(intsums); 
       
        List<Account> accountList =  Security.stripInaccessible(AccessType.READABLE,
                                                                [SELECT Id, Primary_Household__pc FROM Account where id IN :customerIds]).getRecords();
        
        buildCustomerToHouseholdIdMap(accountList,customerToHouseholdIdMap);
        if(Schema.sObjectType.InteractionSummary__c.isUpdateable()) {
            for(InteractionSummary__c isph:intsums){
                isph.Primary_Household__c = customerToHouseholdIdMap.get(isph.Customer__c);
            }
        }
    }
    
    /**
    * @description The method will execute to get list of customer ids 
    * @param intsums
    * @return List<Id>
    */
    private static List<Id> getCustomerIds(List<InteractionSummary__c> intsums){
        List<Id> accId = new List<Id>();
        for(InteractionSummary__c isph:intsums){
            accId.add(isph.Customer__c);
        }
        return accId;
    }
    /**
    * @description The method will execute to generate map with Customer to FSC Household
    * @param accountList
    * @param customerToHouseholdIdMap
    */ 
    private static void buildCustomerToHouseholdIdMap(List<Account> accountList, Map<Id, Id> customerToHouseholdIdMap) {
        for(Account account : accountList) {
            string primaryHouseholdIdonAccount = account.Primary_Household__pc;
            if(String.isNotEmpty(primaryHouseholdIdonAccount)){
                customerToHouseholdIdMap.put(account.Id, account.Primary_Household__pc);
            }
        }
    }
 
    /**
    * @description The method will execute while ACR update Trigger will be invoked to change Customer as well FSC Household Id
    * @param oldMapISPH
    * @param intsums
    */
    public static void interactionSummaryOwnerUpdate(Map<Id,InteractionSummary__c> oldMapISPH, List<InteractionSummary__c> intsums){
        Map<Id,Id> interactionSummaryToAccountIdMap = new Map<Id,Id>();
        Map<Id,Id> customerToHouseholdIdMap = new Map<Id,Id>();
        List<InteractionSummary__c> isphListToUpdateHHID = new List<InteractionSummary__c>();   
        for(InteractionSummary__c isph:intsums){
            InteractionSummary__c oldSingleISPH = oldMapISPH.get(isph.Id);
            if(isph.Customer__c != oldSingleISPH.Customer__c){
                interactionSummaryToAccountIdMap.put(isph.id,isph.Customer__c);
                isphListToUpdateHHID.add(isph);
            }
        }
        
        if(!isphListToUpdateHHID.isEmpty()){
            List<Id> customerIds = interactionSummaryToAccountIdMap.values();

            List<Account> accountList =  Security.stripInaccessible(AccessType.READABLE,
                                                                    [SELECT Id, Primary_Household__pc FROM Account where id IN :customerIds]).getRecords();
            buildCustomerToHouseholdIdMap(accountList,customerToHouseholdIdMap);

            for(InteractionSummary__c singleisph:isphListToUpdateHHID){
                singleisph.Primary_Household__c = customerToHouseholdIdMap.get(singleisph.Id);
            }
        }
    }

    /**
    * @method <This method updates the Primary_Household__c of losing customers ISPH with winning one>
    * @name updateInteractionSummaryHHId
    * @description updates the primary household_c of losing customer ISPH with winning one
    * @param winningAccount
    * @param isphList
    */ 
    public static void updateInteractionSummaryHHId(Account winningAccount, List<InteractionSummary__c> isphList){
        List<InteractionSummary__c> isphToBeUpdated = new List<InteractionSummary__c>();  
        for(InteractionSummary__c isph : isphList) {
            isph.Primary_Household__c = winningAccount.Primary_Household__pc;
            isphToBeUpdated.add(isph);
        }
        updateInteractionSummary(isphToBeUpdated);
    }
    /**
    * @description The method updates the interaction summary list
    * @param interactionSummaryList
    */ 
    public static void updateInteractionSummary(List<InteractionSummary__c> interactionSummaryList) {
        if(interactionSummaryList != null && !interactionSummaryList.isEmpty() && Schema.sObjectType.InteractionSummary__c.isUpdateable()) {
            update interactionSummaryList;
        }
    }
    
}