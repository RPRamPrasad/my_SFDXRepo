/**
 * @description This class is used to capture usage events on Account Action
 * View Details - Setup SF COM Access on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountSetupSFAccessEventController {
    /**
     * @description Account Action View Details 
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickSetupSFComAccess() {
        return true;
    }
    
    /**
     * @description Account Action View Details - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickSetupSFComAccessOnAccount() {
        return true;
    }

    /**
     * @description Account Action View Details - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickSetupSFComAccessOnCase() {
        return true;
    }

    /**
     * @description Account Action View Details - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickSetupSFComAccessOnOpportunity() {
        return true;
    }

    /**
     * @description Account Action View Details - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickSetupSFComAccessOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account Action View Details - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickSetupSFComAccessOnBillingAccount() {
        return true;
    }

    /**
     * @description Account Action View Details - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickSetupSFComAccessOnClaim() {
        return true;
    }


    /**
     * @description Account Action View Details - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickSetupSFComAccessOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account Action View Details - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickSetupSFComAccessOnSimpleConversation() {
        return true;
    }
}
