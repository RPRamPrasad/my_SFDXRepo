/**  
@Author Loco Motivated  
@Name UTIL_AgentOfficeDetails
@description This is a common Utilty class to map of Agent SFDC Id and his Offcie Id and checking Agent Office availability in SFDC
@Version 1.0
*/

public with sharing class UTIL_AgentOfficeDetails {
    
    private static Map<Id,Id> agentProxyMap=new Map<Id,Id>();
    private static final String CLASS_NAME='UTIL_AgentOfficeDetails';
    private static final String METHOD_NAME='getMapOfAgentAndProxyIds';
    private static final String P_CHAR='P';
    
    /**
    * @description getMapOfAgentAndProxyIds: Map of Agent SFDC Id and his Office Id    
    * @param agentRoleList
    * @return : return Map<Id,Id> of Agent SFDC Id and his Offcie Id
    */
    public static Map<Id,Id> getMapOfAgentAndProxyIds(List<AgentRole__c> agentRoleList) {
        if (!agentRoleList.isEmpty()){
            List<User> proxyUserList=Security.stripInaccessible(AccessType.READABLE,
                                                    [Select id,UserExternalID__c from User 
                                                     where UserExternalID__c in :getProxyExternalIdList(agentRoleList)]).getRecords();            
            if (!proxyUserList.isEmpty()){
                buildAgentProxyMap(proxyUserList, agentRoleList);
            }
        }
        return agentProxyMap;
    }
    
  /**
    * @method getMapOfAgentAndProxyIdsWithSFDCID: Map of Agent SFDC Id and his Office Id
    * @description Get Map Of Agent And Proxy Ids With SFDC ID
    * @param agentIdList
    * @return : return Map<Id,Id> of Agent SFDC Id and his Offcie Id
    */
    public static Map<Id,Id> getAgentProxyMapForGivenAgentIds(set<ID> agentIdList) {        
        List<User> agentUserList = Security.stripInaccessible(AccessType.READABLE,
                                                      [SELECT Proxy_External_ID__c,UserExternalID__c 
                                                       FROM User Where Id IN : agentIdList]).getRecords();
        Set<String> proxyExternalIdListFromAgentUserList=new Set<String>();
        for(User agentUser: agentUserList){
            proxyExternalIdListFromAgentUserList.add(agentUser.Proxy_External_ID__c);
        }
        
        List<User> proxyUserList=Security.stripInaccessible(AccessType.READABLE,
                                                    [Select id,UserExternalID__c 
                                                     from User 
                                                     where UserExternalID__c in :proxyExternalIdListFromAgentUserList]).getRecords();
        buildAgentProxyMap(proxyUserList,agentUserList);
        return agentProxyMap;
    }
    
     /**
    * @method getAgentProxyMapForGivenUserIds: Map of Agent SFDC ID and the corresponding Agent Proxy User
    * @description Get Agent Proxy User Map For Given User Ids
    * @param agentIdList
    * @return Map<Id, User>
    */
    public static Map<Id, User> getAgentProxyUserMapForGivenUserIds(set<ID> agentIdList) {  
        Set<String> proxyExternalIdListFromAgentUserList = new Set<String>();
        Map<Id, User> usedIdToProxyUserMap = new Map<Id, User>();

        List<User> userList = Security.stripInaccessible(AccessType.READABLE,
                            [SELECT Proxy_External_ID__c, UserExternalID__c 
                                          FROM User Where Id IN : agentIdList]).getRecords();        
        for(User agentUser: userList){
            proxyExternalIdListFromAgentUserList.add(agentUser.Proxy_External_ID__c);
        }
        
        List<User> proxyUserList =  Security.stripInaccessible(AccessType.READABLE, 
                                                       [Select id, UserExternalID__c, Servicing_Agent_Associate_ID__c 
                                                        from User 
                                                        where UserExternalID__c in :proxyExternalIdListFromAgentUserList]).getRecords();
        buildAgentProxyMap(proxyUserList, userList, usedIdToProxyUserMap);
        
        return usedIdToProxyUserMap;
    }
    
    
  /**
    * @method buildAgentProxyMap: Checking Agent has offcie set up in SFDC
    * @description Build Agent Proxy Map
    * @param proxyUserList
    * @param agentUserList
    */ 
    private static void buildAgentProxyMap(List<User> proxyUserList,List<User> agentUserList){
        Set<String> invalidAgentIdList = new Set<String>();
        for(User agentUser:agentUserList){
            if(!checkForProxyUser(proxyUserList,agentUser)) {
               invalidAgentIdList.add(agentUser.UserExternalID__c);
            }
        }
        logProxyNotFoundException(invalidAgentIdList);
    }
    
    private static void buildAgentProxyMap(List<User> proxyUserList,List<User> agentUserList,Map<id,User> usedIdToProxyUserMap){
        Set<String> invalidAgentIdList = new Set<String>();
        for(User agentUser:agentUserList){
            if(!checkForProxyUser(proxyUserList,agentUser,usedIdToProxyUserMap)) {
               invalidAgentIdList.add(agentUser.UserExternalID__c);
            }
        }
        logProxyNotFoundException(invalidAgentIdList);
    }
    
  /**
    * @method checkForProxyUser: To Check proxy are available in SFDC
    * @description Check For Proxy User
    * @param proxyUserList
    * @param agentUser
    * @return boolean
    */ 
    private static boolean checkForProxyUser(List<User> proxyUserList,User agentUser){
        Boolean isProxyFound=false;
        for(User proxyUser:proxyUserList){
                if(agentUser.Proxy_External_ID__c.equalsIgnoreCase(proxyUser.UserExternalID__c)){
                    isProxyFound=true;
                    agentProxyMap.put(agentUser.Id, proxyUser.id);
                }
        }
        return isProxyFound;
    } 
    
    private static boolean checkForProxyUser(List<User> proxyUserList,User agentUser,Map<id,User> usedIdToProxyUserMap){
        Boolean isProxyFound=false;
        for(User proxyUser:proxyUserList){
                if(agentUser.Proxy_External_ID__c.equalsIgnoreCase(proxyUser.UserExternalID__c)){
                    isProxyFound=true;
                    usedIdToProxyUserMap.put(agentUser.Id, proxyUser);
                }
        }
        return isProxyFound;
    } 
    
  /**
    * @method getProxyforGivenServicingAgentAssocId: User
    * @description Get Proxy For Given Servicing Agent AssocId
    * @param agentAssocId
    * @return : return User for the provided agent associate ID
    */
    public static User getProxyforGivenServicingAgentAssocId(string agentAssocId){
        User proxyUser;
        try{
            UTIL_ParameterValidator_AssociateId associateId = new UTIL_ParameterValidator_AssociateId();
            associateId.validateParameter('agentAssocId', agentAssocId);            
            proxyUser= (User)Security.stripInaccessible(AccessType.READABLE, [Select id,Name,UserExternalID__c,Associate_ID__c, 
                                                                              Servicing_Agent_Associate_ID__c 
                       From User Where UserExternalID__c =: agentAssocId + P_CHAR]).getRecords().get(0);             

            }catch(ListException exp){
                throw new ProxyUserNotFoundException('Proxy User not found: '+agentAssocId);
            }  
            return proxyUser;
    }
    
  /**
    * @method buildAgentProxyMap: Checking Agent has offcie set up in SFDC
    * @description Build Agent Proxy Map
    * @param proxyUserList
    * @param agentRoleList
    */ 
    private static void buildAgentProxyMap(List<User> proxyUserList,List<AgentRole__c> agentRoleList){
        Set<String> invalidAgentIdList = new Set<String>();
        for(AgentRole__c agentRole:agentRoleList){
            if(!checkForProxyUser(proxyUserList,agentRole)) {
               invalidAgentIdList.add(agentRole.Agent__r.UserExternalID__c);
            }
        }
        logProxyNotFoundException(invalidAgentIdList);
    }
    
    /**
    * @method checkForProxyUser: To Check proxy are available in SFDC
    * @description Check For Proxy User
    * @param proxyUserList
    * @param agentRole
    * @return : boolean
    */ 
    private static boolean checkForProxyUser(List<User> proxyUserList,AgentRole__c agentRole){
        Boolean isProxyFound=false;
        for(User proxyUser:proxyUserList){
                if(agentRole.Agent__r.Proxy_External_ID__c.equalsIgnoreCase(proxyUser.UserExternalID__c)){
                    isProxyFound=true;
                    agentProxyMap.put(agentRole.Agent__c, proxyUser.id);
                }
        }
        return isProxyFound;
    }
    
    /**
    * @method getProxyExternalIdList: Set of Agent's Proxy_External_ID__c for all List<AgentRole__c>
    * @description Get Proxy External Id List
    * @param agentRoleList
    * @return : Set<String>
    */  
    private static Set<String> getProxyExternalIdList(List<AgentRole__c> agentRoleList){
        Set<String> proxyExternalIdListFromAgentRoles=new Set<String>();
        for(AgentRole__c agentRole: agentRoleList){
            proxyExternalIdListFromAgentRoles.add(agentRole.Agent__r.Proxy_External_ID__c);
        }       
        return proxyExternalIdListFromAgentRoles;
    }
    
    /**
    * @method to log Proxy's Not Found Exception
    * @description Log Proxy Not Found Exception
    * @name   logProxyNotFoundException
    * @param invalidAgentIdList
    */ 
    public static void logProxyNotFoundException(Set<String> invalidAgentIdList){
        if(!invalidAgentIdList.isEmpty()){
            LoggingService.logHandledException(new ProxyUserNotFoundException('ASSOCIDs: '+invalidAgentIdList),
                                              CLASS_NAME, METHOD_NAME , LoggingLevel.WARN); 
        }
    }
}