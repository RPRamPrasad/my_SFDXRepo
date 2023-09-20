/**
  * @name AQ_AutoCompletionRuleTriggerHandler
  * @author Team Skynet
  * @createdDate 4/14/2023
  * @description  This class will handle Trigger logic for AQ_AutoCompletionRule__c Object
*/
public with sharing class AQ_AutoCompletionRuleTriggerHandler {

  private AQ_AutoCompletionRuleTriggerHandler(){
    AP_LogHolder logHolder = new AP_LogHolder();
    logHolder.info('AQ_AutoCompletionRuleTriggerHandler', 'start time of execution: ' + System.now());
    logHolder.writeToLogExceptionObject();
  }
    /**
     * @description - Before Insert Trigger logic. Updates record owner to proxy
     * @param aqAutoCompletionRules
     */
    public static void handleBeforeInsert(List<AQ_AutoCompletionRule__c> aqAutoCompletionRules) {
        SObjectOwnershipUtility.setObjectOwnerToProxy(aqAutoCompletionRules, false);
    }
}
