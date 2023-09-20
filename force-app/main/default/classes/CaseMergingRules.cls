/**
 * @description CaseMergingRules
 */
public with sharing class CaseMergingRules {
    
    @TestVisible private static final String ERROR_MERGE_BLOCK = 'You cannot update these cases because they have different Record types';
    private Map<Id, List<Case>> masterCaseMap = new Map<Id, List<Case>>();
    private List<Case> masterCases = new List<Case>();
    
    /**
     * @description handleMerges
     * @param cases 
     */
    public void handleMerges(List<Case> cases){
        setupMergingChecks(cases);
        getMasterCases();
        handleRules();
    }
    
    private void setupMergingChecks(List<Case> cases){
        for(Case caseRecord : cases){
            if(caseRecord.MasterRecordId != null){
                List<Case> losingCases = (this.masterCaseMap.containsKey(caseRecord.MasterRecordId)) ? this.masterCaseMap.get(caseRecord.MasterRecordId) : new List<Case>();
                losingCases.add(caseRecord);
                this.masterCaseMap.put(caseRecord.MasterRecordId, losingCases);
            } 
        }
    }
    
    private void getMasterCases(){
        this.masterCases = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, AccountId, RecordTypeId FROM Case WHERE Id In: this.masterCaseMap.keySet()]).getRecords();
    }
    
    private void handleRules(){
        if(!this.masterCases.isEmpty()){
            for(Case masterCase : this.masterCases){
                List<Case> losingCases = this.masterCaseMap.get(masterCase.Id);
                handleLosingCases(masterCase, losingCases);
            }
        }
    }
    
    private void handleLosingCases(Case masterCase, List<Case> losingCases){
        for(Case losingCase : losingCases){
            if(isNotMergeable(losingCase, masterCase)){
                losingCase.addError(ERROR_MERGE_BLOCK);
            }
        }
    }
    
    @TestVisible
    private boolean isNotMergeable(Case losingCase, Case masterCase){
        return (isRecordTypeDifferent(losingCase, masterCase));
    }
    
    @TestVisible
    private boolean isRecordTypeDifferent(Case losingCase, Case masterCase){
        return (losingCase.RecordTypeId != masterCase.RecordTypeId);
    }
    
}