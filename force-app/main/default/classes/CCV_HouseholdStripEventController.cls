/**
 * @description This class is used to capture usage events on Household Strip
 * Click on lightning pages
 * @Date: 05/04/2023
 * @author: Team Atlas
 */
public with sharing class CCV_HouseholdStripEventController {
    /**
     * @description Household Strip - add member(s) click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAddMembers() {
        return true;
    }
    
    /**
     * @description Household Strip - remove member(s) click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickRemoveMembers() {
        return true;
    }

    /**
     * @description Household Strip - move member(s) click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickMoveMembers() {
        return true;
    }

    /**
     * @description Household Strip - change mailing address click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickChangeMailingAddress() {
        return true;
    }

    /**
     * @description Household Strip - update member(s) role click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickUpdateMembersRole() {
        return true;
    }

    /**
     * @description Household Strip - manage relationship(s) click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickManageRelationships() {
        return true;
    }

    /**
     * @description Household Strip - account click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickAccount() {
        return true;
    }

    /**
     * @description Household Strip - click 2 dial click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHouseholdCall() {
        return true;
    }

    /**
     * @description Household Strip - sms/text click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHouseholdText() {
        return true;
    }

    /**
     * @description Household Strip - Email
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHouseholdEmail() {
        return true;
    }

    /**
     * @description Household Strip - show all members click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickShowAll() {
        return true;
    }

    /**
     * @description Household Strip - show less members click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickShowLess() {
        return true;
    }

    /**
     * @description Household Strip - household load
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logLoadHouseholdMembers() {
        return true;
    }

    /**
     * @description Household Strip - household members click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHouseholdMembers() {
        return true;
    }

    /**
     * @description Household Strip - household relationships click
     * @return Boolean
     */
    @AuraEnabled
    public static boolean logClickHouseholdRelationships() {
        return true;
    }
}