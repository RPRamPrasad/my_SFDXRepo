/** 
* @description task trigger test CCC Unlicensed
* @Owner: Grumpycats
*/
@isTest
(seeAllData=false)
private class TaskTriggerTestCCCUnlicensed {

    private static final String AGENT_ROLE_VALIDATION_ERROR_MESSAGE = Label.ObjectOwnerErrorMessage;
	private static final String AGENT_ROLE_ERROR_MESSAGE = 'agent role check error message was not in the exception';	
    private static final String TASK_WHO_NOT_RELATED_TO_ACC = 'task who was not related to the account';
    private static final String TASK_NOT_RELATED_TO_ACC =  'task was not related to the account';
    private static final String TASK_NOT_DEFAULT =  'task was not a default task';
    private static final String TASK_OWNER_NOT_PROXY = 'task owner was not the proxy';

    
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
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnlicensedUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, proxyUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, TASK_OWNER_NOT_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, TASK_NOT_DEFAULT);
        System.assert(insertResult.WhatId == accountRecord.Id, TASK_NOT_RELATED_TO_ACC);
        System.assert(insertResult.WhoId == accountRecord.PersonContactId, TASK_WHO_NOT_RELATED_TO_ACC);
        Test.stopTest();
    }
    @isTest
    private static void testTaskInsertAgentAsOwner(){
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnlicensedUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, agentUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, TASK_OWNER_NOT_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, TASK_NOT_DEFAULT);
        System.assert(insertResult.WhatId == accountRecord.Id, TASK_NOT_RELATED_TO_ACC);
        System.assert(insertResult.WhoId == accountRecord.PersonContactId, TASK_WHO_NOT_RELATED_TO_ACC);
        Test.stopTest();
    }
    @isTest
    private static void testTaskInsertProxyWithoutAgentRole(){
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnlicensedUser();
        User proxyUserWithoutAgentRole = TestUserSetupUtility.getSecondaryProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        String errorMessage = '';
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, proxyUserWithoutAgentRole.Id);
            try{
                insert taskRecord;
            }catch(Exception ex){
                errorMessage = ex.getMessage();
            }
        }
        System.assert(errorMessage.contains(AGENT_ROLE_VALIDATION_ERROR_MESSAGE), AGENT_ROLE_ERROR_MESSAGE);
        Test.stopTest();
    }
    
    @isTest
    private static void testTaskInsertAgentWithoutAgentRole(){
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnlicensedUser();
        User agentUserWithoutAgentRole = TestUserSetupUtility.getSecondaryAgentUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        String errorMessage = '';
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
            taskRecord = TaskTestDataUtility.buildTask(accountRecord, agentUserWithoutAgentRole.Id);
            try{
                insert taskRecord;
            }catch(Exception ex){
                errorMessage = ex.getMessage();
            }
        }
        System.assert(errorMessage.contains(AGENT_ROLE_VALIDATION_ERROR_MESSAGE), AGENT_ROLE_ERROR_MESSAGE);
        Test.stopTest();
    }
    
    @isTest
    private static void testNewLogInsert(){
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnlicensedUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
            taskRecord = TaskTestDataUtility.buildNewLog(accountRecord, proxyUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, TASK_OWNER_NOT_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID, TASK_NOT_DEFAULT);
        System.assert(insertResult.WhatId == accountRecord.Id, TASK_NOT_RELATED_TO_ACC);
        System.assert(insertResult.WhoId == accountRecord.PersonContactId, TASK_WHO_NOT_RELATED_TO_ACC);
        System.assert(insertResult.Log_Call__c, 'log call flag was not set');
        Test.stopTest();
    }
    @isTest
    private static void testNewLogInsertAgentAsOwner(){
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnlicensedUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
            taskRecord = TaskTestDataUtility.buildNewLog(accountRecord, agentUser.Id);
            insert taskRecord;
        }
        Task insertResult = TaskTestDataUtility.retrieveTaskAfterInsert(taskRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, TASK_OWNER_NOT_PROXY);
        System.assert(insertResult.RecordTypeId == TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID, TASK_NOT_DEFAULT);
        System.assert(insertResult.WhatId == accountRecord.Id, TASK_NOT_RELATED_TO_ACC);
        System.assert(insertResult.WhoId == accountRecord.PersonContactId, TASK_WHO_NOT_RELATED_TO_ACC);
        System.assert(insertResult.Log_Call__c, 'log call flag was not set');
        Test.stopTest();
    }
    @isTest
    private static void testNewLogInsertProxyWithoutAgentRole(){
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnlicensedUser();
        User proxyUserWithoutAgentRole = TestUserSetupUtility.getSecondaryProxyUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        String errorMessage = '';
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
            taskRecord = TaskTestDataUtility.buildNewLog(accountRecord, proxyUserWithoutAgentRole.Id);
            try{
                insert taskRecord;
            }catch(Exception ex){
                errorMessage = ex.getMessage();
            }
        }
        System.assert(errorMessage.contains(AGENT_ROLE_VALIDATION_ERROR_MESSAGE), AGENT_ROLE_ERROR_MESSAGE);
        Test.stopTest();
    }
    
    @isTest
    private static void testNewLogInsertAgentWithoutAgentRole(){
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnlicensedUser();
        User agentUserWithoutAgentRole = TestUserSetupUtility.getSecondaryAgentUser();
        Account accountRecord = TaskTestDataUtility.getAccount();
        Task taskRecord = new Task();
        String errorMessage = '';
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
            taskRecord = TaskTestDataUtility.buildNewLog(accountRecord, agentUserWithoutAgentRole.Id);
            try{
                insert taskRecord;
            }catch(Exception ex){
                errorMessage = ex.getMessage();
            }
        }
        System.assert(errorMessage.contains(AGENT_ROLE_VALIDATION_ERROR_MESSAGE), AGENT_ROLE_ERROR_MESSAGE);
        Test.stopTest();
    }
    
}