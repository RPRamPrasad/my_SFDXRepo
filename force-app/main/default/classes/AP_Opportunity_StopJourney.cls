/**
 Name - AP_Opportunity_StopJourney
 @description Helper class used by Opportunity Stop Journey flow
                This class will delete Opportunity-Account messages with 'Scheduled' and update Opportunity-Journey Task Status as Cancelled
==========================================================================================================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Team TGV                4/03/2017             Initial Development
2.0             Team TGV                4/17/2017             Added Stop Journey logic to only delete Account message with Status 'Scheduled'
3.0             Team TGV                4/19/2017             Added new methods to bulk update opportunities when called from before and After Update Opportunity Triggers
4.0             Team TGV                5/01/2017             Defect fix #18574 for RFC Granted
5.0             Team TGV                5/08/2017             Added new logic for Stop Journey on Default Opportunity
6.0             Dream Builders          5/25/2017             Added new logic for Stop Journey on Retention_Stop Opportunity
7.0             Dream Builders          7/20/2017             Removed Logic for Stop Journey on Retention_Stop Opportunity
8.0             Dream Builders          10/11/2017            Add Stop Journey logic to Stage is closed won with cancel Account  meggages  
9.0             Trailblazers            10/26/2017            Added new logic for Stop Journey on Event Leads Opportunity
10.0            TrailBlazers            02/15/2018            Invoking AP_JourneyTracker to track STOP Journey actions on Opportunity   
11.0            QuadCore                04/1/2019             Removing logic to make record type changes on Opportunity
12.0            ClubCar                 02/18/2020            Updated PMD finding for CRUD violations
***************************************************************************************************************************************************************************/
public without Sharing Class AP_Opportunity_StopJourney {
    
    private static final String CLASS_NAME = 'AP_Opportunity_StopJourney';
    private static final String METHOD_NAME = 'oppStopJourney';
    private static final String SOBJECT_OPPORTUNITY = 'Opportunity';
    private static final String TASK_STATUS_CANCELLED  = 'Cancelled';
    private static final String ACCOUNTMESSAGE_STATUS_SCHEDULED  = 'Scheduled';
    private static List<Opportunity> selectedOppList = New List<Opportunity>();
    private static List<Task> journeyTaskToCancel = new List<Task>();
    private static List<AccountMessage__c> accountMessageListToDelete = new List<AccountMessage__c>();
    private static Opportunity selectedOpportunity;
    private static Journey__c selectedJourney;
    private static final String STOP_JOURNEY_ACTION_TYPE = 'Journey Stopped';
    private static final String STOP_JOURNEY_CLOSED_WON_ACTION_TYPE = 'Journey Stopped - Closed Won';
    private static AP_Opportunity_StopJourneyWrapper apOppWrap = new AP_Opportunity_StopJourneyWrapper();
            
    
/**
 * @description oppStopJourneyFromLWC
 * @param opportunityId 
 * @return  `Boolean`
 */
    @AuraEnabled
    public static Boolean oppStopJourneyFromLWC(Id opportunityId) {
          
        Savepoint sp = Database.setSavepoint();
        try {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('OpportunityId', opportunityId, Opportunity.Class);
            selectedOpportunity = [Select id, RecordType.DeveloperName, Journey_ID__c, Journey_Name__c, AccountId, Account.Name, OwnerId, EventCode__c, LOB__c, Name
                                    from Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED LIMIT 1];
            selectedOppList.add(selectedOpportunity);
            deleteTasksAndAccountMessages(selectedOppList);
            //Creating a track record when Agent/ATM stops the journey from the wizard
            AP_JourneyTracker.trackOpportunityJourney(STOP_JOURNEY_ACTION_TYPE, new List<Opportunity>{selectedOpportunity});
            updateOpportunity(selectedOpportunity);
            return true;       
        } catch(Exception flowExpection) {
            Database.rollback(sp);
            LoggingService.logHandledException(flowExpection, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);
            return false;
        }
    }

    /**
    * @description This method will update the Opportunity Journey fields as null
    * @name - updateOpportunity
    * @param currentOpp -  Opportunity List where user is performing the Stop Journey operation 
    */
    private static void updateOpportunity(Opportunity currentOpp) {     
        
        apOppWrap.updateOpportunity(currentOpp);
    }
     
    /**
    * @description This method will delete-Account Messages and update-Task Status as cancelled for all Account messages and Task related to the passed Opportunities
    * @name - deleteTasksAndAccountMessages
    * @param oppList -  List of Opportunities passed for Account Message Deletion and Task Update
    */
    public static void deleteTasksAndAccountMessages(List<Opportunity> oppList) {
        if (oppList != null && !oppList.IsEmpty()) {
            Set<Id> oppIdSet = new Set<Id>();
            Set<String> journeyExtIdSet = new Set<String>();
            List<Id> journeyIdList = new List<Id>();
            for (Opportunity opprecord : oppList) {
                oppIdSet.add(opprecord.id);
                journeyExtIdSet.add(opprecord.Journey_ID__c);
            }
            for(Journey__c journeyRecord: [Select id from Journey__c where Journey_External_ID__c IN :journeyExtIdSet WITH SECURITY_ENFORCED]) {
                journeyIdList.add(journeyRecord.id);
            }      
            //Updating Journey Task as Cancelled
            updateJourneyTasks(journeyIdList,oppIdSet);      
            //Deleting Account Messages with Status 'Scheduled' 
            if (!journeyExtIdSet.IsEmpty()) {
                accountMessageListToDelete = [Select id from AccountMessage__c where JourneyID__c IN: journeyExtIdSet and OpportunityId__c IN: oppIdSet
                                                 and Status__c =: ACCOUNTMESSAGE_STATUS_SCHEDULED WITH SECURITY_ENFORCED];
            } 
            if(!journeyExtIdSet.IsEmpty() && !accountMessageListToDelete.IsEmpty() && Schema.sObjectType.AccountMessage__c.isDeletable()) {
                Database.delete(accountMessageListToDelete);
            }     
        }                         
    }
   
    /**
    * @description Method to bulk delete-Account Messages with scheduled Status and update-Task Status as cancelled for all Account messages and Task related to the passed Opportunities
    *           This method will be invoked from Opportunity After Update Trigger
    * @name - deleteTasksAndAccountMessagesBulk
    * @param oppList -  List of Opportunities passed for Account Message Deletion and Task Update
    * @param oppJourneyExtIdSet
    */
    public static void deleteTasksAndAccountMessagesBulk(List<Opportunity> oppList, Set<String> oppJourneyExtIdSet) {
            
        if (!oppList.IsEmpty() && !oppJourneyExtIdSet.IsEmpty()) {
            Set<Id> oppIdSet = new Set<Id>();
            Set<String> journeyExtIdSet = new Set<String>();
            List<Id> journeyIdList = new List<Id>();
            for (Opportunity opprecord : oppList) {
                oppIdSet.add(opprecord.id);
                journeyExtIdSet.add(opprecord.Journey_ID__c);
            }
            for(Journey__c journeyRecord: [Select id from Journey__c where Journey_External_ID__c IN :oppJourneyExtIdSet WITH SECURITY_ENFORCED]) {
                journeyIdList.add(journeyRecord.id);
            }      
            //Updating Journey Task as Cancelled
            updateJourneyTasks(journeyIdList,oppIdSet);           
            //Deleting Account Messages with Status 'Scheduled' 
            if (!journeyExtIdSet.IsEmpty()) {
                accountMessageListToDelete = [Select id from AccountMessage__c where JourneyID__c IN: oppJourneyExtIdSet and OpportunityId__c IN: oppIdSet and Status__c =: ACCOUNTMESSAGE_STATUS_SCHEDULED WITH SECURITY_ENFORCED];
                deleteAccountMessageList();
            }   
        }                         
    }       
     
    static void deleteAccountMessageList(){
        if(!accountMessageListToDelete.IsEmpty() && Schema.sObjectType.AccountMessage__c.isDeletable()) {
             Database.delete(accountMessageListToDelete);
          }
    }

    /**
    * @description This method will bulk update the Opportunity Journey fields as null and also flip the record Type for Start Journey
    *           Will be invoked from Opportunity Before Update Trigger
    * @name - updateOpportunityList
    * @param currentOppList -  Opportunity List where user is performing the Stop Journey operation / RFC is Granted
    */
    public static void updateOpportunityList(List<Opportunity> currentOppList) {      
        Set<ID> sAccountid = New Set<ID>();
        Set<ID> sOpportunityid = New Set<ID>();
        String oppStageClosedWon = 'Closed Won';
        
        for (Opportunity currentopp : currentOppList) {
            if(oppStageClosedWon.equalsIgnoreCase(currentopp.StageName)){
                sAccountid.add(currentopp.Accountid);
                sOpportunityid.add(currentopp.id);
            }
        }
        
        if(!sOpportunityid.isEmpty()){
            List<Opportunity> selectedOpportunities = [Select id, Journey_ID__c, Journey_Name__c, AccountId, Account.Name, OwnerId, EventCode__c, LOB__c, Name
                                                       from Opportunity where ID IN: sOpportunityid WITH SECURITY_ENFORCED];                                       
            AP_JourneyTracker.trackOpportunityJourney(STOP_JOURNEY_CLOSED_WON_ACTION_TYPE, selectedOpportunities);
        }                                               
        for (Opportunity currentopp : currentOppList) {
                currentOpp.Journey_ID__c = null;
                currentOpp.Journey_Name__c = null;
                currentOpp.Journey_Description__c = null;
                currentOpp.Journey_Start_Date__c = null;                
        }
        
        if(!sAccountid.isEmpty()){
            clearAccountMessages(sAccountid);
        }
        if(!sOpportunityid.isEmpty()){
            clearOpportunityActivites(sOpportunityid);
        }        
    }
    /**
    * @description Method to clear Account message on Opportunity Account, if the opportunity got Closed
    * @name - clearAccountMessages
    * @param sAccountid -  Set of Opportunity's Account id
    */
    public static void clearAccountMessages(Set<id> sAccountid){
        List<AccountMessage__c> lAccountMessgesUpdate = New List<AccountMessage__c>();
        for(AccountMessage__c accMsg :[Select id,Status__c from AccountMessage__c where Account__c IN : sAccountid WITH SECURITY_ENFORCED]){
            accMsg.Status__c = 'Cancelled - stopped journey';
            lAccountMessgesUpdate.add(accMsg);
        }
        updateAccountMessages(lAccountMessgesUpdate);        
    }
          
    /**
    * @description Method to clear Tasks/Activites which are associated to an Closed won Opportunity.
    * @name - clearOpportunityActivites
    * @param sOptyid -  Set of Opportunitys id
    */
    public Static void clearOpportunityActivites(Set<Id> sOptyid){
        List<Task> lCompletedTaskUpdate = New List<Task>();
        for(Task optyTask :[Select id,Status from Task where Whatid IN :sOptyid and TaskCategory__c = 'Journey' and Isclosed = false WITH SECURITY_ENFORCED]){
            optyTask.Status = 'Completed';
            lCompletedTaskUpdate.add(optyTask);
        }
        updateTasks(lCompletedTaskUpdate);
    }
    
    //method to update account messages
    private static void updateAccountMessages(List<AccountMessage__c> accountMessagesToUpdate){
        if(!accountMessagesToUpdate.isEmpty() && Schema.sObjectType.AccountMessage__c.isUpdateable()){
            Database.update(accountMessagesToUpdate);
        }
    }

    private static void updateJourneyTasks(List<Id> journeyIdList, Set<Id> oppIdSet) {
        apOppWrap.updateJourneyTasks(journeyIdList, oppIdSet);
    }

   /**
    * @description updateTasks
    * @param updateCompletedTasks
    */
    //method to update tasks
    private static void updateTasks(List<Task> updateCompletedTasks){
        if(!updateCompletedTasks.isEmpty() && Schema.sObjectType.Task.isUpdateable()){
            Database.update(updateCompletedTasks);
        }
    }
    
    private with sharing class AP_Opportunity_StopJourneyWrapper{

        private void updateOpportunity(Opportunity currentOpp){
            if (currentOpp != null) {
                currentOpp.Journey_ID__c = null;
                currentOpp.Journey_Name__c = null;
                currentOpp.Journey_Description__c = null;
                currentOpp.Journey_Start_Date__c = null;
            }
            if(Schema.sObjectType.Opportunity.isUpdateable()){
                Database.update(currentOpp);
            }
        }

        private void updateJourneyTasks(List<Id> journeyIdList, Set<Id> oppIdSet) {
            if (!journeyIdList.IsEmpty()) {
                journeytaskToCancel = [Select id,IsClosed from Task where JourneyId__c IN: journeyIdList and Whatid IN: oppIdSet
                                         and Isclosed = False WITH SECURITY_ENFORCED];
                for (Task journeyTask : journeytaskToCancel) {
                        journeyTask.status = TASK_STATUS_CANCELLED;
                }
                if(Schema.sObjectType.Task.isUpdateable()) {
                    Database.update(journeytaskToCancel);
                }
            }
        }
    }
}
