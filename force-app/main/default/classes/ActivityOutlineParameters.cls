/**
 * @description Common class used to pass parameters activity outline ui to apex controllers
 */
public with sharing class ActivityOutlineParameters {
    /** @description parent record id */
	@AuraEnabled
    public String parentRecordId{get;set;}

    /** @description parent SObject name */
    @AuraEnabled
    public String parentSObjectName{get;set;}

    /** @description request type (init, past, upcoming, viewAll) */
    @AuraEnabled
    public String requestType{get;set;}

    /** @description account record type */
    @AuraEnabled
    public String accountRecordType{get;set;}

    /** @description task record type */
    @AuraEnabled
    public String taskRecordType{get;set;}

    /** @description current offset */
    @AuraEnabled 
    public Integer currentOffset{get; set;}

    /** @description past offset */
    @AuraEnabled 
    public Integer pastOffset{get; set;}

    /** @description selected object filter */
    @AuraEnabled
    public List<String> selectedObjectFilter{get; set;}

    /** @description newly requested objects */
    @AuraEnabled
    public List<String> newlyRequestedObjects{get; set;}
}