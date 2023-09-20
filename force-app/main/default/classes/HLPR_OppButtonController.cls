/*
Author-QuadC Team
Helper class used by Lightning components for New App Quote, Policy Center and PLM buttons
Version     Author    Date                    Description
  1.1       Akita    11/14/2019   Added         @AuraEnabled to getProfileName() Method
  1.2       Quadcore 05/26/2020   Updated       logic of button display
*/
/**
 * @description HLPR_OppButtonController
 */
public with sharing class HLPR_OppButtonController {

    /**
     * @description inLightningExp
     * @return  `boolean`
     */
    @AuraEnabled
    public static boolean inLightningExp(){
        return (UserInfo.getUiThemeDisplayed().equals('Theme4d')||UserInfo.getUiThemeDisplayed().equals('Theme4u'))?true:false;
    }

    /**
     * @description getProfileName
     * @return  `string`
     */
    @AuraEnabled
    public static string getProfileName(){
        return UTIL_LtngProfileDataAccess.getProfileName();
    }
    /**
     * @description getOpportunity Retrieves the data from the opportunity object
     *
     * @param oppId (String): oppId }
     * @return opportunity: Return Opportunity Object
     */
    public static opportunity getOpportunity(String oppId){
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('oppId', oppId, Opportunity.class);
        List<Opportunity> oppList = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT  Account.IsHealthSourced__pc,State_Code__c,IsQuoteCanvasable__c,Product_system_name__c,account.clientidentifier__c,AgentAlias__c,OwnerServicingAgentAssociateID__c,LOB__c,accountId,StageName,Assigned_to__c,Opportunity_Originator__c,Credit_status__c,status__c,Requested_Effective_Date__c,product__c,OfficeAssigned__c, JointType__c, AdditionalOwner__c, AdditionalOwner__r.clientidentifier__c from Opportunity where id=:oppId
             ] ).getRecords();
        return !oppList.isEmpty() && oppList.size()>0 ? (Opportunity)oppList.get(0) : null;
    }

    /**
     * @description getResponseMap
     * getResponselist This method will return the responseMap back to Aura component
     * This method validates if Product system Name (PSN) is empty or not. If empty it will throw an error.
     * If not it will invoke EffectiveDate Validation
     * @param oppId (String): oppId description}
     * @return Map<String,String> 
     */
    @AuraEnabled
    public static Map<String,String> getResponseMap(String oppId){// change the name of the method
        Opportunity opp = getOpportunity(oppId);
        Map<String,String> responseMap = new Map<String,String>();
        if('No'.equalsIgnoreCase(UTIL_OppQuoteValidation.validateAndReturnHealthSource(opp))){
            responseMap =  UTIL_OppQuoteValidation.getResponseMapOnQuoteValidation(opp);
            responseMap.put('profileName',getProfileName());
            responseMap.put('ownerId',opp.OwnerServicingAgentAssociateID__c);
            responseMap.put('officeAssigned',opp.OfficeAssigned__c);
            responseMap.put('oppIsHealthSourced','No');
        }
        else{
            responseMap.put('oppIsHealthSourced','Yes');
        }
        return responseMap;
    }

    /**
     * @description isValidProfile Validates if the logged in profile is valid based on agent or atm
     *
     * @return boolean : Return boolean value
     */
    @AuraEnabled
    public Static boolean isValidProfile(){
        boolean isValid = false;
        String profileName = getProfileName();
        if(profileName.equals(label.CL_Agent_Profile) || profileName.equals(label.CL_ATM_Profile) || HLPR_OppButtonNavController.supportprofileForNewAppQuoteAndProductionManager(profileName)) {
            isValid = true;
        }
        return isValid;
    }

    /**
     * @description isOppCreatable
     * @return  `boolean`
     */
    @AuraEnabled
    public Static boolean isOppCreatable(){
        return Schema.sObjectType.Opportunity.isCreateable();
    }

    /**
     * @description isOppCreatableAndValidProfile
     * @return  `boolean`
     */
    @AuraEnabled
    public Static boolean isOppCreatableAndValidProfile(){
        return (isOppCreatable() && isValidProfile());
    }

    /**
     * @description isOppNewAndAssigned
     * @param oppId 
     * @return  `boolean`
     */
    @AuraEnabled
    public Static boolean isOppNewAndAssigned(String oppId){
        Opportunity opp = getOpportunity(oppId);
        String profileName = getProfileName();

        if((profileName.equals(label.CL_Agent_Profile)||profileName.equals(label.CL_ATM_Profile))
           && isOppNewAndAssignedToAnotherUser(opp.StageName,opp.Assigned_To__c)){
               return true;
           }
        return false;
    }

    /**
     * @description isOppNewAndAssignedToAnotherUser
     * @param stageName
     * @param assignedUser
     * @return boolean
     */
    //check opportunity stage is new and opportuntiy is assigned to another user
    public static boolean isOppNewAndAssignedToAnotherUser(String stageName, String assignedUser) {
        if(String.isNotBlank(stageName) && String.isNotEmpty(assignedUser) && stageName.equals('New') && !assignedUser.equals(UserInfo.getUserId())){
            return true;
        }
        return false;
    }

    //check for valid profiles for New App Quote and Production Manager

