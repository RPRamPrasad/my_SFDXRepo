/** 
@Author Team AKITA
@Name LWC_NewOppTaskCreateFlow
@CreateDate 12/04/2020  
@description This class is used to update Opportunity and Create Task.
@Version 1.2
Copyright © StateFarm  
Version     Author      Date                           Description
1.1          Akita    06-25-2021     Updated saveTask Method, Added taskCreationFrmOpp() Method
1.2       Opptimizers 05-20-2022     Small performance updates
*/

public with sharing class LWC_NewOppTaskCreateFlow {
    
    public static final String TASK_TYPE_SALES = 'Sales';
    static final String CLASS_NAME = 'LWC_NewOppTaskCreateFlow';
    static final String SAVE_TASK_METHOD = 'saveTask';
    static final String SAVE_STAGE_METHOD = 'saveStage';
    static final String OPPORTUNITY_OBJECT_NAME = 'Opportunity';
    static final String TASK_OBJECT_NAME = 'Task';
    
    /**
* @description Method to update Opportunity and Create Task
* @param dataToBeSaved
* @return String
*/
    @AuraEnabled
    public static String saveTask(String dataToBeSaved) {
        ApexResponse response;
        try {
            String message = '';
            
            DataToSave data = (DataToSave)JSON.deserialize(dataToBeSaved, DataToSave.class);

            List<Opportunity> opp = Security.stripInaccessible(
                AccessType.READABLE,
                [Select Id, LOB__c, OwnerId, Account.PersonContactId, Assigned_To__c,StageName,Status__c,Sub_Status__c,OppTaskFromModalPopUp__c FROM Opportunity WHERE Id = :data.recordId]
            )
                .getRecords();
            
            if (!string.isEmpty(data.status) || !string.isEmpty(data.substatus)){
                opp[0].Status__c = data.status;
                opp[0].Sub_Status__c = data.subStatus;
                opp[0].Id = data.recordId;
                message = OPPORTUNITY_OBJECT_NAME;
            }
            
            
            message = taskCreationFrmOpp(data, opp, message);
            
            
            if((!String.isEmpty(data.subject) || !string.isEmpty(data.status) || !string.isEmpty(data.substatus)) && Schema.sObjectType.Opportunity.isCreateable()){
             Update Security.stripInaccessible(AccessType.UPDATABLE, Opp, true).getRecords();
            }
            
            response = new ApexResponse('Success',message + ' is saved Successfully');
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, SAVE_TASK_METHOD,System.LoggingLevel.ERROR);
            response = new ApexResponse('Error',getExceptionMessage(e));
        } 
        return JSON.serialize(response);
    }

    /**
* @description Method to create task from opportunity Pop Up Model
* @param data
* @param opp
* @param message
* @return String
*/
    private static String taskCreationFrmOpp(dataToSave data, List<Opportunity> opp, String message){
        String returnMessage = message;
        if(!String.isEmpty(data.subject)){
            TaskFactoryTask myFactory = new TaskFactoryTask();
            SObjectType objectType = data.recordId.getSObjectType();
            myFactory.setActivityDate((data.dueDate==null)?Date.Today().addDays(1):data.dueDate)
                .setSubject(data.subject)
                .setTaskType(TASK_TYPE_SALES)
                .setAppCode('SFDC UI - ' + objectType)
                .setOwnerId(opp[0].OwnerId)
                .setWhoId(opp[0].Account.PersonContactId)
                .setWhatId(data.recordId)
                .setLineOfBusiness(opp[0].LOB__c)
                .setAssignedTo(opp[0].Assigned_To__c)
                .setPriority('Low')
                .setStatus('Not Started');
            myFactory.createTask();
            
            if(String.isEmpty(message)) {
                returnMessage = TASK_OBJECT_NAME;
            }
            else {
                returnMessage = message + ' & ' + TASK_OBJECT_NAME;
            }
            
            opp[0].Id = data.recordId;
            if(opp[0].OppTaskFromModalPopUp__c == null){
                opp[0].OppTaskFromModalPopUp__c = 0;
            }
            opp[0].OppTaskFromModalPopUp__c += 1;
        } 
        return returnMessage;
        
    }
    
    /**
* @description Method to update the Opportunity
* @param recordId
* @param stageName
* @return String
*/
    @AuraEnabled
    public static String saveStage(Id recordId, String stageName) {
        ApexResponse response;
        try {
            List<Opportunity> updateOpp = new List<Opportunity>();
            Opportunity opp = new Opportunity();
            opp.StageName = stageName;
            opp.Id = recordId;
            opp.Status__c = '';
            opp.Sub_Status__c = '';
            updateOpp.add(opp);
            
            Update Security.stripInaccessible(AccessType.UPDATABLE, updateOpp, true).getRecords();
            response = new ApexResponse('Success','Success');
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, SAVE_STAGE_METHOD,System.LoggingLevel.ERROR);
            response = new ApexResponse('Error',getExceptionMessage(e));
        } 
        return JSON.serialize(response);
    }
    
     /**
* @description Method to check the login user access on Opportunity and Task
* @return Integer
*/
    @AuraEnabled(cacheable=true)
    public Static Integer isOppCreatableAndisTaskCreatable(){
        if (Schema.sObjectType.Opportunity.isCreateable()  && !Schema.sObjectType.Task.isCreateable()){
            return 1;
        }
        else if (!Schema.sObjectType.Opportunity.isCreateable()  && Schema.sObjectType.Task.isCreateable()){
            return 2;
        }
        else if (Schema.sObjectType.Opportunity.isCreateable() && Schema.sObjectType.Task.isCreateable()){
            return 3;
        }
        else{
            return -1;
        }
    }
    
    /**
* @description Helper class to pass the parameters
*/
    @TestVisible
    private with sharing class DataToSave {

        /**
         * @description recordId
         */
        public Id recordId{get;set;}

        /**
         * @description dueDate
         */
        public Date dueDate{get;set;}

        /**
         * @description subject
         */
        public String subject{get;set;}

        /**
         * @description status
         */
        public String status{get;set;}

        /**
         * @description subStatus
         */
        public String subStatus{get;set;}
    }
    
    /**
* @description Class to control the return response from saveOpp Method.
*/  
    private with sharing class ApexResponse {

        /**
         * @description status
         */
        public String status{get;set;}

        /**
         * @description message
         */
        public String message{get;set;}
        
        /**
         * @description ApexResponse
         * @param status 
         * @param message 
         */
        public ApexResponse(String status, String message) {
            this.status = status;
            this.message = message;
            
        } 
    }

    /**
     * @description Method to get the exception message
     * @param e
     * @return Exception Message
     */
    private static String getExceptionMessage(Exception e) {
        if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, This Opportunity has been returned for credit, and that request was granted. The Stage is no longer editable')) {
            return 'This Opportunity has been returned for credit, and that request was granted. The Stage is no longer editable';
        }
        else if(e.getMessage().contains('No access to entity: Opportunity')) {
            return 'No access to Opportunity';
        }
        else{
             return 'There was an error, please contact the normal support channel.';
        }
    }

}