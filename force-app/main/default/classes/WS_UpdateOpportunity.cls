/****************************************************************************************
Name: WS_UpdateOpportunity
=========================================================================================
Decription: 
@description - This REST Webservice class resides in Salesforce and will be invoked by JAVA webservice salesforceopportunity-api developed by Team ITIC and owned by Team Akita,
Will update Opportunities - This is the first API for updating an opportunity, so more changes coming in
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.00            Team Akita            10/02/2018               Initial Development
******************************************************************************************/
@RestResource(urlMapping='/updateopportunity/*')
global with sharing class WS_UpdateOpportunity {
    
    private static List<User> usr;
    private static List<Opportunity> opp;
    private static final String PROXY_CONCAT ='P';
    private static String proxyExternalID;
    private static final String UNDERSCORE = '_';
    private static final String CLASS_NAME = 'WS_UpdateOpportunity';
    private static final String CREATE_LEAD_MESSAGE_METHOD_NAME = 'updateOpportunity';
    private static final String SERVICEUSER =  '1.03 SF API Only User - Data & User Admin';

    
    private with sharing class ResponseData {    
        private Id opportunityId;
        private boolean isSuccess = true;
        private String failureMessage = '';
        
        //Constructor 
        private ResponseData (Id opportunityId){
            this.opportunityId= opportunityId;
        }
        
        private ResponseData (Id opportunityId, boolean isSuccess, String failedMessage){
            this.opportunityId= opportunityId;
            this.isSuccess = isSuccess;
            this.failureMessage = failedMessage;
        }     
    }     
    
    /***
     * @description - Http Post method for updating an opportunity
     * @param oppRequest
     */
    @HttpPost
    global static void updateOpportunity (HLPR_updateOppRequest oppRequest) { 

       UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', oppRequest.updateOpportunityData.salesforceOpportunityId, Opportunity.class);


        try{
            opp = [Select id from Opportunity where id=:oppRequest.updateOpportunityData.salesforceOpportunityId LIMIT 1 ];           
            if(opp!=null && !opp.isEmpty()){
                
                usr = [SELECT id, Name, Alias FROM user WHERE Associate_ID__c <>:UTIL_Constants.NO_SPACE and Associate_ID__c =:oppRequest.agentOfficeData.agentAssociateID 
                       and UserExternalid__C=:(oppRequest.agentOfficeData.agentAssociateID +'_'+oppRequest.agentOfficeData.agentAssociateID)
                       and IsActive = true limit 1];
                       validateUserAndUpdateProxy(oppRequest);      
            }else {
                throw new WS_UpdateOpportunityException(System.Label.CL_OpportunityID_Invalid_Message+' : '+ oppRequest.updateOpportunityData.salesforceOpportunityId);
            }
        }catch (Exception ex) {
            //log exception
            
            sendOppIdResponseWithFailure(oppRequest.updateOpportunityData.salesforceOpportunityId, ex);
            return;
        }       
        updateOpportunityAndSendResponse(oppRequest);
    }
    
    private static void validateUserAndUpdateProxy(HLPR_updateOppRequest oppRequest){
        if(usr != null && !usr.isEmpty()) {
            proxyExternalID = oppRequest.agentOfficeData.agentAssociateID+PROXY_CONCAT;                    
        }else if (oppRequest.agentOfficeData.agentAssociateID != null &&  !String.isEmpty(oppRequest.agentOfficeData.agentAssociateID)){                  
            throw new WS_UpdateOpportunityException(System.Label.CL_AgentAssociateID_Invalid_Message+' : '+oppRequest.agentOfficeData.agentAssociateID);
        }   
    }
    private static void updateOpportunityAndSendResponse(HLPR_updateOppRequest oppRequest){
        try{
            updateOpportunity(oppRequest,proxyExternalID);            
            sendOppIdIResponse(opp[0].id);   
        }Catch(Exception ex){
            LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);          
            sendOppIdResponseWithFailure(oppRequest.updateOpportunityData.salesforceOpportunityId, ex);
            return;
        }       
        if(opp[0].id!=null) {
            postMessages(opp[0].id, oppRequest);
        }
    }
