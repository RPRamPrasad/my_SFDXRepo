/**
 * @description This class is used to capture usage events on Account Action
 * Manage Relationships Click on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountActionManRelnEventController {
    /**
     * @description Account Action Manage Relationships 
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageRelationships() {
        return true;
    }
    
    /**
     * @description Account Action Manage Relationships - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageRelshipsOnAccount() {
        return true;
    }

    /**
     * @description Account Action Manage Relationships - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageRelshipsOnCase() {
        return true;
    }

    /**
     * @description Account Action Manage Relationships - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageRelshipsOnOpportunity() {
        return true;
    }

    /**
     * @description Account Action Manage Relationships - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageRelshipsOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account Action Manage Relationships - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageRelshipsOnBillingAccount() {
        return true;
    }

    /**
     * @description Account Action Manage Relationships - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageRelshipsOnClaim() {
        return true;
    }


    /**
     * @description Account Action Manage Relationships - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageRelshipsOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account Action Manage Relationships - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageRelshipsOnSimpleConversation() {
        return true;
    }
}

