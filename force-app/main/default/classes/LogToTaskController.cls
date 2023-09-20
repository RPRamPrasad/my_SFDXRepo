/** * @description aura controller for convert log to task component */
public with sharing class LogToTaskController {

    private static final String CLASS_NAME = 'LogToTaskController';

    /**
     * @description Method to convert a Log to a Task and set the due date
     * @param paramMap contains required fields for new task
     * @return resultObject Contains success boolean, Task Id, and Original Subject
    */
    @AuraEnabled
    public static Map<String, Object> convertLogToTask(Map<String, Object> paramMap) {
        boolean isSuccess = false;
        Map<String, Object> resultObject = new Map<String, Object>();

        try {
            List<Task> taskList = getCurrentLog(String.valueOf(paramMap.get('RecordId')));
            if(!taskList.isEmpty()){
                List<Task> tasksToUpdate = new List<Task>();
                Task logToConvert = taskList[0];
                
                if(logToConvert.IsOwnerProxyofCurrentUser__c) {
                    logToConvert.RecordTypeId = TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID;
                    logToConvert.ActivityDate = Date.valueOf(String.valueOf(paramMap.get('TaskDate')));
                    logToConvert.Status = 'Not Started';
                    logToConvert.Log_Title__c = '';
                    logToConvert.Log_Call__c = false;
                    logToConvert.CreatedClosed__c = false;
                    logToConvert.Task_Type__c = String.valueOf(paramMap.get('TaskType'));
                    logToConvert.AssignedTo__c = String.valueOf(paramMap.get('AssignedTo'));
                    
					tasksToUpdate.add(logToConvert);                    
                } else {
                    resultObject.put('IsSuccess', false);
                    return resultObject;
                }
                
                Database.SaveResult saveResult = Database.update(Security.stripInaccessible(AccessType.UPDATABLE, tasksToUpdate, true).getRecords(), true).get(0);
                isSuccess = saveResult.isSuccess();
                resultObject.put('IsSuccess', isSuccess);

                if(isSuccess){
                    resultObject.put('TaskId', saveResult.getId());
                    resultObject.put('Subject', logToConvert.Subject);
                }
            }
        } catch (Exception e) {
           LoggingService.logHandledException(e, CLASS_NAME, 'convertLogToTask', LoggingLevel.ERROR);
           throw new AuraHandledException('Unable to convert Log to Task');
        }
        return resultObject;
    }

    /**
     * @description Method to create chatter post on newly created task that captures the who/when of conversion
     * @param Id Task ID for associated chatter post
     * @param originalSubject Subject of original log before conversion took place
     * @return FeedItem Newly created chatter post
    */
    @AuraEnabled public static FeedItem createChatterPost(Id taskId, String originalSubject){
        FeedItem post = new FeedItem();
        post.ParentId = taskId;
        String username = UserInfo.getName();
        String currentTime = System.now().format('MM/dd/YYYY hh:mm a');
        String body = 'Original Subject Line: ' + originalSubject + '\r\n Conversion Date: ' + currentTime + '\r\n Converted By: ' + username;
        post.Body = body;

        try {
            UTIL_FeedItemDAO.insertFeedItems(new List<FeedItem>{post});
        }
        catch(Exception e){
            LoggingService.logHandledException(e, CLASS_NAME, 'createChatterPost', LoggingLevel.ERROR);
            throw new AuraHandledException('Unable to create chatter post');
        }
        
        return post;
    }

    @TestVisible private static List<Task> getCurrentLog(Id recordId){
        List<Task> logList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, ActivityDate, Status, Subject, Log_Call__c, Log_Title__c, CreatedClosed__c, IsOwnerProxyofCurrentUser__c, Task_Type__c, AssignedTo__c FROM Task WHERE Id =: recordId LIMIT 1]).getRecords();

        return logList;
    }
}