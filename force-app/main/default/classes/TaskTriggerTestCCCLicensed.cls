/** 
* @description task trigger test CCC Licensed
* @Owner: Grumpycats
*/
@isTest
(seeAllData=false)
private class TaskTriggerTestCCCLicensed {
    
    private static final String AGENT_ROLE_VALIDATION_ERROR_MESSAGE = Label.ObjectOwnerErrorMessage;
	private static final String TASK_OWNER_NOT_PROXY = 'task Owner was not the proxy';
    private static final String TASK_NOT_RELATED_TO_ACCOUNT ='task was not related to the account';
    private static final String TASK_NOT_DEFAULT = 'task was not a default task';
    private static final String TASK_WHO_NOT_RELATED_TO_ACCOUNT = 'task who was not related to the account';
    private static final String AGENT_ROLE_ERROR_MESSAGE_NOT_IN_EXCEPTION = 'Agent Role check error message was not in the exception';

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
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, proxyUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, TASK_OWNER_NOT_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, TASK_NOT_DEFAULT);
        System.assert(insertResult.WhatId == accountRecord.Id, TASK_NOT_RELATED_TO_ACCOUNT);
        System.assert(insertResult.WhoId == accountRecord.PersonContactId, TASK_WHO_NOT_RELATED_TO_ACCOUNT);
        Test.stopTest();
    }
    @isTest
    private static void testTaskInsertAgentAsOwner(){
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, agentUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, TASK_OWNER_NOT_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, TASK_NOT_DEFAULT);
        System.assert(insertResult.WhatId == accountRecord.Id, TASK_NOT_RELATED_TO_ACCOUNT);
        System.assert(insertResult.WhoId == accountRecord.PersonContactId, TASK_WHO_NOT_RELATED_TO_ACCOUNT);
        Test.stopTest();
    }
    @isTest
    private static void testTaskInsertProxyWithoutAgentRole(){
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        User proxyUserWithoutAgentRole = TestUserSetupUtility.getSecondaryProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        String errorMessage = '';
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, proxyUserWithoutAgentRole.Id);
            try{
                insert taskRecord;
            }catch(Exception ex){
                errorMessage = ex.getMessage();
            }
        }
        System.assert(errorMessage.contains(AGENT_ROLE_VALIDATION_ERROR_MESSAGE), AGENT_ROLE_ERROR_MESSAGE_NOT_IN_EXCEPTION);
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskInsertAgentWithoutAgentRole(){
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        User agentUserWithoutAgentRole = TestUserSetupUtility.getSecondaryAgentUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        String errorMessage = '';
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, agentUserWithoutAgentRole.Id);
            try{
                insert taskRecord;
            }catch(Exception ex){
                errorMessage = ex.getMessage();
            }
        }
        System.assert(errorMessage.contains(AGENT_ROLE_VALIDATION_ERROR_MESSAGE), AGENT_ROLE_ERROR_MESSAGE_NOT_IN_EXCEPTION);
        Test.stopTest();
    }
    
    @isTest
    private static void testNewLogInsert(){
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
            taskRecord = TaskTestDataUtility.buildNewLog(accountRecord, proxyUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, TASK_OWNER_NOT_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID, TASK_NOT_DEFAULT);
        System.assert(insertResult.WhatId == accountRecord.Id, TASK_NOT_RELATED_TO_ACCOUNT);
        System.assert(insertResult.WhoId == accountRecord.PersonContactId, TASK_WHO_NOT_RELATED_TO_ACCOUNT);
        System.assert(insertResult.Log_Call__c, 'log call flag was not set');
        Test.stopTest();
    }
    @isTest
    private static void testNewLogInsertAgentAsOwner(){
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
            taskRecord = TaskTestDataUtility.buildNewLog(accountRecord, agentUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, TASK_OWNER_NOT_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID, TASK_NOT_DEFAULT);
        System.assert(insertResult.WhatId == accountRecord.Id, TASK_NOT_RELATED_TO_ACCOUNT);
        System.assert(insertResult.WhoId == accountRecord.PersonContactId, TASK_WHO_NOT_RELATED_TO_ACCOUNT);
        System.assert(insertResult.Log_Call__c, 'log call flag was not set');
        Test.stopTest();
    }
    @isTest
    private static void testNewLogInsertProxyWithoutAgentRole(){
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        User proxyUserWithoutAgentRole = TestUserSetupUtility.getSecondaryProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        String errorMessage = '';
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
            taskRecord = TaskTestDataUtility.buildNewLog(accountRecord, proxyUserWithoutAgentRole.Id);
            try{
                insert taskRecord;
            }catch(Exception ex){
                errorMessage = ex.getMessage();
            }
        }
        System.assert(errorMessage.contains(AGENT_ROLE_VALIDATION_ERROR_MESSAGE), AGENT_ROLE_ERROR_MESSAGE_NOT_IN_EXCEPTION);
        Test.stopTest();
    }
    
    @isTest
    private static void testNewLogInsertAgentWithoutAgentRole(){
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        User agentUserWithoutAgentRole = TestUserSetupUtility.getSecondaryAgentUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        String errorMessage = '';
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
            taskRecord = TaskTestDataUtility.buildNewLog(accountRecord, agentUserWithoutAgentRole.Id);
            try{
                insert taskRecord;
            }catch(Exception ex){
                errorMessage = ex.getMessage();
            }
        }
        System.assert(errorMessage.contains(AGENT_ROLE_VALIDATION_ERROR_MESSAGE), AGENT_ROLE_ERROR_MESSAGE_NOT_IN_EXCEPTION);
        Test.stopTest();
    }
}