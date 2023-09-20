/**
* @Name: OfficeProxyLookupFlowHelper
* @Created: 11/04/2019
* @Author: Grumpy Cats
* @description Supports Proxy look ups inside flows
*/

public without sharing class OfficeProxyLookupFlowHelper {
    /**
     * @description officeProxyLookup
     * @param flowInputs 
     * @return  `List<FlowOutputs>`
     */
    @InvocableMethod
    public static List<FlowOutputs> officeProxyLookup(List<FlowInputs> flowInputs){
        List<FlowOutputs> results = new List<FlowOutputs>();
        FlowOutputs result = new FlowOutputs();
        if(String.isNotBlank(flowInputs.get(0).currentUserId)){
            User currentUser = getCurrentUserInfo(flowInputs.get(0).currentUserId);
            Id proxyUserId = getProxyUserInfo(currentUser.Proxy_External_ID__c);
            result.proxyId = proxyUserId;
            result.servicingAgentAssociateId = currentUser.Servicing_Agent_Associate_ID__c;
            results.add(result);
        }
        return results;
    }

    /**
     * @description getCurrentUserInfo
     * @param currentUserId 
     * @return  `User`
     */
    public static User getCurrentUserInfo(String currentUserId){
        User currentUser = new User();
        try{
             currentUser = [SELECT Id, Proxy_External_Id__c, Servicing_Agent_Associate_ID__c FROM User WHERE Id =: currentUserId LIMIT 1]; 
         }catch(QueryException  ex){
                LoggingService.logHandledException(ex, 'OfficeProxyLookupFlowHelper', 'getCurrentUserInfo', System.LoggingLevel.ERROR);
         }
        return currentUser;
    }
    /**
     * @description getProxyUserInfo
     * @param proxyExternalId 
     * @return  `Id`
     */
    public static Id getProxyUserInfo(String proxyExternalId){
        Id proxyId;
        try{
            proxyId = [SELECT Id FROM User WHERE UserExternalId__c =: proxyExternalId LIMIT 1].Id;
        }catch(QueryException  ex){
               LoggingService.logHandledException(ex, 'OfficeProxyLookupFlowHelper', 'getProxyUserInfo', System.LoggingLevel.ERROR); 
        }
        return proxyId;
    }
    /**
     * @description FlowInputs
     */
    public without sharing class FlowInputs{ 
        
        @InvocableVariable
        public String currentUserId;

    }
    /**
     * @description FlowOutputs
     */
    public without sharing class FlowOutputs{       
        @InvocableVariable
        public String proxyId;
        
        @InvocableVariable
        public String servicingAgentAssociateId;
    }
    
}