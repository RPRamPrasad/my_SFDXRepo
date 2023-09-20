/**
@Author Loco Motivated
@Name UTIL_RecordRemoveFromBook_Test
@CreateDate 30/01/2017
@Description: This class contains unit tests for UTIL_RemoveFromBook Processor
@Version 1.0

@Author: Team Golden Spikes - Updated for Planning Conversation Log Object for removed book of business
@ModifiedDate: 5/10/2018

@Author: Team Golden Spikes - Updated for Simple Conversation Object for removed book of business
@ModifiedDate: 08/10/2018

@Author: Pike - Updated tests to create task using a valid profile
@ModifiedDate: 1/16/2019

@Author: Targaryen - Updated tests for tasks which are assigned to contacts
@ModifiedDate: 04/01/2019

@Author: Team Golden Spikes - Updated for Lead Object for removed book of business
@ModifiedDate: 10/15/2019

@Author: Team Golden Spikes - Updated for LeadMetrics Object for removed book of business
@ModifiedDate: 02/21/2020

@Author:Team Dauntless-Updated for removing the Duplicate lines of code for UTIL_RemoveFromBook Processor_Test
@Modifieddate:05/05/2023
*/

/**
 * @description This class contains unit tests for UTIL_RemoveFromBook Processor
 */
@isTest(SeeAllData = false)
public class UTIL_RemoveFromBookProcessor_Test {

    private static User systemUser,
    sysRecOwner,
    testAPIUser,
    agentUser,
    proxyUser;
    private static PermissionSetAssignment psassignment;
    private static CS_StageOrchestration_Counts__c counts;
    private static AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting;
    private static Account accRecord;
    private static AgentRole__c[] agentRoleDeletion;
    private static AccountMessage__c[] accountMessgae;
    private static AccountMessage__c accountMessgaeCreation;
    

    private static UTIL_RemoveFromBookProcessor_Test_Wrapper1 remWrap1 = new UTIL_RemoveFromBookProcessor_Test_Wrapper1();
    private static UTIL_RemoveFromBookProcessor_Test_Wrapper2 remWrap2 = new UTIL_RemoveFromBookProcessor_Test_Wrapper2();

