/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountAAGSendTextEventController {
    /**
     * @description Account At A Glance Send Text
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendText() {
        return true;
    }
    
    /**
     * @description Account At A Glance Send Text - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendTextOnAccount() {
        return true;
    }

    /**
     * @description Account At A Glance Send Text - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendTextOnCase() {
        return true;
    }

    /**
     * @description Account At A Glance Send Text - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendTextOnOpportunity() {
        return true;
    }

    /**
     * @description Account At A Glance Send Text - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendTextOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account At A Glance Send Text - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendTextOnBillingAccount() {
        return true;
    }

    /**
     * @description Account At A Glance Send Text - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendTextOnClaim() {
        return true;
    }


    /**
     * @description Account At A Glance Send Text - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendTextOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account At A Glance Send Text - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendTextOnSimpleConversation() {
        return true;
    }

}
