/** 
 * @description handle case trigger operations
 * @Owner CATs
 */ 
public with sharing class CaseBeforeTriggerHandler {
    
    @TestVisible public static boolean isInsert = false;
    @TestVisible private static boolean mockUserData = false;
    private static boolean isPrevalidatedUser;
    /**
     * @description handleBeforeInsert 
     * @param newCaseList 
     * @param oldCaseMap 
     */
    public static void handleBeforeInsert(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        isInsert = true;
        userHasPrevalidatedData();
        
        if(isPrevalidatedUser){
            handleValidatedInserts(newCaseList, oldCaseMap);
        }else{
            handleNonValidatedInserts(newCaseList, oldCaseMap);
        }
    }
    
    private static void handleNonValidatedInserts(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        CaseHandler.handleSPI(newCaseList);
        for(Case caseRecord : newCaseList){
            CaseHandler.keepCaseOwnerFieldsInSync(caseRecord); 
        }
        CaseRecordTypeSortingUtility.handleRecordTypeSorting(newCaseList, oldCaseMap); 
    }
    
    private static void handleValidatedInserts(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case caseRecord : newCaseList){
            CaseHandler.keepCaseOwnerFieldsInSync(caseRecord); 
        }
    }
    /**
     * @description handleBeforeUpdate
     * @param newCaseList 
     * @param oldCaseMap 
     */
    public static void handleBeforeUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        userHasPrevalidatedData();
            
        if(isPrevalidatedUser){
            handleValidatedUpdates(newCaseList, oldCaseMap);
        }else{
            handleNonValidatedUpdates(newCaseList, oldCaseMap);
        }
    }
    
    
    private static void handleNonValidatedUpdates(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        List<Case> spiCheckList = new List<Case>();
        List<Case> closedCaseList = new List<Case>();
        Set<Id> closedCaseIdSet = new Set<Id>();
        for(Case caseRecord : newCaseList){
            Case oldCase = oldCaseMap.get(caseRecord.Id);
            handleBeforeUpdatesForAllCases(caseRecord,oldCase);
            if(!isInsert){    
            	spiCheckList = CaseHandler.getCasesForSPICheck(caseRecord, oldCase); 
                if(caseRecord.Status == CaseHandlerConstants.CASE_STATUS_CLOSED){
                    closedCaseList.add(caseRecord);  
                    closedCaseIdSet.add(caseRecord.Id);
                }
                handleEscalation(caseRecord);
          	}
        }
        
        if(!spiCheckList.isEmpty()){
           CaseHandler.handleSPI(spiCheckList); 
        }  
        if(!isInsert){
            CaseRecordTypeSortingUtility.handleRecordTypeSorting(newCaseList, oldCaseMap); 
            if(!closedCaseList.isEmpty()){
              CaseHandler.handleCaseClosure(closedCaseList, closedCaseIdSet);   
            }
        	
        }  
    }
    
    private static void handleValidatedUpdates(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case caseRecord : newCaseList){
            Case oldCase = oldCaseMap.get(caseRecord.Id);
            handleBeforeUpdatesForAllCases(caseRecord,oldCase);
        }    
    }

    private static void handleBeforeUpdatesForAllCases(Case caseRecord, Case oldCase){
        CaseHandler.keepCaseOwnerFieldsInSync(caseRecord, oldCase);
        CaseStatusHandler.handleCaseStatusChange(caseRecord, oldCase);
        CaseSnoozeHandler.handleSnoozeUpdates(caseRecord, oldCase, isPrevalidatedUser);
    }
    
    
    @TestVisible
    private static void handleEscalation(Case caseRecord){
        if(isNotValidForEscalation(caseRecord)){
            caseRecord.isEscalated = false;
        }
    }

    private static boolean isNotValidForEscalation(Case caseRecord){
        CasePermissionUtil permUtil = new CasePermissionUtil();
        return ((caseRecord.IsEscalated && caseRecord.RecordTypeId != CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE) && permUtil.isCaseEscalationUser());
    }
    
    private static boolean userHasPrevalidatedData(){
        if(UnitTestDataUtility.isUnitTest && Test.isRunningTest()){
            isPrevalidatedUser = mockUserData;
        }else{
            isPrevalidatedUser = CaseHandlerUtility.userHasPrevalidatedData();
        }
        return isPrevalidatedUser;
    }

}