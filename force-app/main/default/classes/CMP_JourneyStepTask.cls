/**
Author Team ClubCar
Name - CMP_JourneyStepTask
@description This class will be invoked by JourneyStepTaskForm lightning component
Team: ClubCar
========================================================================================================================================
History
-------
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                02/25/2019              Initial Development
******************************************************************************************************************************************/
public with sharing class CMP_JourneyStepTask {

    private static final String CLASS_NAME = 'CMP_JourneyStepTask';
    private static final String METHOD_NAME = 'processTaskJnyStep';
    
    /**
    * @description processTaskJnyStep for inserting task master journey step
    * @param masterJnyStep - Journey step passed to the method
    * @return boolean value based on the exception
    */
    @AuraEnabled
    public static Boolean processTaskJnyStep (Journey_Step__c masterJnyStep) {
        Boolean exceptionOccurred = false;
        try {
            AP_JourneyStepProcessing jrnyStepProcessingObj = new AP_JourneyStepProcessing();
            jrnyStepProcessingObj.insertTaskJourneyStep(masterJnyStep);
        } catch (Exception jrnyStepInsertException) {
            exceptionOccurred = true;
            LoggingService.logHandledException(jrnyStepInsertException, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return exceptionOccurred;
    }    
}