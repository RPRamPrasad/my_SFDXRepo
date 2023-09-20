/**
 * @description This class handles claim shares for Claimant participants for agent roles and 
 * claim participants. 
 * @Date: 2/18/2022
 * @author: Moneyball
 */
public without sharing class UTIL_ClaimShareClaimant extends UTIL_AgencySharesModels {
    private static final String CLASS_NAME = 'UTIL_ClaimShareClaimant';

    private static final String ACCESS_LEVEL = 'Read';
    private static final String MANUAL_ROW_CAUSE = 'Manual';
    private static final String CLAIMANT_ROLE = 'C';

    @TestVisible
    private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();

    private UTIL_ClaimShareClaimant(){}
    
    /**
     * @name insertClaimShares
     * @description inserts ClaimShare records from AgentRoleData which contains account ids.
     * @param agentRoleData agent role data with account ids
     * @return List<Database.SaveResult>
     */
    public static List<Database.SaveResult> insertClaimShares(AgentRoleData agentRoleData) {
        if (!isClaimantShareManagementEnabled()) {
            return new List<Database.SaveResult>();
        }

        List<ClaimShare> claimShares = new List<ClaimShare>();
        for (AgentRole__c agentRole : agentRoleData.agentRoles) {
            Id agentProxyId = agentRoleData.agentToProxyIds.get(agentRole.Agent__c);
            Id accountId = agentRole.Customer__c;
            List<Id> claimantAccountId = new List<Id>();
            claimantAccountId.add(accountId);
            List<Id> claimIds = getClaimantClaimIds(claimantAccountId);
            List<Id> agentProxyIds = new List<Id>();
            agentProxyIds.add(agentProxyId);

            claimShares.addAll(generateClaimShares(agentProxyIds, claimIds));
        }

        return insertClaimShares(claimShares);
    } 

    /**
     * @name insertClaimShares
     * @description inserts ClaimShare records from ClaimParticipant list which contains account ids.
     * @param newClaimParticipants claim participants data with account ids
     * @return List<Database.SaveResult>
     */
    public static List<Database.SaveResult> insertClaimShares(List<ClaimParticipant> newClaimParticipants) {
        List<ClaimParticipant> claimantParticipants = getClaimantParticipants(newClaimParticipants);
        if (claimantParticipants.size() <= 0) {
            return new List<Database.SaveResult>();
        }

        List<AgentRole__c> agentRoles = getAgentRolesFromClaimParticipant(claimantParticipants);
        Map<Id,Id> agentProxyIds = getAgentProxiesFromAgentRoles(agentRoles);
        List<ClaimShare> claimShares = new List<ClaimShare>();

        for (ClaimParticipant claimParticipant : claimantParticipants) {
            List<Id> agentProxiesForParticipant = new List<Id>();
            for (AgentRole__c agentRole : agentRoles) {
                if (agentRole.Customer__c == claimParticipant.ParticipantAccountId) {
                    agentProxiesForParticipant.add(agentProxyIds.get(agentRole.Agent__c));
                }
            }
            List<Id> claimIds =  new List<Id>();
            claimIds.add(claimParticipant.ClaimId);
            List<ClaimShare> generatedClaimShares = generateClaimShares(agentProxiesForParticipant, claimIds);
            claimShares.addAll(generatedClaimShares);
        }
        
        return insertClaimShares(claimShares);
    }

    /**
     * @name deleteClaimShares
     * @description delete ClaimShare records from AgentRoleData which contains account ids.
     * @param agentRoleData agent role data with account ids
     * @return List<Database.DeleteResult>
     */
    public static List<Database.DeleteResult> deleteClaimShares(AgentRoleData agentRoleData) {
        if (!isClaimantShareManagementEnabled()) {
            return new List<Database.DeleteResult>();
        }
        List<ClaimShare> existingShares = new List<ClaimShare>();

        for (AgentRole__c agentRole : agentRoleData.agentRoles) {
            Id agentProxyId = agentRoleData.agentToProxyIds.get(agentRole.Agent__c);
            Id accountId = agentRole.Customer__c;

            List<Id> claimantAccountId = new List<Id>();
            claimantAccountId.add(accountId);
            List<Id> claimIds = getClaimantClaimIds(claimantAccountId);
            List<Id> agentProxyIds = new List<Id>();
            agentProxyIds.add(agentProxyId);

            List<ClaimShare> agentRoleShares = getClaimShares(claimIds, agentProxyIds);
            existingShares.addAll(agentRoleShares);
        }

        return deleteClaimShares(existingShares);
    } 

    /**
     * @name getClaimantClaimIds
     * @description get all the claim ids where the claim participant's acccount is in the list of account ids.
     * @param accountIds account ids
     * @return List<Id>
     */
    @TestVisible
    private static List<Id> getClaimantClaimIds(List<Id> accountIds) {
        List<Id> claimIds = new List<Id>();
        List<ClaimParticipant> claimParticipants = [
                        SELECT ClaimId
                        FROM ClaimParticipant
                        WHERE RoleCd__c = :CLAIMANT_ROLE 
                        AND ParticipantAccountId IN :accountIds WITH SECURITY_ENFORCED];
        for (ClaimParticipant claimParticipant : claimParticipants) {
            claimIds.add(claimParticipant.ClaimId);
        }

        return claimIds;
    }

    /**
     * @name generateClaimShares
     * @description Generate all the ClaimShare objects for the given set of UserOrGroupId and claim ids.
     * @param userOrGroupIds List of UserOfGroupId
     * @param claimIds list of claim Id
     * @return List<ClaimShare>
     */
    private static List<ClaimShare> generateClaimShares(List<Id> userOrGroupIds, List<Id> claimIds) {
        List<ClaimShare> claimShares = new List<ClaimShare>();
        for (Id userOrGroupId : userOrGroupIds) {
            for (Id claimId : claimIds) {
                ClaimShare claimShare = new ClaimShare();
                claimShare.ParentId = claimId;
                claimShare.UserOrGroupId = userOrGroupId;
                claimShare.AccessLevel = ACCESS_LEVEL;
                claimShare.RowCause = MANUAL_ROW_CAUSE;
                claimShares.add(claimShare);
            }
        }
        
        return claimShares;
    }

    /**
     * @name insertClaimShares
     * @description Insert claimant claim shares into the database and log the results.
     * @param claimantSharesToAdd list of shares
     * @return List<Database.SaveResult>
     */
    public static List<Database.SaveResult> insertClaimShares(List<ClaimShare> claimantSharesToAdd){
        if (claimantSharesToAdd != null){
            List<ClaimShare> claimantSharesToSaveList = new List<ClaimShare>(claimantSharesToAdd);
            List<Database.SaveResult> saveResults = Database.insert(claimantSharesToSaveList, false);
            LoggingService.logDatabaseResult(saveResults, claimantSharesToSaveList, CLASS_NAME, 'insertClaimShares', System.LoggingLevel.ERROR);
            return saveResults;
        }
        return new List<Database.SaveResult>();
    }

    /**
     * @name deleteClaimShares
     * @description Delete claim shares from the database. Log the results.
     * @param claimantShares claim shares to be deleted
     * @return List<Database.DeleteResult>
     */
    public static List<Database.DeleteResult> deleteClaimShares(List<ClaimShare> claimantShares) {
        if (claimantShares != null) {
            List<Database.DeleteResult> deleteResults = Database.delete(claimantShares, false);
            LoggingService.logDatabaseResult(deleteResults, claimantShares, CLASS_NAME, 'deleteClaimShares', System.LoggingLevel.ERROR);
            return deleteResults;
        }
        return new List<Database.DeleteResult>();
    }

    /**
     * @name getClaimShares
     * @description Get the claim shares for the given list of claim ids and agent proxy ids
     * @param claimIds list of claim id
     * @param agentProxyIds list of agent proxy ids
     * @return List<ClaimShare>
     */
    public static List<ClaimShare> getClaimShares(List<Id> claimIds, List<Id> agentProxyIds) {
        List<ClaimShare> existingClaimShares = new List<ClaimShare>();

        try {
             existingClaimShares = [
                SELECT Id, UserOrGroupId, ParentId 
                FROM ClaimShare 
                WHERE ParentId IN : claimIds 
                AND UserOrGroupId IN : agentProxyIds
                AND RowCause = : MANUAL_ROW_CAUSE WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, 'getClaimShares', System.LoggingLevel.ERROR);
        }
        
        return existingClaimShares;
    }

    /**
     * @name getClaimantParticipants
     * @description filters out the claim participants that are not claimants
     * @param claimParticipants claim participants data with account ids
     * @return List<claimParticipants>
     */
    public static List<ClaimParticipant> getClaimantParticipants(List<ClaimParticipant> claimParticipants) {
        List<ClaimParticipant> claimantClaimParticipants = new List<ClaimParticipant>();
        for (ClaimParticipant claimParticipant : claimParticipants) {
            if (CLAIMANT_ROLE.equalsIgnoreCase(claimParticipant.RoleCd__c)) {
                claimantClaimParticipants.add(claimParticipant);
            }
        }
        return claimantClaimParticipants;
    }

    /**
     * @name getAgentRolesFromClaimParticipant
     * @description gets the agent roles for all the claim participants
     * @param claimParticipants claim participants data with account ids
     * @return List<AgentRole>
     */
    public static List<AgentRole__c> getAgentRolesFromClaimParticipant(List<ClaimParticipant> claimParticipants) {
        List<Id> claimParticipantsIds = new List<Id>();
        for (ClaimParticipant claimParticipant : claimParticipants) {
            claimParticipantsIds.add(claimParticipant.ParticipantAccountId);
        }

        return [SELECT Agent__c, Customer__c FROM AgentRole__c WHERE Customer__c IN :claimParticipantsIds WITH SECURITY_ENFORCED];
    }

    /**
     * @name getAgentProxiesFromAgentRoles
     * @description returns the agent proxies from the agent roles related to the claim participants
     * @param agentRoles claim participants data with account ids
     * @return Map<Id,Id>
     */
    public static Map<Id,Id> getAgentProxiesFromAgentRoles(List<AgentRole__c> agentRoles) {
        List<Id> agentRolesIds = new List<Id>();
        for (AgentRole__c agentRole : agentRoles) {
            agentRolesIds.add(agentRole.Agent__c);
        }

        return UTIL_AgencyShares.getAgentProxyMap(agentRolesIds);
    }

    /**
     * @name isClaimantShareManagementEnabled
     * @description checks to see if claimant claim shares is toggle on.
     * @return boolean
     */
    private static boolean isClaimantShareManagementEnabled() {
        return UTIL_ClaimShareClaimant.toggleContext.isActive(UTIL_Toggles.CLAIMANT_SHARES);
    }

}
