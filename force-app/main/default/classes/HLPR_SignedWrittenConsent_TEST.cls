/**
Author Team ClubCar
Name - HLPR_SignedWrittenConsent_TEST
@description Test class written for HLPR_SignedWrittenConsent 
========================================================================================================================================+
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                10/20/2020              Initial Development
/*
VERSION         AUTHOR                  DATE                DETAIL
2.0            Team Incognito          09/06/2022           Team Incognito - Remove duplicate code /Refactor
******************************************************************************************************************************************/
@isTest()
public class HLPR_SignedWrittenConsent_TEST {
    
    private static User sysAdminuser;
    private static Account testAccount;
    private static User agentUser;
    private static User proxyUser;
    private static User systemUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    
    //setup method to set test data for Agent Office Creation of Agent, ATM, Proxy Users
    @TestSetup
    private static void setUpTriggerAndUserData() {
        systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();  
        insert systemUser;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);            
        insert sysAdminUserIdSetting;
        sysAdminuser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert sysAdminuser;
        createSwcToggleRecord();
        System.runAs(sysAdminuser) {
            agentStandardUserRole= new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentStandardUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='opportunityAg',Username='TestProxUserForOppTst11@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            Database.insert(proxyUser);
            User testAgentUser1 = new User(Alias='Alia',LastName='opportunityProxy',Username='TestAgtUserForOppTst11@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            Database.insert(agentUser);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        }
    }
    
    //method to build Account record with the given parameter value
    private static Account buildAccountRecord(String paramClientIdentifier) {
        String acctRecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId;
        Account acctRecord = new Account(FirstName = 'rrrrr', LastName = 'tttttttt', ClientIdentifier__c = paramClientIdentifier,RecordTypeId = acctRecordTypeId,
                                         Edit_In_VFP__c = true,PersonDoNotCall = true,BillingState = 'TX');
        return acctRecord;
    }
    
    //method to build Opportunity record with the given parameter value
    private static Opportunity buildOpportunityRecord(String paramAccountId, String paramLOB, Boolean populateSwcFields) {
        Opportunity opptyRecord = new Opportunity (Name = 'Tst Opportunity', AccountId = paramAccountId,CloseDate = System.today().addDays(10), LOB__c = paramLOB,
                                                   StageName = 'Assigned',DateCaptured__c = System.today().addDays(-9));
        if(populateSwcFields){
            opptyRecord.OppSignedWrittenConsentRequestedDate__c = System.Today();
            opptyRecord.OppSignedWrittenConsentStatus__c = 'Requested';
        }
        return opptyRecord; 
    }

    /**
     * @description createSwcToggleRecord
     */
    //method to build signed written consent toggle record
    public static void createSwcToggleRecord(){
        Toggle__c toggleRecord = new Toggle__c (FeatureName__c = 'SignedWrittenConsent', Status__c = false);
        insert toggleRecord;
    }
    
    //testMethod to test signed written consent on opportunity create
    @isTest
    private static void testSWCOnOpportunityCreate(){
        /*User queryAgent = [Select id from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];        
        agentUser= queryAgent;        
        Account testAccount;
        System.runAs(agentUser) {
            testAccount = TestDataFactory_Journey.buildAccountRecord('1213121');
            insert testAccount;            
        }*/

        agentUser = retrieveAgentMethod();     
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
        System.runAs(agentUser) {
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(buildOpportunityRecord(testAccount.id, 'Auto', true));
            oppList.add(buildOpportunityRecord(testAccount.id, 'Fire', true));
            oppList.add(buildOpportunityRecord(testAccount.id, 'Bank', true));
            oppList.add(buildOpportunityRecord(testAccount.id, 'Life', true));
            Test.startTest();
            insert oppList;            
            Test.stopTest();            
            for(Opportunity oppRecord : [Select id, OppSignedWrittenConsentGrantedDate__c , OppSignedWrittenConsentRequestedDate__c,
                                         OppSignedWrittenConsentStatus__c, DateCaptured__c from Opportunity where AccountId = :testAccount.id]){
                System.assertEquals(null, oppRecord.OppSignedWrittenConsentGrantedDate__c, 'Opportunity SWC GrantedDate was not updated to null');
                System.assertEquals(null, oppRecord.OppSignedWrittenConsentRequestedDate__c, 'Opportunity SWC RequestedDate was not updated to null');
                System.assertEquals(null, oppRecord.OppSignedWrittenConsentStatus__c, ' Opportunity SWC Status was not updated to null');                                 
            }
        }      
    }
    
    //testMethod to verify SWC date captured logic is not executed on Organization Accounts.
    @isTest
    private static void testSWCOnOpportunityCreateOnOrgAcc(){
        User queryAgent = [Select id from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];        
        agentUser= queryAgent;        
        Account test_Account;
        System.runAs(agentUser) {
            test_Account = buildAccountRecord('1213121');            
            Id orgRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Organization' AND SobjectType = 'Account' Limit 1].Id;
            test_Account.RecordTypeId = orgRecordTypeId;
            insert test_Account;            
        }        
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=test_Account.id, agent__c=agentUser.id);
        insert newAgentRole;
        System.runAs(agentUser) {
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(buildOpportunityRecord(test_Account.id, 'Auto', false));
            oppList.add(buildOpportunityRecord(test_Account.id, 'Fire', false));
            Test.startTest();
            insert oppList;            
            Test.stopTest();            
            for(Opportunity oppRecord : [Select id, Opportunity.Account.RecordType.Name, OppSignedWrittenConsentGrantedDate__c , OppSignedWrittenConsentRequestedDate__c,
                                         OppSignedWrittenConsentStatus__c, DateCaptured__c from Opportunity where AccountId = :test_Account.id]){
                System.assertEquals(System.today() - 9 , oppRecord.DateCaptured__c, 'Opportunity Date Captured was not updated');
                System.assertEquals(null, oppRecord.OppSignedWrittenConsentGrantedDate__c, 'Opportunity SWC GrantedDate was not updated to null');
                System.assertEquals(null, oppRecord.OppSignedWrittenConsentRequestedDate__c, 'Opportunity SWC RequestedDate was not updated to null');
                System.assertEquals(null, oppRecord.OppSignedWrittenConsentStatus__c, ' Opportunity SWC Status was not updated to null');                                 
            }
        }      
    }
    
