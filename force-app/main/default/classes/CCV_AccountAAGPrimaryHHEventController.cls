/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountAAGPrimaryHHEventController {
    /**
     * @description Account At A Glance Primary Household
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGPrimaryHousehold() {
        return true;
    }
    
    /**
     * @description Account At A Glance Primary Household - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGPrimaryHHOnAccount() {
        return true;
    }

    /**
     * @description Account At A Glance Primary Household - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGPrimaryHHOnCase() {
        return true;
    }

    /**
     * @description Account At A Glance Primary Household - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGPrimaryHHOnOpportunity() {
        return true;
    }

    /**
     * @description Account At A Glance Primary Household - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGPrimaryHHOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account At A Glance Primary Household - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGPrimaryHHOnBillingAccount() {
        return true;
    }

    /**
     * @description Account At A Glance Primary Household - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGPrimaryHHOnClaim() {
        return true;
    }


    /**
     * @description Account At A Glance Primary Household - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGPrimaryHHOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account At A Glance Primary Household - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGPrimaryHHOnSimpleConversation() {
        return true;
    }

}
