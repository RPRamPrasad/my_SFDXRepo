/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountAAGVerticalTabEventController {
    /**
     * @description Account At A Glance 
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAtAGlanceVerticalTab() {
        return true;
    }
    
    /**
     * @description Account At A Glance - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGVerticalTabOnAccount() {
        return true;
    }

    /**
     * @description Account At A Glance - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGVerticalTabOnCase() {
        return true;
    }

    /**
     * @description Account At A Glance - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGVerticalTabOnOpportunity() {
        return true;
    }

    /**
     * @description Account At A Glance - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGVerticalTabOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account At A Glance - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGVerticalTabOnBillingAccount() {
        return true;
    }

    /**
     * @description Account At A Glance - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGVerticalTabOnClaim() {
        return true;
    }


    /**
     * @description Account At A Glance - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGVerticalTabOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account At A Glance - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGVerticalTabOnSimpleConversation() {
        return true;
    }

}
