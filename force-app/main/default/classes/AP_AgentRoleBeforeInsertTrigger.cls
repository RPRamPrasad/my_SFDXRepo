/**
 * @Author: Team Targaryen
 * @owner: Team Targaryen
 * @description : This class will add Household Id into AgentRole object on Agent Role before insert.
 * @createdDate: 04/17/2020
 * @version 1.0
 */

public without sharing class AP_AgentRoleBeforeInsertTrigger {
    
    /**
      * @description : This method will get the Household Id from Account and add into Agentrole object 
      * @param agentRolesList
      */
    public static void agentRoleBeforeInsert(List<AgentRole__c> agentRolesList) {
        Map<Id, String> customerToHouseholdIdMap = new Map<Id, String>();
        List<Id> customerIds = getCustomerIds(agentRolesList);
        
        List<Account> accountList = [ SELECT Id, Primary_Household__pc 
                                        FROM Account 
                                        WHERE id IN :customerIds
                                    ];
        buildCustomerToHouseholdIdMap(accountList, customerToHouseholdIdMap);
      
        for(AgentRole__c agentRole : agentRolesList) {
            agentRole.Primary_Household__c = customerToHouseholdIdMap.get(agentRole.Customer__c);
        }
    }
    
    /**
    * @description The method will execute to get list of customer ids
    * @author Targaryen.SFDoc | 04-17-2020 
    * @param agentRolesList 
    * @return List<Id> 
    **/
    private static List<Id> getCustomerIds(List<AgentRole__c> agentRolesList) {
        List<Id> customerIds = new List<Id>();    
        for(AgentRole__c agentRole : agentRolesList) {
            customerIds.add(agentRole.Customer__c);
        }
        return customerIds;
    }

    /**
    * @description The method will execute to generate map with Customer to FSC Household
    * @author Targaryen.SFDoc | 04-17-2020
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