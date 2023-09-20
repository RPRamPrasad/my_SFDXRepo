/**
 * @description tests for LogToTaskController
 */
@isTest
(seeAllData=false)
public with sharing class LogToTaskControllerTest {
    
    @testSetup
    private static void testSetup() {
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
    }

    @isTest
    private static void testConvertLogToTaskAsAgent() {
        
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        User atmUser = TestUserSetupUtility.getAtmUser();

        Date newDueDate = Date.today();
        newDueDate = newDueDate.addDays(5);

        Task agentTask;
        Task atmTask;

        boolean isSuccess = false;
        Map<String, Object> saveResult = new Map<String, Object>();

        System.runAs(sysAdminUser) {
            Account testAccount = insertAccount();
            agentTask = TaskTestDataUtility.buildNewLog(testAccount, agentUser.Id);
            atmTask = TaskTestDataUtility.buildNewLog(testAccount, atmUser.Id);
            insert agentTask;
            insert atmTask;
        }

        Map<String, Object> paramMap = new Map<String,Object>();
        paramMap.put('RecordId', agentTask.Id);
        paramMap.put('TaskDate', newDueDate);
        paramMap.put('TaskType', 'Sales');
        paramMap.put('AssignedTo', agentUser.Id);

        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            saveResult = LogToTaskController.convertLogToTask(paramMap);
            LogToTaskController.createChatterPost(String.valueOf(saveResult.get('TaskId')), String.valueOf(saveResult.get('Subject')));
            isSuccess = Boolean.valueOf(saveResult.get('IsSuccess'));
            
        }
        Test.stopTest();

        Task updatedTask = TaskTestDataUtility.retrieveTaskAfterInsert(agentTask.Id);
        System.assert(isSuccess, 'Agent should be able to convert Logs owned by their office into Tasks');
        System.assertEquals(updatedTask.recordTypeId, TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID, 'Log record type was not updated correctly!');
    }
    
    @isTest
    private static void testConvertLogToTaskAsAdmin() {
        
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        User atmUser = TestUserSetupUtility.getAtmUser();

        Date newDueDate = Date.today();
        newDueDate = newDueDate.addDays(5);

        Task agentTask;
        Task atmTask;
        
        boolean isSuccess;
        Map<String, Object> saveResult = new Map<String, Object>();
        Exception expectedException;

        System.runAs(sysAdminUser) {
            Account testAccount = insertAccount();
            agentTask = TaskTestDataUtility.buildNewLog(testAccount, agentUser.Id);
            atmTask = TaskTestDataUtility.buildNewLog(testAccount, atmUser.Id);
            insert agentTask;
            insert atmTask;
        }

        Map<String, Object> paramMap = new Map<String,Object>();
        paramMap.put('RecordId', agentTask.Id);
        paramMap.put('TaskDate', newDueDate);
        paramMap.put('TaskType', 'Service');
        paramMap.put('AssignedTo', 'testId');

        Test.startTest();
        System.runAs(sysAdminUser) {
            try {
                saveResult = LogToTaskController.convertLogToTask(paramMap);
                isSuccess = Boolean.valueOf(saveResult.get('IsSuccess'));
                LogToTaskController.createChatterPost(String.valueOf(saveResult.get('TaskId')), String.valueOf(saveResult.get('Subject')));
            } catch (AuraHandledException ex) {
                expectedException = ex;
            }
        }
        Test.stopTest();

        Task updatedTask = TaskTestDataUtility.retrieveTaskAfterInsert(agentTask.Id);
        System.assertEquals(updatedTask.recordTypeId, TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID, 'Log should not be able to be updated by non-agent-office users!');
    }
    
    private static Account insertAccount() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account account = new Account(FirstName = 'FirstName', LastName = 'LastName', BillingAddressType__c = 'US', ClientIdentifier__c = '12345678909', PersonEmail = 'TEST@EMAIL.COM');
        insert account;
        return account;
    }
}