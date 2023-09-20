/** This is a helper class to provide the access to the related customer to the entire office on creation of the agent role for a customer
  * and also remove the access from the related customer.
  * 
  * @author Stark
  * @modifiedDate 01/07/2021
  * @description refactor agent role trigger to utilize separate classes for account, case and agreement shares
  * added FSC Insurance policy shares
  * FSC feature work - E-214149 FSC Agent Role Trigger to Call Policy Share
  * @owner Stark
  **/
  public without sharing class AP_NewAgentRoleTrigger {
    
    /**@description variable is used by AccountContactRelationship update for soft or hard delete household shares*/
    public static Boolean isDeleteFromACR = false;
    private static final String CLASS_NAME = 'AP_NewAgentRoleTrigger';
    private static final String FSC_AGENTROLE_UPDATE_CHECK = 'FSC_AgentRole_Update_Check';
    
   /**
   * @description Handler method to create Agent Role Sharing records to open up Customer Access to the Agent.
   * @param newAgentRolesList : set of new agent role
   */
    public static void agentRoleAfterInsertAddToShare(List<AgentRole__c> newAgentRolesList) {
        String methodName = 'agentRoleAfterInsertAddToShare';
        try {
            UTIL_AgencySharesModels.AgentRoleData agentRoleData = buildAgentRoleData(newAgentRolesList,false);
            System.debug(LoggingLevel.INFO, 'agentRoleData after insert -->'+agentRoleData);
            UTIL_AccountShares.createAccountShares(agentRoleData);
            UTIL_HouseholdAccountShares.createHouseholdShares(agentRoleData);
            UTIL_InsurancePolicyShares.createInsurancePolicyShares(agentRoleData);
            UTIL_BillingAccountShares.createBillingAccountSharesFromAgentRoleData(agentRoleData);
        }
        catch(Exception e)
        {   
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
        
    }
    
    /**
     * @description Handler method to delete Agent Role Sharing records to remove up Customer Access to the Agent.
     * @param deletedAgentRoleList : list of deleted agent roles
    */
    public static void agentRoleBeforeDeleteRemoveFromShare(List<AgentRole__c> deletedAgentRoleList) {
        String methodName = 'agentRoleBeforeDeleteRemoveFromShare';
        try {
            UTIL_AgencySharesModels.AgentRoleData agentRoleData = buildAgentRoleData(deletedAgentRoleList,true);
            System.debug(LoggingLevel.INFO, 'agentRoleData before delete -->'+agentRoleData);
            UTIL_AccountShares.deleteAccountShares(agentRoleData);
        }
        catch(Exception e)
        {   
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }             
    }

    /**
    * @description Handler method to after delete Agent Role Sharing records to remove up Household Access to the Agent.
    * through after Delete AgentRole Trigger
   	* @param deletedAgentRoleList : list of deleted agent role
   	*/
  	public static void agentRoleAfterDeleteRemoveFromShare(List<AgentRole__c> deletedAgentRoleList) {
    	String methodName = 'agentRoleAfterDeleteRemoveFromShare';
    	try {
            UTIL_AgencySharesModels.AgentRoleData agentRoleData = buildAgentRoleData(deletedAgentRoleList,true);
            System.debug(LoggingLevel.INFO, 'agentRoleData after delete -->'+agentRoleData);
            UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(agentRoleData);
            UTIL_BillingAccountShares.deleteBillingAccountSharesFromAgentRoleData(agentRoleData);
            UTIL_HouseholdAccountShares.deleteHouseholdAccountShares(agentRoleData);
    	}
    	catch(Exception e)
    	{   
        	LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
    	}
    }

   /**
    * @description Handler method to create Agent Role Sharing records to open up Customer Access to the Agent.
    * This will runs to find any left over shares to be create when agent role is updated
    * through after update AgentRole Trigger - Data Load / 1.07 profile
    * Handler method to create Agent Role Sharing records to open up Household Access to the Agent.
    * through before update AgentRole Trigger 
    * through after update AccountContactRelationship (Remove Member - soft delete)
    * @param newAgentRolesList : list of new agent role - Trigger.New
    * @param deletedAgentRoleList : list of old agent role - Trigger.Old
   */
    public static void agentRoleAfterUpdateAddToShare(List<AgentRole__c> newAgentRolesList, List<AgentRole__c> deletedAgentRoleList) {
        String methodName = 'agentRoleAfterUpdateAddToShare';
        try {
            if(isDeleteFromACR) {
                UTIL_AgencySharesModels.AgentRoleData agentRoleData = buildAgentRoleData(deletedAgentRoleList,true);
            	System.debug(LoggingLevel.INFO, 'agentRoleData after update delete from ACR -->'+agentRoleData);
            	UTIL_HouseholdAccountShares.deleteHouseholdAccountShares(agentRoleData);
            }
            else if(FeatureManagement.checkPermission(FSC_AGENTROLE_UPDATE_CHECK)) {
                UTIL_AgencySharesModels.AgentRoleData agentRoleData = buildAgentRoleData(newAgentRolesList,false);
                System.debug(LoggingLevel.INFO, 'agentRoleData update -->'+agentRoleData);
                UTIL_InsurancePolicyShares.createInsurancePolicyShares(agentRoleData);
            }
        }
        catch(Exception e)
        {   
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
    
    }

    /**
    * @description Handler method to create Agent Role Sharing records to open up Household Access to the Agent.
    * through insert AccountContactRelationship Trigger (Add Member)
   	* @param newAgentRolesList : list of new agent role
   	*/
    public static void insertHousholdSharesFromACR(List<AgentRole__c> newAgentRolesList) {
        List<AgentRole__c> newAgentRolesListLocal = newAgentRolesList;
        String methodName = 'insertHousholdSharesFromACR';
        try {
            newAgentRolesListLocal = [ SELECT Agent__c, Customer__c, Primary_Household__c 
                                  FROM AgentRole__c 
                                  WHERE Id IN: newAgentRolesList
                                ];
            UTIL_AgencySharesModels.AgentRoleData agentRoleData = buildAgentRoleData(newAgentRolesListLocal,false);
            System.debug(LoggingLevel.INFO, 'agentRoleData after insert add member -->'+agentRoleData);
            UTIL_HouseholdAccountShares.createHouseholdShares(agentRoleData);
        }
        catch(Exception e)
        {   
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
    }

    /**
    * @description build AgentRoleData wrapper to set wrapper attributes
    * @param agentRoleList : list of agent role
    * @param isDelete : boolean to check for delete
    * @return UTIL_AgencySharesModels.AgentRoleData : wrapper AgentRoleData
   	*/
    private static UTIL_AgencySharesModels.AgentRoleData buildAgentRoleData(List<AgentRole__c> agentRoleList, Boolean isDelete) {
        Map<Id, Id>  agentRolesToAgentIds = new Map<Id,Id>();
        Map<Id, Id>  agentRolesToAccountIds = new Map<Id,Id>();
        Map<Id, Id>  agentRolesToHouseholdIds = new Map<Id,Id>();
		Map<Id, Set<Id>> agentToAccountsAgentRoleMap = new Map<Id, Set<Id>> ();
        Map<Id, Set<Id>> householdToAgentsAgentRoleMap = new Map<Id, Set<Id>> ();
        // Create a Map of Agent Roles and Agents/Agent Roles and Accounts.
        for(AgentRole__c agentRole: agentRoleList){
            agentRolesToAgentIds.put(agentRole.Id, agentRole.Agent__c);
            agentRolesToAccountIds.put(agentRole.Id, agentRole.Customer__c);
            if (isDelete) {
                agentToAccountsAgentRoleMap = buildAgentToAccountsMap(agentRole,agentToAccountsAgentRoleMap);
                if (agentRole.Primary_Household__c != null) {
                    agentRolesToHouseholdIds.put(agentRole.Id, agentRole.Primary_Household__c);
                    householdToAgentsAgentRoleMap = buildHouseholdToAgentsMap(agentRole,householdToAgentsAgentRoleMap);
                }
            }

        }
        
        // Get a map of Agent's and there associated office/Proxy ID.
        Map<Id,Id> agentToProxyIds = UTIL_AgencyShares.getAgentProxyMap(agentRolesToAgentIds.values());

        // Use Agent Role Data object to limit parameters
        UTIL_AgencySharesModels.AgentRoleData agentRoleData = new UTIL_AgencySharesModels.AgentRoleData();
        agentRoleData.agentRoles = agentRoleList;
        agentRoleData.agentToProxyIds = agentToProxyIds;
        agentRoleData.agentRolesToAccountIds = agentRolesToAccountIds;
        agentRoleData.agentToAccountsAgentRoleMap = agentToAccountsAgentRoleMap;
        agentRoleData.agentRolesToHouseholdIds = agentRolesToHouseholdIds;
        agentRoleData.householdToAgentsAgentRoleMap = householdToAgentsAgentRoleMap;
        return agentRoleData;
    }

    /**
    * @description build Agent to Accounts Map
    * @param agentRole : agent role
    * @param agentToAccountsAgentRoleMap : list of agent role
    * @return Map<Id,Set<Id>> : agent to set of accounts
   	*/
    private static Map<Id,Set<Id>> buildAgentToAccountsMap(AgentRole__c agentRole, Map<Id,Set<Id>> agentToAccountsAgentRoleMap) {
        // Loop through each Agent Roles and add objects Account ID to the Agent to Account
        // Map. If the Account has not been added to the  Agent yet you will need to create a new list.
        if (agentToAccountsAgentRoleMap.containsKey(agentRole.Agent__c)) {
            agentToAccountsAgentRoleMap.get(agentRole.Agent__c).add(agentRole.Customer__c);
        } else {
            Set<Id> accounts = new Set<Id>();
            accounts.add(agentRole.Customer__c);
            agentToAccountsAgentRoleMap.put(agentRole.Agent__c,accounts);
        }
        return agentToAccountsAgentRoleMap;
    }

    /**
    * @description build household to agents Map
    * @param agentRole : list of agent role
    * @param householdToAgentsAgentRoleMap : list of agent role
    * @return Map<Id,Set<Id>> : household to set of agents
   	*/
    private static Map<Id,Set<Id>> buildHouseholdToAgentsMap(AgentRole__c agentRole, Map<Id,Set<Id>> householdToAgentsAgentRoleMap) {
        // Loop through each Agent Roles and add objects Agent ID to the accounts (household) to Agents
        // Map. If the Agent has not been added to the  Account yet you will need to create a new list.
        if (householdToAgentsAgentRoleMap.containsKey(agentRole.Primary_Household__c)) {
            householdToAgentsAgentRoleMap.get(agentRole.Primary_Household__c).add(agentRole.Agent__c);
        } else {
            Set<Id> agents = new Set<Id>();
            agents.add(agentRole.Agent__c);
            householdToAgentsAgentRoleMap.put(agentRole.Primary_Household__c,agents);
        }
        return householdToAgentsAgentRoleMap;
    }


}