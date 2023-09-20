/**
 @name LiveEngageChatController
 @author Team Hydra
 @description This retrieves LiveEngage chat configurations from the CS_LiveEngageChat__c custom setting.
 */
public with sharing class LiveEngageChatController {

    /**
    * @name getChatConfigurationCustomSetting
    * @description get chat configuration by the live-engage chat name
    * @param name
    * @return CS_LiveEngageChat__c
    */
    @AuraEnabled(cacheable=true)
    public static CS_LiveEngageChat__c getChatConfigurationCustomSetting(String name) {
        if (String.isBlank(name)) {
            throw new LiveEngageChatException('Chat configuration name has not been set.');
        }
        
        List<CS_LiveEngageChat__c> settings = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT
                    AccountId__c, CampaignId__c, EngagementId__c, SkillId__c, AppInstallationId__c 
                FROM CS_LiveEngageChat__c
                WHERE Name = :name
                LIMIT 1])
                .getRecords();
        if (settings.isEmpty()) {
            throw new LiveEngageChatException('No chat configuration named "' + name + '".');
        }
        
        return settings[0];
    }

    /**
    * @name LiveEngageChatException
    * @description an exception that is being used by getChatConfigurationCustomSetting
    */
    public with sharing class LiveEngageChatException extends System.Exception {}

}
