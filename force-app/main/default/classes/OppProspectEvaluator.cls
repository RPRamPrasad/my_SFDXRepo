/**
 * @description This class has been developed as a controller for prospect evaluator aura component. 
 * This has been developed as a feature E-317322. The main purpose of this class is to update the data base field to true or false 
 * when the user click on Prospect Evaluator field that is on Highlights panel.
 */
public with sharing class OppProspectEvaluator {
    static final String CLASS_NAME = 'OppProspectEvaluator';
    static final String HIDEORSHOWDASHBOARD = 'hideOrShowDashBoard';
    
    /**
     * @description : This method queries Opportunity and updates its hasProspectEval__c value to true or false
     * @param oppId
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean updateEvalStatus(Id oppId){
        
        Opportunity queriedOppData = [SELECT hasProspectEval__c FROM Opportunity WHERE Id = :oppId WITH SECURITY_ENFORCED];
        Boolean oppUpdated = false; 
       
        Opportunity oppToUpdate = new Opportunity(); // the Opportunity of the parameter ID
        oppToUpdate.id = oppId;

        if(queriedOppData.hasProspectEval__c){
            oppToUpdate.hasProspectEval__c = false;
        }
        else {
            oppToUpdate.hasProspectEval__c = true;
        }
        
        try{
            update Security.stripInaccessible(AccessType.UPDATABLE, new List<Opportunity>{oppToUpdate}).getRecords(); 
            oppUpdated = true;
        }
        catch(Exception e){
            LoggingService.logHandledException(e, CLASS_NAME, HIDEORSHOWDASHBOARD,System.LoggingLevel.ERROR);
        }

       return oppUpdated;
    }
}