    //testMethod to test signed written consent on opportunity create with account person do not call as false and billing state not TX
    @isTest
    private static void testSWCOnNotPersonDoNotCallAccountOpportunityCreate(){
        User queryAgent = [Select id from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];        
        agentUser= queryAgent;        
        Account testAccount;
        System.runAs(agentUser) {
            testAccount = buildAccountRecord('1213121');
            testAccount.PersonDoNotCall=false;
            insert testAccount;            
        }
            
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
        System.runAs(agentUser) {
            Opportunity opptyRecord = buildOpportunityRecord(testAccount.id, 'Auto', false);  
            Test.startTest();
            insert opptyRecord; 
            Test.stopTest();
            List<Opportunity> opptyList = [Select id,DateCaptured__c from Opportunity where AccountId = :testAccount.id];
            Datetime dateCaptured = opptyList[0].DateCaptured__c;
            System.assertEquals(dateCaptured, opptyList[0].DateCaptured__c, 'Opportunity Date Captured is updated');        }        
    }

    //testMethod to test swc on opportunity create and check date captured is not updated on closed and closed won opportunities
    @isTest
    private static void testSWCForClosedAndClosedWonOpportunitiesOnOpportunityCreate(){
        /*User queryAgent = [Select id from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];        
        agentUser= queryAgent;
        Account testAccount;
        System.runAs(agentUser) {
            testAccount = TestDataFactory_Journey.buildAccountRecord('1213121');
            insert testAccount;            
        }*/

        agentUser = retrieveAgentMethod();
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
        System.runAs(agentUser) {
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity closedOppty = buildOpportunityRecord(testAccount.id, 'Auto', true);
            closedOppty.StageName = 'Closed';
            Opportunity closedWonOppty = buildOpportunityRecord(testAccount.id, 'Fire', true);
            closedWonOppty.StageName = 'Closed Won';
            oppList.add(closedOppty);
            oppList.add(closedWonOppty);
            oppList.add(buildOpportunityRecord(testAccount.id, 'Auto', true));
            oppList.add(buildOpportunityRecord(testAccount.id, 'Fire', true));
            Test.startTest();
            insert oppList; 
            Test.stopTest();
            for (Opportunity oppRecord : [Select id,DateCaptured__c, StageName, OppSignedWrittenConsentStatus__c,  OppSignedWrittenConsentRequestedDate__c from Opportunity]){
                if ('Closed'.equals(oppRecord.StageName) || 'Closed Won'.equals(oppRecord.StageName)){
                    System.assertEquals(System.today().addDays(-9), oppRecord.DateCaptured__c, 'Opportunity Date Captured is not as expected');
                }
                else {
                    System.assertEquals(null, oppRecord.OppSignedWrittenConsentStatus__c, 'Opportunity SWC status was not updated');
                }
            }
         
        }        
    }    
    
