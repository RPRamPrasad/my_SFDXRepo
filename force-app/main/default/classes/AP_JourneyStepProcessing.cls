/****************************************************************************************
Name: AP_JourneyStepProcessing
=========================================================================================
* @description : This class will be invoked by JourneyStep Triggers. 
				 Responsible for replication of JourneySteps based on state Journeyrecords
Team: ClubCar
=========================================================================================
History
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  10/11/2018              Initial Development
2.0             ClubCar                  02/04/2019              Added logic for populating Journey ExternalId on Journey Step
3.0             ClubCar                  02/25/2019              Added new helper method to insert master task journey step
4.0             ClubCar                  05/02/2019              Added logic for populating Step Type Code on task journey step 
5.0             ClubCar                  2/20/2020               Updated PMD finding for CRUD violations
******************************************************************************************/ 
public with sharing class AP_JourneyStepProcessing {

    private static final String METADATA_MAPPINGTYPE_JNYSTEPTOACCMSG = 'JourneyStepToAccountMessage';
    private static final String CLASS_NAME = 'AP_JourneyStepProcessing';
    private static final String PREINSERT_METHODNAME = 'processJnyStepsPreInsert';
    private static final String POSTINSERT_METHODNAME = 'processJnyStepsPostInsert';
    public static Boolean insertTriggerFirstRun = true;
    private static final String DELIMITER_HYPEN = '-';
    private static final String CONTACTMETHOD_CALL = 'Call';    
    private static final Integer VENDORCODE = 0;
    private static final Integer STEPTYPECODE_TASK = 3;
    private static Set<Id> masterJrnyIdSet = new Set<Id>();
    private static List<Journey__c> stateJourneyList;
    
    /**
    * @method - processJnyStepsPreInsert
    * @description - Invoked by JourneyStep BeforeInsert Trigger
    *  				 This method will add JourneyStep records with related Journey Fields.
    * @param jrnyStepList - Journey Steps List
    */  
    public void processJnyStepsPreInsert (List <Journey_Step__c> jrnyStepList) {
        try {
            Map<Id, Journey__c> masterJrnyIdToJourney = new Map<Id, Journey__c> ();
            for(Journey_Step__c jrnyStep : jrnyStepList) {
                masterJrnyIdSet.add(jrnyStep.JourneyID__c);
            }
        
            for (Journey__c masterJrny : [Select Id, JourneyName__c,StateCode__c , BusinessLineCode__c, CategoryName__c, JourneyNumber__c, 
                                          JourneyFundingID__c from Journey__c where Id IN : masterJrnyIdSet WITH SECURITY_ENFORCED] ) {
                masterJrnyIdToJourney.put(masterJrny.Id, masterJrny);
            }
        
            for (Journey_Step__c jrnyStepPreInsert : jrnyStepList) {
                jrnyStepPreInsert.JourneyName__c = masterJrnyIdToJourney.get(jrnyStepPreInsert.JourneyID__c).JourneyName__c;
                jrnyStepPreInsert.StateCode__c = masterJrnyIdToJourney.get(jrnyStepPreInsert.JourneyID__c).StateCode__c;
                jrnyStepPreInsert.BusinessLineCode__c = masterJrnyIdToJourney.get(jrnyStepPreInsert.JourneyID__c).BusinessLineCode__c;
                jrnyStepPreInsert.CategoryName__c = masterJrnyIdToJourney.get(jrnyStepPreInsert.JourneyID__c).CategoryName__c;
                jrnyStepPreInsert.Bundle_ID__c = masterJrnyIdToJourney.get(jrnyStepPreInsert.JourneyID__c).JourneyFundingID__c;
                jrnyStepPreInsert.JourneyNumber__c = masterJrnyIdToJourney.get(jrnyStepPreInsert.JourneyID__c).JourneyNumber__c;
            }
        }
        catch (Exception jnyStepPreInsertExp) {
            LoggingService.logHandledException(jnyStepPreInsertExp, CLASS_NAME, PREINSERT_METHODNAME, LoggingLevel.ERROR);
        }        
    }
    
    /**
    * @method - processJnyStepsPostInsert
    * @description - Invoked by JourneyStep AfterInsert Trigger
    *  				 This method will replicate current master JourneyStep into state JourneySteps based on State Journey records
    * @param jrnyStepList - Journey Steps List
    */
    public void processJnyStepsPostInsert (List <Journey_Step__c> jrnyStepList) {
        try {
            List<Journey_Step__c> jrnyStepListToInsert = New List<Journey_Step__c>();         
            //Map of MasterJourneyID and JourneyStep__c Object            
            Map<Id, List<Journey_Step__c>> mastJrnyIdJrnyStepMap = buildMasterJrnyIdToStepMap(jrnyStepList);     
            //Map of JourneyId and MasterJourneyID
            Map<Id, Id> jrnyIdMasterJrnyIdMap = buildStateJrnyIdToMasterJrnyIdMap();          
        
            //Build Journey Step record for each State Journey record
            if (!stateJourneyList.isEmpty()) {
                for (Journey__c stateJrny : stateJourneyList) {                
                    Id masterJourneyId = jrnyIdMasterJrnyIdMap.get(stateJrny.id);
                    List<Journey_Step__c> listToBeCloned = mastJrnyIdJrnyStepMap.get(masterJourneyId);
                    for(Journey_Step__c theClonedJourneyStep: listToBeCloned) {
                        Journey_Step__c jnyStepToCreate = new Journey_Step__c ();
                        //Using the sObject clone method to copy JourneyStep   
                        jnyStepToCreate = theClonedJourneyStep.clone();
                        jnyStepToCreate.JourneyID__c = stateJrny.Id;
                        jnyStepToCreate.StateCode__c = stateJrny.StateCode__c;
                        //Populate JourneyStep External Id
                        if (stateJrny.Journey_External_ID__c != null && theClonedJourneyStep.JourneyStepID__c != null){
                            jnyStepToCreate.ExternalJourneyStepIdentifier__c = stateJrny.Journey_External_ID__c + DELIMITER_HYPEN + theClonedJourneyStep.JourneyStepID__c;
                            jnyStepToCreate.Journey_External_ID__c = stateJrny.Journey_External_ID__c;
                        }
                        jrnyStepListToInsert.add(jnyStepToCreate);
                    }   
                }            
                insertJourneyStepList(jrnyStepListToInsert);
            }
        }
        catch (Exception jnyStepPostInsertExp ) {
            LoggingService.logHandledException(jnyStepPostInsertExp, CLASS_NAME, POSTINSERT_METHODNAME, LoggingLevel.ERROR); 
        }
    }
    
    /**
    * @method - insertTaskJourneyStep
    * @description - Helper method to insert JourneyStep of type Task recieved from JourneyStepTask Lightning component
    * @param masterJnyStep - Master Journey Step
    */
       public void insertTaskJourneyStep(Journey_Step__c masterJnyStep) {
                           
        masterJnyStep.JourneyStepID__c = UTIL_LtngJourneyProcess.getJourneyStepId(masterJnyStep.JourneyID__c);
        masterJnyStep.VendorCode__c = VENDORCODE;
        masterJnyStep.ContactMethodName__c = CONTACTMETHOD_CALL;
        masterJnyStep.steptypecode__c = STEPTYPECODE_TASK;               
        insert masterJnyStep;
    }

    // private method to insert Journey Step list based on CRUD validation
    private static void insertJourneyStepList (List<Journey_Step__c> journeyStepListToInsert) {
        if(journeyStepListToInsert !=null && !journeyStepListToInsert.isEmpty() && Schema.SObjectType.Journey_Step__c.isCreateable()) {
            insert journeyStepListToInsert;
        }  
    }
    
    // helper method to populate map for master JourneyId and associated JourneySteps
    private static Map<Id, List<Journey_Step__c>> buildMasterJrnyIdToStepMap (List<Journey_Step__c> jrnyStepList) {
        Map<Id, List<Journey_Step__c>> mastJrnyIdJrnyStepMap = new Map<Id, List<Journey_Step__c>>(); 
        // Iterate through JourneyStep List and collect thier JourneyId                    
        for(Journey_Step__c jrnyStep : jrnyStepList) {
            masterJrnyIdSet.add(jrnyStep.JourneyID__c);
            List<Journey_Step__c> stepsWithinTheMaster = mastJrnyIdJrnyStepMap.get(jrnyStep.JourneyID__c);
            if(stepsWithinTheMaster==null) {
                stepsWithinTheMaster = new List<Journey_Step__c>();
            }
            stepsWithinTheMaster.add(jrnyStep);     
            mastJrnyIdJrnyStepMap.put(jrnyStep.JourneyID__c,stepsWithinTheMaster);              
        }
        return mastJrnyIdJrnyStepMap;
    }

    // helper method to pull State Journey records that need JourneyStep replication
    private static Map<Id, Id> buildStateJrnyIdToMasterJrnyIdMap() {
        Map<Id, Id> jrnyIdMasterJrnyIdMap = new Map<Id, Id>();
        stateJourneyList = new List<Journey__c>();
        for (Journey__c stateJrnyRecord : [Select Id, MasterJourneyId__c, StateCode__c, Journey_External_ID__c 
                                                from Journey__c where MasterJourneyId__c IN : masterJrnyIdSet WITH SECURITY_ENFORCED]) {
            stateJourneyList.add(stateJrnyRecord);
            jrnyIdMasterJrnyIdMap.put(stateJrnyRecord.id, stateJrnyRecord.MasterJourneyId__c);
        }
        return jrnyIdMasterJrnyIdMap;   
    }
}