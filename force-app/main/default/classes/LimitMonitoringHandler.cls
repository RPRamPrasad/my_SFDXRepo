/**
* Author : Team Simpli Fi
* @description : Class for getting limit size and old limit monitoring 
*/ 
public without sharing class LimitMonitoringHandler {
    
    private ApexValidation validation = new ApexValidation();
    private List<Limit_Monitoring__c> lms = new List<Limit_Monitoring__c>();
    private Map<Id, Limit_Monitoring__c> oldLmsMap = new Map<Id, Limit_Monitoring__c>();

    /**
     * @description Constructor for LimitMonitoringHandler
     * @param lms 
     */ 
    public LimitMonitoringHandler(List<Limit_Monitoring__c> lms){
        this.lms = (lms != null) ? lms : new List<Limit_Monitoring__c>();
    }
    
    /**
     * @description Constructor for LimitMonitoringHandler
     * @param lms 
     * @param oldLmsMap
     */ 
    public LimitMonitoringHandler(List<Limit_Monitoring__c> lms, Map<Id, Limit_Monitoring__c> oldLmsMap){
        this.lms = (lms != null) ? lms : new List<Limit_Monitoring__c>();
        this.oldLmsMap = (oldLmsMap != null) ? oldLmsMap : new Map<Id, Limit_Monitoring__c>();
    }
    
    /**
     * @description Gets the limit size and old limit monitoring for each Limit_Monitoring__c record in lms list
     */ 
    public void handleLimitMonitoring(){
        if(this.lms.isEmpty()){
            return;
        }
        for(Limit_Monitoring__c lm : this.lms){
            Integer limitSize = getLimitSize(lm);
            Limit_Monitoring__c oldLm = getOldLimitMonitoring(lm);
            lm.Number_of_Offenses__c = (oldLm != null) ? oldLm.Number_of_Offenses__c + limitSize : limitSize;
        }
    }
    
    private Integer getLimitSize(Limit_Monitoring__c lm){
        List<String> limitsHit = (validation.isValidObject(lm.Limits__c)) ? lm.Limits__c.split(';') : new List<String>();
        return (limitsHit.isEmpty()) ? 1 : limitsHit.size();  
    }
    
    private Limit_Monitoring__c getOldLimitMonitoring(Limit_Monitoring__c lm){
        return (this.oldLmsMap.isEmpty()) ? null : this.oldLmsMap.get(lm.Id);
    }
    
}