    //testMethod to test swc tasks cancel on opportunity create
    @isTest
    private static void testSWCTaskCancelOnOpportunityCreate(){
        String taskDescription = 'Beginning this due date, consent has been provided to continue marketing efforts.Depending on the state, this can be a 30 day window or a 90 day window that you are able to market to the prospect';
        User queryAgent = [Select id from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];        
        agentUser= queryAgent;
        Account testAccount;
        Account testAccount1;
        CS001_ByPassTriggerGtoZ__c objectBasedByPassTrigger = CS001_ByPassTriggerGtoZ__c.getInstance();
        System.runAs(agentUser) {
            testAccount = buildAccountRecord('1213121');
            testAccount.BillingState = 'MO';
            insert testAccount;
            testAccount1 = buildAccountRecord('1213333');
            insert testAccount1;         
        }
        
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
        agentRoleList.add(new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id));
        agentRoleList.add(new AgentRole__c(customer__c=testAccount1.id, agent__c=agentUser.id));
        insert agentRoleList;
        objectBasedByPassTrigger.Override_OpportunityAfterInsert__c = true;
        insert objectBasedByPassTrigger;
        System.runAs(agentUser) {
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(buildOpportunityRecord(testAccount.id, 'Auto', true));
            oppList.add(buildOpportunityRecord(testAccount.id, 'Fire', true));
            oppList.add(buildOpportunityRecord(testAccount1.id, 'Auto', true));
            oppList.add(buildOpportunityRecord(testAccount1.id, 'Fire', true));
            insert oppList;
            
            List<Task> taskList = new List<Task>();
            taskList.add(new Task (WhatId=oppList.get(0).Id, subject='Signed Written Consent Granted',ActivityDate = Date.today(),Description=taskDescription,TaskCategory__c='Journey',AppCode__c = 'SFDC_MKTCLD'));
            taskList.add(new Task (WhatId=oppList.get(1).Id, subject='Other',ActivityDate = Date.today(),Description='Call',TaskCategory__c='Marketing',AppCode__c = 'Auto Change and Service'));
            taskList.add(new Task (WhatId=oppList.get(1).Id, subject='Call',ActivityDate = Date.today(),Description='Call to quote',TaskCategory__c='Application/Policy',AppCode__c = 'SFDC ILP Journey'));
            taskList.add(new Task (WhatId=oppList.get(2).Id, subject='Send Letter',ActivityDate = Date.today(),Description='Send Mail',TaskCategory__c='Account Change',AppCode__c = 'SFDC Customer Separate'));
            taskList.add(new Task (WhatId=oppList.get(3).Id, subject='Signed Written Consent Granted',ActivityDate = Date.today(),Description=taskDescription,TaskCategory__c='Journey',AppCode__c = 'SFDC_MKTCLD'));
            insert taskList;
            objectBasedByPassTrigger.Override_OpportunityAfterInsert__c = false;
            update objectBasedByPassTrigger;
            List<Opportunity> opportunityInsertList = new List<Opportunity> ();
            opportunityInsertList.add(buildOpportunityRecord(testAccount.id, 'Auto', false));
            opportunityInsertList.add(buildOpportunityRecord(testAccount1.id, 'Fire', false));
            Test.startTest();
            insert opportunityInsertList;
            Test.stopTest();
            List<Task> cancelledTaskList = [Select Id from Task where Status = 'Cancelled'];
            System.assert(cancelledTaskList.size() == 2, 'Unexpected Cancelled SWC Task List Size');
        }        
    }
    
    //test method to check exception
    @isTest
    private static void testSwcOnOpportunityCreateException(){
        Test.startTest();
        HLPR_SignedWrittenConsent.processConsentOnOpportunityCreate(null);
        Test.stopTest();
        List<ExceptionLog__c> exLog = [SELECT Id from ExceptionLog__c class__c where class__c = 'HLPR_SignedWrittenConsent'
                                      AND Method__c = 'processConsentOnOpportunityCreate'];           
        system.assert(exLog.size() == 1, 'Unexpected exceptionLogSize');     
    } 

    //test method to check exception
    @isTest
    private static void testSwcCreateException(){
        Test.startTest();
        HLPR_SignedWrittenConsent.processSWCRequestedRecords(null);
        Test.stopTest();
        List<ExceptionLog__c> exLog = [SELECT Id from ExceptionLog__c class__c where class__c = 'HLPR_SignedWrittenConsent'
                                      AND Method__c = 'processSwcRequestedRecords'];            
        system.assert(exLog.size() == 1, 'Unexpected exceptionLogSize');     
    }    
    
    // test methos to verify duplicate swc records on same Account and Office are dismissed
    @isTest
    private static void testSwcOldRecordsGetDismissed(){
        /*User queryAgent = [Select id from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];        
        agentUser= queryAgent;        
        Account testAccount;
        System.runAs(agentUser) {
            testAccount = TestDataFactory_Journey.buildAccountRecord('1213121');
            insert testAccount;            
        }*/

        agentUser = retrieveAgentMethod();           
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
        System.runAs(agentUser) {
            Opportunity swcOpp = buildOpportunityRecord(testAccount.id, 'Auto', false);
            insert swcOpp;
            SignedWrittenConsent__c signedWrittenConsentRecord = TestDataFactory_Journey.buildSwcRecord(System.Today()-30, System.Today(), swcOpp);
            insert signedWrittenConsentRecord;
            SignedWrittenConsent__c signedWrittenConsentRecord1 = TestDataFactory_Journey.buildSwcRecord(System.Today(), System.Today()+30, swcOpp);
            Test.startTest();
            insert signedWrittenConsentRecord1;
            Test.stopTest(); 
            SignedWrittenConsent__c oldSwcRecord = [Select Status__c from SignedWrittenConsent__c where Id =:signedWrittenConsentRecord.Id];
            System.assert('Not Applicable'.equals(oldSwcRecord.Status__c),'Duplicate swc record status was not updated');
        }
    }
    
    // test method to verify Signed Written consent After Insert Trigger is bypassed
    @isTest
    private static void testSwcAfterInsertTriggerBypassed(){
        User queryAgent = [Select id from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];        
        agentUser= queryAgent;        
        Account testAccount;
        System.runAs(agentUser) {
        	CS001_ByPassTriggerGtoZ__c objectBasedByPassTrigger = CS001_ByPassTriggerGtoZ__c.getInstance();
        	objectBasedByPassTrigger.Override_SWCAfterInsert__c = true;
        	insert objectBasedByPassTrigger; 
            testAccount = buildAccountRecord('1213121');
            insert testAccount;            
        }            
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
        System.runAs(agentUser) {
            Opportunity swcOpp = buildOpportunityRecord(testAccount.id, 'Auto', false);
            insert swcOpp;
            SignedWrittenConsent__c signedWrittenConsentRecord = TestDataFactory_Journey.buildSwcRecord(System.Today()-30, System.Today(), swcOpp);
            insert signedWrittenConsentRecord;
            SignedWrittenConsent__c signedWrittenConsentRecord1 = TestDataFactory_Journey.buildSwcRecord(System.Today(), System.Today()+30, swcOpp);
            Test.startTest();
            insert signedWrittenConsentRecord1;
            Test.stopTest(); 
            SignedWrittenConsent__c oldSwcRecord = [Select Status__c from SignedWrittenConsent__c where Id =:signedWrittenConsentRecord.Id];
            System.assert('Requested'.equals(oldSwcRecord.Status__c),'SWC After Insert trigger was not bypassed');            
        }
    }

    // helper method to build Signed ritten Consent records
    /*private static SignedWrittenConsent__c buildSwcRecord(Date consentStartDate, Date consentEndDate, Opportunity oppForSwc) {
        SignedWrittenConsent__c signedWrittenConsentRecord = new SignedWrittenConsent__c();
        signedWrittenConsentRecord.InitiatedFromId__c = oppForSwc.Id;
        signedWrittenConsentRecord.Account__c = oppForSwc.AccountId;
        signedWrittenConsentRecord.Status__c = 'Requested';
        signedWrittenConsentRecord.RequestStartDate__c = consentStartDate;
        signedWrittenConsentRecord.RequestEndDate__c = consentEndDate;
        signedWrittenConsentRecord.RequestedDate__c = System.Today();
        return signedWrittenConsentRecord;
    }  */ 

    /* @Refactor
    * @method- retrieveAgentMethod
    * @description -Return agent Users data, method to avoid deplicate code
    * @return - User
    */
	private static User  retrieveAgentMethod() { 
    
        User queryAgent = [Select id from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];        
        agentUser= queryAgent;       
        System.runAs(agentUser) {
            testAccount = buildAccountRecord('1213121');
            insert testAccount;            
        }          
    return queryAgent;
    }
}