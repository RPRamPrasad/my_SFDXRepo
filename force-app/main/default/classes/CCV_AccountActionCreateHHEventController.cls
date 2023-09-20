/**
 * @description This class is used to capture usage events on Account Action
 * Create Household Click on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountActionCreateHHEventController {
    /**
     * @description Account Action Create Household
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickCreateHousehold() {
        return true;
    }
    
    /**
     * @description Account Action Create Household - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickCreateHouseholdOnAccount() {
        return true;
    }

    /**
     * @description Account Action Create Household - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickCreateHouseholdOnCase() {
        return true;
    }

    /**
     * @description Account Action Create Household - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickCreateHouseholdOnOpportunity() {
        return true;
    }

    /**
     * @description Account Action Create Household - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickCreateHouseholdOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account Action Create Household - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickCreateHouseholdOnBillingAccount() {
        return true;
    }

    /**
     * @description Account Action Create Household - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickCreateHouseholdOnClaim() {
        return true;
    }


    /**
     * @description Account Action Create Household - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickCreateHouseholdOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account Action Create Household - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickCreateHouseholdOnSimpleConversation() {
        return true;
    }
}
