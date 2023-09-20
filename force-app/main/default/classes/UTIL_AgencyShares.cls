/**
 * @description This class will house various methods used for logic shared across different types of agency shares.
 * @Date: 09/17/20
 * @author: Jonathan Larkin VAASTT
 * @owner Kraken
 */
public without sharing abstract class UTIL_AgencyShares extends UTIL_AgencySharesModels {

    private static final String CLASS_NAME='UTIL_AgencyShares';

    /** @description throw error for test */
    public static Exception throwErrorForTest {get;set;}

    /** @description map of agent to proxy
     * @param agentIds
     * @return Map<Id,Id>
    */
    public static Map<Id,Id> getAgentProxyMap(Set<Id> agentIds) { 
        List<Id> ids = new List<Id>();
        ids.addAll(agentIds);
        return getAgentProxyMap(ids);
    }

    /**
     * @description Get a list of Proxy/Office Id's that are associated to the agents in our new roles.
     * @param agentIds
     * @return Map<Id,Id>
     */
    public static Map<Id,Id> getAgentProxyMap(List<Id> agentIds) {
        String methodName = 'getAgentProxyMap';

        Map<String,Id> agentsExternalIdMap = new Map<String,Id>();
        Map<Id,Id> agentsProxyIds = new Map<Id,Id>();

        try{  

            // We need this statement to test exceptions thrown by query are handled
            if(test.isRunningTest() && throwErrorForTest != null ){
                throw throwErrorForTest;
            } 

            // Get a list of agent Id's and map them and their external ID values
            for(User agent: [SELECT id, Proxy_External_ID__c FROM User WHERE Id = :agentIds]){
                agentsExternalIdMap.put(agent.Proxy_External_ID__c,agent.Id); 
            }
            
            if(agentsExternalIdMap.isEmpty()){
                return agentsProxyIds; 
            }

            // Get a list of offices using a map of agents external Id's, use the agents office ID as the proxy Id.
            for(User office: [SELECT id, UserExternalID__c FROM User WHERE UserExternalID__c=:agentsExternalIdMap.keySet()]){
                agentsProxyIds.put(agentsExternalIdMap.get(office.UserExternalID__c),office.id);
            }

        } 
        catch(DmlException e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        } catch(QueryException e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName,  System.LoggingLevel.ERROR);
        }

        return agentsProxyIds;                   
    } 

    /**
     * @description Take a list of all agent roles and and create an account of agents to maps.
     * @param allAgentRoles
     * @return Map<Id,Set<Id>>
     */
    public static Map<Id,Set<Id>> buildAccountToAgentSet(List<AgentRole__c> allAgentRoles) {
        Map<Id, Set<Id>> accountToAgentsMap = new Map<Id, Set<Id>>();
        for (AgentRole__c agentRole: allAgentRoles) {

            if (accountToAgentsMap.containsKey(agentRole.Customer__c)) {
                accountToAgentsMap.get(agentRole.Customer__c).add(agentRole.Agent__c);
            } else {
                Set<Id> agents = new Set<Id>();
                agents.add(agentRole.Agent__c);
                accountToAgentsMap.put(agentRole.Customer__c,agents);
            }
        }

        return accountToAgentsMap;
    }


    /**
     * @description This method will contain code extracted from the Agreement Risk Share Delete Loop too "Reduce" complexity.
     * @param deleteShareLoopData
     * @param agentRoleData
     * @param sharesToDelete
     */
    public static void deleteSharesLoop(DeleteShareLoopData deleteShareLoopData, AgentRoleData agentRoleData, Set<sObject> sharesToDelete){

        for(Id policyId: deleteShareLoopData.policyIds){ 

            String mapKey = (String)policyId + (String)agentRoleData.agentToProxyIds.get(deleteShareLoopData.agentRole.Agent__c);

            // If we only have one account for the policy, no action is neccessary just add it to the list.
            if(deleteShareLoopData.allPolicyAccountInformation.get(policyId).size() <= 1){

                if(deleteShareLoopData.shareMap.containsKey(mapKey)){	
                    sharesToDelete.add(deleteShareLoopData.shareMap.get(mapKey));
                }

            } else {

                    // Determine which shares to delete using a complex set of logic that's been extracted.
                    DeleteAgentRoleData deleteData = new DeleteAgentRoleData(agentRoleData.agentToAccountsAgentRoleMap, deleteShareLoopData.agentRole, policyId);
                    deleteData.allPolicyAccountInformation = deleteShareLoopData.allPolicyAccountInformation;
                    
                    boolean shouldDeleteShare = determineDelete(deleteData);

                    // Make final decision on go/no go for delete.
                    if (shouldDeleteShare && deleteShareLoopData.shareMap.containsKey(mapKey)) {
                        sharesToDelete.add(deleteShareLoopData.shareMap.get(mapKey));
                    }
                }
            }
    }




    /**
    * @description This method will use provided data to determine if an Insurance Policy/Agreement Risk should be
    * deleted. This is shared code and has therefore been moved to the Agency Share class.
    * @param deleteData
    * @return boolean
    */
    private static boolean determineDelete(DeleteAgentRoleData deleteData) {
        AgentRole__c agentRole = deleteData.agentRole;
        Map<Id, Set<Id>> agentToAccountsAgentRoleMap = deleteData.agentToAccountsAgentRoleMap;

        boolean deleteRisk = true;
        for(Id accountId: deleteData.allPolicyAccountInformation.get(deleteData.policyId).keySet()){

            Set<Id> agents = deleteData.allPolicyAccountInformation.get(deleteData.policyId).get(accountId);

            if(agents == null){
                continue;
            }

            // Before setting delete to false check:
            // 1. This is not the account, whose share we are deleting
            // 2. The other accounts on the agent do not have the same agent as on the agent role we are deleting.
            // 3. If the Agent is shared by multiple accounts, make sure that the other accounts aren't in the list to be deleted.
            if(accountId != agentRole.Customer__c && agents.contains(agentRole.Agent__c) 
                && !agentToAccountsAgentRoleMap.get(agentRole.Agent__c).contains(accountId)){ 
                    deleteRisk = false;
                    break;
            }
        } 
        return deleteRisk;
    }

}
