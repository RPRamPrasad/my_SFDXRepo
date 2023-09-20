/**
 * @description This class is used to capture usage events on Account Household Members
 * Vertical Tab Click on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountHHMVerticalTabEventController {
    /**
     * @description Account Household Members 
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHouseholdMembersVerticalTab() {
        return true;
    }
    
    /**
     * @description Account Household Members - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHHMVerticalTabOnAccount() {
        return true;
    }

    /**
     * @description Account Household Members - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHHMVerticalTabOnCase() {
        return true;
    }

    /**
     * @description Account Household Members - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHHMVerticalTabOnOpportunity() {
        return true;
    }

    /**
     * @description Account Household Members - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHHMVerticalTabOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account Household Members - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHHMVerticalTabOnBillingAccount() {
        return true;
    }

    /**
     * @description Account Household Members - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHHMVerticalTabOnClaim() {
        return true;
    }


    /**
     * @description Account Household Members - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHHMVerticalTabOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account Household Members - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHHMVerticalTabOnSimpleConversation() {
        return true;
    }
}
