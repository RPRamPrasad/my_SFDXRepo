/**
* @author : Team Sparky
* @date : 3/5/2020
* @name AT_ClaimsController
* @description : retrieves OData for AT_Claims lightning component
* Version : 1.0
*/
public with sharing class AT_ClaimsController {
    
    @TestVisible public static String subUserType = UTIL_CurrentUser.retrieveCurrentUser().SubUserType__c;
    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
    private static final String ENTERPRISE_LOSS_REPORTING = 'ENTERPRISE_LOSS_REPORTING';
    private static final String ECRM_CLAIMS_SUPPORT = 'ECRM_Claims_Support';

    /**
     * @name getClaimsByInsurancePolicyForAccount
     * @param clientIdentifier
     * @description returns a list of claims
     * @return List<Claim>
     */
    @AuraEnabled
    public static List<Claim> getClaimsByInsurancePolicyForAccount(String clientIdentifier){
        return UTIL_ClaimSearch.getClaimsByInsurancePolicyForAccount(clientIdentifier);
    }

    /**
     * @name getClaimsByHousehold
     * @param householdId
     * @description returns a list of claims
     * @return List<Claim>
     */
    @AuraEnabled
    public static List<Claim> getClaimsByHousehold(Id householdId){
        return UTIL_ClaimSearch.getClaimsByHousehold(householdId);
    }

    /**
     * @name isCCCRep
     * @description returns true if the logged in profile is a CCC Rep
     * @return Boolean
     */
    @AuraEnabled(cacheable=true)
    public static boolean isCCCRep() {
        return UTIL_Constants.CCC_SALES.equals(subUserType) || UTIL_Constants.CCC_SERVICE.equals(subUserType);
    }

     /**
     * @name isLossHistoryIframe
     * @description returns true if the current context is Loss History IFrame
     * @return Boolean
     */
    @AuraEnabled(cacheable=true)
    public static boolean isLossHistoryIframe() {
        return AT_ClaimsController.toggleContext.isActive(UTIL_Toggles.HOUSEHOLD_LOSS_HISTORY_IFRAME);
    }

    /**
     * @name isELRVisible
     * @return Boolean
     * @description This checks if the enterprise loss reporting feature is enabled 
     */
    @AuraEnabled(cacheable=true)
    public static Boolean isELRVisible() {
        return FeatureManagement.checkPermission(ENTERPRISE_LOSS_REPORTING);
    }

    /**
     * @name isSupportEnabled
     * @return Boolean
     * @description This checks if the ECRM_CLAIMS_SUPPORT is enabled 
     */
    @AuraEnabled(cacheable=true)
    public static Boolean isSupportEnabled() {
        try {
            return FeatureManagement.checkPermission(ECRM_CLAIMS_SUPPORT);
        }
        catch (Exception ex){
            throw new AuraHandledException('Error on isSupportEnabled ' + ex.getMessage());
        }
    }

}