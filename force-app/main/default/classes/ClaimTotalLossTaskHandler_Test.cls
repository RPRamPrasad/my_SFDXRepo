/**
 * @name ClaimTotalLossTaskHandler_Test
 * @author ACCSEdent (ACCSE - Claims)
 * @description Tests the ClaimTotalLossTaskHandler class.
 */
@isTest(seeAllData=false)
public with sharing class ClaimTotalLossTaskHandler_Test {
    private static final String CLAIM_SYNC_NAME = 'SF_CRM_FSCCLAIMSYNC';
    private static final String INDIVIDUAL_RECORD_TYPE = UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME;
    private static User commonAgentUser1 = new User(Alias='alias',LastName='CmpMemProx',Username='remCmpMemAgent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test',Servicing_Agent_Associate_ID__c='123test');
    /**
    * @name setup
    * @description creates the users and configures the custom settings to allow data to be created
    */
    @TestSetup
    public static void setup() {
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;

        User claimSyncUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        claimSyncUser.LastName = CLAIM_SYNC_NAME;
        insert claimSyncUser;

        System.runAs(systemUser) {
            PermissionSet psFSC = [SELECT Id, Name FROM PermissionSet WHERE Name='FSCInsurance'];
            PermissionSet psSync = [SELECT Id, Name FROM PermissionSet WHERE Name='SF_CRM_FSCClaimSync_PermSet'];
            List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment> {
                new PermissionSetAssignment(AssigneeId=claimSyncUser.Id, PermissionSetId=psFSC.Id),
                new PermissionSetAssignment(AssigneeId=claimSyncUser.Id, PermissionSetId=psSync.Id)
            };
            insert assignments;

            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false, systemUser);
            insert passTriggerAll;
        }

        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('1701A','systemUser','systemUserTest@statefarm.com'); 
        insert systemAdmin;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdmin.Id);            
        insert sysAdminUserIdSetting;
        TaskTestDataUtility.createAccount();
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(commonAgentUser1);
        insert agentUser;
    }

    /**
    * @name testTaskInsertForTotalLoss
    * @description task Insert for total loss claim
    */
    @isTest
    private static void testTaskInsertForTotalLoss(){
        Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
       
		Test.startTest();
        User claimSyncUser = getClaimSyncUser();
        Id accountId = TaskTestDataUtility.getAccount().Id;
        Id agentUserId = [Select Id from User where Alias = 'alias'].get(0).Id;

        InsurancePolicy insPolicy = new InsurancePolicy(Name = 'Policy1', NameInsuredId = accountId, Servicing_Agent__c = agentUserId);
        insert insPolicy;
       
        Claim claim = new Claim(Name = 'Test', PolicyNumberId = insPolicy.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = true);

        System.runAs(claimSyncUser) {
            insert claim;
        }
		test.stopTest();

        List<Task> insertedTasks = [SELECT Id FROM Task WHERE CreatedDate = TODAY AND Action_Required__c = 'Submit Policy Transaction'];
        System.assertEquals(1, insertedTasks.size(), 'insertedTasks size is not 1');
    }
    
    /**
    * @name testTaskInsertForTotalLossWithInvalidAgent
    * @description tests failure handling when inactive agent is used
    */
    @isTest
    private static void testTaskInsertForTotalLossWithInvalidAgent(){
        Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
        List<Claim> claimList = new List<Claim>();
       
		Test.startTest();
        User claimSyncUser = getClaimSyncUser();
        Id accountId = TaskTestDataUtility.getAccount().Id;
        Id agentUserId = [Select Id from User where Alias = 'alias'].get(0).Id;
        User testAgentUser1 = new User(Alias='Al1as',LastName='tester',Username='remCmpMemAgent1@statefarm.com',Associate_ID__c='321test',UserExternalID__c='321test',Servicing_Agent_Associate_ID__c='321test');
        User inactiveAgent = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
        inactiveAgent.isActive = false;
        insert inactiveAgent;
        InsurancePolicy insPolicy = new InsurancePolicy(Name = 'Policy1', NameInsuredId = accountId, Servicing_Agent__c = agentUserId);
        insert insPolicy;
        InsurancePolicy insPolicy2 = new InsurancePolicy(Name = 'Policy2', NameInsuredId = accountId, Servicing_Agent__c = inactiveAgent.id);
        insert insPolicy2;
        InsurancePolicy insPolicy3 = new InsurancePolicy(Name = 'Policy3', NameInsuredId = accountId);
        insert insPolicy3;
        
        List<ExceptionLog__c> exceptionLogsPreCheck = [SELECT Id, Exception_Message__c, Stack_Trace__c  FROM ExceptionLog__c WHERE CreatedDate = TODAY AND Class__c = 'ClaimTotalLossTaskHandler'];
        System.assertEquals(0, exceptionLogsPreCheck.size(), 'Incorrect number of exceptions inserted');
        
        Claim claim = new Claim(Name = 'Test', PolicyNumberId = insPolicy.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = true);
        claimList.add(claim);
        Claim claim2 = new Claim(Name = 'Test', PolicyNumberId = insPolicy2.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = true);
        claimList.add(claim2);
        Claim claim3 = new Claim(Name = 'Test', PolicyNumberId = insPolicy3.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = true);
        claimList.add(claim3);

        System.runAs(claimSyncUser) {
            insert claimList;
        }
		test.stopTest();
        
        List<Task> insertedTasks = [SELECT Id FROM Task WHERE CreatedDate = TODAY AND Action_Required__c = 'Submit Policy Transaction'];
        System.assertEquals(1, insertedTasks.size(), 'Incorrect number of tasks inserted');
        List<ExceptionLog__c> exceptionLogs = [SELECT Id  FROM ExceptionLog__c WHERE CreatedDate = TODAY AND Class__c = 'ClaimTotalLossTaskHandler'];
        System.assertEquals(2, exceptionLogs.size(), 'Incorrect number of exceptions inserted');
    }
    
    /**
    * @name testMultipleTotalLossClaimsPerPolicy
    * @description appropriate amount of tasks Inserting for multiple total loss claims on the same account
    */
    @isTest
    private static void testInsertMultipleTotalLossClaimsPerPolicy(){
        Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
       
		Test.startTest();
        User claimSyncUser = getClaimSyncUser();
        Id accountId = TaskTestDataUtility.getAccount().Id;
        Id agentUserId = [Select Id from User where Alias = 'alias'].get(0).Id;
        InsurancePolicy insPolicy = new InsurancePolicy(Name = 'Policy1', NameInsuredId = accountId, Servicing_Agent__c = agentUserId);
        insert insPolicy;

        List<Claim> insertClaims = new List<Claim>();
        Claim claim = new Claim(Name = 'Test1', PolicyNumberId = insPolicy.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = true);
        insertClaims.add(claim);
        Claim claim2 = new Claim(Name = 'Test2', PolicyNumberId = insPolicy.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = true);
        insertClaims.add(claim2);
        Claim claim3 = new Claim(Name = 'Test3', PolicyNumberId = insPolicy.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = true);
        insertClaims.add(claim3);

        System.runAs(claimSyncUser) {
            insert insertClaims;
        }
		test.stopTest();

		List<Task> insertedTasks = [SELECT Id FROM Task WHERE CreatedDate = TODAY AND Action_Required__c = 'Submit Policy Transaction'];
        System.assertEquals(3, insertedTasks.size(), 'insertedTasks size is not 3');
        List<ExceptionLog__c> exceptionLogs = [SELECT Id FROM ExceptionLog__c WHERE CreatedDate = TODAY AND Class__c = 'ClaimTotalLossTaskHandler'];
        System.assertEquals(0, exceptionLogs.size(), 'exceptionLogs size is not 0');
    }
    
    /**
    * @name testMultipleTotalLossClaimsDifferentPolicies
    * @description appropriate amount of tasks Inserting for multiple total loss claims on multiple policies
    */
    @isTest
    private static void testMultipleTotalLossClaimsDifferentPolicies(){
        Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
       
		Test.startTest();
        User claimSyncUser = getClaimSyncUser();
        Id accountId = TaskTestDataUtility.getAccount().Id;
        Id agentUserId = [Select Id from User where Alias = 'alias'].get(0).Id;
        InsurancePolicy insPolicy1 = new InsurancePolicy(Name = 'Policy1', NameInsuredId = accountId, Servicing_Agent__c = agentUserId);
        insert insPolicy1;
        InsurancePolicy insPolicy2 = new InsurancePolicy(Name = 'Policy2', NameInsuredId = accountId, Servicing_Agent__c = agentUserId);
        insert insPolicy2;

        List<Claim> insertClaims = new List<Claim>();
        Claim claim1 = new Claim(Name = 'Test1', PolicyNumberId = insPolicy1.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = true);
        insertClaims.add(claim1);
        Claim claim2 = new Claim(Name = 'Test2', PolicyNumberId = insPolicy2.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = true);
        insertClaims.add(claim2);

        System.runAs(claimSyncUser) {
            insert insertClaims;
        }
		test.stopTest();
        
        List<Task> insertedTasks = [SELECT Id FROM Task WHERE CreatedDate = TODAY AND Action_Required__c = 'Submit Policy Transaction'];
        System.assertEquals(2, insertedTasks.size(), 'insertedTasks size is not 2');
        List<ExceptionLog__c> exceptionLogs = [SELECT Id FROM ExceptionLog__c WHERE CreatedDate = TODAY AND Class__c = 'ClaimTotalLossTaskHandler'];
        System.assertEquals(0, exceptionLogs.size(), 'exceptionLogs size is not 0');
    }
    
    /**
    * @name testTaskInsertForTotalLoss
    * @description task Insert for total loss claim
    */
    @isTest
    private static void testTotalLossUpdateExistingTask(){
        Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
       
		Test.startTest();
        User claimSyncUser = getClaimSyncUser();
        Id accountId = TaskTestDataUtility.getAccount().Id;
        Id agentUserId = [Select Id from User where Alias = 'alias'].get(0).Id;
        InsurancePolicy insPolicy = new InsurancePolicy(Name = 'Policy1', NameInsuredId = accountId, Servicing_Agent__c = agentUserId);
        insert insPolicy;
       
        Claim claim = new Claim(Name = 'Existing Task Test', PolicyNumberId = insPolicy.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = true);

        System.runAs(claimSyncUser) {
            insert claim;
        }
        List<Task> insertedTasks = [SELECT Id FROM Task WHERE CreatedDate = TODAY AND Action_Required__c = 'Submit Policy Transaction'];
        System.assertEquals(1, insertedTasks.size(), 'insertedTasks size is not 1');

        System.runAs(claimSyncUser) {
            claim.TotalLossIndicator__c = false;
            update claim;
            claim.TotalLossIndicator__c = true;
            update claim; 
        }
		test.stopTest();

        //We got 1 in the insert above, so the result should still be only 1 task. No more should be inserted and no exceptions should generate.
        List<Task> insertedTasks2ndRun = [SELECT Id FROM Task WHERE CreatedDate = TODAY AND Action_Required__c = 'Submit Policy Transaction'];
        System.assertEquals(1, insertedTasks2ndRun.size(), 'insertedTasks2ndRun size is not 1');
        List<ExceptionLog__c> exceptionLogs = [SELECT Id FROM ExceptionLog__c WHERE CreatedDate = TODAY AND Class__c = 'ClaimTotalLossTaskHandler'];
        System.assertEquals(0, exceptionLogs.size(), 'exceptionLogs size is not 0');
    }
    
        /**
    * @name testMultipleClaimsWithOnlyOneTotalLossEligible
    * @description appropriate amount of tasks Inserting for multiple total loss claims on multiple policies
    */
    @isTest
    private static void testMultipleClaimsWithOnlyOneTotalLossEligible(){
        Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
       
		Test.startTest();
        User claimSyncUser = getClaimSyncUser();
        Id accountId = TaskTestDataUtility.getAccount().Id;
        Id agentUserId = [Select Id from User where Alias = 'alias'].get(0).Id;
        InsurancePolicy insPolicy1 = new InsurancePolicy(Name = 'Policy1', NameInsuredId = accountId, Servicing_Agent__c = agentUserId);
        insert insPolicy1;
        InsurancePolicy insPolicy2 = new InsurancePolicy(Name = 'Policy2', NameInsuredId = accountId, Servicing_Agent__c = agentUserId);
        insert insPolicy2;
        InsurancePolicy insPolicy3 = new InsurancePolicy(Name = 'Policy2', NameInsuredId = accountId, Servicing_Agent__c = agentUserId);
        insert insPolicy3;

        List<Claim> insertClaims = new List<Claim>();
        Claim claim1 = new Claim(Name = 'Test1', PolicyNumberId = insPolicy1.id, ProdLineCd__c = 'F', ClaimStatusCd__c ='N', TotalLossIndicator__c = true);
        insertClaims.add(claim1);
        Claim claim2 = new Claim(Name = 'Test2', PolicyNumberId = insPolicy2.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = false);
        insertClaims.add(claim2);
        Claim claim3 = new Claim(Name = 'Test3', PolicyNumberId = insPolicy3.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = false);
        insertClaims.add(claim3);
        
        System.runAs(claimSyncUser) {
            insert insertClaims;
        }
        
        List<Claim> updateClaims = new List<Claim>();
        claim1.ProdLineCd__c = 'A';
        updateClaims.add(claim1);
        claim2.TotalLossIndicator__c = true;
        updateClaims.add(claim2);
        claim3.TotalLossIndicator__c = true;
        updateClaims.add(claim3);

        System.runAs(claimSyncUser) {
            update updateClaims;
        }
		test.stopTest();
        
        List<Task> insertedTasks = [SELECT Id FROM Task WHERE CreatedDate = TODAY AND Action_Required__c = 'Submit Policy Transaction'];
        System.assertEquals(2, insertedTasks.size(), 'insertedTasks size is not 2');
        List<ExceptionLog__c> exceptionLogs = [SELECT Id FROM ExceptionLog__c WHERE CreatedDate = TODAY AND Class__c = 'ClaimTotalLossTaskHandler'];
        System.assertEquals(0, exceptionLogs.size(), 'exceptionLogs size is not 0');
    }
    
        /**
    * @name testTaskInsertForTotalLoss
    * @description task Insert for total loss claim
    */
    @isTest
    private static void testTotalLossUpdateNoExistingTask(){
        Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
       
		Test.startTest();
        User claimSyncUser = getClaimSyncUser();
        Id accountId = TaskTestDataUtility.getAccount().Id;
        Id agentUserId = [Select Id from User where Alias = 'alias'].get(0).Id;
        InsurancePolicy insPolicy = new InsurancePolicy(Name = 'Policy1', NameInsuredId = accountId, Servicing_Agent__c = agentUserId);
        insert insPolicy;
       
        Claim claim = new Claim(Name = 'Test', PolicyNumberId = insPolicy.id, ProdLineCd__c = 'A', ClaimStatusCd__c ='N', TotalLossIndicator__c = false);

        System.runAs(claimSyncUser) {
            insert claim;
        }

        List<Task> insertedTasks = [SELECT Id FROM Task WHERE CreatedDate = TODAY AND Action_Required__c = 'Submit Policy Transaction'];
        System.assertEquals(0, insertedTasks.size(), 'insertedTasks size is not 0');
        List<ExceptionLog__c> exceptionLogs = [SELECT Id FROM ExceptionLog__c WHERE CreatedDate = TODAY AND Class__c = 'ClaimTotalLossTaskHandler'];
        System.assertEquals(0, exceptionLogs.size(), 'exceptionLogs size is not 0');
        
        System.runAs(claimSyncUser) {
            claim.TotalLossIndicator__c = true;
            update claim; 
        }
		test.stopTest();
        
        List<Task> insertedTasks2ndRun = [SELECT Id FROM Task WHERE CreatedDate = TODAY AND Action_Required__c = 'Submit Policy Transaction'];
        System.assertEquals(1, insertedTasks2ndRun.size(), 'insertedTasks2ndRun size is not 1');
        List<ExceptionLog__c> exceptionLogs2ndRun = [SELECT Id FROM ExceptionLog__c WHERE CreatedDate = TODAY AND Class__c = 'ClaimTotalLossTaskHandler'];
        System.assertEquals(0, exceptionLogs2ndRun.size(), 'exceptionLogs2ndRun size is not 0');
    }

    private static User getClaimSyncUser() {
        return [SELECT Id FROM User WHERE NAME = :CLAIM_SYNC_NAME LIMIT 1];
    }
}