/**
 * @name TaskAfterTrigger
 * @description handles the After trigger for Task object
*/
public with sharing class TaskAfterTrigger {
    
    private Map<TaskTriggerKey, Object> triggerMap = new Map<TaskTriggerKey, Object>();
    private List<Task> tasks;
    private Set<Id> caseIds = new Set<Id>();
    private List<Task> caseTasks = new List<Task>();
    private TaskPermissionUtil permissionUtil = new TaskPermissionUtil();
    private ApexValidation validate = new ApexValidation();
    private CS_FeatureToggle__c featureToggle = CS_FeatureToggle__c.getInstance();

    /**
     * @name TaskAfterTrigger
     * @description sets the tasks variable and populates the triggerMap 
     * @param tasks
     * @param operation
     */
    public TaskAfterTrigger(List<Task> tasks, TriggerOperation operation){
        this.tasks = tasks;
        this.triggerMap.put(TaskTriggerKey.TRIGGER_OPERATION, operation);
    }

    /**
     * @name handleAfterTrigger
     * @description Main Method that checks for the permission on Task API and Jarvis
     */
    public void handleAfterTrigger(){
        if(permissionUtil.isPrevalidatedUser()){ //This 
            return;
        }else{
            handleTasks();
        } 
    }

    private void handleTasks(){
        if(validate.isValidObject(this.tasks)){
            handleCampaignTasks();
        	handleCaseTasks();
        }
    }
    
    private void handleCampaignTasks(){
        if(this.featureToggle.CampaignTaskProgress__c){
            UTIL_CampaignTaskProgress.updateCampaignTaskCompletion(this.tasks);
        } 
    }
    
    private void handleCaseTasks(){
        getCaseTasks();
        if(!this.caseTasks.isEmpty()){
            this.triggerMap.put(TaskTriggerKey.CASE_TASKS, this.caseTasks);
            this.triggerMap.put(TaskTriggerKey.CASE_IDS, this.caseIds);
            CaseRelationService service = new CaseRelationService(this.triggerMap);
            service.handleCaseRelations();
        } 
    }
    
    private void getCaseTasks(){
        for(Task taskRecord : this.tasks){
            if(isCaseTask(taskRecord)){
                this.caseTasks.add(taskRecord);
                this.caseIds.add(taskRecord.WhatId);
            }
        }
    }
    
    private boolean isCaseTask(Task taskRecord){
        return (taskRecord.WhatId != null && (String.valueOf(taskRecord.WhatId).startsWith('500') || taskRecord.IsCaseTask__c));
    }
    
}