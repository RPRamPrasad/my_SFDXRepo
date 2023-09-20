/**
 * @author : Team Hydra
 * Date Created : 2/29/2020
 * @description : Controller to get an environment URL from custom settings.
 * Version : 1.0
 */
public with sharing class CustomSettingEnvironmentUrlCtl {
    
    /**
    * @name getEnvironmentUrl
    * @description returns custom setting environment url
    * @param urlName
    * @return CS_EnvironmentURLCustomSetting__c
    */
    @AuraEnabled(cacheable=true)
    public static CS_EnvironmentURLCustomSetting__c getEnvironmentUrl(String urlName) {
        List<CS_EnvironmentURLCustomSetting__c> urls = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT
                    Value__c
                FROM CS_EnvironmentURLCustomSetting__c
                WHERE Name =: urlName])
                .getRecords();
        if (urls.isEmpty()) {
            throw new EnvironmentUrlException('No custom setting environment URL record with name of ' + urlName);
        }
        
        return urls[0];
    }

    /**
     * @name EnvironmentUrlException
     * @description Extends System.Exception class
     */
    public with sharing class EnvironmentUrlException extends System.Exception {}
}