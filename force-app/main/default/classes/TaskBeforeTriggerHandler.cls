/** 
* @name TaskBeforeTriggerHandler
* @description task before trigger handler
*/
public with sharing class TaskBeforeTriggerHandler {

    public static boolean isInsert = false;
	@TestVisible private static boolean mockUserHasPrevalidatedData = false;
    
    /**
     * @name handleBeforeInsert
     * @description process the Before Insert trigger on the task object based user permission
     * @param newTaskList
     */
    public static void handleBeforeInsert(List<Task> newTaskList){
        isInsert = true;
		boolean userHasPrevalidatedData = TaskHandlerUtility.userHasPrevalidatedData();
        if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
         	userHasPrevalidatedData = mockUserHasPrevalidatedData;
        }
        if(userHasPrevalidatedData){
            handleValidatedTaskInsert(newTaskList);
        }else{
            handleNonValidatedTaskInsert(newTaskList);
        }

        // Check if premium increase handler should be bypassed.
        CS001_ByPassTriggerGtoZ__c byPassObjectTrigger = CS001_ByPassTriggerGtoZ__c.getInstance();
        if(!byPassObjectTrigger.Override_TaskPremiumIncreaseHandler__c){
            TaskPremiumIncreaseHandler.handlePremiumIncrease(newTaskList);
        }
    }
    
    @TestVisible private static void handleValidatedTaskInsert(List<Task> newTaskList){
        List<Task> tasksWithPrimaryClientIds = new List<Task>();
        Set<String> clientIdentifierSet = new Set<String>();
        for(Task taskRecord : newTaskList){
            TaskHandler.handleLogs(taskRecord);

            if(String.isNotBlank(taskRecord.PrimaryClientId__c)){ //Replace with custom permission
            	clientIdentifierSet.add(taskRecord.PrimaryClientId__c);
                tasksWithPrimaryClientIds.add(taskRecord);
            }
            
            // Swap the owner - For Case Migration we can't set the owner using external identifier. 
            // And we can't create new User field as we already have Assigned To
            // So we are using Assigned To as we don't get Assigned To from Case Migration
            if(taskRecord.OwnerId == UserInfo.getUserId() && taskRecord.AssignedTo__c != null){
                taskRecord.OwnerId = taskRecord.AssignedTo__c;
                taskRecord.AssignedTo__c = null;
            }

            TaskHandler.handleInvalidRecordType(taskRecord);
            TaskPriorityHandler.handlePriority(taskRecord);
        }
        if(!clientIdentifierSet.isEmpty()){
            TaskHandler.handlePrimaryClientId(tasksWithPrimaryClientIds, clientIdentifierSet);
        }
    }
    
    @TestVisible private static void handleNonValidatedTaskInsert(List<Task> newTaskList){
        for(Task taskRecord : newTaskList){
            TaskHandler.handleLogs(taskRecord);
            TaskHandler.handleInvalidRecordType(taskRecord);
            TaskPriorityHandler.handlePriority(taskRecord);
        }
        TaskHandler.handleSPI(newTaskList);
        TaskHandler.handleAgentRoleCheck(newTaskList);
        TaskHandler.setTaskOwnerToProxy(newTaskList);
    }
    
    /**
     * @name handleBeforeUpdate
     * @description process the Before Update trigger on the task object
     * @param newTaskList
     * @param oldTaskMap
     */
    public static void handleBeforeUpdate(List<Task> newTaskList, Map<Id,Task> oldTaskMap){
        List<Task> spiCheckList = new List<Task>();
        if(!isInsert){
            for(Task taskRecord: newTaskList){
                Task oldTask = oldTaskMap.get(taskRecord.Id); 
				spiCheckList = TaskHandlerUtility.taskNeedsSPICheckOnUpdate(taskRecord, oldTask, spiCheckList);
                TaskHandler.handleInvalidRecordType(taskRecord);
                TaskOutcomeHandler.handleCloseTaskWithOutcome(taskRecord, oldTask);
                TaskHandler.handleAgencySubjectChange(taskRecord, oldTask);
                TaskPriorityHandler.handlePriority(taskRecord);
            }
            TaskHandler.handleTaskOwnerChange(newTaskList, oldTaskMap);
        }
        if(!spiCheckList.isEmpty()){
            TaskHandler.handleSPI(spiCheckList);
        }
    }
    
    /**
     * @name handleBeforeDelete
     * @description process the Before Delete trigger on the task object
     * @param oldTaskList
     */
    public static void handleBeforeDelete(List<Task> oldTaskList){
       TaskHandler.handleTaskDelete(oldTaskList);
    }
}