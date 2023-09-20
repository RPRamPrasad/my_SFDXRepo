/**
 * @description Provides a mechanism for overriding the AP_AccountTrigger's requirement
 * that an Account owner has to be the StateFarm System user when running unit tests.
 */
@isTest(SeeAllData=false)
public with sharing class UTIL_OverrideSystemUser_TEST {
    /**
     * @description Provides a mechanism for overriding the AP_AccountTrigger's requirement
     * that an Account owner has to be the StateFarm System user when running unit tests.
     */
    public static void doOverride() { 
        
        User thisUser = [Select Id from User where Id = :UserInfo.getUserId() limit 1]; 
        AccountOwnerSystemUserCustomSetting__c settings = AccountOwnerSystemUserCustomSetting__c.getInstance();
        
        // settings object may be uninitialized but it's never null
        settings.SFDC_User_ID__c = thisUser.Id;
        upsert settings;
    } 
}