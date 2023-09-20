/** 
* @description task trigger test ATM
* @Owner: Grumpycats
*/
@isTest
(seeAllData=false)
private class TaskTriggerTestATM {
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
        User atmUser = TestUserSetupUtility.getAtmUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUser);
        System.runAs(atmUser){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, atmUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, OWNER_NOT_CHANGED_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, 'record type was not set to the default task record type');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskUpdate(){
        User atmUser = TestUserSetupUtility.getAtmUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUser);
        System.runAs(atmUser){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, atmUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, OWNER_NOT_CHANGED_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, 'record type was not set to the default task record type');
        String updatedSubject = 'testing task update by agent';
        System.runAs(atmUser){
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
        User atmUser = TestUserSetupUtility.getAtmUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUser);
        System.runAs(atmUser){
            taskRecord = TaskTestDataUtility.buildNewLog(accountRecord, atmUser.Id);
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
        User atmUser = TestUserSetupUtility.getAtmUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUser);
        System.runAs(atmUser){
            taskRecord = TaskTestDataUtility.buildNewLog(accountRecord, atmUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, OWNER_NOT_CHANGED_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID, 'record type was not set to the log call record type');
        System.runAs(atmUser){
            insertResult.Priority = TaskHandlerConstants.TASK_PRIORITY_HIGH;
            update insertResult;
        }
        Task updateResult = TaskTestDataUtility.retrieveTaskAfterInsert(insertResult);
        System.assert(updateResult.Priority == TaskHandlerConstants.TASK_PRIORITY_HIGH, 'task priority was not updated');
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskCreateWithATMNoATMRole(){
        Account accountRecord = TaskTestDataUtility.getAccount();
        User atmUser1 = TestUserSetupUtility.getAtmUser(); 
        User atmUser2 = TestUserSetupUtility.getSecondaryAtmUser();
        String errorMsg = '';
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{atmUser1,atmUser2});
        // ATM1 creates and inserts a task
        System.runAs(atmUser1){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, atmUser1.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        String updatedSubject = 'testing task update by ATM2';
        
        // ATM2 edits this task and gets an error
        System.runAs(atmUser2){
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