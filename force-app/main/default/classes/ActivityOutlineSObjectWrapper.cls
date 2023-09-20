/**
 * @description Class that is used to wrap different types of objects to be returned to activity outline
 */
public with sharing class ActivityOutlineSObjectWrapper extends ActivityOutlineSObjectWrapperBase {

    private static final String DATE_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'';
    
    /** @description flag type */
    @AuraEnabled
    public String flagType{get;set;}

    /** @description due date */
    @AuraEnabled
    public Date dueDate{get;set;}

    /** @description event start date and time */
    @AuraEnabled
    public Datetime eventStartDateTime{get;set;}

    /** @description display date */
    @AuraEnabled
    public DateTime displayDate{get;set;}

    /** @description boolean that indicates if this is an all-day event */
    @AuraEnabled
    public Boolean isAllDayEvent{get;set;}

    /** @description opportunity stage */
    @AuraEnabled
    public String oppStage{get;set;}

    /** @description contact method name */
    @AuraEnabled
    public String contactMethodName{get;set;}
    
    /** @description interaction end time */
    @AuraEnabled
    public DateTime interactionEndTime{get;set;}
    
    /** @description interaction start time */
    @AuraEnabled
    public DateTime interactionStartTime{get;set;}
    
    /** @description enterprise interaction identifier */
    @AuraEnabled
    public String enterpriseInteractionIdent{get;set;}

    /** @description enterprise interaction name for interaction */
    @AuraEnabled
    public String name{get;set;}
    
    /** @description completed date time of activity */
    @AuraEnabled
    public DateTime completedDateTime{get;set;} 
        
    /** @description display date in a user local format */
    @AuraEnabled
    public String displayDateUserLocalString {
        get {
            return this.displayDate != null ? this.displayDate.format(DATE_FORMAT) : null;
        }
    }

    /** @description Flag used to help control menu item display for nested section item logs */
    @AuraEnabled
    public Boolean isLogRecord{get;set;}

    /** @description Id of User who created log/task */
    @AuraEnabled
    public string createdById {get;set;}
}