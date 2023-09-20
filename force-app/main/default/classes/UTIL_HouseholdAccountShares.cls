/**
 * @description This class will house various methods used for adding/removing Household Account Shares to/from the Database. 
 * @Date: 04/10/2021
 * @author Team Stark
 * @owner Team Stark
 */
public without sharing class UTIL_HouseholdAccountShares extends UTIL_AgencyShares {

    private static final String CLASS_NAME = 'UTIL_HouseholdAccountShares';

    private static final String KEY_SYMBOL = '+';
    private static final String AGENT_ACCOUNTACCESS_LEVEL = 'Edit';
    private static final String AGENT_OPPORTUNITY_ACCESS_LEVEL = 'None';
    private static final String AGENT_CASE_ACCESS_LEVEL = 'None';
    private static final String MANUAL_ROW_CAUSE = 'Manual';
    @TestVisible
    private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();

    /**
     * @description This method will be used to create new account shares for each new agent role.
     * @param List<AgentRole__c>
     * @param agentRoleData
     */
    public static void createHouseholdShares(AgentRoleData agentRoleData) {
        //implement Toggle Strategy using HOUSEHOLD_SHARE if off, no apex code will be executed
        if (!isHouseholdAccountShareEnabled()) {
            return;
        }
        Set<AccountShare> sharesToAdd = new Set<AccountShare>();

        // Loop through all agent roles and create corresponding account shares.
        for(AgentRole__c newAgentRole : agentRoleData.agentRoles) {
            if(newAgentRole.Primary_Household__c == null) {
                continue;
            }
            AccountShare share = new AccountShare();
            share.accountId = newAgentRole.Primary_Household__c;
            share.AccountAccessLevel = AGENT_ACCOUNTACCESS_LEVEL;
            share.OpportunityAccessLevel = AGENT_OPPORTUNITY_ACCESS_LEVEL;
            share.CaseAccessLevel = AGENT_CASE_ACCESS_LEVEL;
            share.RowCause = MANUAL_ROW_CAUSE;
            share.UserOrGroupId = agentRoleData.agentToProxyIds.get(newAgentRole.Agent__c);
            sharesToAdd.add(share);
        }
        List<AccountShare> householdSharesToAdd = new List<AccountShare>(sharesToAdd);

        // Insert Account Shares
        insertHouseholdShareAndLogFailures(householdSharesToAdd);
    }

    /**
     * @description This method will be used to delete account shares for each agent role that will be deleted.
     * @name deleteHouseholdAccountShares
     * @param agentRoleData
     */
    public static void deleteHouseholdAccountShares(AgentRoleData agentRoleData) {
        //implement Toggle Strategy using HOUSEHOLD_SHARE if off, no apex code will be executed
        if (!isHouseholdAccountShareEnabled()) {
            return;
        }
        Map<String, AccountShare> householdShareKeyMap = buildHouseholdAccountShareKeyMap(agentRoleData);
        List<AgentRole__c> surviveAllAgentRoles = surviveAgentRolesFromHouseholds(agentRoleData);
        Map<Id,Set<Id>> surviveHouseholdToAllAgentsMap = buildHouseholdIdToAgentsMap(surviveAllAgentRoles);
        Set<AccountShare> householdSharesToDelete = new Set<AccountShare>();
        
        // Iterate through the deleted set again to exactly identify the share records
        for(AgentRole__c agentRole : agentRoleData.agentRoles) {
            if(surviveHouseholdToAllAgentsMap.containsKey(agentRole.Primary_Household__c)) {
            	if(surviveHouseholdToAllAgentsMap.get(agentRole.Primary_Household__c).contains(agentRole.Agent__c)) {
                	continue;
                }
                String key = agentRole.Primary_Household__c + KEY_SYMBOL + agentRoleData.agentToProxyIds.get(agentRole.Agent__c);
                householdSharesToDelete.add(householdShareKeyMap.get(key));
            }
            else if(agentRole.Primary_Household__c != null) {
                String key = agentRole.Primary_Household__c + KEY_SYMBOL + agentRoleData.agentToProxyIds.get(agentRole.Agent__c);
                householdSharesToDelete.add(householdShareKeyMap.get(key));
            }
        }
        //delete account shares
        List<AccountShare> householdSharesToDeleteList = new List<AccountShare>(householdSharesToDelete);
        deleteHouseholdShareAndLogFailures(householdSharesToDeleteList);
    }
    
    /**
     * @description perform query to get agent role list for deletion
     * @param agentRoleData
     * @return List<AgentRole__c>
     */
    private static List<AgentRole__c> surviveAgentRolesFromHouseholds(AgentRoleData agentRoleData) {
        String methodName = 'surviveAgentRolesFromHouseholds';
        List<AgentRole__c> allAgentRoles = new List<AgentRole__c>();
        try {
            //Find all roles related to Primary household which have survived after delete
            allAgentRoles = [
                SELECT Id, Customer__c, Agent__c, Primary_Household__c
                FROM AgentRole__c 
                WHERE Primary_Household__c IN: agentRoleData.agentRolesToHouseholdIds.values()
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
        return allAgentRoles;
    }

    /**
     * @description build a map for household to set of agents
     * @param allAgentRoles
     * @return Map<Id,Set<Id>>
     */
    private static Map<Id,Set<Id>> buildHouseholdIdToAgentsMap(List<AgentRole__c> allAgentRoles) {
        Map<Id, Set<Id>> householdToAgentsMap = new Map<Id, Set<Id>>();
        // Create a helper map to help using combination of user account id and set of agent ids
        // This map is provide details of surviving agents after delete
        for (AgentRole__c agentRole: allAgentRoles) {
            if (householdToAgentsMap.containsKey(agentRole.Primary_Household__c)) {
                householdToAgentsMap.get(agentRole.Primary_Household__c).add(agentRole.Agent__c);
            } else {
                Set<Id> agents = new Set<Id>();
                agents.add(agentRole.Agent__c);
                householdToAgentsMap.put(agentRole.Primary_Household__c,agents);
            }
        }
        return householdToAgentsMap;
    }

    /**
     * @description build a map for key to AccountShare
     * @param agentRoleData
     * @return Map<String, AccountShare>
     */
    private static Map<String, AccountShare> buildHouseholdAccountShareKeyMap(AgentRoleData agentRoleData) {
        String methodName = 'buildHouseholdAccountShareKeyMap';
        List<AccountShare> householdShares = new List<AccountShare> ();
        try {
            // Find all account shares where account id (household recordType) 
            // and proxy id match the provided roles to delete
            householdShares = [
                SELECT Id, AccountId, UserOrGroupId 
                FROM AccountShare
                WHERE AccountId IN: agentRoleData.agentRolesToHouseholdIds.values()
                AND RowCause =: MANUAL_ROW_CAUSE
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
        Map<String, AccountShare> householdShareKeyMap = new Map<String, AccountShare>();
        // Create a helper map to help identify exact record using combination of user account id and proxy group id
        for (AccountShare accountShare : householdShares) {
            householdShareKeyMap.put(accountShare.AccountId + KEY_SYMBOL + accountShare.UserOrGroupId, accountShare);
        }
        return householdShareKeyMap;
    }

    /**
     * @description Insert account shares into the database. Log and return the list of results.
     * @param listOfAccountShares
     */
    private static void insertHouseholdShareAndLogFailures(List<AccountShare> listOfAccountShares) {

        if(listOfAccountShares != null && !listOfAccountShares.isEmpty()) {

            String methodName='insertHouseholdShareAndLogFailures';

            List<Database.SaveResult> saveResults = Database.insert(listOfAccountShares, false);
            LoggingService.logDatabaseResult(saveResults, listOfAccountShares, CLASS_NAME, methodName, System.LoggingLevel.ERROR);

        }

    }

    /**
     * @description Delete account shares from the database. Log the results.
     * @param listOfAccountShares 
     */
    private static void deleteHouseholdShareAndLogFailures(List<AccountShare> listOfAccountShares) {

        if(listOfAccountShares != null && !listOfAccountShares.isEmpty()) {

            String methodName='deleteHouseholdShareAndLogFailures';

            List<Database.DeleteResult> deleteResults = Database.delete(listOfAccountShares, false);
            LoggingService.logDatabaseResult(deleteResults, listOfAccountShares, CLASS_NAME, methodName, System.LoggingLevel.ERROR);

        }

    }

    /**
     * @description This method is used to check whether we need to enabled household share logic or not using toggle strategy.
     * if HOUSEHOLD_SHARES values is enabled in Custom metadataType CM_Tooggle, household shares logic will be active otherwise not
     * @return boolean
     */
    private static boolean isHouseholdAccountShareEnabled() {
        return UTIL_HouseholdAccountShares.toggleContext.isActive(UTIL_Toggles.HOUSEHOLD_SHARES);
    }

}
