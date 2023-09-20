/**
 * @description This class is used to capture usage events on Insights/Indicators component visiblity
 * Logging which Indicators have been displayed on the component
 * @Date: 07/10/2023
 * @author: Team Skynet
 */

public with sharing class InsightEventController {
    /**
     * @description Indicator : Error_AP
     * @return Boolean
     * @throws AuraHandledException
     */
    @AuraEnabled
    public static boolean showAutoPropensityIndicator() {
        try {
            return true;
        } catch (Exception e){
			throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description Indicator : Error_PD
     * @return Boolean
     * @throws AuraHandledException
     */
    @AuraEnabled
    public static boolean showBillPastDueIndicator() {
        try {
            return true;
        } catch (Exception e){
			throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description Indicator : Error_TL
     * @return Boolean
     * @throws AuraHandledException
     */
    @AuraEnabled
    public static boolean showTotalLossIndicator() {
        try {
            return true;
        } catch (Exception e){
			throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description Indicator : ADT_Available
     * @return Boolean
     * @throws AuraHandledException
     */
    @AuraEnabled
    public static boolean showADTIndicator() {
        try {
            return true;       
        } catch (Exception e){
			throw new AuraHandledException(e.getMessage());
        }
    }

     /**
     * @description Indicator : Additional Info
     * @return Boolean
     * @throws AuraHandledException
     */
    @AuraEnabled
    public static boolean showAdditionalInfo() {
        try {
            return true;      
        } catch (Exception e){
			throw new AuraHandledException(e.getMessage());
        }
    }
}