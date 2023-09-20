/****************************************************************************************
Name: HLPR_JourneyEditAndDeleteTrigger
=========================================================================================
* @description : Helper class for AP_JourneyEditAndDeleteTrigger apex class
Team: ClubCar
=========================================================================================
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  02/26/2020             Initial Development
******************************************************************************************/ 
public with sharing class HLPR_JourneyEditAndDeleteTrigger {
    private static Map<Id, List<Journey_Step__c>> masterJourneyToMasterJourneyStepListMap;
    private static Map<Id, List<Journey_Step__c>> masterJourneyToChildJourneyStepListMap;
    private static List<Journey_Step__c> jnyStepList;

    /**
    * @method - applyJourneyEditsToJourneySteps
    * @description - This method will be update JourneySteps for edited Journey records
    * @param masterJourneyIdList - List of master Journey Id's
    * @param masterJourneyList - List of Journey__c records
    */
    public static void applyJourneyEditsToJourneySteps(List<Id> masterJourneyIdList, List<Journey__c> masterJourneyList){
        jnyStepList = [Select id,JourneyId__c,JourneyId__r.Masterjourneyid__c from journey_Step__c 
                                where journeyid__c IN:masterJourneyIdList OR journeyid__r.masterjourneyid__c IN:masterJourneyIdList WITH SECURITY_ENFORCED];            
        populateJourneyToMasterJourneyStepsMap(jnyStepList);
        populateJourneyToChildJourneyStepsMap(jnyStepList);
        updateJourneyStepsList(masterJourneyList);
    }

    //Helper method to map list of master journey steps with associated edited master journey
    private static void populateJourneyToMasterJourneyStepsMap(List<Journey_Step__c> jnyStepList){
        masterJourneyToMasterJourneyStepListMap = new Map<Id, List<Journey_Step__c>>();
        List<Journey_Step__c> masterJourneyStepListForMap;
        for (Journey_Step__c masterJourneyStep : jnyStepList) {
            masterJourneyStepListForMap = masterJourneyToMasterJourneyStepListMap.get(masterJourneyStep.JourneyId__c);
            
            if(masterJourneyStepListForMap == null){               
                masterJourneyStepListForMap = new List<Journey_Step__c> ();
                masterJourneyStepListForMap.add(masterJourneyStep);
            }else{
                masterJourneyStepListForMap.add(masterJourneyStep);
            }
            masterJourneyToMasterJourneyStepListMap.put(masterJourneyStep.JourneyId__c, masterJourneyStepListForMap);   
        }
    }

    //Helper method to map list of child journey steps with associated edited master journey
    private static void populateJourneyToChildJourneyStepsMap(List<Journey_Step__c> jnyStepList){
        masterJourneyToChildJourneyStepListMap = new Map<Id, List<Journey_Step__c>>();
        List<Journey_Step__c> childJourneyStepListForMap;
        for (Journey_Step__c childJourneyStep : jnyStepList) {
            childJourneyStepListForMap = masterJourneyToChildJourneyStepListMap.get(childJourneyStep.JourneyId__r.Masterjourneyid__c);
            if(childJourneyStepListForMap == null){               
                childJourneyStepListForMap = new List<Journey_Step__c> ();
                childJourneyStepListForMap.add(childJourneyStep);
            }else{
                childJourneyStepListForMap.add(childJourneyStep);
            }
            masterJourneyToChildJourneyStepListMap.put(childJourneyStep.JourneyId__r.Masterjourneyid__c, childJourneyStepListForMap);
        }
    }

    //Helper method to update journeysteps
    private static void updateJourneyStepsList(List<Journey__c> masterJourneyList){
        List<Journey_Step__c> jrnyStepListToBeUpdated = new List<Journey_Step__c>();
        for(Journey__c masterEditedJourney : masterJourneyList){
            List<Journey_Step__c> jrnyStepList = new List<Journey_Step__c>();
            jrnyStepList.addAll(masterJourneyToMasterJourneyStepListMap.get(masterEditedJourney.id));
            jrnyStepList.addAll(masterJourneyToChildJourneyStepListMap.get(masterEditedJourney.id));
            for (Journey_Step__c masterJrnyStep : jrnyStepList){
                masterJrnyStep.JourneyName__c = masterEditedJourney.JourneyName__c;
                masterJrnyStep.BusinessLineCode__c = masterEditedJourney.BusinessLineCode__c;
                masterJrnyStep.CategoryName__c = masterEditedJourney.CategoryName__c;
                jrnyStepListToBeUpdated.add(masterJrnyStep);
            }
        }
        updateJourneySteps(jrnyStepListToBeUpdated);
    }

    //method to update journey steps
    private static void updateJourneySteps(List<Journey_Step__c> jrnyStepListToBeUpdated){
        if(!jrnyStepListToBeUpdated.isEmpty() && Schema.sObjectType.Journey_Step__c.isUpdateable()){
            update jrnyStepListToBeUpdated;
        }
    }

}