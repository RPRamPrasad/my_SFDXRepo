/**
 * @description This is a base class.  It is used by ActivityOutlineSObjectWrapper to wrap different types of objects to be returned to activity outline
 */
public virtual with sharing class ActivityOutlineSObjectWrapperBase { 

    /** @description sObject record id */
    @AuraEnabled
    public String sobjectRecordId{get;set;}

    /** @description created date */
    @AuraEnabled
    public DateTime createdDate{get;set;}

    /** @description last modified date */
    @AuraEnabled
    public DateTime lastModifiedDate{get;set;}

    /** @description last modified by name */
    @AuraEnabled
    public String lastModifiedByName{get;set;}

    /** @description customer */
    @AuraEnabled
    public String customer{get;set;}

    /** @description customer name */
    @AuraEnabled
    public String customerName{get;set;}

    /** @description status */
    @AuraEnabled
    public String status{get;set;}

    /** @description record subject */
    @AuraEnabled
    public String recordSubject{get;set;}

    /** @description line of business */
    @AuraEnabled
    public String lob{get;set;}

    /** @description related to */
    @AuraEnabled
    public String relatedTo{get;set;}

    /** @description related to name */
    @AuraEnabled
    public String relatedToName{get;set;}

    /** @description sObject type */
    @AuraEnabled
    public String sobjectType{get;set;}

    /** @description description */
    @AuraEnabled
    public String description{get;set;}

    /** @description related assigned to name */
    @AuraEnabled
    public String assignedToName{get;set;} 

     /** @description display icon name */
    @AuraEnabled
    public String displayIconName{get;set;}

     /** @description is closed */
     @AuraEnabled
     public Boolean isClosed{get;set;}

     /** @description related tasks */
    @AuraEnabled
    public List<ActivityOutlineSObjectWrapper> relatedTasks{get;set;}

     /** @description related events */
    @AuraEnabled
    public List<ActivityOutlineSObjectWrapper> relatedEvents{get;set;}
    
    /** @description related opportunity notes */
    @AuraEnabled
    public List<ActivityOutlineSObjectWrapper> relatedOpportunityNotes{get;set;}

     /** @description related case notes */
     @AuraEnabled
     public List<ActivityOutlineSObjectWrapper> relatedCaseNotes{get;set;}

     /** @description related account notes */
     @AuraEnabled
     public List<ActivityOutlineSObjectWrapper> relatedAccountNotes{get;set;}

     /** @description related interaction summaries */
     @AuraEnabled
     public List<ActivityOutlineSObjectWrapper> relatedInteractionSummaries{get;set;}

     /** @description related virtual meetings */
     @AuraEnabled
     public List<ActivityOutlineSObjectWrapper> relatedVirtualMeetings{get;set;}

    /** @description display title */
    @AuraEnabled
    public String displayTitle {
       get {
           String title = '';
           if (this.recordSubject != null) {
               title =  this.assignedToName != null ? this.recordSubject + ' - Assigned To: ' + this.assignedToName : this.recordSubject + ' - Assigned To: ';
           }
           return title;
       }
   }
}