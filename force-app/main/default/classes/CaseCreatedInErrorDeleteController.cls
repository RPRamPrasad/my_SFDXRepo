/**
 * @description CaseCreatedInErrorDeleteController
 */
public with sharing class CaseCreatedInErrorDeleteController {
    private static final String CLASS_NAME = 'CaseCreatedInErrorDeleteController';
    private static Case caseRelatedObj;
    /**
     * @description getRelatedRecords
     * @param recordId 
     * @return  `List<SObject>`
     */
    @AuraEnabled
    public static List<SObject> getRelatedRecords(Id recordId){
        List<SObject> relatedObjs = new List<SObject>();
        try{
            caseRelatedObj = [SELECT Id, AccountId, 
                                        (SELECT Id, isClosed FROM Tasks), 
                                        (SELECT Id, EndDateTime FROM Events), 
                                        (SELECT Id FROM Case_Notes__r) 
                                    FROM Case 
                                    WHERE Id = :recordId WITH SECURITY_ENFORCED];    
            relatedObjs.addAll(caseRelatedObj.Tasks);
            relatedObjs.addAll(caseRelatedObj.Events);
            relatedObjs.addAll(caseRelatedObj.Case_Notes__r);
            relatedObjs.add(caseRelatedObj);
        } catch(Exception ex){
            LoggingService.logHandledException(ex, CLASS_NAME, 'getRelatedRecords', System.LoggingLevel.ERROR);
        }
        return relatedObjs;
    }
    /**
     * @description deleteErrorCase
     * @param casesToDelete 
     */
    @AuraEnabled
    public static void deleteErrorCase(List<Case> casesToDelete){
        try{
            CaseAfterTriggerHandler.bypassCaseDelete = true;
            Database.delete(casesToDelete);
        } catch(Exception ex){
            LoggingService.logHandledException(ex, CLASS_NAME, 'deleteErrorCase', System.LoggingLevel.ERROR);
        }
    }
}