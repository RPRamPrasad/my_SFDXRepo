/** 
* @description task trigger test TaskAPI
* @Owner: Grumpycats
*/
@isTest
(seeAllData=false)
private class TaskTriggerTestAPI {

    @testSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            TaskTestDataUtility.createAccount();
            TaskTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), TaskTestDataUtility.getAccount());
            TaskTestDataUtility.addUserToTaskAPIPermSet(TestUserSetupUtility.getApiOnlyUser());
        }
    }
    
    @isTest
    private static void testBulkTaskInsert(){
        User taskAPI = TestUserSetupUtility.getApiOnlyUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Test.startTest();
        List<Task> taskList = new List<Task>();
        System.runAs(taskAPI){
            Task newLog = TaskTestDataUtility.buildNewLog(accountRecord, proxyUser.Id);
            Task newLogClone = newLog.clone();
            Task taskRecord = TaskTestDataUtility.buildTask(accountRecord, proxyUser.Id);
            taskRecord.Status = TaskHandlerConstants.TASK_STATUS_NOT_STARTED;
            Task taskRecordClone = taskRecord.clone();
            taskList.add(taskRecord);
            taskList.add(taskRecordClone);
            taskList.add(newLog);
            taskList.add(newLogClone);
            insert taskList;
        }
        List<Task> insertResults = TaskTestDataUtility.retrieveTaskListAfterInsert(taskList);
        System.assert(insertResults.size() == 4, 'all 4 task were not inserted');
        Integer logCount = 0;
        Integer taskCount = 0;
        for(Task taskRecord : insertResults){
            if(taskRecord.RecordTypeId == TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID){
                taskCount = taskCount + 1;
               	System.assert(taskRecord.OwnerId == proxyUser.Id, 'owner was not the proxy');
                System.assert(taskRecord.Status == TaskHandlerConstants.TASK_STATUS_NOT_STARTED, 'status was not set to not started');
                System.assert(!taskRecord.Log_Call__c, 'normal task has the log call flag');
                System.assert(taskRecord.AssignedTo__c == null, 'task api assigned the task to someone');
            }else if(taskRecord.RecordTypeId == TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID){
                logCount = logCount + 1;
                System.assert(taskRecord.OwnerId == proxyUser.Id, 'owner was not the proxy');
                System.assert(taskRecord.Status == TaskHandlerConstants.TASK_STATUS_COMPLETED, 'status was not set to completed');
                System.assert(taskRecord.Log_Call__c, 'log does not have the log call flag');
                System.assert(taskRecord.AssignedTo__c == null, 'task api assigned the task to someone');
                System.assert(taskRecord.TaskSubtype == 'Call', 'task is not subtype call');
            }
        }
        System.assert(taskCount == 2, 'unexpected number of tasks');
        System.assert(logCount == 2, 'unexpected number of logs');
        Test.stopTest();
    }
    
}