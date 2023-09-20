/**
 * @description Utility class for the SR_Rest flow
 * @Owner CATs
 */
public without sharing class SR_Util {
    /**
     * @description hasSupportingRecord
     * @param payload 
     * @return  `boolean`
     */
    public boolean hasSupportingRecord(SR_Payload payload){
        return (payload.taskRecord != null || payload.logRecord != null);
    }
    /**
     * @description hasDefaults
     * @param payload 
     * @return  `boolean`
     */
    @TestVisible
    public boolean hasDefaults(SR_Payload payload){
        return (payload.defaults != null && (payload.defaults.caseRecord != null || payload.defaults.taskRecord != null || payload.defaults.logRecord != null));
    }
    /**
     * @description getContact
     * @param clientId 
     * @return  `Contact`
     */
    @TestVisible
    public Contact getContact(String clientId){
        return new Contact(ClientIdentifier__c = clientId);
    }
    /**
     * @description getAccount
     * @param clientId 
     * @return  `Account`
     */
    @TestVisible
    public Account getAccount(String clientId){
        return new Account(ClientIdentifier__c = clientId);
    }
    /**
     * @description getOwner
     * @param userExternalId 
     * @return  `User`
     */
    @TestVisible
    public User getOwner(String userExternalId){
        return new User(UserExternalId__c = userExternalId);
    }
    /**
     * @description setUpLog
     * @param logRecord 
     * @return  `Task`
     */
    public Task setUpLog(Task logRecord){
        logRecord.CreatedClosed__c = true;
        logRecord.Log_Call__c = true;
        logRecord.Status = TaskHandlerConstants.TASK_STATUS_COMPLETED;
        logRecord.TaskSubtype = TaskHandlerConstants.TASK_SUBTYPE_CALL;
        logRecord.RecordTypeId = TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID;
        logRecord.ActivityDate = (logRecord.ActivityDate == null) ? Date.today() : logRecord.ActivityDate;
        if(String.isNotBlank(logRecord.Log_Title__c)){ //Should this check be subject populated?
            logRecord.Subject = (logRecord.Contact_Type__c == null) ? logRecord.Log_Title__c : logRecord.Contact_Type__c + ' : ' + logRecord.Log_Title__c;
        }
        return logRecord;
    }
    /**
     * @description buildExceptions
     * @param payload 
     * @param errorMessage 
     * @return  `Service_Request_Exception__c`
     */
    public Service_Request_Exception__c buildExceptions(SR_Payload payload, String errorMessage){
        Service_Request_Exception__c ex = new Service_Request_Exception__c();

        Integer maxTextLength = 255;
        if (errorMessage.length() > maxTextLength) {
            errorMessage = errorMessage.substring(0, maxTextLength);
        }
        ex.ErrorMessage__c = errorMessage;
        ex.Payload__c = JSON.serializePretty(payload, true);
        ex.SObject_Type__c = 'SR_Payload';
        ex.isSuccessfullyReplayed__c = false;
        ex.RecordTypeId = SR_Constants.EXCEPTION_RECORD_TYPE_AUTO_RETRY;
        ex.Event_Id__c = payload.eventId;
        return ex;
    }
    /**
     * @description buildExceptionsList
     * @param serviceRequestList 
     * @param errorMessage 
     * @return  `List<Service_Request_Exception__c>`
     */
    public List<Service_Request_Exception__c> buildExceptionsList(List<SR_Payload> serviceRequestList, String errorMessage){
        List<Service_Request_Exception__c> exList = new List<Service_Request_Exception__c>();
        for(SR_Payload serviceRequestRecord : serviceRequestList){
            Service_Request_Exception__c ex = buildExceptions(serviceRequestRecord, errorMessage);
            exList.add(ex);
        }
        return exList; 
    }
    /**
     * @description handleEventMatchTiers
     * @param payload 
     * @param caseList 
     * @return  `String`
     */
    public String handleEventMatchTiers(SR_Payload payload, List<Case> caseList) {
        String tierString = '';
        if(caseList.isEmpty()) {
        	tierString = SR_Constants.CASE_NO_CASES_FOUND;
        } else if(SR_MatchingRulesUtil.isTier1Payload(payload)) {
            tierString = SR_Constants.CASE_NO_MATCH_TIER_1;
        } else if(SR_MatchingRulesUtil.isTier2Payload(payload)) {
            tierString = SR_Constants.CASE_NO_MATCH_TIER_2;
        } else if(SR_MatchingRulesUtil.isMultiTierPayload(payload)) {
            tierString = SR_Constants.CASE_NO_MATCH_MULTI_TIER;
        } else if(SR_MatchingRulesUtil.isTier3Payload(payload)) {
            tierString = SR_Constants.CASE_NO_MATCH_TIER_3;
        } else if(SR_MatchingRulesUtil.isTier4Payload(payload)) {
            tierString = SR_Constants.CASE_NO_MATCH_TIER_4;
        } else {
            tierString = SR_Constants.CASE_NO_MATCH_TIER_5;
        }
        return tierString;
    }

}