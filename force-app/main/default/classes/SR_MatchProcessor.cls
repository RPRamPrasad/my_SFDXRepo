/**
 * @description Process Matching results from SR_Match
 * @Owner CATs
 */
public without sharing class SR_MatchProcessor {

    private static final String DEFAULT_CASE_SUBJECT = 'Policy Issued and Mailed';

    public Map<String, SR_Payload> queueablePayloadsMap = new Map<String, SR_Payload>();
    public Map<String, Case> caseMap = new Map<String, Case>();
    public Map<String, Task> taskMap = new Map<String, Task>();
    SR_Util utility = new SR_Util();
    /**
     * @description handleNoMatch
     * @param payload 
     * @param acct 
     */
    public void handleNoMatch(SR_Payload payload, Account acct){
        setUpRecordForInsert(payload, acct);
        setupTasks(payload, null);
        if(payload.taskRecord != null){
            this.taskMap.put(payload.eventId, payload.taskRecord);
        }
        if(payload.logRecord != null){
            this.taskMap.put(payload.eventId, payload.logRecord);
        }
    }
    /**
     * @description handleMatch
     * @param payload 
     * @param matchingCase 
     */
    public void handleMatch(SR_Payload payload, Case matchingCase){
        setupSObjectsForUpdate(payload, matchingCase);
        if(matchingCase.Event_Id__c != payload.eventId) {
            this.caseMap.put(payload.eventId, payload.caseRecord);   
        }
        if(payload.taskRecord != null){
            this.taskMap.put(payload.eventId, payload.taskRecord);
        }
        if(payload.logRecord != null){
            this.taskMap.put(payload.eventId, payload.logRecord);
        } 
    }
    
    @TestVisible
	private void setupSObjectsForUpdate(SR_Payload payload, Case matchingCase){
        payload.caseRecord.Id = matchingCase.Id; 
        payload.caseRecord.OwnerId = matchingCase.OwnerId;
        payload.caseRecord.Policy_Identifier__c = (payload.matchParams.policyId != null) ? payload.matchParams.policyId : matchingCase.Policy_Identifier__c;
        payload.caseRecord.Subject = matchingCase.Subject;
        payload.caseRecord.Tier_Matched__c = matchingCase.Tier_Matched__c;
        payload.caseRecord.Automated_System_Events__c = (matchingCase.Automated_System_Events__c != null) ? matchingCase.Automated_System_Events__c + 1 : 1;
        if(payload.caseRecord.Status == 'Closed' && matchingCase.Follow_Up_Date__c != null) {
            // add ternary for record type status check
            payload.caseRecord.Status = 'Enrollment_Case'.equals(payload.matchParams.recordTypeName) ? 'Setup' : 'Agent Review';
        }
        setupTasks(payload, matchingCase);
    }
    
    @TestVisible
    private void setupTasks(SR_Payload payload, Case matchingCase){
        if(payload.taskRecord != null){
           populateTaskFields(payload.taskRecord, matchingCase, false);
           setCaseFieldsFromTask(payload, matchingCase);
        }
        if(payload.logRecord != null){ 
           populateTaskFields(payload.logRecord, matchingCase, true);
        }
    }
    
    @TestVisible
    private void populateTaskFields(Task taskRecord, Case matchingCase, boolean isLog){
        if(isLog){
            taskRecord = utility.setUpLog(taskRecord);
        }
        if(matchingCase != null) {
            taskRecord.WhoId = matchingCase.ContactId;
            taskRecord.WhatId = matchingCase.Id; 
            taskRecord.OwnerID = matchingCase.ownerId;
        }
        taskRecord.ActivityDate = (taskRecord.ActivityDate == null) ? Date.today() : taskRecord.ActivityDate;
    }

    private void setCaseFieldsFromTask(SR_Payload payload, Case matchingCase){
        payload.caseRecord.isEscalated = true;
        if (matchingCase == null || matchingCase.Follow_up_Date__c == null || matchingCase.Follow_up_Date__c > payload.taskRecord.ActivityDate) {
            payload.caseRecord.Follow_up_Date__c = payload.taskRecord.ActivityDate;
        }

        //Populate Default Case fields in case default case was used for insert
        if(payload.defaults != null && payload.defaults.caseRecord != null){
            payload.defaults.caseRecord.isEscalated = true;
            payload.defaults.caseRecord.Follow_up_Date__c = payload.taskRecord.ActivityDate;
       }
    }

    private void setUpRecordForInsert(SR_Payload payload, Account acct){
        if(utility.hasDefaults(payload)){
            handleDefaults(payload, acct);
        } else {
            setupCaseForInsert(payload, acct);
            this.caseMap.put(payload.eventId, payload.caseRecord);
        }
    }

    private void handleDefaults(SR_Payload payload, Account acct){
        if(payload.defaults.taskRecord != null){
            payload.defaults.taskRecord.OwnerId = UserInfo.getUserId();
            payload.defaults.taskRecord.AssignedTo__r = utility.getOwner(payload.matchParams.ownerAssociateId);
            payload.defaults.taskRecord.WhoId = acct.PersonContactId;
            payload.defaults.taskRecord.WhatId = acct.Id;
            this.taskMap.put(payload.eventId, payload.defaults.taskRecord);
        }  
        if(payload.defaults.logRecord != null){
            payload.defaults.logRecord = utility.setUpLog(payload.defaults.logRecord);
            payload.defaults.logRecord.OwnerId = UserInfo.getUserId();
            payload.defaults.logRecord.AssignedTo__r = utility.getOwner(payload.matchParams.ownerAssociateId);
            payload.defaults.logRecord.WhoId = acct.PersonContactId;
            payload.defaults.logRecord.WhatId = acct.Id;
            this.taskMap.put(payload.eventId, payload.defaults.logRecord);
        }  
        if(payload.defaults.caseRecord != null){
            payload.defaults.caseRecord.Policy_Identifier__c = (payload.matchParams.policyId != null) ? payload.matchParams.policyId : null;
            payload.defaults.caseRecord.Vehicle_Identifier__c = (payload.matchParams.vehicleId != null) ? payload.matchParams.vehicleId : null;
            payload.defaults.caseRecord.Contact = (payload.matchParams.secondaryClientId != null) ? utility.getContact(payload.matchParams.secondaryClientId) : utility.getContact(payload.matchParams.clientId);  
            payload.defaults.caseRecord.Account = utility.getAccount(payload.matchParams.clientId);
            payload.defaults.caseRecord.Case_Owner__r = utility.getOwner(payload.matchParams.ownerAssociateId);
            payload.defaults.caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(payload.matchParams.recordTypeName).getRecordTypeId();
            payload.defaults.caseRecord.Tier_Matched__c = utility.handleEventMatchTiers(payload, acct.Cases);
            payload.defaults.caseRecord.Automated_System_Events__c = utility.hasSupportingRecord(payload) ? 0 : 1;
            this.caseMap.put(payload.eventId, payload.defaults.caseRecord);
        }
    }

    @TestVisible
    private void setupCaseForInsert(SR_Payload payload, Account acct){
        handleNoCaseRecord(payload);
        handleUpdateEvent(payload);
        payload.caseRecord.Policy_Identifier__c = (payload.matchParams.policyId != null) ? payload.matchParams.policyId : null;
        payload.caseRecord.Vehicle_Identifier__c = (payload.matchParams.vehicleId != null) ? payload.matchParams.vehicleId : null;
        payload.caseRecord.Contact = (payload.matchParams.secondaryClientId != null) ? utility.getContact(payload.matchParams.secondaryClientId) : utility.getContact(payload.matchParams.clientId); 
        payload.caseRecord.Account = utility.getAccount(payload.matchParams.clientId);
        payload.caseRecord.Case_Owner__r = utility.getOwner(payload.matchParams.ownerAssociateId);
        payload.caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(payload.matchParams.recordTypeName).getRecordTypeId();
        payload.caseRecord.Tier_Matched__c = utility.handleEventMatchTiers(payload, acct.Cases);
        payload.caseRecord.Automated_System_Events__c = utility.hasSupportingRecord(payload) ? 0 : 1;
    }

    @TestVisible
    private void handleNoCaseRecord(SR_Payload payload){
        if(payload.caseRecord == null){
            payload.caseRecord = new Case();  
        }
    }
    
    @TestVisible
    private void handleUpdateEvent(SR_Payload payload){
        if(utility.hasSupportingRecord(payload)){
            payload.caseRecord.Subject = (payload.logRecord != null) ? payload.logRecord.Subject : payload.taskRecord.Subject;
            payload.caseRecord.Description = (payload.logRecord != null) ? payload.logRecord.Description : payload.taskRecord.Description;
            payload.caseRecord.LOB__c = (payload.logRecord != null) ? payload.logRecord.LineofBusiness__c : payload.taskRecord.LineofBusiness__c;
        }else{
            payload.caseRecord.Subject = (payload.caseRecord.Subject == null) ? DEFAULT_CASE_SUBJECT : payload.caseRecord.Subject;
        }
    }
}