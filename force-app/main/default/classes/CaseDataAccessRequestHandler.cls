/** 
* @description handle data access request cases
* @Owner: CATS
*/
public with sharing class CaseDataAccessRequestHandler {

	/**
     * @description handleDataAccessRequest
     * @param dataAccessRequestCases 
     * @param oldCaseMap 
     */
    public static void handleDataAccessRequest(List<Case> dataAccessRequestCases, Map<Id,Case> oldCaseMap){
        processDataAccessRequests(dataAccessRequestCases, oldCaseMap);
    }
    
    @TestVisible private static void processDataAccessRequests(List<Case> dataAccessRequestCases, Map<Id,Case> oldCaseMap){
        for(Case caseRecord : dataAccessRequestCases){
            if(CaseBeforeTriggerHandler.isInsert){
                handleDataAccessRequestInsert(caseRecord);
            }else{
                handleDataAccessRequestUpdate(caseRecord);
            }   
        }
    }
    
    @TestVisible private static void handleDataAccessRequestInsert(Case caseRecord){
        if(caseRecord.OwnerId != CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID){
            CaseHandler.setOwnerToQueue(caseRecord, CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID);
        }
    }
    
    
    @TestVisible private static void handleDataAccessRequestUpdate(Case caseRecord){
        if(caseRecord.Status == CaseHandlerConstants.CASE_STATUS_CLOSED){
            CaseHandler.setOwnerToQueue(caseRecord, CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID);
        }
    }
}