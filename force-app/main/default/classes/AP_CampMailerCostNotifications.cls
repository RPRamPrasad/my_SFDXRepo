/****************************************************************************************
Name: AP_CampMailerCostNotifications
Copyright © State Farm
=========================================================================================
@description : This class will be invoked by CampaignMessageAfterInsert, CampaignAfterUpdate
			   triggers and AP_Campaign_StartJourney class which will help to send Notifications to Agent and ATM when they Initiate Direct Mails
			   either from Order/Upload Leads or from OneOff or Start Journey operation
Team: ClubCar
=========================================================================================
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  04/27/2020              Initial Development
2.0             ClubCar                  05/17/2020              Added logic to send cost notifications after Start Journey Operation 
******************************************************************************************/ 
public with sharing class AP_CampMailerCostNotifications { 
    
    private static final String CLASS_NAME = 'AP_CampMailerCostNotifications';
    private static final String METHODNAME_ONEOFF = 'processOneOffSendNotifications';
	private static final String METHODNAME_LEADNOTIFICATIONS = 'processOrderUploadLeadSendNotifications';
    private static final String METHODNAME_STARTJOURNEYNOTIFICATIONS = 'processStartJourneySendNotifications';
    public static final String NOTIFICATIONTYPE_LEADNOTIFICATIONS = 'OrderLeadNotifications';
    public static final String NOTIFICATIONTYPE_ONEOFFNOTIFICATIONS = 'OneOffNotifications';
    public static final String NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS = 'StartJourneyNotifications';
    private static Map<Id,Id> campaignIdToInitatedOrLastModfdByIdMap = new Map<Id,Id>();
	private static Map<Id,Id> campaignIdToOwnerIdMap = new Map<Id,Id>();    
    public static EmailDataWrapper emailDataWrapper = new EmailDataWrapper();
 	private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();    
    
    /**
    * @method- Invoked by  CampaignMessageAfterInsert Trigger           
    * @description  This method will help us to form the email body with required campaign message details,
    * 				fetch the users who have performed the operation and send the email notifications as required
    * @name  processOneOffSendNotifications
    * @param  byPassObjectTrigger - boolean to check bypass trigger
    * @param  campMessageList - Campaign Messages List
    */    
    public static void processOneOffSendNotifications(Boolean byPassObjectTrigger,List<CampaignMessage__c> campMessageList){
        try{
            if(!isTriggerByPassedOrToggleOn(byPassObjectTrigger)){
                Map<Id,String> campIdToUserExternalIdMap = campaignToCampaignMessageMap(campMessageList);
                if(!emailDataWrapper.campIdToCampaignMessageMap.isEmpty()){                
                    getCampaignAndCampaignMessages(emailDataWrapper.campIdToCampaignMessageMap.keySet(),NOTIFICATIONTYPE_ONEOFFNOTIFICATIONS);                    
                    getAgentEmail(campIdToUserExternalIdMap);                    
                    HLPR_CampMailerCostNotifications.sendEmailNotifications(emailDataWrapper, NOTIFICATIONTYPE_ONEOFFNOTIFICATIONS);
                } 
            }
        }
        catch(Exception CampSendNotificationException){
            LoggingService.logHandledException(CampSendNotificationException, CLASS_NAME, METHODNAME_ONEOFF, LoggingLevel.ERROR);
        }        
    }
    
    /**
    * @method- Invoked by  CampaignAfterUpdate Trigger           
    * @description  This method will help us to form the email body with required campaign message details,
    * 				fetch the users who have performed the operation and send the email notifications as required
    * @name  processOrderUploadLeadSendNotifications
    * @param  byPassObjectTrigger - boolean to check bypass trigger
    * @param  updatedCampaignList - Campaign List
    * @param  oldCampaignMap - Old Campaign Map
    */
    public static void processOrderUploadLeadSendNotifications(Boolean byPassObjectTrigger, List<Campaign> updatedCampaignList, Map<Id,Campaign> oldCampaignMap){
        try{ 
            if(!isTriggerByPassedOrToggleOn(byPassObjectTrigger)){
                Set<Id> updatedLeadCampaignIds = getUpdatedLeadCampaignIds(updatedCampaignList,oldCampaignMap);
                if(!updatedLeadCampaignIds.isEmpty()){                    
                    getCampaignAndCampaignMessages(updatedLeadCampaignIds, NOTIFICATIONTYPE_LEADNOTIFICATIONS);
                    getOwnerIdToSvcAgentExtIdMap();
                    HLPR_CampMailerCostNotifications.sendEmailNotifications(emailDataWrapper, NOTIFICATIONTYPE_LEADNOTIFICATIONS);
                }
            }
        }
        catch(Exception CampSendNotificationException){
            LoggingService.logHandledException(CampSendNotificationException, CLASS_NAME, METHODNAME_LEADNOTIFICATIONS, LoggingLevel.ERROR);
        }        
    }    
    
    /**
    * @method- Invoked by  AP_Campaign_StartJourney Class           
    * @description  This method will help us to form the email body with required campaign message details, journey steps,
    * 				fetch the users who have performed the start journey operation and send the email notifications as required
    * @name  processStartJourneySendNotifications
    * @param  jrnyStartedCampaignId - Campaign Record Id
    * @param lastModifiedById
    */
    
    @future    
    public static void processStartJourneySendNotifications(id jrnyStartedCampaignId,Id lastModifiedById){
        try{
            if(!toggleContext.isActive(UTIL_Toggles.RESTRICTCAMPSENDNOTIFICATIONS)) {
                List<Campaign> campaignList = getCampaignAndCampaignMessages(new set<Id>{jrnyStartedCampaignId},NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS);
                getCampIdToOwnrIdAndLastModfdByIdMap(campaignList[0],lastModifiedById);
                getOwnerIdToSvcAgentExtIdMap();
                campaignIdToJrnyStepListMap(campaignList[0]);
                HLPR_CampMailerCostNotifications.sendEmailNotifications(emailDataWrapper, NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS);
            }            
        }
        catch(Exception CampSendNotificationException){
            LoggingService.logHandledException(CampSendNotificationException, CLASS_NAME, METHODNAME_STARTJOURNEYNOTIFICATIONS, LoggingLevel.ERROR);
        }        
    }
    
    //Helper method to check if trigger bypassed and sendnotifications is not toggled
    private static Boolean isTriggerByPassedOrToggleOn(Boolean byPassObjectTrigger) {       
        return CS001_ByPassTriggerAll__c.getInstance().Override_All__c || toggleContext.isActive(UTIL_Toggles.RESTRICTCAMPSENDNOTIFICATIONS) || byPassObjectTrigger;        
    }
    
    //Helper method to get campaign to campaignmessage map
    private static Map<Id,String> campaignToCampaignMessageMap(List<CampaignMessage__c> campMessageList){
        Map<Id,String> campIdToUserExternalIdMap = new Map<Id,String>();        
        for(CampaignMessage__c campMessage : campMessageList){
            if(String.isBlank(campMessage.JourneyID__c)){
                emailDataWrapper.campIdToCampaignMessageMap.put(campMessage.campaign__c, campMessage);
                campIdToUserExternalIdMap.put(campMessage.campaign__c,campMessage.AssociateID__c + '_' + campMessage.AssociateID__c);
            }
        }
        return campIdToUserExternalIdMap;
    }
    
    //Helper method to get campaignid to campaign map and campaignid to campaignmessagelist map
    private static List<Campaign> getCampaignAndCampaignMessages(Set<Id> campaignIds, String notificationType){
        List<Campaign> campaignList;
        if(notificationType.equals(NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS)){
            campaignList = [Select id,Total_Number_Members__c,Name,OwnerId,Journey_ID__c,Journey_Start_Date__c,(Select Cost__c, Itemid__c,TransmissionDate__c,Status__c,Journeyid__c,Mailclasscode__c,JourneyName__c,Campaign__c                                       
                            from CampaignMessage__r where Status__c != 'Cancelled - Stopped Journey' AND (Status__c = 'Sent' OR JourneyID__c = null) ORDER BY Transmissiondate__c) from Campaign where Id IN:campaignIds WITH SECURITY_ENFORCED];
        }																
        else{
            campaignList = [Select id,Total_Number_Members__c,Name,OwnerId,Journey_ID__c,Journey_Start_Date__c,(Select Cost__c, Itemid__c,TransmissionDate__c,Status__c,Journeyid__c,Mailclasscode__c,JourneyName__c,Campaign__c                                       
                            from CampaignMessage__r where Status__c != 'Cancelled - Stopped Journey' ORDER BY Transmissiondate__c) from Campaign where Id IN:campaignIds WITH SECURITY_ENFORCED];
        }
        
        for(Campaign camp : campaignList) {
            emailDataWrapper.campIdToCampMap.put(camp.Id,camp);    
            emailDataWrapper.campIdToCampaignMessageListMap.put(camp.Id, camp.CampaignMessage__r);
        }
        return campaignList;
    }
    
    //Helper method to get agent email
    private static void getAgentEmail(Map<Id,String> campIdToUserExternalIdMap){
        Map<String,String> userExtIdToEmailMap = new Map<String,String>();
        for(User usr : [Select Id,Email,Userexternalid__c from user where Userexternalid__c IN:campIdToUserExternalIdMap.values() WITH SECURITY_ENFORCED]){
            userExtIdToEmailMap.put(usr.UserExternalID__c,usr.Email);
        }
        getCampaignIdToAgentEmailMap(userExtIdToEmailMap,campIdToUserExternalIdMap);
    }
    
    //Helper method to get campaign id to agent email map
    private static void getCampaignIdToAgentEmailMap(Map<String,String> userExtIdToEmailMap,Map<Id,String> campIdToUserExternalIdMap){
        for(Id campaignId : campIdToUserExternalIdMap.keyset()){
            emailDataWrapper.campIdToAgentEmailMap.put(campaignId, userExtIdToEmailMap.get(campIdToUserExternalIdMap.get(campaignId)));           
        }
    }
    
    //Helper method to get updated lead campaign ids
    private static set<Id> getUpdatedLeadCampaignIds(List<Campaign> updatedCampaignList, Map<Id,Campaign> oldCampaignMap){
        Set<Id> updatedLeadCampaignIds = new set<Id>();
        Set<String> campaignTypeSet = new set<String>{'Lead', 'Lead Upload Individual','Lead Upload Organization'};
            for(Campaign updatedCampaign : updatedCampaignList){
                Campaign oldCampaign = oldCampaignMap.get(updatedCampaign.Id);
                if(oldCampaign.Status != null && updatedCampaign.Status != null && oldCampaign.Status.equals('Fulfillment Pending')
                   && updatedCampaign.Status.equals('Fulfillment Completed') && updatedCampaign.Journey_ID__c != null && campaignTypeSet.contains(updatedCampaign.Type)){
                       updatedLeadCampaignIds.add(updatedCampaign.Id);
                       campaignIdToOwnerIdMap.put(updatedCampaign.Id,updatedCampaign.ownerid);
                       campaignIdToInitatedOrLastModfdByIdMap.put(updatedCampaign.Id,updatedCampaign.Initiated_By_Id__c);
                   }           
            }       
        return updatedLeadCampaignIds;
    }
    
    //Helper method to get campaign ownerid to servicingagentexternalid map
    private static void getOwnerIdToSvcAgentExtIdMap(){
        if(!campaignIdToOwnerIdMap.isEmpty()){
            Map<Id,String> ownerIdToSvcAgentExtIdMap = new Map<Id,String>();
            for(User usr : [Select Id,Servicing_Agent_External_ID__c from user where Id IN:campaignIdToOwnerIdMap.values() WITH SECURITY_ENFORCED]){
                ownerIdToSvcAgentExtIdMap.put(usr.Id, usr.Servicing_Agent_External_ID__c);
            }
            getCampaignIdToAgentEmailAndInitiatedOrLastModfdUserMap(ownerIdToSvcAgentExtIdMap);
        }
    }
    
    //Helper method to get campaign id to agent email, initiated or lastmodified user map
    private static void getCampaignIdToAgentEmailAndInitiatedOrLastModfdUserMap(Map<Id,String> ownerIdToSvcAgentExtIdMap){
        Map<String,String> userExtIdToEmailMap = new Map<String,String>();
        Map<Id,User> userIdToUserMap = new Map<Id,User>();
        for(User usr : [Select Id,Email,Userexternalid__c,Name from user where Userexternalid__c IN:ownerIdToSvcAgentExtIdMap.values() OR Id IN:campaignIdToInitatedOrLastModfdByIdMap.values() WITH SECURITY_ENFORCED]){
            userExtIdToEmailMap.put(usr.UserExternalID__c,usr.Email);
            userIdToUserMap.put(usr.Id,usr);
        }
        for(Id campaignId : campaignIdToInitatedOrLastModfdByIdMap.keySet()){
            emailDataWrapper.campIdToAgentEmailMap.put(campaignId, userExtIdToEmailMap.get(ownerIdToSvcAgentExtIdMap.get(campaignIdToOwnerIdMap.get(campaignId))));
            emailDataWrapper.campIdToInitiatedOrLstModfdUserMap.put(campaignId,userIdToUserMap.get(campaignIdToInitatedOrLastModfdByIdMap.get(campaignId)));
        }
    }
    
    //Helper method to get campaign id to owner id and lastmodifiedbyid map on start journey
    private static void getCampIdToOwnrIdAndLastModfdByIdMap(Campaign jrnyStartedCampaign, Id lastModifiedById){
        campaignIdToOwnerIdMap.put(jrnyStartedCampaign.Id,jrnyStartedCampaign.OwnerId);        
        campaignIdToInitatedOrLastModfdByIdMap.put(jrnyStartedCampaign.Id,lastModifiedById);                
    }
    
    //Helper method to get campaign id to journey steps list map
    private static void campaignIdToJrnyStepListMap(Campaign jrnyStartedCampaign){        
        List<Journey_Step__c> jrnyStepList = [Select id,Cost__c,DaysNum__c,MailClassCode__c,ItemID__c,JourneyName__c,JourneyId__c from Journey_Step__c 
                                              where JourneyID__r.Journey_External_ID__c = :jrnyStartedCampaign.Journey_ID__c AND ContactMethodName__c = 'Mailing' WITH SECURITY_ENFORCED];
        emailDataWrapper.campIdToJrnyStepListMap.Put(jrnyStartedCampaign.Id,jrnyStepList);
    }
    
    /**
     * @description - wrapper class to pass necessary data to helper class
    */
    public with sharing class EmailDataWrapper {
        public Map<Id,Campaign> campIdToCampMap = new Map<Id,Campaign>();
        public Map<Id,String> campIdToAgentEmailMap = new Map<Id,String>();
        public Map<Id,User> campIdToInitiatedOrLstModfdUserMap = new Map<Id,User>();
        public Map<Id,List<CampaignMessage__c>> campIdToCampaignMessageListMap = new Map<Id,List<CampaignMessage__c>>();
        public Map<Id,CampaignMessage__c> campIdToCampaignMessageMap = new Map<Id,CampaignMessage__c>();
        public Map<Id,List<Journey_Step__c>> campIdToJrnyStepListMap = new Map<Id,List<Journey_Step__c>>();
    }    
}