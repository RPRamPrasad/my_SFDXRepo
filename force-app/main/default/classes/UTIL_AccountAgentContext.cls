/**
@author Team STARK
@owner Team STARK
@name UTIL_AccountAgentContext
@createDate 05/31/2020
@ModifiedDate 
@description This class is used by LWC Account for Agent Context functionality (Non-Agency - CCC)
@version 1.0
*/
public with sharing class UTIL_AccountAgentContext {

    @TestVisible 
    private static Account customer = new Account();
    private static final String CLASS_NAME = 'UTIL_AccountAgentContext';
    private final static String INTERACTION_ID_ERROR_MESSAGE = 'The interaction id is not found.';
    private final static String CCC_SALES = Label.CL_CCCLicensedProfile;
   
    private static final String INSERT_AGENT_CONTEXT_FOR_CCC_USER = 'insertAgentContextforCCCUser';
    private static final String GET_CUSTOMER_LINK_FOR_SAVE_ACTION = 'getSalesCallTrackerLink';
    private static IDAO_AccountCreateEditHelper helperDAOInstance = new UTIL_AccountCreateEditHelper();
    private static User loggedInUser = helperDAOInstance.getLoggedInUser();
    private static Boolean isCCCuser { get; set; }
   
    private static String callTrackerUrl { get; set; }
    private static Boolean isCreate { get; set; }
    private static User selectedAgentContext { get; set; }    
     

    /**
    * @description This method is used to get Target domian
    * @name : getTargetDomains
    * @return String
    */
    @AuraEnabled(cacheable=true)
    public static String getTargetDomains() { 
        return UTIL_AccountCreateEdit_Additional.getTargetDomains(); 
    }

    /**
    * @description This method is used to retrieve users within a state/agent code
    * @name : queryForUserWithStAgtCode
    * @param stAgtCode : input state agent code
    * @return String : output servicing agent json
    */
    @AuraEnabled(cacheable = true)
    public static Object queryForUserWithStAgtCode(String stAgtCode) { // Method to query on User object with the State Agent Code
        Map<String,String> servAgtMap = new Map<String,String>();
        Boolean isStAgtUserFound = false;
        for (User stAgtCodeListedUser : helperDAOInstance.getUsersWithStAgtCode(stAgtCode)) {
            if (stAgtCodeListedUser.UserExternalID__c.equalsIgnoreCase(stAgtCodeListedUser.Associate_ID__c+UTIL_CreateCustomerConstants.UNDERSCORE+stAgtCodeListedUser.Associate_ID__c)) {
                servAgtMap.put('servicingAgentUserId',stAgtCodeListedUser.Id);
                servAgtMap.put('servicingAgentAssocId',stAgtCodeListedUser.Servicing_Agent_Associate_ID__c);
                servAgtMap.put('servicingAgentName',stAgtCodeListedUser.Name);
                isStAgtUserFound = true;
            }
        }
        if (!isStAgtUserFound) { servAgtMap.put('notFound','State agent user was not found.'); }
        return JSON.serialize(servAgtMap);
    }

    /**
    * @description This method is used to retrieve existing agent context using clientId
    * @name : populateAgentDetailsFromAgentContext
    * @param clientId : input customer client id
    * @return String : output agent name json
    */
    @AuraEnabled(cacheable = true)
    public static String populateAgentDetailsFromAgentContext(String clientId) {
        User loggedInUser = helperDAOInstance.getLoggedInUser();
        String agentContextId = loggedInUser.Associate_ID__c + UTIL_CreateCustomerConstants.TILDE;
        if (String.isNotBlank(clientId)) { agentContextId += clientId; }
        List<AgentContext__c> existingAgentContext = helperDAOInstance.getAgentContextDetails(agentContextId);
        if (existingAgentContext != null && !existingAgentContext.isEmpty()) { 
            Map<String,String> agtCntxMap = new Map<String,String>();
            agtCntxMap.put('servicingAgentUserId',existingAgentContext[0].Agent__c);
            agtCntxMap.put('servicingAgentAssocId',existingAgentContext[0].Agent__r.Associate_ID__c);
            agtCntxMap.put('servicingAgentName',existingAgentContext[0].Agent__r.Name);
            return JSON.serialize(agtCntxMap);
        }
        else { return null; }
    }

    /**
    * @description This method is used to get create Agent Context for CCC Users
    * @name : createAgentContextForCCCUser
    * @param accountId : input account id
    * @param isNewCustomer : input boolean value of is customer new ?
    * @param userJSON : input userJSON for user details
    * @return String : output url
    */
    @AuraEnabled
    public static String createAgentContextForCCCUser(String accountId, Boolean isNewCustomer, String userJSON) {
        isCCCUser = false;
        LoggedInUserDetails loggedInUser = (LoggedInUserDetails) JSON.deserializeStrict(userJSON,LoggedInUserDetails.class);
        for(CM_AgentContextAllowedProfile__mdt agentContextAllowedProfile : UTIL_AccountCreateEditHelper.getAgentContextAllowedProfile()) {
            if(loggedInUser.loggedInUserProfileName.equals(agentContextAllowedProfile.Profile__c)){
                isCCCUser = true;
                break;
            }
        }
        isCreate = isNewCustomer;
        customer = helperDAOInstance.getAccountDetails(accountId);
        String clientId = customer.ClientIdentifier__c;
        AgentContext__c agentContextWithOutClientId = populateAgentContextForClientId(null);
        AgentContext__c agentContextWithClientId = populateAgentContextForClientId(clientId);
        if(String.isNotBlank(loggedInUser.agentAssociateId)) { 
            selectedAgentContext = new User();
            selectedAgentContext = helperDAOInstance.getUsersWithAssociateId(loggedInUser.agentAssociateId)[0];
        }
        if (isCCCUser && selectedAgentContext != null) {
            callTrackerUrl = insertAgentContextforCCCUser(agentContextWithOutClientId,agentContextWithClientId, loggedInUser.loggedInUserProfileName);
        }
        return callTrackerUrl;
    }

    private static String insertAgentContextforCCCUser(AgentContext__c agentContextWithOutClientId, AgentContext__c agentContextWithClientId, String loggedInProfile) {
        AgentContext__c  newAgentContextWithOutClientId =agentContextWithOutClientId;
        Datetime halfHourBack = Datetime.now().addMinutes(-30);
        if(agentContextWithOutClientId == null) {
            if(agentContextWithClientId != null && agentContextWithClientId.LastModifiedDate >= halfHourBack) { 
                //update agentContextWithClientId with selected agent and retain Interaction Id & EIID

                UTIL_AgentContextDAO_Wrapper.UTIL_AgentContextDAOWrapper8 daoWrap8 = new UTIL_AgentContextDAO_Wrapper.UTIL_AgentContextDAOWrapper8();
                daoWrap8.agtContextId = null;
                daoWrap8.agentId = selectedAgentContext.Id;
                daoWrap8.cccUserId = UserInfo.getUserId();
                daoWrap8.accountId = customer.Id;
                daoWrap8.cccAssociateId = loggedInUser.Associate_ID__c.trim();
                daoWrap8.clientId = customer.ClientIdentifier__c;
                daoWrap8.interactionId = agentContextWithClientId.interactionId__c;
                daoWrap8.enterpriseInteractionId = agentContextWithClientId.EIID__c;

                newAgentContextWithOutClientId = UTIL_AgentContextDAO.populateAgentContextObject(daoWrap8);

                UTIL_AgentContextDAO.UpdateAgentContextWrapper8 updWrap = new UTIL_AgentContextDAO.UpdateAgentContextWrapper8();
                updWrap.agtContextId = agentContextWithClientId.Id;
                updWrap.agentId =  selectedAgentContext.id;
                updWrap.cccUserId =  UserInfo.getUserId();
                updWrap.accountId = customer.id;
                updWrap.cccAssociateId =  loggedInUser.Associate_ID__c.trim();
                updWrap.clientId =  customer.ClientIdentifier__c;
                updWrap.interactionId =  agentContextWithClientId.interactionId__c;
                updWrap.enterpriseInteractionId = agentContextWithClientId.EIID__c;

                Database.SaveResult updateAgentContextsResult = UTIL_AgentContextDAO.updateAgentContext(updWrap);
                LoggingService.logDatabaseResult(new Database.SaveResult[]{updateAgentContextsResult}, new AgentContext__c[]{agentContextWithClientId}, CLASS_NAME, INSERT_AGENT_CONTEXT_FOR_CCC_USER, System.LoggingLevel.ERROR);
            }
            else {
                //delete existing agentContextWithClientId
                deleteAgentContextForCCCUsers(agentContextWithClientId);
                
                UTIL_AgentContextDAO_Wrapper.UTIL_AgentContextDAOWrapper8 daoWrap8 = new UTIL_AgentContextDAO_Wrapper.UTIL_AgentContextDAOWrapper8();
                daoWrap8.agtContextId = null;
                daoWrap8.agentId = selectedAgentContext.Id;
                daoWrap8.cccUserId = UserInfo.getUserId();
                daoWrap8.accountId = customer.Id;
                daoWrap8.cccAssociateId = loggedInUser.Associate_ID__c.trim();
                daoWrap8.clientId = customer.ClientIdentifier__c;
                daoWrap8.interactionId = null;
                daoWrap8.enterpriseInteractionId = null;

                //upsert new agent context record without interaction id and EIID
                newAgentContextWithOutClientId = UTIL_AgentContextDAO.populateAgentContextObject(daoWrap8);
                UTIL_AgentContextDAO_Wrapper.UpsertAgentContextWrapper7 upsertWrap7 = new UTIL_AgentContextDAO_Wrapper.UpsertAgentContextWrapper7();
                upsertWrap7.agentId = selectedAgentContext.id;
                upsertWrap7.cccUserId = UserInfo.getUserId();
                upsertWrap7.accountId = customer.id;
                upsertWrap7.cccAssociateId = loggedInUser.Associate_ID__c.trim();
                upsertWrap7.clientId = customer.ClientIdentifier__c;
                upsertWrap7.interactionId = null;
                upsertWrap7.enterpriseInteractionId = null;

                Database.UpsertResult upsertAgentContextsResult = UTIL_AgentContextDAO.upsertAgentContext(upsertWrap7);
                LoggingService.logDatabaseResult(new Database.UpsertResult[]{upsertAgentContextsResult}, new AgentContext__c[]{agentContextWithOutClientId}, CLASS_NAME, INSERT_AGENT_CONTEXT_FOR_CCC_USER, System.LoggingLevel.ERROR);
            }
        }
        else {
                //This scenario is based on Gloabl Search or current Prod when agentContextWithOutClientId is not null and inserted by Internal GateWay
                //delete existing agentContextWithClientId
                deleteAgentContextForCCCUsers(agentContextWithClientId);
                
                //update agentContextWithClientId with selected agent and retain only Interaction Id & no EIID
                UTIL_AgentContextDAO.UpdateAgentContextWrapper8 updWrap = new UTIL_AgentContextDAO.UpdateAgentContextWrapper8();
                updWrap.agtContextId = newAgentContextWithOutClientId.Id;
                updWrap.agentId =  selectedAgentContext.id;
                updWrap.cccUserId =  UserInfo.getUserId();
                updWrap.accountId = customer.id;
                updWrap.cccAssociateId =  loggedInUser.Associate_ID__c.trim();
                updWrap.clientId =  customer.ClientIdentifier__c;
                updWrap.interactionId =  newAgentContextWithOutClientId.interactionId__c;
                updWrap.enterpriseInteractionId = null;
                Database.SaveResult updateAgentContextsResult = UTIL_AgentContextDAO.updateAgentContext(updWrap);
                LoggingService.logDatabaseResult(new Database.SaveResult[]{updateAgentContextsResult}, new AgentContext__c[]{agentContextWithOutClientId}, CLASS_NAME, INSERT_AGENT_CONTEXT_FOR_CCC_USER, System.LoggingLevel.ERROR);
            
        }
        
        callTrackerUrl = getSalesCallTrackerLink(newAgentContextWithOutClientId, loggedInProfile);
        return callTrackerUrl;
    }

    private static void deleteAgentContextForCCCUsers(AgentContext__c agentContextWithClientId) {
        if(agentContextWithClientId != null) {
            Database.DeleteResult deleteAgentContextResult = UTIL_AgentContextDAO.deleteAgentContext(agentContextWithClientId);
            LoggingService.logDatabaseResult(new Database.DeleteResult[]{deleteAgentContextResult}, new AgentContext__c[]{agentContextWithClientId}, CLASS_NAME, INSERT_AGENT_CONTEXT_FOR_CCC_USER, System.LoggingLevel.ERROR);
        }
    }

    private static  AgentContext__c populateAgentContextForClientId(String clientId) {
        String agentContextId = loggedInUser.Associate_ID__c.trim() + UTIL_CreateCustomerConstants.TILDE;
        if (String.isNotBlank(clientId)) { agentContextId += clientId.trim(); }
        List<AgentContext__c> existingAgentContext = helperDAOInstance.getAgentContextDetails(agentContextId);
        return existingAgentContext != null && existingAgentContext.size() > 0 ? existingAgentContext[0] : null;
    }

    private static String getSalesCallTrackerLink(AgentContext__c agtConxt, String loggedInProfile) {
        String callTrackerURL;
        if (loggedInProfile.equals(CCC_SALES) && isCreate) {
            String interactionId = agtConxt.InteractionId__c;
            if(String.isEmpty(agtConxt.InteractionId__c)) {              
                LoggingService.logHandledException(new callOutException(INTERACTION_ID_ERROR_MESSAGE),
                                                   CLASS_NAME, GET_CUSTOMER_LINK_FOR_SAVE_ACTION, System.LoggingLevel.WARN);    
                interactionId = LinkConstants.URL_BLANK_PARAMVALUE;
            }
            callTrackerURL = CL_Custom_Links.buildCallTrackerLinkForCCCSalesOnAccountCreate(customer.Id, interactionId);          
        }
        return callTrackerURL;
    }

    /**
    * @description This inner class is used to make request Address Wrapper JSON
    * @name : RequestAddressWrapper
    */
    public with sharing class LoggedInUserDetails {
        public String agentAssociateId;
        public String loggedInUserProfileName;
    }

}
