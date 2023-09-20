/**
* @Author: Team Octonauts
* @owner: Team Octonauts
* @description : This class will add Household Id into Simple Conversation object on Simple Conversation before insert.
* @createdDate: 07/29/2020
* @version 1.0
*/

public with sharing class AP_SimpleConversationHandler {
    /**
* @description : This method will get the Household Id from Account and add into Simple Conversation object
* @param simpleConv Conversation List
*/
    public static void simpleConvUpdateAccount(List<SimpleConversation__c> simpleConv) {
        Map<Id, Id> customerToHouseholdIdMap = new Map<Id, Id>(); //
        List<Id> customerIds = getCustomerIds(simpleConv); //get customer id's from SC
        //customerIds = Account Id's
        List<Account> accountList =  Security.stripInaccessible(AccessType.READABLE,
                                                                [SELECT Id, Primary_Household__pc FROM Account where id IN :customerIds]).getRecords();

        buildCustomerToHouseholdIdMap(accountList,customerToHouseholdIdMap);
        for(SimpleConversation__c simpleConversation:simpleConv){
            simpleConversation.Primary_Household__c = customerToHouseholdIdMap.get(simpleConversation.Account__c);
        }
    }

    /**
    * @description The method will execute to get list of customer ids
    * @author Octonauts.SFDoc | 07-29-2020
    * @param simpleConv
    * @return List<Id>
    **/
    private static List<Id> getCustomerIds(List<SimpleConversation__c> simpleConv){
        List<Id> accId = new List<Id>();
        for(SimpleConversation__c simpleConversation:simpleConv){
            accId.add(simpleConversation.Account__c);
        }
        return accId;
    }

    /**
    * @description The method will execute to generate map with Customer to FSC Household
    * @author Octonauts.SFDoc | 07-29-2020
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