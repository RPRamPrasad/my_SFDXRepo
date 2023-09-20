/**
  * @name Batch_CreateMissingAgreeRiskShares_TEST
  * @author NSYNC
  * @description Test class for Batch_CreateMissingAgreeRiskShares 
  */
@isTest(SeeAllData=false)
public with sharing class BATCH_CreateMissingAgreeRiskShares_TEST {

    @testsetup
    private static void setup() {  
		User processID = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin('CreateRiskShareTestSystemAdm@statefarm.com');   
        User systemUser = UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','ShareAdm','RiskShareSysAd@statefarm.com');
        TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
        User agentOffice = null;
        List<User> userList = [SELECT Id, UserExternalID__c,servicing_agent_external_id__c,Associate_ID__c,UserType__c,IsActive,MasterUserRecord__c FROM User where Servicing_Agent_Associate_ID__c = '1111111111X'];
	    for (User auser:userList) {
            if ('1111111111XP'.equals(auser.UserExternalID__c)) {
                agentOffice = auser;
            }
        }
        if (null != agentOffice) {
            agentOffice.IsActive = true;
            agentOffice.UserType__c = 'Agent Proxy';
            agentOffice.MasterUserRecord__c = true;
            Database.update(agentOffice);
        }
        insert new List<User>{processID, systemUser};
        // Query your permission set name from Organization that your want to test.
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'SF_CRM_AgreeRiskShare_PermSet' Limit 1];
        
        // Assign the above inserted user for the above Permission Set.        
        PermissionSetAssignment permSetAssign = new PermissionSetAssignment();        
        permSetAssign.AssigneeId = processID.Id;
        permSetAssign.PermissionSetId = permSet.Id;
        insert permSetAssign;
        System.runAs(systemUser){
	        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(SFDC_USER_ID__c=systemUser.id);
	        insert sysAdminUserIdSetting;
            CS_ApexBatchSize__c batchSizeAllAgents = new CS_ApexBatchSize__c();
            batchSizeAllAgents.Name ='CreateMissingAgreeRiskShares';
            batchSizeAllAgents.BatchSize__c =1;
            CS_ApexBatchSize__c batchSizeLargeBook = new CS_ApexBatchSize__c();
            batchSizeLargeBook.Name ='CreateMissingRiskShareLargeBook';
            batchSizeLargeBook.BatchSize__c =11;
            CS_ApexBatchSize__c limitSizeAgentRole = new CS_ApexBatchSize__c();
            limitSizeAgentRole.Name ='CreateMissingRiskShareAgentRoleLimit';
            limitSizeAgentRole.BatchSize__c = 11;
            insert new List<CS_ApexBatchSize__c>{batchSizeAllAgents, batchSizeLargeBook, limitSizeAgentRole};
        }
    }
    /**
    * @method test method to verify that the scheduler class is able to be scheduled properly 
    * @name  testCreateMissingSharesBatch
    * @description Test Create Missing Shares Batch
    */
    @isTest
    private static void testCreateMissingSharesBatch() {
        Batch_CreateMissingAgreeRiskShares batchClass = new Batch_CreateMissingAgreeRiskShares();
        String jobId = '';
        User processID = [Select Id, name from User where username = 'CreateRiskShareTestSystemAdm@statefarm.com' Limit 1];
        Test.StartTest();
        System.runas(processID){
            jobId = Database.executeBatch(batchClass, 2);
        }
        Test.StopTest();
        List<ExceptionLog__c> exLog = [Select id, Class__c from ExceptionLog__c where Class__c = 'AP_CreateMissingAgreeRiskShares'];
        System.assertEquals(1, exLog.size(), 'The given two parameters are not equal:1=' + exLog.size());
    }
}