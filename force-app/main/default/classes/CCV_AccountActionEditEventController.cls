/**
 * @description This class is used to capture usage events on Account Actions
 * Edit Click on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountActionEditEventController {
    /**
     * @description Account Action Edit 
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickEdit() {
        return true;
    }
    
    /**
     * @description Account Action Edit - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickEditOnAccount() {
        return true;
    }

    /**
     * @description Account Action Edit - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickEditOnCase() {
        return true;
    }

    /**
     * @description Account Action Edit - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickEditOnOpportunity() {
        return true;
    }

    /**
     * @description Account Action Edit - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickEditOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account Action Edit - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickEditOnBillingAccount() {
        return true;
    }

    /**
     * @description Account Action Edit - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickEditOnClaim() {
        return true;
    }


    /**
     * @description Account Action Edit - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickEditOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account Action Edit - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickEditOnSimpleConversation() {
        return true;
    }
}
