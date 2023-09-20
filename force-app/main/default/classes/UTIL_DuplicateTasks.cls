/**
@Author: Team Dream Builders
@description This class is responsible for duplicating tasks from existing Account and relating opportunities
to the new Account from customer separate processor.
@Version <1.0>
@Author: Loco Motivated
@description This class is responsible for duplicating tasks from existing Account and relating opportunities
to the new Account from customer separate processor. Updated for Refactoring.
@Version <1.5>

@Author: Club-Car - Added functionality to handle seperate of tasks from cases, as case object is enabled as part of CCC
@ModifiedDate: 7/14/2017
*/
public without sharing class UTIL_DuplicateTasks {
    private static final String TASK_STRING = 'Task';
    private static final String TRACKED_CHANGE = 'TrackedChange';
    private static final String NOTE = ' “ THIS IS THE BODY OF FEED  THAT WAS ORIGINALLY CAPTURED – ';

    /**
    * @description Associating Tasks from Original Opportunity to New Opportunity
    * @name duplicateTasksOnOpportunits
    * @param opportunitsWrapper
    * @return Map<ID, Task>
    */
    public static Map<ID, Task> duplicateTasksOnOpportunits(DuplicateTasksWrapperList opportunitsWrapper) {
        Account originalAccount = opportunitsWrapper.originalAccount;
        Account newAccount = opportunitsWrapper.newAccount;
        List<Opportunity> originalOpportunityList = opportunitsWrapper.originalOpportunityList;
        Map<Id,Opportunity> addedNewOpportunitysMap = opportunitsWrapper.addedNewOpportunitysMap;
        Map<ID, List<Task>> originalOpportunityTaskMap = new Map<ID, List<Task>>();
        List<Task> originalOpportunityTaskList = new List<Task>();
        List<ID> lOriginalAccOptyIDs = new List<ID>();
        Map<ID, Task> allNewTaskMap = new Map<ID, Task>();

        sObjectType taskType = Schema.getGlobalDescribe().get(TASK_STRING);
        Map<String,Schema.SObjectField> taskfieldsMap = taskType.getDescribe().fields.getMap();
        String selectQuery = 'Select ';
        for (String fieldName : taskfieldsMap.keySet()) {
            selectQuery+= fieldName+' , ';
        }
        for(Opportunity orginalOpportunity : originalOpportunityList){
            lOriginalAccOptyIDs.add(orginalOpportunity.id);
        }

        Id originalAccountContactID= originalAccount.PersonContactId;
        Id newAccountContactID= newAccount.PersonContactId;
        selectQuery = selectQuery.substringBeforeLast(', ')+ ' from Task where (AccountID = \''+String.escapeSingleQuotes(originalAccount.Id)+'\' OR WhoID = \''+String.escapeSingleQuotes(originalAccountContactID)+'\' ) And IsClosed=false And WhatId IN : lOriginalAccOptyIDs AND TaskCategory__c != \''+String.escapeSingleQuotes('SignedWrittenConsent')+'\' AND AppCode__c != \''+String.escapeSingleQuotes('SFDC_MKTCLD')+'\'';

        originalOpportunityTaskList = Database.query(selectQuery);
        originalOpportunityTaskMap = setupTaskMap(originalOpportunityTaskList);

        Map<Id, Id> addedNewOpportunityIdsMap = new Map<Id, Id>();
        for(Id mapKey : addedNewOpportunitysMap.keySet()) {
            addedNewOpportunityIdsMap.put(mapKey, addedNewOpportunitysMap.get(mapKey).Id);
        }

        for(Opportunity originalOpportunity : originalOpportunityList) {
            if(originalOpportunityTaskMap.get(originalOpportunity.Id) != null) {
                TaskWrapperList prepareTaskWrap = new TaskWrapperList();
		            prepareTaskWrap.originalAccountContactID = originalAccountContactID;
		            prepareTaskWrap.newAccountContactID = newAccountContactID;
		            prepareTaskWrap.originalWhatId = originalOpportunity.Id;
		            prepareTaskWrap.originalWhatTaskMap = originalOpportunityTaskMap;
		            prepareTaskWrap.addedNewWhatsMap = addedNewOpportunityIdsMap;
	            allNewTaskMap.putAll(prepareTask(prepareTaskWrap));
            }
        }
        if(!allNewTaskMap.isEmpty()) {
            UTIL_TaskDAO.insertTasks(allNewTaskMap.values());
            prepareTaskRelationForTask(newAccountContactID, allNewTaskMap, originalAccountContactID);
            createTaskFeeds(allNewTaskMap, originalOpportunityTaskList);
        }
        return allNewTaskMap;
    }

    /**
     * @description duplicate tasks wrapper list
     */
    public class DuplicateTasksWrapperList{
		public Account originalAccount;
		public Account newAccount;
		public List<Opportunity> originalOpportunityList;
		public Map<Id,Opportunity> addedNewOpportunitysMap;
	}

    /**
     * @description This method prepares a map of Task Ids and lists of Tasks
     * @name setupTaskMap
     * @param originalTaskList
     * @return Map<ID, List<Task>> originalTaskMap returns a map which holds lists of Tasks
     */
    private static Map<ID, List<Task>> setupTaskMap(List<Task> originalTaskList) {
        Map<ID, List<Task>> originalTaskMap = new Map<ID, List<Task>>();

        for(Task task : originalTaskList) {
            if(!originalTaskMap.containsKey(task.whatID)) {
                originalTaskMap.put(task.whatID, new List<Task>());
                originalTaskMap.get(task.whatID).add(task);
            } else {
                originalTaskMap.get(task.whatID).add(task);
            }
        }
        return originalTaskMap;
    }
    /**
    * @description This method used to preapre a new Task object and inserting into a map objects with orginal task ID as key for further implementation
    * @name prepareTask
    * @param prepareTasksWrapper
    * @return Map<ID, Task> map-retruns a map which holds a new task
    *
    */
    private static Map<ID, Task> prepareTask(TaskWrapperList prepareTasksWrapper) {
        ID originalAccountContactID = prepareTasksWrapper.originalAccountContactID;
        ID newAccountContactID = prepareTasksWrapper.newAccountContactID;
        ID originalWhatId = prepareTasksWrapper.originalWhatId;
        Map<ID, List<Task>> originalWhatTaskMap = prepareTasksWrapper.originalWhatTaskMap;
        Map<Id,Id> addedNewWhatsMap = prepareTasksWrapper.addedNewWhatsMap;
        Map<ID, Task> newTaskMap = new Map<ID, Task>();

        for(Task originalTask :originalWhatTaskMap.get(originalWhatId)) {
            Task newTask = originalTask.clone();
            newTask.WhatID = addedNewWhatsMap.get(originalWhatId);
            if(UTIL_SeparateProcessor.isWhoIDWithOldAccount(originalTask.WhoId,originalAccountContactID)){
                 newTask.WhoId=newAccountContactID;
            }
            newTaskMap.put(originalTask.Id, newTask);
        }
        return newTaskMap;
    }

    /**
     * @description task wrapper list
     */
    public class TaskWrapperList{
		public ID originalAccountContactID;
		public ID newAccountContactID;
		public ID originalWhatId;
		public Map<ID, List<Task>> originalWhatTaskMap;
		public Map<Id,Id> addedNewWhatsMap;
	}

    /**
    * @description Associating Tasks from Original Case to New Case
    * @name duplicateTasksOnCases
    * @param taskOnCaseWrapper
    * @return Map<ID, Task>
    */
    public static Map<ID, Task> duplicateTasksOnCases(CasesWrapperList taskOnCaseWrapper) {
        Account originalAccount = taskOnCaseWrapper.originalAccount;
        Account newAccount = taskOnCaseWrapper.newAccount;
        List<Case> originalCasesList = taskOnCaseWrapper.originalCasesList;
        Map<Id,Case> addedNewCasesMap = taskOnCaseWrapper.addedNewCasesMap;
        Map<ID, List<Task>> originalCaseTaskMap = new Map<ID, List<Task>>();
        List<Task> orginalCasesTaskList = new List<Task>();
        List<ID> lOriginalAccCaseIDs = new List<ID>();
        Map<ID, Task> allNewTaskMap = new Map<ID, Task>();

        sObjectType taskType = Schema.getGlobalDescribe().get(TASK_STRING);
        Map<String,Schema.SObjectField> taskfieldsMap = taskType.getDescribe().fields.getMap();
        String selectQuery = 'Select ';
        for (String fieldName : taskfieldsMap.keySet()) {
            selectQuery+= fieldName+' , ';
        }
        for(Case orginalCase : originalCasesList){
            lOriginalAccCaseIDs.add(orginalCase.id);
        }
        Id originalAccountContactID= originalAccount.PersonContactId;
        Id newAccountContactID= newAccount.PersonContactId;
        selectQuery = selectQuery.substringBeforeLast(', ')+ ' from Task where IsClosed=false And WhatId IN : lOriginalAccCaseIDs';
        orginalCasesTaskList = Database.query(String.escapeSingleQuotes(selectQuery));
        originalCaseTaskMap = setupTaskMap(orginalCasesTaskList);

        Map<Id, Id> addedNewCaseIdsMap = new Map<Id, Id>();
        for(Id mapKey : addedNewCasesMap.keySet()) {
            addedNewCaseIdsMap.put(mapKey, addedNewCasesMap.get(mapKey).Id);
        }

        for(Case originalCase : originalCasesList) {
            if(originalCaseTaskMap.get(originalCase.Id) != null) {
                TaskWrapperList tasksWrap = new TaskWrapperList();
		            tasksWrap.originalAccountContactID = originalAccountContactID;
		            tasksWrap.newAccountContactID = newAccountContactID;
		            tasksWrap.originalWhatId = originalCase.Id;
		            tasksWrap.originalWhatTaskMap = originalCaseTaskMap;
		            tasksWrap.addedNewWhatsMap = addedNewCaseIdsMap;
	            allNewTaskMap.putAll(prepareTask(tasksWrap));
            }
        }
        if(!allNewTaskMap.isEmpty()) {
            UTIL_TaskDAO.insertTasks(allNewTaskMap.values());
            prepareTaskRelationForTask(newAccountContactID, allNewTaskMap, originalAccountContactID);
            createTaskFeeds(allNewTaskMap, orginalCasesTaskList);
        }
        return allNewTaskMap;
    }

    /**
     * @description cases wrapper list
     */
    public class CasesWrapperList{
		public Account originalAccount;
		public Account newAccount;
		public List<Case> originalCasesList;
		public Map<Id,Case> addedNewCasesMap;
	}

    /**
    * @description This method used to preapre  TaskRelation for newly created task's which are related to an opportunities
    * @name prepareTaskRelationForTask
    * @param newAccountContactID - New Account contact ID
    * @param newTaskMap - map which holds newly created Task's
    * @param originalAccountContactID - original Account contact ID
    */
    public static void prepareTaskRelationForTask(ID newAccountContactID, Map<ID, Task> newTaskMap, ID originalAccountContactID) {
        List<TaskRelation> newTasksRelationList = new List<TaskRelation>();
        String originalAccountContact = originalAccountContactID;
        Set<ID> newTaskIds = newTaskMap.keySet();
        Map<ID, List<TaskRelation>> taskRelationMap = new Map<Id, List<TaskRelation>>();

        for (Id newTaskId : newTaskIds) {
            taskRelationMap.put(newTaskId, new List<TaskRelation>());
        }
        List<TaskRelation> taskRelationsAll = new List<TaskRelation>([Select RelationId,AccountId,TaskID From TaskRelation where
                                                                            isWhat = false AND (RelationId<>: originalAccountContact )
                                                                            AND taskID IN :newTaskIds]);

        for (TaskRelation taskRelation : taskRelationsAll) {
            List<TaskRelation> taskRelations = taskRelationMap.get(taskRelation.TaskId);
            Task newTask = newTaskMap.get(taskRelation.TaskId);
            if (taskRelation.RelationId != newTask.WhoId) {
                taskRelations.add(taskRelation);
            }
            taskRelationMap.put(taskRelation.TaskId, taskRelations);
        }
        for (Id orginalTaskId : newTaskMap.keySet()) {
            Task newTask = newTaskMap.get(orginalTaskId);
            newTasksRelationList.addAll(copyFromOrginalTaskRelationForContacts(taskRelationMap.get(orginalTaskId), newTask));
        }
        if(!newTasksRelationList.isEmpty()) {
            UTIL_TaskRelationDAO.insertTaskRelations(newTasksRelationList);
        }
    }

    /**
    * @description This method used to copy the TaskRelation data from original TaskRelation which are belongs to original task
    * @name copyFromOrginalTaskRelationForContacts
    * @param originalTaskRelationList - List<TaskRelation>
    * @param newTask - New Task
    * @return List<TaskRelation>
    */
     private static List<TaskRelation> copyFromOrginalTaskRelationForContacts(List<TaskRelation> originalTaskRelationList, Task newTask) {
         List<TaskRelation> newTaskRelation = new List<TaskRelation>();
         for (TaskRelation orginalTaskRelation:originalTaskRelationList) {
             newTaskRelation.Add(New TaskRelation(RelationId = orginalTaskRelation.RelationId, Taskid = newTask.Id, isWhat = false));
         }
         return newTaskRelation;
     }

    /**
    * @description This method creates task feed for the new task
    * @name createTaskFeeds
    * @param newTaskMap - Task map -  key (Original Task ID), Value (New Task)
    * @param originalTasksList - List of Original Task
    */
    public static void createTaskFeeds(Map<ID,Task> newTaskMap, List<Task> originalTasksList) {
        Map<ID, List<FeedItem>> mlOriginalTaskFeeds = new Map<ID, List<FeedItem>>();
        List<FeedItem> lNewFeedItem = new List<FeedItem>();
        for(FeedItem feeds :UTIL_DuplicateTasks.retrieveFeedItems(newTaskMap.keySet())) {
            if(!mlOriginalTaskFeeds.containsKey(feeds.ParentID)) {
                mlOriginalTaskFeeds.put(feeds.ParentID, new List<FeedItem>());
                mlOriginalTaskFeeds.get(feeds.ParentID).add(feeds);
            } else {
                mlOriginalTaskFeeds.get(feeds.ParentID).add(feeds);
            }
        }
        for(Task orignalTask : originalTasksList) {
            if(mlOriginalTaskFeeds.containsKey(orignalTask.Id)) {
                lNewFeedItem.addAll(populateFeedItemList(mlOriginalTaskFeeds.get(orignalTask.Id), orignalTask.Id, newTaskMap));
            }
        }
        if(!lNewFeedItem.isEmpty()) {
             UTIL_FeedItemDAO.insertFeedItems(lNewFeedItem);
        }
    }
    /**
    * @description This helper method creates the new FeedItems to  New Task under new Account
    * @name populateFeedItemList
    * @param taskFeeds -  List of TaskFeeds
    * @param taskId
    * @param newTaskMap -  Map of orginal Tasks
    * @return List<FeedItem>
    */
    private static List<FeedItem> populateFeedItemList (List<FeedItem> taskFeeds, Id taskId, Map<ID,Task> newTaskMap) {
        List<FeedItem> newFeedItemList = new List<FeedItem>();
        for(FeedItem originalFeed : taskFeeds) {
            if(!String.isEmpty(originalFeed.Body)) {
                newFeedItemList.add(UTIL_DuplicateTasks.cloneTaskFeed(originalFeed, newTaskMap.get(taskId).Id));
            }
        }
        return newFeedItemList;
    }

    /**
    * @description This method is used to retrieve all feed items based on parent ID
    * @name retrieveFeedItems
    * @param parentIDs
    * @return List<FeedItem>
    */
    public static List<FeedItem> retrieveFeedItems(Set<ID> parentIDs) {
        List <FeedItem> originalFeedItems = [SELECT BestCommentId, Body, HasContent, HasLink, LinkUrl, RelatedRecordId, Revision, Title, ID, ParentID, IsRichText,LastEditById,LastEditDate,
                                             Type, createdDate,createdBy.firstname, createdBy.lastname FROM FeedItem WHERE ParentID in :parentIDs and
                                             Type!=:TRACKED_CHANGE WITH SECURITY_ENFORCED order by CreatedDate];
        return originalFeedItems;
    }

    /**
    * @description This method is used to colone the feeditem object and append with new parent ID
    * @name cloneTaskFeed
    * @param originalFeed -FeedItem
    * @param newParentID -String
    * @return - FeedItem
    */
    public static FeedItem cloneTaskFeed(FeedItem originalFeed, ID newParentID) {
        FeedItem  newFeedItem = originalFeed.clone();
        newFeedItem.ParentId = newParentID;
        newFeedItem.Body = newFeedItem.Body + NOTE + originalFeed.createdBy.firstname + ' ' + originalFeed.createdBy.lastname + ' ' + originalFeed.CreatedDate.format()+' "';

        return newFeedItem;
    }

}