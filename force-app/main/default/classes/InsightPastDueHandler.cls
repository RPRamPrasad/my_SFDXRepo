/**
 * @description This class will process the InsightPastDueHandler
 */
public with sharing class InsightPastDueHandler {
   private static final String BILLING_ACTION_ELIGIBLE_USER = 'Billing_Action_Eligible_User';

   /**
    * @description This method will process the getPastDueData
    * @param accountList
    * @return  `String`
    */
   @AuraEnabled
   Public static String getPastDueData(List<Account> accountList){
      Boolean checkpoint = false;
      String validation = '';
      try{
      for(Integer i = 0; i < accountList[0].BillingParticipants__r.size(); i++){
        if(accountList[0].BillingParticipants__r[i].BillingAccountID__r.PastDueIndicator__c){
            checkpoint = true;
            break;
        }
      }
      if(FeatureManagement.checkPermission(BILLING_ACTION_ELIGIBLE_USER)){
        if(checkpoint){
          validation = 'Error_PD';
        }
        else{
          validation = 'Success_PD';
        }
      }
      else{
        if(checkpoint){
          validation = 'No_DP_Error_PD';
        }
        else{
          validation = 'No_DP_Success_PD';
        }
      }
      } catch(Exception e){
        AP_LogHolder logHolder = new AP_LogHolder();
          logHolder.info('InsightPastDueHandler', e.getMessage() + System.now());
          logHolder.writeToLogExceptionObject();
      }
    return validation;
   }
}