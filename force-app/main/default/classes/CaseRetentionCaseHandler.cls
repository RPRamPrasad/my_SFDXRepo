/** 
* @description handle retention cases 
* @Owner: CATS
*/
public with sharing class CaseRetentionCaseHandler {
    /**
     * @description handleRetentionCase
     * @param retentionCases 
     * @param oldCaseMap 
     */
    public static void handleRetentionCase(List<Case> retentionCases, Map<Id,Case> oldCaseMap){
        processRetentionCases(retentionCases, oldCaseMap);
    }
    
    @TestVisible private static void processRetentionCases(List<Case> retentionCases, Map<Id,Case> oldCaseMap){
        for(Case caseRecord : retentionCases){
            if(CaseBeforeTriggerHandler.isInsert){
            	handleRententionCaseInsert(caseRecord);
            }else{
                Case oldCase = oldCaseMap.get(caseRecord.Id);
            	handleRententionCaseUpdate(caseRecord, oldCase); // handle an update that impacts status  
            }  
        }
    }
    
    @TestVisible private static void handleRententionCaseInsert(Case caseRecord){
        CaseHandler.setAssignedToOnCase(caseRecord, CaseHandlerConstants.CASE_STATUS_PENDING);
    }
    
    @TestVisible private static void handleRententionCaseUpdate(Case caseRecord, Case oldCase){
        CaseStatusHandler.handleDefaultStatusUpdates(caseRecord, oldCase); // handle an update that impacts status  
    }
    
}