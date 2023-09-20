/**
 * @description Constants class for Service Request Flows
 * @Owner CATs
 */
public without sharing class SR_Constants {
    public static final String EXCEPTION_RECORD_TYPE_AUTO_RETRY = Schema.SObjectType.Service_Request_Exception__c.getRecordTypeInfosByDeveloperName().get('Auto_Retry').getRecordTypeId();
    public static final String EXCEPTION_RECORD_TYPE_MANUAL_RETRY = Schema.SObjectType.Service_Request_Exception__c.getRecordTypeInfosByDeveloperName().get('Manual_Retry').getRecordTypeId();
    
    public static final String SOBJECT_TYPE_CASE = 'Case';
    public static final String SOBJECT_TYPE_TASK = 'Task';
    public static final String SOBJECT_TYPE_SR_PAYLOAD = 'SR_Payload';
    
    //Case AppCode
    public static final String CASE_APP_CODE_AUTO_CHANGE_AND_SERVICE = 'Auto Change and Service';
    public static final String CASE_APP_CODE_AUTO_PVC = 'Auto - PVC';
    public static final String CASE_APP_CODE_FIRE_PVC = 'Fire - PVC';
    public static final String CASE_APP_CODE_LIFECYCLE = 'Lifecycle - PC';

    // Case Matching Tiers for Analytics
    public static final String CASE_NO_CASES_FOUND = 'No Cases Found - Create';
    public static final String CASE_NO_MATCH_TIER_1 = 'No Match Found - Tier 1';
    public static final String CASE_NO_MATCH_TIER_2 = 'No Match Found - Tier 2';
    public static final String CASE_NO_MATCH_TIER_3 = 'No Match Found - Tier 3';
    public static final String CASE_NO_MATCH_TIER_4 = 'No Match Found - Tier 4';
    public static final String CASE_NO_MATCH_TIER_5 = 'No Match Found - Tier 5';
    public static final String CASE_NO_MATCH_MULTI_TIER = 'No Match Found - Multi Tier';
    public static final String CASE_MATCH_TIER_1 = 'Match Found - Tier 1';
    public static final String CASE_MATCH_TIER_2 = 'Match Found - Tier 2';
    public static final String CASE_MATCH_TIER_3 = 'Match Found - Tier 3';
    public static final String CASE_MATCH_TIER_4 = 'Match Found - Tier 4';
    public static final String CASE_MATCH_TIER_5 = 'Match Found - Tier 5';
    public static final String CASE_MATCH_TIER_FINAL = 'Match Found - Final Match Attempt';
}