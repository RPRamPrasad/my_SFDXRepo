/**
 * @description CaseEscalationController
 */
public with sharing class CaseEscalationController {

    @TestVisible private Map<TaskTriggerKey, Object> triggerMap = new Map<TaskTriggerKey, Object>();
    private Map<Id, Case> caseMap = new Map<Id, Case>();
    private Map<Id, Case> updatedCaseMap = new Map<Id, Case>();
    private List<Task> tasks = new List<Task>();
    private TriggerOperation operation;
    private ApexValidation validate = new ApexValidation();
    /**
     * @description CaseEscalationController
     * @param triggerMap 
     */
    public CaseEscalationController(Map<TaskTriggerKey, Object> triggerMap){
        this.triggerMap = triggerMap;
        this.operation = (TriggerOperation)triggerMap.get(TaskTriggerKey.TRIGGER_OPERATION);
        this.tasks = (List<Task>)triggerMap.get(TaskTriggerKey.CASE_TASKS);
        this.caseMap = (Map<Id, Case>)triggerMap.get(TaskTriggerKey.CASE_MAP);
        this.updatedCaseMap = (triggerMap.containsKey(TaskTriggerKey.UPDATED_CASE_MAP)) ? (Map<Id,Case>)triggerMap.get(TaskTriggerKey.UPDATED_CASE_MAP) : new Map<Id, Case>();
    }
    /**
     * @description handleCaseEscalation
     * @return  `Map<TaskTriggerKey, Object>`
     */
    public Map<TaskTriggerKey, Object> handleCaseEscalation(){
        for(Task record : this.tasks){
            Case relatedCase = (this.updatedCaseMap.containsKey(record.WhatId)) ? this.updatedCaseMap.get(record.WhatId) : this.caseMap.get(record.WhatId);
            if(isEscalatable(record) && validate.isValidObject(relatedCase)){
                relatedCase = handleEscalation(relatedCase);
                addCaseToMap(relatedCase);
            }
        }
        addResultsToTriggerMap();
        return this.triggerMap;
    }
 
    private Case handleEscalation(Case relatedCase){
        if(!validate.isValidObject(relatedCase.tasks)){ //relatedTasks is null or empty (no related tasks)
            relatedCase.Follow_up_Date__c = null;
            relatedCase.IsEscalated = false; 
        }else{
            Task oldestTask = relatedCase.tasks.get(0);
            relatedCase.Follow_up_Date__c = oldestTask.ActivityDate;
            relatedCase.IsEscalated = true;
        }
        return relatedCase;
    }
    
    private void addCaseToMap(Case relatedCase){
        if(relatedCase.Id != null){
            this.updatedCaseMap.put(relatedCase.Id, relatedCase);
        }
    }
    
    private void addResultsToTriggerMap(){
        if(validate.isValidObject(this.updatedCaseMap)){
            this.triggerMap.put(TaskTriggerKey.UPDATED_CASE_MAP, this.updatedCaseMap);
        }
    }
    
    private boolean isEscalatable(Task record){
        return (isInsert() && !record.isClosed) || isUpdate();
    }
    
    private boolean isUpdate(){
        return (this.operation == TriggerOperation.BEFORE_UPDATE || this.operation == TriggerOperation.AFTER_UPDATE);
    }

    private boolean isInsert(){
        return (this.operation == TriggerOperation.BEFORE_INSERT || this.operation == TriggerOperation.AFTER_INSERT);
    }
}