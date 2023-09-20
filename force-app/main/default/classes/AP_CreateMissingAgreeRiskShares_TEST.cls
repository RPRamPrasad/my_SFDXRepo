/**
  * @name AP_CreateMissingAgreeRiskShares_TEST
  * @author NSYNC
  * @description Test class for AP_CreateMissingAgreeRiskShares for Insurance Policy
  */
@isTest(SeeAllData=false)
public with sharing class AP_CreateMissingAgreeRiskShares_TEST {
      
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
     * @description testCreateMissingSharesWithInsertFor1Agent
     */
    private static testmethod void testCreateMissingSharesWithInsertFor1Agent() {
        Batch_CreateMissingAgreeRiskShares batchClass = new Batch_CreateMissingAgreeRiskShares();
        String jobId = '';
        User systemUser = [Select Id, name from User where email = 'RiskShareSysAd@statefarm.com' Limit 1];
        User agentOffice = null;
        User agent = null;
        List<User> userList = [SELECT Id, servicing_agent_external_id__c,UserExternalID__c,Associate_ID__c, isActive, usertype__c FROM User where Servicing_Agent_Associate_ID__c = '1111111111X'];
        
        for (User auser:userList) {
            if ('1111111111XP'.equals(auser.UserExternalID__c)) {
                agentOffice = auser;
            }
            if ('1111111111X_1111111111X'.equals(auser.UserExternalID__c)) {
                agent = auser;
            }
        }
        System.runAs(systemUser) {
        	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
 	        Account a = UTIL_CreateCustomerTestData.createIndividualCustomer('Smith');
	        a.clientIdentifier__c= 'testkdvbsmi';
	        insert a;
	        List<AgentRole__c> agRoleList = new List<AgentRole__c>();
	        agRoleList.add(new AgentRole__c(Agent__c=agent.Id, RelationshipNature__c='Customer', Customer__c=a.Id));
	        insert agRoleList;
            CS001_ByPassTriggerGtoZ__c override_InsurancePolicyTriggers = new CS001_ByPassTriggerGtoZ__c(Override_InsurancePolicyTriggers__c = true);
            insert override_InsurancePolicyTriggers;
	        createDummyPolicyDataAndPartyRole(a, agent.Associate_ID__c, 1);
        }
        Test.StartTest();
        System.runas(systemUser){
            jobId = Database.executeBatch(batchClass, 2);
        }
        Test.StopTest();
       List<InsurancePolicyShare> ipsList2 = [SELECT Id,ParentId,UserOrGroupId,AccessLevel,RowCause  FROM InsurancePolicyShare where accesslevel = 'Read' and rowcause = 'Manual'];
        System.assertEquals(1, ipsList2.size(), 'The given two parameters are not equal:1=' + ipsList2.size());
              List<ExceptionLog__c> expList = [SELECT Id, Exception_Message__c FROM ExceptionLog__c where class__c = 'AP_CreateMissingAgreeRiskShares']; 
        System.assertEquals('Results for AP_CreateMissingAgreeRiskShares : Total Agent Offices - 1, Agent Offices with Missing Shares - 1, Shares inserted - 1', expList.get(0).Exception_Message__c, 'The message is not expected');
   }
   /**
     * @description testCreateMissingSharesWithInsertFor1AgentMultPol
     */
    private static testmethod void testCreateMissingSharesWithInsertFor1AgentMultPol() {
        Batch_CreateMissingAgreeRiskShares batchClass = new Batch_CreateMissingAgreeRiskShares();
        String jobId = '';
        User systemUser = [Select Id, name from User where email = 'RiskShareSysAd@statefarm.com' Limit 1];
        User agentOffice = null;
        User agent = null;
        List<User> userList = [SELECT Id, servicing_agent_external_id__c,UserExternalID__c,Associate_ID__c, isActive, usertype__c FROM User where Servicing_Agent_Associate_ID__c = '1111111111X'];
        
        for (User auser:userList) {
            if ('1111111111XP'.equals(auser.UserExternalID__c)) {
                agentOffice = auser;
            }
            if ('1111111111X_1111111111X'.equals(auser.UserExternalID__c)) {
                agent = auser;
            }
        }
        System.runAs(systemUser) {
        	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
 	        Account a = UTIL_CreateCustomerTestData.createIndividualCustomer('Smith');
	        a.clientIdentifier__c= 'testkdvbsmi';
	        insert a;
	        List<AgentRole__c> agRoleList = new List<AgentRole__c>();
	        agRoleList.add(new AgentRole__c(Agent__c=agent.Id, RelationshipNature__c='Customer', Customer__c=a.Id));
	        insert agRoleList;
            CS001_ByPassTriggerGtoZ__c override_InsurancePolicyTriggers = new CS001_ByPassTriggerGtoZ__c(Override_InsurancePolicyTriggers__c = true);
            insert override_InsurancePolicyTriggers;
	        createDummyPolicyDataAndPartyRole(a, agent.Associate_ID__c, 3);
        }
        Test.StartTest();
        System.runas(systemUser){
            jobId = Database.executeBatch(batchClass, 2);
        }
        Test.StopTest();
       List<InsurancePolicyShare> ipsList2 = [SELECT Id,ParentId,UserOrGroupId,AccessLevel,RowCause  FROM InsurancePolicyShare where accesslevel = 'Read' and rowcause = 'Manual'];
        System.assertEquals(2, ipsList2.size(), 'The given two parameters are not equal:2=' + ipsList2.size());
              List<ExceptionLog__c> expList = [SELECT Id, Exception_Message__c FROM ExceptionLog__c where class__c = 'AP_CreateMissingAgreeRiskShares']; 
        System.assertEquals('Results for AP_CreateMissingAgreeRiskShares : Total Agent Offices - 1, Agent Offices with Missing Shares - 1, Shares inserted - 2', expList.get(0).Exception_Message__c, 'The message is not expected');
   }
    /**
     * @description createDummyPolicyDataAndPartyRole
     * @param accountIn
     * @param agentAssocId
     * @param size
     */
	private static void createDummyPolicyDataAndPartyRole(Account accountIn, String agentAssocId, Integer size){
        String agreIndexId = '123456A11';
		InsurancePolicy inspol = new InsurancePolicy();
        inspol.sourceSystemIdentifier = agreIndexId;
		inspol.NameInsuredId = accountIn.Id;
		inspol.Name = 'NameFor'+agreIndexId;
		inspol.Servicing_Agent__r = new User(UserExternalId__c = agentAssocId+'_'+agentAssocId);
		inspol.ExternalSourceSyncTime__c = Datetime.now().addHours(-5);
		insert inspol;
		
		InsurancePolicyParticipant insPolPart = new InsurancePolicyParticipant();
		insPolPart.PrimaryParticipantAccountId =  accountIn.Id;
		insPolPart.SourceSystemIdentifier = agreIndexId + '~' + accountIn.ClientIdentifier__c + '~' + 1;
		insPolPart.ExternalSourceSyncTime__c = Datetime.now().addHours(-5);
        insPolPart.InsurancePolicyId = inspol.Id;
        insPolPart.Role = 'Named Insured';
        insPolPart.RoleNameCd__c = '18';
		insert insPolPart;
        Integer i = 2;
		if (size > 1)  {
        String agreIndexId2 = '123456A1' + String.valueOf(i);
		InsurancePolicy inspol2 = new InsurancePolicy();
        inspol2.sourceSystemIdentifier = agreIndexId2;
		inspol2.NameInsuredId = accountIn.Id;
		inspol2.Name = 'NameFor'+agreIndexId2;
		inspol2.Servicing_Agent__r = new User(UserExternalId__c = agentAssocId+'_'+agentAssocId);
		inspol2.ExternalSourceSyncTime__c = Datetime.now().addHours(-5);
		insert inspol2;
		
		InsurancePolicyParticipant insPolPart2 = new InsurancePolicyParticipant();
		insPolPart2.PrimaryParticipantAccountId =  accountIn.Id;
		insPolPart2.SourceSystemIdentifier = agreIndexId2 + '~' + accountIn.ClientIdentifier__c + '~' + 1;
		insPolPart2.ExternalSourceSyncTime__c = Datetime.now().addHours(-5);
        insPolPart2.InsurancePolicyId = inspol2.Id;
        insPolPart2.Role = 'Named Insured';
        insPolPart2.RoleNameCd__c = '18';
		insert insPolPart2;
 }       
		if (size > 2)  {
        i = 3;    
        String agreIndexId3 = '123456A1' + String.valueOf(i);
		InsurancePolicy inspol3 = new InsurancePolicy();
        inspol3.sourceSystemIdentifier = agreIndexId3;
		inspol3.NameInsuredId = accountIn.Id;
		inspol3.Name = 'NameFor'+agreIndexId3;
		inspol3.Servicing_Agent__r = new User(UserExternalId__c = agentAssocId+'_'+agentAssocId);
		inspol3.ExternalSourceSyncTime__c = Datetime.now().addHours(-5);
		insert inspol3;
		
		InsurancePolicyParticipant insPolPart3 = new InsurancePolicyParticipant();
		insPolPart3.PrimaryParticipantAccountId =  accountIn.Id;
		insPolPart3.SourceSystemIdentifier = agreIndexId3 + '~' + accountIn.ClientIdentifier__c + '~' + 1;
		insPolPart3.ExternalSourceSyncTime__c = Datetime.now().addHours(-5);
        insPolPart3.InsurancePolicyId = inspol3.Id;
        insPolPart3.Role = 'Named Insured';
        insPolPart3.RoleNameCd__c = '18';
		insert insPolPart3;
 }       
	}

}