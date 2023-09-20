/**
* @author Team Quadcore
* @created 12/22/2020
* @description This is a Apex Class which is called by OpportunityAfterUpdatetrigger for Kill switch Process.
* @version 2.0
*/
public without sharing class AP_OpportunityKillProcess {
   
    private static final String CLASS_NAME = 'AP_OpportunityKillProcess';
    private static final String METHOD_NAME = 'hasKillSwitchAccess';
    private static final Set<String> TASKCANCELSTAGES = new Set<String> {'Not Now -  Follow Up', 'App Submitted', 'Closed' , 'Closed Won' };

 /**
 * @description Method to check whether the Opportunity and task has  write permission set access.
 * @return Boolean value
 */
    public static Boolean hasKillSwitchAccess() {

        User loggedInUser;
        for(User usr: [select id,Profile.Name from User WHERE Id = :UserInfo.getUserId() LIMIT 1]) {
            loggedInUser = usr;
        }
        List<TaskUpdateProfileAccess__c> profileAccessSettings = new List<TaskUpdateProfileAccess__c>();
        profileAccessSettings = validateProfileSettings(profileAccessSettings, loggedInUser);
        
        if(profileAccessSettings.size() ==0) {
            return false;
        }
        List<String> taskEditablePSes = new List<String>();
        List<String> oppEditablePSes = new List<String>();
        
        for(TaskUpdateProfileAccess__c accessSetting : profileAccessSettings) {
            if(accessSetting.Is_Opp_Editable__c) {
                oppEditablePSes.AddAll(accessSetting.Permissionset_Name__c.Split(','));
            }
            else if(accessSetting.Is_Task_Editable__c){
                taskEditablePSes.AddAll(accessSetting.Permissionset_Name__c.Split(','));
            }
        }
        
        Boolean isTaskPSEmptyInSetting = taskEditablePSes.isEmpty();
        Boolean isOppPSEmptyInSetting = oppEditablePSes.isEmpty();
        
        //Boolean isOppPSNotEmpty = getOppPermissionSet(oppEditablePSes);

        Boolean isTaskPSNotEmpty = getTaskPermissioNSetSize(taskEditablePSes);

  
         return (isTaskPSEmptyInSetting && isOppPSEmptyInSetting) || isTaskPSNotEmpty ;
    }
    
    /**
   * @description Method is to change the task status.
   * @param oppIds List<Id> 
   * @return tasksToBeCancelled
   */
    private static List<Task>cancelledTaskList(List<Id> oppIds){
        List<Task> tasksToBeCancelled = new List<Task>();
          for(Task tsks : [SELECT Id, TaskCategory__c, Status 
                         FROM Task 
                         WHERE WhatId IN :oppIds AND TaskCategory__c IN ('Prospecting Plan','Sales Follow-Up')  AND Status IN ('In Progress','Not Started')]){
                             tasksToBeCancelled.add(tsks);
                         }
        for(Task tsk : tasksToBeCancelled) {
            tsk.Status = 'cancelled';
            }
            return tasksToBeCancelled;
    }
    
    /**
   * @description Method is to throw Error or success messages.
   * @param oppIds List<Id> 
   */
    public static void updateTaskStatusToCancelled(List<Id> oppIds) { 
        if(oppIds.size() > 0){
            List<Task> tasksToBeCancelled = cancelledTaskList(oppIds);
            if(tasksToBeCancelled.size() ==0) {
                return;
            }
              try{
                Database.SaveResult[] updateTaskresults =   Database.update(tasksToBeCancelled, false) ;  
                LoggingService.logDatabaseResult(updateTaskresults, tasksToBeCancelled, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
               }
            catch(DMLException ex){
                LoggingService.logHandledException(ex, CLASS_NAME , METHOD_NAME, System.LoggingLevel.ERROR);
            }
        }
    }
    
    /**
    * @description Method to check the Custom settings access.
    * @param profileAccessSettings List<TaskUpdateProfileAccess__c> 
    * @param loggedInUser User 
    * @return profileAccessSettings
    */
    private static List<TaskUpdateProfileAccess__c> validateProfileSettings(List<TaskUpdateProfileAccess__c> profileAccessSettings, User loggedInUser){
        for(TaskUpdateProfileAccess__c prfAccessSetting : [select id,Name,Profile_Name__c,Permissionset_Name__c, Is_Opp_Editable__c, Is_Task_Editable__c 
        from TaskUpdateProfileAccess__c WHERE Profile_Name__c =: loggedInUser.Profile.Name]) {
            profileAccessSettings.add(prfAccessSetting);
        }
        return profileAccessSettings;
    }

    /**
    * @description Method to get the Opportunities with permission sets.
    * @param oppEditablePSes List<String> 
    * @return Boolean
    */
    private static Boolean getOppPermissionSet(List<String> oppEditablePSes){
        List<PermissionSetAssignment> oppPSAssigned = new List<PermissionSetAssignment>();
        for(PermissionSetAssignment opps : [SELECT id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment 
        WHERE AssigneeId=:UserInfo.getUserId() AND PermissionSet.Name IN :oppEditablePSes ]){
                     oppPSAssigned.add(opps);
        }
        return (oppPSAssigned.size() >0);
    }
 
    /**
    * @description Method to get the Tasks with permission sets.
    * @param taskEditablePSes List<String> 
    * @return Boolean
    */
    private static Boolean getTaskPermissioNSetSize(List<String> taskEditablePSes){
        List<PermissionSetAssignment> taskPSAssigned = new List<PermissionSetAssignment>();

        for(PermissionSetAssignment tkps : [SELECT id, AssigneeId, PermissionSet.Name 
                                                        FROM PermissionSetAssignment
                                                        WHERE AssigneeId=:UserInfo.getUserId() AND PermissionSet.Name IN :taskEditablePSes]){
                taskPSAssigned.add(tkps);
        }

        return (taskPSAssigned.size() > 0);
    }
 
    /**
    * @description Method to get the Tasks with permission sets.
    * @param updatedOpportunity Opportunity 
    * @param oppIdToUpdateTaskList List<Id> 
    */
    public static void validateTaskData(Opportunity updatedOpportunity, List<Id> oppIdToUpdateTaskList){
            oppIdToUpdateTaskList.add(updatedOpportunity.Id);
    }
    
   
}