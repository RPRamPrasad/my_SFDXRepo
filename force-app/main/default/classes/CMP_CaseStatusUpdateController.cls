/**
* @Name: CMP_CaseStatusUpdateController
* @Author: Bisdona
* @description Custom Case Path Status Update Controller
*
* History:
* --------
* Bisdona		06/12/2019:		Removed the logic to update Assigned To and put it in AP_CaseBeforeUpdate Class, as this is only for status update.
*
*/

public with sharing class CMP_CaseStatusUpdateController {
    
    private static final Integer QUERY_LIMIT = 1;
    private static final String CASE_NOT_ASSIGNED_ERROR = 'Case must be assigned before moving to Pending.';
    private static final String CLASS_NAME = 'CMP_CaseStatusUpdateController';
    private static final String FAILURE_RECORD= 'Failure record: ';
    public static Boolean nullId = false;
    /**
     * @description updateStage
     * @param recordId 
     * @param desiredStage 
     * @return  `String`
     */
    @AuraEnabled
    public static String updateStage(String recordId, String desiredStage) {     
        String  errorString = '';
        Case caseToUpdate = new Case(Id=recordId);
        
        if ('Pending'.equalsIgnoreCase(desiredStage) && !isAssigned(recordId)) {
            errorString = CASE_NOT_ASSIGNED_ERROR;
        } else {
            errorString = updateStatus(caseToUpdate, desiredStage); 
        }
        return errorString;       
    }
    /**
     * @description fetchOpenActivitiesForCase
     * @param recordId 
     * @param isOwnerProxyofCurrentUser 
     * @return  `boolean`
     */
    @AuraEnabled
    public static boolean fetchOpenActivitiesForCase(String recordId, Boolean isOwnerProxyofCurrentUser) {
        if(FeatureManagement.checkPermission('Agency_User') && !isOwnerProxyofCurrentUser){
            AuraHandledException e = new AuraHandledException('insufficient access rights on object id');
            throw e;
        }
        
        List<Task> taskRecords = new List<Task>();
        String methodName = 'fetchOpenActivitiesForCase';
        try {
            taskRecords = Security.stripInaccessible(AccessType.READABLE, [Select Id, WhatId, Status FROM Task WHERE WhatId =: recordId AND (Status = 'In Progress' OR Status = 'Not Started') WITH SECURITY_ENFORCED]).getRecords();
        } catch (Exception e) {
            e.setMessage(FAILURE_RECORD + recordId + ', ' + e.getMessage());
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        return !taskRecords.isEmpty();
    }
    
    private static String updateStatus(Case c, String newStatus) {
        c.status = newStatus;
        String methodName = 'updateStatus';
        List<Case> caseList = new List<Case>();
        caseList.add(c);     
        try{
             update Security.stripInaccessible(AccessType.UPDATABLE, caseList, true).getRecords();
        } catch (DmlException updateException){
            updateException.setMessage(FAILURE_RECORD + c.Id + ', ' + updateException.getMessage());
            LoggingService.logHandledException(updateException, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            return updateException.getDmlMessage(0);
        } catch (Exception e) {
            e.setMessage(FAILURE_RECORD + c.Id + ', ' + e.getMessage());
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
        return '';
    }

    private static boolean isAssigned(String recordId){
        String methodName = 'isAssigned';

        List<Case> cases = new List<Case>();
        try{
            if(Test.isRunningTest() && nullId) {
                recordId = null; 
            }
            cases = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, Status, Assigned_To__c, CreatedDate FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT :QUERY_LIMIT]).getRecords();
            Case c = cases[0];
        	return c.Assigned_To__c != null;
        } catch (Exception ex) {
            ex.setMessage(FAILURE_RECORD + recordId + ', ' + ex.getMessage());
            LoggingService.logHandledException(ex, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            return false;
        }
    }
}