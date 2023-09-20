/**
 * @description handle case trigger operations
 * @Owner CATs
 */
public with sharing class CaseHandler {

    @TestVisible private static List<Case> mockCases = new List<Case>();
    private static Set<Id> customerIdSet = new Set<Id>();
    private static Set<Id> objectOwnerIdSet = new Set<Id>();
    /**
     * @description setAssignedToOnCase
     * @param caseRecord 
     * @param status 
     */
    public static void setAssignedToOnCase(Case caseRecord, String status){ 
        if(!CaseHandlerUtility.caseReasonIsChangeOfAddress(caseRecord) && CaseHandlerUtility.assignedToIsWriteable(caseRecord)){
            caseRecord.Assigned_To__c = Userinfo.getUserId();
            if(status!=null || String.isNotBlank(status)){
              caseRecord.status = status;
            }
        }
    }  
    /**
     * @description keepCaseOwnerFieldsInSync
     * @param caseRecord 
     */
    public static void keepCaseOwnerFieldsInSync(Case caseRecord){   
        if(!CaseHandlerUtility.caseOwnerCustomFieldIsPopulated(caseRecord) && CaseHandlerUtility.caseOwnerSObjectTypeIsUser(caseRecord)){
            caseRecord.Case_Owner__c = caseRecord.OwnerId;
        }else if(CaseHandlerUtility.caseOwnerCustomFieldIsPopulated(caseRecord)){ 
         	caseRecord.OwnerId = caseRecord.Case_Owner__c;
        }
    }
    /**
     * @description keepCaseOwnerFieldsInSync
     * @param caseRecord 
     * @param oldCase 
     */
    public static void keepCaseOwnerFieldsInSync(Case caseRecord, Case oldCase){ 
        if(!CaseHandlerUtility.userIsAllowedToChangeOwner(oldCase) && (CaseHandlerUtility.caseOwnerCustomFieldChanged(caseRecord, oldCase) || CaseHandlerUtility.caseOwnerWasChanged(caseRecord, oldCase))){
        	caseRecord.addError(CaseHandlerConstants.CHANGE_OWNER_ERROR_MESSAGE.replace('{!sobject}', String.valueOf(Case.SObjectType).toLowerCase()));    
        }else if(CaseHandlerUtility.caseOwnerCustomFieldChanged(caseRecord, oldCase)){
            caseRecord.OwnerId = caseRecord.Case_Owner__c;
        }else if(CaseHandlerUtility.caseOwnerWasChanged(caseRecord, oldCase) && CaseHandlerUtility.caseOwnerSObjectTypeIsUser(caseRecord)){
            caseRecord.Case_Owner__c = caseRecord.OwnerId;      
        }else if(CaseHandlerUtility.caseOwnerWasChanged(caseRecord, oldCase)){
            caseRecord.Case_Owner__c = null;
        } 
    }
    /**
     * @description checkAgentRoleForCaseOwner
     * @param caseList 
     */
    public static void checkAgentRoleForCaseOwner(List<Case> caseList){ 
        for(Case caseRecord : caseList){
            setupAgentRoleCheck(caseRecord);
        }
        if(!customerIdSet.isEmpty() && !objectOwnerIdSet.isEmpty()){
            AgentRoleValidationUtility.checkAgentRoleForSObjectOwner(caseList,customerIdSet,objectOwnerIdSet);
        }      
    }
	
   @TestVisible private static void setupAgentRoleCheck(Case caseRecord){
        objectOwnerIdSet.add(caseRecord.Case_Owner__c);
        if(caseRecord.AccountId != null){ 
            customerIdSet.add(caseRecord.AccountId);
        }else if(caseRecord.ContactId != null){
            customerIdSet.add(caseRecord.ContactId);
        }
    }
    /**
     * @description handleSPI
     * @param newCaseList 
     */
    public static void handleSPI(List<Case> newCaseList){ 
        if(!newCaseList.isEmpty()){
            AP_SPISecurityManager spiSecurity = new AP_SPISecurityManager();
       		spiSecurity.handle(newCaseList);  
        }
    }
    /**
     * @description handleCaseClosure
     * @param closedCaseList 
     * @param closedCaseIdSet 
     */
    public static void handleCaseClosure (List<Case> closedCaseList, Set<Id> closedCaseIdSet) { 
        Set<Id> caseIdsWithOpenTasks = getCaseIdsAndAssociateTasks(closedCaseIdSet);
        for(Case caseRecord : closedCaseList){
            if(caseIdsWithOpenTasks.contains(caseRecord.Id)){
                caseRecord.addError(System.label.CL_CASE_CLOSE_ERROR_MESSAGE); 
            } 
        }
    }
    /**
     * @description setCaseShare
     * @param newCaseList 
     */
    public static void setCaseShare(List<Case> newCaseList){ //Covered By CaseTriggerTest
        if(!newCaseList.isEmpty()){
            AP_createCaseShare.createAppropriateCaseShare(newCaseList);
        }
    }
    /**
     * @description setCaseOwnerToProxy
     * @param newCaseList 
     * @param afterTrigger 
     */
    public static void setCaseOwnerToProxy(List<Case> newCaseList, boolean afterTrigger) { //Covered By CaseTriggerTest
        if(!newCaseList.isEmpty() && !CaseHandlerUtility.userHasPrevalidatedData()){
            SObjectOwnershipUtility.setObjectOwnerToProxy(newCaseList, afterTrigger);
        }
    }
    /**
     * @description handleCaseOwnerChange
     * @param newCaseList 
     * @param oldCaseMap 
     */
    public static void handleCaseOwnerChange(List<Case> newCaseList, Map<Id,Case> oldCaseMap){ //Covered By CaseTriggerTest
        List<Case> casesWithOwnerChange = getCasesWithOwnerChange(newCaseList, oldCaseMap);
        completeCaseOwnerChange(casesWithOwnerChange);    
    }
    
    @TestVisible private static List<Case> getCasesWithOwnerChange(List<Case> newCaseList, Map<Id,Case> oldCaseMap){
        List<Case> casesWithOwnerChange = new List<Case>();
        for(Case caseRecord : newCaseList){
            Case oldCase = oldCaseMap.get(caseRecord.Id);
            if(oldCase != null){
                casesWithOwnerChange = processOwnerChange(caseRecord, oldCase, casesWithOwnerChange);
            }     
        }
        return casesWithOwnerChange;
    }
    
    @TestVisible private static List<Case> processOwnerChange(Case caseRecord, Case oldCase, List<Case> casesWithOwnerChange){
        if(CaseHandlerUtility.caseOwnerWasChanged(caseRecord, oldCase) && CaseHandlerUtility.caseOwnerSObjectTypeIsUser(caseRecord)){
            caseRecord.Assigned_To__c = null;//Blank Assigned To if the Office is changed
            casesWithOwnerChange.add(caseRecord); //Check Agent Role if the new owner is a user and not a queue
        }else if(CaseHandlerUtility.caseOwnerWasChanged(caseRecord, oldCase)){
            caseRecord.Assigned_To__c = null;//Blank Assigned To if the Office is changed 
        }
        return casesWithOwnerChange;
    }
    
    @TestVisible private static void completeCaseOwnerChange(List<Case> casesWithOwnerChange){
        if(!casesWithOwnerChange.isEmpty() && CaseHandlerUtility.userRequiresAgentRoleCheck()){
            checkAgentRoleForCaseOwner(casesWithOwnerChange);    
            setCaseOwnerToProxy(casesWithOwnerChange, false);
            updateCaseOwnerCustomField(casesWithOwnerChange);
        }else if(!casesWithOwnerChange.isEmpty() && !CaseHandlerUtility.userHasPrevalidatedData()){
            setCaseOwnerToProxy(casesWithOwnerChange, false);
            updateCaseOwnerCustomField(casesWithOwnerChange);
        }else if(CaseHandlerUtility.userHasPrevalidatedData()){
            updateCaseOwnerCustomField(casesWithOwnerChange);
        } 
    }
    /**
     * @description setOwnerToQueue
     * @param caseRecord 
     * @param queueId 
     */
    public static void setOwnerToQueue(Case caseRecord, Id queueId){
        caseRecord.OwnerId = queueId;
        caseRecord.Case_Owner__c = null;
    }
    /**
     * @description changeRecordTypeToCustomerServiceRequest
     * @param caseRecord 
     */
    public static void changeRecordTypeToCustomerServiceRequest(Case caseRecord){
        caseRecord.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST;
    }
    /**
     * @description getCasesForSPICheck
     * @param caseRecord 
     * @param oldCase 
     * @return  `List<Case>`
     */
    public static List<Case> getCasesForSPICheck(Case caseRecord, Case oldCase){
        List<Case> spiCheckList = new List<Case>();
        if(CaseHandlerUtility.skipSPICheck(caseRecord, oldCase)){
        	caseRecord.SkipSPIBeforeUpdateTrigger__c = false;
        }else{
            spiCheckList.add(caseRecord);
        }        
        return spiCheckList;
    }

    @TestVisible private static Set<Id> getCaseIdsAndAssociateTasks (Set<Id> closedCaseIdSet) { //Get a list of Cases and their assoicated tasks...Note: will return rows even if there are no open tasks
        List<Case> casesWithOpenTasks = Security.stripInaccessible(AccessType.READABLE,
                                                                   [SELECT Id, (SELECT Status,IsClosed,IsRecurrence FROM Tasks WHERE IsRecurrence = false AND IsClosed = false LIMIT 1) FROM Case WHERE Id IN : closedCaseIdSet]).getRecords();
        if (Test.isRunningTest() && !mockCases.isEmpty() && UnitTestDataUtility.isUnitTest) {
            casesWithOpenTasks = mockCases;
        }
        return getCaseIdsWithTasks(casesWithOpenTasks);  
    }
    
    @TestVisible private static Set<Id> getCaseIdsWithTasks(List<Case> casesWithOpenTasks){
        Set<Id> caseIdsWithTasksSet = new Set<Id>();
        for(Case caseRecord : casesWithOpenTasks){
            if (!caseRecord.tasks.isEmpty()){
                caseIdsWithTasksSet.add(caseRecord.Id);
            }
        }
        return caseIdsWithTasksSet;
    }
    
    @TestVisible
    private static void updateCaseOwnerCustomField(List<Case> newCaseList){
        for(Case caseRecord : newCaseList){
            caseRecord.Case_Owner__c = caseRecord.OwnerId;
        } 
    }
    
   
}