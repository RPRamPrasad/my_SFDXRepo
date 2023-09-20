/**
  * @name AP_CustomerGroupTrigger 
  * @author Loco Motivated
  * @createdDate 12/18/2017
  * @description This class updates CustomerGroup__c OwnerId fields in Agent's Proxy User
  */

public without sharing class AP_CustomerGroupTrigger {
    
    private static final String CLASS_NAME = 'AP_CustomerGroupTrigger';
    private static final String METHOD_NAME = 'updateOwnerWithAgentProxy';
    private static final String EXCEPTION_MESSAGE = 'This action cannot be completed at this time. Please try again later.';
    private static final String HOUSEHOLD = 'Household';
    
  /**
    * @description updateOwnerWithAgentProxy: This method will Set the Owner of input CustomerGroup__c Record/records to the his Agent's Offcie as Owner
    * @param groupList
    */  
    public static void updateOwnerWithAgentProxy(List<CustomerGroup__c> groupList) {
        try{
            set<Id> agentUserList = new set<Id>();
            
            //Adding Agent's SFDC Id to Set of Id's
            for(CustomerGroup__c groupRec : groupList){
                agentUserList.add(groupRec.Agent__c);
            }
            
            //Getting Map of Agent's SFDC Id and his Proxy User Id
            Map<Id,Id> agentProxyMap=UTIL_AgentOfficeDetails.getAgentProxyMapForGivenAgentIds(agentUserList);
            
            for(CustomerGroup__c groupRec : groupList){
                //checking each group record with agentproxy Map else adding error to each record
                if(agentProxyMap.containsKey(groupRec.Agent__c)) {
                    //Maling owner of each record to their Proxy user
                    groupRec.OwnerId = agentProxyMap.get(groupRec.Agent__c);
                }else{
                    groupRec.addError(EXCEPTION_MESSAGE);
                }
                
                //Setting default group name
                groupRec.Name = HOUSEHOLD;
            }
        }catch(exception ex){
            LoggingService.logHandledException(ex, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
            UTIL_AgentProxySelection.tagAllErrors(groupList, ex.getMessage());
        }
        
    }
}