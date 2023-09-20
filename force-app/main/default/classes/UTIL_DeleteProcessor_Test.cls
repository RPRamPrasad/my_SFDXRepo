/**
* @Name: UTIL_DeleteProcessor_Test
* @Author: Loco Motivated
* @Description: This class contains unit tests for Delete Processor
* @Date: 10/04/2016
*/

/**
* @Name: UTIL_DeleteProcessor_Test
* @Author: Loco Motivated
* @Description: updating the class for C2C updates
* @Date: 4/04/2017
*/

/**
@Author: Team Golden Spikes - Updated to test the planning conversation log records delete.
@ModifiedDate: 5/16/2018
*/

/**
 * @Author: Pike - Updated tests to create task using a valid profile
 * @ModifiedDate: 1/16/2019
 */

/**
@Author: Team Golden Spikes - Updated to test the lead records delete.
@ModifiedDate: 10/15/2019
*/

/**
 * @description This class contains unit tests for Delete Processor
 */
@isTest(seeAllData=false)
public class UTIL_DeleteProcessor_Test {
    private static Account acc;
    private static Account acc1;
    private static string jsonString;
    private static AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting;
    private static Contact testcontact;
    /*private static Task testTask1;
    private static Task testTask2;*/
    private static List<CustomerGroupMember__C> testGroupMember = new List<CustomerGroupMember__C>();
    private static List<AgentContext__c> testAgentContext = new List<AgentContext__c>();
    private static CustomerGroup__C testGroup;
    private static List<Relationship__c> testRelationship2=new List<Relationship__c>();
    private static Campaign cam;
    private static CampaignMember cmember1;
    private static LeadMetrics__c leadMetric;
    private static List<Task> tasklist=new List<Task>();
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();
    private static UTIL_DeleteProcessor_Wrapper delProcWrap = new UTIL_DeleteProcessor_Wrapper();

    /**
     * @description test method used for setup for user id setting
     */
    @TestSetup
    public static void setup(){
        delProcWrap.counts= new CS_StageOrchestration_Counts__c(Retry_Count__c=3,Chunk_Size__c=5);
        delProcWrap.systemUser = UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');
        delProcWrap.testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','test@statefarm.com');

        UTIL_StageOrchestrationTestUtils.AgentUserWrapper agentWrap = new UTIL_StageOrchestrationTestUtils.AgentUserWrapper();
        agentWrap.a_alias = 'echo';
        agentWrap.a_lastName = 'lastname';
        agentWrap.a_UserName = 'agentUser@statefarm.com';
        agentWrap.a_associateId = 'associate11';
        agentWrap.a_userExternalId = 'externId';
        agentWrap.a_servicingAgentAssocId = 'associate11';

        delProcWrap.agentUser = UTIL_StageOrchestrationTestUtils.buildAgentUser(agentWrap);
        insert delProcWrap.systemUser;
        insert delProcWrap.testAPIUser;
        insert delProcWrap.agentUser;
        delProcWrap.psassignment = UTIL_StageOrchestrationTestUtils.assignPSet(delProcWrap.testAPIUser);
        insert delProcWrap.psassignment;

        TestDataFactory_CustomSetting.createDeleteRecordConfig('1.03 SF API Only User - Data & User Admin', 'Account');
        TestDataFactory_CustomSetting.createDeleteRecordConfig('1.03 SF API Only User - Data & User Admin', 'Opportunity');
        delProcWrap.salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        System.runAs(delProcWrap.systemUser) {
            sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(SFDC_USER_ID__c=delProcWrap.systemUser.id);
            insert sysAdminUserIdSetting;
            insert delProcWrap.counts;
        }
    }

    private static void getUsers(){
        jsonString ='{"orchestrationInfo" : {"jsonVersionNumber" : "1.0","orchestrationEventName" : {"orchestrationEventType" : "Record Remove- Delete","orchestrationEventDetail" : {"orchestrationEventValues" : { "clientId" : "'+delProcWrap.clientIdentifier+'" }}}}}';
        List<User> userList = [Select Id, Name, Associate_Id__c, Servicing_Agent_associate_id__c, UserExternalId__c, Alias, email, username, Profile.name From User Where alias in ('echo','test','Alias')];
        for(User usr : userList){
            if(usr.alias == 'Alias'){
                delProcWrap.systemUser = usr;
            }
            else if(usr.alias == 'test'){
                delProcWrap.testAPIUser = usr;
            }
            else if(usr.alias == 'echo'){
                delProcWrap.agentUser = usr;
            }
        }
        delProcWrap.salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
    }

    /**
     * @description test method used for create account contact and group data
     */
    public static void createAccountContactAndGroupData(){
        acc = new Account(FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c=delProcWrap.clientIdentifier);
        acc1 = new Account(FirstName='Ftest1',LastName='Ltest1',BillingAddressType__c='US',ClientIdentifier__c=delProcWrap.clientIdentifier1);
        testGroup = new CustomerGroup__c(SFGroupIdentifier__C='76893567431',agent__c=delProcWrap.salesRoleHierarchy1.Agent.id,GroupCategory__c='Primary');
    }

