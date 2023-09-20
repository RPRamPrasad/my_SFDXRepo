/**
 * Author : Golden Spikes Team
 * Date Created : 10/08/2020
 * @description : This is a helper class for routing leads to CCC
 */
public with sharing class LeadCCCHandler {
    private static final String RICH_TEXT_NEW_LINE = '<br/>';
    private static final String LEAD_SETTING_TYPE = 'Transfer to CCC';
    private static final List<String> EXCLUDED_SCODE = new String[] {'S30154'};
    @TestVisible private static DateTime mockedCurrentDateTime;
/**
 * @description preCCCEligibleCheck 
 * @param leadInfo 
 * @return  `Boolean`
 */
    public static Boolean preCCCEligibleCheck(HLPR_CreateLeadRequest.LeadInformation leadInfo) {
        return !(EXCLUDED_SCODE).contains(leadInfo.sCode?.toUpperCase()) &&
            ((String.isNotBlank(leadInfo.mobilePhone) || String.isNotBlank(leadInfo.phone)));
    }
/**
 * @description isCCCEligible
 * @param externalLeadSource 
 * @return  `Boolean`
 */
    public static Boolean isCCCEligible(String externalLeadSource) {
        Boolean isCCCEligible = false;
        DateTime currentDateTime;
        try {
            for (LeadSetting__c ldSetting : [SELECT StartTime__c, EndTime__c, Frequency__c FROM LeadSetting__c
                WHERE Name = :externalLeadSource AND Type__c = :LEAD_SETTING_TYPE AND Active__c = true WITH SECURITY_ENFORCED LIMIT 1]) {
                if(Test.isRunningTest()) {
                    currentDateTime = mockedCurrentDateTime;
                } else {
                    currentDateTime = Datetime.now();
                }
                Time currentTime = currentDateTime.time();
                Time allowedStartTime = ldSetting.StartTime__c;
                String frequency = ldSetting.Frequency__c;
                Time allowedEndTime = ldSetting.EndTime__c;
                if (String.isNotBlank(frequency) && frequency.contains(currentDateTime.format('u')) 
                    && currentTime >= allowedStartTime && currentTime <= allowedEndTime) {
                    isCCCEligible = true;
                }
            }
        } catch (Exception ex) {
            throw new HLPR_CreateLeadRequest.LeadServiceException(ex.getMessage(), ex);
        }
        return isCCCEligible;
    }
/**
 * @description sendEmail 
 * @param newLd 
 */
    public static void sendEmail(Lead newLd) {
        CSLeadBatch__c leadCustomSettingRecord = CSLeadBatch__c.getValues('CCC Email Notification');
        if(leadCustomSettingRecord != null) {
            String[] toAddresses = new List<String> {leadCustomSettingRecord.BatchEmailRecipient__c};
            String senderDisplayName = leadCustomSettingRecord.SenderDisplayName__c;
            String emailSubject = 'You have a new '+ newLd.LeadSource;
            String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + newLd.Id;
            String emailBody = 'Lead: <a href="'+recordUrl+'">'+ newLd.FirstName + ' ' + newLd.LastName + '</a> has been assigned to you.' + RICH_TEXT_NEW_LINE;
            emailBody += 'Acxiom Lead Id: ' + newLd.External_Lead_ID__c + RICH_TEXT_NEW_LINE;
            emailBody += 'Salesforce Lead Id: ' + newLd.Id;
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setToAddresses(toAddresses);
            emailMessage.setSenderDisplayName(senderDisplayName);
            emailMessage.setSubject(emailSubject);
            emailMessage.setHTMLBody(emailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMessage });
        }
    }
}