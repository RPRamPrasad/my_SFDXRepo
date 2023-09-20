/****************************************************************************************
Name: CMP_CaseStartStopJourney
@description Controller class for Case Start/Stop Journey component 
Team: ClubCar
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  03/07/2019              Initial Development
******************************************************************************************/ 

public with sharing class CMP_CaseStartStopJourney {
    
    private static final String CLASS_NAME = 'CMP_CaseStartStopJourney';
    private static final String QUERYJRNY_METHODNAME = 'retrieveJourneyDetails';
    private static final String APPLYJRNY_METHODNAME = 'applyCaseJourney';
    private static final String STOPJRNY_METHODNAME = 'stopCaseJourney';
    private static final String EXCEPTION_OCCURRED = 'EXCEPTIONOCCURRED';
    private static final String NO_JOURNEYS = 'NOJOURNEYS';
    
    /**
    * @class CaseStartStopJourneyWrapper
    * @description Inner Class to return data required by StartStopJourneyModal Lightning Component
    */
    public with sharing class CaseStartStopJourneyWrapper {
        
        @AuraEnabled
        public Boolean exceptionOccured = false;
        
        @AuraEnabled
        public Boolean showJourneySelection = false;
        
        @AuraEnabled
        public List<Journey__c> journeyList = null;
        
        @AuraEnabled
        public Map<Id, List<Journey_Step__c>> jrnyIdAndStepMap = null;
        
        @AuraEnabled
        public String errorMessage = null;

        @AuraEnabled
        public Boolean isValidUserForJourneyOpr = false;
        
    }
    /**
    * @class CaseStartStopJourneyWrapper
    * @description Inner Class to return data required by StartStopJourneyModal Lightning Component
    */
    public with sharing class CaseStartStopJourneySteps {
        /**
         * @description journeyStepId
         */
        @AuraEnabled
        public Decimal journeyStepId {get;set;}
        /**
         * @description calculatedDate
         */
        @AuraEnabled
        public Date calculatedDate {get;set;}
        /**
         * @description methodName
         */
        @AuraEnabled
        public String methodName {get;set;}
        /**
         * @description description
         */
        @AuraEnabled
        public String description {get;set;}
        
    }
    
    /**
    * @method retrieveJourneyDetails
    * @description This method will be invoked by Case Journey Component when user clicks on Start Journey button
    * @param sObjectRecordId
    * @return Journey and Steps List when applicable Journey's meet the Case Journey criteria
    */    
    @AuraEnabled
    public static CaseStartStopJourneyWrapper retrieveJourneyDetails (Id sObjectRecordId) {
        Boolean showJourneySelection = false;  
        Case queriedCaseRecord = null;
        Boolean exceptionOccured = false;        
        String errorMessage = null;
        CaseStartStopJourneyWrapper wrapperObj;
        List<Journey__c> canBeAppliedJourneyList = null;
        wrapperObj = new CaseStartStopJourneyWrapper();
        try {
            // retrieve case record with additional fields
            queriedCaseRecord = HLPR_StartStopJourney.retrieveCaseRecord(sObjectRecordId);
            canBeAppliedJourneyList = HLPR_StartStopJourney.queryJourneyAndStepDetails(queriedCaseRecord);
            if (canBeAppliedJourneyList!= null && !canBeAppliedJourneyList.IsEmpty()) {
                showJourneySelection = true;
            }
            else {
                showJourneySelection = false;
                errorMessage = NO_JOURNEYS;
            }
            wrapperObj.showJourneySelection = showJourneySelection;
            wrapperObj.exceptionOccured = exceptionOccured; 
            wrapperObj.errorMessage = errorMessage; 
            wrapperObj.journeyList = canBeAppliedJourneyList;
            wrapperObj.jrnyIdAndStepMap = HLPR_StartStopJourney.jrnyIdAndStepMap;
            wrapperObj.isValidUserForJourneyOpr = canUserPerformJourneyOpr();
            return wrapperObj;
        } catch (Exception getCaseJourneyExp) {

            wrapperObj.showJourneySelection = false;
            wrapperObj.exceptionOccured = true; 
            wrapperObj.errorMessage = EXCEPTION_OCCURRED; 
            wrapperObj.journeyList = null;
            wrapperObj.jrnyIdAndStepMap = null;
            wrapperObj.isValidUserForJourneyOpr = canUserPerformJourneyOpr();

            LoggingService.logHandledException(getCaseJourneyExp, CLASS_NAME, QUERYJRNY_METHODNAME, LoggingLevel.ERROR);
            return wrapperObj;
        }
    }
    
    /**
    * @method applyCaseJourney
    * @description This method will be invoked when user selects a Journey on Start Journey component and clicks on Start Journey
    * @param recordId
    * @param journeyId
    * @return messageForCmp - message sent to Cmp
    */ 
   /* @AuraEnabled
    public static String applyCaseJourney(Id recordId, Id journeyId) {
        String messageForCmp;
        try {
            HLPR_StartStopJourney.applyJourneyOnCase(recordId, journeyId);
        } catch (Exception applyCaseJourneyExp) {
            messageForCmp = applyCaseJourneyExp.getMessage();
            LoggingService.logHandledException(applyCaseJourneyExp, CLASS_NAME, APPLYJRNY_METHODNAME, LoggingLevel.ERROR);
        }        
        return messageForCmp;        
    }*/
    @AuraEnabled
    public static Boolean applyCaseJourneyLWC(Id recordId, Id journeyId) {
        Boolean result;
        String messageForCmp;
        try {
            HLPR_StartStopJourney.applyJourneyOnCase(recordId, journeyId);
            result = true;
        } catch (Exception applyCaseJourneyExp) {
            result = false;
            messageForCmp = applyCaseJourneyExp.getMessage();
            LoggingService.logHandledException(applyCaseJourneyExp, CLASS_NAME, APPLYJRNY_METHODNAME, LoggingLevel.ERROR);
        }        
        return result;        
    }
    /**
    * @method stopCaseJourney
    * @description This method will be invoked when user selects a Journey on Start Journey component and clicks on Stop Journey
    * @param recordId - recordId passed to the method
    * @return messageForCmp - message sent to Cmp
    */
    @AuraEnabled
    public static Boolean stopCaseJourney(Id recordId) {
        String messageForCmp;
        Boolean result;
        try {
            HLPR_StartStopJourney.stopJourneyOnCase(recordId);
            result = true;
        } catch (Exception stopCaseJourneyExp) {
            messageForCmp = stopCaseJourneyExp.getMessage();
            LoggingService.logHandledException(stopCaseJourneyExp, CLASS_NAME, STOPJRNY_METHODNAME, LoggingLevel.ERROR);
            result = false;
        }        
        return result;        
    }
/**
 * @description retrieveJourneyPreviewData
 * @param selectedJourneyId
 * @return List<CaseStartStopJourneySteps>
 */
    // This method is used to retrieve the Journey Preview data and calculate the total cost of Journey
    @AuraEnabled(cacheable=true)
    public static List<CaseStartStopJourneySteps> retrieveJourneyPreviewData(String selectedJourneyId){
        List<CaseStartStopJourneySteps> journeyPreviewDataList = new List<CaseStartStopJourneySteps>();
        List<Journey_Step__c> journeyStepList = new List<Journey_Step__c>();
        //isValidRecordId(selectedJourneyId);
        journeyStepList = Security.stripInaccessible(AccessType.READABLE,
                                                    [SELECT id, name, JourneyName__c, JourneyStepID__c, StepTypeCode__c, ContactMethodName__c,
                                                    ItemEffectiveDate__c, Cost__c,LetterName__c,Script__c,DaysNum__c, Bundle_ID__c, MailClassCode__c,ItemID__c 
                                                    FROM Journey_Step__c WHERE JourneyID__c=:selectedJourneyId ORDER BY JourneyStepID__c asc 
                                                    LIMIT 50]).getRecords();
        for(integer i=0;i<journeyStepList.size();i++)
        {
            
            CaseStartStopJourneySteps jsteps = new CaseStartStopJourneySteps();
            jSteps.journeyStepId =  i+1;
            jSteps.calculatedDate = system.today().addDays(Integer.valueOf(journeyStepList[i].DaysNum__c));
            jSteps.methodName = journeyStepList[i].LetterName__c;
            jSteps.description = journeyStepList[i].Script__c;
            journeyPreviewDataList.add(jSteps);

        }
        return journeyPreviewDataList;
    }
/**
 * @description canUserPerformJourneyOpr
 * @return Boolean
 */
    //method to validate Agent custom permission 
    public static Boolean canUserPerformJourneyOpr() {
        return FeatureManagement.checkPermission('PerformOpportunityStartStopJourney');
    } 

    private static Boolean isValidRecordId(String recordId) {
        try {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('journeyId', recordId, Journey_Step__c.class);
            return true;
        } catch (InvalidParameterValueException e) {
            return false;
        }
    }
}
