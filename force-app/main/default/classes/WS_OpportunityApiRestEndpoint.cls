/****************************************************************************************
Name: WS_OpportunityApiRestEndpoint
=========================================================================================
Decription: 
This is a REST webservice that will be called by the salesforceopportunity-api Java service. Its purpose is to accept opportunity create payloads,
determine whether a duplicate opportunity with those details already exists, then update the existing opportunity or create a new opportunity if
no duplicate exists.
=========================================================================================
History
-------
VERSION         AUTHOR                    						DATE                   DETAIL
1.00            Team Akita - Opportunity Management            1/14/2021               Initial Development
******************************************************************************************/
/**
 * @description WS_OpportunityApiRestEndpoint
 */
@RestResource(urlMapping='/createopportunity/*')
global with sharing class WS_OpportunityApiRestEndpoint {
    
    private static final String CLASS_NAME = 'WS_OpportunityApiRestEndpoint';
    private static final String CREATE_LEAD_MESSAGE_METHOD_NAME = 'createOpportunity';
    private static final String AGENTROLE_PROXY_EXP = 'Required fields are missing: [UserOrGroupId]';
    private static final String FOREIGN_KEY_EXP = 'Foreign key external ID';
    //private static final String SPI_ERROR ='Found SPI data in OpportunityDetail/OpportunityDescription field';
    private static User user;
    private static String proxyExternalID;
    private static final String PROXY_CONCAT ='P';
    private static List<Opportunity> opportunityList;
    
    private with sharing class ResponseData {    
        private Id opportunityId;
        private ResponseData (Id opportunityId){
            this.opportunityId= opportunityId;
        }     
    }
    
    /**
     * @description createOpportunity
     * @param oppRequest 
     */
    @HttpPost
    global static void createOpportunity (HLPR_CreateOppRequest oppRequest) {
        try {
            if (oppRequest != null) {
                WS_OpportunityApiRequestValidator.validateRequiredFields(oppRequest);
                populateAgentDataFields(oppRequest.agentOfficeData.agentAssociateID);
                if(oppRequest.opportunityData.doNotDedup==null || !oppRequest.opportunityData.doNotDedup){
                    opportunityList=WS_OpportunityApiRequestValidator.checkForDuplicateOpportunity(oppRequest,proxyExternalID); 
                } else{
                    opportunityList = new List<Opportunity>();
               }
            }
        }catch (Exception ex) {
            throw new WS_OpportunityApiRequestException(ex.getMessage(), ex);
        }
        if(!opportunityList.isEmpty()) {
            updateExistingOpportunity(opportunityList[0], oppRequest);
        } else {
            createNewOpportunity(oppRequest);
        } 
    }
    
    private static void populateAgentDataFields(String agentAssociateId){
        user = WS_OpportunityApiRequestValidator.checkForValidAgent(agentAssociateId);
        proxyExternalID = agentAssociateId+PROXY_CONCAT;
    }
    
    private static void updateExistingOpportunity(Opportunity opportunity, HLPR_CreateOppRequest oppRequest){ 
        try {
            updateOpportunityFields(opportunity, oppRequest);
            sendOppIdIResponse(opportunityList[0].Id);
            UTIL_CreateOpportunityNote.createOpportunityNoteBasedOnDescriptionAndDetail(oppRequest.opportunityData.Description, oppRequest.opportunityData.OpportunityDetail, opportunity);
        } catch(Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            throw new WS_OpportunityApiRequestException(ex.getMessage(), ex);
        }      
        postMessages(opportunityList[0].Id, oppRequest);
    }
    
    private static void updateOpportunityFields(Opportunity opp, HLPR_CreateOppRequest oppRequest) {
        if(oppRequest.opportunityData.appcode == UTIL_OpportunityProcessing.PLMOD_APP_CODE && oppRequest.agentOfficeData.sendNotification) {
            if(String.isNotBlank(opportunityList[0].Assigned_To__c) || !opportunityList[0].IsOfficeNotified__c) {
                opp.isOfficeNotified__c = true;
            } else {
                //ensuring that we do not notify to office, if its unassigned still.
                oppRequest.agentOfficeData.sendNotification = false;
            }
       } 
        if(String.isNotBlank(oppRequest.opportunityData.Temperature)) {
            opp.Temperature__c = oppRequest.opportunityData.Temperature;
        }   
        UTIL_OpportunityProcessing.setStringOppField(opp, Opportunity.Phone__c , oppRequest.opportunityData.phone);
        UTIL_OpportunityProcessing.setStringOppField(opp, Opportunity.Email__c , oppRequest.opportunityData.email); 
        opp = UTIL_OpportunityUtil.updateStageIfReOpen(opp, oppRequest.opportunityData.StageName);
        UTIL_OpportunityDAO.updateOpportunityForAccount(new List<Opportunity>{opp});
    }
    
    private static void createNewOpportunity(HLPR_CreateOppRequest oppRequest) {
        Savepoint sp1 = Database.setSavepoint();
        Opportunity opportunity;
        try {            
            opportunity = createOpportunityRecord(oppRequest, user);
            sendOppIdIResponse(opportunity.id);
            UTIL_CreateOpportunityNote.createOpportunityNoteBasedOnDescriptionAndDetail(oppRequest.opportunityData.Description, oppRequest.opportunityData.OpportunityDetail, opportunity);
            postMessages(opportunity.ID, oppRequest);
        } catch (Exception ex) {
            Database.rollback(sp1);
            LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            if ((ex.getmessage().contains(AGENTROLE_PROXY_EXP)) || (ex.getmessage().contains(FOREIGN_KEY_EXP))){
                throw new WS_OpportunityApiRequestException(System.Label.CL_PROXY_NOT_FOUND_ERROR + ex);
            }else{
                throw new WS_OpportunityApiRequestException(ex.getMessage(), ex);
            }
        }              
    }
    
    private static Opportunity createOpportunityRecord(HLPR_CreateOppRequest oppRequest, final User user) {
        Account account;
        account = UTIL_OpportunityProcessing.constructAccount(oppRequest);
        UTIL_AccountDAO.upsertAccountsByClientIdentifier(new List<Account>{account});              
        UTIL_OpportunityProcessing.upsertAgentRole(oppRequest, user, account);
        Opportunity opportunity = UTIL_OpportunityProcessing.constructOpportunity(oppRequest, account, proxyExternalID);
        UTIL_OpportunityDAO.insertOpportunityForAccount((new List<Opportunity>{opportunity}));        
        return opportunity;
    }   
    
    private static void postMessages(String opportunityId, HLPR_CreateOppRequest oppRequest) {         
        try {
            if(oppRequest.agentOfficeData.sendNotification){          
                UTIL_OpportunityNotificationManager.postOppNotifications(new List<String>{opportunityId}); 
            }            
        } catch(Exception ex) { 
            LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }  
    
    private static void sendOppIdIResponse(Id oppId){    
        ResponseData responseObj = new ResponseData(oppId); 
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseObj));
    }
}