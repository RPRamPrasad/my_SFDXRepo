/**
@Author Team Opptimizers
@Name HLPR_OpportuntiyProductTrigger
@CreateDate 5/10/2022
@description This class is used to send the email notification with opportunity product data (difference)
@Version 1.0
Copyright © StateFarm
*/

public with sharing class HLPR_OpportuntiyProductTrigger {
    static final String TEAM_MAIL_BOX  = 'home.sys-opptimizerssfdcprocid.737j01@statefarm.com';
    static final String CLASS_NAME = 'HLPR_OpportuntiyProductTrigger';
    static final String UPDATE_PRODUCT_FIELD_ACTIVELIST = 'updateProductFieldActiveList';
    private static final String PROD_BASE_URL = '.statefarm.com';
    private static final String ICP_TP_ENV = 'ICP_TP_ENV'; 
    /**
* @description method to compare the opportunity product data against product field picklist and send email notification
*/
    public static void updateProductFieldActiveList() {
        
        try {
            List<AggregateResult> existingOpportunityProducts = [SELECT Product_Description__c FROM OpportunityProduct__c WITH SECURITY_ENFORCED GROUP BY Product_Description__c Limit 500 ];
            Set<String> existingOpportunityProductDescription = new Set<String>();
            for(AggregateResult prod : existingOpportunityProducts) {
                existingOpportunityProductDescription.add((String)prod.get('Product_Description__c'));
            }
            
            Set<String> existingProductActivePicklist = getPicklistValues('Opportunity', 'Product__c');
            
            existingOpportunityProductDescription.removeAll(existingProductActivePicklist);
            if(existingOpportunityProductDescription.size() > 0) {
                sendEmail(existingOpportunityProductDescription);
            }
        }
        catch(Exception e){
            LoggingService.logHandledException(e, CLASS_NAME, UPDATE_PRODUCT_FIELD_ACTIVELIST,System.LoggingLevel.ERROR);
        }
    }

    /**
* @description Method to send email notification with product difference list
* @param productList
*/
    public static void sendEmail(Set<String> productList) {
        
        String envName = getEnvironmentName();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {TEAM_MAIL_BOX};
        message.subject = 'Product Differences - '+ envName;
        message.setSenderDisplayName('Opportunity Product Data');
        message.setHtmlBody(getEmailBody(productList));
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.sendEmail(messages);
    }
    /**
* @description Method to send email notification with product difference list
* @return String of environment name productList
*/
 public static String getEnvironmentName(){
        CS_EnvironmentURLCustomSetting__c baseUrl = CS_EnvironmentURLCustomSetting__c.getInstance(ICP_TP_ENV);
        if(PROD_BASE_URL.equals(baseUrl.Value__c)){
            return 'Production';
        }
        else{
            return baseUrl.Value__c.substring(1,5);
        }
 }
    /**
* @description Method to form a body of email
* @param productList
* @return htmlBody
*/
    public static String  getEmailBody(Set<String> productList) {
        string tdHead='"border:1px solid black; width=200px; color:black;font-weight:bold;"';
        string tdbody='"border:1px solid black; width=200px; color:black;font-weight:normal;"';
        string htmlBody = '<div style="border:2thick double #32a1ce;; border-radius:15px;"><p>Hello Team,</p>'
        +'<p><b>Please DO NOT REPLY to this email. For any questions, please send a new email to the address mentioned</b></p>'
        +'<p>Below are the product difference list, Opportunity Product Data vs Active Product field Picklist Values </p>'
        +'<table style="border:1px solid black; border-collapse:collapse;">'
        +'<tr><td style='+tdHead+'>Product Differences</td></tr>';
        for(String proList : productList) {
            htmlBody += '<tr><td style='+tdbody+'>'+proList+'</td></tr>';
        }

        return htmlBody;
    }

/**
* @description Method to get current active picklist values
* @param objectName
* @param fieldName
* @return Set<String>
*/
    private static Set<String> getPicklistValues(String objectName, String fieldName) {
        Set<String> picklistValues = new Set<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.isActive()) {
                picklistValues.add(pickListVal.getValue());
            }
        }
        return picklistValues;
    }

}