/**
 * @description This class is used to capture usage events on Account Action
 * View Details Click on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountActionViewEventController {
    /**
     * @description Account Action View Details 
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetails() {
        return true;
    }
    
    /**
     * @description Account Action View Details - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsOnAccount() {
        return true;
    }

    /**
     * @description Account Action View Details - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsOnCase() {
        return true;
    }

    /**
     * @description Account Action View Details - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsOnOpportunity() {
        return true;
    }

    /**
     * @description Account Action View Details - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account Action View Details - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsOnBillingAccount() {
        return true;
    }

    /**
     * @description Account Action View Details - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsOnClaim() {
        return true;
    }


    /**
     * @description Account Action View Details - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account Action View Details - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsOnSimpleConversation() {
        return true;
    }
}
