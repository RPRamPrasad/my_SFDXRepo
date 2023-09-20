/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountAAGSendEmailEventController {
    /**
     * @description Account At A Glance Send Email
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendEmail() {
        return true;
    }
    
    /**
     * @description Account At A Glance Send Email - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendEmailOnAccount() {
        return true;
    }

    /**
     * @description Account At A Glance Send Email - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendEmailOnCase() {
        return true;
    }

    /**
     * @description Account At A Glance Send Email - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendEmailOnOpportunity() {
        return true;
    }

    /**
     * @description Account At A Glance Send Email - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendEmailOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account At A Glance Send Email - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendEmailOnBillingAccount() {
        return true;
    }

    /**
     * @description Account At A Glance Send Email - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendEmailOnClaim() {
        return true;
    }


    /**
     * @description Account At A Glance Send Email - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendEmailOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account At A Glance Send Email - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGSendEmailOnSimpleConversation() {
        return true;
    }

}
