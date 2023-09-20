/**
* @description TemplateTriggerHandler
* @Owner: Task team
*/
public with sharing class TemplateTriggerHandler {

    Map<TemplateTriggerKey, Object> triggerMap = new Map<TemplateTriggerKey, Object>();
    List<Template__c> templates = new List<Template__c>();
    Map<Id, Template__c> oldMap = new Map<Id, Template__c>();
    TriggerOperation operation;
    Integer numberOfOfficeTemplates = 0;
    Integer maxNumberOfTemplates = 50;
    boolean isAgencyUser = false;
   	ApexValidation validate = new ApexValidation();

    /**
     * @name TemplateTriggerHandler
     * @description TemplateTriggerHandler
     * @param triggerMap
     */
    public TemplateTriggerHandler(Map<TemplateTriggerKey, Object> triggerMap){
        this.triggerMap = triggerMap;
        this.templates = (List<Template__c>)triggerMap.get(TemplateTriggerKey.TEMPLATES);
        this.oldMap = (Map<Id, Template__c>)triggerMap.get(TemplateTriggerKey.OLD_TEMPLATE_MAP);
        this.operation = (TriggerOperation)triggerMap.get(TemplateTriggerKey.TRIGGER_OPERATION);
        this.isAgencyUser = FeatureManagement.checkPermission('Agency_User');
    }

    /**
     * @name handleTemplates
     * @description handleTemplates
     */
    public void handleTemplates(){
        if(validate.isValidObject(this.templates)){
            handleTriggers();
        }
    }

    private void handleTriggers(){
        if(isBeforeTrigger()){
            handleSPI();
            handleAgencyUsers();
        }
    }

    private void handleAgencyUsers(){
        if(this.isAgencyUser){
            handleLimit();
            handleOwner();
        }
    }

    private void handleLimit(){
        if(isInsert()){
            getOfficeTemplateCount();
            preventTemplateLimit();
        }
    }

    private void preventTemplateLimit(){
        if(this.numberOfOfficeTemplates >= this.maxNumberOfTemplates){
            for(Template__c template: this.templates){
                template.addError('You have reached the maximum number of allowed Templates, ' + maxNumberOfTemplates + '. Please review and delete templates that are no longer needed.');
            }
        }
    }

    private void handleSPI(){
        SObjectSPIHelper spiHelper;
        spiHelper = new SObjectSPIHelper(this.templates);
    }

    private void handleOwner(){
        SObjectOwnerHelper ownerHelper;
        if(isUpdate() && validate.isValidObject(this.oldMap)){
            ownerHelper = new SObjectOwnerHelper(this.templates, this.oldMap, false);
        }else if(isInsert()){
            ownerHelper = new SObjectOwnerHelper(this.templates, false);
        }
    }

    private void getOfficeTemplateCount(){
    	this.numberOfOfficeTemplates = [SELECT COUNT() FROM Template__c WHERE Is_Owned_By_My_Office__c = true AND RecordTypeId =: Schema.SObjectType.Template__c.getRecordTypeInfosByDeveloperName().get('Agent_Office').getRecordTypeId() WITH SECURITY_ENFORCED];
    }

    private boolean isBeforeTrigger(){
        return (this.operation == TriggerOperation.BEFORE_UPDATE || this.operation == TriggerOperation.BEFORE_INSERT);
    }

    private boolean isInsert(){
        return (this.operation == TriggerOperation.BEFORE_INSERT || this.operation == TriggerOperation.AFTER_INSERT);
    }

    private boolean isUpdate(){
        return (this.operation == TriggerOperation.BEFORE_UPDATE || this.operation == TriggerOperation.AFTER_UPDATE);
    }

}