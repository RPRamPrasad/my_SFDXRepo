/**
 * @description handle case after trigger operations
 * @Owner CATs
 */ 
public with sharing class CaseAfterTriggerHandler {

    @TestVisible public static boolean bypassCaseDelete = false;
    /**
     * @description handleAfterInsert
     * @param newCaseList 
     */
    public static void handleAfterInsert(List<Case> newCaseList){
        CaseChangeOfAddressProcessor processor = new CaseChangeOfAddressProcessor();
        processor.createCOATasks(newCaseList);
        if(!CaseHandlerUtility.userHasPrevalidatedData()){
            handleNonValidatedInserts(newCaseList);
        }
        CaseHandler.setCaseShare(newCaseList);
    }
    
    
    private static void handleNonValidatedInserts(List<Case> newCaseList){
    	CaseHandler.setCaseOwnerToProxy(newCaseList, true);
    }
    /**
     * @description handleAfterUpdate
     * @param newCaseList 
     * @param oldCaseMap 
     */
    public static void handleAfterUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        if(CaseBeforeTriggerHandler.isInsert){
            CaseBeforeTriggerHandler.isInsert = false;
            return;
        }
        
        List<Case> caseOwnerUpdateList = new List<Case>();
        for(Case caseRecord : newCaseList){
            Case oldCase = oldCaseMap.get(caseRecord.Id);
            if(CaseHandlerUtility.caseOwnerWasChanged(caseRecord, oldCase)){
                caseOwnerUpdateList.add(caseRecord);
            }
        }
        CaseHandler.setCaseShare(caseOwnerUpdateList);
    }    
     /**
      * @description handleAfterDelete
      * @param oldCaseList 
      */
    public static void handleAfterDelete(List<Case> oldCaseList){
        if(!bypassCaseDelete){
            handleDeleteValidation(oldCaseList);
        }
    }
    

    private static void handleDeleteValidation(List<Case> oldCaseList){
        List<Case> nonMergeCases = new List<Case>();
        List<Case> mergedCases = new List<Case>();
        CaseMergingRules mergeRules = new CaseMergingRules();

        for(Case caseRecord : oldCaseList){
            if(caserecord.MasterRecordId != null 
               || (Test.isRunningTest() && caseRecord.Status == 'Merged')){
                mergedCases.add(caseRecord);
            }else{
                nonMergeCases.add(caseRecord);
            }
        }

        if(!mergedCases.isEmpty()){
            mergeRules.handleMerges(mergedCases);
        }

        if(!nonMergeCases.isEmpty()){
            AP_DeleteRecordHandler.handleDeletion(nonMergeCases);
        }
    }
}