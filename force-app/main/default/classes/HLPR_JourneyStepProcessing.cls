/****************************************************************************************
Name: HLPR_JourneyProcessing
Copyright © State Farm
=========================================================================================
@description This class will be invoked by JourneyStep Lightning Component. 
Team: ClubCar
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  10/11/2018              Initial Development
******************************************************************************************/ 
public with sharing class HLPR_JourneyStepProcessing {
    
    private static final String CLASS_NAME = 'HLPR_JourneyStepProcessing';
    private static final String METHOD_NAME = 'getJourneyStepDetails';
    /**
    * @description Inner Class to return Journey Details required by JourneyStep Lightning Component
    */
    public with sharing class JourneyStepWrapper {
        /**
    	* @description userAlias get,set
    	*/
        @AuraEnabled
        public String userAlias{get;set;}
         /**
    	* @description journeyNumber get,set
    	*/
        @AuraEnabled
        public String journeyNumber{get;set;}
         /**
    	* @description journeyStepId get,set
    	*/
        @AuraEnabled
         public Integer journeyStepId{get;set;}
    }
    /**
    * @description Method invoked by JourneyStep Lightning Component to get Journey Details
    * @param masterJnyId
    * @return wrapperClassObj
    */
    @AuraEnabled
    public static JourneyStepWrapper getJourneyStepDetails (Id masterJnyId) {
        JourneyStepWrapper wrapperClassObj = new JourneyStepWrapper();
        try {
            wrapperClassObj.journeyNumber = UTIL_LtngJourneyProcess.getMasterJourney(masterJnyId).JourneyNumber__c;
            wrapperClassObj.userAlias = UTIL_LtngJourneyProcess.getUserAlias();
            wrapperClassObj.journeyStepId = UTIL_LtngJourneyProcess.getJourneyStepId(masterJnyId);
        }
        catch (Exception jnyAfterInsertException) {
            LoggingService.logHandledException(jnyAfterInsertException, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);
        }        
        return wrapperClassObj;
    }  
    
}