/**
* @Name UTIL_OrchestrationJSONtoAgentRole 
* @Author Club Car,Loco Motivated,Akita
* @description This is a utility class that implements Mapping for Agent role fields from JSON
*/

public without sharing class UTIL_OrchestrationJSONtoAgentRole {
    private static final String AGENT_ROLE='Agent Role';

    /**
     * @method jsonAgentRoleConverter: For Mapping Agent Role data from Json
     * @description JSON AgentRole Converter
     * @param parseAgentJSON
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> jsonAgentRoleConverter(AP_StageOrchestrationJSONParser parseAgentJSON) {
        Set<String> userExternalIdSet = new Set<String>();
        List<AgentRole__c> parsedAgentRole = new List<AgentRole__c>();
        List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> listOfAgentRoleDataToSync=new List<AP_StageOrchestrationJSONParser.OrchestrationDataValues>();
        
        for(AP_StageOrchestrationJSONParser.OrchestrationDataName orchDataName : parseAgentJSON.orchestrationInfo.orchestrationDataName){
            if(AGENT_ROLE.equalsIgnoreCase(orchDataName.orchestrationNameDetail.dataName)){
                listOfAgentRoleDataToSync.add(orchDataName.orchestrationNameDetail.orchestrationDataValues);
                userExternalIdSet.add(orchDataName.orchestrationNameDetail.orchestrationDataValues.agent.trim()+UTIL_StageOrchestrationConstants.UNDERSCORE+orchDataName.orchestrationNameDetail.orchestrationDataValues.agent.trim());
            }
        }
        
        if(!listOfAgentRoleDataToSync.isEmpty()){
            parsedAgentRole=processJsonDataToAgenRoleObject(listOfAgentRoleDataToSync,userExternalIdSet); 
        }
        return parsedAgentRole;
        
    }
    
    /**
     * @description Process Agent AssocIds From Json
     * @param parseAgentJSON
     * @return Set<String>
     */
    public static Set<String> processAgentAssocIdsFromJson(AP_StageOrchestrationJSONParser parseAgentJSON){
    	Set<String> userAssocIdSet = new Set<String>();
    	for(AP_StageOrchestrationJSONParser.OrchestrationDataName orchDataName : parseAgentJSON.orchestrationInfo.orchestrationDataName){
            if(AGENT_ROLE.equalsIgnoreCase(orchDataName.orchestrationNameDetail.dataName)){
                userAssocIdSet.add(orchDataName.orchestrationNameDetail.orchestrationDataValues.agent.trim());
            }
        }
        return userAssocIdSet;
    }
    
    
    private static List<AgentRole__c> processJsonDataToAgenRoleObject( List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> listOfAgentRoleDataToSync,Set<String> userExternalIdSet){
        checkUserAvailability(userExternalIdSet);
        return getListOfAgentRoles(listOfAgentRoleDataToSync);
    }
    
    private static void checkUserAvailability(Set<String> userExternalIdSet){
        List<User> agentUserDetails= [Select UserExternalID__c,id,Associate_ID__c from User where UserExternalID__c in : userExternalIdSet and SubUserType__c in ('Agent', 'PSO', 'SFO')];
        if(agentUserDetails.size()!=userExternalIdSet.size()){
            throw new DataNotFoundException(UTIL_StageOrchestrationConstants.INVALID_USER_NOT_FOUND);
        }
    }
    
    /**
    * @method getListOfAgentRoles: For Mapping Agent Role field values from Json
    * @description Get List Of AgentRoles
    * @param listOfAgentRoleDataToSync
    * @return List<AgentRole__c>
    */
    private static List<AgentRole__c> getListOfAgentRoles(List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> listOfAgentRoleDataToSync){
        List<AgentRole__c> agentRoleList=new List<AgentRole__c>();
        for(AP_StageOrchestrationJSONParser.OrchestrationDataValues jsonARValues:listOfAgentRoleDataToSync){
            AgentRole__c agentRole = new AgentRole__c();
            agentRole.RelationshipNature__c = getRelationShipNature(jsonARValues.relationshipNature);
            agentRole.AgentRoleIdentifier__c = jsonARValues.agent+UTIL_Constants.TILT_SYMBOL+jsonARValues.customer;
            agentRole.Customer__r=new account(clientidentifier__c=jsonARValues.customer);
            agentRole.Agent__r=new User(UserExternalID__c=jsonARValues.agent.trim()+UTIL_StageOrchestrationConstants.UNDERSCORE+jsonARValues.agent.trim());
            agentRole.RelationshipStartDate__c=date.valueOf(jsonARValues.startDate);
            agentRoleList.add(agentRole);
        } 
      //returns all the valid AgentRoles list which are Agent Profile only
       return agentRoleList;
        
    }
    
   /**
    * @method getRelationShipNature: For Mapping Agent Role field values from Json
    * @description Get Relationship Nature
    * @param jsonRelationshipNature
    * @return String
    */    
    public static String getRelationShipNature(String jsonRelationshipNature){
        Map<String, String> transformToPicklistMap = UTIL_StageOrchestrationConstants.AGENTROLE_PICKLIST_CONVERSION;
        if(transformToPicklistMap.containsKey(jsonRelationshipNature.toUpperCase())){
            jsonRelationshipNature = transformToPicklistMap.get(jsonRelationshipNature.toUpperCase());
        }
        return jsonRelationshipNature;
    }
}