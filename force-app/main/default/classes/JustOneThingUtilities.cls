/**
 * @description Apex utility controller for JOT component
 * @owner ASTRO
 **/
public with sharing class JustOneThingUtilities {

    private static final String LOG_DEFAULT_PRIORITY_VALUE = 'Low';
    private static final String TASK_DEFAULT_PRIORITY_VALUE = 'Medium';

    /**
     * @description - Checks if the assigned to field can be updated by the user
     * @return String - returns the user id the field can be updated, otherwise it returns null
     */
    public static String handleAssignedToUserAccess() {
        return Schema.SObjectType.Task.fields.AssignedTo__c.isUpdateable() ? UserInfo.getUserId() : null;
    }

    /**
     * @description - Checks if the owner id to field can be updated by the user
     * @return String - returns the user id the field can be updated, otherwise it returns null
     */
    public static String handleOfficeAssignedUserAccess() {
        return Schema.SObjectType.Task.fields.OwnerId.isUpdateable() ? UserInfo.getUserId() : null;
    }

    /**
     * @description - Inserts a log into the database
     * @param logRecord - The log record to be inserted
     * @return Database.SaveResult - returns the results from inserting into the database
     */
    public static Database.SaveResult insertLog(Task logRecord) {
        List<Database.SaveResult> logSaveResults;
        List<Task> tasks = new List<Task>();
        tasks.add(logRecord);

        logSaveResults = Database.insert(Security.stripInaccessible(AccessType.UPDATABLE, tasks, true).getRecords(), false);

        return logSaveResults.get(0);
    }

    /**
     * @description - Inserts a task into the database
     * @param taskRecord - The task record to be inserted
     * @return Database.SaveResult - returns the results from inserting into the database
     */
    public static Database.SaveResult insertTask(Task taskRecord) {
        List<Database.SaveResult> taskSaveResults;
        List<Task> tasks = new List<Task>();
        tasks.add(taskRecord);

        taskSaveResults = Database.insert(Security.stripInaccessible(AccessType.UPDATABLE, tasks, true).getRecords(), false);
        return taskSaveResults.get(0);
    }

    /**
     * @description - Inserts an Event into the database
     * @param eventRecord - The event record to be inserted
     * @return Database.SaveResult - returns the results from inserting into the database
     */
    public static Database.SaveResult insertEvent(Event eventRecord) {
        List<Database.SaveResult> eventSaveResults;
        List<Event> events = new List<Event>();
        events.add(eventRecord);

        eventSaveResults = Database.insert(Security.stripInaccessible(AccessType.UPDATABLE, events, true).getRecords(), false);
        return eventSaveResults.get(0);
    }

    /**
     * @description - Inserts a list of task relations into the database
     * @param taskRelations - List of task relations to be inserted
     */
    public static void insertTaskRelations(List<TaskRelation> taskRelations) {
        if (taskRelations != null && !taskRelations.isEmpty()) {
            Database.insert(taskRelations, false);
        }
    }

    /**
     * @description - Inserts a list of event relations into the database
     * @param eventRelations - List of event relations to be inserted
     */
    public static void insertEventRelations(List<EventRelation> eventRelations) {
        if (eventRelations != null && !eventRelations.isEmpty()) {
            Database.insert(eventRelations, false);
        }
    }

    /**
     * @description - Builds a new log and sets the fields using values from the parameters
     * @param paramMap - Map of parameters to use when setting fields
     * @param recordId - The id to use when setting the what id
     * @return Task - returns a log which has the fields set using the parameters
     */
    public static Task buildLog(Map<String, Object> paramMap, Id recordId) {
        SObjectType objectType = recordId.getSobjectType();
        TaskFactoryNewLog logFactory = new TaskFactoryNewLog();
        logFactory.setLogTitle(String.valueOf(paramMap.get('Subject')))
                  .setDescription(String.valueOf(paramMap.get('Description')))
                  .setAppCode('SFDC UI - ' + String.valueOf(objectType))
                  .setPriority(LOG_DEFAULT_PRIORITY_VALUE)
                  .setOwnerId(String.valueOf(paramMap.get('OwnerId')))
                  .setWhoId(String.valueOf(paramMap.get('WhoId')))
                  .setWhatId(recordId);

        return logFactory.returnNewLog();
    }

    /**
     * @description - Builds a new task and sets the fields using values from the parameters
     * @param paramMap - Map of parameters to use when setting fields
     * @param recordId - The id to use when setting the what id
     * @return Task - returns a task which has the fields set using the parameters
     */
    public static Task buildTask(Map<String, Object> paramMap, Id recordId) {
        SObjectType objectType = recordId.getSobjectType();

        TaskFactoryTask taskFactory = new TaskFactoryTask();
        taskFactory.setActivityDate(Date.valueOf(String.valueOf(paramMap.get('ActivityDate'))))
                    .setSubject(String.valueOf(paramMap.get('Subject')))
                    .setDescription(String.valueOf(paramMap.get('Description')))
                    .setPriority(TASK_DEFAULT_PRIORITY_VALUE)
                    .setStatus('Not Started')
                    .setAppCode('SFDC UI - ' + String.valueOf(objectType))
                    .setOwnerId(String.valueOf(paramMap.get('OwnerId')))
                    .setWhoId(String.valueOf(paramMap.get('WhoId')))
                    .setWhatId(recordId)
                    .setAssignedTo((paramMap.containsKey('AssignedTo')) ? String.valueOf(paramMap.get('AssignedTo')) : null)
                    .setTaskType(setTaskType(recordId.getSObjectType()))
                    .setLineOfBusiness(String.valueOf(paramMap.get('LOB')));

        return taskFactory.returnTask();
    }

    /**
     * @description - Builds a new event and sets the fields using values from the parameters
     * @param paramMap - Map of parameters to use when setting fields
     * @param recordId - The id to use when setting the what id
     * @return Event - returns an event which has the fields set using the parameters
     */
    public static Event buildEvent(Map<String, Object> paramMap, Id recordId) {
        DateTime startTime = (DateTime)JSON.deserialize('"' + paramMap.get('EventStartDateTime') + '"', DateTime.class);
        DateTime endTime = (DateTime)JSON.deserialize('"' + paramMap.get('EventEndDateTime') + '"', DateTime.class);

        Event eventRecord = new Event();
        eventRecord.Subject = String.valueOf(paramMap.get('Subject'));
        eventRecord.Description = String.valueOf(paramMap.get('Description'));
        eventRecord.WhatId = recordId;
        eventRecord.WhoId = String.valueOf(paramMap.get('WhoId'));
        eventRecord.OwnerId = String.valueOf(paramMap.get('OwnerId'));
        eventRecord.StartDateTime = startTime;
        eventRecord.EndDateTime = endTime;
        eventRecord.AssignedTo__c = (paramMap.containsKey('AssignedTo')) ? String.valueOf(paramMap.get('AssignedTo')) : null;
        eventRecord.Location = String.valueOf(paramMap.get('Location'));

        return eventRecord;
    }

    /**
     * @description - Builds a list of taskRelation records using the contact ids and the task id
     * @param relatedContactIds - List of contact ids to relate to the task
     * @param taskId - The id of the task
     * @return List<TaskRelation> - returns a list of task relations
     */
    public static List<TaskRelation> buildTaskRelations(List<Object> relatedContactIds, Id taskId) {
        List<TaskRelation> taskRelations = new List<TaskRelation>();
        for (Object relatedContactId : relatedContactIds) {
            taskRelations.add(new TaskRelation(RelationId = String.valueOf(relatedContactId), TaskId = taskId, isWhat = false));
        }
        return taskRelations;
    }

    /**
     * @description - Builds a list of eventRelation records using the contact ids and the event id
     * @param relatedContactIds - List of contact ids to relate to the event
     * @param eventId - The id of the event
     * @return List<EventRelation> - returns a list of event relations
     */
    public static List<EventRelation> buildEventRelations(List<Object> relatedContactIds, Id eventId) {
        List<EventRelation> eventRelations = new List<EventRelation>();
        for (Object relatedContactId : relatedContactIds) {
            eventRelations.add(new EventRelation(RelationId = String.valueOf(relatedContactId), EventId = eventId, isWhat = false, IsParent = true));
        }
        return eventRelations;
    }

    /**
     * @description - Returns the task type of Sales or Service if the SObject type of the what id is an Opportunity, Case, Account, or Billing Account.
     * @param objectType - The SObject type of the record id used as the what id of the task
     * @return String - returns the task type if the object is an Opportunity, Case, Account, or Billing Account. Otherwise, returns an empty string
     */
    @TestVisible
    public static String setTaskType(SObjectType objectType) {
        Set<SObjectType> salesObjects = new Set<SObjectType>{
            Opportunity.getSObjectType()
        };

        Set<SObjectType> serviceObjects = new Set<SObjectType>{
            Account.getSObjectType(),
            Billing_Account__c.getSObjectType(),
            Case.getSObjectType(),
            InsurancePolicy.getSObjectType(),
            Claim.getSobjectType()
        };

        if (salesObjects.contains(objectType)) {
            return TaskHandlerConstants.TASK_TYPE_SALES;
        } else if (serviceObjects.contains(objectType)) {
            return TaskHandlerConstants.TASK_TYPE_SERVICE;
        } else {
            return '';
        }
    }
}