    /**
     * @description test method used for create task data
     */
    public static void createTaskData(){
        delProcWrap.testTask1 = new Task (WhatId=acc.Id, subject='Call',Priority='No', OwnerId =delProcWrap.agentUser.id,ActivityDate = Date.today(),Description='TASK111', status='Not Started',TaskCategory__c='Alert');
        delProcWrap.testTask2 = new Task (WhatId=acc.Id, Description='TASK333', status='Started', Subject='Send Quote',Priority='Yes', OwnerId =delProcWrap.agentUser.id,ActivityDate =Date.newInstance(2016, 12, 25), TaskCategory__c='Alert');
        tasklist.add(delProcWrap.testTask1);
        tasklist.add(delProcWrap.testTask2);
        tasklist.add(new Task (WhatId=acc.Id, Description='TASK222', status=UTIL_StageOrchestrationConstants.TASK_CLOSED_STATUS, Subject='Send Letter',Priority='No', OwnerId =delProcWrap.agentUser.id,ActivityDate =Date.newInstance(2018, 07, 07), TaskCategory__c='Alert'));
        insert tasklist;
    }

    /**
     * @description test method used for create case data
     */
    public static void createCaseData(){
        delProcWrap.testCase1 = new Case (AccountId=acc.Id, status='New', Case_Originator__c = 'CCC Sales', OwnerId =delProcWrap.systemUser.id);
        delProcWrap.caselist.add(delProcWrap.testCase1);
        delProcWrap.caselist.add(new Case (AccountId=acc.Id, status='New', Case_Originator__c = 'CCC Sales', OwnerId =delProcWrap.systemUser.id));
        delProcWrap.caselist.add(new Case (AccountId=acc.Id, status='New', Case_Originator__c = 'CCC Sales', OwnerId =delProcWrap.systemUser.id));
        insert delProcWrap.caselist;
    }

    /**
     * @description test method used for create lead data
     */
    public static void createLeadData() {
        Lead refLead = new Lead(LastName = 'TestReferralLd-1', CustomerReferrer__c = acc.id, ownerId = delProcWrap.salesRoleHierarchy1.agentOffice.id,
        recordtypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName().get('SF_Referral').getRecordTypeId());
        insert refLead;
    }

    /**
     * @description test method used for create lead metric data
     */
    public static void createLeadMetricData() {
        leadMetric = new LeadMetrics__c(LeadName__c = 'TestReferralLd-1', CustomerReferrer__c = acc.id, ownerId = delProcWrap.salesRoleHierarchy1.agentOffice.id);
        insert leadMetric;
    }

    /**
     * @description test method used for create opportunity data
     */
    public static void createOpportunityData(){
        delProcWrap.oppList.add(new Opportunity (Name='newoppty1',AccountId=acc.Id,Type='ABC', StageName='Needs Analysis', LOB__c='Auto', ForecastCategoryName='Pipeline',RecordTypeId=optyRecordTypeId, CloseDate=Date.today()));
        delProcWrap.oppList.add(new Opportunity (Name='newoppty2',AccountId=acc.Id,Type='ABC', StageName='Needs Analysis', LOB__c='Auto', ForecastCategoryName='Pipeline',RecordTypeId=optyRecordTypeId, CloseDate=Date.today()));
        insert delProcWrap.oppList;
        SalesAttempt__c sc1 = new SalesAttempt__c(Opportunity__c = delProcWrap.oppList.get(0).id);
        insert sc1;
    }

    /**
     * @description test method used for create campaign data
     */
    public static void createCampaignData(){
        cam = new Campaign(Name ='testCampaign', Type = 'Lead');
        insert cam;
    }

    /**
     * @description test method used for create campaign member data
     */
    public static void createCampaignMemberData(){
        testcontact = [Select Id from Contact Where FirstName=:acc.FirstName];
        cmember1 = new CampaignMember (CampaignId=cam.Id,Status='Sent',ContactId=testcontact.Id);
        insert cmember1;
    }

    /**
     * @description test method used to create relationship data
     */
    public static void createRealtionshipData(){
        testRelationship2.add(new Relationship__c (AccountTwo__c=acc.id,AccountOne__c=acc1.id,RelationshipType__c='Son',RelationshipIdentifier__c=acc.ClientIdentifier__c+'~'+acc1.ClientIdentifier__c));
        testRelationship2.add(new Relationship__c (AccountTwo__c=acc1.id,AccountOne__c=acc.id,RelationshipType__c='Parent',RelationshipIdentifier__c=acc1.ClientIdentifier__c+'~'+acc.ClientIdentifier__c));
        insert testRelationship2;
    }

