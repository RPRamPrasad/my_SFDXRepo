public with sharing class ActivityWrapper {
    @AuraEnabled
    public String dueDate{get;set;}
    @AuraEnabled
    public String modifiedDate{get;set;}
    @AuraEnabled
    public String status{get;set;}
    @AuraEnabled
    public String customer{get;set;}
    @AuraEnabled
    public String description{get;set;}
    @AuraEnabled
    public String clientID{get; set;}
    @AuraEnabled
    public String lob{get;set;}
    @AuraEnabled
    public String category{get;set;}
    @AuraEnabled
    public String agentName{get;set;}
    @AuraEnabled
    public String activityID{get;set;}
    @AuraEnabled
    public String associateID{get;set;}
    @AuraEnabled
    public Boolean displayCompleteAction{get;set;}
    @AuraEnabled
    public Boolean displaySupportAction{get;set;}
    @AuraEnabled
    public String householdReminder {get;set;}
}
