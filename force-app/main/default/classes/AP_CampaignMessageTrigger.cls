/****************************************************************************************
Name: AP_CampaignMessageTrigger
Copyright © State Farm
=========================================================================================
@description : This class will be invoked by CampaignMessageAfterUpdate trigger
Campaign Enddate will be updated as per Campaign bumpdays logic mentioned in CM_CampaignExpiryDateLogic__mdt 
Team: ClubCar
=========================================================================================
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  05/10/2019              Initial Development
2.0             ClubCar                  06/01/2019              updated code review comments
3.0             ClubCar                  2/18/2020               Updated PMD finding for CRUD violations
******************************************************************************************/ 
public with sharing class AP_CampaignMessageTrigger {   

    private static final String CLASS_NAME = 'AP_CampaignMessageTrigger';
    private static final String METHODNAME = 'processCampaignMessages';
    private static final String IN_PROGRESS = 'inProgress';
    private static List<CM_CampaignExpiryDateLogic__mdt > expiryDateAdjustmentRulesList;
    private static Map<Id, Campaign> campaignIdToCampaignMap = new Map<Id, Campaign> ();
    private static final String CAMPMESSAGE_STATUS_SENT = 'Sent';
    private static final String CAMPMESSAGE_STATUS_CANCELLED = 'Cancelled - Stopped Journey';
    private static Map<String, List<CM_CampaignExpiryDateLogic__mdt>> expiryDateAdjustmentRuleSets = new Map<String, List<CM_CampaignExpiryDateLogic__mdt>>();
    private static List<Campaign> campaignsToUpdateList = new List<Campaign> ();
    
    /**
    * @method : processCampaignMessages
    * @description  : Entry level method called by CampaignMessageAfterUpdate Trigger
    * @param campaignMessagesList : List of Campiagn Messages   
    */
    public static void processCampaignMessages(List<CampaignMessage__c> campaignMessagesList) { 
        try {
            compileExpiryDateAdjustmentRuleSets();
            compileParentCampaignMap(campaignMessagesList);
            updateDirectMailSentCampaignsToInProgress(campaignMessagesList);
            applyExpiryDateAdjustmentRulesToCampaignMessages(campaignMessagesList);
            updateParentCampaigns();  
        }
        catch (Exception procCampMessageException) {
            LoggingService.logHandledException(procCampMessageException, CLASS_NAME, METHODNAME, LoggingLevel.ERROR);
        }
    }

    /**
    * @method : updateDirectMailSentCampaignsToInProgress
    * @description  : method that updates the CurrentPathStep__c of campaigns with a campaign message of status 'sent'
    * @param campaignMessages : List of Campiagn Messages   
    */
    private static void updateDirectMailSentCampaignsToInProgress(List<CampaignMessage__c> campaignMessages){
        Campaign campaign;
        for(CampaignMessage__c campaignMessage: campaignMessages){
            if(CAMPMESSAGE_STATUS_SENT.equalsIgnoreCase(campaignMessage.Status__c)){
                campaign = campaignIdToCampaignMap.get(campaignMessage.Campaign__c);
                campaign.CurrentPathStep__c = IN_PROGRESS;
            }
        }
    }
    /**
    * @method : applyExpiryDateAdjustmentRulesToCampaignMessages
    * @description  : Helper method to route campaign messages as per status
    * @param campaignMessagesList : List of Campiagn Messages   
    */
    private static void applyExpiryDateAdjustmentRulesToCampaignMessages(List<CampaignMessage__c> campaignMessagesList) {
        for (CampaignMessage__c updatedCampMessage : campaignMessagesList) {
            if(updatedCampMessage.Status__c.equals(CAMPMESSAGE_STATUS_SENT)) {
                updateCampExpiryDateOnMsgSent(updatedCampMessage);
            }
            else if (updatedCampMessage.Status__c.equals(CAMPMESSAGE_STATUS_CANCELLED)) {
                updateCampExpiryDateOnMsgCancel(updatedCampMessage);
            }
        }   
    }
    
    /**
    * @method : updateCampExpiryDateOnMsgSent
    * @description  : Helper method to process sent campaign message, campaign lastMessageSentdate__c field will be updated with message transmission date.
    *                 Campaign expiry date will be bumped if it meets criteria
    * @param sentCampaignMessage : Campiagn Message
    */
    private static void updateCampExpiryDateOnMsgSent(CampaignMessage__c sentCampaignMessage) {     
        Campaign campaignToUpdateForMsgSent = campaignIdToCampaignMap.get(sentCampaignMessage.Campaign__c);
        campaignToUpdateForMsgSent.LastMessageSentDate__c = sentCampaignMessage.TransmissionDate__c;
        Decimal daysToBump = getBumpDays(campaignToUpdateForMsgSent);
        if (daysToBump != null){
            date calculatedDate = addBumpDaysToDate(sentCampaignMessage.TransmissionDate__c, daysToBump);
            if(calculatedDate > campaignToUpdateForMsgSent.EndDate) {
                campaignToUpdateForMsgSent.EndDate = calculatedDate;        
            }
        }
        campaignsToUpdateList.add(campaignToUpdateForMsgSent);
    }

    /**
    * @method : updateCampExpiryDateOnMsgCancel
    * @description  : Helper method to route cancelled Campaign Message based on oneoff message or Journey Messages
    *                 no action would be taken on one off messages, only Journey Messages will update Campaign Expiry date
    * @param cancelledCampaignMessage : Campiagn Message
    */
    private static void updateCampExpiryDateOnMsgCancel(CampaignMessage__c cancelledCampaignMessage) {
        Campaign campaignToUpdateForMsgCancel = campaignIdToCampaignMap.get(cancelledCampaignMessage.Campaign__c);
        Decimal daysToBump = getBumpDays(campaignToUpdateForMsgCancel);
        if (daysToBump != null){
            if(campaignToUpdateForMsgCancel.LastMessageSentDate__c != null) {
                campaignToUpdateForMsgCancel.Enddate = addBumpDaysToDate(campaignToUpdateForMsgCancel.LastMessageSentDate__c, daysToBump);
            } else {
                campaignToUpdateForMsgCancel.Enddate = addBumpDaysToDate(campaignToUpdateForMsgCancel.StartDate, daysToBump);
            }
        }
        campaignsToUpdateList.add(campaignToUpdateForMsgCancel);
    }
    
    /**
    * @method : compileParentCampaignMap
    * @description  : Helper method to query parent campaigns for bumping campaign expiry date
    * @param campaignMessagesList : List of Campiagn Messages
    */
    private static void compileParentCampaignMap (List<CampaignMessage__c> campaignMessagesList) {
        campaignIdToCampaignMap = UTIL_CampaignData.getCampaignsFromCampaignMessages(campaignMessagesList);
   }
    
    /**
    * @method : compileExpiryDateAdjustmentRuleSets
    * @description  : Helper method to query custom metadata rules for campaign expiry
    */
    private static void compileExpiryDateAdjustmentRuleSets() {
        if (expiryDateAdjustmentRulesList == null || expiryDateAdjustmentRulesList.isEmpty()) {
            expiryDateAdjustmentRulesList = queryExpiryDateAdjustmentRules();
            for (CM_CampaignExpiryDateLogic__mdt expiryDateAdjustmentRule : expiryDateAdjustmentRulesList) {
                List<CM_CampaignExpiryDateLogic__mdt> expiryDateAdjustmentRulesForSameCampList  = null;
                expiryDateAdjustmentRulesForSameCampList = processAdjustmentRuleForCampaign(expiryDateAdjustmentRule, expiryDateAdjustmentRulesForSameCampList);
            }
        }
    }

    /**
     * @description processAdjustmentRuleForCampaign
     * @param expiryDateAdjustmentRule 
     * @param expiryDateAdjustmentRulesForSameCampList
     * @return List<CM_CampaignExpiryDateLogic__mdt>
     */
    private static List<CM_CampaignExpiryDateLogic__mdt> processAdjustmentRuleForCampaign(CM_CampaignExpiryDateLogic__mdt expiryDateAdjustmentRule, List<CM_CampaignExpiryDateLogic__mdt> expiryDateAdjustmentRulesForSameCampList){
        List<CM_CampaignExpiryDateLogic__mdt> expiryDateAdjustmentRules_SameCampList = expiryDateAdjustmentRulesForSameCampList;
        for(CM_CampaignExpiryDateLogic__mdt innerexpiryDateAdjustmentRule : expiryDateAdjustmentRulesList) {
            if (expiryDateAdjustmentRule.CampRecordTypeName__c.equals(innerexpiryDateAdjustmentRule.CampRecordTypeName__c)) {
                expiryDateAdjustmentRules_SameCampList = expiryDateAdjustmentRuleSets.get(expiryDateAdjustmentRule.CampRecordTypeName__c);
                expiryDateAdjustmentRules_SameCampList = (expiryDateAdjustmentRules_SameCampList == null)? new List <CM_CampaignExpiryDateLogic__mdt>():expiryDateAdjustmentRules_SameCampList;
                expiryDateAdjustmentRules_SameCampList.add(innerexpiryDateAdjustmentRule);
            }
            expiryDateAdjustmentRuleSets.put(expiryDateAdjustmentRule.CampRecordTypeName__c, expiryDateAdjustmentRules_SameCampList);
        }
        return expiryDateAdjustmentRules_SameCampList;
    }

    /**
    * @method : queryExpiryDateAdjustmentRules
    * @description  : Helper method to query campaignexpiry metadatarules list
    * @return List<CM_CampaignExpiryDateLogic__mdt> 
    */
    private static List<CM_CampaignExpiryDateLogic__mdt> queryExpiryDateAdjustmentRules() {       
        return [Select ActivationDate__c, DeactivationDate__c,CampRecordTypeName__c, Days__c
                from CM_CampaignExpiryDateLogic__mdt where BumpCampExpDate__c = true WITH SECURITY_ENFORCED];
    }

    /**
    * @method : getBumpDays
    * @description  : Helper method to retrieve bump days from custom metadata
    * @param parentCampaign
    * @return decimal : days to bump
    */
    private static decimal getBumpDays(Campaign parentCampaign) {
        List<CM_CampaignExpiryDateLogic__mdt> duplicateExpiryDateAdjustmentRuleForSameCampList = expiryDateAdjustmentRuleSets.get(parentCampaign.RecordType.DeveloperName);
        Decimal daysToBump = null;
        if (duplicateExpiryDateAdjustmentRuleForSameCampList!= null) {
            for (CM_CampaignExpiryDateLogic__mdt expiryDateAdjustmentRule : duplicateExpiryDateAdjustmentRuleForSameCampList) {
                if (parentCampaign.StartDate >= expiryDateAdjustmentRule.ActivationDate__c && parentCampaign.StartDate <= expiryDateAdjustmentRule.DeactivationDate__c) {
                    daysToBump = expiryDateAdjustmentRule.Days__c;
                    break;
                }
            }
        }
        return daysToBump;  
    }

    /**
    * @method : addBumpDaysToDate
    * @description  : Helper method to add bump days to passed date
    * @param passedDate
    * @param bumpDays
    * @return date : expiration date
    */
    private static date addBumpDaysToDate(date passedDate, decimal bumpDays) {
        return passedDate.addDays(bumpDays.intValue());
    }
    
    /**
    * @method : updateParentCampaigns
    * @description  : Helper method to perform dml update on campaignList
    */
    private static void updateParentCampaigns() {
        if (campaignsToUpdateList != null && !campaignsToUpdateList.isEmpty()) {
            update campaignsToUpdateList;
        }
    }
}