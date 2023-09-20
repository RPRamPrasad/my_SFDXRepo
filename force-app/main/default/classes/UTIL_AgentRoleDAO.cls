/**
 *  @Author Impact Force (upsert, refactor) and Team Pike (insert, delete,update)
 *  @owner Team Stark
 *  @name UTIL_AgentRoleDAO
 *  @CreateDate 10/6/2016
 *  @description Common 'Data Access' operations encapsulating 'log and throw' exception handling. Initially developed for customer synchronization processing
 *  @Version 2.0
 */
public without sharing class UTIL_AgentRoleDAO {
    
   /**
  * @name upsertAgentRole
  * @description upsertUserAgentRole
  * @param agentrole - a AgentRole object
  */ 
    public static void upsertUserAgentRole(AgentRole__c agentrole) {
        if(agentRole != null) {
            upsert agentrole AgentRoleIdentifier__c ; 
        }
    }
    
    /**
  * @name upsertAgentRoles
  * @description upsertUserAgentRoles
  * @param agentroles - a AgentRole object
  */ 
    public static void upsertUserAgentRoles(List<AgentRole__c> agentroles) {
        if(agentroles != null && !agentroles.isEmpty()) {
            upsert agentroles AgentRoleIdentifier__c ;
        }
    }
    
     /**
   * Takes the List<AgentRole__c> and inserts into SFDC datastore
   * @name insertAgentRoles
   * @description insertAgentRoles
   * @param agentRoleList - Agent roles to be inserted
   */
    public static void insertAgentRoles(List<AgentRole__c> agentRoleList) {
        if(agentRoleList != null && !agentRoleList.isEmpty()) {
            insert agentRoleList;
        }
    }
    
     /**
   * Takes the List<AgentRole__c> and deletes from SFDC datastore
   * @description deleteAgentRoles
   * @name deleteAgentRoles
   * @param agentRoleList - Agent roles to be deleted (Id for each is REQUIRED)
   */    
     public static void deleteAgentRoles(List<AgentRole__c> agentRoleList) {   
         if(agentRoleList != null && !agentRoleList.isEmpty()) {
             delete agentRoleList;
         }
    }
     
    /**
   * Takes the List<AgentRole__c> and update from SFDC datastore
   * @description updateAgentRoles
   * @name updateAgentRoles
   * @param agentRoleList - Agent roles to be updated (Id for each is REQUIRED)
   */    
     public static void updateAgentRoles(List<AgentRole__c> agentRoleList) {   
         if(agentRoleList != null && !agentRoleList.isEmpty()) {
             update agentRoleList;
         }
     }
    
  /**
  * @name upsertAgentRoles
  * @description upsertAgentRoles
  * @param agentRoleList - Agent roles to be upserted
  */ 
    public static void upsertAgentRoles(List<AgentRole__c> agentRoleList) {
        if(agentRoleList != null && !agentRoleList.isEmpty()) {
            upsert agentRoleList;
        }
    }

   /**
    * @name deleteAgentRole
    * @description deleteAgentRole
    * @param agentrole - a AgentRole object
    */ 
    public static void deleteAgentRole(AgentRole__c agentrole) {
        if(agentRole != null) {
            delete agentrole; 
        }
    } 
    /**
     * @name upsertedAgentRolesResult
     * @description upsertedAgentRolesResult
     * @param agentRolesToBeUpserted
     * @return List<Database.UpsertResult>
     */ 
    public static List<Database.UpsertResult> upsertedAgentRolesResult(List<AgentRole__c> agentRolesToBeUpserted){
        List<Database.UpsertResult> agentrolesUpdatedResult = Database.upsert(agentRolesToBeUpserted, AgentRole__c.AgentRoleIdentifier__c,false);
        return agentrolesUpdatedResult;
    }
   
}