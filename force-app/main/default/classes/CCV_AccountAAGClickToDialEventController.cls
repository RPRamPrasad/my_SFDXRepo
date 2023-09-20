/**
 * @description This class is used to capture usage events on Account At A Glance
 * Vertical Tab Click on lightning pages
 * @Date: 12/10/2022
 * @author: Team Atlas
 */

public with sharing class CCV_AccountAAGClickToDialEventController {
    /**
     * @description Account At A Glance Click To Dial
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGClickToDial() {
        return true;
    }
    
    /**
     * @description Account At A Glance Click To Dial - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGClickToDialOnAccount() {
        return true;
    }

    /**
     * @description Account At A Glance Click To Dial - case click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGClickToDialOnCase() {
        return true;
    }

    /**
     * @description Account At A Glance Click To Dial - opportunity click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGClickToDialOnOpportunity() {
        return true;
    }

    /**
     * @description Account At A Glance Click To Dial - insurance policy click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGClickToDialOnInsurancePolicy() {
        return true;
    }

    /**
     * @description Account At A Glance Click To Dial - billing account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGClickToDialOnBillingAccount() {
        return true;
    }

    /**
     * @description Account At A Glance Click To Dial - claim click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGClickToDialOnClaim() {
        return true;
    }


    /**
     * @description Account At A Glance Click To Dial - financial account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGClickToDialOnFinancialAccount() {
        return true;
    }

    /**
     * @description Account At A Glance Click To Dial - simple conversation click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAAGClickToDialOnSimpleConversation() {
        return true;
    }

}
