/****************************************************************************************
Name: HLPR_StartStopJourney
=========================================================================================
@description Helper for CMP_CaseStartStopJourney class. Test coverage will be covered by CMP_CaseStartStopJourney_Test 
=========================================================================================
History
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  03/07/2019              Initial Development
2.0				ClubCar					 06/14/2019				 Removed references to Task - Journey recordtype
3.0             ClubCar                  02/20/2020              Updated PMD finding for CRUD violations
4.0             ClubCar                  02/20/2020              Updated PMD finding for SOQL Injection
******************************************************************************************/ 
public with sharing class HLPR_StartStopJourney {

    public static Map<Id, List<Journey_Step__c>> jrnyIdAndStepMap;
    public static List<Journey__c> journeyList;
    private static final String CATEGORY_NAME = 'Cases';
    private static List<CM_USStateCodeMapping__mdt> metaDataStateCodeMapping;
    private static Map<String, String> stateCodeMap;
    private static final String JOURNEYSTEP_TYPE_CALL = 'Call';
    private static final String TASK_STATUS_NOTSTARTED  = 'Not Started';
    private static final String TASK_PRIORITY_NO  = 'No';
    private static final String TASK_TASKTYPE_SERVICE  = 'Service';
    private static final String TASK_APPCODE_CASEJOURNEY = 'Case Journey';
    private static final String TASK_CATEGORY_JOURNEY  = 'Journey';
    private static final String START_JOURNEY_ACTION_TYPE = 'Journey Started';
    private static final String STOP_JOURNEY_ACTION_TYPE = 'Journey Stopped';
    private static final String TASK_STATUS_CANCELLED  = 'Cancelled';
    
    /**
    * @description retrive case record with required fields
    * @param recordId
    * @return Case record
    */
    public static Case retrieveCaseRecord(Id recordId ) {
        return [Select id, OwnerId, Assigned_To__c, LOB__c, Account.PersonContactId, Account.Name,JourneyName__c,
 						JourneyId__c, JourneyDescription__c, JourneyStartDate__c, AccountId, Account.ShippingState, Account.BillingState 
 						from Case where id =:recordId WITH SECURITY_ENFORCED LIMIT 1];
    }

    /**
    * @description retrive Journey record with required fields
    * @param journeyId
    * @return Journey record
    */
    public static Journey__c retrieveJourneyRecord(Id journeyId ) {
        return [Select id, Journey_External_ID__c, JourneyName__c, JourneyDescription__c 
		                             from Journey__c where id =:journeyId WITH SECURITY_ENFORCED LIMIT 1];
    }
    
    /**
    * @description query applicable Journey and related steps based on provided case details
    * @param caseRecord
    * @return jrnyList - List of Journeys
    */
    public static List<Journey__c> queryJourneyAndStepDetails (Case caseRecord) {
        retrieveStateCodeMapping();
        String stateCode = decideJrnyStateForAcc(caseRecord.Account.ShippingState, caseRecord.Account.BillingState);
        String numericStateCode = stateCodeMap.get(stateCode);
        List<Journey__c> jrnyList = [SELECT id, name, StateCode__c, JourneyName__c, EffectiveDate__c,(SELECT id, name, JourneyName__c, JourneyStepID__c, StepTypeCode__c, ContactMethodName__c,
                                        ItemEffectiveDate__c, Cost__c,LetterName__c,Script__c,DaysNum__c, Bundle_ID__c, MailClassCode__c,ItemID__c FROM journey_step__r ORDER BY JourneyStepID__c ASC) 
                                            FROM journey__c WHERE Categoryname__c=:CATEGORY_NAME AND EffectiveDate__c <=today AND ExpirationDate__c>=today AND StateCode__c=:numericStateCode WITH SECURITY_ENFORCED];
        if(jrnyList!= null && !jrnyList.IsEmpty()){
            populateJrnyIdAndStepsMap(jrnyList);
        }
        return jrnyList;
    }
    
    /**
    * @description Helper method to populate map of Journey Id and related Steps for page component
    * @param jrnyList - List of journeys passed
    */
    public static void populateJrnyIdAndStepsMap (List<Journey__c> jrnyList) {

        jrnyIdAndStepMap = new Map<Id, List<Journey_Step__c>> ();
        for (Journey__c jrny : jrnyList) {
            jrnyIdAndStepMap.put(jrny.id, jrny.journey_step__r); 
        }
    }
    
    // Helper method to decide applicable state for displaying Journey's. Account shipping state takes precedence over Account billing state
    private static String decideJrnyStateForAcc (String shippingState, String billingState) {
        if (String.IsNotBlank(shippingState)){
            return shippingState;
        }        
        else {
            return billingState;
        }
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
    
    /**
    * @description Helper method to apply selected Journey on Case - Journey Tasks would be created and Account messages would be created, if applicable
    * @param caseRecordId    
    * @param selectedJourneyId
    */
    public static void applyJourneyOnCase(Id caseRecordId, Id selectedJourneyId) {
	    Savepoint sp = Database.setSavepoint();
	    try {
	        Case caseRecord = retrieveCaseRecord(caseRecordId); 
	        Journey__c selectedJourney = retrieveJourneyRecord(selectedJourneyId);	                                      
	        updateCaseWithJrnyDetails(caseRecord, selectedJourney);
	        createCaseJourneyTasks(caseRecord, selectedJourney);
	        AP_JourneyTracker.trackCaseJourney(START_JOURNEY_ACTION_TYPE,new List<Case>{caseRecord});
	    } catch (Exception applyCaseJourneyExp) {
	        Database.rollback(sp);
	        throw applyCaseJourneyExp;
	    }    
	}
    
    //Helper method to update case record with selected Journey details
    private static void updateCaseWithJrnyDetails (Case caseRecord, Journey__c selectedJourney) {
        if (caseRecord != null && selectedJourney != null && Schema.sObjectType.Case.isUpdateable()) {   
            caseRecord.JourneyID__c = selectedJourney.Journey_External_ID__c;
            caseRecord.JourneyName__c = selectedJourney.JourneyName__c;
            caseRecord.JourneyDescription__c = selectedJourney.JourneyDescription__c;
            caseRecord.JourneyStartDate__c = System.Today();
            update caseRecord;
        }
    }    
    
    //Helper method to create Journey Task on Case for all Journey Steps of contactmethod type 'Call'  
    private static void createCaseJourneyTasks(Case caseRecord, Journey__c selectedJourney) {
        List<Task> listTaskToInsert = new List<Task>();
        if (caseRecord != null && selectedJourney != null) {
           for (Journey_Step__c selectedJrnyStep : [Select id, LetterName__c, JourneyStepID__c,DaysNum__c, Script__c from Journey_Step__c
                                                 where JourneyID__c =:selectedJourney.id AND ContactMethodName__c =:JOURNEYSTEP_TYPE_CALL WITH SECURITY_ENFORCED]) {
                Task journeyTask = New Task();
                journeyTask.AssignedTo__c =  caseRecord.Assigned_To__c;
                journeyTask.whoid =  caseRecord.Account.PersonContactId;
                journeyTask.ownerid =  caseRecord.ownerid;
                journeyTask.Whatid = caseRecord.id;
                journeyTask.LineofBusiness__c = caseRecord.LOB__c;                                                     
                journeyTask.JourneyName__c = selectedJourney.JourneyName__c;
                journeyTask.JourneyId__c = selectedJourney.id;                                                     
                journeyTask.Status = TASK_STATUS_NOTSTARTED;                                                     
                journeyTask.Subject = selectedJrnyStep.LetterName__c;
                journeyTask.AppCode__c = TASK_APPCODE_CASEJOURNEY;
                journeyTask.TaskCategory__c = TASK_CATEGORY_JOURNEY;
                journeyTask.Task_Type__c = TASK_TASKTYPE_SERVICE;           
                journeyTask.StepNumber__c = selectedJrnyStep.JourneyStepID__c;
                journeyTask.Priority = TASK_PRIORITY_NO; 
                if (selectedJrnyStep.DaysNum__c != null) {
                    journeyTask.ActivityDate =  caseRecord.JourneyStartDate__c.AddDays(selectedJrnyStep.DaysNum__c.intValue());
                }                               
                if (selectedJrnyStep.Script__c != null) {
                    journeyTask.Description = selectedJrnyStep.Script__c;
                }   
                listTaskToInsert.add(journeyTask);
            }
        }
        insertTaskList(listTaskToInsert);
    }
      
 	//*************************************** Stop Journey Operation***************************************************//
    
    /**
    * @description Helper Method to Stop Journey on Case
    * @param caseRecordId
    */
    public static void stopJourneyOnCase(Id caseRecordId) {
	    Savepoint sp = Database.setSavepoint();
	    try {
	        Case caseRecord = retrieveCaseRecord(caseRecordId);
            Journey__c appliedJrny = [Select id from Journey__c where Journey_External_ID__c =: caseRecord.JourneyID__c WITH SECURITY_ENFORCED Limit 1];
	        AP_JourneyTracker.trackCaseJourney(STOP_JOURNEY_ACTION_TYPE,new List<Case>{caseRecord});
            cancelCaseJourneyTasks(new Set<Id>{caseRecordId}, new Set<Id>{appliedJrny.id});
            updateCaseJourneyFieldsAsNull(new List<Case>{caseRecord});            
	    } catch (Exception applyStopJourneyExp) {
	        Database.rollback(sp);
	        throw applyStopJourneyExp;
	    }    
	}

    //Helper method to update Case Journey fields as null
    private static void updateCaseJourneyFieldsAsNull (List<Case> caseRecordList) {
        List<Case> casesToUpdateList = new List<Case> ();
        for (Case caserecord : caseRecordList) {
            caserecord.JourneyID__c = null;
            caserecord.JourneyName__c = null;
            caserecord.JourneyDescription__c = null;
            caserecord.JourneyStartDate__c = null;
            casesToUpdateList.add(caserecord);
        }        
        if (!casesToUpdateList.isEmpty()) {
            update casesToUpdateList;
        }            
    }
    
    //Helper method to cancel Journey tasks on current case
    private static void cancelCaseJourneyTasks (Set<Id> caseRecordIdSet, Set<Id> appliedJourneyIdSet) {
        List<Task> taskToCancelList = new List<Task>();        
        for (Task taskToCancel : [Select id, IsClosed from Task where JourneyId__c IN: appliedJourneyIdSet
                                  And Whatid IN: caseRecordIdSet and Isclosed = false WITH SECURITY_ENFORCED]) {                                      
			taskToCancel.Status = TASK_STATUS_CANCELLED;
            taskToCancelList.add(taskToCancel);
        }        
        if(!taskToCancelList.isEmpty() && Schema.sObjectType.Task.isUpdateable()) {
            update taskToCancelList;    
        }            
    }

    //method to insert task list based on CRUD validation
    private static void insertTaskList (List<Task> taskListToInsert) {
        if(!taskListToInsert.isEmpty()) {
            insert taskListToInsert;
        }  
    }
}