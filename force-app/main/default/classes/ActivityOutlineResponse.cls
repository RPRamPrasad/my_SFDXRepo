/**
* @description ActivityOutlineResponse will provide required properties for ActivityOutline component filters & timeline.
*/
public with sharing class ActivityOutlineResponse {

    /** @description constructor of this class */
    public ActivityOutlineResponse(){
        this.sObjectFilterOptions = new List<ActivityOutlineTypeOption>();
        this.pastRecords = new List<ActivityOutlineSObjectWrapper>();
        this.currentRecords = new List<ActivityOutlineSObjectWrapper>();
        this.hasMoreCurrentRecords = false;
        this.userObjectPreference = new ActivityController.PreferenceItem();
    }

    /** @description user object preferences  */
    @AuraEnabled
    public ActivityController.PreferenceItem userObjectPreference {get; set;}
    
    /** @description sObject filter options */
    @AuraEnabled
    public List<ActivityOutlineTypeOption> sObjectFilterOptions{get;set;}

    /** @description list of past records */
    @AuraEnabled
    public List<ActivityOutlineSObjectWrapper> pastRecords{get;set;}

    /** @description list of current records */
    @AuraEnabled
    public List<ActivityOutlineSObjectWrapper> currentRecords{get;set;}

    /** @description boolean that indicates if there are more current records */
	@AuraEnabled
    public Boolean hasMoreCurrentRecords{get;set;}
}