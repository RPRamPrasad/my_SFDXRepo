/**
* @Author  Team AKITA
* @Date Created  12/04/2020  
* @description  Test class for LWC_NewOppTaskCreateFlow - Apex Class.
* @Version 1.0 
* Copyright © StateFarm
*/

@isTest
public class LWC_NewOppTaskCreateFlow_Test {
    public static User agentUser;
    public static User adminUser;
    public static User cccLicensedUser;
    public static User cccUnlicensedUser;
    public static User enterpriseUser600;
    public static User ltdEnterpriseUser601;
    public static User proxyUser;
    public static Account acc;
    public static Opportunity opp;
    public static AgentContext__c ac;
    private static PermissionSetAssignment psassignment;
    private static String opportuntiyReadOnly = 'Opportunity_Standard_R';
    private static String opportunityReadWrite = 'SF_CRM_Opportunity_Standard_W_PermSet';
    
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();
    
    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }
    
    //method to build userrole with the given parameter value
    private static UserRole buildUserRole(String roleName) {
        UserRole role = new UserRole(name = roleName);
        return role;
    }
    
    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildUserRoleWithParent(String roleName, String parentRole) {
        UserRole role = new UserRole(name = roleName, parentRoleId = parentRole);
        return role;
    }
    
    //method to build Agent Role record with Customer Account Id
    private static AgentRole__c buildAgentRoleRecord(String accountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = userInfo.getUserId(), Customer__c = accountId);
        
        return agentRole;
    }
    
    
    //method to build Agent Context Record with the given parameter value
    private static AgentContext__c buildAgentContextRecord(String paramAccountId, String paramAgntContxtIdentifier, String paramAgntUser) {
        AgentContext__c agentContext = new AgentContext__c(Agent__c = paramAgntUser, AgentContextIdentifier__c = paramAgntContxtIdentifier,
                                                           CCCRepresentative__c = userInfo.getUserId(), Customer__c = paramAccountId);
        return agentContext;
    }
    
    //method to build Account record with Client First Name, Last Name, and Client Id
    private static Account buildAccountRecord(String fstLstName, String clientId, Id owner) {
        String[] splitFSTLSTName = fstLstName.split(' ');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account act = new Account(FirstName = splitFSTLSTName[0] , LastName = splitFSTLSTName[1], ownerId = owner,
                                  RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = clientId);
        return act;
    }
    
    //method to build Opportunity record with Lob,Product, AccountId and OwnerId
    private static Opportunity buildOpportunityRecord(String accountId, String lobProduct, String ownerId) {
        String[] splitlobProduct = lobProduct.split('-');   
        Opportunity opp = new Opportunity(Name = splitlobProduct[0],
                                          AccountId = accountId, 
                                          LOB__c = splitlobProduct[0], 
                                          Product__c = (splitlobProduct.size()>1)?splitlobProduct[1]:'',
                                          Requested_Effective_Date__c = Date.today(),
                                          StageName = 'New',
                                          CloseDate = Date.today()+60,
                                          ownerId = ownerId);
        return opp;
    }
    
    //method to assign permissionset for the given user in parameter value
    private static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }
    
    /**
     * @description setUp
     */
    @testSetup
    public static void setUp() {
        
        User adminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile('TestAdminUser@statefarm.com.bad');
        insert adminuser;
        User agentUser;
        User proxyUser; 
        User cccLicensedUser;
        User cccUnlicensedUser;
        User enterpriseUser600;
        User ltdEnterpriseUser601;
        
        System.runAs(adminUser) {
            byPassTrigger();
            
            UserRole agentUserRole = buildUserRole('AgentRole');
            insert agentUserRole;
            
            UserRole proxyUserRole = buildUserRoleWithParent('ProxyRole', agentUserRole.id);
            insert proxyUserRole;
            User testAgentUser = new User(Alias='X7PZ',LastName='agent,user,75-338-Office',Username='TestAgentUser@statefarm.com.bad',Associate_ID__c='ASSOCID0001',UserExternalID__c='EXTERNALID1',Servicing_Agent_Associate_ID__c='AGTASSOCID1',Territory_Associate_ID__c='',Servicing_Agent_Associate_ID_List__c='',Territory_Associate_ID_List__c='');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser (testAgentUser);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;
            User testProxyUser1 = new User(Alias='X7PX',LastName='middle,Last,75-338-Office',Username='TestProxyUser@statefarm.com.bad',UserExternalID__c='ASSOCID0001_T65B51YS000P',Servicing_Agent_Associate_ID__c='ASSOCID0001');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            User testCCCLicenUser = new User(Alias='X7PT',LastName='CCC,user,75-338-Office',Username='TestCCCUser@statefarm.com.bad',Associate_ID__c='ppcczz33ttc',UserExternalID__c='');
            cccLicensedUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUserMethod(testCCCLicenUser);
            insert cccLicensedUser;
            User testCCCUnLicenUser = new User(Alias='X7PU',LastName='CCC,unlisenced,75-338-Office',Username='TestCCC301User@statefarm.com.bad',Associate_ID__c='ppcczz33ttb',UserExternalID__c='');
            cccUnlicensedUser = UTIL_UserProvisioning_TEST.buildCCCUnlicensedUserMethod(testCCCUnLicenUser);
            insert cccUnlicensedUser;
            User testEntpUser = new User(Alias='Y6P1',LastName='600,EnterpriseUser,75-338-Office',Username='TestEnterpriseUser600r@statefarm.com.bad',Associate_ID__c='ppcczz33tta',UserExternalID__c='');
            enterpriseUser600 = UTIL_UserProvisioning_TEST.buildEnterpriseUser(testEntpUser);
            insert enterpriseUser600;
            User testLtdEntpUser = new User(Alias='Y6P2',LastName='601,LtdEnterpriseUser,75-338-Office',Username='TestLtdEnterpriseUser601r@statefarm.com.bad',Associate_ID__c='ppcczz33ttx',UserExternalID__c='');
            ltdEnterpriseUser601 = UTIL_UserProvisioning_TEST.buildLtdEnterpriseUser(testLtdEntpUser);
            insert ltdEnterpriseUser601;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,cccLicensedUser,cccUnlicensedUser,enterpriseUser600,ltdEnterpriseUser601});
 
            assignPermissionSet(enterpriseUser600, opportuntiyReadOnly);
            assignPermissionSet(ltdEnterpriseUser601, opportunityReadWrite);
            
            
        }
        
        acc = LWC_NewOppTaskCreateFlow_Test.buildAccountRecord('FST LST','111',agentUser.Id);
        insert acc;
        
        opp = LWC_NewOppTaskCreateFlow_Test.buildOpportunityRecord (acc.id,'Auto-Private Passenger',proxyUser.Id);
        insert opp; 
        
        
        //Insert agent role to give account access to the Agent
        AgentRole__c agentRole;
        System.runAs(agentUser) {
            agentRole = buildAgentRoleRecord(acc.Id);
        }
        insert agentRole;
        
    }
    
    /**
     * @description queryTestData
     */
    //Query the test data
    public static void queryTestData() {
        agentUser = [Select Id,Associate_ID__c from User where username = 'TestAgentUser@statefarm.com.bad'];
        adminUser = [Select Id,Associate_ID__c from User where username = 'TestAdminUser@statefarm.com.bad'];
        cccLicensedUser = [Select Id,Associate_ID__c from User where username = 'TestCCCUser@statefarm.com.bad'];
        cccUnlicensedUser = [Select Id,Associate_ID__c from User where username = 'TestCCC301User@statefarm.com.bad'];
        enterpriseUser600 = [Select Id,Associate_ID__c from User where username = 'TestEnterpriseUser600r@statefarm.com.bad'];
        ltdEnterpriseUser601 = [Select Id,Associate_ID__c from User where username = 'TestLtdEnterpriseUser601r@statefarm.com.bad'];
        proxyUser = [Select Id,Associate_ID__c from User where username = 'TestProxyUser@statefarm.com.bad'];
        acc = [Select Id,ClientIdentifier__c, Name from Account where lastname = 'LST'];
        opp = [Select Id from Opportunity Limit 1 ];
    }
    
    
    @isTest public static void testOpportunityUpdatedAndTaskCreatedWhenSubjectPassedAgent() {
        queryTestData();
        System.runAs(agentUser) {
            LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable();
            LWC_NewOppTaskCreateFlow.DataToSave data = new LWC_NewOppTaskCreateFlow.DataToSave();
            data.recordId = opp.Id;
            data.dueDate = Date.today();
            data.subject = 'Test Subject';
            data.status = 'Quote In Progress';
            data.subStatus = null;
            ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOppTaskCreateFlow.saveTask(JSON.serialize(data)),ApexResponse.class);
            Opportunity updatedOpp = [SELECT Id, Status__c, Sub_Status__c FROM Opportunity WHERE Id = :opp.Id];
            Task task = [SELECT Id, Subject, ActivityDate FROM Task WHERE WhatId = :opp.Id];
            System.assertEquals('Success',response.status, 'Expected value not same as the actual value');
            System.assertEquals(data.status, updatedOpp.Status__c, 'Expected Status__c not equal to Actual');
            System.assertEquals(data.subStatus, updatedOpp.Sub_Status__c, 'Expected Sub_Status__c not equal to Actual');
            System.assertEquals(data.subject, task.Subject, 'Expected Subject not equal to Actual');
            System.assertEquals(data.dueDate, task.ActivityDate, 'Expected ActivityDate not equal to Actual');
            System.assertEquals(3,LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable(), 'Expected value not same as the actual value');
            
        }
    }
    
    
    @isTest public static void testOpportunityUpdatedAndTaskNotCreatedWhenSubjectNotPassedAgent() {
        queryTestData();
        System.runAs(agentUser) {
            LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable();
            LWC_NewOppTaskCreateFlow.DataToSave data = new LWC_NewOppTaskCreateFlow.DataToSave();
            data.recordId = opp.Id;
            data.dueDate = Date.today();
            data.status = 'Quote In Progress';
            data.subStatus = null; 
            ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOppTaskCreateFlow.saveTask(JSON.serialize(data)),ApexResponse.class);
            Opportunity updatedOpp = [SELECT Id, Status__c, Sub_Status__c FROM Opportunity WHERE Id = :opp.Id];
            List<Task> task = [SELECT Id, Subject, ActivityDate FROM Task WHERE WhatId = :opp.Id];
            System.assertEquals('Success',response.status, 'Expected value not same as the actual value');
            System.assertEquals(data.status, updatedOpp.Status__c, 'Expected Status__c not equal to Actual');
            System.assertEquals(data.subStatus, updatedOpp.Sub_Status__c, 'Expected Sub_Status__c not equal to Actual');
            System.assertEquals(0, task.size(), 'Expected value not same as the actual value');
            System.assertEquals(3,LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable(), 'Expected value not same as the actual value');
        }
    }
    
    @isTest public static void testOppUpdateandTaskNotCreated601() {
        queryTestData();
        System.runAs(ltdEnterpriseUser601) {
            LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable();
            LWC_NewOppTaskCreateFlow.DataToSave data = new LWC_NewOppTaskCreateFlow.DataToSave();
            data.recordId = opp.Id;
            data.status = 'Quote In Progress';
            data.subStatus = null;
            ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOppTaskCreateFlow.saveTask(JSON.serialize(data)),ApexResponse.class);
            Opportunity updatedOpp = [SELECT Id, Status__c, Sub_Status__c FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals('Success',response.status, 'Expected value not same as the actual value');
            System.assertEquals(data.status, updatedOpp.Status__c, 'Expected Status__c not equal to Actual');
            System.assertEquals(data.subStatus, updatedOpp.Sub_Status__c, 'Expected Sub_Status__c not equal to Actual');
            System.assertEquals(1,LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable(), 'Expected value not same as the actual value');
        }
    }
    
     @isTest public static void testOnlyTaskCreatedWhenSubjectPassed301() {
        queryTestData();
        System.runAs(cccUnlicensedUser) {
            LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable();
            LWC_NewOppTaskCreateFlow.DataToSave data = new LWC_NewOppTaskCreateFlow.DataToSave();
            data.recordId = opp.Id;
            data.dueDate = Date.today();
            data.subject = 'Test Subject';
            ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOppTaskCreateFlow.saveTask(JSON.serialize(data)),ApexResponse.class);
            Task task = [SELECT Id, Subject, ActivityDate FROM Task WHERE WhatId = :opp.Id];
            System.assertEquals('Success',response.status, 'Expected value not same as the actual value');
            System.assertEquals(data.subject, task.Subject, 'Expected Subject not equal to Actual');
            System.assertEquals(data.dueDate, task.ActivityDate, 'Expected ActivityDate not equal to Actual');
            System.assertEquals(2,LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable(), 'Expected value not same as the actual value');
        }
    }
    
      
    @isTest public static void testTaskExpection() {
        queryTestData();
        System.runAs(cccLicensedUser) {
            LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable();
            LWC_NewOppTaskCreateFlow.DataToSave data = new LWC_NewOppTaskCreateFlow.DataToSave();
            data.recordId = '0023F00000AKd95QAD';
            data.status = 'Quote In Progress';
            ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOppTaskCreateFlow.saveTask(JSON.serialize(data)),ApexResponse.class);
            System.assertEquals('Error',response.status, 'Expected value not same as the actual value');
            System.assertEquals(3,LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable(), 'Expected value not same as the actual value');
        }
    }
    
    @isTest public static void testEnterpriser600() {
        queryTestData();
        System.runAs(enterpriseUser600) {
            LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable();
            System.assertEquals(-1,LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable(), 'Expected value not same as the actual value');  
        }
    }
    
    @isTest public static void testOpportunityStageUpdatedAgent() {
        queryTestData();
        System.runAs(agentUser) { 
            LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable();
            ApexResponse response;
            response = (ApexResponse)JSON.deserialize(LWC_NewOppTaskCreateFlow.saveStage(opp.Id, 'Quoting'),ApexResponse.class);
            Opportunity updatedOpp = [SELECT Id, StageName, Status__c, Sub_Status__c FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals('Quoting', updatedOpp.StageName, 'Expected StageName not equal to Actual');
            System.assertEquals(null, updatedOpp.Status__c, 'Expected Status__c not equal to Actual');
            System.assertEquals(null, updatedOpp.Sub_Status__c, 'Expected Sub_Status__c not equal to Actual');
            System.assertEquals(3,LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable(), 'Expected value not same as the actual value');
        }
    }
    
    @isTest public static void testOpportunityStageUpdatedAgentRFCGranted() {
        queryTestData();
        System.runAs(agentUser) {      
            Opportunity opp = new Opportunity(Name = 'Auto-Private Passenger',
                                              AccountId = acc.id, 
                                              LOB__c = 'Auto', 
                                              Product__c = 'Private Passenger',
                                              Requested_Effective_Date__c = Date.today(),
                                              StageName = 'Closed',
                                              CloseDate = Date.today()+60,
                                              ownerId = proxyUser.Id,
                                              Credit_Status__c = 'RFC Granted');
            
            insert opp;
            ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOppTaskCreateFlow.saveStage(opp.Id, 'Quoting'),ApexResponse.class);
            System.assertEquals('Error',response.status, 'Expected value not same as the actual value');
        }
    }
    
     @isTest public static void testOpportunityStageUpdated300() {
        queryTestData();
        System.runAs(cccLicensedUser) { 
            LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable();
            ApexResponse response;
            response = (ApexResponse)JSON.deserialize(LWC_NewOppTaskCreateFlow.saveStage(opp.Id, 'Quoting'),ApexResponse.class);
            Opportunity updatedOpp = [SELECT Id, StageName, Status__c, Sub_Status__c FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals('Quoting', updatedOpp.StageName, 'Expected StageName not equal to Actual');
            System.assertEquals(null, updatedOpp.Status__c, 'Expected Status__c not equal to Actual');
            System.assertEquals(null, updatedOpp.Sub_Status__c, 'Expected Sub_Status__c not equal to Actual');
            System.assertEquals(3,LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable(), 'Expected value not same as the actual value');
        }
    }

     @isTest public static void testOpportunityStageUpdated301() {
        queryTestData();
        System.runAs(cccUnlicensedUser) { 
            ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOppTaskCreateFlow.saveStage(opp.Id, 'Quoting'),ApexResponse.class);
            System.assertEquals('Error',response.status, 'Expected value not same as the actual value');   
        }
    }
  
    
    @isTest public static void testStageExpection() {
        queryTestData();
        System.runAs(cccLicensedUser) {
            ApexResponse response = (ApexResponse)JSON.deserialize( LWC_NewOppTaskCreateFlow.saveStage('0023F00000AKd95QAD', 'Quoting'),ApexResponse.class);
            System.assertEquals('Error',response.status, 'Expected value not same as the actual value');
            System.assertEquals(3,LWC_NewOppTaskCreateFlow.isOppCreatableAndisTaskCreatable(), 'Expected value not same as the actual value');
        }
    }
    
    // class for ApexResponse
    private with sharing class ApexResponse {

        /**
         * @description status
         */
        public String status{get;set;}

        /**
         * @description message
         */
        public String message{get;set;}
    }
}