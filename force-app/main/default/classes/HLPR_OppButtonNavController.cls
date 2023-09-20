/*
Author-QuadC Team
Helper class used by Lightning components for New App Quote, Policy Center and PLM buttons
Version     Author    Date                    Description
  1.0       Quadcore 05/26/2020               Logic of generate of URL's   
*/
/**
 * @description HLPR_OppButtonNavController
 */
public with sharing class HLPR_OppButtonNavController {
    private static final List<String> EXCLUDE_STAGE_NAMES = new String[] {'App Submitted', 'Not Now -  Follow Up', 'Closed', 'Closed Won'};
    private static final String QUOTE_IN_PROGRESS_STATUS = 'Quote In Progress';
    private static final List<String> EXCLUDE_STATUS_NAMES = new String[] {'Quote Provided', 'Application Pending'};
    private static final List<String> EXCLUDE_STAGE_NAMES_NAPQ = new String[] {'Quoting','App Submitted', 'Closed Won'};
    private static final List<String> EXCLUDE_STATUS_NAMES_NAPQ = new String[] {'Quote In Progress','Quote Provided', 'Application Pending'}; //

    /**
     * @description newAppQuoteUrl -- Generates the new App Quote url based on the logged in profile
     *
     * @param opp (Opportunity): opp object }
     * @param oppProd
     * @param profileName (String): profileName logged inprofile information}
     * @return String: Return generated url to launch new app quote application
     */
    @AuraEnabled
    public Static String newAppQuoteUrl(Opportunity opp, OpportunityProduct__c oppProd, String profileName){
        String stateAgentCode = opp.State_Code__c.split('/')[1].trim();
        String effectiveDate = String.valueOf(opp.Requested_Effective_Date__c);
        String url = '';
        if (supportprofileForNewAppQuoteAndProductionManager(profileName) || profileName.equals(label.CL_TechSupport_Profile) || profileName.equals(label.CL_108BSUPPORT_PROFILE)) {
            url = '/c/ExternalLinkApp.app?linkId=189&agentAssocId='+opp.OwnerServicingAgentAssociateID__c+'&accountId='+opp.AccountId+
                '&opportunityId='+opp.Id+'&lob='+opp.LOB__c+'&PID='+oppProd.Product_Id__c+
                '&effectiveDate='+effectiveDate+'&stateAgentCode='+stateAgentCode+'&LOBCD='+oppProd.Lob_Cd__c;
            String jointSecondClientId = '&jointSecondClientId=' + (String.IsNotEmpty(opp.AdditionalOwner__r.clientidentifier__c) ? opp.AdditionalOwner__r.clientidentifier__c : '');
            String jointType = '&jointType='+ (String.IsNotEmpty(opp.JointType__c) ? opp.JointType__c : '');
            url += jointSecondClientId + jointType;
            updateAssignedToIfBlankNewAppQuote(opp,null,profileName);
        }else if(profileName.equals(label.CL_Agent_Profile)||profileName.equals(label.CL_ATM_Profile)){
            // ProductParameters
            String appName = getApplicationName();
            url = '/c/ExternalLinkApp.app?linkId=88&accountId='+opp.AccountId+
                '&opportunityId='+opp.Id+'&lob='+opp.LOB__c+'&newStageName=Quoting'+'&PID='+oppProd.Product_Id__c+
                '&effectiveDate='+effectiveDate+'&stateAgentCode='+stateAgentCode+'&LOBCD='+oppProd.Lob_Cd__c+'&appName='+appName;
            String jointSecondClientId = '&jointSecondClientId=' + (String.IsNotEmpty(opp.AdditionalOwner__r.clientidentifier__c) ? opp.AdditionalOwner__r.clientidentifier__c : '');
            String jointType = '&jointType='+ (String.IsNotEmpty(opp.JointType__c) ? opp.JointType__c : '');
            url += jointSecondClientId + jointType;
            updateAssignedToIfBlankNewAppQuote(opp,UserInfo.getUserId(),profileName);   
        }
        return url;
    }
      /**
     * @description prodMgrURL -- Generates the Production Manager url based on the logged in profile
     *
     * @param opp (Opportunity): opp object }
     * @param profileName (String): profileName logged inprofile information}
     * @return String: Return generated url to launch Production Manager application
     */    
   @AuraEnabled
    public Static String prodMgrURL(Opportunity opp, String profileName){  
        String url = '';
        if (supportprofileForNewAppQuoteAndProductionManager(profileName) || profileName.equals(label.CL_TechSupport_Profile) || profileName.equals(label.CL_108BSUPPORT_PROFILE)) {
            url = '/c/ExternalLinkApp.app?linkId=20&agentAssocId='+opp.OwnerServicingAgentAssociateID__c+'&accountId='+opp.AccountId+
                '&userId='+opp.AgentAlias__c+'&opportunityId='+opp.Id;
                updateAssignedToIfBlank(opp,null,profileName);
            }else if(profileName.equals(label.CL_Agent_Profile)||profileName.equals(label.CL_ATM_Profile)){
                  String appName = getApplicationName();
            url = '/c/ExternalLinkApp.app?linkId=6&accountId='+opp.AccountId+'&appName='+appName;        
                updateAssignedToIfBlank(opp,UserInfo.getUserId(),profileName);
        }
        return url;
    }
     /**
     * @description updateAssignedToIfBlank Update the stage and assigned to value of opportunity.
     *
     * @param opp (Opportunity): opp object information}
     * @param associateId (String): associateId value of associate id to be updated}
     * @param profileName
     */
    private Static void updateAssignedToIfBlank(Opportunity opp, String associateId,String profileName){  
        Boolean toUpdate = false;
        if(opp != null && opp.Assigned_To__c == null && associateId != null ){
            opp.Assigned_To__c = associateId;
           toUpdate = true;
        }
        if (!(EXCLUDE_STAGE_NAMES).contains(opp.StageName)){
            		opp.StageName = 'Quoting';
            	if(!EXCLUDE_STATUS_NAMES.contains(opp.status__c))
            	{
                	opp.status__c = QUOTE_IN_PROGRESS_STATUS;
            	}
              toUpdate = true;
        }
        updateOpportunity(opp, toUpdate, profileName); 
    }
     /**
     * @description updateAssignedToIfBlankNewAppQuote Update the stage and assigned to value of opportunity.
     *
     * @param opp (Opportunity): opp object information}
     * @param associateId (String): associateId value of associate id to be updated}
     * @param profileName
     */
    private Static void updateAssignedToIfBlankNewAppQuote(Opportunity opp, String associateId,String profileName){  
        Boolean toUpdate = new HLPR_OppButtonNavController_Wrapper().updateAssignedToIfBlankNewAppQuote(opp, associateId, profileName);
        updateOpportunity(opp, toUpdate, profileName); 
    }
    /**
     *  @description This method will update the opportunity
     *  @param opp : opportunity information
     *  @param toUpdate : indicates if we need to update the opp or not
     *  @param profileName : indicates which profile it is agency or not
     */
    private static void updateOpportunity(Opportunity opp, Boolean toUpdate, String profileName){
        HLPR_OppButtonNavController_Wrapper navWrap = new HLPR_OppButtonNavController_Wrapper();
        navWrap.updateOpportunity(opp, toUpdate, profileName);
    }
     /**
     * @description agentATMButtonVisibility display buttons on opportunity page for agent and atm profile
     *
     * @param opportunityOriginator (String): opportunityOriginator is used to identify the type of opportunity}
     * @param creditStatus (String): creditStatus validate if the opportunity's credit status value}
     * @return String: Return the identifier which will help to display the buttons.
     */
    public static String agentATMButtonVisibility(String opportunityOriginator, String creditStatus){
        String oppButtonVisibility = '';
        if(!'Internet Lead Provider'.equals(opportunityOriginator) || 'RFC Requested'.equals(creditStatus) || 'RFC Not Granted'.equals(creditStatus) ){
            oppButtonVisibility = 'ilp';
        }
         else if('RFC Granted'.equals(creditStatus)){          
            oppButtonVisibility = 'rfcGranted';
         }
         else {
              oppButtonVisibility = 'isRFCToBeDisplay';
         }
         return oppButtonVisibility;
    }
       /**
     * agentATMButtonVisibility display buttons on opportunity page for non agent and atm profile
     * @description oppBtnVbilityForNonAgentProfiles
     * @param opportunityOriginator (String): opportunityOriginator is used to identify the type of opportunity}
     * @param creditStatus (String): creditStatus validate if the opportunity's credit status value}
     * @param profileName
     * @return String: Return the identifier which will help to display the buttons.
     */
    public  static String oppBtnVbilityForNonAgentProfiles(String opportunityOriginator, String creditStatus, String profileName){
        String oppButtonVisibility = '';
        if(Schema.sObjectType.Opportunity.isCreateable() && supportprofileForNewAppQuoteAndProductionManager(profileName)) 
        {
            oppButtonVisibility = 'ValidEdit';
        }
        else if(!Schema.sObjectType.Opportunity.isCreateable() && (supportprofileForNewAppQuoteAndProductionManager(profileName)||profileName.equals(label.CL_108BSUPPORT_PROFILE))){
            oppButtonVisibility = 'ValidRead';
        }
        else if (profileName.equals(label.CL_CCCUnlicensedProfile)||profileName.equals(label.CL_SALESLDR_PROFILE)){
            oppButtonVisibility = 'Hidden';
        } 
        return oppButtonVisibility;
    }   

    /**
     * @description supportprofileForNewAppQuoteAndProductionManager
     * @param loggedInProfile 
     * @return  `boolean`
     */
    public static boolean supportprofileForNewAppQuoteAndProductionManager(String loggedInProfile) {
        Boolean isAllowedProfile = false;
        for(CM_NewAppQuoteAndProdMgrAllowedProfile__mdt allowedProfile : UTIL_LtngProfileDataAccess.getSupportProfilesFromMetadata()) {
            if(loggedInProfile.equals(allowedProfile.Profile__c)) {
                isAllowedProfile = true;
            }
        }
        return isAllowedProfile;
    }
    
    /**
     * @description getApplicationName
     * @return  `String`
     */
    public static String getApplicationName() {

        return 'ECRM 3.0';
    }

    private with sharing class HLPR_OppButtonNavController_Wrapper{
        private void updateOpportunity(Opportunity opp, Boolean toUpdate, String profileName){
            if(toUpdate && Schema.sObjectType.Opportunity.isCreateable() && !profileName.equals(label.CL_TechSupport_Profile))
            {
                AP_OpportunityTrigger.doNotExecuteReOpenProcess();
                update Security.stripInaccessible(AccessType.UPDATABLE, new List<Opportunity>{opp}).getRecords();     
            }  
        }

        private Boolean updateAssignedToIfBlankNewAppQuote(Opportunity opp, String associateId,String profileName){  
            Boolean toUpdate = false;
            if(opp != null && opp.Assigned_To__c == null && associateId != null ){
                opp.Assigned_To__c = associateId;
                toUpdate = true;
            }
            if(!(EXCLUDE_STAGE_NAMES_NAPQ).contains(opp.StageName)){
                opp.StageName = 'Quoting';
                toUpdate = true;
            }
            if('Quoting'.equals(opp.StageName) && !EXCLUDE_STATUS_NAMES_NAPQ.contains(opp.status__c))
            {
                opp.status__c = QUOTE_IN_PROGRESS_STATUS;
                toUpdate = true;
            }

            return toUpdate;
        }
    }
}