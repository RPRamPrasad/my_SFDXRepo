/**
* Author : Locomotivated Team
* Date Created : 4/18/2018
* @description : This class will update the ProductsServicedByMe__C owner to Agents Office when 
* a productsServicedByMeOwnner is assigned as Agent or ATM.
* This class will also prevent the deletion of Activity and Events
* Version : 1.0 Initial Development
*/

public with sharing class AP_ProductsServicedByMeTrigger {
    
    private static final String CLASSNAME = 'AP_ProductsServicedByMeTrigger';
    private static final String METHODNAME = 'updateOwnerWithAgentProxy';
    private static final String OWNERID_FIELD_API_NAME='Ownerid';
    
/**
* @description : This method will assign ownership of the Products Serviced by me  to Agents Office 
* @name :updateOwnerWithAgentProxy
* @param productsServicedByMeList
*/     
    public static void updateOwnerWithAgentProxy(List<ProductsServicedByMe__c> productsServicedByMeList) { 
        try {
            Profile loggedInUserprofileDetails=[Select id,Name from profile where id=:userinfo.getProfileId()];
            if(loggedInUserprofileDetails.Name.equalsIgnoreCase(UTIL_Constants.AGENT_PROFILE_NAME)||loggedInUserprofileDetails.Name.equalsIgnoreCase(UTIL_Constants.ATM_PROFILE_NAME)){
                mapOwnerIdAndAgentDetails(productsServicedByMeList);
            }else{
                mapOwnerIdBasedOnAgentLookup(productsServicedByMeList);
            }
        }
        catch(Exception e) {
            UTIL_AgentProxySelection.tagAllErrors(productsServicedByMeList, e.getMessage());
            LoggingService.logHandledException(e, CLASSNAME, METHODNAME, LoggingLevel.ERROR);
        }
    }
    
/**
* @description : This method will assign ownerid to proxy and Agent__c to the servicing agent on the Products Serviced by me based on the OwnerId feild
* @name :mapOwnerIdAndAgentDetails
* @param productsServicedByMeList
*/     
    private static void mapOwnerIdAndAgentDetails(List<ProductsServicedByMe__c> productsServicedByMeList) {
        
        Map<Id,User> ownerProxyExtIdDetailsMap = generateOwnerProxyExtIdDetailsMap(productsServicedByMeList, OWNERID_FIELD_API_NAME);
        Map<String,id> servicingAgentMap= getProxyToAgentMap(ownerProxyExtIdDetailsMap);
        for(ProductsServicedByMe__c productsServicedByMe:productsServicedByMeList){
            if(ownerProxyExtIdDetailsMap.get(productsServicedByMe.ownerId)!=null){
                String servicingAgentAssocId=ownerProxyExtIdDetailsMap.get(productsServicedByMe.ownerId).Servicing_Agent_Associate_ID__c;
                productsServicedByMe.Agent__c=servicingAgentMap.get(servicingAgentAssocId + '_' + servicingAgentAssocId );
                productsServicedByMe.ownerId=ownerProxyExtIdDetailsMap.get(productsServicedByMe.ownerId).id;
                
            } else{
                productsServicedByMe.addError(System.Label.CL_Exception_Message);  
            }
        }      
    }
    
    /**
* @description : This method will assign ownership of the Products Serviced by me  to Agents Office based on the Agent Lookup feild
* @name :mapOwnerIdBasedOnAgentLookup
* @param productsServicedByMeList
*/     
    public static void mapOwnerIdBasedOnAgentLookup(List<ProductsServicedByMe__c> productsServicedByMeList){
        
        Map<Id,User> ownerProxyExtIdDetailsMap = generateOwnerProxyExtIdDetailsMap(productsServicedByMeList, 'Agent__c');
        for(ProductsServicedByMe__c productsServicedByMe:productsServicedByMeList){
            if(String.isNotBlank(productsServicedByMe.Agent__c) && ownerProxyExtIdDetailsMap.get(productsServicedByMe.Agent__c)!=null){
                User ownerProxy = ownerProxyExtIdDetailsMap.get(productsServicedByMe.Agent__c);
                productsServicedByMe.ownerId=ownerProxy.id;
            }else{
                productsServicedByMe.addError(System.Label.CL_Exception_Message);    
            }
        }
    }

    /**
* @description : Utility Method to build the agent to proxy map.
* @name :generateOwnerProxyExtIdDetailsMap
* @param  productsServicedByMeList
* @param  fieldAPINameKey
* @return : Map<Id, User>
*/     
           
    private static Map<Id, User> generateOwnerProxyExtIdDetailsMap(List<ProductsServicedByMe__c> productsServicedByMeList, String fieldAPINameKey) { 
		Set<Id> agentIdList = new Set<Id>();
        for(ProductsServicedByMe__c createdProducts : productsServicedByMeList) {
            Id value = (Id)createdProducts.get(fieldAPINameKey); 
            if(String.isNotBlank(value)) {
                 agentIdList.add(value);
            }
        }
        
        return UTIL_AgentOfficeDetails.getAgentProxyUserMapForGivenUserIds(agentIdList);
    }
    
    /**
* @description : Utility Method to build the servicing agent associate id to agents salesforce Id map
* @name :getProxyToAgentMap
* @param  ownerProxyExtIdDetailsMap 
* @return :  Map<String,id>
*/     
    private static Map<String,id> getProxyToAgentMap(Map<Id,User> ownerProxyExtIdDetailsMap){
        List<String> agentExtIdList=new List<String>();
        Map<String,id> servicingAgentMap=new Map<String,Id>();
        for(User proxyUser:ownerProxyExtIdDetailsMap.values()){
            agentExtIdList.add(proxyUser.Servicing_Agent_Associate_ID__c + '_' + proxyUser.Servicing_Agent_Associate_ID__c );
        }
        
        List<User> agentDetailsList=(List<User>)Security.stripInaccessible(AccessType.READABLE,[Select id,UserExternalID__c from user where UserExternalID__c IN :agentExtIdList]).getRecords();
        for(User agentUser:agentDetailsList){
            servicingAgentMap.put(agentUser.UserExternalID__c,agentUser.id);
        }
        return servicingAgentMap;
    }
}