/**
  * @name CaseAdvanceStageBatch
  * @author Team BabyYoda
  * @createdDate 06/26/2020
  * @description  batch advances case from Request Submitted to Agent Review after 7 days with no updates
  *               and advances from Agent Review to Closed after 30 days with no updates
*/
public with sharing class CaseAdvanceStageBatch implements Schedulable, Database.Batchable<SObject>{
    private static final String CLASS_NAME = 'CaseAdvanceStageBatch';
    private static final String EXECUTE_METHOD_NAME = 'execute';
    private static final String START_METHOD_NAME = 'start';

    private static final String SNOOZE = 'Snooze__c';
    private static final String AGENT_REVIEW = 'Agent Review';
    private static final String REQUEST_SUBMITTED = 'Request Submitted';
    private static final String SETUP_IN_COMPLETE = 'Setup Incomplete';
    private static final Id CASE_RECORDTYPE_ID_POLICY_CHANGE = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE;
    private static final Id CASE_RECORDTYPE_ID_ENROLLMENT_CASE = CaseHandlerConstants.CASE_RECORDTYPE_ID_ENROLLMENT_CASE;

    private static final String CS_CASE_CONFIG_PC_AUTO_CLOSE = 'PolicyChangeAutoCloseDays';
    private static final String CS_CASE_CONFIG_PC_AUTO_UNSNOOZE = 'PolicyChangeAutoUnSnoozeDays';
    private static final String CS_CASE_CONFIG_PC_AUTO_AGENTREVIEW = 'PolicyChangeAutoAgentReviewDays';

    @TestVisible private static List<Case> updatedCases = new List<Case>();

    private static Datetime unSnoozeDate;
    private static Datetime autoAgentReviewDate;
    private static Datetime autoCloseDate;
    
    //Use Default values if Custom Settings is missing
    private static Integer autoCloseDays = 30;
    private static Integer autoAgentReviewDays = 14;
    private static Integer autoUnSnoozeDays = 7;

    private static final CS_Case_Config__c AUTO_CLOSE_DAYS = CS_Case_Config__c.getValues(CS_CASE_CONFIG_PC_AUTO_CLOSE);
    private static final CS_Case_Config__c AUTO_SNOOZE_DAYS = CS_Case_Config__c.getValues(CS_CASE_CONFIG_PC_AUTO_UNSNOOZE);	
    private static final CS_Case_Config__c AUTO_AGENT_REVIEW_DAYS = CS_Case_Config__c.getValues(CS_CASE_CONFIG_PC_AUTO_AGENTREVIEW);

    
    /**
     * @description  
     * @param context
     */
    public void execute(SchedulableContext context) {
        CaseAdvanceStageBatch recordUpdateBatch = new CaseAdvanceStageBatch();
        Database.executeBatch(recordUpdateBatch, 2000);
    }
    
    /**
     * @description  
     * @param context
     * @return
     */
    public Database.QueryLocator start(Database.BatchableContext context){

        String queryString = '';
        try{
            setUpDates();           

            queryString = 'SELECT Id, LastModifiedDate, Status, Automated_System_Events__c, ' +
            '(Select CreatedDate from Histories Where Field = :SNOOZE Order By CreatedDate  Desc Limit 1) ' +
            'FROM Case ' +
            'WHERE RecordTypeId IN(:CASE_RECORDTYPE_ID_POLICY_CHANGE, :CASE_RECORDTYPE_ID_ENROLLMENT_CASE) ' +
            'AND ((Status = :AGENT_REVIEW AND LastModifiedDate < :autoCloseDate AND Follow_Up_Date__c = null) ' +
            'OR (Status = :AGENT_REVIEW AND Snooze__c = true) ' +
            'OR (Status = :REQUEST_SUBMITTED AND LastModifiedDate < :autoAgentReviewDate)'+
            'OR (Status = :SETUP_IN_COMPLETE AND LastModifiedDate < :autoCloseDate))';
        } catch(Exception ex){
            LoggingService.logHandledException(ex, CLASS_NAME, START_METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return Database.getQueryLocator(queryString);
    }

    /**
     * @description
     * @param context
     * @param unprocessedList
     */
    public void execute(Database.BatchableContext context, List<Case> unprocessedList){
        List<Case> changedCases = new List<Case>();
        try{
            if(!unprocessedList.isEmpty()){
            	changedCases = handleStatusUpdates(unprocessedList);
                List<Database.SaveResult> saveResults = Database.update(changedCases, false);
                handleSaveResults(saveResults);
            }
        }catch(Exception ex){
       		LoggingService.logHandledException(ex, CLASS_NAME, EXECUTE_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }

    private void handleSaveResults(List<Database.SaveResult> saveResults){
        DML_AllOrNothingException ex = new DML_AllOrNothingException(saveResults);
        if(String.isNotBlank(ex.getMessage())){
            throw ex;
        }
    }

    /**
     * @description : No code for Finish Method
     * @param context
     */
    public void finish(Database.BatchableContext context){
        // this is enforced method. But need to do nothing. 
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('CaseAdvanceStageBatch', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
    
    private List<Case> handleStatusUpdates(List<Case> unprocessedList){
        setUpDates();
        List<Case> casesToUpdate = new List<Case>();
        for(Case singleCase : unprocessedList){
            if(singleCase.Status == 'Request Submitted'){
                singleCase.Status = 'Agent Review';
                singleCase = setAutomatedSystemEvents(singleCase);
                casesToUpdate.add(singleCase);
            }else if(singleCase.Status == 'Agent Review' && singleCase.LastModifiedDate < autoCloseDate ){
                singleCase.Status = 'Closed';
                singleCase.Snooze__c = false;
                singleCase = setAutomatedSystemEvents(singleCase);
                casesToUpdate.add(singleCase);
            } else if(isReadyToUnSnooze(singleCase)){
                singleCase.Snooze__c = false;
                singleCase = setAutomatedSystemEvents(singleCase);
                casesToUpdate.add(singleCase);
            }else if(singleCase.Status == 'Setup Incomplete' && singleCase.LastModifiedDate < autoCloseDate){
                singleCase.Status = 'Closed';
                singleCase.Snooze__c = false;
                singleCase = setAutomatedSystemEvents(singleCase);
                casesToUpdate.add(singleCase);

            }
        }
        if(Test.isRunningTest()){
            updatedCases = casesToUpdate;
            casesToUpdate = new List<Case>();
        }
        return casesToUpdate;
    }

    private Case setAutomatedSystemEvents(Case singleCase){
        singleCase.Automated_System_Events__c = (singleCase.Automated_System_Events__c != null) ? singleCase.Automated_System_Events__c + 1 : 1;
        return singleCase;
    }

    @TestVisible private boolean isReadyToUnSnooze(Case caseRecord){

        if(caseRecord.Histories == null || caseRecord.Histories.size() ==0){
            return false;
        }

        CaseHistory snoozeHistory = caseRecord.Histories.get(0);
        if(snoozeHistory.CreatedDate < unSnoozeDate){
            return true;
        }

        return false;
    }
    
    private void setUpDates(){

        if(AUTO_CLOSE_DAYS != null){
            autoCloseDays = Integer.valueOf(AUTO_CLOSE_DAYS.Value__c);
        }
        if(AUTO_AGENT_REVIEW_DAYS != null){
            autoAgentReviewDays = Integer.valueOf(AUTO_AGENT_REVIEW_DAYS.Value__c);
        }
        if(AUTO_SNOOZE_DAYS != null){
            autoUnSnoozeDays = Integer.valueOf(AUTO_SNOOZE_DAYS.Value__c);
        }
        autoCloseDate = Datetime.now().addDays(0-autoCloseDays);
        autoAgentReviewDate = Datetime.now().addDays(0-autoAgentReviewDays);
        unSnoozeDate = Datetime.now().addDays(0-autoUnSnoozeDays);
    }

}