    /**
     * @description test method used to create group member test data
     */
    public static void createGroupMemberTestData(){
        testGroupMember.add(new CustomerGroupMember__C (Customer__c=acc.id, Group__C=testGroup.Id,GroupMemberId__c='76893567431'+acc.ClientIdentifier__c));
        insert testGroupMember;
    }

    /**
     * @description test method used to create agent context test data
     */
    public static void createAgentContextTestData(){
        testAgentContext.add(new AgentContext__c (Customer__c=acc.id,AgentContextIdentifier__c=delProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C+'~'+acc.ClientIdentifier__c));
        testAgentContext.add(new AgentContext__c (Customer__c=acc1.id,AgentContextIdentifier__c=delProcWrap.salesRoleHierarchy1.Agent.Associate_ID__C+'~'+acc1.ClientIdentifier__c));
        insert testAgentContext;
    }

    @isTest
    static void testDeleteProcessorWithAllData(){
        UTIL_DeleteProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMERGROUPINGS,true);
        getUsers();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            createAccountContactAndGroupData();
            insert acc;
            insert acc1;
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=acc.id, agent__c=delProcWrap.salesRoleHierarchy1.Agent.Id,agentroleIdentifier__c=delProcWrap.salesRoleHierarchy1.Agent.Associate_ID__c+'~'+delProcWrap.clientIdentifier);
            insert newAgentRole;
            delProcWrap.assignedStaff = new AssignedStaff__c(Agent__c = delProcWrap.salesRoleHierarchy1.Agent.id, Customer__c = acc.id, Staff__c = delProcWrap.salesRoleHierarchy1.AgentTeamMember.id,
            AssignedStaffIdentifier__c = acc.ClientIdentifier__c+'~'+delProcWrap.salesRoleHierarchy1.Agent.Associate_ID__c+'~'+delProcWrap.salesRoleHierarchy1.agentTeamMember.Associate_ID__c);
            insert delProcWrap.assignedStaff;
            insert testGroup;
            insert new LeadConversionDetail__c(Customer__c=acc.id,Name=acc.Name);
            createCaseData();
            createOpportunityData();
            CS001_ByPassTriggerGtoZ__c leadTriggerBypass = new CS001_ByPassTriggerGtoZ__c(Override_LeadBeforeInsert__c = true, Override_LeadAfterInsert__c = true, Override_LeadAfterUpdate__c = true, Override_LeadAfterDelete__c = true);
            insert leadTriggerBypass;
            createLeadData();
            createLeadMetricData();
            createCampaignData();
            createCampaignMemberData();
            createRealtionshipData();
            createGroupMemberTestData();
            createAgentContextTestData();
        }

        System.runAs(delProcWrap.salesRoleHierarchy1.Agent) {
            createTaskData();
        }

        System.runAs(delProcWrap.testAPIUser){
            Test.startTest();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c=1.0;
            stgorc.Value__c=jsonString;
            insert stgorc;
            Test.stopTest();
            //system.debug(delProcWrap.testTask2);
        }
          List<AssignedStaff__c> assignedStaffList = [select id from AssignedStaff__c where id = :delProcWrap.assignedStaff.id];
        system.assert(assignedStaffList.isEmpty(), 'List<AssignedStaff__c> is not empty');
        verifyAllChildClosed();
        
    }
    
        
       static void verifyAllChildClosed(){
         //system.debug('delProcWrap.testTask2.id :'+  delProcWrap.testTask2.id);
        Task t3 = [Select Id, status, whatId FROM Task WHERE id=:delProcWrap.testTask2.id LIMIT 1];  
        system.assertEquals('Cancelled', t3.status, 'Task status is not Cancelled');
        Case c1 = [Select Id, status,ownerId FROM Case WHERE id=:delProcWrap.testCase1.id LIMIT 1];
        system.assertEquals('Closed', c1.status, 'Case Status is not Closed');
        system.assertEquals(delProcWrap.systemUser.Id, c1.ownerId, 'Expected owner Id is not equals to actual owner Id');
        List<Opportunity> delOppty = [Select Id FROM Opportunity Where AccountId=:acc.Id];
        system.assertEquals(0, delOppty.size(), 'Size of List<Opportunity> is not equals to 0');
        List<SalesAttempt__c> delSalesAttemptForOpportunity = [Select Id From SalesAttempt__c];
        system.assertEquals(0,delSalesAttemptForOpportunity.size(), 'Size of List<SalesAttempt__c> is not equals to 0');
        List<Lead> delLead = [Select Id FROM Lead Where CustomerReferrer__c =: acc.Id];
        system.assertEquals(0, delLead.size(), 'Size of List<Lead> is not equals to 0');
        LeadMetrics__c ldMetricRecordAfterUpdate = [Select Id, Status__c, LeadDeletedBy__c, LeadDeletionDate__c from LeadMetrics__c Where Id =: leadMetric.Id limit 1];
        System.assertEquals('Deleted', ldMetricRecordAfterUpdate.Status__c, 'Status is Incorrect');
        System.assertEquals(delProcWrap.testAPIUser.Id, ldMetricRecordAfterUpdate.LeadDeletedBy__c, 'Lead Metric Deleted By is Incorrect');
        System.assert(ldMetricRecordAfterUpdate.LeadDeletionDate__c != null, 'Lead Metric DeletedDate is Incorrect');

        List<LeadConversionDetail__c> delLeadConLst =[select id from LeadConversionDetail__c where customer__c=:acc.id];
        system.assertEquals(0, delLeadConLst.size(), 'Size of List<LeadConversionDetail__c> not equals to 0');
        List<Relationship__c> delRlshp =[select id from Relationship__c where AccountOne__c=:acc.id or AccountTwo__c=:acc.id];
        system.assert(delRlshp.isEmpty(), 'List<Relationship__c> is not empty');
        List<AgentContext__c> agentContextList = [select id from AgentContext__c where Customer__c=:acc.id];
        system.assert(agentContextList.isEmpty(), 'List<AgentContext__c> is not empty');
        List<Account> testacc = [Select Id From account Where id=:acc.Id];
        system.assert(testacc.isEmpty(), 'List<Account> is not empty');
       
        }

    @isTest
    static void testDeleteProcessorWithNoagentContextData(){
        UTIL_DeleteProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMERGROUPINGS,true);
        getUsers();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            createAccountContactAndGroupData();
            insert acc;
            insert acc1;
            insert testGroup;
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=acc.id, agent__c=delProcWrap.salesRoleHierarchy1.Agent.Id,agentroleIdentifier__c=delProcWrap.salesRoleHierarchy1.Agent.Associate_ID__c+'~'+delProcWrap.clientIdentifier);
            insert newAgentRole;
            insert new LeadConversionDetail__c(Customer__c=acc.id,Name=acc.Name);
            createCaseData();
            createOpportunityData();
            CS001_ByPassTriggerGtoZ__c leadTriggerBypass = new CS001_ByPassTriggerGtoZ__c(Override_LeadBeforeInsert__c = true, Override_LeadAfterInsert__c = true, Override_LeadAfterUpdate__c = true, Override_LeadAfterDelete__c = true);
            insert leadTriggerBypass;
            createLeadData();
            createLeadMetricData();
            createCampaignData();
            createCampaignMemberData();
            createRealtionshipData();
            createGroupMemberTestData();
        }

        System.runAs(delProcWrap.salesRoleHierarchy1.Agent) {
            createTaskData();
        }

        System.runAs(delProcWrap.testAPIUser){
            Test.startTest();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c=1.0;
            stgorc.Value__c=jsonString;
            insert stgorc;
            Test.stopTest();
        }

        List<CustomerGroupMember__c> actualGroupMember=[select id from Customergroupmember__C where id IN: testGroupMember];
        system.assert(actualGroupMember.isEmpty(), 'List<CustomerGroupMember__c> is not empty');
        verifyAllChildClosed();

            }

    @isTest
    static void  testCustomerGroupingsWithToggleDisabledWithNoGroupingData() {
        UTIL_DeleteProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMERGROUPINGS,false);
        getUsers();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            createAccountContactAndGroupData();
            insert acc; 
            insert acc1;
            insert testGroup;
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=acc.id, agent__c=delProcWrap.salesRoleHierarchy1.Agent.Id,agentroleIdentifier__c=delProcWrap.salesRoleHierarchy1.Agent.Associate_ID__c+'~'+delProcWrap.clientIdentifier);
            insert newAgentRole;
            insert new LeadConversionDetail__c(Customer__c=acc.id,Name=acc.Name);
            createCaseData();
            createOpportunityData();
            CS001_ByPassTriggerGtoZ__c leadTriggerBypass = new CS001_ByPassTriggerGtoZ__c(Override_LeadBeforeInsert__c = true, Override_LeadAfterInsert__c = true, Override_LeadAfterUpdate__c = true, Override_LeadAfterDelete__c = true);
            insert leadTriggerBypass;
            createLeadData();
            createLeadMetricData();
            createCampaignData();
            createCampaignMemberData();
            createRealtionshipData();
        }
        System.runAs(delProcWrap.salesRoleHierarchy1.Agent) {
            createTaskData();
        }
        System.runAs(delProcWrap.testAPIUser){
            Test.startTest();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c=1.0;
            stgorc.Value__c=jsonString;
            insert stgorc;
            Test.stopTest();
        }
        List<CustomerGroupMember__c> actualGroupMember=[select id from Customergroupmember__C where id IN: testGroupMember];
        system.assert(actualGroupMember.isEmpty(), 'List<CustomerGroupMember__c> is not empty');
        verifyAllChildClosed();
    }

    @isTest
    static void testDeleteProcessorWithOnlyAccountData(){
        getUsers();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            createAccountContactAndGroupData();
            insert acc;
        }

        System.runAs(delProcWrap.testAPIUser){
            Test.startTest();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c=1.0;
            stgorc.Value__c=jsonString;
            insert stgorc;
            Test.stopTest();
        }

        List<Account> testacc = [Select Id From account Where id=:acc.Id];
        system.assertEquals(0,testacc.size(), 'Size of List<Account> is not equals to 0');
    }

    @isTest
    static void testDeleteProcessorWithOutTaskData(){
        getUsers();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            createAccountContactAndGroupData();
            insert acc;
            insert acc1;
            createRealtionshipData();
            createCaseData();
            createOpportunityData();
            CS001_ByPassTriggerGtoZ__c leadTriggerBypass = new CS001_ByPassTriggerGtoZ__c(Override_LeadBeforeInsert__c = true, Override_LeadAfterInsert__c = true, Override_LeadAfterUpdate__c = true, Override_LeadAfterDelete__c = true);
            insert leadTriggerBypass;
            createLeadData();
            createLeadMetricData();
            createCampaignData();
            createCampaignMemberData();
        }

        System.runAs(delProcWrap.testAPIUser){
            Test.startTest();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c=1.0;
            stgorc.Value__c=jsonString;
            insert stgorc;
            Test.stopTest();
        }

        Case c1 = [Select Id, status,ownerId FROM Case WHERE id=:delProcWrap.testCase1.id LIMIT 1];
        system.assertEquals('Closed', c1.status, 'Case status is not Closed');
        system.assertEquals(delProcWrap.systemUser.Id, c1.ownerId, 'Expected owner Id is not equals to the actual owner Id');
        List<Opportunity> delOppty = [Select Id FROM Opportunity Where AccountId=:acc.Id];
        system.assertEquals(0, delOppty.size(), 'Size of List<Opportunity> is not equals to 0');
        List<SalesAttempt__c> delSalesAttemptForOpportunity = [Select Id From SalesAttempt__c];
        system.assertEquals(0,delSalesAttemptForOpportunity.size(), 'Size of List<SalesAttempt__c> is not equals to 0');
        List<Lead> delLead = [Select Id FROM Lead Where CustomerReferrer__c =: acc.Id];
        system.assertEquals(0, delLead.size(), 'Size of List<Lead> is not equals to 0');
        LeadMetrics__c ldMetricRecordAfterUpdate = [Select Id, Status__c, LeadDeletedBy__c, LeadDeletionDate__c from LeadMetrics__c Where Id =: leadMetric.Id limit 1];
        System.assertEquals('Deleted', ldMetricRecordAfterUpdate.Status__c, 'Status is Incorrect');
        System.assertEquals(delProcWrap.testAPIUser.Id, ldMetricRecordAfterUpdate.LeadDeletedBy__c, 'Lead Metric Deleted By is Incorrect');
        System.assert(ldMetricRecordAfterUpdate.LeadDeletionDate__c != null, 'Lead Metric DeletedDate is Incorrect');
        List<CampaignMember> delCM = [Select Id FROM CampaignMember Where ContactId=:acc.PersonContactId];
        system.assertEquals(0, delCM.size(), 'Size of List<CampaignMember> is not equals to 0');
        List<Relationship__c> delRlshp =[select id from Relationship__c where AccountOne__c=:acc.id or AccountTwo__c=:acc.id];
        system.assert(delRlshp.isEmpty(), 'List<Relationship__c> is not empty');
        List<Account> testacc = [Select Id From account Where id=:acc.Id];
        system.assert(testacc.isEmpty(), 'List<Account> is not empty');
    }

    @isTest
    static void testDeleteProcessorwithAccountandCaseData(){
        getUsers();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            createAccountContactAndGroupData();
            insert acc;
            createCaseData();
        }

        System.runAs(delProcWrap.testAPIUser){
            Test.startTest();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c=1.0;
            stgorc.Value__c=jsonString;
            insert stgorc;
            Test.stopTest();
        }

        List<Account> testacc = [Select Id From account Where id=:acc.Id];
        system.assertEquals(0,testacc.size(), 'Size of List<Account> is not equals to 0');
        Case c1 = [Select Id, status,ownerId FROM Case WHERE id=:delProcWrap.testCase1.id LIMIT 1];
        system.assertEquals('Closed', c1.status, 'Case status is not Closed');
        system.assertEquals(delProcWrap.systemUser.Id, c1.ownerId, 'Expected owner Id is not equals to actual owner Id');
    }

    @isTest
    static void testDeleteProcessorWithOutOppData(){
        getUsers();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            createAccountContactAndGroupData();
            insert acc;
            insert acc1;
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=acc.id, agent__c=delProcWrap.salesRoleHierarchy1.Agent.Id,agentroleIdentifier__c=delProcWrap.salesRoleHierarchy1.Agent.Associate_ID__c+'~'+delProcWrap.clientIdentifier);
            insert newAgentRole;
            createCaseData();
            createRealtionshipData();
            CS001_ByPassTriggerGtoZ__c leadTriggerBypass = new CS001_ByPassTriggerGtoZ__c(Override_LeadBeforeInsert__c = true, Override_LeadAfterInsert__c = true, Override_LeadAfterUpdate__c = true, Override_LeadAfterDelete__c = true);
            insert leadTriggerBypass;
            createLeadData();
            createLeadMetricData();
            createCampaignData();
            createCampaignMemberData();
        }

        System.runAs(delProcWrap.salesRoleHierarchy1.Agent) {
            createTaskData();
        }

        System.runAs(delProcWrap.testAPIUser){
            Test.startTest();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c=1.0;
            stgorc.Value__c=jsonString;
            insert stgorc;
            Test.stopTest();
        }
        verifyAllChildClosed1();
        List<Relationship__c> delRlshp =[select id from Relationship__c where AccountOne__c=:acc.id or AccountTwo__c=:acc.id];
        system.assert(delRlshp.isEmpty(), 'List<Relationship__c> is not empty');
    }
        static void verifyAllChildClosed1()
        {
        Task t1 = [Select Id, status FROM Task WHERE id=:delProcWrap.testTask1.id LIMIT 1];
        system.assertEquals('Cancelled', t1.status, 'Task status is not Cancelled');
        Case c1 = [Select Id, status,ownerId FROM Case WHERE id=:delProcWrap.testCase1.id LIMIT 1];
        system.assertEquals('Closed', c1.status, 'Case status is not Closed');
        system.assertEquals(delProcWrap.systemUser.Id, c1.ownerId, 'Expected owner Id is not equals to the actual owner Id');
        List<Lead> delLead = [Select Id FROM Lead Where CustomerReferrer__c =: acc.Id];
        system.assertEquals(0, delLead.size(), 'Size of List<Lead> is not equals to 0');
        LeadMetrics__c ldMetricRecordAfterUpdate = [Select Id, Status__c, LeadDeletedBy__c, LeadDeletionDate__c from LeadMetrics__c Where Id =: leadMetric.Id limit 1];
        System.assertEquals('Deleted', ldMetricRecordAfterUpdate.Status__c, 'Status is Incorrect');
        System.assertEquals(delProcWrap.testAPIUser.Id, ldMetricRecordAfterUpdate.LeadDeletedBy__c, 'Lead Metric Deleted By is Incorrect');
        System.assert(ldMetricRecordAfterUpdate.LeadDeletionDate__c != null, 'Lead Metric DeletedDate is Incorrect');
        List<CampaignMember> delCM = [Select Id FROM CampaignMember Where ContactId=:acc.PersonContactId];
        system.assert(delCM.isEmpty(), 'List<CampaignMember> is not empty');
        
        List<Account> testacc = [Select Id From account Where id=:acc.Id];
        system.assert(testacc.isEmpty(), 'List<Account> is not empty');
    }
    

    @isTest
    static void testDeleteProcessorWithOutCMData(){
        getUsers();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            createAccountContactAndGroupData();
            insert acc;
            insert acc1;
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=acc.id, agent__c=delProcWrap.salesRoleHierarchy1.Agent.Id,agentroleIdentifier__c=delProcWrap.salesRoleHierarchy1.Agent.Associate_ID__c+'~'+delProcWrap.clientIdentifier);
            insert newAgentRole;
            createCaseData();
            createOpportunityData();
            createRealtionshipData();
        }

        System.runAs(delProcWrap.salesRoleHierarchy1.Agent) {
            createTaskData();
        }

        System.runAs(delProcWrap.testAPIUser){
            Test.startTest();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c=1.0;
            stgorc.Value__c=jsonString;
            insert stgorc;
            Test.stopTest();
        }

        Task t3 = [Select Id, status FROM Task WHERE id=:delProcWrap.testTask2.id LIMIT 1];
        system.assertEquals('Cancelled', t3.status, 'Task status is not Cancelled');
        Case c1 = [Select Id, status,ownerId FROM Case WHERE id=:delProcWrap.testCase1.id LIMIT 1];
        system.assertEquals('Closed', c1.status, 'Case status is not Closed');
        system.assertEquals(delProcWrap.systemUser.Id, c1.ownerId, 'Expected owner Id is not equals to the actual owner Id');
        List<Opportunity> delOppty = [Select Id FROM Opportunity Where AccountId=:acc.Id];
        system.assertEquals(0, delOppty.size(), 'Size of List<Opportunity> is not equals to 0');
        List<SalesAttempt__c> delSalesAttemptForOpportunity = [Select Id From SalesAttempt__c];
        system.assertEquals(0,delSalesAttemptForOpportunity.size(), 'Size of List<SalesAttempt__c> is not equals to 0');
        List<Relationship__c> delRlshp =[select id from Relationship__c where AccountOne__c=:acc.id or AccountTwo__c=:acc.id];
        system.assert(delRlshp.isEmpty(), 'List<Relationship__c> is not empty');
        List<Account> testacc = [Select Id From account Where id=:acc.Id];
        system.assertEquals(0, testacc.size(), 'Size of List<Account> is not equals to 0');
    }

    @isTest
    static void testDeleteProcessorWithOutRealtionshipsData(){
        getUsers();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            createAccountContactAndGroupData();
            insert acc;
            insert acc1;
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=acc.id, agent__c=delProcWrap.salesRoleHierarchy1.Agent.Id,agentroleIdentifier__c=delProcWrap.salesRoleHierarchy1.Agent.Associate_ID__c+'~'+delProcWrap.clientIdentifier);
            insert newAgentRole;
            createCaseData();
            createOpportunityData();
            CS001_ByPassTriggerGtoZ__c leadTriggerBypass = new CS001_ByPassTriggerGtoZ__c(Override_LeadBeforeInsert__c = true, Override_LeadAfterInsert__c = true, Override_LeadAfterUpdate__c = true, Override_LeadAfterDelete__c = true);
            insert leadTriggerBypass;
            createLeadData();
            createLeadMetricData();
            createCampaignData();
            createCampaignMemberData();
        }

        System.runAs(delProcWrap.salesRoleHierarchy1.Agent) {
            createTaskData();
        }

        System.runAs(delProcWrap.testAPIUser){
            Test.startTest();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c=1.0;
            stgorc.Value__c=jsonString;
            insert stgorc;
            Test.stopTest();
        }

        verifyAllChildClosed1();
        List<Opportunity> delOppty = [Select Id FROM Opportunity Where AccountId=:acc.Id];
        system.assertEquals(0, delOppty.size(), 'Size of List<Opportunity> is not equals to 0');
        List<SalesAttempt__c> delSalesAttemptForOpportunity = [Select Id From SalesAttempt__c];
        system.assertEquals(0,delSalesAttemptForOpportunity.size(), 'Size of List<SalesAttempt__c> is not equals to 0');
    }

    @isTest
    static void testDeleteProcessorWithEntityIsDeletedException(){
        UTIL_DeleteProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMERGROUPINGS,true);
        getUsers();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            createAccountContactAndGroupData();
            insert acc;
            insert acc1;
            createAgentContextTestData();
            delete testAgentContext;
        }

        System.runAs(delProcWrap.testAPIUser){
            Test.startTest();
            UTIL_DeleteProcessor deleteProcess=new UTIL_DeleteProcessor();
            deleteProcess.deletesObjectList(testAgentContext,'UTIL_DeleteProcessor','deleteProcessor');
            Test.stopTest();
            ExceptionLog__c results = [SELECT IsHandled__c,Class__c,Method__c,Exception_Message__c  FROM ExceptionLog__c
                                       where class__c like '%UTIL_DeleteProcessor%' limit 1];
            System.assertEquals('UTIL_DeleteProcessor' , results.Class__c, 'The given two parameters are not equal');
            System.assertEquals('deleteProcessor', results.Method__c, 'The given two parameters are not equal');
            System.assertEquals(true, results.IsHandled__c, '\'IsHandled__c\' is false');
            System.assertEquals('Records already deleted: '+testAgentContext.get(0).id+','+testAgentContext.get(1).id, results.Exception_Message__c, 'The given two parameters are not equal');
        }
    }

    @isTest
    static void testDeleteProcessorForAccountNotAvailableOnSFDC(){
        getUsers();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            createAccountContactAndGroupData();
            insert acc1;
        }

        System.runAs(delProcWrap.testAPIUser){
            Test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c=1.0;
            stgorc.Value__c=jsonString;
            stgorcList.add(stgorc);
            try{
                new UTIL_DeleteProcessor().execute(stgorcList);
                System.assert(true, 'Assertion returns false');
            }
            catch(StageProcessorException ex){
                System.assert(false, 'Assertion returns true');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testDeleteProcessorNullException(){
        getUsers();
        System.runAs(delProcWrap.testAPIUser) {
            Test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c=1.0;
            stgorc.Value__c=null;
            stgorcList.add(stgorc);
            try{
                new UTIL_DeleteProcessor().execute(stgorcList);
            }
            catch(StageProcessorException ex){
                System.assert(ex.getCause() instanceof InvalidInputException, 'Cause of exception is not an instance of InvalidInputException');
                System.assertEquals(UTIL_StageOrchestrationConstants.EMPTY_JSON_EXCEPTION_MESSAGE, ex.getMessage(), 'Expected exception message is not equals to the actual exception message');
            }
            Test.stopTest();
        }
    }

    //method to test Planning Conversation Log Records delete on the deletion of account
    @isTest
    private static void testDeleteProcessorForPlanningConvLog() {
        getUsers();
        List<PlanningConversationLog__c> planConvLog = new List<PlanningConversationLog__c>();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c  objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c(Override_All__c = true);
            insert objectBasedByPassTrigger;
            createAccountContactAndGroupData();
            insert acc;
            AgentRole__c agentRole = new AgentRole__c (customer__c = acc.id, agent__c = delProcWrap.salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            insert agentRole;
            SimpleConversation__c simpleConv1 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple1', Account__c = acc.id, Agent__c = delProcWrap.salesRoleHierarchy1.agent.id, ownerId = delProcWrap.salesRoleHierarchy1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv1;
            planConvLog.add(new PlanningConversationLog__c (Account__c = acc.id, Comments__c = 'Test Comments1', Agent__c = delProcWrap.salesRoleHierarchy1.agent.id, SimpleConversation__c = simpleConv1.id, ownerId = delProcWrap.salesRoleHierarchy1.agentOffice.id));
            planConvLog.add(new PlanningConversationLog__c (Account__c = acc.id, Comments__c = 'Test Comments2', Agent__c = delProcWrap.salesRoleHierarchy1.agent.id, SimpleConversation__c = simpleConv1.id, ownerId = delProcWrap.salesRoleHierarchy1.agentOffice.id));
            insert planConvLog;
        }

        Test.startTest();
        List<PlanningConversationLog__c> actualPlanConvListBefore = [Select id, ownerId from PlanningConversationLog__c];
        System.assertEquals(2, actualPlanConvListBefore.size(), 'Size of List<PlanningConversationLog__c> is not equals to 2');
        System.runAs(delProcWrap.testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c = UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c = 1.0;
            stgorc.Value__c = jsonString;
            //insert stgorc;
            stgorcList.add(stgorc);
            new UTIL_DeleteProcessor().execute(stgorcList);
        }
        List<PlanningConversationLog__c> actualPlanConvListAfter = [Select id, ownerId from PlanningConversationLog__c];
        System.assertEquals(0, actualPlanConvListAfter.size(), 'Size of List<PlanningConversationLog__c> is not equals to 0');
        Test.stopTest();
    }

    //method to test Simple Conversation Records delete on the deletion of account
    @isTest
    private static void testDeleteProcessorForSimpleConv() {
        SimpleConversation__c simpleConv1;
        SimpleConversation__c simpleConv2;
        getUsers();
        System.runAs(delProcWrap.systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c  objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c(Override_All__c = true);
            insert objectBasedByPassTrigger;
            createAccountContactAndGroupData();
            insert acc;
            AgentRole__c agentRole = new AgentRole__c (customer__c = acc.id, agent__c = delProcWrap.salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            insert agentRole;
            simpleConv1 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple1', Account__c = acc.id, Agent__c = delProcWrap.salesRoleHierarchy1.agent.id, ownerId = delProcWrap.salesRoleHierarchy1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv1;
            simpleConv2 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple2', Account__c = acc.id, Agent__c = delProcWrap.salesRoleHierarchy1.agent.id, ownerId = delProcWrap.salesRoleHierarchy1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv2;
        }

        Test.startTest();
        List<SimpleConversation__c> actualSimpleConvListBefore = [Select id, ownerId from SimpleConversation__c];
        System.assertEquals(2, actualSimpleConvListBefore.size(), 'Size of List<SimpleConversation__c> not equals to 2');
        System.runAs(delProcWrap.testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c = UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            stgorc.VersionNumber__c = 1.0;
            stgorc.Value__c = jsonString;
            //insert stgorc;
            stgorcList.add(stgorc);
            new UTIL_DeleteProcessor().execute(stgorcList);
        }
        List<SimpleConversation__c> actualSimpleConvListAfter = [Select id, ownerId from SimpleConversation__c];
        System.assertEquals(0, actualSimpleConvListAfter.size(), 'Size of List<SimpleConversation__c> is not equals to 0');
        Test.stopTest();
    }

    private class UTIL_DeleteProcessor_Wrapper{
        private Task testTask1;
        private Task testTask2;
        private Case testCase1;
        private List<Case> caselist =new List<Case>();
        private List<Opportunity> oppList=new List<Opportunity>();
        private User systemUser;
        private User testAPIUser;
        private User agentUser;
        private PermissionSetAssignment psassignment;
        private CS_StageOrchestration_Counts__c counts;
        private final String clientIdentifier='IAMCLIENTID';
        private final String clientIdentifier1='AMCLIENTID1';
        private TestData_SalesRoleHierarchy salesRoleHierarchy1;
        private AssignedStaff__c  assignedStaff;
    }
}