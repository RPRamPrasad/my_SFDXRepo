/**
* Author : Team Simpli Fi
* @description : Class for updating Limit_Monitoring__c object
*/ 
public without sharing class LimitMonitoringFuture {

    /**
     * @description Updates list of Limit_Monitoring__c records
     * @param jsonString
     */ 
    @Future
    public static void handleLimitMonitoring(String jsonString){
        try{
            List<Limit_Monitoring__c> lms = (String.isNotEmpty(jsonString)) ? (List<Limit_Monitoring__c>)JSON.deserializeStrict(jsonString, List<Limit_Monitoring__c>.class) : new List<Limit_Monitoring__c>();
            if(!lms.isEmpty()){
                Database.upsert(lms , Limit_Monitoring__c.Class_Name__c, false);
            }
        }catch(Exception ex){
            LoggingService.logHandledException(ex, 'LimitMonitoringFuture', 'handleLimitMonitoring', LoggingLevel.ERROR);
        }
    }
    
}