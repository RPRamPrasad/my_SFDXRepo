/**
 * @description This class is used to capture usage events on Account Action
 * Manage Household Click on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountActionManageHHEventController {
    /**
     * @description Account Action Manage Household 
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageHousehold() {
        return true;
    }
    
    /**
     * @description Account Action Manage Household - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageHouseholdOnAccount() {
        return true;
    }

    /**
     * @description Account Action Manage Household - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageHouseholdOnCase() {
        return true;
    }

    /**
     * @description Account Action Manage Household - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageHouseholdOnOpportunity() {
        return true;
    }

    /**
     * @description Account Action Manage Household - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageHouseholdOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account Action Manage Household - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageHouseholdOnBillingAccount() {
        return true;
    }

    /**
     * @description Account Action Manage Household - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageHouseholdOnClaim() {
        return true;
    }


    /**
     * @description Account Action Manage Household - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageHouseholdOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account Action Manage Household - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageHouseholdOnSimpleConversation() {
        return true;
    }
}
