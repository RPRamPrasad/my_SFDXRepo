/**
 Author Team Clubcar
 Name - AP_Opportunity_StartJourney
 @description - Helper class used by Opportunity Start Journey flow
                This class will update the Opportunity record with selected Journey Details and create Journey Tasks and Account Messages
=========================================================================================================================================
History
-------
VERSION         AUTHOR                  DATE                DETAIL
18.0            Team Clubcar            2/06/2017           Initial Development
*****************************************************************************************************************************************/
public with Sharing Class AP_Opportunity_StartJourney {
    
    private static final String CLASS_NAME = 'AP_Opportunity_StartJourney';
    private static final String METHOD_NAME = 'oppStartJourney';
    private static final String TASK_DESCRIPTION_MESSAGE = 'Follow up or Determine next marketing step';
    private static List<Journey_Step__c> listJourneyStepFromMapping; 
    private static list<CMOpportunityStartJourneyMapping__mdt> mappingForAccountMessagetoJourneyStep;
    private static final String START_JOURNEY_ACTION_TYPE = 'Journey Started';
    
    /**
    * @description Entry Level method for the class, This method will be called by LWC
    * @name - oppStartJourney
    * @param  opportunityId -  List of String containing Opportunity Id and Journey Id 
    * @param journeyId
    * @return List<Boolean> - This method return a Boolean List as an Output for the Flow.
    */
    @AuraEnabled
    public static Boolean oppStartJourney(Id opportunityId, Id journeyId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('OpportunityId', opportunityId, Opportunity.Class);
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('JourneyId', journeyId, Journey__c.Class);
        Savepoint sp = Database.setSavepoint();
        try {
                Opportunity selectedOpportunity = getOpportunityRecord(opportunityId);
                Journey__c selectedJourney = getJourneyRecord(journeyId);
                mappingForAccountMessagetoJourneyStep = getOppJrnyMappingMetadata();
                listJourneyStepFromMapping = queryJourneySteps(mappingForAccountMessagetoJourneyStep, selectedJourney.Id);
                updateOpportunity(selectedOpportunity,selectedJourney);                
                createAccountMessages(selectedOpportunity,selectedJourney,listJourneyStepFromMapping);          
                createJourneyTasks(selectedOpportunity,selectedJourney);
                //Creating a track record when Agent/ATM is starting journey on the current opportunity
                AP_JourneyTracker.trackOpportunityJourney(START_JOURNEY_ACTION_TYPE,new List<Opportunity>{selectedOpportunity});
            return true;
        } catch(Exception flowExpection) {
                Database.rollback(sp);
                LoggingService.logHandledException(flowExpection, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);
                return false;
            }          
    }

    // helper method to query Journey Step records based on metadatamapping
    private static List<Journey_Step__c> queryJourneySteps(list<CMOpportunityStartJourneyMapping__mdt> mappingForAccountMessagetoJourneyStep, Id selectedJourneyId) {
        SET<String> contactMethodSet; 
        contactMethodSet = new SET<String>{'Mailing', 'Email'};
        String queryStart = 'Select Id,DaysNum__c';
        String queryEnd = ' from Journey_Step__c where ContactMethodName__c IN :contactMethodSet AND JourneyId__c =:selectedJourneyId';
        String queryFields='';
        String queryDelimiter = ',';       

        if (mappingForAccountMessagetoJourneyStep != null && !mappingForAccountMessagetoJourneyStep.isEmpty()) {
            for(CMOpportunityStartJourneyMapping__mdt metamapping : mappingForAccountMessagetoJourneyStep) {                
                queryFields = queryFields + queryDelimiter + metamapping.SourceField__c;
            }
        }                
        String dynamicQuery = queryStart + queryFields + queryEnd;           
        return Database.Query(String.escapeSingleQuotes(dynamicQuery));
    }
        
    /**
    * @description Helper method to update Opportunity record with selected Journey Information 
    * @name - updateOpportunity
    * @param currentOpp - Opportunity record
    * @param currentJourney - Selected Journey record
    */

    private static void updateOpportunity(Opportunity currentOpp, Journey__c currentJourney) {  

        if (currentOpp != null && currentJourney != null) {    
            currentOpp.Journey_ID__c = currentJourney.Journey_External_ID__c;
            currentOpp.Journey_Name__c = currentJourney.JourneyName__c;
            currentOpp.Journey_Description__c = currentJourney.JourneyDescription__c;
            currentOpp.Journey_Start_Date__c = OppCalJrnyStartDate.calculateJourneyStartDate(currentOpp, currentJourney);            
            if(Schema.sObjectType.Opportunity.isUpdateable()){
                Database.update(currentOpp);
            }
        }
    }      
   
    /**
    * @description - Helper method to create Journey Task based on selected Journey - Journey Steps for ContactMethodName equals Call
    * @name - createJourneyTasks
    * @param currentOpp - Opportunity record
    * @param currentJourney - Selected Journey record
    */

    private static void createJourneyTasks(Opportunity currentOpp, Journey__c currentJourney) {
        List<Task> listTaskToInsert = new List<Task>();
        List<String> journeyStepValues = new List<string>{'Call','Other','Appointment'};
        if (currentOpp != null && currentJourney != null) {
        for (Journey_Step__c selectedJS : [Select id, ContactMethodName__c, JourneyStepID__c,DaysNum__c, Script__c from Journey_Step__c
                                                where JourneyID__c =:currentJourney.id AND ContactMethodName__c in:journeyStepValues WITH SECURITY_ENFORCED]) {
                Task journeyTask = New Task();
                journeyTask.AssignedTo__c = currentOpp.Assigned_To__c;
                journeyTask.whoid = currentOpp.Account.PersonContactId;
                journeyTask.ownerid = currentOpp.ownerid;
                journeyTask.Whatid = currentOpp.id;
                journeyTask.LineofBusiness__c = currentOpp.LOB__c;
                journeyTask.JourneyName__c = currentJourney.JourneyName__c;
                journeyTask.JourneyId__c = currentJourney.id;
                journeyTask.Status = 'Not Started';
                journeyTask.Subject = selectedJS.ContactMethodName__c;
                journeyTask.AppCode__c ='SFDC ILP Journey';
                journeyTask.TaskCategory__c ='Journey';
                journeyTask.Task_Type__c ='Sales';           
                journeyTask.StepNumber__c = selectedJS.JourneyStepID__c;
                journeyTask.Priority = 'No'; 
                if (selectedJS.DaysNum__c != null) {
                    journeyTask.ActivityDate =  currentOpp.Journey_Start_Date__c.AddDays(selectedJS.DaysNum__c.intValue());
                }                               
                if (selectedJS.Script__c != null) {
                    journeyTask.Description = selectedJS.Script__c;}
                else {
                    journeyTask.Description = TASK_DESCRIPTION_MESSAGE;
                }
                listTaskToInsert.add(journeyTask);  
            }
        }
        UTIL_TaskDAO.insertTasks(listTaskToInsert);
    }   

        
    /**
    * @description Helper method to create Account Messages based on selected Journey - Journey Steps for ContactMethodName equals Mailing
    * @name - createAccountMessages
    * @param currentOpp - Opportunity record
    * @param currentJourney - Selected Journey record
    * @param queriedlistJourneyStep - List of Journey Steps created from metadata mapping
    */ 
    private static void createAccountMessages(Opportunity currentOpp, Journey__c currentJourney, List<Journey_Step__c> queriedlistJourneyStep) {
        List<AccountMessage__c> listAccountMessageToInsert = new List<AccountMessage__c>();        
        if (queriedlistJourneyStep != null && !queriedlistJourneyStep.isEmpty()) {

            for (Journey_Step__c selectedJS1 : queriedlistJourneyStep) {
                AccountMessage__c jsAccountMessage = new AccountMessage__c();
        
                jsAccountMessage = buildAccountMsgRecord(currentOpp,currentJourney, selectedJS1);
                if (selectedJS1.DaysNum__c != null) {
                    jsAccountMessage.TransmissionDate__c =  currentOpp.Journey_Start_Date__c.AddDays(selectedJS1.DaysNum__c.intValue());
                }                
                listAccountMessageToInsert.add(jsAccountMessage);
            }
        }
        insertAccountMessageList(listAccountMessageToInsert);     
    }

    // helper method to build Account Message records based on Journey Step mapping
    private static AccountMessage__c buildAccountMsgRecord(Opportunity currentOpp, Journey__c currentJourney, Journey_Step__c selectedJS1) {
        String agentAssocId = [Select id, Servicing_Agent_Associate_ID__c from User where id =: currentOpp.OwnerId WITH SECURITY_ENFORCED LIMIT 1].Servicing_Agent_Associate_ID__c;
        AccountMessage__c jsAccountMessage = new AccountMessage__c();
        if (mappingForAccountMessagetoJourneyStep != null && !mappingForAccountMessagetoJourneyStep.isEmpty()) {
            for(CMOpportunityStartJourneyMapping__mdt metadataMapping : mappingForAccountMessagetoJourneyStep){                
                jsAccountMessage.put(metadataMapping.TargetField__c,selectedJS1.get(metadataMapping.SourceField__c));
            }
        } 
        jsAccountMessage.name = currentOpp.Account.FirstName;
        jsAccountMessage.Account__c = currentOpp.Accountid;
        jsAccountMessage.BusinessLineCode__c = currentOpp.LOB__c;
        jsAccountMessage.JourneyID__c = currentJourney.Journey_External_ID__c;
        jsAccountMessage.JourneyDescription__c = currentJourney.JourneyDescription__c;
        jsAccountMessage.JourneyName__c = currentJourney.JourneyName__c;
        jsAccountMessage.CategoryName__c = currentJourney.CategoryName__c;
        jsAccountMessage.CreatorRoleCode__c = currentJourney.CreatorRoleCode__c;
        jsAccountMessage.CustomDemographicsID__c = currentJourney.CustomDemographicsInd__c;
        jsAccountMessage.JourneyFundingID__c = currentJourney.JourneyFundingID__c;
        jsAccountMessage.Status__c = 'Scheduled';
        jsAccountMessage.AssociateID__c = agentAssocId;
        jsAccountMessage.OpportunityId__c = currentOpp.id;
        return jsAccountMessage;
    }


    // helper method to return opportunity records with required fields
    private static Opportunity getOpportunityRecord(Id oppId) {
            return [Select id, LOB__c, X_Date__c, Ownerid,Accountid,Account.PersonContactId, CreatedDate, Account.FirstName, Journey_Start_Date__c,
                        RecordType.DeveloperName, Assigned_To__c, Account.Name, Name, Journey_Name__c, EventCode__c, Journey_ID__c from Opportunity 
                            where id =:oppId WITH SECURITY_ENFORCED LIMIT 1];
    }

    // helper method to return Journey__c record with required fields
    private static Journey__c getJourneyRecord(Id journeyId) {
        Journey__c jrnyrecord =  [Select id,JourneyName__c,JourneyDescription__c, Journey_External_ID__c, CategoryName__c,
                    CreatorRoleCode__c, CustomDemographicsInd__c, JourneyFundingID__c,Type__c from Journey__c 
                        where id =:journeyId WITH SECURITY_ENFORCED Limit 1];
                        return jrnyrecord;
    }
    // helper method to return CMOpportunityStartJourneyMapping__mdt record with required fields
    private static List<CMOpportunityStartJourneyMapping__mdt> getOppJrnyMappingMetadata () {
        String mappingTypeJrnyStepToAccMessage = 'JourneyStepToAccountMessage';
        return [SELECT Id, MappingType__c, SourceField__c, TargetField__c FROM CMOpportunityStartJourneyMapping__mdt
                    where MappingType__c =: mappingTypeJrnyStepToAccMessage WITH SECURITY_ENFORCED];
    }

    private static void insertAccountMessageList(List<AccountMessage__c> accountMessageListToInsert) {
        if (!accountMessageListToInsert.isEmpty() && Schema.SObjectType.AccountMessage__c.isCreateable()) {
            Database.insert(accountMessageListToInsert);
        }   
    }

    // helper method to query Journey Step DaysNum with CRUD validation
    private static Integer getJourneyStepDaysNum (Id currentJourneyId) {
        Integer stepOne = 1;
            List<Journey_Step__c> jnyStepFirstList = [SELECT DaysNum__c FROM Journey_Step__c WHERE JourneyStepID__c =: stepOne AND JourneyID__c =: currentJourneyId WITH SECURITY_ENFORCED];
            return jnyStepFirstList[0].DaysNum__c.intvalue();
    }
}