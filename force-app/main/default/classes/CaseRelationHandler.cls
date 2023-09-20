/**
 * @description CaseRelationHandler
 */
public with sharing class CaseRelationHandler {
    
    @TestVisible private Map<TaskTriggerKey, Object> triggerMap = new Map<TaskTriggerKey, Object>();
    private Map<Id, Case> caseMap = new Map<Id, Case>();
    private Map<Id, Case> updatedCaseMap = new Map<Id, Case>();
    private ApexValidation validate = new ApexValidation();
    /**
     * @description CaseRelationHandler
     * @param triggerMap 
     */
    public CaseRelationHandler(Map<TaskTriggerKey, Object> triggerMap){
        this.triggerMap = triggerMap;
        this.caseMap = (Map<Id,Case>)triggerMap.get(TaskTriggerKey.CASE_MAP);
        this.updatedCaseMap = (triggerMap.containsKey(TaskTriggerKey.UPDATED_CASE_MAP)) ? (Map<Id,Case>)triggerMap.get(TaskTriggerKey.UPDATED_CASE_MAP) : new Map<Id, Case>();
    }
    /**
     * @description handleRelatedCases
     * @return  `Map<TaskTriggerKey, Object>`
     */
    public Map<TaskTriggerKey, Object> handleRelatedCases(){ //Main Method
        getCaseMap();
        if(validate.isValidObject(this.caseMap.values())){
            for(Case record : this.caseMap.values()){
                record = handleCaseChanges(record);
                addCaseToMap(record); 
            }
            addResultsToTriggerMap();
        }
        return this.triggerMap;
    }
    
    private void getCaseMap(){
        this.caseMap = (triggerMap.containsKey(TaskTriggerKey.CASE_MAP)) ? (Map<Id, Case>)triggerMap.get(TaskTriggerKey.CASE_MAP) : new Map<Id,Case>();
    }
    
    private Case handleCaseChanges(Case record){ 
        handleOpenTasks(record);
        closeCOACase(record); 
        return record;
    }
    /**
     * @description handleOpenTasks
     * @param record 
     * @return  `Case`
     */
    public Case handleOpenTasks(Case record){//RE-Open Case if there is an open task.
        if(validate.isValidObject(record.tasks) && record.IsClosed){ //Do no reopen if the 1st task in the task list is a log
            reopenCase(record);
        }
        return record;
    }
    /**
     * @description closeCOACase
     * @param record 
     * @return  `Case`
     */
    public Case closeCOACase(Case record){//Close Open COA Case if there are no more open tasks
        if(CaseHandlerConstants.CASE_REASON_CHANGE_OF_ADDRESS.equalsIgnoreCase(record.Reason) && record.tasks.isEmpty() && !record.IsClosed){
            record.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
        }
        return record;
    }
    
    private Case reopenCase(Case record){
        if(record.recordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST 
        || record.recordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_RETENTION){
            record.Status = CaseHandlerConstants.CASE_STATUS_PENDING;
        } else if(record.recordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE){
            record.Status = CaseHandlerConstants.CASE_STATUS_AGENT_REVIEW;
        }
		return record;
    }
    
    private void addCaseToMap(Case record){
        if(record.Id != null){
           this.updatedCaseMap.put(record.Id, record);
        }
    }
    
    private void addResultsToTriggerMap(){
        if(!this.updatedCaseMap.isEmpty()){
            this.triggerMap.put(TaskTriggerKey.UPDATED_CASE_MAP, this.updatedCaseMap);
        }
    }
}