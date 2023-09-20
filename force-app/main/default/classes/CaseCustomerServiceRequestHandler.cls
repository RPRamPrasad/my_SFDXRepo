/** 
* @description handle customer service requests 
* @Owner: CATS
*/
public with sharing class CaseCustomerServiceRequestHandler {

    @TestVisible private static List<Case> checkAgentRoleForCases = new List<Case>();
    /**
     * @description handleCustomerServiceRequest
     * @param customerServiceRequestCases 
     * @param oldCaseMap 
     */
    public static void handleCustomerServiceRequest(List<Case> customerServiceRequestCases, Map<Id, Case> oldCaseMap){
        checkAgentRoleForCases = new List<Case>();
        processCustomerServiceRequests(customerServiceRequestCases, oldCaseMap);
        processCustomerServiceRequestBeforeInserts();
    }
    
    @TestVisible private static void processCustomerServiceRequests(List<Case> customerServiceRequestCases, Map<Id, Case> oldCaseMap){
        for(Case caseRecord : customerServiceRequestCases){
            if(CaseBeforeTriggerHandler.isInsert){
                handleCustomerServiceRequestBeforeInsertRecord(caseRecord);     
            }else{
                handleCustomerServiceRequestBeforeUpdateRecord(caseRecord, oldCaseMap);
            }  
        }
    }

    @TestVisible private static void processCustomerServiceRequestBeforeInserts(){
        if(CaseBeforeTriggerHandler.isInsert && !checkAgentRoleForCases.isEmpty()){
            CaseHandler.checkAgentRoleForCaseOwner(checkAgentRoleForCases); //handle Agent Role Checks
        } 
    }
    
    @TestVisible private static void handleCustomerServiceRequestBeforeInsertRecord(Case caseRecord){
        CaseHandler.setAssignedToOnCase(caseRecord, CaseHandlerConstants.CASE_STATUS_PENDING);
        if(CaseHandlerUtility.userRequiresAgentRoleCheck()){ 
            checkAgentRoleForCases.add(caseRecord);
        }
    }
    
    @TestVisible private static void handleCustomerServiceRequestBeforeUpdateRecord(Case caseRecord, Map<Id, Case> oldCaseMap){
        Case oldCase = oldCaseMap.get(caseRecord.Id);
        CaseStatusHandler.handleDefaultStatusUpdates(caseRecord, oldCase);  // handle an update that impacts status
    }
    
    
}