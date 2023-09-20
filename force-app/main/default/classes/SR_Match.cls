/**
 * @description Service Request Matching is to eliminate duplicates
 * @Owner CATs
 */
public without sharing class SR_Match {
    
    @TestVisible private Map<String, SR_Payload> queueablePayloadsMap = new Map<String, SR_Payload>();
    @TestVisible private Map<String, SR_Payload> clientToPayloadMap = new Map<String, SR_Payload>();
    @TestVisible private Id recordTypeId;
    @TestVisible private String recordTypeName;
    @TestVisible private Map<SR_Key, Object> srMap = new Map<SR_Key, Object>();
    @TestVisible private List<Account> accounts = new List<Account>();
    @TestVisible private List<SR_Payload> invalidClientIdPayloads = new List<SR_Payload>();
    @TestVisible private Set<String> accountsClientIdSet = new Set<String>();
    SR_MatchProcessor matchProcessor = new SR_MatchProcessor();
    ApexValidation validator = new ApexValidation();
    @TestVisible private Integer caseQueryLimit = 15;
    @TestVisible private Integer acctQueryLimit = 1250;
    @TestVisible private Integer dayRange = 30;
    @TestVisible private Date caseCreatedDateRange = (Date.today() - dayRange);
    private Set<Id> tier1CaseIds = new Set<Id>();
    /**
     * @description SR_Match
     * @param srMap 
     */
    public SR_Match(Map<SR_Key, Object> srMap){
        this.srMap = srMap;
        this.clientToPayloadMap = (Map<String, SR_Payload>)this.srMap.get(SR_Key.CLIENT_TO_PAYLOAD_MAP);
        this.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get((String)this.srMap.get(SR_Key.RECORD_TYPE_NAME)).getRecordTypeId();
        this.recordTypeName = (String)this.srMap.get(SR_Key.RECORD_TYPE_NAME);
        this.tier1CaseIds = (this.srMap.containsKey(SR_Key.TIER_1_CASE_IDS)) ? (Set<Id>)this.srMap.get(SR_Key.TIER_1_CASE_IDS) : new Set<Id>();
    }
    /**
     * @description getMatchResults
     * @return  `Map<SR_Key, Object>`
     */
    public Map<SR_Key, Object> getMatchResults(){
        getAccountCases();
        handleAccountCases();
        setupResultMap();
        return this.srMap;
    }

    @TestVisible
    private void getAccountCases(){
        setupMatchVariables();
        this.accounts = Security.stripInaccessible(AccessType.READABLE, 
                                                               [SELECT ClientIdentifier__c, Name, PersonContactId,
                                                                (SELECT Id, Subject, LastModifiedDate, Status, Policy_Identifier__c, ProductDescription__c, Vehicle_Identifier__c, Automated_System_Events__c, Event_Id__c,
                                                                 Account.PersonContactId, OwnerId, Owner_User_External_Id__c, ContactId, RecordTypeId, LOB__c, isClosed, ClosedDate, Follow_Up_Date__c 
                                                                 FROM Cases 
                                                                 WHERE ((RecordTypeId =: this.recordTypeId 
                                                                 AND MasterRecordId = null 
                                                                 AND CreatedDate >=: this.caseCreatedDateRange) OR (Id In: this.tier1CaseIds))  
                                                                 ORDER BY LastModifiedDate DESC 
                                                                 LIMIT: this.caseQueryLimit)
                                                                FROM Account 
                                                                WHERE ClientIdentifier__c In: this.clientToPayloadMap.keySet() 
                                                                LIMIT: this.acctQueryLimit]).getRecords();
        
        if(this.accounts.isEmpty()){
            Map<String, SR_Payload> originalPayloadsMap = (Map<String, SR_Payload>)this.srMap.get(SR_Key.ORIGINAL_PAYLOADS_MAP);
            throw new SR_Exception(SR_Exception.EXCEPTION_MESSAGE_NO_ACCOUNTS_FOUND, originalPayloadsMap.values());
        }
    }
    
    @TestVisible
    private void handleAccountCases(){
        for(Account acct : this.accounts){
            this.accountsClientIdSet.add(acct.ClientIdentifier__c);
            if(acct.Cases.isEmpty()){
                SR_Payload clientPayload = this.clientToPayloadMap.get(acct.ClientIdentifier__c);
                matchProcessor.handleNoMatch(clientPayload, acct);
            }else{
                getMatch(acct);
            }
        }

        if(this.accountsClientIdSet.size() != this.clientToPayloadMap.size()){
            sortInvalidClientIdPayloads();
        }
    }
    
    @TestVisible
    private void getMatch(Account acct){
        SR_Payload payload = this.clientToPayloadMap.get(acct.ClientIdentifier__c);
        SR_MatchingRules rules = new SR_MatchingRules(payload, acct.cases);
        Case matchingCase = rules.handleMatching();
        if(matchingCase == null){
            matchProcessor.handleNoMatch(payload, acct);
        }else{            
            matchProcessor.handleMatch(payload, matchingCase);              
        }
    }

    @TestVisible
    private void sortInvalidClientIdPayloads(){
        for(String eventClientId : this.clientToPayloadMap.keySet()){
            if(!this.accountsClientIdSet.contains(eventClientId)){
                this.invalidClientIdPayloads.add(this.clientToPayloadMap.get(eventClientId));
            }
        }
    }
    
    @TestVisible
    private void setupResultMap(){
        if(validator.isValidObject(matchProcessor.caseMap)){
            this.srMap.put(SR_Key.CASE_MAP, matchProcessor.caseMap);
        }
        if(validator.isValidObject(matchProcessor.taskMap)){
            this.srMap.put(SR_Key.TASK_MAP, matchProcessor.taskMap);
        }
        if(!this.queueablePayloadsMap.isEmpty()){
            setQueueableMap(this.queueablePayloadsMap);
        }
        if(validator.isValidObject(matchProcessor.queueablePayloadsMap)){
            setQueueableMap(matchProcessor.queueablePayloadsMap);
        }
        if(!this.invalidClientIdPayloads.isEmpty()){
            this.srMap.put(SR_Key.INVALID_CLIENT_ID_PAYLOADS, this.invalidClientIdPayloads);
        }
    }
    
    @TestVisible
    private void setQueueableMap(Map<String, SR_Payload> payloadsMap){
        Map<String, SR_Payload> queueableMap = (this.srMap.containsKey(SR_Key.QUEUEABLE_PAYLOADS_MAP)) ? (Map<String, SR_Payload>)this.srMap.get(SR_Key.QUEUEABLE_PAYLOADS_MAP) : new Map<String, SR_Payload>();
        queueableMap.putAll(payloadsMap);
        this.srMap.put(SR_Key.QUEUEABLE_PAYLOADS_MAP, queueableMap);
    }

    @TestVisible
    private void setupMatchVariables(){
        CS_SR_Matching_Config__c matchConfig = CS_SR_Matching_Config__c.getValues(this.recordTypeName);
        this.caseQueryLimit = (matchConfig != null && matchConfig.Inner_Case_Query_Limit__c != null) ? Integer.valueOf(matchConfig.Inner_Case_Query_Limit__c) : this.caseQueryLimit;
        this.acctQueryLimit = (matchConfig != null && matchConfig.Account_Query_Limit__c != null) ? Integer.valueOf(matchConfig.Account_Query_Limit__c) : this.acctQueryLimit;
        this.dayRange = (matchConfig != null && matchConfig.Case_Created_Day_Range__c != null) ? Integer.valueOf(matchConfig.Case_Created_Day_Range__c) : this.dayRange;
        this.caseCreatedDateRange = (Date.today() - this.dayRange);
    }    
}