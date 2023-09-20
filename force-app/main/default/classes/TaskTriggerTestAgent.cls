/** 
* @description task trigger test Agent
* @Owner: Grumpycats
*/
@isTest
(seeAllData=false)
private class TaskTriggerTestAgent {
    private static final String OWNER_NOT_CHANGED_PROXY = 'owner has not been changed to the proxy';
	@testSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            TaskTestDataUtility.createAccount();
            TaskTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), TaskTestDataUtility.getAccount());
        }
    }
    
    @isTest
    private static void testTaskInsert(){
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, agentUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, OWNER_NOT_CHANGED_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, 'record type was not set to the default task record type');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskUpdate(){
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, agentUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, OWNER_NOT_CHANGED_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, 'record type was not set to the default task record type');
        String updatedSubject = 'testing task update by agent';
        System.runAs(agentUser){
            insertResult.Subject = updatedSubject;
            update insertResult;
        }
        Task updateResult = TaskTestDataUtility.retrieveTaskAfterInsert(insertResult);
        System.assert(updateResult.Subject == updatedSubject, 'subject was not updated');
        System.assert(updateResult.OwnerId == proxyUser.Id, OWNER_NOT_CHANGED_PROXY);
        System.assert(updateResult.RecordTypeId == TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, 'record type was not set to the default task record type');
        Test.stopTest();
    }
    
    @isTest
    private static void testNewLogInsert(){
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            taskRecord = TaskTestDataUtility.buildNewLog(accountRecord, agentUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        String logTitle = insertResult.Log_Title__c;
        String contactType = insertResult.Contact_Type__c;
        
        System.assert(insertResult.OwnerId == proxyUser.Id, OWNER_NOT_CHANGED_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID, 'record type was not set to the log call record type');
        System.assert(insertResult.Subject.contains(logTitle), 'log title was not put into the log subject');
        System.assert(insertResult.Subject.contains(contactType), 'contact Type was not put into the log subject');
        System.assert(insertResult.Log_Call__c, 'log call flag was not set to true');
        Test.stopTest();
    }
    
    @isTest
    private static void testNewLogUpdate(){
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            taskRecord = TaskTestDataUtility.buildNewLog(accountRecord, agentUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, OWNER_NOT_CHANGED_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID, 'record type was not set to the log call record type');
        System.runAs(agentUser){
            insertResult.Priority = TaskHandlerConstants.TASK_PRIORITY_HIGH;
            update insertResult;
        }
        Task updateResult = TaskTestDataUtility.retrieveTaskAfterInsert(insertResult);
        System.assert(updateResult.Priority == TaskHandlerConstants.TASK_PRIORITY_HIGH, 'task priority was not updated');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskCreateWithAgentNoAgentRole(){
        Account accountRecord = TaskTestDataUtility.getAccount();
        User agentUser1 = TestUserSetupUtility.getAgentUser(); // owns the account
        User agentUser2 = TestUserSetupUtility.getSecondaryAgentUser();
        String errorMsg = '';
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser1,agentUser2});
        System.runAs(agentUser1){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, agentUser1.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        String updatedSubject = 'testing task update by agent2';
        
        System.runAs(agentUser2){
            insertResult.Subject = updatedSubject;
            try{
            	update insertResult;
            }catch(Exception ex){
                errorMsg = ex.getMessage();
            }
        }
        System.assert(errorMsg.length()>0, 'No error message');
        Test.stopTest();
    }
}