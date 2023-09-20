/**
  * @name AQ_WorkAssignmentRuleTriggerHandler
  * @author Team Skynet
  * @createdDate 10/27/2022
  * @description  This class will handle Trigger logic for AQ_WorkAssignmentRule__c Object
*/
public with sharing class AQ_WorkAssignmentRuleTriggerHandler {

  private AQ_WorkAssignmentRuleTriggerHandler(){
    AP_LogHolder logHolder = new AP_LogHolder();
    logHolder.info('AQ_WorkAssignmentRuleTriggerHandler', 'start time of execution: ' + System.now());
    logHolder.writeToLogExceptionObject();
  }

    /**
     * @description - Before Insert Trigger logic. Updates record owner to proxy
     * @param aqWorkAssignmentRules
     */
    public static void handleBeforeInsert(List<AQ_WorkAssignmentRule__c> aqWorkAssignmentRules){
        SObjectOwnershipUtility.setObjectOwnerToProxy(aqWorkAssignmentRules, false);
    }

}
