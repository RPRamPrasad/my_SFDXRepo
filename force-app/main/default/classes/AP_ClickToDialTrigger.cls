/*
*  Author: Team ITIC
*  Description: This Class helps validate the Trigger logic for Click to Dial Object. 
*/

/**
 * @description AP_ClickToDialTrigger
 */
public with sharing class AP_ClickToDialTrigger {
    
    private static AP_CallCenterHelper helper = new AP_CallCenterHelper();

    /**  
    * @Name:  updateAgencyOfficeCallCenterField
    * @description This method checks and validates inserted agents and marks the agency office with appropriate values
    * @param newRecords
    * @param  callCenterAdapter
    */ 
    public static void updateAgencyOfficeCallCenterField(List<Click_to_Dial__c> newRecords, String callCenterAdapter){
        Map<String, User> atmUsersMap = new Map<String, User>();
        Set<String> agentUsersToBeUpdated = new Set<String>();       
        for(Click_to_Dial__c insertedAgentUser :newRecords){
            agentUsersToBeUpdated.add(insertedAgentUser.Agent_Associate_ID__c);
        }  
        List<User> agentUsers = [SELECT Id, Name, Profile.name, Associate_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_Associate_ID_List__c, CallCenterId FROM User 
                                 WHERE Associate_ID__c = :agentUsersToBeUpdated AND Profile.NAME = :AP_UserProvisioningConstants.AGENT_PROFILE_NAME 
                                 AND MasterUserRecord__c = true WITH SECURITY_ENFORCED];
        
        if(User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
            List<User> agentToBeUpdate = updateCallCenter(agentUsers, callCenterAdapter);
            update agentToBeUpdate;
        }
        
        List<User> atmToBeUpdated =  queryForAgentTeamMembers(newRecords);
        helper.updateATMforClickToDialFunctionality(atmToBeUpdated, atmUsersMap);
        update atmUsersMap.values();
    }
    
    /**
    * @method: This method checks and validates inserted agents are throws an exception if they dont exist in User Object.
    * @Name:  throwError
    * @description verifyAgentExists
    * @param newRecords 
    */  
    public static void verifyAgentExists(List<Click_to_Dial__c> newRecords){
        Set<String> agtAssociateID = new Set<String>();
        for(Click_to_Dial__c agentUser : newRecords){
            agtAssociateID.add(agentUser.Agent_Associate_ID__c);
        }
        Integer agentUsers=[SELECT count () FROM User WHERE Associate_ID__c = : agtAssociateID AND Profile.NAME = :AP_UserProvisioningConstants.AGENT_PROFILE_NAME
                                 AND MasterUserRecord__c = true];
        for(Click_to_Dial__c agentUser : newRecords) {
            if(agentUsers == 0) {
                agentUser.adderror('Associate ID provided does not match with any Agent\'s Associate ID');             
            } 
        }    
    }
    
    /**
    * @method: This method returns the query of the inserted agents in click to dial and validates 
    *          if the values exist in Servicing Assoc List field on user object.
    * @Name:  queryForAgentTeamMembers
    * @description queryForAgentTeamMembers
    * @param newRecords
    * @return : List
    */      
    public static List<User> queryForAgentTeamMembers(List<Click_to_Dial__c> newRecords){
        Set<String> userInformation = new Set<String>();
        for(Click_to_Dial__c agent : newRecords){
            userInformation.add(agent.Agent_Associate_ID__c);
        } 
        
        return  [SELECT Id, Name, Profile.name, Associate_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_Associate_ID_List__c, CallCenterId FROM User 
                 WHERE Servicing_Agent_Associate_ID__c IN :userInformation AND Profile.NAME = :AP_UserProvisioningConstants.ATM_PROFILE_NAME AND isActive = true WITH SECURITY_ENFORCED];
        
    }
    
    /**
    * @method: This method fetches the records from the Callcenter object for the inserted agents in  click to dial object.
    * @Name:  updateCallCenter
    * @description updateCallCenter
    * @param agentServicingAssociateIdInfo
    * @param document
    * @return : List
    */
    public static List<User> updateCallCenter(List<User> agentServicingAssociateIdInfo, String document){   
        Map<String,String> callcenterType= AP_CallCenterHelper.CallCenterData();
        List<User> agentOfficeToBeUpdated = new list<User>();
        for(User agencyUser : agentServicingAssociateIdInfo){
            if(agencyUser.Profile.name != AP_UserProvisioningConstants.PROXY_PROFILE_NAME){
                agencyUser.CallCenterId = callCenterType.get(document); 
                agencyUser.ClickToDialEnabled__c = false;
                if((AP_UserProvisioningConstants.NONCCLA).equals(document)){
                    agencyUser.ClickToDialEnabled__c = true;
                }
                agentOfficeToBeUpdated.add(agencyUser);
            }
        }
        return agentOfficeToBeUpdated;
    }  
}