    @TestSetup
    private static void testSetupData() {
        UserRole agentStandardUserRole;
        UserRole proxyStandardUserRole;
        systemUser = UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');
        sysRecOwner = UTIL_StageOrchestrationTestUtils.buildSystemRecordOwner('123e', 'RecordOwner','recowner@statefarm.com');
        systemUser.UserExternalID__c='sys128';
        sysRecOwner.UserExternalID__c='rec128';
        insert systemUser;
        insert sysRecOwner;
        testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','sf_crm_stageorch@statefarm.com');
        testAPIUser.UserExternalID__c='testapi';
        insert testAPIUser;
        psassignment = UTIL_StageOrchestrationTestUtils.assignPSet(testAPIUser);
        insert psassignment;
        System.runAs(systemUser) {
            agentStandardUserRole = new UserRole(name = 'AgentRole');
            insert agentStandardUserRole;

            proxyStandardUserRole = new UserRole(name = 'ProxyRole', parentRoleId = agentStandardUserRole.id);
            insert proxyStandardUserRole;
        }
        System.runAs(systemUser) {
            User testProxyUser1 = new User(Alias='Proxy',LastName='ProxyAccOwner',Username='proxyAgent@statefarm.com',UserExternalID__c='1234567testP',Servicing_Agent_Associate_ID__c='1234567test');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyStandardUserRole.id;
            insert proxyUser;

            UTIL_StageOrchestrationTestUtils.AgentUserWrapper agentWrap = new UTIL_StageOrchestrationTestUtils.AgentUserWrapper();
            agentWrap.a_alias = 'alias';
            agentWrap.a_lastName = 'accOwner';
            agentWrap.a_UserName = 'accOwnerAgent@statefarm.com';
            agentWrap.a_associateId = '1234567test';
            agentWrap.a_userExternalId = '123tst';
            agentWrap.a_servicingAgentAssocId = '1234567test';

            agentUser = UTIL_StageOrchestrationTestUtils.buildAgentUser(agentWrap);
            agentUser.userRoleId= agentStandardUserRole.id;
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser});
        }

        System.runAs(systemUser) {
            remWrap2.testCampaign = new Campaign(Name = 'testCampaign', Type = 'Lead', OwnerId = proxyUser.id);
            insert remWrap2.testCampaign;

            CS001_ByPassTriggerAtoF__c campTriggerBypass=new CS001_ByPassTriggerAtoF__c(Override_CampaignMemberAfterDelete__c=true,Override_CaseAfterInsert__c=true, Override_CaseBeforeInsert__c = true);
            insert campTriggerBypass;
        }
    }
    //method to get user data
    private static void getUsers(){
        List<User> usrlist = [
            SELECT
            Id, Username, Associate_ID__c,
            Proxy_External_ID__c, Servicing_Agent_Associate_ID__c,
            Servicing_Agent_External_ID__c, UserExternalID__c,
            Agent_Name_Alias__c, SubUserType__c
            FROM User where  UserExternalID__c in('sys128',
            'rec128','testapi','1234567testP','123tst')
            order by UserExternalID__c ];
        proxyUser = usrlist.get(0);
        agentUser = usrlist.get(1);
        sysRecOwner = usrlist.get(2);
        systemUser = usrlist.get(3);
        testAPIUser = usrlist.get(4);
    }
    //method to get count and Account
    private static void countandAcc(){
        counts = new CS_StageOrchestration_Counts__c(Retry_Count__c=3,Chunk_Size__c=5);
        accRecord = new account(FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c='IAMCLIENT12');
        remWrap2.testCampaign = [Select Id, Name,Type from Campaign where OwnerId=:proxyUser.Id];
    }

        @isTest
       static void testMethodforRemoveFromBook(){
        getUsers();
        countandAcc();
        testMethodforRemoveFromBookRunAsSystemUser();
        List<Contact> contactRecord = [SELECT Id from Contact where AccountId =: accRecord.Id limit 1];
        testMethodforRemoveFromBookRunAsAgentUser(contactRecord);
        testingStageOrchestration();
        //Agent will not be able to see AgentRole__c,Task,opportunity,AccountMessage__c,CampaignMember that's why asserting in system mode
        removeFromBookAgentRoleDeletion(contactRecord);
        //Case assertion for changing the status which are not Closed to Closed
        remWrap1.originalCaseList=[select id,accountID,OwnerId,Description,status from Case where accountID=:accRecord.Id AND Id!= :remWrap2.cases3.Id];
        for(Case caseAssertion : remWrap1.originalCaseList){
            if(caseAssertion.Id!=remWrap2.cases2.Id){
                system.assertEquals(UTIL_StageOrchestrationConstants.CASE_CLOSE_STATUS, caseAssertion.status, 'The given two paramters are not equal');
                system.assertEquals(sysRecOwner.Id, caseAssertion.OwnerId, 'The given two paramters are not equal');
            }
            //Cases which are Closed doesn't have any impact through this Remove from book process
            if(caseAssertion.Id==remWrap2.cases2.Id){
                system.assertEquals(remWrap2.cases2.Status, caseAssertion.status, 'The given two paramters are not equal');
            }
        }
        //verifying Cases which are Owned by sysRecord Ower and the Tasks owned by Loosing Agent's Office
        removeFromBookCasesAfterInsert();
}
    //Method for recurring Assert lines for object actualOpportunity
    public static void testAssertforactualOpportunity()
            { remWrap1.actualOpportunity = [select name,OwnerId,AccountId,StageName,description,CloseDate,Assigned_To__c from Opportunity where id=:remWrap1.expectedOpportunity.Id];
            system.assertEquals(remWrap1.expectedOpportunity.Name, remWrap1.actualOpportunity.name, 'Expected Opportunity name is not equals to the actual Opportunity name');
            system.assertEquals(proxyUser.id, remWrap1.actualOpportunity.Assigned_To__c, 'The given two parameters are not equal');
            system.assertEquals(sysRecOwner.id, remWrap1.actualOpportunity.OwnerId, 'Expected owner Id is not equals to the actual owner Id');
            system.assertEquals(remWrap1.expectedOpportunity.AccountId, remWrap1.actualOpportunity.AccountId, 'Expected Account Id is not equals to the actual Account Id');
            system.assertEquals(UTIL_StageOrchestrationConstants.OPPORTUNITY_CLOSED_STAGE_NAME , remWrap1.actualOpportunity.StageName, 'Expected Opportunity stage name is not equals to the actual Opportunity stage name');
            system.assertEquals(UTIL_StageOrchestrationConstants.OPPORTUNITY_DESCRIPTION, remWrap1.actualOpportunity.description, 'Expected Opportunity description is not equals to the actual Opportunity description');
            }

    private static void testMethodforRemoveFromBookRunAsSystemUser(){
        System.runAs(systemUser)  {
                    UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
                    sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(SFDC_USER_ID__c=sysRecOwner.id);
                    insert sysAdminUserIdSetting;
                    insert accRecord;
                    insert counts;
                    AgentRole__c newAgentRole = new AgentRole__c(customer__c=accRecord.id, agent__c=agentUser.id,agentroleIdentifier__c='1234567test~IAMCLIENT12');
                    insert newAgentRole;
                    User agentQueryAfterInsert = [Select Associate_ID__c from User where id =: agentUser.id];
                    accountMessgaeCreation = new AccountMessage__c(AssociateID__c = agentQueryAfterInsert.Associate_ID__c, Account__c = accRecord.Id, Status__c = 'Scheduled');
                    insert accountMessgaeCreation;
                    remWrap1.leadCreation = new Lead(LastName = 'TestReferralLd-1', CustomerReferrer__c = accRecord.id, ownerId = proxyUser.id,
                    recordtypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName().get('SF_Referral').getRecordTypeId());
                    insert remWrap1.leadCreation;
                    Account testcontact = [SELECT PersonContactId FROM Account WHERE id = :accRecord.id];
                    remWrap2.testCampaignMember = new CampaignMember(
                        CampaignId = remWrap2.testCampaign.Id,
                        Status = 'Sent',
                        ContactId = testcontact.PersonContactId
                    );
                    insert remWrap2.testCampaignMember;
                    remWrap2.cases3 = new Case (accountid=accRecord.Id,Description='Cases With Sys Owner', Case_Originator__c = 'CCC Sales', status='New',OwnerId=systemUser.id);
                    insert remWrap2.cases3;
                }
        }

    private static void testMethodforRemoveFromBookRunAsAgentUser(List<Contact> contactRecord){
            System.runAs(agentUser)  {
                        remWrap1.taskCreation =new Task (WhatId=accRecord.Id, subject='Call',Description='TASK111', status='Incomplete',AssignedTo__c=agentUser.id);
                        remWrap1.taskCreation1 =new Task (WhatId=accRecord.Id, subject='Call',Description='TASK222', status='InProgress',AssignedTo__c=agentUser.id);
                        remWrap1.taskCreation2 =new Task (WhatId=accRecord.Id, subject='Call',Description='TASK222', status='Completed',AssignedTo__c=agentUser.id);
                        remWrap1.taskCreation3 =new Task (WhoId=contactRecord.get(0).Id, subject='Call',Description='Contact task', status='InProgress',AssignedTo__c=agentUser.id);
                        remWrap1.expectedTaskList.add(remWrap1.taskCreation);
                        remWrap1.expectedTaskList.add(remWrap1.taskCreation1);
                        remWrap1.expectedTaskList.add(remWrap1.taskCreation2);
                        remWrap1.expectedTaskList.add(remWrap1.taskCreation3);
                        remWrap2.cases =new Case (accountid=accRecord.Id,Description='Cases', Case_Originator__c = 'CCC Sales', status='new',OwnerId=proxyUser.id);
                        remWrap2.cases1 =new Case (accountid=accRecord.Id,Description='Cases1', Case_Originator__c = 'CCC Sales', status='onhold',OwnerId=proxyUser.id);
                        remWrap2.cases2 =new Case (accountid=accRecord.Id,Description='Cases2', Case_Originator__c = 'CCC Sales', status='Closed',OwnerId=proxyUser.id);
                        remWrap1.expectedCaseList.add(remWrap2.cases);
                        remWrap1.expectedCaseList.add(remWrap2.cases1);
                        remWrap1.expectedCaseList.add(remWrap2.cases2);
                        insert remWrap1.expectedCaseList;
                        remWrap1.expectedTaskList.add(new Task (WhatId=remWrap2.cases.Id, subject='Call',Description='CaseTASK111', status='Incomplete',AssignedTo__c=agentUser.id));
                        remWrap1.expectedTaskList.add(new Task (WhatId=remWrap2.cases1.Id, subject='Call',Description='CaseTASK111', status='Completed',AssignedTo__c=agentUser.id));
                        insert remWrap1.expectedTaskList;
                        remWrap1.expectedOpportunity = new Opportunity(AccountId=accRecord.Id ,Name = 'testOpp', CloseDate=Date.today(), StageName='New',description='testDescription',LOB__c='Auto',
                                                              Assigned_To__c=agentUser.id,OwnerId=proxyUser.id );
                        insert remWrap1.expectedOpportunity;
                        List<Task> taskListForOpp=new List<Task>();
                        taskListForOpp.add(new Task (WhatId=remWrap1.expectedOpportunity.Id, subject='Task Under Opp To be Reassigned',Description='TASKForGivenOpp1', status='InProgress',AssignedTo__c=agentUser.id));
                        taskListForOpp.add(new Task (WhatId=remWrap1.expectedOpportunity.Id, subject='Task Under Opp Closed Reassign',Description='TASKForGivenOpp2', status='Incomplete',AssignedTo__c=agentUser.id));
                        insert taskListForOpp;
                        remWrap2.productsServicedBeMe = new ProductsServicedByMe__c(Agent__c=agentUser.Id,ProductLine__c='Auto',
                                                                          ProductType__c='ATV',CarrierName__c='Assigned Risk/JUA',Customer__c = accRecord.Id);
                        insert remWrap2.productsServicedBeMe;
                    }
            }
    
    //Task assertion for changing the status which are not completed to Removed From Book
			
			public static void testAssertfortaskCreation()
    {
      //Agent will not be able to see AgentRole__c,Task ,Campaign Members ,AccountMessage__c that's why asserting in system mode
        agentRoleDeletion = [SELECT id FROM AgentRole__c WHERE Customer__c = :accRecord.Id];
        system.assert(agentRoleDeletion.isEmpty(), 'SOQL query has not return empty list of AgentRole__c');
        remWrap1.actualTaskList=[select id,WhatId,subject,OwnerId,status,AssignedTo__c from task where WhatId=:accRecord.Id];
        //Task assertion for changing the status which are not completed to Removed From Book
        for(Task taskAssertion : remWrap1.actualTaskList){
            system.assertEquals(UTIL_StageOrchestrationConstants.OPPORTUNITY_TASK_CLOSED_REASON, taskAssertion.status, 'The given two parameters are not equal');
            system.assertEquals(proxyUser.Id, taskAssertion.AssignedTo__c, 'The given two parameters are not equal');
            system.assertEquals(sysRecOwner.Id, taskAssertion.OwnerId, 'Expected owner Id is not equals to the actual owner Id');
        }
    }
    

            private static void removeFromBookAgentRoleDeletion(List<Contact> contactRecord){
                agentRoleDeletion=[Select id From AgentRole__c where Customer__c=:accRecord.Id];
                system.assert(agentRoleDeletion.isEmpty(), 'AgentRole__c[] is not empty');
                remWrap1.actualTaskList=[select id,WhatId,whoId,subject,OwnerId,Description,status,AssignedTo__c from task where WhatId=:accRecord.Id];
                remWrap1.actualTaskList.addAll([select id,WhatId,WhoId,subject,OwnerId,Description,status,AssignedTo__c from task where WhoId=:contactRecord.get(0).Id]);
                //Task assertion for changing the status which are not completed to Removed From Book
                for(Task taskAssertion : remWrap1.actualTaskList){
                    if(taskAssertion.whoId == contactRecord.get(0).Id){
                        system.assertEquals(UTIL_StageOrchestrationConstants.OPPORTUNITY_TASK_CLOSED_REASON, taskAssertion.status, 'The given two paramters are not equal');
                        system.assertEquals(sysRecOwner.Id, taskAssertion.OwnerId, 'The given two OwnerId are not equal');
                        system.assertEquals(proxyUser.id, taskAssertion.AssignedTo__c, 'The given two paramters are not equal');
                    }
                    if(taskAssertion.Id != remWrap1.taskCreation2.Id){
                        system.assertEquals(UTIL_StageOrchestrationConstants.OPPORTUNITY_TASK_CLOSED_REASON, taskAssertion.status, 'The given two paramters are not equal');
                        system.assertEquals(sysRecOwner.Id, taskAssertion.OwnerId, 'The given two OwnerId are not equal');
                        system.assertEquals(proxyUser.id, taskAssertion.AssignedTo__c, 'The given two paramters are not equal');
                    }
                    if(taskAssertion.Id == remWrap1.taskCreation.Id){
                        system.assertEquals(remWrap1.taskCreation.WhatId, taskAssertion.WhatId, 'The given two WhatId are not equal');
                        system.assertEquals(remWrap1.taskCreation.Subject, taskAssertion.Subject, 'The given two Subject are not equal');
                        system.assertEquals(remWrap1.taskCreation.Description, taskAssertion.Description, 'The given two Description are not equal');
                    }
                    //Task which are Completed doesn't have any impact through this Remove from book process
                    if(taskAssertion.Id == remWrap1.taskCreation2.Id){
                        system.assertEquals(remWrap1.taskCreation2.Status, taskAssertion.status, 'The given two status are not equal');
                        system.assertEquals(proxyUser.Id, taskAssertion.AssignedTo__c, 'The given two paramters are not equal');
                        system.assertEquals(sysRecOwner.Id, taskAssertion.OwnerId, 'The given two OwnerId are not equal');
                    }
                }
        }

        private static void removeFromBookCasesAfterInsert(){
            remWrap2.casesAfterInsert=[select accountId,Status,OwnerId,(select status,ownerId,AssignedTo__c from tasks) from Case where Id=:remWrap2.cases3.Id];
            system.assertEquals(remWrap2.cases3.Status, remWrap2.casesAfterInsert.status, 'Given two Case statuses are not equal');
            system.assertEquals(systemUser.id, remWrap2.casesAfterInsert.OwnerId, 'The given two paramters are not equal');
            //verifying Opportunities and the Tasks owned by Loosing Agent's Office
            remWrap1.actualOpportunity = [select name,OwnerId,AccountId,StageName,description,CloseDate,Assigned_To__c from Opportunity where id=:remWrap1.expectedOpportunity.Id];
            system.assertEquals(remWrap1.expectedOpportunity.Name, remWrap1.actualOpportunity.name, 'Opportunity names are not equal');
            system.assertEquals(proxyUser.id, remWrap1.actualOpportunity.Assigned_To__c, 'The given two paramters are not equal');
            system.assertEquals(sysRecOwner.id, remWrap1.actualOpportunity.OwnerId, 'Owner IDs are not equal');
            system.assertEquals(remWrap1.expectedOpportunity.AccountId, remWrap1.actualOpportunity.AccountId, 'Account IDs are not equal');
            system.assertEquals(UTIL_StageOrchestrationConstants.OPPORTUNITY_CLOSED_STAGE_NAME , remWrap1.actualOpportunity.StageName, 'Opportunity stage names are not equal');
            system.assertNotEquals(remWrap1.expectedOpportunity.Description, remWrap1.actualOpportunity.description, 'Opportunity descriptions are equal');
            List<Task> taskListForOppToAssert = [select id,WhatId,subject,OwnerId,Description,status,AssignedTo__c,createddate from task where WhatId =:remWrap1.expectedOpportunity.Id];
              for(Task taskAssertion : taskListForOppToAssert){
                system.assertEquals(sysRecOwner.Id,taskAssertion.OwnerId, 'Owner IDs are not equal');
                system.assertEquals(sysRecOwner.Id, taskAssertion.AssignedTo__c, 'The given two paramters are not equal');
                system.assertEquals('Removed From Book',taskAssertion.status, 'TaskAssertion status not equals to \'Removed From Book\'');
            }
            accountMessgae = [select id from AccountMessage__c where id=:accountMessgaeCreation.id];
            system.assert(accountMessgae.isEmpty(), 'SOQL query has not return empty list of AccountMessage__c');
            remWrap1.leadDeletion = [select id from Lead where id=:remWrap1.leadCreation.id];
            system.assert(remWrap1.leadDeletion.isEmpty(), 'SOQL query has not return empty list of Lead');
            //CampaignMember assertion weather it is removed from his book
            remWrap2.campaignMemberAfterInsert = [SELECT id FROM CampaignMember WHERE id = :remWrap2.testCampaignMember.Id];
            system.assert(remWrap2.campaignMemberAfterInsert.isEmpty(), 'SOQL query has not return empty list of CampaignMember');
            remWrap2.actualProductsServicedByMeList = [SELECT id FROM ProductsServicedByMe__c WHERE Id = :remWrap2.productsServicedBeMe.Id];
            system.assert(remWrap2.actualProductsServicedByMeList.isEmpty(), 'SOQL query has not return empty list of ProductsServicedByMe__c');
    }
    @isTest
    static void testMethodforRemoveFromBookWithoutProductsServicedByMeData(){
        getUsers();
        countandAcc();
        System.runAs(systemUser)  {
            insertAccRecordsTest();
            insertNewAgentRolesTest();
            insertLeadCreationTest();
            insertCampaignMemberTest();
        }
        System.runAs(agentUser)  {
            insertOpportunityTest();
        }
        getTestStageOrchestration();
        system.assert(remWrap2.campaignMemberAfterInsert.isEmpty(), 'SOQL query has not return empty list of CampaignMember');
    }

    @isTest
    static void testMethodforRemoveFromBookWithCustomerGroupingEnabled(){
        UTIL_RemoveFromBookProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMERGROUPINGS,true);
        getUsers();
        countandAcc();
		System.runAs(systemUser)  {
			insertAccRecordsTest();
			insertNewAgentRolesTest();
			insertLeadCreationTest();
			insertCampaignMemberTest();
			insertHouseHoldGroupMemberTest();
		}
	 
	    System.runAs(agentUser)  { 
			insertOpportunityTest();
			remWrap2.productsServicedBeMe = new ProductsServicedByMe__c(Agent__c=agentUser.Id,ProductLine__c='Auto',
																  ProductType__c='ATV',CarrierName__c='Assigned Risk/JUA',Customer__c = accRecord.Id);
			insert remWrap2.productsServicedBeMe;
		}
     
		getTestStageOrchestration();
        List<CustomerGroupMember__c> houseHoldGroupMemberList;
        houseHoldGroupMemberList = [Select Id from CustomerGroupMember__c Where GroupMemberId__c='IAMGR0UPID0~IAMCLIENT12'];
        //system.assert(houseHoldGroupMemberList.isEmpty());
        remWrap2.actualProductsServicedByMeList = [Select id from ProductsServicedByMe__c where Id=:remWrap2.productsServicedBeMe.Id];
        system.assert(remWrap2.actualProductsServicedByMeList.isEmpty(), 'SOQL query has not return empty list of ProductsServicedByMe__c');
    }

    @isTest
    static void testMethodforRemoveFromBookWithCustomerGroupingDisabled(){
        UTIL_RemoveFromBookProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMERGROUPINGS,false);
        getUsers();
        countandAcc();
		
		System.runAs(systemUser)  {
			insertAccRecordsTest();
			insertNewAgentRolesTest();
			insertLeadCreationTest();
			insertCampaignMemberTest();
			insertHouseHoldGroupMemberTest();
        }
		
		System.runAs(agentUser)  { 
			insertOpportunityTest();
			remWrap2.productsServicedBeMe = new ProductsServicedByMe__c(Agent__c=agentUser.Id,ProductLine__c='Auto',
																  ProductType__c='ATV',CarrierName__c='Assigned Risk/JUA',Customer__c = accRecord.Id);
			insert remWrap2.productsServicedBeMe;
		}
		
        getTestStageOrchestration();
        List<CustomerGroupMember__c> houseHoldGroupMemberList = [Select Id from CustomerGroupMember__c Where GroupMemberId__c='IAMGR0UPID0~IAMCLIENT12'];
        system.assert(!houseHoldGroupMemberList.isEmpty(), 'SOQL query has return empty list of CustomerGroupMember__c');
        remWrap2.actualProductsServicedByMeList = [Select id from ProductsServicedByMe__c where Id=:remWrap2.productsServicedBeMe.Id];
        system.assert(remWrap2.actualProductsServicedByMeList.isEmpty(), 'SOQL query has not return empty list of ProductsServicedByMe__c');
    }

    @isTest
    static void testMethodforRemoveFromBookwithoutTask(){
        getUsers();
        countandAcc();
        System.runAs(systemUser)  {
            insertAccRecordsTest();
            insertNewAgentRolesTest();
            insertLeadCreationTest();
            insertCampaignMemberTest();
        }
        System.runAs(agentUser)  {
            remWrap1.expectedOpportunity = new Opportunity(AccountId=accRecord.Id ,Name = 'testOpp', CloseDate=Date.today(), StageName='New',description='',LOB__c='Auto',
                                                  Assigned_To__c=agentUser.id,OwnerId=proxyUser.id );
            insert remWrap1.expectedOpportunity;

            remWrap2.productsServicedBeMe = new ProductsServicedByMe__c(Agent__c=agentUser.Id,ProductLine__c='Auto',
                                                              ProductType__c='ATV',CarrierName__c='Assigned Risk/JUA',Customer__c = accRecord.Id);
            insert remWrap2.productsServicedBeMe;
        }
        testingStageOrchestration();
        //Agent will not be able to see AgentRole__c,opportunity,AccountMessage__c that's why asserting in system mode
        agentRoleDeletion=[Select id From AgentRole__c where Customer__c=:accRecord.Id];
        system.assert(agentRoleDeletion.isEmpty(), 'SOQL query has not return empty list of AgentRole__c');
        testAssertforactualOpportunity();
        accountMessgae = [select id from AccountMessage__c where id=:accountMessgaeCreation.id];
        system.assert(accountMessgae.isEmpty(), 'SOQL query has not return empty list of AccountMessage__c');
        remWrap1.leadDeletion = [select id from Lead where id=:remWrap1.leadCreation.id];
        system.assert(remWrap1.leadDeletion.isEmpty(), 'SOQL query has not return empty list of Lead');
        //CampaignMember assertion weather it is removed from his book
        remWrap2.campaignMemberAfterInsert =[select id from CampaignMember where id=:remWrap2.testCampaignMember.Id];
        system.assert(remWrap2.campaignMemberAfterInsert.isEmpty(), 'SOQL query has not return empty list of CampaignMember');
        remWrap2.actualProductsServicedByMeList = [Select id from ProductsServicedByMe__c where Id=:remWrap2.productsServicedBeMe.Id];
        system.assert(remWrap2.actualProductsServicedByMeList.isEmpty(), 'SOQL query has not return empty list of ProductsServicedByMe__c');
    }

    @isTest
    static void testMethodforRemoveFromBookwithoutOpportunity(){
        getUsers();
        countandAcc();
        System.runAs(systemUser)  {
            insertAccRecordsTest();
			insertNewAgentRolesTest();
			insertLeadCreationTest();
			insertCampaignMemberTest();
        }

        System.runAs(agentUser)  {
            remWrap1.taskCreation =new Task (WhatId=accRecord.Id, subject='Call', OwnerId =agentUser.id,Description='TASK111', status='Incomplete',AssignedTo__c=agentUser.id);
            remWrap1.taskCreation1 =new Task (WhatId=accRecord.Id, subject='Call', OwnerId =agentUser.id,Description='TASK222', status='InProgress',AssignedTo__c=agentUser.id);
            remWrap1.expectedTaskList.add(remWrap1.taskCreation);
            remWrap1.expectedTaskList.add(remWrap1.taskCreation1);
            insert remWrap1.expectedTaskList;

            remWrap2.productsServicedBeMe = new ProductsServicedByMe__c(Agent__c=agentUser.Id,ProductLine__c='Auto',
                                                              ProductType__c='ATV',CarrierName__c='Assigned Risk/JUA',Customer__c = accRecord.Id);
            insert remWrap2.productsServicedBeMe;
        }

        testingStageOrchestration();
        testAssertfortaskCreation();
        accountMessgae = [select id from AccountMessage__c where id=:accountMessgaeCreation.id];
        system.assert(accountMessgae.isEmpty(), 'SOQL query has not return empty list of AccountMessage__c');

        remWrap1.leadDeletion = [select id from Lead where id=:remWrap1.leadCreation.id];
        system.assert(remWrap1.leadDeletion.isEmpty(), 'SOQL query has not return empty list of Lead');

        //CampaignMember assertion weather it is removed from his book
        remWrap2.campaignMemberAfterInsert =[select id from CampaignMember where id=:remWrap2.testCampaignMember.Id];
        system.assert(remWrap2.campaignMemberAfterInsert.isEmpty(), 'SOQL query has not return empty list of CampaignMember');

        remWrap2.actualProductsServicedByMeList = [Select id from ProductsServicedByMe__c where Id=:remWrap2.productsServicedBeMe.Id];
        system.assert(remWrap2.actualProductsServicedByMeList.isEmpty(), 'SOQL query has not return empty list of ProductsServicedByMe__c');
    }
   

    @isTest
    static void testMethodforRemoveFromBookwithoutAccountMessage(){
        getUsers();
        countandAcc();
        System.runAs(systemUser)  {
            insertAccRecordsTest();
            insertNewAgentRolesTest();
            insertCampaignMemberTest();
        }

        System.runAs(agentUser)  {
            remWrap1.taskCreation =new Task (WhatId=accRecord.Id, subject='Call', OwnerId =agentUser.id,Description='TASK111', status='Incomplete',AssignedTo__c=agentUser.id);
            remWrap1.taskCreation1 =new Task (WhatId=accRecord.Id, subject='Call', OwnerId =agentUser.id,Description='TASK222', status='InProgress',AssignedTo__c=agentUser.id);
            remWrap1.expectedTaskList.add(remWrap1.taskCreation);
            remWrap1.expectedTaskList.add(remWrap1.taskCreation1);
            insert remWrap1.expectedTaskList;

            remWrap1.expectedOpportunity = new Opportunity(AccountId=accRecord.Id ,Name = 'testOpp', CloseDate=Date.today(), StageName='New',description='',LOB__c='Auto',
                                                  Assigned_To__c=agentUser.id,OwnerId=proxyUser.id );
            insert remWrap1.expectedOpportunity;

            remWrap2.productsServicedBeMe = new ProductsServicedByMe__c(Agent__c=agentUser.Id,ProductLine__c='Auto',
                                                              ProductType__c='ATV',CarrierName__c='Assigned Risk/JUA',Customer__c = accRecord.Id);
            insert remWrap2.productsServicedBeMe;
        }

        testingStageOrchestration();
        testAssertfortaskCreation();

        testAssertforactualOpportunity();

        //CampaignMember assertion weather it is removed from his book
        remWrap2.campaignMemberAfterInsert =[select id from CampaignMember where id=:remWrap2.testCampaignMember.Id];
        system.assert(remWrap2.campaignMemberAfterInsert.isEmpty(), 'SOQL query has not return empty list of CampaignMember');

        remWrap2.actualProductsServicedByMeList = [Select id from ProductsServicedByMe__c where Id=:remWrap2.productsServicedBeMe.Id];
        system.assert(remWrap2.actualProductsServicedByMeList.isEmpty(), 'SOQL query has not return empty list of ProductsServicedByMe__c');
    }

    @isTest
    static void testMethodforRemoveFromBookwithoutCampaignMembers(){
        getUsers();
        countandAcc();
        System.runAs(systemUser)  {
           insertAccRecordsTest();
           insertNewAgentRolesTest();
           insertLeadCreationTest();
        }

        System.runAs(agentUser)  {
            remWrap1.taskCreation =new Task (WhatId=accRecord.Id, subject='Call', OwnerId =agentUser.id,Description='TASK111', status='Incomplete',AssignedTo__c=agentUser.id);
            remWrap1.taskCreation1 =new Task (WhatId=accRecord.Id, subject='Call', OwnerId =agentUser.id,Description='TASK222', status='InProgress',AssignedTo__c=agentUser.id);
            remWrap1.expectedTaskList.add(remWrap1.taskCreation);
            remWrap1.expectedTaskList.add(remWrap1.taskCreation1);
            insert remWrap1.expectedTaskList;

            remWrap1.expectedOpportunity = new Opportunity(AccountId=accRecord.Id ,Name = 'testOpp', CloseDate=Date.today(), StageName='New',description='test',LOB__c='Auto', Assigned_To__c=agentUser.id);
            insert remWrap1.expectedOpportunity;

            remWrap2.productsServicedBeMe = new ProductsServicedByMe__c(Agent__c=agentUser.Id,ProductLine__c='Auto',
                                                              ProductType__c='ATV',CarrierName__c='Assigned Risk/JUA',Customer__c = accRecord.Id);
            insert remWrap2.productsServicedBeMe;
        }

       testingStageOrchestration();
       testAssertfortaskCreation();
            remWrap1.actualOpportunity = [select name,OwnerId,AccountId,StageName,description,CloseDate,Assigned_To__c from Opportunity where id=:remWrap1.expectedOpportunity.Id];
        system.assertEquals(remWrap1.expectedOpportunity.Name, remWrap1.actualOpportunity.name, 'Expected Opportunity name is not equals to the actual Opportunity name');
        system.assertEquals(proxyUser.id, remWrap1.actualOpportunity.Assigned_To__c, 'The given two parameters are not equal');
        system.assertEquals(sysRecOwner.id, remWrap1.actualOpportunity.OwnerId, 'Expected owner Id is not equals to the actual owner Id');
        system.assertEquals(remWrap1.expectedOpportunity.AccountId, remWrap1.actualOpportunity.AccountId, 'Expected Account Id is not equals to the actual Account Id');
        system.assertEquals(UTIL_StageOrchestrationConstants.OPPORTUNITY_CLOSED_STAGE_NAME , remWrap1.actualOpportunity.StageName, 'The given two parameters are not equal');
        system.assertNotEquals(remWrap1.expectedOpportunity.Description, remWrap1.actualOpportunity.description, 'Expected Opportunity description is should not be equals to the actual Opportunity description');

        accountMessgae = [select id from AccountMessage__c where id=:accountMessgaeCreation.id];
        system.assert(accountMessgae.isEmpty(), 'SOQL query has not return empty list of AccountMessage__c');

        remWrap1.leadDeletion = [select id from Lead where id=:remWrap1.leadCreation.id];
        system.assert(remWrap1.leadDeletion.isEmpty(), 'SOQL query has not return empty list of Lead');

        remWrap2.actualProductsServicedByMeList = [Select id from ProductsServicedByMe__c where Id=:remWrap2.productsServicedBeMe.Id];
        system.assert(remWrap2.actualProductsServicedByMeList.isEmpty(), 'SOQL query has not return empty list of ProductsServicedByMe__c');
    }

    @isTest
    static void testMethodforRemoveFromBookWithAssignedStaff(){
        getUsers();
        countandAcc();
        TestData_SalesRoleHierarchy salesRoleHierarchy0;
        AssignedStaff__c newAssignedStaff;
        System.runAs(systemUser)  {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(SFDC_USER_ID__c=systemUser.id);
            insert sysAdminUserIdSetting;
            insert accRecord;
            insert counts;

            salesRoleHierarchy0 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=accRecord.id, agent__c=salesRoleHierarchy0.Agent.Id,agentroleIdentifier__c=salesRoleHierarchy0.Agent.Associate_ID__c + '~IAMCLIENT12');
            insert newAgentRole;
            newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accRecord.clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+salesRoleHierarchy0.AgentTeamMember.Associate_Id__c,Customer__c=accRecord.Id,Staff__c=salesRoleHierarchy0.AgentTeamMember.Id);
            insert newAssignedStaff;
        }

         StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        testStageOrchestration.TransactionType__c=UTIL_StageOrchestrationConstants.REMOVE_FROM_BOOK_TRANSACTION;
        testStageOrchestration.VersionNumber__c=1.0;
        testStageOrchestration.Value__c=buildJsonString('IAMCLIENT12', salesRoleHierarchy0.Agent.Associate_ID__c);

        System.runAs(testAPIUser) {
            test.startTest();
            insert testStageOrchestration;
            test.stopTest();
        }
        System.runAs(salesRoleHierarchy0.Agent)  {
            account[] testAccountList=[Select id From account where id=:accRecord.Id];
            System.assert(testAccountList.isEmpty(), 'Account[] is not empty');
        }
        //Agent will not be able to see AgentRole__c,Task,opportunity,AccountMessage__c,CampaignMember that's why asserting in system mode

        agentRoleDeletion=[Select id From AgentRole__c where Customer__c=:accRecord.Id];
        system.assert(agentRoleDeletion.isEmpty(), 'SOQL query has not return empty list of AgentRole__c');

        List<AssignedStaff__c> assignedStaffList = [Select id from AssignedStaff__c where Customer__c=:accRecord.Id];
        system.assert(assignedStaffList.isEmpty(), 'SOQL query has not return empty list of AssignedStaff__c');
    }

    @isTest
    static void testMethodforRemoveFromBookWithMultiAssignedStaff(){
        getUsers();
        countandAcc();
        TestData_SalesRoleHierarchy salesRoleHierarchy0;
        TestData_SalesRoleHierarchy salesRoleHierarchy1;
        AssignedStaff__c newAssignedStaff;
        AssignedStaff__c newAssignedStaff0;
        System.runAs(systemUser)  {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(SFDC_USER_ID__c=systemUser.id);
            insert sysAdminUserIdSetting;
            insert accRecord;
            insert counts;

            salesRoleHierarchy0 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
            salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('B');
            AgentRole__c newAgentRole0 = new AgentRole__c(customer__c=accRecord.id, agent__c=salesRoleHierarchy1.Agent.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_ID__c + '~IAMCLIENT12');
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=accRecord.id, agent__c=salesRoleHierarchy0.Agent.Id,agentroleIdentifier__c=salesRoleHierarchy0.Agent.Associate_ID__c + '~IAMCLIENT12');
            insert new List<AgentRole__c>{newAgentRole0, newAgentRole};
            newAssignedStaff0= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accRecord.clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+salesRoleHierarchy0.AgentTeamMember.Associate_Id__c,Customer__c=accRecord.Id,Staff__c=salesRoleHierarchy0.AgentTeamMember.Id);
            newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, AssignedStaffIdentifier__c =accRecord.clientIdentifier__c+'~'+salesRoleHierarchy1.Agent.Associate_ID__c+'~'+salesRoleHierarchy1.AgentTeamMember.Associate_Id__c,Customer__c=accRecord.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
            insert new List<AssignedStaff__c>{newAssignedStaff0, newAssignedStaff};
        }

        StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        testStageOrchestration.TransactionType__c=UTIL_StageOrchestrationConstants.REMOVE_FROM_BOOK_TRANSACTION;
        testStageOrchestration.VersionNumber__c=1.0;
        testStageOrchestration.Value__c=buildJsonString('IAMCLIENT12', salesRoleHierarchy0.Agent.Associate_ID__c);

        System.runAs(testAPIUser) {
            test.startTest();
            insert testStageOrchestration;
            test.stopTest();
        }
        System.runAs(salesRoleHierarchy0.Agent)  {
            account[] testAccountList=[Select id From account where id=:accRecord.Id];
            System.assert(testAccountList.isEmpty(), 'Account[] is not empty');
        }
        System.runAs(salesRoleHierarchy1.Agent)  {
            account[] testAccountList=[Select id From account where id=:accRecord.Id];
            System.assert(!testAccountList.isEmpty(), 'Account[] is empty');
        }
        //Agent will not be able to see AgentRole__c,Task,opportunity,AccountMessage__c,CampaignMember that's why asserting in system mode

        agentRoleDeletion=[Select id From AgentRole__c where Customer__c=:accRecord.Id];
        system.assert(!agentRoleDeletion.isEmpty(), 'SOQL query has return empty list of AgentRole__c');
        system.assertEquals(1,agentRoleDeletion.size(), 'Size of AgenRole list is not equals to 1');

        List<AssignedStaff__c> assignedStaffList = [Select id from AssignedStaff__c where Customer__c=:accRecord.Id];
        system.assert(!assignedStaffList.isEmpty(), 'List<AssignedStaff__c> is empty');
        system.assertEquals(1,assignedStaffList.size(), 'Size of List<AssignedStaff__c> not equals to 1');
        system.assertEquals(newAssignedStaff.Id,assignedStaffList[0].Id, 'The given two parameters are not equal');
    }

    //method to update Planning Conversation Log Owner For Remove From Book
    @isTest
    private static void testMethodForPlanningConversationLogUpdateOnAgentRemoveFromBook() {
        getUsers();
        countandAcc();

        User noAccessProfileUser = UTIL_StageOrchestrationTestUtils.buildtestUser('tst2NoAc2', UTIL_Constants.NO_ACCESS_PROFILE_NAME, 'P2PP2PP2P11');
        insert noAccessProfileUser;
        TestData_SalesRoleHierarchy salesRoleHierarchyForPlanConvLog1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('E');
        TestData_SalesRoleHierarchy salesRoleHierarchyForPlanConvLog2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('K');
        PlanningConversationLog__c planConvLog1;
        PlanningConversationLog__c planConvLog2;
        System.runAs(systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
            insert passTriggerAll;
        }

        System.runAs(salesRoleHierarchyForPlanConvLog1.agent) {
            insert accRecord;
            AgentRole__c agentRole11 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchyForPlanConvLog1.Agent.Id, agentroleIdentifier__c = salesRoleHierarchyForPlanConvLog1.Agent.Associate_ID__c + '~' + accRecord.clientIdentifier__c);
            insert agentRole11;
            AgentRole__c agentRole21 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchyForPlanConvLog2.Agent.Id, agentroleIdentifier__c = salesRoleHierarchyForPlanConvLog2.Agent.Associate_ID__c + '~' + accRecord.clientIdentifier__c);
            agentRole21.Agent__c = salesRoleHierarchyForPlanConvLog2.Agent.id;
            insert agentRole21;
        }

        System.runAs(systemUser) {
            sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(
                Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,
                SFDC_USER_ID__c = noAccessProfileUser.id
            );
            insert sysAdminUserIdSetting;

            SimpleConversation__c simpleConv1 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple1', Account__c = accRecord.id, Agent__c = salesRoleHierarchyForPlanConvLog1.agent.id, ownerId = salesRoleHierarchyForPlanConvLog1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv1;
            SimpleConversation__c simpleConv2 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple2', Account__c = accRecord.id, Agent__c = salesRoleHierarchyForPlanConvLog2.agent.id, ownerId = salesRoleHierarchyForPlanConvLog2.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv2;

            planConvLog1 = new PlanningConversationLog__c (Account__c = accRecord.id, Comments__c = 'Test Comments', Agent__c = salesRoleHierarchyForPlanConvLog1.agent.id, SimpleConversation__c = simpleConv1.id, ownerId = salesRoleHierarchyForPlanConvLog1.agentOffice.id);
            insert planConvLog1;
            planConvLog2 = new PlanningConversationLog__c (Account__c = accRecord.id, Comments__c = 'Test Comments', Agent__c = salesRoleHierarchyForPlanConvLog2.agent.id, SimpleConversation__c = simpleConv2.id, ownerId = salesRoleHierarchyForPlanConvLog2.agentOffice.id);
            insert planConvLog2;
        }

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.TransactionType__c = UTIL_StageOrchestrationConstants.REMOVE_FROM_BOOK_TRANSACTION;
            testStageOrchestration.VersionNumber__c = 1.0;
            testStageOrchestration.Value__c = buildJsonString('IAMCLIENT12', salesRoleHierarchyForPlanConvLog1.Agent.Associate_ID__c);
            stgorcList.add(testStageOrchestration);
            new UTIL_RemoveFromBookProcessor().execute(stgorcList);
        }
        List<PlanningConversationLog__c> actualPlanConvList = [Select id, name, ownerId, Agent__c, Account__r.clientIdentifier__c from PlanningConversationLog__c];
        System.assertEquals(actualPlanConvList.size(), 2, 'Size of List<PlanningConversationLog__c> not equals to 2');
        for(PlanningConversationLog__c planConvLog: actualPlanConvList) {
            if((planConvLog.Id).equals(planConvLog1.id)) {
                system.assertEquals('IAMCLIENT12', planConvLog.Account__r.clientIdentifier__c, 'The given two parameters are not equal');
                system.assertEquals(noAccessProfileUser.Id, planConvLog.ownerId, 'The given two parameters are not equal');
                system.assertEquals(salesRoleHierarchyForPlanConvLog1.agent.id, planConvLog.Agent__c, 'Agent id should not be changed');
            } else if((planConvLog.Id).equals(planConvLog2.id)) {
                system.assertEquals(salesRoleHierarchyForPlanConvLog2.agentOffice.id, planConvLog.ownerId, 'The given two parameters are not equal');
                system.assertEquals('IAMCLIENT12', planConvLog.Account__r.clientIdentifier__c, 'The given two parameters are not equal');
                system.assertEquals(salesRoleHierarchyForPlanConvLog2.agent.id, planConvLog.Agent__c, 'Agent id should not be changed');
            }
        }
        Test.stopTest();
    }

    //method to update Simple Conversation Owner For Remove From Book
    @isTest
    private static void testMethodForSimpleConversationUpdateOnAgentRemoveFromBook() {
        getUsers();
        countandAcc();

        User noAccessProfileUser = UTIL_StageOrchestrationTestUtils.buildtestUser('tstNoAc1', UTIL_Constants.NO_ACCESS_PROFILE_NAME, 'K2PP2PP2P11');
        insert noAccessProfileUser;
        TestData_SalesRoleHierarchy salesRoleHierarchyForSimpleConv1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('G');
        TestData_SalesRoleHierarchy salesRoleHierarchyForSimpleConv2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('T');
        SimpleConversation__c simpleConv1;
        SimpleConversation__c simpleConv2;
        System.runAs(systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
            insert passTriggerAll;
        }

        System.runAs(salesRoleHierarchyForSimpleConv1.agent) {
            insert accRecord;
            AgentRole__c agentRole11 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchyForSimpleConv1.Agent.Id, agentroleIdentifier__c = salesRoleHierarchyForSimpleConv1.Agent.Associate_ID__c + '~' + accRecord.clientIdentifier__c);
            insert agentRole11;
            AgentRole__c agentRole21 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchyForSimpleConv2.Agent.Id, agentroleIdentifier__c = salesRoleHierarchyForSimpleConv2.Agent.Associate_ID__c + '~' + accRecord.clientIdentifier__c);
            agentRole21.Agent__c = salesRoleHierarchyForSimpleConv2.Agent.id;
            insert agentRole21;
        }

        System.runAs(systemUser) {
            sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = noAccessProfileUser.id);
            insert sysAdminUserIdSetting;
            simpleConv1 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple1', Account__c = accRecord.id, Agent__c = salesRoleHierarchyForSimpleConv1.agent.id, ownerId = salesRoleHierarchyForSimpleConv1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv1;
            simpleConv2 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple2', Account__c = accRecord.id, Agent__c = salesRoleHierarchyForSimpleConv2.agent.id, ownerId = salesRoleHierarchyForSimpleConv2.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv2;
        }

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.TransactionType__c = UTIL_StageOrchestrationConstants.REMOVE_FROM_BOOK_TRANSACTION;
            testStageOrchestration.VersionNumber__c = 1.0;
            testStageOrchestration.Value__c = buildJsonString('IAMCLIENT12', salesRoleHierarchyForSimpleConv1.Agent.Associate_ID__c);
            stgorcList.add(testStageOrchestration);
            new UTIL_RemoveFromBookProcessor().execute(stgorcList);
        }
        List<SimpleConversation__c> actualSimpleConvList = [Select id, ownerId, Account__r.clientIdentifier__c from SimpleConversation__c];
        System.assertEquals(actualSimpleConvList.size(), 2, 'Size of List<SimpleConversation__c> not equals to 2');
        for(SimpleConversation__c simpleConv: actualSimpleConvList) {
            if((simpleConv.Id).equals(simpleConv1.id)) {
                system.assertEquals('IAMCLIENT12', simpleConv.Account__r.clientIdentifier__c, 'The given two parameters are not equal');
                system.assertEquals(noAccessProfileUser.Id, simpleConv.ownerId, 'The given two parameters are not equal');
            } else if((simpleConv.Id).equals(simpleConv2.id)) {
                system.assertEquals(salesRoleHierarchyForSimpleConv2.agentOffice.id, simpleConv.ownerId, 'The given two parameters are not equal');
                system.assertEquals('IAMCLIENT12', simpleConv.Account__r.clientIdentifier__c, 'The given two parameters are not equal');
            }
        }
        Test.stopTest();
    }

    //method to update Customer Initiated Cancellation For Remove From Book
    @isTest
    private static void testMethodForCICRemoveFromBook() {
        getUsers();
        countandAcc();

        User noAccessProfileUser = UTIL_StageOrchestrationTestUtils.buildtestUser('tst12no11Access11User12', UTIL_Constants.NO_ACCESS_PROFILE_NAME, 'P2PP2PP2P11');
        insert noAccessProfileUser;
      TestData_SalesRoleHierarchy salesRoleHierarchyForCic = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('E');

        CustomerInitiatedCancellations__c cic;

        System.runAs(systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
            insert passTriggerAll;
        }

        System.runAs(salesRoleHierarchyForCic.agent) {
            insert accRecord;
            AgentRole__c agentRole11 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchyForCic.Agent.id, agentroleIdentifier__c = salesRoleHierarchyForCic.Agent.Associate_ID__c + '~' + accRecord.clientIdentifier__c);
            insert agentRole11;

        }

        System.runAs(systemUser) {
            sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(
                Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,
                SFDC_USER_ID__c = noAccessProfileUser.id
            );
            insert sysAdminUserIdSetting;
            cic = new CustomerInitiatedCancellations__c(
                Customer__c = accRecord.id,
                AssociatedPolicyNumber__c = '987 8747-A25-46B',
                CancellationReason__c = 'Moving to new place',
                DateOfContact__c = Date.today(),
                EffectiveDateOfCancellation__c = Date.today(),
                LineOfBusiness__c = 'Auto',
                MethodOfContact__c = 'E-Mail',
                PersonRequestingCancellationName__c = 'Lisa',
                PolicyDescription__c = 'Description',
                ownerId = salesRoleHierarchyForCic.agentOffice.id
            );

            insert cic;
        }

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.TransactionType__c = UTIL_StageOrchestrationConstants.REMOVE_FROM_BOOK_TRANSACTION;
            testStageOrchestration.VersionNumber__c = 1.0;
            testStageOrchestration.Value__c = buildJsonString('IAMCLIENT12', salesRoleHierarchyForCic.Agent.Associate_ID__c);
            stgorcList.add(testStageOrchestration);
            new UTIL_RemoveFromBookProcessor().execute(stgorcList);
        }

        List<CustomerInitiatedCancellations__c> actualCicList = [Select id, name, ownerId, Customer__r.clientIdentifier__c from CustomerInitiatedCancellations__c];
        System.assertEquals(actualCicList.size(), 1, 'Size of List<CustomerInitiatedCancellations__c> not equals to 1');
        for(CustomerInitiatedCancellations__c cicNote: actualCicList) {
            if((cicNote.Id).equals(cic.id)) {
                system.assertEquals('IAMCLIENT12', cicNote.Customer__r.clientIdentifier__c, 'The given two parameters are not equal');
                system.assertNotEquals(cic.ownerId, cicNote.ownerId, 'Expected owner Id is should not be equals to the actual owner Id');

            }
        }
        Test.stopTest();
    }

    //test method to verify LeadMetrics update for losing agent
    @isTest private static void testMethodForLeadMetricsUpdateOnAgentRemoveFromBook() {
        getUsers();
        countandAcc();

        LeadMetrics__c leadMetricsCreation;
        User noAccessProfileUser = UTIL_StageOrchestrationTestUtils.buildtestUser('tstNoAc1', UTIL_Constants.NO_ACCESS_PROFILE_NAME, 'K2PP2PP2P11');
        insert noAccessProfileUser;
        TestData_SalesRoleHierarchy salesRoleHierarchyForLeadMetrics = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('G');

        System.runAs(systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
            insert passTriggerAll;
        }

        System.runAs(salesRoleHierarchyForLeadMetrics.agent) {
            insert accRecord;
            AgentRole__c agentRole11 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchyForLeadMetrics.Agent.Id, agentroleIdentifier__c = salesRoleHierarchyForLeadMetrics.Agent.Associate_ID__c + '~' + accRecord.clientIdentifier__c);
            insert agentRole11;
        }

        System.runAs(systemUser) {
            sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(
                Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,
                SFDC_USER_ID__c = noAccessProfileUser.id
            );
            insert sysAdminUserIdSetting;
            CS001_ByPassTriggerGtoZ__c leadTriggerBypass = new CS001_ByPassTriggerGtoZ__c(Override_LeadBeforeInsert__c = true, Override_LeadAfterInsert__c = true, Override_LeadAfterUpdate__c = true, Override_LeadAfterDelete__c = true);
            insert leadTriggerBypass;
            leadMetricsCreation = new LeadMetrics__c(LeadName__c = 'TestReferralLd-1', CustomerReferrer__c = accRecord.id, ownerId = salesRoleHierarchyForLeadMetrics.agentOffice.id);
            insert leadMetricsCreation;
        }

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.TransactionType__c = UTIL_StageOrchestrationConstants.REMOVE_FROM_BOOK_TRANSACTION;
            testStageOrchestration.VersionNumber__c = 1.0;
            testStageOrchestration.Value__c = buildJsonString('IAMCLIENT12', salesRoleHierarchyForLeadMetrics.Agent.Associate_ID__c);
            stgorcList.add(testStageOrchestration);
            new UTIL_RemoveFromBookProcessor().execute(stgorcList);
        }
        LeadMetrics__c ldMetricRecordAfterUpdate = [Select Id, Status__c, LeadDeletedBy__c, LeadDeletionDate__c from LeadMetrics__c where id=:leadMetricsCreation.id limit 1];
        System.assertEquals('Deleted', ldMetricRecordAfterUpdate.Status__c, 'Status is Incorrect');
        System.assertEquals(testAPIUser.Id, ldMetricRecordAfterUpdate.LeadDeletedBy__c, 'Lead Metric Deleted By is Incorrect');
        System.assert(ldMetricRecordAfterUpdate.LeadDeletionDate__c != null, 'Lead Metric DeletedDate is Incorrect');
        Test.stopTest();
    }

    @isTest
    static void testMethodforEmptyJsonException(){
        getUsers();
        countandAcc();

        system.runAs(testAPIUser){
            Test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = null;
            stgorcList.add(testStageOrchestration);
            try{
                new UTIL_RemoveFromBookProcessor().execute(stgorcList);
                system.assert(false, 'Assertion returns true');
            }
            catch(StageProcessorException ex){
                System.assert(ex.getCause() != null, 'Method \'getCause\' returns null');
                System.assert(ex.getCause() instanceof InvalidInputException, 'Method \'getCause\' has not return an instance of InvalidInputException');
                System.assertEquals(UTIL_StageOrchestrationConstants.EMPTY_JSON_EXCEPTION_MESSAGE, ex.getMessage(), 'Expected exception message is not equals to the actual exception message');
            }
            Test.stopTest();
        }
    }

    /**
     * @description test method for build json string
     * @param clientAccountId
     * @param fromAssociateId
     * @return  `String`
     */
    public static String buildJsonString(String clientAccountId, String fromAssociateId) {
        String json=        '{ '+
            '"orchestrationInfo" : { '+
            '"jsonVersionNumber" : "1.0", '+
            '"orchestrationDataName" : [], '+
            '"orchestrationEventName" : { '+
            '"orchestrationEventType" : "Remove From Book",'+
            '"orchestrationEventDetail" : { '+
            '"orchestrationEventValues" : { '+
            '"ClientId" : "'+clientAccountId+'", '+
            '"fromAssociateId" : "'+fromAssociateId+'" '+
            '} '+
            '} '+
            '} '+
            '} '+
            '}';
        return json;
    }

    private class UTIL_RemoveFromBookProcessor_Test_Wrapper1{

        private Lead leadCreation;
        private Lead[] leadDeletion;
        private Task[] actualTaskList,
        expectedTaskList = new List<Task>();
        private Task taskCreation,
        taskCreation1,
        taskCreation2,
        taskCreation3,
        taskCreationAfterInsert;
        private Case[] originalCaseList,
        expectedCaseList=new List<Case>();
        private Opportunity actualOpportunity,
        expectedOpportunity;
    }

    private class UTIL_RemoveFromBookProcessor_Test_Wrapper2{
        private Case cases,
        cases1,
        cases2,
        cases3,
        casesAfterInsert;
        private Campaign testCampaign;
        private CampaignMember testCampaignMember;
        private CampaignMember[] campaignMemberAfterInsert;
        private ProductsServicedByMe__c productsServicedBeMe;
        private List<ProductsServicedByMe__c> actualProductsServicedByMeList;
    }
	
	private static void insertAccRecordsTest(){
	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(SFDC_USER_ID__c=sysRecOwner.id);
    insert sysAdminUserIdSetting;
    insert accRecord;
    insert counts;
	}


	private static void insertNewAgentRolesTest(){
		AgentRole__c newAgentRole = new AgentRole__c(
			customer__c=accRecord.id, 
			agent__c=agentUser.id,
			agentroleIdentifier__c='1234567test~IAMCLIENT12'
		);
		insert newAgentRole;
	}

	private static void insertLeadCreationTest(){
		User agentQueryAfterInsert = [Select Associate_ID__c from User where id =: agentUser.id];
		accountMessgaeCreation = new AccountMessage__c(AssociateID__c = agentQueryAfterInsert.Associate_ID__c, Account__c = accRecord.Id, Status__c = 'Scheduled');
		insert accountMessgaeCreation;
		remWrap1.leadCreation = new Lead(LastName = 'TestReferralLd-1', CustomerReferrer__c = accRecord.id, ownerId = proxyUser.id,
		recordtypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName().get('SF_Referral').getRecordTypeId());
		insert remWrap1.leadCreation;
	}

	private static void insertCampaignMemberTest(){
			Account testcontact = [SELECT PersonContactId FROM Account WHERE id = :accRecord.id];
				remWrap2.testCampaignMember = new CampaignMember(
					CampaignId = remWrap2.testCampaign.Id,
					Status = 'Sent',
					ContactId = testcontact.PersonContactId
				);
				insert remWrap2.testCampaignMember;
	}
	
	private static void  insertHouseHoldGroupMemberTest(){
		CustomerGroup__c houseHoldGroup = new CustomerGroup__c(Agent__c=agentUser.id, GroupCategory__c='Primary', SFGroupIdentifier__c='IAMGR0UPID0');
        insert houseHoldGroup;
        CustomerGroupMember__c houseHoldGroupMember = new CustomerGroupMember__c(Customer__c=accRecord.id, Group__c=houseHoldGroup.Id,GroupMemberId__c='IAMGR0UPID0~IAMCLIENT12');
        insert houseHoldGroupMember;
	}

	private static void insertOpportunityTest(){
	        remWrap1.taskCreation =new Task (WhatId=accRecord.Id, subject='Call',Description='TASK111', status='Incomplete',AssignedTo__c=agentUser.id);
            remWrap1.taskCreation1 =new Task (WhatId=accRecord.Id, subject='Call',Description='TASK222', status='InProgress',AssignedTo__c=agentUser.id);
            remWrap1.taskCreation2 =new Task (WhatId=accRecord.Id, subject='Call',Description='TASK222', status='Completed',AssignedTo__c=agentUser.id);
            remWrap1.expectedTaskList.add(remWrap1.taskCreation);
            remWrap1.expectedTaskList.add(remWrap1.taskCreation1);
            remWrap1.expectedTaskList.add(remWrap1.taskCreation2);
            insert remWrap1.expectedTaskList;
            remWrap2.cases =new Case (accountid=accRecord.Id,Description='Cases', Case_Originator__c = 'CCC Sales', status='new',OwnerId=proxyUser.id);
            remWrap2.cases1 =new Case (accountid=accRecord.Id,Description='Cases1', Case_Originator__c = 'CCC Sales', status='onhold',OwnerId=proxyUser.id);
            remWrap2.cases2 =new Case (accountid=accRecord.Id,Description='Cases2', Case_Originator__c = 'CCC Sales', status='Closed',OwnerId=proxyUser.id);
            remWrap1.expectedCaseList.add(remWrap2.cases);
            remWrap1.expectedCaseList.add(remWrap2.cases1);
            remWrap1.expectedCaseList.add(remWrap2.cases2);
            insert remWrap1.expectedCaseList;
            remWrap1.expectedOpportunity = new Opportunity(AccountId=accRecord.Id ,Name = 'testOpp', CloseDate=Date.today(), StageName='New',description='testDescription',LOB__c='Auto',
                                                  Assigned_To__c=agentUser.id,OwnerId=proxyUser.id );
            insert remWrap1.expectedOpportunity;	
    }
    //Testing Stage Orchestration Records in system mode
    private static void testingStageOrchestration()
    {
         StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        testStageOrchestration.TransactionType__c=UTIL_StageOrchestrationConstants.REMOVE_FROM_BOOK_TRANSACTION;
        testStageOrchestration.VersionNumber__c=1.0;
        testStageOrchestration.Value__c=buildJsonString('IAMCLIENT12','1234567test');
        System.runAs(testAPIUser) {
            test.startTest();
            insert testStageOrchestration;
            test.stopTest();
        }
        System.runAs(agentUser) {
            account[] testAccountList = [SELECT id FROM account WHERE id = :accRecord.Id];
            System.assert(testAccountList.isEmpty(), 'Account[] is not empty');
        }
    }

	private static void getTestStageOrchestration(){
		StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        testStageOrchestration.TransactionType__c=UTIL_StageOrchestrationConstants.REMOVE_FROM_BOOK_TRANSACTION;
        testStageOrchestration.VersionNumber__c=1.0;
        testStageOrchestration.Value__c=buildJsonString('IAMCLIENT12','1234567test');
        System.runAs(testAPIUser) {
            test.startTest();
            insert testStageOrchestration;
            test.stopTest();
        }
        System.runAs(agentUser)  {
            account[] testAccountList=[Select id From account where id=:accRecord.Id];
            System.assert(testAccountList.isEmpty(), 'Account[] is not empty');
        }
         //Agent will not be able to see AgentRole__c,Task,opportunity,AccountMessage__c,CampaignMember that's why asserting in system mode
        agentRoleDeletion=[Select id From AgentRole__c where Customer__c=:accRecord.Id];
        system.assert(agentRoleDeletion.isEmpty(), 'SOQL query has not return empty list of AgentRole__c');
        remWrap1.actualTaskList=[select id,WhatId,subject,OwnerId,Description,status,AssignedTo__c from task where WhatId=:accRecord.Id AND id!=:remWrap1.taskCreation2.Id];
        //Task assertion for changing the status which are not completed to Removed From Book
        for(Task taskAssertion : remWrap1.actualTaskList){
            system.assertEquals(UTIL_StageOrchestrationConstants.OPPORTUNITY_TASK_CLOSED_REASON, taskAssertion.status, 'The given two parameters are not equal');
            system.assertEquals(sysRecOwner.Id, taskAssertion.OwnerId, 'Expected owner Id is not equals to the actual owner Id');
            system.assertEquals(proxyUser.id, taskAssertion.AssignedTo__c, 'The given two parameters are not equal');
        }
        remWrap1.taskCreationAfterInsert=[Select WhatId,subject,Description from task where Id=:remWrap1.taskCreation.Id];
        system.assertEquals(remWrap1.taskCreation.WhatId, remWrap1.taskCreationAfterInsert.WhatId, 'Expected WhatId is not equals to the actual WhatId');
        system.assertEquals(remWrap1.taskCreation.Subject, remWrap1.taskCreationAfterInsert.Subject, 'Expected Task subject is not equals to the actual Task subject');
        system.assertEquals(remWrap1.taskCreation.Description, remWrap1.taskCreationAfterInsert.Description, 'Expected Task description is not equals to the actual Task description');
        //Task which are Completed doesn't have any impact through this Remove from book process
        remWrap1.taskCreationAfterInsert=[Select OwnerId,AssignedTo__c,status from task where Id=:remWrap1.taskCreation2.Id];
        system.assertEquals(remWrap1.taskCreation2.Status, remWrap1.taskCreationAfterInsert.status, 'Expected Task status is not equals to the actual Task status');
        system.assertEquals(proxyUser.Id, remWrap1.taskCreationAfterInsert.AssignedTo__c, 'The given two parameters are not equal');
        system.assertEquals(sysRecOwner.Id, remWrap1.taskCreationAfterInsert.OwnerId, 'Expected owner Id is not equals to the actual owner Id');
        //Case assertion for changing the status which are not Closed to Closed
        remWrap1.originalCaseList=[select id,accountID,OwnerId,Description,status from Case where accountID=:accRecord.Id AND id!=:remWrap2.cases2.Id];
        for(Case caseAssertion : remWrap1.originalCaseList){
            system.assertEquals(UTIL_StageOrchestrationConstants.CASE_CLOSE_STATUS, caseAssertion.status, 'Expected status is not equals to the actual status');
            system.assertEquals(sysRecOwner.Id, caseAssertion.OwnerId, 'Expected owner Id is not equals to the actual owner Id');
        }
        //Cases which are Closed doesn't have any impact through this Remove from book process
        remWrap2.casesAfterInsert=[select accountId,Status,OwnerId from Case where Id=:remWrap2.cases2.Id];
        system.assertEquals(remWrap2.cases2.Status, remWrap2.casesAfterInsert.status, 'Expected case status is not equals to the actual case status');
        remWrap1.actualOpportunity = [select name,OwnerId,AccountId,StageName,description,CloseDate,Assigned_To__c from Opportunity where id=:remWrap1.expectedOpportunity.Id];
        system.assertEquals(remWrap1.expectedOpportunity.Name, remWrap1.actualOpportunity.name, 'Expected Opportunity name is not equals to the actual Opportunity name');
        system.assertEquals(proxyUser.id, remWrap1.actualOpportunity.Assigned_To__c, 'The given two parameters are not equal');
        system.assertEquals(sysRecOwner.id, remWrap1.actualOpportunity.OwnerId, 'Expected owner Id is not equals to the actual owner Id');
        system.assertEquals(remWrap1.expectedOpportunity.AccountId, remWrap1.actualOpportunity.AccountId, 'Expected Account Id is not equals to the actual Account Id');
        system.assertEquals(UTIL_StageOrchestrationConstants.OPPORTUNITY_CLOSED_STAGE_NAME , remWrap1.actualOpportunity.StageName, 'Expected Opportunity stage name is not equals to the actual Opportunity stage name');
        system.assertNotEquals(remWrap1.expectedOpportunity.Description, remWrap1.actualOpportunity.description, 'Expected Opportunity description is equals to the actual Opportunity description');
        accountMessgae = [select id from AccountMessage__c where id=:accountMessgaeCreation.id];
        system.assert(accountMessgae.isEmpty(), 'SOQL query has not return empty list of AccountMessage__c');
        remWrap1.leadDeletion = [select id from Lead where id=:remWrap1.leadCreation.id];
        system.assert(remWrap1.leadDeletion.isEmpty(), 'SOQL query has not return empty list of Lead');
        //CampaignMember assertion weather it is removed from his book
        remWrap2.campaignMemberAfterInsert =[select id from CampaignMember where id=:remWrap2.testCampaignMember.Id];
        system.assert(remWrap2.campaignMemberAfterInsert.isEmpty(), 'SOQL query has not return empty list of CampaignMember');
	}
}