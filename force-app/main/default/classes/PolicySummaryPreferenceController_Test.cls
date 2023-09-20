/**
* @description This is the test class for the PolicySummaryPreferenceController Apex class.
* @Date: 09/26/2022
* @author: Team NSYNC - Wong Soon CIWA 
*/
@isTest(SeeAllData=false)
public with sharing class PolicySummaryPreferenceController_Test {

/**
* @description Test retrieve for nothing in cache and no existing preference
*/
    @isTest
    private static void fetchUserPreferenceNoExisting() {
                System.runAs(TestDataFactory_User.getSysAdminUser()) 
        {
            test.startTest();

	        System.assertEquals(PolicySummaryPreferenceController.fetchUserPreference(),'policy-card','Expected value is'+PolicySummaryPreferenceController.fetchUserPreference()+', but actual value is policy-card');
            test.stopTest();

        }
    }
/**
* @description Test retrieve for nothing in cache and no existing preference and no cache
*/
   @isTest
    private static void fetchUserPreferenceNoExistingCa() {
                System.runAs(TestDataFactory_User.getSysAdminUser()) 
        {
            test.startTest();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.UserInfoPartition');
               sessionPart.put('PolicySummaryView', 'policy-card');
	        System.assertEquals(PolicySummaryPreferenceController.fetchUserPreference(),'policy-card','Expected value is'+PolicySummaryPreferenceController.fetchUserPreference()+', but actual value is policy-card');
            test.stopTest();

        }
    }
/**
* @description Test retrieve for nothing in cache and has existing preference
*/
    @isTest
    private static void fetchUserPreferenceWithExistingPreference() {
        User adminUser = TestDataFactory_User.getSysAdminUser();
           Preference__c newPref = new Preference__c(
                PreferenceName__c = 'PolicySummaryView',
                PreferenceUser__c = adminUser.Id,
                PreferenceValue__c = 'policy-list',
                PreferenceLevel__c = 'User',
                PreferenceObject__c = 'InsurancePolicy'
            );
                    insert newPref;
        
                System.runAs(adminUser) 
        {
            test.startTest();
          PolicySummaryPreferenceController.fetchUserPreference();
          List <Preference__c> prefList  = [SELECT PreferenceValue__c 
            FROM Preference__c 
            WHERE PreferenceName__c = 'PolicySummaryView' 
            AND PreferenceUser__c = :UserInfo.getUserId()];
            
            test.stopTest();
        System.assertEquals(prefList.get(0).PreferenceValue__c,'policy-list','Expected value is'+prefList.get(0).PreferenceValue__c+', but actual value is policy-list');

        }
    }
/**
* @description Test update with existing preference
*/
    @isTest
    private static void updateUserViewWithExistingPreference() {
        User adminUser = TestDataFactory_User.getSysAdminUser();
           Preference__c newPref = new Preference__c(
                PreferenceName__c = 'PolicySummaryView',
                PreferenceUser__c = adminUser.Id,
                PreferenceValue__c = 'policy-list',
                PreferenceLevel__c = 'User',
                PreferenceObject__c = 'InsurancePolicy'
            );
                    insert newPref;
        
                System.runAs(adminUser) 
        {
            test.startTest();
            PolicySummaryPreferenceController.updateUserView('policy-card');
            List <Preference__c> prefList  = [SELECT PreferenceValue__c 
            FROM Preference__c 
            WHERE PreferenceName__c = 'PolicySummaryView' 
            AND PreferenceUser__c = :UserInfo.getUserId()];
            
            test.stopTest();
        System.assertEquals(prefList.get(0).PreferenceValue__c,'policy-card','Expected value is'+prefList.get(0).PreferenceValue__c+', but actual value is policy-card');

        }
    }
/**
* @description Test update and no existing preference
*/
    @isTest
    private static void updateUserViewWithNoExistingPreference() {
        User adminUser = TestDataFactory_User.getSysAdminUser();
        System.runAs(adminUser) 
        {
            test.startTest();
            PolicySummaryPreferenceController.updateUserView('policy-card');
            List <Preference__c> prefList  = [
                SELECT PreferenceValue__c 
                FROM Preference__c 
                WHERE PreferenceName__c = 'PolicySummaryView' 
                AND PreferenceUser__c = :UserInfo.getUserId()
            ];
            
            test.stopTest();
        System.assertEquals(prefList.get(0).PreferenceValue__c,'policy-card','Expected value is'+prefList.get(0).PreferenceValue__c+', but actual value is policy-card');
        }
    }
}