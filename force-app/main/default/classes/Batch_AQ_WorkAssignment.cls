/**
  * @name Batch_AQ_WorkAssignment
  * @author Team Skynet
  * @createdDate 11/15/2022
  * @description Query Unassigned Tasks and assign the ones that we have WorkAssignmentPreference rules for
  */
  public with sharing class Batch_AQ_WorkAssignment implements Schedulable, Database.Batchable<SObject> {
    private static final String CLASS_NAME = 'Batch_AQ_WorkAssignment';
    private static final String START_METHOD_NAME = 'start';
    private static final String ASSIGNTASKS_METHOD_NAME = 'assignTasks';
    private static final String ACCOUNT_TYPE = 'Account';
    private static final String NOT_STARTED = 'Not Started';
    private static final String TASK_RECORDTYPE = 'Task';
    private static final String SOEDELEGATE_DEFAULT_USERNAME = 'sf_crm_soedelegate@statefarm.com';
    private static final String TASKAPI_DEFAULT_USERNAME = 'sf_crm_taskapi@statefarm.com';

    private static final String CS_AGENTQUEUE_CONFIG_HOURS_BEHIND = 'BatchAgentQueueHoursBehind';
    private static final CS_AGENTQUEUE_Config__c HOURS_BEHIND = CS_AGENTQUEUE_Config__c.getValues(CS_AGENTQUEUE_CONFIG_HOURS_BEHIND);

    private static final String CS_AGENTQUEUE_CONFIG_SOEDELEGATE = 'SoeDelegateUserName';
    private static final CS_AGENTQUEUE_Config__c CS_AGENTQUEUE_CONFIG_SOEDELEGATE_USERNAME = CS_AGENTQUEUE_Config__c.getValues(CS_AGENTQUEUE_CONFIG_SOEDELEGATE);

    private static final String CS_AGENTQUEUE_CONFIG_TASKAPI = 'TaskApiUserName';
    private static final CS_AGENTQUEUE_Config__c CS_AGENTQUEUE_CONFIG_TASKAPI_USERNAME = CS_AGENTQUEUE_Config__c.getValues(CS_AGENTQUEUE_CONFIG_TASKAPI);

    /**
     * @method execute
     * @description Loop through Unassigned Task objects and runs the roundRobinAssignment method to handle assignment
     * @param sc a SchedulableContext object
     */
    public void execute(SchedulableContext sc) {

        Batch_AQ_WorkAssignment aqWorkAssignment = new Batch_AQ_WorkAssignment();
        Database.executeBatch(aqWorkAssignment, 2000);
    }

    /**
     * @method start
     * @description This method identifies Unassigned Task records to be assigned using the WorkAssignmentPreferences of their Owner
     * @param bc Batchable context set by platform
     * @return <Tasks>
     * @throws exception - <Method is not throwing any exception>
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Database.QueryLocator queryLocator;
        String queryString = '';
        DateTime hoursBack = getTaskTime();

        List<Id> createdByIds = getCreatedByIds();

        //Fetch all the stand alone Tasks created by Jarvis, which are not assigned, created within a particular timeframe for a pilot agent office
        queryString = 'SELECT Id, CreatedDate, OwnerId, Subject, LineofBusiness__c, WhatId, Account.LastName, Status ' +
                    'FROM Task ' +
                    'WHERE Status = :NOT_STARTED ' +
                    'AND RecordType.Name = :TASK_RECORDTYPE ' +
                    'AND CreatedById IN :createdByIds ' +
                    'AND (WhatId = null OR What.Type = :ACCOUNT_TYPE) ' +
                    'AND CreatedDate > :hoursBack ' +
                    'AND LastModifiedDate > :hoursBack ' +
                    'AND AssignedTo__c = null ' +
                    'AND Original_Subject__c = null ' +
                    'ORDER BY CreatedDate ASC ' +
                    'LIMIT 100000 ';

        try {
            queryLocator = Database.getQueryLocator(queryString);
        } catch(Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME , START_METHOD_NAME, System.LoggingLevel.ERROR);
        }


        return queryLocator;
    }

    private List<Id> getCreatedByIds(){
        List<String> userNames = new List<String>();

        if(CS_AGENTQUEUE_CONFIG_SOEDELEGATE_USERNAME == null){
            userNames.add(SOEDELEGATE_DEFAULT_USERNAME);
        } else {
            userNames.add(CS_AGENTQUEUE_CONFIG_SOEDELEGATE_USERNAME.ValueString__c);
        }

        if(CS_AGENTQUEUE_CONFIG_TASKAPI_USERNAME != null){
            userNames.add(CS_AGENTQUEUE_CONFIG_TASKAPI_USERNAME.ValueString__c);
        } else {
            userNames.add(TASKAPI_DEFAULT_USERNAME);
        }

        List<User> users = Security.stripInaccessible(AccessType.READABLE, [SELECT Id FROM User WHERE UserName = :userNames ]).getRecords();

        //List<Id> createdByIds = new List<Id>(new Map<Id, User>(users).keySet());

        return new List<Id>(new Map<Id, User>(users).keySet());
    }

    /**
     * @description This method executes the batchable records
     * @method execute: execute method for the batch
     * @param bc Batchable context set by platform
     * @param unassignedTasksToProcess Objects in scope for this batch execution
     *
     */
    public void execute(Database.BatchableContext bc, List<Task> unassignedTasksToProcess) {
        if(!unassignedTasksToProcess.isEmpty()){
            assignTasks(unassignedTasksToProcess);
        }
    }

    /**
     * @method assignTasks
     * @description calls the assignTasksToUsers method
     * @param unassignedTasksToProcess List<Task> to be Assigned based on AQ_WorkAssignmentRule__c objects
     */
    public static void assignTasks(List<Task> unassignedTasksToProcess) {
        try{
            // AQ_AutoCloseHandler.autoCloseTasks(unassignedTasksToProcess);
            AQ_TaskWorkAssignmentHandler.assignTasksToUsers(unassignedTasksToProcess);
        } catch (Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME , ASSIGNTASKS_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }

    /**
     * @method finish
     * @description This method is declared but has no implementation for interface
     * @param bc Batchable context set by platform
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {

    }

    /**
     * @description This method will process the getTaskTime
     * @return  `DateTime`
     */
    public static DateTime getTaskTime(){
        Datetime hoursBack = datetime.now().addHours(-1);

        if(HOURS_BEHIND != null) {

            hoursBack = (DateTime)JSON.deserialize('"'+HOURS_BEHIND.TaskBatchStartTime__c+'"', DateTime.class);
            //Check if task batch start time is older than 7 days
            if (datetime.now().addDays(-7) > hoursBack){
                hoursBack = datetime.now().addHours(-Integer.valueOf(HOURS_BEHIND.Value__c));
            }
        }
        return hoursBack;
    }
}
