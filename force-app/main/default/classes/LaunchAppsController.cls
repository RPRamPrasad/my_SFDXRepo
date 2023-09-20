/**
 * @name LaunchToolsController
 * @author Team Octonauts
 * @description This class is used when launching Policy List Print from Simple Conversation Tab on Account record page
 */
 
public with sharing class LaunchAppsController {
    /**
     * @description Method to get policy list custom settings
     * @return 'CS_PolicyListPrint__c'
     */
    @AuraEnabled
    public static LaunchAppWrapper getPolicyListCustomSettings(String accountId){    
        try {    
            CS_PolicyListPrint__c policyListPrintData = CS_PolicyListPrint__c.getValues('PolicyListPrint_DataSet');//CS_PolicyListPrint__c.getInstance();//
            LaunchAppWrapper appObj = new LaunchAppWrapper();
            appObj.csPolicyListPrint = policyListPrintData;
            User userData = new User();
            if (User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() &&
                Schema.SObjectType.User.fields.Name.isAccessible() && 
                Schema.SObjectType.User.fields.Servicing_Agent_Associate_ID__c.isAccessible()) {
                    userData = [Select Id,Name,Servicing_Agent_Associate_ID__c from User Where Id=:userInfo.getUserId() WITH SECURITY_ENFORCED];
                }
            appObj.servicingAgentDetails = userData;
            List<Account> accDetails = new List<Account>();
            accDetails = Security.stripInaccessible(AccessType.READABLE,[SELECT Id, Name, ClientIdentifier__c from Account where Id=:accountId WITH SECURITY_ENFORCED]).getRecords();
            appObj.accountDetails = accDetails[0];
            return appObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Account updateLastAccess(String accountId){
        try {
            return new Account();
            /*accountData.Id = accountId;
            accountData.Last_Accessed_By__c = userInfo.getName();
            accountData.Last_Accessed_Time__c = System.now();
            update Security.stripInaccessible(AccessType.UPDATABLE, new List<Account>{accountData}).getRecords();*/
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class LaunchAppWrapper {
        @AuraEnabled
        public CS_PolicyListPrint__c csPolicyListPrint = new CS_PolicyListPrint__c();
        @AuraEnabled
        public User servicingAgentDetails = new User();
        @AuraEnabled
        public Account accountDetails = new Account();
    }
}