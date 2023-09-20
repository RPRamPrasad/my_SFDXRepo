/**
 * @description UTIL_CampaignTaskProgress
 */

public with sharing class UTIL_CampaignTaskProgress {
    private static final String CLASS_NAME = 'UTIL_CampaignTaskProgress';
    private static final String UPDATE_CAMPAIGN_TASK_COMPLETION_METHOD_NAME = 'updateCampaignTaskCompletion'; 
    private static Boolean hasTaskInProgress = false;
/**
 * @description updateCampaignTaskCompletion
 * @param newTasks 
 */

    public static void updateCampaignTaskCompletion(List<Task> newTasks){
        Set<String> campaignIds = buildCampaignIdSet(newTasks);
        if(!campaignIds.isEmpty()){
            List<Task> tasks = getTasksFromCampaignIds(campaignIds);
            Map<String,List<Task>> taskMap = createTaskMap(campaignIds, tasks);
            List<Campaign> campaigns = updateCampaignTaskCompletion(taskMap);
            try{
                update Security.stripInaccessible(AccessType.READABLE, campaigns).getRecords();
            } catch(Exception exceptionMessage) {
                LoggingService.logHandledException(exceptionMessage, CLASS_NAME, UPDATE_CAMPAIGN_TASK_COMPLETION_METHOD_NAME, System.LoggingLevel.ERROR);
            } 
        }
    }
    private static List<Task> getTasksFromCampaignIds(Set<String> campaignIds){
        return Security.stripInaccessible(AccessType.READABLE
        , [SELECT id, whatid,Campaign__c, status FROM Task where whatId in :campaignIds limit 5000]).getRecords();
    }
    private static List<Campaign> updateCampaignTaskCompletion(Map<String,List<Task>> taskMap){
        List<Campaign> campaigns = new List<Campaign>();
        for(String campaignId: taskMap.keySet()){
            List<Task> tasks = taskMap.get(campaignId);
            Campaign campaign = new Campaign(id = campaignId);
            Decimal taskProgress = UTIL_CampaignTaskProgress.getCampaignTaskProgress(tasks, campaign);
            campaign.TaskProgress__c = taskProgress;
            if(taskProgress == 100){
                campaign.CurrentPathStep__c = 'tasksCompleted';
            } else if (hasTaskInProgress || taskProgress > 0){
                 campaign.CurrentPathStep__c = 'inProgress';
             }
            campaigns.add(campaign);
        }

        return campaigns;
    }

    private static Map<String,List<Task>> createTaskMap(Set<String> campaignIds, List<Task> tasks){
        Map<String,List<Task>> taskMap = new Map<String,List<Task>>();
        List<Task> tempTaskList;
        for(String campaignId: campaignIds){
            taskMap.put(campaignId, new List<Task>());
        }
        for(Task task: tasks){
            if(task.Campaign__c != null){
                tempTaskList = taskMap.get(task.Campaign__c);
                tempTaskList.add(task);
                taskMap.put(task.Campaign__c, tempTaskList);
            }
        }
        return taskMap;
    }

    private static Decimal getCampaignTaskProgress(List<Task> tasks, Campaign campaign){
        Decimal totalTasks = tasks.size();
        Decimal totalTasksCompleted = 0;
        Decimal percentComplete = 0;
        
        for(Task task: tasks){
            if('Completed'.equalsIgnoreCase(task.Status) || 'Cancelled'.equalsIgnoreCase(task.Status)){
                totalTasksCompleted++;
            }
            if('In Progress'.equalsIgnoreCase(task.Status)) {
                hasTaskInProgress = true;
            }
        }

        if(totalTasks > 0){
            percentComplete = (totalTasksCompleted/totalTasks) * 100;
        }
        return percentComplete;
    }
    private static Set<String> buildCampaignIdSet(List<Task> tasks){
        Set<String> campaignIds = new Set<String>();
        for(Task task: tasks){
            if(task.Campaign__c != null){
                campaignIds.add(task.Campaign__c);
            }
        }
        return campaignIds;
    }
}