/**
 * @description isAllowedprofileForNewAppQuoteAndProductionManager
 * @return  `boolean`
 */
    @AuraEnabled
    public Static boolean isAllowedprofileForNewAppQuoteAndProductionManager(){
        boolean isValid = false;
        String profileName = getProfileName();
        if(profileName.equals(label.CL_Agent_Profile) || profileName.equals(label.CL_ATM_Profile)|| HLPR_OppButtonNavController.supportprofileForNewAppQuoteAndProductionManager(profileName) || profileName.equals(label.CL_TechSupport_Profile) || profileName.equals(label.CL_108BSUPPORT_PROFILE)) {
            isValid = true;
        }
        return isValid;
    }

    /**
     * @description oppButtonVisibility
     * @param oppId 
     * @return  `String`
     */
    @AuraEnabled
     public Static String oppButtonVisibility(String oppId){
        String profileName = getProfileName();
        Opportunity opp = getOpportunity(oppId);
        String opportunityOriginator =opp.Opportunity_Originator__c;
        String creditStatus = opp.Credit_status__c;
        if(profileName.equals(label.CL_Agent_Profile) || profileName.equals(label.CL_ATM_Profile)){
           return HLPR_OppButtonNavController.agentATMButtonVisibility(opportunityOriginator,creditStatus);
         }
        else {
            return HLPR_OppButtonNavController.oppBtnVbilityForNonAgentProfiles(opportunityOriginator,creditStatus,profileName);
        }
    }

    /**
     * @description queries isQuoteCanvasable__c field on Opp object
     * @param oppId
     * @return string
     */
    @AuraEnabled
    public Static String isOppQuoteCanvasable(String oppId){
        return HLPR_LWC_NewOpportunityWorkflow.isOppQuoteCanvasable(oppId);
    }

    /**
     * @description newAppQuoteUrl
     * @param oppId 
     * @param productDetails 
     * @return  `String`
     */
    @AuraEnabled
    public Static String newAppQuoteUrl(String oppId,String productDetails){
        OpportunityProduct__c oppProd = (OpportunityProduct__c)JSON.deserialize(productDetails,OpportunityProduct__c.class);
        Opportunity opp = getOpportunity(oppId);
        String profileName = getProfileName();
        return UTIL_OppQuoteValidation.newAppQuoteUrl(opp, oppProd, profileName);
    }

    /**
     * @description prodMgrURL
     * @param oppId 
     * @return  `String`
     */
    @AuraEnabled
    public Static String prodMgrURL(String oppId){
        Opportunity opp = getOpportunity(oppId);
        String profileName = getProfileName();
        return HLPR_OppButtonNavController.prodMgrURL(opp,profileName);
    }

    /**
     * @description getAppName
     * @return  `String`
     */
    @AuraEnabled
    public Static String getAppName(){
        return HLPR_OppButtonNavController.getApplicationName();
    }

    /**
     * @description updateOpportunity
     * @param oppId 
     * @return  `String`
     */
    @AuraEnabled
    public static String updateOpportunity(String oppId) {
        Opportunity opp = getOpportunity(oppId);
        return LWC_OppUpdateOnQuoting.validateAndInvokeOpp(opp);
    }
}