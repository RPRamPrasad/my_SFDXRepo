/****************************************************************************************
Name: AP_JourneyProcessing
=========================================================================================
Purpose: This class will be invoked by Journey Triggers. 
         The main purpose of the class is to multiply Journey Master records into State specific records
         Also responsible for populating non UI Fields on master Journey records
Team: ClubCar
=========================================================================================
History
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  09/20/2018              Initial Development
2.0             ClubCar                  02/04/2019              Added logic to create dup Journey for CA, TX and NY
3.0             ClubCar                  05/01/2019              Added logic to populate Targetgroupcode for Case Journeys
4.0				ClubCar					 05/01/2019 			 Added logic to avoid recursive trigger
5.0             ClubCar                  2/18/2020               Updated PMD finding for CRUD violations
******************************************************************************************/ 
/**
 * @description AP_JourneyProcessing
 */
public with sharing class AP_JourneyProcessing {

    private static final String CLASS_NAME = 'AP_JourneyProcessing';
    private static final String METHOD_NAME = 'processJourneyStates';
    private static final Integer CHARLNGTHSIX = 6;    
    private static List<String> statePicklistValues;
    private static List<CM_USStateCodeMapping__mdt> metaDataStateCodeMapping;
    private static Map<String, String> stateCodeMap;
    private static final String DELIMITER_HYPEN = '-';

    public static Boolean isAfterInsertTriggerFirstRun = true;
    private static Map <String, List<String>> stateCodeToDupStateCodeMap = new Map <String, List<String>> {'CA' => new List<String> {'05','55','75'},
                                                'TX' => new List<String> {'43','53'}, 'NY' => new List<String> {'32','52'}};  
                                                    
    /**
    * @method - processJourneyStates
    * @description - This method will be invoked by Journey After Insert Trigger
    *    			 Master Journey Records will be multiplied into state Journey records.
    *                When Applicable to All States field is clicked, Journey records will be created for all States, otherwise Journey records will be created for user selected states
    * @param jnyList - List of Journeyc records passed by After Insert Trigger operation
    */  
                                                    
    public static void processJourneyStates(List<Journey__c> jnyList) {
        isAfterInsertTriggerFirstRun = false;
        List<Journey__c> jnyListToInsert = new List<Journey__c> ();
        List<Journey__c> jnyInnerList = new List<Journey__c> (); 
        try {
            retrieveStatePicklistValues();      
            retrieveStateCodeMapping();
            for(Journey__c masterJny : jnyList) {                
                if(String.isBlank(masterJny.StateCode__c) && (!String.isBlank(masterJny.ApplicableStates__c) || masterJny.AppliestoAllStates__c)) {               
                    if(masterJny.AppliestoAllStates__c) {                           
                        //create Journey record for all states
                        jnyInnerList = buildJourneyforStates(masterJny, statePicklistValues);                    }
                    else {
                        // create Journey records for user selected states
                        List<String> stateCodeList = new List<String>();
                        stateCodeList = masterJny.ApplicableStates__c.split(';');
                        jnyInnerList = buildJourneyforStates(masterJny, stateCodeList);
                    }
                    jnyListToInsert.addAll(jnyInnerList);
                }
            }
            insertJourneyList(jnyListToInsert);          
        }
        catch (Exception jnyAfterInsertException) {
            LoggingService.logHandledException(jnyAfterInsertException, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);
        }
    }    
 
    //Helper method to retrieve Journey ApplicableState__c picklist values
    private static void retrieveStatePicklistValues () {
        if (!(statePicklistValues != null)) {
            Schema.DescribeFieldResult fieldResult = Journey__c.ApplicableStates__c.getDescribe();
            statePicklistValues = new List<String>();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple) {
                statePicklistValues.add(pickListVal.getLabel());
            } 
        }        
    }
    
    //Helper method to build Journey records based on Master Journey record
    private static List<Journey__c> buildJourneyforStates (Journey__c masterJourney, List<String> applicableStateCodeList) {    
        
        List<Journey__c> stateJourneyList = new List<Journey__c>();
        if(applicableStateCodeList != null &&  !applicableStateCodeList.isEmpty()) {
            for(String stateCode : applicableStateCodeList) {
                //building Journey record for CA, NY and TX states
                if (stateCodeToDupStateCodeMap.containsKey(stateCode)) {
                    for (String duplicateStates : stateCodeToDupStateCodeMap.get(stateCode)) {
                        stateJourneyList.add(cloneJrnyFromMaster(duplicateStates , masterJourney));
                    }
                }
                // building Journey records for all remaining states
                else {
                    stateJourneyList.add(cloneJrnyFromMaster(stateCode, masterJourney));
                }
            }            
        } return stateJourneyList;        
    } 
    
    /** Helper method to clone state Journey records based on Master Journey records
Parameter statecode will pass statecode for all states and numeric statecode for CA, NY and TX
* @description cloneJrnyFromMaster
* @param statecode
* @param masterJourney
* @return Journey__c
*/
    private static Journey__c cloneJrnyFromMaster (String statecode, Journey__c masterJourney) {
        
        String numericStateCode = null;
        numericStateCode = stateCodeMap.get(stateCode);
        if (String.isEmpty(numericStateCode)) {
            numericStateCode = statecode;
        }
        Journey__c clonnedJny = new Journey__c ();
        clonnedJny = masterJourney.clone();
        clonnedJny.StateCode__c = numericStateCode;
        clonnedJny.JourneyNumber__c = masterJourney.Name.right(6);
        clonnedJny.JourneyFundingID__c = masterJourney.Name.right(6);
        clonnedJny.Journey_External_ID__c = masterJourney.Name.right(6) + DELIMITER_HYPEN + numericStateCode;
        clonnedJny.MasterJourneyId__c = masterJourney.id;        
        return clonnedJny;        
    }
    
    //Helper method to retrieve metadata mapping for state and statecode
    private static void retrieveStateCodeMapping () {
        if (metaDataStateCodeMapping == null) {
            metaDataStateCodeMapping = [Select DeveloperName, State__c, StateCode__c
                                        from CM_USStateCodeMapping__mdt where State__c != null Limit 51];
            stateCodeMap = new Map<String, String>();
            if(metaDataStateCodeMapping != null && !metaDataStateCodeMapping.isEmpty()){
                for (CM_USStateCodeMapping__mdt mappingRecord : metaDataStateCodeMapping){
                    stateCodeMap.put(mappingRecord.State__c, mappingRecord.StateCode__c);
                }
            } 
        } 
    }
    



    
    // private method to insert journey list based on CRUD validation
    private static void insertJourneyList (List<Journey__c> journeyListToInsert) {
        if(journeyListToInsert !=null && !journeyListToInsert.isEmpty() && Schema.SObjectType.Journey__c.isCreateable()) {
            insert journeyListToInsert;
        }  
    } 
}