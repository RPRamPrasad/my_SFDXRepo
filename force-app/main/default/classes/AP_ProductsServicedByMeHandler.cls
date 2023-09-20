/**
* @Author: Team Targaryen
* @owner: Team Targaryen
* @description : This class will add Household Id into Product Serviced ByMe object 
* @createdDate: 11/05/2020
* @version 1.0
*/

public with sharing class AP_ProductsServicedByMeHandler {
    /**
    * @description The method will execute while PSBM Insert Trigger will be invoked to update FSC Household Id
    * @author: Targaryen.SFDoc | 11/15/2020 
    * @param prodServicedByMe 
    * @return: void 
    **/    
    public static void productsServicedByMeUpdateHHId(List<ProductsServicedByMe__c> prodServicedByMe) { 
        Map<Id, Id> customerToHouseholdIdMap = new Map<Id, Id>(); 
        List<Id> customerIds = getCustomerIds(prodServicedByMe); 
       
        List<Account> accountList =  Security.stripInaccessible(AccessType.READABLE,
                                                                [SELECT Id, Primary_Household__pc FROM Account where id IN :customerIds]).getRecords();
        
        buildCustomerToHouseholdIdMap(accountList,customerToHouseholdIdMap);
        for(ProductsServicedByMe__c psbm:prodServicedByMe){
            psbm.Primary_Household__c = customerToHouseholdIdMap.get(psbm.Customer__c);
        }
    }
    
    /**
    * @description The method will execute to get list of customer ids
    * @author: Targaryen.SFDoc | 11/15/2020 
    * @param prodServicedByMe 
    * @return List<Id> 
    **/
    private static List<Id> getCustomerIds(List<ProductsServicedByMe__c> prodServicedByMe){
        List<Id> accId = new List<Id>();
        for(ProductsServicedByMe__c psbm:prodServicedByMe){
            accId.add(psbm.Customer__c);
        }
        return accId;
    }
    /**
    * @description The method will execute to generate map with Customer to FSC Household
    * @author: Targaryen.SFDoc | 11/15/2020 
    * @param accountList
    * @param customerToHouseholdIdMap 
    * @return: void 
    **/
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
    * @author: Targaryen.SFDoc | 11/16/2020 
    * @param oldMapPSBM
    * @param prodServicedByMe 
    * @return: void 
    **/
    public static void productsServicedByMeOwnerUpdate(Map<Id,ProductsServicedByMe__c> oldMapPSBM, List<ProductsServicedByMe__c> prodServicedByMe){
        Map<Id,Id> productsServicedByMeToAccountIdMap = new Map<Id,Id>();
        Map<Id,Id> customerToHouseholdIdMap = new Map<Id,Id>();
        List<ProductsServicedByMe__c> psbmListToUpdateHHID = new List<ProductsServicedByMe__c>();
               
        for(ProductsServicedByMe__c psbm:prodServicedByMe){
            ProductsServicedByMe__c oldSinglePSBM = oldMapPSBM.get(psbm.Id);
            if(psbm.Customer__c != oldSinglePSBM.Customer__c){
                productsServicedByMeToAccountIdMap.put(psbm.id,psbm.Customer__c);
                psbmListToUpdateHHID.add(psbm);
            }
        }
        
        if(!psbmListToUpdateHHID.isEmpty()){
            List<Id> customerIds = productsServicedByMeToAccountIdMap.values();

            List<Account> accountList =  Security.stripInaccessible(AccessType.READABLE,
                                                                    [SELECT Id, Primary_Household__pc FROM Account where id IN :customerIds]).getRecords();

            buildCustomerToHouseholdIdMap(accountList,customerToHouseholdIdMap);

            for(ProductsServicedByMe__c singlePsbm:psbmListToUpdateHHID){
                singlePsbm.Primary_Household__c = customerToHouseholdIdMap.get(singlePsbm.Customer__c);
            }
        }
    }

    /**
    * @method <This method updates the Primary_Household__c of losing customers PSBM with winning one>
    * @description Update Products Service By Me HHId
    * @name updateProductsServicedByMeHHId
    * @param winningAccount
    * @param psbmList
    */ 
    public static void updateProductsServicedByMeHHId(Account winningAccount, List<ProductsServicedByMe__c> psbmList){
		List<ProductsServicedByMe__c> psbmToBeUpdated = new List<ProductsServicedByMe__c>();
        for(ProductsServicedByMe__c psbm : psbmList) {
            psbm.Primary_Household__c = winningAccount.Primary_Household__pc;
            psbmToBeUpdated.add(psbm);
        }
        UTIL_ProductsServicedByMeDAO.updateProductsServicedByMe(psbmToBeUpdated);
    }
}
