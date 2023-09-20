/**
Author Team ClubCar
Name - CMP_NewCampaignMessageButton
@description This class will be invoked by NewCampaignMessageButton lightning component
Team: ClubCar
===========================================================================================
History
-------
VERSION         AUTHOR                      DATE                    DETAIL
1.0            Team ClubCar                2/14/2018              Initial Development
2.0            Team ClubCar                3/20/2020              Updated with SECURITY_ENFORCED feature
*******************************************************************************************/
public with sharing class CMP_NewCampaignMessageButton {
    
    private static final String CLASS_NAME = 'CMP_NewCampaignMessageButton';
    private static final String METHOD_NAME = 'getCampaignData'; 

    /**
    * @method Invoked by NewCampaignMessageButton Lightning Component
    * @description  getCampaignDataWithPermission used to retrieve campaign data with permission
    * @param campaignId - Opportunity or Account Id
    * @return campaignDataWithPermission
    */
    @AuraEnabled
    public static CampaignDataWithPermission getCampaignDataWithPermission(Id campaignId) {
        
        CampaignDataWithPermission campaignDataWithPermission;
        
        try {
            campaignDataWithPermission = new CampaignDataWithPermission(getCampaignList(campaignId)[0], CMP_RetrieveAccountMessages.isUserAnAgent());       
            
        } catch (Exception campaignDataException) {
            
            LoggingService.logHandledException(campaignDataException, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR); 
        }
        return campaignDataWithPermission;
    }
    /**
    * @description  getCampaignList used to retrieve campaign
    * @param campaignId
    * @return Campaign List
    */
    public static List<Campaign> getCampaignList(Id campaignId) {
        return [Select Id,RecordType.DeveloperName from Campaign where Id =:campaignId WITH SECURITY_ENFORCED LIMIT 1];
    }
    
    /**
    * @description  CampaignDataWithPermission used to Encapsulates Campaign and validation details required by NewCampaignMessageButtonHelper.js
    */
    public with sharing class CampaignDataWithPermission {
        
        @AuraEnabled
        public Campaign record = null;        
        
        @AuraEnabled
        public Boolean userMayView = false;
        
        /**
    	* @description  Encapsulates Campaign and validation details required by NewCampaignMessageButtonHelper.js
		* @param campaign
		* @param allowed
    	*/
        public CampaignDataWithPermission(Campaign campaign, Boolean allowed) {
            record = campaign;
            userMayView = allowed;
        }
    }   
}