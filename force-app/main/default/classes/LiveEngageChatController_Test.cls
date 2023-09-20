@isTest
public with sharing class LiveEngageChatController_Test {

    private static final String ACCOUNT_ID = '1';
    private static final String CAMPAIGN_ID = '2';
    private static final String ENGAGEMENT_ID = '3';
    private static final String SKILL_ID = '4';
    private static final String APP_INSTALLATION_ID = '5';

    @isTest	
    private static void testGetConfig() {
        String name = 'test';

        Test.startTest();
        createCustomSetting(name);
        CS_LiveEngageChat__c config = LiveEngageChatController.getChatConfigurationCustomSetting(name);
        Test.stopTest();

        System.assertEquals(config.AccountId__c, ACCOUNT_ID, 'Setting did not contain expected value');
        System.assertEquals(config.CampaignId__c, CAMPAIGN_ID, 'Setting did not contain expected value');
        System.assertEquals(config.EngagementId__c, ENGAGEMENT_ID, 'Setting did not contain expected value');
        System.assertEquals(config.SkillId__c, SKILL_ID, 'Setting did not contain expected value');
        System.assertEquals(config.AppInstallationId__c, APP_INSTALLATION_ID, 'Setting did not contain expected value');
    }

    @isTest	
    private static void testMissingConfig() {
        String actualName = 'actual name';
        String otherName = 'other name';

        Test.startTest();
        createCustomSetting(actualName);
        
        String error = null;
        try {
            LiveEngageChatController.getChatConfigurationCustomSetting(otherName);
        } catch (LiveEngageChatController.LiveEngageChatException e) {
            error = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('No chat configuration named "' + otherName + '".', error, 'Exception should be thrown');
    }

    @isTest	
    private static void testMissingConfigName() {
        String name = null;

        Test.startTest();        
        String error = null;
        try {
            LiveEngageChatController.getChatConfigurationCustomSetting(name);
        } catch (LiveEngageChatController.LiveEngageChatException e) {
            error = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Chat configuration name has not been set.', error, 'Exception should be thrown');
    }

    private static CS_LiveEngageChat__c createCustomSetting(String name) {
        CS_LiveEngageChat__c setting = new CS_LiveEngageChat__c();
        setting.name = name;
        setting.AccountId__c = ACCOUNT_ID;
        setting.CampaignId__c = CAMPAIGN_ID;
        setting.EngagementId__c = ENGAGEMENT_ID;
        setting.SkillId__c = SKILL_ID;
        setting.AppInstallationId__c = APP_INSTALLATION_ID;

        insert setting;
        return setting;
    }
}
