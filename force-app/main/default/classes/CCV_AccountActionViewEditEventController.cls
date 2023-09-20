/**
 * @description This class is used to capture usage events on Account Action
 * Edit Click through View Details on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountActionViewEditEventController {
    /**
     * @description Account Action View Details : Edit
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsEdit() {
        return true;
    }
    
    /**
     * @description Account Action View Details - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsEditOnAccount() {
        return true;
    }

    /**
     * @description Account Action View Details : Edit - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsEditOnCase() {
        return true;
    }

    /**
     * @description Account Action View Details : Edit - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsEditOnOpportunity() {
        return true;
    }

    /**
     * @description Account Action View Details : Edit - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsEditOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account Action View Details : Edit - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsEditOnBillingAccount() {
        return true;
    }

    /**
     * @description Account Action View Details : Edit - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsEditOnClaim() {
        return true;
    }


    /**
     * @description Account Action View Details : Edit - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsEditOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account Action View Details : Edit - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickViewDetailsEditOnSimpleConversation() {
        return true;
    }
}
