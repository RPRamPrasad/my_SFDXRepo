@IsTest(SeeAlldata=false)
public class CMP_CaseStatusUpdateController_Test {
    private static User agentUser;
    private static User systemAdminUser;
    
    private static final String CASE_NEW_STATUS = 'New';
    private static final String CASE_CLOSED_STATUS = 'Closed';
    private static final String CASE_PENDING_STATUS = 'Pending';
    private static final String CASE_NOT_ASSIGNED_ERROR = 'Case must be assigned before moving to Pending.';

    
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    /**
     * @description testSetupData
     */
    @testsetup
    public static void testSetupData() {        
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID); 
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        agentUser = UTIL_UserProvisioning_TEST.setUpAgentUser();
    }
    
        /**
	* @description getUsers method used for retrieving test users (must be called at beginning of test)
	* @name   getUsers
	*/
    public static void getUsers(){
        agentUser = [SELECT Id, Associate_ID__c, username from User where Username = 'verifytaskAgent123@statefarm.com.bad'];
        systemAdminUser = [SELECT Id, username from User where Username=:SYSADMIN_USER_ID];
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
    }
    @isTest
    private static void testSwitchToNewStatusUnassigned() {
        getUsers();
       
        Case newCase;
        system.runAs(systemAdminUser){
            newCase= new Case(Status = CASE_PENDING_STATUS, AgentAssociateId__c = agentUser.Associate_ID__c, ownerId = agentUser.Id, Assigned_To__c = null, ContactId = UTIL_CaseTestData.contactId());
            insert newCase;
        }
                
        Test.startTest();
        String statusString;
        system.runAs(agentUser) {
            String desiredStatus = CASE_NEW_STATUS;
            statusString = CMP_CaseStatusUpdateController.updateStage(newcase.Id, desiredStatus);
        }
        System.AssertEquals('', statusString, 'Expected value is empty, but actual value is '+statusString);
        Case c = retrieveCase(newcase.Id);  
        System.AssertEquals(CASE_NEW_STATUS, c.Status ,'Expected value is '+CASE_NEW_STATUS+', but actual value is '+c.Status);
        Test.stopTest();      
    }
    @isTest
    private static void testSwitchToNewStatusAssigned() {
        getUsers();
       
        Case newCase;
        system.runAs(systemAdminUser){
            newCase= new Case(Status = CASE_PENDING_STATUS, AgentAssociateId__c = agentUser.Associate_ID__c, ownerId = agentUser.Id, Assigned_To__c = agentUser.Id, ContactId = UTIL_CaseTestData.contactId());
            insert newCase;
        }
                
        Test.startTest();
        String statusString;
        system.runAs(agentUser) {
            String desiredStatus = CASE_NEW_STATUS;
            statusString = CMP_CaseStatusUpdateController.updateStage(newcase.Id, desiredStatus);
        }
        System.AssertEquals('', statusString, 'Expected value is empty, but actual value is '+statusString);
        Case c = retrieveCase(newcase.Id);  
        System.AssertEquals(CASE_NEW_STATUS, c.Status, 'Expected value is '+CASE_NEW_STATUS+', but actual value is '+c.Status);
        System.AssertEquals(null, c.Assigned_To__c, 'Expected value is null, but actual value is '+c.Assigned_To__c);
        Test.stopTest();      
    }
    @isTest
    private static void testSwitchToPendingStatusAssigned() {
        getUsers();

        
        Case newCase;
        system.runAs(systemAdminUser){
            newCase= new Case(Status = CASE_NEW_STATUS, AgentAssociateId__c = agentUser.Associate_ID__c, ownerId = agentUser.Id, Assigned_To__c = agentUser.Id, ContactId = UTIL_CaseTestData.contactId());
            insert newCase;
        }
                
        Test.startTest();
        String statusString;
        system.runAs(agentUser) {
            String desiredStatus = CASE_PENDING_STATUS;
            statusString = CMP_CaseStatusUpdateController.updateStage(newcase.Id, desiredStatus);
        }
        System.AssertEquals('', statusString, 'Expected value is empty, but actual value is '+statusString);
        Case c = retrieveCase(newcase.Id);  
        System.AssertEquals(CASE_PENDING_STATUS, c.Status,'Expected value is '+CASE_PENDING_STATUS+', but actual value is '+c.Status );
        Test.stopTest();      
    }
    @isTest
    private static void testSwitchToPendingStatusUnassigned() {
        getUsers();

        
        Case newCase;
        system.runAs(systemAdminUser){
            newCase= new Case(Status = CASE_NEW_STATUS, AgentAssociateId__c = agentUser.Associate_ID__c, ownerId = agentUser.Id, Assigned_To__c = null, ContactId = UTIL_CaseTestData.contactId());
            insert newCase;
        }
                
        Test.startTest();
        String statusString;
        system.runAs(agentUser) {
            String desiredStatus = CASE_PENDING_STATUS;
            statusString = CMP_CaseStatusUpdateController.updateStage(newcase.Id, desiredStatus);
        }
        Case c = retrieveCase(newcase.Id);  
        System.AssertEquals(CASE_PENDING_STATUS, c.Status, 'Expected value is '+CASE_PENDING_STATUS+', but actual value is '+c.Status );
        Test.stopTest();      
    }
    @isTest
    private static void testSwitchToClosedStatusWithOpenTask() {
        getUsers();

        
        Case newCase;
        system.runAs(systemAdminUser){
            newCase= new Case(Status = CASE_NEW_STATUS, AgentAssociateId__c = agentUser.Associate_ID__c, ownerId = agentUser.Id, Assigned_To__c = null, ContactId = UTIL_CaseTestData.contactId());
            insert newCase;
        }
                
        Test.startTest();
        String statusString;
        system.runAs(agentUser) {
            Case createdCase = retrieveCase(newCase.Id);
            Task task1 = new Task (WhatId=createdCase.Id, subject='Call',Priority='No',ActivityDate = Date.today(),Description='TASK111', status='Not Started',TaskCategory__c='Alert');
            insert task1;
            String desiredStatus = CASE_CLOSED_STATUS;
            statusString = CMP_CaseStatusUpdateController.updateStage(newcase.Id, desiredStatus);
        }
        System.AssertEquals(System.label.CL_CASE_CLOSE_ERROR_MESSAGE, statusString, 'Expected value is '+System.label.CL_CASE_CLOSE_ERROR_MESSAGE+', but actual value is '+statusString);
        Case c = retrieveCase(newcase.Id);  
        System.AssertEquals(CASE_PENDING_STATUS, c.Status, 'Expected value is '+CASE_PENDING_STATUS+', but actual value is '+c.Status );
        Test.stopTest();      
    }
    @isTest
    private static void testSwitchToPendingStatusWithOpenTask() {
        getUsers();
        
        Case newCase;
        system.runAs(systemAdminUser){
            newCase= new Case(ownerId = agentUser.Id);
            insert newCase;
        }
                
        Test.startTest();
        String statusString;
        system.runAs(agentUser) {
            Case createdCase = retrieveCase(newCase.Id);
            CMP_CaseStatusUpdateController.nullId = true;
            Task task1 = new Task (WhatId=createdCase.Id, subject='Call',Priority='No',ActivityDate = Date.today(),Description='TASK111', status='Not Started',TaskCategory__c='Alert');
            insert task1;
            String desiredStatus = CASE_PENDING_STATUS;
            statusString = CMP_CaseStatusUpdateController.updateStage(newcase.Id, desiredStatus);
        }
        System.AssertEquals(CaseHandlerConstants.CASE_NOT_ASSIGNED_ERROR, statusString, 'Expected value is '+CaseHandlerConstants.CASE_NOT_ASSIGNED_ERROR+', but actual value is '+statusString);
        Case c = retrieveCase(newcase.Id);  
        System.AssertEquals(CASE_PENDING_STATUS, c.Status, 'Expected value is '+CASE_PENDING_STATUS+', but actual value is '+c.Status);
        Test.stopTest();      
    }
    @isTest
    private static void testSwitchToClosedStatusWithoutOpenTask() {
        getUsers();

        
        Case newCase;
        system.runAs(systemAdminUser){
            newCase= new Case(Status = CASE_NEW_STATUS, AgentAssociateId__c = agentUser.Associate_ID__c, ownerId = agentUser.Id, Assigned_To__c = null, ContactId = UTIL_CaseTestData.contactId());
            insert newCase;
        }
                
        Test.startTest();
        String statusString;
        system.runAs(agentUser) {
            String desiredStatus = CASE_CLOSED_STATUS;
            statusString = CMP_CaseStatusUpdateController.updateStage(newcase.Id, desiredStatus);
        }
        System.AssertEquals('', statusString, 'Expected value is empty, but actual value is '+statusString);
        Case c = retrieveCase(newcase.Id);  
        System.AssertEquals(CASE_CLOSED_STATUS, c.Status, 'Expected value is '+CASE_CLOSED_STATUS+', but actual value is '+c.Status);
        Test.stopTest();      
    }

    @isTest
    private static void testFetchOpenActivitiesForCase() {
        getUsers();
        Test.startTest();
        Case testCase = new Case(Subject='Test Case Data');
        insert testCase;
        Task mockTask = new Task(Subject='Test Task', WhatId=testCase.Id, OwnerId=agentUser.Id);
        insert mockTask;
        Boolean fetchResult = CMP_CaseStatusUpdateController.fetchOpenActivitiesForCase(testCase.Id, true);
        Integer numQueriesRun;
        numQueriesRun = Limits.getDMLStatements();
        Test.stopTest();
        System.assertEquals(fetchResult, true, 'Unexpected number of tasks returned');
    }
    
    @isTest
    private static void testFetchOpenActivitiesForCaseThrowException() {
        getUsers();
        Test.startTest();
        Case testCase = new Case(Subject='Test Case Data');
        insert testCase;
        Task mockTask = new Task(Subject='Test Task', WhatId=testCase.Id, OwnerId=agentUser.Id);
        insert mockTask;
        AuraHandledException auraEx = null;
        System.runAs(agentUser){
            try{
                CMP_CaseStatusUpdateController.fetchOpenActivitiesForCase(testCase.Id, false);
            }catch(AuraHandledException e){
                auraEx = e;
            }
        }
        Test.stopTest();
        System.assert(auraEx != null, 'Agent can close Case and Task that belong to other agent office.');
    }
    
    
    private static Case retrieveCase(String recordId) {
        return [
            SELECT Id, Status, Assigned_To__c 
            FROM Case 
            WHERE Id=:recordId
        ];
    } 
}