/**
 * @description CaseRelationService
 */
public with sharing class CaseRelationService {

    
    @TestVisible private Map<TaskTriggerKey, Object> triggerMap = new Map<TaskTriggerKey, Object>();
    private List<Task> tasks = new List<Task>();
    private boolean isEscalationUser = false;
    private boolean isTechSupportUser = false;
    private ApexValidation validate = new ApexValidation();
    private CasePermissionUtil permissionUtil = new CasePermissionUtil();
    private CaseRelationUtil util;
    
    /**
     * @description CaseRelationService
     * @param triggerMap 
     */
    public CaseRelationService(Map<TaskTriggerKey, Object> triggerMap){
        this.triggerMap = triggerMap; //Should have Case Tasks, Trigger Operation, and Case Ids only at this point
        this.tasks = (List<Task>)triggerMap.get(TaskTriggerKey.CASE_TASKS);
        this.isEscalationUser = permissionUtil.isCaseEscalationUser();
        this.isTechSupportUser = permissionUtil.isTechSupportUser();
    }
    /**
     * @description handleCaseRelations
     */
    public void handleCaseRelations(){//Main Method
        if(validate.isValidObject(this.tasks)){ //Consider removing
            setupController();
            handleRelatedCases();
            handleCaseEscalation();
            handleCaseToUpdate();
        }
    }
    
    private void setupController(){
        util = new CaseRelationUtil(this.triggerMap);
        this.triggerMap = util.setupController(); //Should add the Case Map to the trigger Map
    }

    private void handleRelatedCases(){
        if(!this.isTechSupportUser){
            CaseRelationHandler handler = new CaseRelationHandler(this.triggerMap);
            this.triggerMap = handler.handleRelatedCases();
        }
    }
    
    private void handleCaseEscalation(){
        if(this.isEscalationUser){
            CaseEscalationController escalation = new CaseEscalationController(this.triggerMap);
            this.triggerMap = escalation.handleCaseEscalation();
        }
    }

    private void handleCaseToUpdate(){
        if(this.triggerMap.containsKey(TaskTriggerKey.UPDATED_CASE_MAP)){
            updateCases();
        }
    }

    
    private void updateCases(){
        try{
            Map<Id, Case> updatedCases = (Map<Id, Case>)this.triggerMap.get(TaskTriggerKey.UPDATED_CASE_MAP);
            Database.update(updatedCases.values(), false);
        }catch(Exception ex){
            LoggingService.logHandledException(ex, 'CaseRelationService', 'updateCases', System.LoggingLevel.ERROR);
        }
    }

}