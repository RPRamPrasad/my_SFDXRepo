/****************************************************************************************
Name: CMP_SimpleConEmailController
Copyright © State Farm
=========================================================================================
@description This class will be invoked by Cancel Button - LWC
Team: Octonauts
******************************************************************************************/
public with sharing class CMP_SimpleConEmailController {

/**
* @description Method for Cancel Meeting
* @param recordId 
* @return wrap
*/
    @AuraEnabled
    public static SendOutlookEmailWrapper sendOutlookEmail(String recordId){

        //Retrive Conducted By from Simple Conversation Record
        SendOutlookEmailWrapper wrap = new SendOutlookEmailWrapper();
        try{
            SimpleConversation__c simpleConvEmailRecord = [Select Name, SimpleConversationName__c, ConductedBy__c, SimpleConversationType__c,  AppointmentStartDateTime__c, AppointmentEndDateTime__c, Id, Status__c, ConductedBy__r.email, ConductedBy__r.Name, Account__c, Account__r.Name from SimpleConversation__c where Id =: recordId WITH SECURITY_ENFORCED limit 1];
            List<SimpleConversation__c> simpleConvEmailRecords = new List<SimpleConversation__c>();
            simpleConvEmailRecords.add(simpleConvEmailRecord);
            HLPR_SimpleConversationTrigger.sendCalendarEmailQuickAction(simpleConvEmailRecords);
            wrap.response = 'Success';
            wrap.responseMessage = 'Outlook Meeting has been sent to the user listed in the Conducted By field.';
        }
        catch(Exception e){
            AP_LogHolder logHolder = new AP_LogHolder();
              logHolder.info('CMP_SimpleConEmailController', e.getMessage() + System.now());
              logHolder.writeToLogExceptionObject();
          }
          return wrap;
        }

       /**
* @description Wrapper class for cancel message
*/
public with sharing class SendOutlookEmailWrapper{
    @AuraEnabled
    public string response;
    @AuraEnabled
    public string responseMessage;
}

}