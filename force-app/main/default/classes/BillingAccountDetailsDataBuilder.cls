/**
* Author : Team Nsync
* Date Created : 9/29/21
* @description : Used to build BillingAccountDetails
*/

public with sharing class BillingAccountDetailsDataBuilder extends BillingTabModels {

    private static final string CLASS_NAME = 'BillingAccountDetailsDataBuilder';
    private BillingAccountDetailsDataBuilder(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info(CLASS_NAME, 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }

    /**
     * @name - buildAgent
     * @description - retrieves agent data from a given servicing agent ID
     * @param servincingAgentId
     * @return AgentData
     */
    public static AgentData buildAgent(String servincingAgentId){
        String methodName = 'buildAgent';
        List<User> agents = new List<User>();   
        AgentData agentData;
        try {
            agents = [
                SELECT Id, Name, State_Agent_Code__c, State_Agent_Code_List__c, Associate_ID__c, Servicing_Agent_Associate_ID__c, MasterUserRecord__c, isActive
                FROM User 
                WHERE 
                    State_Agent_Code__c = :servincingAgentId
                AND
                    MasterUserRecord__c = true
                AND
                    isActive = true
                AND
                (
                    SubUserType__c = 'Agent'
                    OR
                    SubUserType__c = 'PSO'
                    OR
                    SubUserType__c = 'SFO'
                )
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
       
        if(agents == null || agents.isEmpty()) {
            agentData = findSecondaryAgentForBillingDetails(servincingAgentId);
        } else {
            agentData =  buildAndAssignAgentForBillingDetails(servincingAgentId, agents.get(0));
        }
     
        return agentData;
       
    }

    private static AgentData findSecondaryAgentForBillingDetails(String servincingAgentId) {
        String methodName = 'processAgentDataSecondary';
        AgentData agentData;
        List<User> agents = new List<User>();
        String stateCodeWildcard = '%' + servincingAgentId + '%';

            try {
                agents = UTIL_BillingAccountDataFindSA.createSecondaryAgentList(stateCodeWildcard);
            } catch (System.QueryException qe) {
                LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            }
    
           
            if(agents != null && !agents.isEmpty()) {
              agentData = buildAndAssignAgentForBillingDetails(servincingAgentId, agents.get(0)); 
            }
            
       return agentData;
       
    }

     private static AgentData buildAndAssignAgentForBillingDetails( String servincingAgentId, User agent) {
        return BillingTabAgentDataBuilder.buildAgentData(servincingAgentId, agent);
    }

}
