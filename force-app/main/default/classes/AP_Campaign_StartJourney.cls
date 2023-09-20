/****************************************************************************************
Name: AP_Campaign_StartJourney
=========================================================================================
* @description : This class will update the Campaign record with selected Journey Details and create Journey Tasks and call CMM on TP
Team: ClubCar
=========================================================================================
VERSION         AUTHOR                    	DATE                    DETAIL
1.0             Team Dream Builders         09/13/2017              Initial Development
2.0             Team TrailBlazers           02/16/2018              Invoking AP_JourneyTracker to track START Journey actions on Campaign
3.0             Team Golden Spikes          03/07/2018              18R02 - Updated the JourneyStep query criteria for createJourneyTasks to include additional contactMethodName - Other, Appointment.
4.0             Team Golden Spikes          03/16/2018              18R02 - Updated createCampaignMessage logic for populating additional campaign message fields for all campaigns.
5.0             Team Pike                   04/19/2018              Removed LOB_OTHER as the value is no longer in the Task picklist values
6.0             Team ClubCar                08/15/2018              Added logic to send Campiagn Messages to Acxiom for all Campaign except Customer Prospect
7.0             Team ClubCar                06/14/2019              Removed references to Task - Journey recordtype
8.0             Team ClubCar                08/15/2019              Updated callout to TP2.0 CMM
9.0        		Team ClubCar              	02/20/2020     			Updated PMD finding for CRUD violations
10.0			Team ClubCar              	05/17/2020     			Invoking AP_CampMailerCostNotifications to send cost notifications after start journey operation
******************************************************************************************/

public with Sharing class AP_Campaign_StartJourney {
    
    private static final String CLASS_NAME = 'AP_Campaign_StartJourney';
    private static final String METHOD_NAME = 'campaignStartJourney';
    private static final String START_JOURNEY_ACTION_TYPE = 'Journey Started';

    /**
    * @method - campaignStartJourney
    * @description - entry method for the class
    * @param campaignJourneyRequest - List of Campaign and Journey Id's
    * @return Boolean
    */ 
    public static List<Boolean> campaignStartJourney(List<CampaignJourneyRequest> campaignJourneyRequest) {
        List<Boolean> flowUpdateExceptionList = new List<Boolean>();
        Savepoint sp = Database.setSavepoint();
        try {
            if (campaignJourneyRequest != null && !campaignJourneyRequest.isEmpty()) {
                Campaign selectedCampaign = getCampaignDetails(campaignJourneyRequest.get(0).campaignId);
                Journey__c selectedJourney = getJourneyDetails(campaignJourneyRequest.get(0).journeyId);
                String servicingAgentAssociateId = getServicingAgentAssocId(selectedCampaign.OwnerId);
                selectedCampaign.Journey_Start_Date__c = campaignJourneyRequest.get(0).selectedJourneyDate;
                addJourneyDetailsOnCampaign(selectedCampaign, selectedJourney);                
                HLPR_AcxiomCampaignMessageCallout.callCmmServiceForPostOperation(selectedCampaign, selectedJourney.Id, servicingAgentAssociateId);
                AP_JourneyTracker.trackCampaignJourney(START_JOURNEY_ACTION_TYPE, new List<Campaign>{selectedCampaign});                
                flowUpdateExceptionList.add(false);
            } 
            else  {
                flowUpdateExceptionList.add(true);
            }
        } catch(Exception flowExpection) {
            Database.rollback(sp);
            LoggingService.logHandledException(flowExpection, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);
            flowUpdateExceptionList.add(true);
        }   
        return flowUpdateExceptionList;
    }
/**
 * @description updateCampaignAndStartJourney
 * @param campaignId 
 * @param journeyId 
 * @param journeyStartDate 
 * @return  `Boolean`
 */
    @AuraEnabled
    public static Boolean updateCampaignAndStartJourney(String campaignId, String journeyId, Date journeyStartDate) {
        Savepoint sp = Database.setSavepoint();
        try {
                Campaign selectedCampaign = getCampaignDetails(campaignId);
                Journey__c selectedJourney = getJourneyDetails(journeyId);
                String servicingAgentAssociateId = getServicingAgentAssocId(selectedCampaign.OwnerId);
                selectedCampaign.Journey_Start_Date__c = journeyStartDate;
                addJourneyDetailsOnCampaign(selectedCampaign, selectedJourney);
            	AP_CampMailerCostNotifications.processStartJourneySendNotifications(selectedCampaign.Id, getCampLastModfdById(selectedCampaign.Id));            
                HLPR_AcxiomCampaignMessageCallout.callCmmServiceForPostOperation(selectedCampaign, selectedJourney.Id, servicingAgentAssociateId);
                AP_JourneyTracker.trackCampaignJourney(START_JOURNEY_ACTION_TYPE, new List<Campaign>{selectedCampaign});
                return true;
            
        } catch(Exception flowExpection) {
            Database.rollback(sp);
            LoggingService.logHandledException(flowExpection, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);
           	return false;
        }   
    }
    
    //Helper method to get campaign lastmodifedbyid
    private static Id getCampLastModfdById(Id campaignId){
        return [Select id,LastModifiedbyId from Campaign where Id = :campaignId WITH SECURITY_ENFORCED Limit 1].LastModifiedbyId;
    }
    
    /**
    * @method - addJourneyDetailsOnCampaign
    * @description - Helper method to update Campagin record with selected Journey Information 
    * @param currentCampaign - Campagin record
    * @param currentJourney - Selected Journey record
    */
    private static void addJourneyDetailsOnCampaign(Campaign currentCampaign, Journey__c currentJourney) {
        currentCampaign.Journey_ID__c = currentJourney.Journey_External_ID__c;
        currentCampaign.Journey_Name__c = currentJourney.JourneyName__c;
        currentCampaign.Journey_Description__c = currentJourney.JourneyDescription__c;
        Database.update(currentCampaign); 
    } 

    /**
    * @method - getCampaignDetails
    * @description - helper method to query campaign details based on campaignId
    * @param campaignId - Campaign and Journey Id
    * @return Campaign - Campaign details
    */ 
    private static Campaign getCampaignDetails(String campaignId) {
        return [Select id, OwnerId,Campaign_Identifier__c,Name,Journey_Start_Date__c,Journey_Name__c,External_Campaign_ID__c,Journey_ID__c,
                Campaign.RecordType.DeveloperName from Campaign where id =:campaignId WITH SECURITY_ENFORCED Limit 1];
    }

    /**
    * @method - getJourneyDetails
    * @description - helper method to query journey details based on journeyId
    * @param journeyId - Campaign and Journey Id
    * @return Journey__c - Journey details
    */  
    private static Journey__c getJourneyDetails(String journeyId) {
        return [Select id,JourneyName__c, JourneyDescription__c, Journey_External_ID__c 
                from Journey__c where id =:journeyId WITH SECURITY_ENFORCED Limit 1];
    }

    /**
    * @method - getServicingAgentAssocId
    * @description - helper method to query servicingAgentAssociateId based on campaignownerid
    * @param campaignOwnerId : Campaign OwnerId
    * @return String - ServicingAgent AssociateId 
    */ 
    private static String getServicingAgentAssocId(Id campaignOwnerId) {
        return [Select id, Servicing_Agent_Associate_ID__c from User where id =: campaignOwnerId WITH SECURITY_ENFORCED Limit 1].Servicing_Agent_Associate_ID__c;
    }
    
	/**
    * @description -  CampaignJourneyRequest
	*/
    public with sharing class CampaignJourneyRequest {
        
        public String campaignId;        
        public String journeyId;        
        public Date selectedJourneyDate;        
    }
}