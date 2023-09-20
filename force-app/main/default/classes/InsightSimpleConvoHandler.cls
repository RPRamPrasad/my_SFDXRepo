/**
 * @description This class will process the InsightSimpleConvoHandler
 */
public with sharing class InsightSimpleConvoHandler {

  /**
   * @description This method will process the getSCData
   * @param accountList
   * @return  `String`
   */
   @AuraEnabled
   public static String getSCData(List<Account> accountList){
      String validation = 'Error_SC';
      //Decimal daysSinceLastConversation;
      //daysSinceLastConversation = accountList[0].Simple_Conversations__r[0].DaysSinceLastConversation__c;
      try{
        Date appointmentEndDate = Date.valueOf(accountList[0].Simple_Conversations__r[0].AppointmentEndDateTime__c);
        Date appointmentStartDate = Date.valueOf(accountList[0].Simple_Conversations__r[0].AppointmentStartDateTime__c);
        Date createdDate = Date.valueOf(accountList[0].Simple_Conversations__r[0].CreatedDate);
        Date validDate = createdDate;
        Integer dateDiff = 0;
        if(appointmentEndDate != null){
          validDate = appointmentEndDate;
        }
        else if(appointmentStartDate != null){
          validDate = appointmentStartDate;
        }
        Date checkToday = system.today();
        dateDiff = validDate.daysBetween(checkToday);
        if (dateDiff <= 365){
          validation = 'Success_SC';
        }
        else if(dateDiff > 365){
          validation = 'Warning_SC';
        }
    } catch(Exception e){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('InsightPastDueHandler', e.getMessage() + System.now());
        logHolder.writeToLogExceptionObject();

        throw new AuraHandledException(e.getMessage());
    }
      return validation;
   }
}