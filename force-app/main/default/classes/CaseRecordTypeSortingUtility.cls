/** 
* @description handle the sorting of case record types
* @Owner: CATS
*/
public with sharing class CaseRecordTypeSortingUtility {
    
    @TestVisible private static List<Case> customerServiceRequestCases = new List<Case>();
    @TestVisible private static List<Case> dataAccessRequestCases = new List<Case>();
    @TestVisible private static List<Case> retentionCases = new List<Case>();
    @TestVisible private static List<Case> policyChangeCases = new List<Case>();
    @TestVisible private static List<Case> ownerCheckCases = new List<Case>();
    @TestVisible private static List<Case> billingRequestCases = new List<Case>();
    /**
    * @description handleRecordTypeSorting
    * @param newCaseList 
    * @param oldCaseMap 
    */
    public static void handleRecordTypeSorting(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        resetClassLevelVariablesForTest();
       	for(Case caseRecord : newCaseList){
            if(CaseHandlerUtility.caseIsDoNotUseRecordType(caseRecord)){
               CaseHandler.changeRecordTypeToCustomerServiceRequest(caseRecord); //Switch any Invalid record types to a Customer Service Request
            }
            if(!CaseHandlerUtility.caseIsDataAccessRequest(caseRecord)){
                ownerCheckCases.add(caseRecord); // add cases for agent role check
            }
            sortingCaseType(caseRecord);
        }
        handleSortedCases(oldCaseMap);
        if(!CaseBeforeTriggerHandler.isInsert && !ownerCheckCases.isEmpty()) {
            CaseHandler.handleCaseOwnerChange(ownerCheckCases, oldCaseMap);
        }
    }
    
    @TestVisible private static void handleSortedCases(Map<Id, Case> oldCaseMap){
        if(!customerServiceRequestCases.isEmpty()){
            CaseCustomerServiceRequestHandler.handleCustomerServiceRequest(customerServiceRequestCases, oldCaseMap);
        }
        if(!dataAccessRequestCases.isEmpty()){
            CaseDataAccessRequestHandler.handleDataAccessRequest(dataAccessRequestCases, oldCaseMap);
        }
        if(!retentionCases.isEmpty()){
            CaseRetentionCaseHandler.handleRetentionCase(retentionCases, oldCaseMap);
        }
        if(!policyChangeCases.isEmpty()){
            CasePolicyChangeHandler.handlePolicyChangeCases(policyChangeCases, oldCaseMap);
        }
        if(!billingRequestCases.isEmpty() && CaseBeforeTriggerHandler.isInsert){
            CaseBillingRequestHandler.handleBillingRequestCases(billingRequestCases, oldCaseMap);
        }
    }
    
    @TestVisible private static void resetClassLevelVariablesForTest(){
        if(Test.isRunningTest() && !UnitTestDataUtility.isUnitTest){
            customerServiceRequestCases = new List<Case>();
            dataAccessRequestCases = new List<Case>();
            retentionCases = new List<Case>();
            policyChangeCases = new List<Case>();
            billingRequestCases = new List<Case>();
        }
    }
    /**
     * @description sortingCaseType
     * @param caseRecord 
     */
    public static void sortingCaseType(Case caseRecord){
        if(CaseHandlerUtility.caseIsCustomerServiceRequest(caseRecord)){//Customer Service Request
                customerServiceRequestCases.add(caseRecord);
            }else if(CaseHandlerUtility.caseIsDataAccessRequest(caseRecord)){//Data Access Request
                dataAccessRequestCases.add(caseRecord);
            }else if(CaseHandlerUtility.caseIsRetentionCase(caseRecord)){//Retention Case
                retentionCases.add(caseRecord);
            }else if(CaseHandlerUtility.caseIsPolicyChange(caseRecord)){//Policy Change
                policyChangeCases.add(caseRecord);
            }else if(CaseHandlerUtility.caseIsBillingRequest(caseRecord)){//Billing Requesst
                billingRequestCases.add(caseRecord);
            }
    }
}