/**
*  Asynchronous post messages
*  @description - post the messages for notifications
*  @name  postMessages
*  @param opportunityId - The opportunity to Post
*  @param oppRequest - Opportunity request
*  
*/
    private static void postMessages(String opportunityId, HLPR_updateOppRequest oppRequest) {                 
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
    
    private static void sendOppIdResponseWithFailure(Id oppId, Exception ex){        
        ResponseData responseObj = new ResponseData(oppId, false, ex.getMessage()); 
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseObj));
    }  
    
    private static void updateOpportunity(HLPR_updateOppRequest oppRequest,String proxyExternalID){
        List<Opportunity> oppNotification = Security.stripInaccessible(
               AccessType.READABLE,
               [SELECT IsOfficeNotified__c,Assigned_To__c, AppCode__c FROM Opportunity WHERE id=:opp[0].id LIMIT 1]).getRecords();

        Opportunity opportunity = new Opportunity();
        opportunity.id = oppRequest.updateOpportunityData.salesforceOpportunityId;
        //Owner
        if(String.isNotBlank(proxyExternalID)) {
            opportunity.Owner = new User(UserExternalID__c =proxyExternalID);
        }
        //StageName,Status,Substatus 
        updatingStageFields(oppRequest,opportunity);
        
        //Temperature
        if(String.isNotBlank(oppRequest.updateOpportunityData.temperature)) {
            opportunity.Temperature__c=oppRequest.updateOpportunityData.temperature;
        }
        //TotalPremium,MonthlyPremium
        updatingPremiumFields(oppRequest,opportunity);
        //IsOfficeNotified__c
        if(oppNotification[0].AppCode__c == UTIL_OpportunityProcessing.PLMOD_APP_CODE && oppRequest.agentOfficeData.sendNotification) {    
            if(String.isNotBlank(oppRequest.updateOpportunityData.assignedTo) || String.isNotBlank(oppNotification[0].Assigned_To__c) || !oppNotification[0].isOfficeNotified__c) { 
                opportunity.isOfficeNotified__c = true;
            } else {
                //ensuring that we do not notify again to office, if its unassigned still.
                oppRequest.agentOfficeData.sendNotification = false;
            }
        }
        //DateCaptured
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id=:profileId].Name;
        String partnerProfileName = System.label.ServiceUser;  
        AssignOpportunityClass assignOppClass = new AssignOpportunityClass();
        assignOppClass.partnerProfileName = partnerProfileName; 
        assignOppClass.profileName = profileName;
        assignOppClass.oppRequest = oppRequest;
        assignOppClass.opportunity = opportunity;
        assignOpportunity(assignOppClass);
    }

    /**
     * @description AssignOpportunityClass
     */
    private class AssignOpportunityClass{
        String partnerProfileName; 
        String profileName;
        HLPR_updateOppRequest oppRequest;
        Opportunity opportunity;
    }

    private static void assignOpportunity(AssignOpportunityClass assignOpp){
        if(assignOpp.partnerProfileName.equals(assignOpp.profileName) && String.isNotBlank(assignOpp.oppRequest.updateOpportunityData.submittedPhone)
            && getOldOpportunityPhone(assignOpp.oppRequest.updateOpportunityData.salesforceOpportunityId) != assignOpp.oppRequest.updateOpportunityData.submittedPhone) {
                assignOpp.opportunity.DateCaptured__c = system.now();
        }
        //Status
        if(String.isNotBlank(assignOpp.oppRequest.updateOpportunityData.Status)) {
            assignOpp.opportunity.Status__c = assignOpp.oppRequest.updateOpportunityData.Status;
        }
        //substatus 
        if(String.isNotBlank(assignOpp.oppRequest.updateOpportunityData.SubStatus)) {
            assignOpp.opportunity.Sub_Status__c = assignOpp.oppRequest.updateOpportunityData.SubStatus;
        }
        Id newAssignedToUser = getAssignedToUser(assignOpp.oppRequest);
        if(String.isNotBlank(newAssignedToUser)) {
            assignOpp.opportunity.Assigned_To__c = newAssignedToUser;
        }
 
        updateSubmittedPhoneAndEmail(assignOpp.oppRequest, assignOpp.opportunity);
        UTIL_OpportunityDAO.updateOpportunityForAccount(new List<Opportunity>{assignOpp.opportunity});               
        createOpportunityNote(assignOpp.oppRequest);
    }
    
    private static void updateSubmittedPhoneAndEmail(HLPR_updateOppRequest oppRequest, Opportunity opp){
        UTIL_OpportunityProcessing.setStringOppField(opp, Opportunity.Phone__c , oppRequest.updateOpportunityData.submittedPhone);
        UTIL_OpportunityProcessing.setStringOppField(opp, Opportunity.Email__c , oppRequest.updateOpportunityData.submittedEmail);
    }
    private static void updatingStageFields(HLPR_updateOppRequest oppRequest, Opportunity opportunity){
        //StageName
        if(String.isNotBlank(oppRequest.updateOpportunityData.stageName)) {
            opportunity.StageName=oppRequest.updateOpportunityData.stageName;
            //Status
            if(String.isNotBlank(oppRequest.updateOpportunityData.Status)) {
                opportunity.Status__c = oppRequest.updateOpportunityData.Status;
            }else {
                opportunity.Status__c = '';
            }
            //substatus 
            if(String.isNotBlank(oppRequest.updateOpportunityData.SubStatus)) {
                opportunity.Sub_Status__c = oppRequest.updateOpportunityData.SubStatus;
            }else{
                opportunity.Sub_Status__c = '';
            }
        }
    }

    private static void updatingPremiumFields(HLPR_updateOppRequest oppRequest, Opportunity opportunity) {
        //TotalPremium
        if(String.isNotBlank(oppRequest.updateOpportunityData.totalPremium)) {
            opportunity.Amount= decimal.valueOf(oppRequest.updateOpportunityData.totalPremium);
        }
        //MonthlyPremium
        if(String.isNotBlank(oppRequest.updateOpportunityData.monthlyPremium)) {
            opportunity.Monthly_Premium__c =decimal.valueof(oppRequest.updateOpportunityData.monthlyPremium);
        }
    }
    
    private static String getServicingAgentAssociateId(String oppId) {
        List<Opportunity> opp = Security.stripInaccessible(AccessType.READABLE, [SELECT Owner.Servicing_Agent_Associate_Id__c FROM Opportunity WHERE Id = :oppId]).getRecords();
        return opp.get(0).owner.servicing_agent_associate_id__c;
    }

    private static String getOldOpportunityPhone(String oppId) {
        List<Opportunity> opp = Security.stripInaccessible(AccessType.READABLE, [SELECT Phone__c FROM Opportunity WHERE Id = :oppId]).getRecords();
        return opp.get(0).Phone__c;
    }

    
    private static void createOpportunityNote(HLPR_updateOppRequest oppRequest){
        Opportunity opportunity = new Opportunity();
        opportunity.id = oppRequest.updateOpportunityData.salesforceOpportunityId;
        String description = oppRequest.updateOpportunityData.opportunityDescription;
        String details = oppRequest.updateOpportunityData.opportunityDetail;
        UTIL_CreateOpportunityNote.createOpportunityNoteBasedOnDescriptionAndDetail(description, details, opportunity);
    }
    
    private static Id getAssignedToUser(HLPR_updateOppRequest oppRequest) {
        Id newAssignedToId;
        String userExternalId =  oppRequest.updateOpportunityData.assignedTo + UNDERSCORE + getServicingAgentAssociateId(oppRequest.updateOpportunityData.salesforceOpportunityId);
        List<User> newAssignedToUser = Security.stripInaccessible(AccessType.READABLE, [SELECT Id FROM User WHERE UserExternalId__c = :userExternalId AND isActive = true]).getRecords();
        if (!newAssignedToUser.isEmpty()){
            newAssignedToId = newAssignedToUser.get(0).Id;
        }
        return newAssignedToId;
    }
}