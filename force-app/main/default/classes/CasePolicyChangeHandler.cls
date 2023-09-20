/** 
* @description handle Policy changes cases
* @Owner: CATS
*/
public with sharing class CasePolicyChangeHandler {
	
    /**
     * @description : Handles Policy CHange Case insert and updates
     * @param policyChangeCases 
     * @param oldCaseMap
     */
    
   public static void handlePolicyChangeCases(List<Case> policyChangeCases, Map<Id,Case> oldCaseMap){
        processPolicyChangeCases(policyChangeCases, oldCaseMap);
    }
    
    @TestVisible private static void processPolicyChangeCases(List<Case> policyChangeCases, Map<Id,Case> oldCaseMap){
        
		for(Case caseRecord : policyChangeCases){
            if(CaseBeforeTriggerHandler.isInsert){
                handlePolicyChangeBeforeInsertRecord(caseRecord);     
            } 
        }        
    }
    
     @TestVisible private static void handlePolicyChangeBeforeInsertRecord(Case caseRecord){
        CaseHandler.setAssignedToOnCase(caseRecord, null);        
    }
    
}