/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * methods. Classes defined with the @isTest annotat * The @isTest class annotation indicates this class only contains test
ion do not count against * the organization size limit for all Apex s
cripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 * @description AP_QA_Opportunity_UpdateStageName_TEST
 Version     Author         Date         Description
 1.1         Opptimizers    9-8-2022     added @isTest annotations
 */
@isTest(seeAllData=false)
private class AP_QA_Opportunity_UpdateStageName_TEST {
	
	private static AP_QA_Opportunity_UpdateStageName updateQuoteStatus;
	private static User commonProxyUser1 = new User(Alias='Proxy',LastName='ProxyAccOwner',Username='proxyAgent@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
	private static User commonAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='accOwnerAgent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test123te',Servicing_Agent_Associate_ID__c='123test');
    @testsetup
	private static void setUp() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=false);
        insert passTriggerAll;
        CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
        insert accountByPassTrigger;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);            
        insert sysAdminUserIdSetting;
        
        CS001_ByPassTriggerAtoF__c accBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        accBasedByPassTrigger.Override_AccountBeforeInsert__c = false;
        insert accBasedByPassTrigger;
        
        CS001_ByPassTriggerGtoZ__c oppByPassTrigger = new CS001_ByPassTriggerGtoZ__c(Override_OppBeforeInsert__c=true);
        insert oppByPassTrigger;    
    }
    
    @isTest
    static void testUpdateStageName() {
        Account testAccount= new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'cid1');
        insert testAccount;
        
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com'); 
        insert systemAdmin;
        
        UserRole agentStandardUserRole;
        UserRole proxyStandardUserRole;
        System.runAs(systemAdmin) {
            agentStandardUserRole = new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentStandardUserRole.id);
            insert proxyStandardUserRole;       
        }
        User agentUser;
        User proxyUser;
        System.runAs(systemAdmin) {
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(commonProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            insert proxyUser;             
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(commonAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            insert agentUser;
            
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, Agent__c=agentUser .id);
            insert newAgentRole;        
        }
        Opportunity opp = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption');
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        system.runAs(agentUser) { 
            insert opp;
           	Map<String, String> requestParams = new Map<String, String>();
            requestParams.put('newStageName', 'Quoting');
        	requestParams.put('opportunityId', opp.Id);
            
			updateQuoteStatus = new AP_QA_Opportunity_UpdateStageName();
            updateQuoteStatus.setRequestParameters(requestParams);
        	updateQuoteStatus.execute();
        }
        Test.stopTest();
        
		Opportunity actual = [SELECT ID, StageName,Status__c FROM Opportunity WHERE ID = :opp.ID];
        System.assertEquals('Quoting', actual.StageName, 'The actual StatusStage is not Quoting');
        System.assertEquals('Quote In Progress', actual.Status__c, 'The actual Status is not Quote In Progress');
    }
    
    @isTest
    static void testUpdateStageNameNullParameter() {
        Account testAccount= new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'cid1');
        insert testAccount;
        
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com'); 
        insert systemAdmin;
        
        UserRole agentStandardUserRole;
        UserRole proxyStandardUserRole;
        System.runAs(systemAdmin) {
            agentStandardUserRole = new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentStandardUserRole.id);
            insert proxyStandardUserRole;       
        }
        User agentUser;
        User proxyUser;
        System.runAs(systemAdmin) {
            
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(commonProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            insert proxyUser; 
            
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(commonAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            insert agentUser;
            
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, Agent__c=agentUser .id);
            insert newAgentRole;        
        }
        Opportunity opp = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption');
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        system.runAs(agentUser) { 
            insert opp;
           	Map<String, String> requestParams = new Map<String, String>();
            
            try {
            	updateQuoteStatus = new AP_QA_Opportunity_UpdateStageName();
            	updateQuoteStatus.setRequestParameters(requestParams);
        		updateQuoteStatus.execute();
            } catch (NoDataFoundException ex) {
                System.assertEquals('Opportunity ID is null.', ex.getMessage(), 'The expected exception message does not match the actual value');
            }
        }
        Test.stopTest();
        
		Opportunity actual = [SELECT ID, StageName FROM Opportunity WHERE ID = :opp.ID];
        System.assertEquals('Assigned', actual.StageName, 'The actual Status it not Assigned');
    }
    
    @isTest
    static void testUpdateStageNameIncorrectOpportunityId() {
        Account testAccount= new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'cid1');
        insert testAccount;
        
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com'); 
        insert systemAdmin;
        
        UserRole agentStandardUserRole;
        UserRole proxyStandardUserRole;
        System.runAs(systemAdmin) {
            agentStandardUserRole = new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentStandardUserRole.id);
            insert proxyStandardUserRole;       
        }
        User agentUser;
        User proxyUser;
        System.runAs(systemAdmin) {
            
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(commonProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            insert proxyUser; 
            
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(commonAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            insert agentUser;
            
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, Agent__c=agentUser .id);
            insert newAgentRole;        
        }
        Opportunity opp = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',Status__c='Quote Provided');
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        system.runAs(agentUser) { 
            insert opp;
           	Map<String, String> requestParams = new Map<String, String>();
            requestParams.put('opportunityId', '00909090993203232');
             requestParams.put('newStageName', 'Quoting');
			updateQuoteStatus = new AP_QA_Opportunity_UpdateStageName();
            updateQuoteStatus.setRequestParameters(requestParams);
            
            try {
        		updateQuoteStatus.execute();
            } catch (NoDataFoundException ex) {
                System.assertEquals('Opportunity does not exist. Id: 00909090993203232', ex.getMessage(), 'The expected exception message does not match the actual value');
            }
        }
        Test.stopTest();
        
		Opportunity actual = [SELECT ID, StageName,status__c FROM Opportunity WHERE ID = :opp.ID];
        System.assertEquals('Assigned', actual.StageName, 'The actual Status it not Assigned');
       
    }

    @isTest
    static void testUpdateStageNameStatusCheck() {
        Account testAccount= new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'cid1');
        insert testAccount;
        
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com'); 
        insert systemAdmin;
        
        UserRole agentStandardUserRole;
        UserRole proxyStandardUserRole;
        System.runAs(systemAdmin) {
            agentStandardUserRole = new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentStandardUserRole.id);
            insert proxyStandardUserRole;       
        }
        User agentUser;
        User proxyUser;
        System.runAs(systemAdmin) {
            
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(commonProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            insert proxyUser; 
            
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(commonAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            insert agentUser;
            
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, Agent__c=agentUser .id);
            insert newAgentRole;        
        }
        Opportunity opp = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',Status__c='Quote Provided');
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        system.runAs(agentUser) { 
            insert opp;
           	Map<String, String> requestParams = new Map<String, String>();
            requestParams.put('opportunityId', opp.Id);
             requestParams.put('newStageName', 'Quoting');
			updateQuoteStatus = new AP_QA_Opportunity_UpdateStageName();
            updateQuoteStatus.setRequestParameters(requestParams);
            
            try {
        		updateQuoteStatus.execute();
            } catch (NoDataFoundException ex) {
                System.assertEquals('Opportunity does not exist. Id: 00909090993203232', ex.getMessage(), 'The expected exception message does not match the actual value');
            }
        }
        Test.stopTest();
        
		Opportunity actual = [SELECT ID, StageName,status__c FROM Opportunity WHERE ID = :opp.ID];
        System.assertEquals('Quoting', actual.StageName, 'The actual Status it not Assigned');
        System.assertEquals('Quote Provided', actual.status__c, 'The actual Status it not Assigned');
       
    }

    @isTest
    static void testUpdateStageNameStatusCheckEmpty() {
        Account testAccount= new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'cid1');
        insert testAccount;
        
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com'); 
        insert systemAdmin;
        
        UserRole agentStandardUserRole;
        UserRole proxyStandardUserRole;
        System.runAs(systemAdmin) {
            agentStandardUserRole = new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentStandardUserRole.id);
            insert proxyStandardUserRole;       
        }
        User agentUser;
        User proxyUser;
        System.runAs(systemAdmin) {
            
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(commonProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            insert proxyUser; 
            
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(commonAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            insert agentUser;
            
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, Agent__c=agentUser .id);
            insert newAgentRole;        
        }
        Opportunity opp = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption');
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        system.runAs(agentUser) { 
            insert opp;
           	Map<String, String> requestParams = new Map<String, String>();
            requestParams.put('opportunityId', opp.Id);
             requestParams.put('newStageName', 'Quoting');
			updateQuoteStatus = new AP_QA_Opportunity_UpdateStageName();
            updateQuoteStatus.setRequestParameters(requestParams);
            
            try {
        		updateQuoteStatus.execute();
            } catch (NoDataFoundException ex) {
                System.assertEquals('Opportunity does not exist. Id: 00909090993203232', ex.getMessage(), 'The expected exception message does not match the actual value');
            }
        }
        Test.stopTest();
        
		Opportunity actual = [SELECT ID, StageName,status__c FROM Opportunity WHERE ID = :opp.ID];
        System.assertEquals('Quoting', actual.StageName, 'The actual Status it not Assigned');
        System.assertEquals('Quote In Progress', actual.status__c, 'The actual Status it not Assigned');
       
    }
}