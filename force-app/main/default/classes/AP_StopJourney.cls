/****************************************************************************************
Name: AP_StopJourney
=========================================================================================
* @description : This class will update the Campaign record to remove all Journey Details, cancel Journey Tasks and call CMM on TP
Team: ClubCar
=========================================================================================
VERSION    AUTHOR               DATE           DETAIL
8.0        ClubCar              02/20/2020     Updated PMD finding for CRUD violations
9.0        ClubCar              08/23/2021     added logic to cancel campaign messages in salesforce
10.0        ClubCar             09/20/2021     updated logic to cancel just Journey messages and not one offs 
******************************************************************************************/ 

public with sharing class AP_StopJourney {
    private static final String SCHEDULED_JOURNEY_CAMPAIGN_STATUS = 'Scheduled';
    private static final String EMPTY_STRING = '';
    private static final String CLASS_NAME = 'AP_StopJourney';
    private static final String TASK_STATUS_CANCELLED  = 'Cancelled';
    private static final String METHOD_NAME = 'stopJourneyFromlWC';
    private static final String STOP_JOURNEY_ACTION_TYPE = 'Journey Stopped';

    /**
    * @method - stopJourneyFromlWC
    * @description - Entry method from stop Journey on campaign LWC
    * @param campaignId - Campaign Id
    * @return Boolean
    */
    //method to perform stop journey action from Campaign Start/stop journey LWC Component.
    @AuraEnabled
    public static Boolean stopJourneyFromlWC(Id campaignId) {
       Savepoint sp = Database.setSavepoint();
       try{
            Campaign stoppedJourneyCampaign = getCampaignDetails(campaignId);
            AP_JourneyTracker.trackCampaignJourney(STOP_JOURNEY_ACTION_TYPE, new List<Campaign>{stoppedJourneyCampaign});
            cancelJourneyTasksForCampaign(stoppedJourneyCampaign);
            clearJourneyDetailsOnCampaign(stoppedJourneyCampaign);
            cancelJourneyCampaignMessages(stoppedJourneyCampaign.CampaignMessage__r);
            callCmmAndCancelCampaignMessages(stoppedJourneyCampaign);
            return true;           
        } catch(Exception ex) {
            Database.rollback(sp);
            LoggingService.logHandledException(ex, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);
            return false;
        }
    }

    /**
    * @method - clearJourneyDetailsOnCampaign
    * @description - This method will clear Journey fields on Campaign
    * @param stoppedJourneyCampaign - Campaign
    */
    private static void clearJourneyDetailsOnCampaign (Campaign stoppedJourneyCampaign) {
        stoppedJourneyCampaign.Journey_ID__c = EMPTY_STRING;
        stoppedJourneyCampaign.Journey_Description__c = EMPTY_STRING;
        stoppedJourneyCampaign.Journey_Name__c = EMPTY_STRING;
        stoppedJourneyCampaign.Journey_Start_Date__c = null;
        updateCampaign(stoppedJourneyCampaign);
    }

    private static void cancelJourneyCampaignMessages(List<CampaignMessage__c> campMessageList) {
        List<CampaignMessage__c> cmpMsgCancelList = new List<CampaignMessage__c>();
        for (CampaignMessage__c cmpMsg : campMessageList){
            if(cmpMsg.status__c.equals(SCHEDULED_JOURNEY_CAMPAIGN_STATUS)){
                cmpMsg.status__c = 'Cancelled - Stopped Journey';
                cmpMsgCancelList.add(cmpMsg);
            }
        }
        updateCampMsgList(cmpMsgCancelList);
    }

    /**
    * @method - getCampaignDetails
    * @description - helper method to query campaign details based on campaignId
    * @param campaignId - Campaign Id
    * @return Campaign 
    */
    private static Campaign getCampaignDetails(Id campaignId) {
        return [select id, RecordType.DeveloperName, Journey_Name__c, Name, External_Campaign_ID__c, Ownerid, 
                Journey_ID__c,  (select status__c from CampaignMessage__r where Status__c = :SCHEDULED_JOURNEY_CAMPAIGN_STATUS
                                    AND JourneyNumber__c != null) from Campaign where Id = :campaignId WITH SECURITY_ENFORCED];
        
    }

    /**
    * @method - callCmmAndCancelCampaignMessages
    * @description - This method will call CMM and campaign messages will be cancelled through webservice
    * @param stoppedJourneyCampaign - Campaign
    */
    private static void callCmmAndCancelCampaignMessages (Campaign stoppedJourneyCampaign){
        List<CampaignMessage__c> campaignMessagesTobeCancelled  = stoppedJourneyCampaign.CampaignMessage__r;
        if(campaignMessagesTobeCancelled!=null && !campaignMessagesTobeCancelled.isEmpty()) {
            HLPR_AcxiomCampaignMessageCallout.callCmmServiceForPutOperation(campaignMessagesTobeCancelled);               
        }
    }
    
    /**
    * @method - cancelJourneyTasksForCampaign
    * @description - To Cancel the Journey Tasks on Campaign
    * @param stoppedJourneyCampaign - Campaign
    */
    private static void cancelJourneyTasksForCampaign(Campaign stoppedJourneyCampaign){        
        Journey__c journeyOnCampaign = [Select id from Journey__c where Journey_External_ID__c =:stoppedJourneyCampaign.Journey_ID__c WITH SECURITY_ENFORCED Limit 1];
        //Updating Journey Task as Cancelled
        if (journeyOnCampaign != null) {
            List<Task> journeytaskToCancel = [Select id from Task where JourneyId__c =: journeyOnCampaign.ID and Whatid =: stoppedJourneyCampaign.Id and IsClosed = False WITH SECURITY_ENFORCED];
            for (Task journeyTask : journeytaskToCancel) {
                journeyTask.Status = TASK_STATUS_CANCELLED;
            }
            updateTaskList(journeytaskToCancel);       
        }
    }

    //method to update task list after stop journey operation
    private static void updateCampMsgList (List<CampaignMessage__c> cmpMsgListToCancel) {
        if(!cmpMsgListToCancel.isEmpty() && Schema.sObjectType.CampaignMessage__c.fields.Status__c.isUpdateable()) {
            Database.update(cmpMsgListToCancel);
        }  
    }
    
    //method to update task list after stop journey operation
    private static void updateTaskList (List<Task> taskListToCancel) {
        if(taskListToCancel !=null && !taskListToCancel.isEmpty() && Schema.sObjectType.Task.fields.Status.isUpdateable()) {
            Database.update(taskListToCancel);
        }  
    }
    
    //method to update campaign after stop journey operation
    private static void updateCampaign (Campaign stoppedJourneyCampaign) {
        if(Schema.sObjectType.Campaign.isUpdateable()){
            Database.update(stoppedJourneyCampaign);
        }
    }
}