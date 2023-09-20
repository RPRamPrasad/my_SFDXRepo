/**
 * @description CaseRelationUtil
 */
public with sharing class CaseRelationUtil {

	@TestVisible private Map<TaskTriggerKey, Object> triggerMap = new Map<TaskTriggerKey, Object>();
    private List<Task> tasks = new List<Task>();
    private Set<Id> caseIds = new Set<Id>();
    private Map<Id, Case> caseMap = new Map<Id, Case>();
    
    /**
     * @description CaseRelationUtil
     * @param triggerMap 
     */
    public CaseRelationUtil(Map<TaskTriggerKey, Object> triggerMap){
        this.triggerMap = triggerMap;
        this.caseIds = (Set<Id>)triggerMap.get(TaskTriggerKey.CASE_IDS);
        this.tasks = (List<Task>)triggerMap.get(TaskTriggerKey.CASE_TASKS);
    }
    /**
     * @description setupController
     * @return  `Map<TaskTriggerKey, Object>`
     */
    public Map<TaskTriggerKey, Object> setupController(){ //Main Method
        this.caseMap = new Map<Id, Case>(getCaseAndTaskData());
        this.triggerMap.put(TaskTriggerKey.CASE_MAP, this.caseMap);
        return this.triggerMap;
    }
    
    private List<Case> getCaseAndTaskData(){
        return [SELECT Id, Reason, Status, IsClosed, RecordTypeId, 
                      (SELECT Id, ActivityDate, WhatId, isClosed, RecordTypeId, Status 
                       FROM Tasks 
                       WHERE IsRecurrence = false 
                       AND IsClosed = false
                       ORDER BY ActivityDate ASC LIMIT 10) 
                      FROM Case WITH_SECURITY_ENFORCED 
                      WHERE Id IN: this.caseIds];
    } 
}