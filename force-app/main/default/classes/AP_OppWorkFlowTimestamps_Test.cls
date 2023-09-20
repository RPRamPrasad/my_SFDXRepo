/**
Author Team Quadcore
Name - AP_OppWorkFlowTimestamps_Test
@description Test class written for AP_OppWorkFlowTimestamps_Test 
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     added @isTest annotations
**/
@isTest()
public with sharing class AP_OppWorkFlowTimestamps_Test {
    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static User systemUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static UserRole agentTeamMemberUserRole;
    
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    
    @TestSetup
    private static void setUpTriggerAndUserData() {
        systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();  
        insert systemUser;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);            
        insert sysAdminUserIdSetting;
        sysAdminuser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert sysAdminuser;           
        
        System.runAs(sysAdminuser) {
            agentStandardUserRole= new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            agentTeamMemberUserRole = new UserRole(name= 'AgentTeamMemberRole', parentRoleId = agentStandardUserRole.id);
            insert agentTeamMemberUserRole;
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentTeamMemberUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='opportunityAg',Username='TestProxUserForOppTst11@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            Database.insert(proxyUser);
            User testAgentUser1 = new User(Alias='Alia',LastName='opportunityProxy',Username='TestAgtUserForOppTst11@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            Database.insert(agentUser);
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        }
    }
    private static Account buildAccountRecord(String paramClientIdentifier) {
        String acctRecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId;
        return new Account(FirstName = 'rrrrr', LastName = 'tttttttt', ClientIdentifier__c = paramClientIdentifier,RecordTypeId = acctRecordTypeId,Edit_In_VFP__c = true
                                        );
    
    }
    
    //method to build Opportunity record with the given parameter value
    private static Opportunity buildOpportunityRecord(String paramAccountId) {
        Opportunity opptyRecord = new Opportunity ();
        opptyRecord.Name = 'Tst Opportunity';
        opptyRecord.AccountId = paramAccountId;
        opptyRecord.CloseDate = System.today().addDays(10);
        opptyRecord.LOB__c = 'Fire';
        opptyRecord.StageName = 'New';
        
        return opptyRecord; 
    }
    
    @isTest
    private static void testUpdatedOpportunityNotClosed(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
        Opportunity opportunity = new Opportunity();
        
        System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213121');
            acctRecord.PersonDoNotCall=true;
            insert acctRecord;  
        }
        testAccount = [select id, ClientIdentifier__c, ownerId from Account where CreatedbyId =:agentUser.id Limit 1];
       
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
 
        System.runAs(agentUser) {
            CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            byPass.Override_OpportunityAfterInsert__c = true;
            insert byPass;
            opportunity = buildOpportunityRecord(testAccount.id);
            insert opportunity;
			
            opportunity.StageName='Closed';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today(), opportunity.CloseDate, 'CloseDate is updated successfully');
            System.assertEquals(System.now().date(), opportunity.OppAssignedDateTime__c.date(), 'OppAssignedDateTime__c is updated successfully');
           
            
            opportunity.StageName= 'Closed Won';
            opportunity.CloseDate= System.today().addDays(10);
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,Last_Modified_by_Sales_Associate__c,Last_Modified_Date_By_Sales_Associate__c from Opportunity where Id=:opportunity.Id Limit 1];

            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertNotEquals(null, opportunity.Last_Modified_by_Sales_Associate__c, 'Custom Last modified By is updated successfully');
            System.assertNotEquals(null, opportunity.Last_Modified_Date_By_Sales_Associate__c, 'Custom last modified date is updated successfully');
        }
    }

    @isTest
    private static void testUpdatedOpportunityWithSystemAdmin(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        User systemAd = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'systemAdminTest@statefarm.com' LIMIT 1];      
		sysAdminuser=systemAd;
        Account testAccount;
        Opportunity opportunity = new Opportunity();
        
        System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213121');
            acctRecord.PersonDoNotCall=true;
            insert acctRecord;  
        }
        testAccount = [select id, ClientIdentifier__c, ownerId from Account where CreatedbyId =:agentUser.id Limit 1];
       
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
 
        System.runAs(agentUser) {
            CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            byPass.Override_OpportunityAfterInsert__c = true;
            insert byPass;
            opportunity = buildOpportunityRecord(testAccount.id);
            insert opportunity;
        
        }
        
        System.runAs(sysAdminuser) {
            opportunity.Source_Comments__c ='Test';
            update opportunity;
             opportunity = [select Id, CloseDate, OppAssignedDateTime__c,Last_Modified_by_Sales_Associate__c,Last_Modified_Date_By_Sales_Associate__c from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(null, opportunity.Last_Modified_by_Sales_Associate__c, 'Custom Last modified By is updated successfully');
            System.assertEquals(null, opportunity.Last_Modified_Date_By_Sales_Associate__c, 'Custom last modified date is updated successfully');           

        }
            
    }

    @isTest
    private static void testUpdatedOpportunityCloseDateFuture(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
        Opportunity opportunity = new Opportunity();
        
        System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213121');
            acctRecord.PersonDoNotCall=true;
            insert acctRecord;
        }
        testAccount = [select id, ClientIdentifier__c, ownerId from Account where CreatedbyId =:agentUser.id Limit 1];
       
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
 
        System.runAs(agentUser) {
            CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            byPass.Override_OpportunityAfterInsert__c = true;
            insert byPass;
            opportunity = buildOpportunityRecord(testAccount.id);
            insert opportunity;
			//When stage is closed, then user is able to update the closed date to future date
            opportunity.StageName='Closed';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today(), opportunity.CloseDate, 'CloseDate is updated to Current Date');
            System.assertEquals('Closed',opportunity.StageName,'Expected value is Closed, but actual value is '+opportunity.StageName);

            opportunity.CloseDate = System.today().addDays(10);
            update opportunity;

            opportunity = [select Id, CloseDate, OppAssignedDateTime__c from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today().addDays(10), opportunity.CloseDate, 'CloseDate is Updated to Future Date');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not Equal to Current Date');
            
            //When stage is Closed Won, then user is able to update the closed date to future date
            opportunity.StageName='Closed Won';
            update opportunity;
            
            opportunity.CloseDate = System.today().addDays(10);
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today().addDays(10), opportunity.CloseDate, 'CloseDate is Updated to Future Date');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not Equal to Current Date');
            System.assertEquals('Closed Won',opportunity.StageName,'Expected value is Closed Won, but actual value is '+opportunity.StageName);
            
            //When moves from Closed to Closed Won, if the Close date was set to future, it updates to Current Date
            opportunity.StageName='Closed';
            opportunity.CloseDate = System.today().addDays(10);
            update opportunity;
            
            opportunity.StageName='Closed Won';
            update opportunity;
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
			System.assertEquals(System.today(), opportunity.CloseDate, 'CloseDate is Updated to Current Date successfully');
            System.assertEquals('Closed Won',opportunity.StageName,'Expected value is Closed Won, but actual value is '+opportunity.StageName);
            opportunity.CloseDate = System.today().addDays(10);
            
            //When moving from Closed Won to Closed, and close date is set as a future date then no updates to Close date
            opportunity.StageName='Closed';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today().addDays(10), opportunity.CloseDate, 'CloseDate updated to Future Date Sucessfuly');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not equal to current date');
            System.assertEquals('Closed',opportunity.StageName,'Expected value is Closed, but actual value is '+opportunity.StageName);
            
            //If Stage set to Closed. Future date updated for Closed date.  Then anything else is modified then no updates to Close date
            opportunity.Status__c= 'Cancelled';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today().addDays(10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Closed',opportunity.StageName,'Expected value is Closed, but actual value is '+opportunity.StageName);
            
            //If stage set to Closed Won. Future date updated for Closed date.  Then anything else is modified then no updates to Close date
            opportunity.StageName='Closed Won';
            opportunity.CloseDate = System.today().addDays(10);
            update opportunity;
            
            opportunity.Status__c= 'Cancelled';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today().addDays(10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Closed Won',opportunity.StageName,'Expected value is Closed Won, but actual value is '+opportunity.StageName);
           
        }
    }
    
    @isTest
    private static void testUpdatedOpportunityOpenStageToClosedAndCloseDateFuture(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
        Opportunity opportunity = new Opportunity();
        
        System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213121');
            acctRecord.PersonDoNotCall=true;
            insert acctRecord;
        }
        testAccount = [select id, ClientIdentifier__c, ownerId from Account where CreatedbyId =:agentUser.id Limit 1];
       
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
 
        System.runAs(agentUser) {
            CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            byPass.Override_OpportunityAfterInsert__c = true;
            insert byPass;
            opportunity = buildOpportunityRecord(testAccount.id);
            insert opportunity;

            opportunity.StageName='Closed';
            opportunity.CloseDate = System.today().addDays(10);
            update opportunity;
            
            //If the stage changes from quoting(open stage) to closed and update the Closed Date to future date (2 fields at the sametime), closed date updates to current date
            opportunity.StageName='Quoting';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Quoting',opportunity.StageName,'');
            
            AP_OpportunityTrigger.runOnce=true;
            opportunity.StageName='Closed';

            opportunity.Status__c= 'Cancelled';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertNotEquals(System.today().addDays(10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Closed',opportunity.StageName,'Expected value is Closed, but actual value is '+opportunity.StageName);
            
            //If the stage changes from quoting(open stage) to closed Won and update the Closed Date to future date (2 fields at the sametime), closed date updates to current date
            opportunity.StageName='Quoting';
            opportunity.CloseDate = System.today().addDays(10);
            update opportunity;
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Quoting',opportunity.StageName,'Expected value is Quoting, but actual value is '+opportunity.StageName);
            
            AP_OpportunityTrigger.runOnce=true;
            opportunity.StageName='Closed Won';
            opportunity.Status__c= 'Cancelled';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertNotEquals(System.today().addDays(10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Closed Won',opportunity.StageName,'Expected value is Closed Won, but actual value is '+opportunity.StageName);
        }
    }
    
    @isTest
    private static void testUpdatedOpportunityCloseDatePast(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
        Opportunity opportunity = new Opportunity();
        
        System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213121');
            acctRecord.PersonDoNotCall=true;
            insert acctRecord;
        }
        testAccount = [select id, ClientIdentifier__c, ownerId from Account where CreatedbyId =:agentUser.id Limit 1];
       
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
 
        System.runAs(agentUser) {
            CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            byPass.Override_OpportunityAfterInsert__c = true;
            insert byPass;
            opportunity = buildOpportunityRecord(testAccount.id);
            insert opportunity;
            
            //When stage is closed, then user is able to update the closed date to Past date
            opportunity.StageName='Closed';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today(), opportunity.CloseDate, 'CloseDate is updated successfully');
            System.assertEquals('Closed',opportunity.StageName,'Expected value is Closed, but actual value is '+opportunity.StageName);

            opportunity.CloseDate = System.today().addDays(-10);
            update opportunity;

            opportunity = [select Id, CloseDate, OppAssignedDateTime__c from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today().addDays(-10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            
            //When stage is closed Won, then user is able to update the closed date to Past date
            opportunity.StageName='Closed Won';
            opportunity.CloseDate = System.today().addDays(-10);
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today().addDays(-10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Closed Won',opportunity.StageName,'Expected value is Closed Won, but actual value is '+opportunity.StageName);
            
            opportunity.StageName='Closed';
            opportunity.CloseDate = System.today().addDays(-10);
            update opportunity;
            
            //When moves from Closed to Closed Won, if the Close was set to past date, no updates to closed Date
            opportunity.StageName='Closed Won';
            update opportunity;
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
			System.assertEquals(System.today().addDays(-10), opportunity.CloseDate, 'CloseDate is Updated to Current Date successfully');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Closed Won',opportunity.StageName,'Expected value is Closed Won, but actual value is '+opportunity.StageName);
            
            opportunity.CloseDate = System.today().addDays(-10);
            update opportunity;
            System.assertEquals(System.today().addDays(-10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            
            //When moving from Closed Won to Closed, and close date is set as a past date then no updates to Close date
            opportunity.StageName='Closed';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today().addDays(-10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Closed',opportunity.StageName,'Expected value is Closed, but actual value is '+opportunity.StageName);
            
            //If set to Closed Won/Closed. past date updated for Closed date.  Then anything else is modified then no updates to Close date
            opportunity.Status__c= 'Cancelled';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today().addDays(-10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Closed',opportunity.StageName,'Expected value is Closed, but actual value is '+opportunity.StageName);
            
        }
    }
    
    @isTest
    private static void testUpdatedOpportunityOpenStageToClosedAndCloseDatePast(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
        Opportunity opportunity = new Opportunity();
        
        System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213121');
            acctRecord.PersonDoNotCall=true;
            insert acctRecord;
        }
        testAccount = [select id, ClientIdentifier__c, ownerId from Account where CreatedbyId =:agentUser.id Limit 1];
       
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
 
        System.runAs(agentUser) {
            CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            byPass.Override_OpportunityAfterInsert__c = true;
            insert byPass;
            opportunity = buildOpportunityRecord(testAccount.id);
            insert opportunity;

            opportunity.StageName='Closed';
            opportunity.CloseDate = System.today().addDays(-10);
            update opportunity;
            
            //If the stage changes from quoting(open stage) to closed and update the Closed Date to past date (2 fields at the sametime), closed date updates to current date             
            opportunity.StageName='Quoting';
            update opportunity;
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today().addDays(-10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Quoting',opportunity.StageName,'Expected value is Quoting, but actual value is '+opportunity.StageName);
            
            AP_OpportunityTrigger.runOnce=true;
            opportunity.StageName='Closed';
            opportunity.Status__c= 'Cancelled';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertNotEquals(System.today().addDays(-10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Closed',opportunity.StageName,'Expected value is Closed, but actual value is '+opportunity.StageName);
            
            //If the stage changes from quoting(open stage) to closedwon and update the Closed Date to past date (2 fields at the sametime), closed date updates to current date
            opportunity.StageName='Quoting';
            opportunity.CloseDate = System.today().addDays(-10);
            update opportunity;
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(System.today().addDays(-10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertNotEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Quoting',opportunity.StageName,'Expected value is Quoting, but actual value is '+opportunity.StageName);
            
            AP_OpportunityTrigger.runOnce=true;
            opportunity.StageName='Closed Won';

            opportunity.Status__c= 'Cancelled';
            update opportunity;
            
            opportunity = [select Id, CloseDate, OppAssignedDateTime__c,StageName from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertNotEquals(System.today().addDays(-10), opportunity.CloseDate, 'CloseDate updated is validated successfully');
            System.assertEquals(System.today(), opportunity.CloseDate, 'CloseDate is not updated successfully');
            System.assertEquals('Closed Won',opportunity.StageName,'Expected value is Closed Won, but actual value is '+opportunity.StageName);
        }
    }
}