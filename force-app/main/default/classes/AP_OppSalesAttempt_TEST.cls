/**
Author Team Quadcore
Name - AP_OppSalesAttempt_TEST
@description Test class written for AP_OppSalesAttempt_TEST 
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     added @isTest annotations
**/
@isTest()
public class AP_OppSalesAttempt_TEST {
	private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static User systemUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static UserRole agentTeamMemberUserRole;
    
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
	public static Map<String,List<SalesAttempt__c>> salesAttemptMap = new Map<String,List<SalesAttempt__c>>();

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
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
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
       private static void insertSalesAttempt(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
           List<SalesAttempt__c> salesAttemptList = new List<SalesAttempt__c>();
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
            Opportunity opportunity = buildOpportunityRecord(testAccount.id);
                insert opportunity;
           SalesAttempt__c sc = [select id, name,isShellRecord__c,owner.name, SA_TCM__c,Total_Email__c,Total_Text__c,Total_calls__c from salesattempt__c where opportunity__c=:opportunity.id];
            
            salesAttemptList.add(sc);
            salesAttemptMap.put(opportunity.id, salesAttemptList);
            AP_OppSalesAttempt.salesAttemptMap = salesAttemptMap;

            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity newStage = new Opportunity();
            newStage.id = opportunity.id;
            newStage.Total_Calls_Made__c = 5;
            newStage.Total_Email__c = 2;
            newStage.Total_Calls__c = 2;
            newStage.Total_Text__c = 1;
            update newStage;
            
            SalesAttempt__c scs = [select id, name,isShellRecord__c,owner.name, SA_TCM__c,Total_Email__c,Total_Text__c,Total_calls__c from salesattempt__c where opportunity__c=:opportunity.id];
            System.assertEquals(0, scs.SA_TCM__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, scs.Total_Email__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, scs.Total_Text__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, scs.Total_calls__c,'Sales attempt was not updated successfully!');
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            
            Opportunity assignedStageOpp = new Opportunity();
            assignedStageOpp.id=opportunity.id;
            assignedStageOpp.StageName = 'Not Now -  Follow Up';
            assignedStageOpp.OppNotNowFollowUpDateTime__c=System.Today()-2;
            update assignedStageOpp;
            
            System.assertNotEquals(newStage.StageName, assignedStageOpp.StageName,'Opportunity Update doesnot happend successfully');    
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity nnfpStage = new Opportunity();
            nnfpStage.id = opportunity.id;
            nnfpStage.Total_Calls_Made__c = 7;
            nnfpStage.Total_Email__c = 3;
            nnfpStage.Total_Calls__c = 3;
            nnfpStage.Total_Text__c = 1;
            nnfpStage.Total_New_Calls__c=1;
            nnfpStage.Total_New_Text__c=0;
            nnfpStage.Total_New_Email__c=1;
            update nnfpStage;
            
            //Test.startTest();
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity nnfpStageTCMNew = new Opportunity();
            nnfpStageTCMNew.id = opportunity.id;
            nnfpStageTCMNew.StageName='New';
            nnfpStageTCMNew.id = opportunity.id;
            nnfpStageTCMNew.OppNotNowFollowUpDateTime__c=System.Today()-2;
            update nnfpStageTCMNew;
            
            
            //Test.stopTest();
            List<SalesAttempt__c> salesAttempts = [select id, name,SA_TCM__c,Total_Email__c,Total_Text__c,Total_calls__c from SalesAttempt__c where opportunity__c=:opportunity.id order by name desc];
            System.assertEquals(1, salesAttempts.size(),'Sales attempt was not updated successfully!');
            System.assertEquals(5, salesAttempts[0].SA_TCM__c,'Sales attempt was not updated successfully!');
            System.assertEquals(2, salesAttempts[0].Total_Email__c,'Sales attempt was not updated successfully!');
            System.assertEquals(1, salesAttempts[0].Total_Text__c,'Sales attempt was not updated successfully!');
            System.assertEquals(2, salesAttempts[0].Total_calls__c,'Sales attempt was not updated successfully!');
                System.assertEquals('1', salesAttempts[0].name,'Name is not updated correctly');
               
            }
           
    }

    @isTest
    private static void insertSalesAttemptWithWrongClientId(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
           List<SalesAttempt__c> salesAttemptList = new List<SalesAttempt__c>();
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
            Opportunity opportunity = buildOpportunityRecord(testAccount.id);
                insert opportunity;
            SalesAttempt__c sc = [select id, name,isShellRecord__c,owner.name, SA_TCM__c,Total_Email__c,Total_Text__c,Total_calls__c from salesattempt__c where opportunity__c=:opportunity.id];
            
            salesAttemptList.add(sc);
            salesAttemptMap.put(opportunity.id, salesAttemptList);
            AP_OppSalesAttempt.salesAttemptMap = salesAttemptMap;

            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity newStage = new Opportunity();
            newStage.id = opportunity.id;
            newStage.Total_Calls_Made__c = 5;
            newStage.Total_Email__c = 2;
            newStage.Total_Calls__c = 2;
            newStage.Total_Text__c = 1;
            update newStage;
            
            SalesAttempt__c scs = [select id, name,isShellRecord__c,owner.name, SA_TCM__c,Total_Email__c,Total_Text__c,Total_calls__c from salesattempt__c where opportunity__c=:opportunity.id];
            System.assertEquals(0, scs.SA_TCM__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, scs.Total_Email__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, scs.Total_Text__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, scs.Total_calls__c,'Sales attempt was not updated successfully!');
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            
            Opportunity assignedStageOpp = new Opportunity();
            assignedStageOpp.id=opportunity.id;
            assignedStageOpp.StageName = 'Not Now -  Follow Up';
            assignedStageOpp.OppNotNowFollowUpDateTime__c=System.Today()-2;
             update assignedStageOpp;
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity nnfpStage = new Opportunity();
            nnfpStage.id = opportunity.id;
            nnfpStage.Total_Calls_Made__c = 7;
            nnfpStage.Total_Email__c = 3;
            nnfpStage.Total_Calls__c = 3;
            nnfpStage.Total_Text__c = 1;
            nnfpStage.Total_New_Calls__c=1;
            nnfpStage.Total_New_Text__c=0;
            nnfpStage.Total_New_Email__c=1;
            update nnfpStage;
            
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity nnfpStageTCMNew = new Opportunity();
            nnfpStageTCMNew.id = opportunity.id;
            nnfpStageTCMNew.StageName='New';
            nnfpStageTCMNew.id = opportunity.id;
            nnfpStageTCMNew.OppNotNowFollowUpDateTime__c=System.Today()-2;
            update nnfpStageTCMNew;
            
            
            List<SalesAttempt__c> salesAttempts = [select id, name,SA_TCM__c,Total_Email__c,Total_Text__c,Total_calls__c from SalesAttempt__c where opportunity__c=:opportunity.id order by name desc];
            System.assertEquals(1, salesAttempts.size(),'Sales attempt was not updated successfully!');
            System.assertEquals(5, salesAttempts[0].SA_TCM__c,'Sales attempt was not updated successfully!');
            System.assertEquals(2, salesAttempts[0].Total_Email__c,'Sales attempt was not updated successfully!');
            System.assertEquals(1, salesAttempts[0].Total_Text__c,'Sales attempt was not updated successfully!');
            System.assertEquals(2, salesAttempts[0].Total_calls__c,'Sales attempt was not updated successfully!');
                System.assertEquals('1', salesAttempts[0].name,'Name is not updated correctly');
            }
           
    }
    
    @isTest
    private static void testSalesAttempt(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
           List<SalesAttempt__c> salesAttemptList = new List<SalesAttempt__c>();
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
            Opportunity opportunity = buildOpportunityRecord(testAccount.id);
                insert opportunity;
            SalesAttempt__c sc = buildSalesAttemptRecord(opportunity);
                insert sc;
            
            
                        salesAttemptList.add(sc);
           salesAttemptMap.put(opportunity.id, salesAttemptList);
                   AP_OppSalesAttempt.salesAttemptMap = salesAttemptMap;
           
            
             Opportunity updateOpp = new Opportunity();
                    updateOpp.id = opportunity.id;
                    updateOpp.StageName = 'Not Now -  Follow Up';
                    update updateOpp;
                AP_OppSalesAttempt ab = new AP_OppSalesAttempt();
                    Opportunity salesAttemptOpportunity = ab.getSalesAttempts(opportunity,salesAttemptList,updateOpp);
                    System.assertEquals(1,salesAttemptOpportunity.Sales_Attempts__c,'Sales Attempts value under opportunity is wrong');
            }
        
           
    }

    @isTest
    private static void testUpdatedOpportunity(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
           List<SalesAttempt__c> salesAttemptList = new List<SalesAttempt__c>();
           salesAttemptMap.put('1213121', salesAttemptList);
            System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213121');
            acctRecord.PersonDoNotCall=true;
            insert acctRecord;  
            }
            testAccount = [select id, ClientIdentifier__c, ownerId from Account where CreatedbyId =:agentUser.id Limit 1];
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
            insert newAgentRole;
            System.runAs(agentUser) {
            Opportunity opportunity = buildOpportunityRecord(testAccount.id);
                insert opportunity;
            SalesAttempt__c sc = buildSalesAttemptRecord(opportunity);
            AP_OppSalesAttempt ab = new AP_OppSalesAttempt();
            Opportunity updatedOpportunity = ab.getUpdatedOpportunity(opportunity,sc);
            System.assertEquals(null,updatedOpportunity.OppContactEstablishedDateTime__c,'Re open of salesattemtp is not done accurately');
            System.assertEquals(null,updatedOpportunity.OppQuoteInProgressDateTime__c,'Re open of salesattemtp is not done accurately');
            System.assertEquals(null,updatedOpportunity.OppQuoteProvidedDateTime__C,'Re open of salesattemtp is not done accurately');
            System.assertEquals(null,updatedOpportunity.OppAppPendingDateTime__C,'Re open of salesattemtp is not done accurately');
            }
    }
    
    @isTest
    private static void testUpdatedOpportunityClosed(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
           List<SalesAttempt__c> salesAttemptList = new List<SalesAttempt__c>();
           salesAttemptMap.put('1213121', salesAttemptList);
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
            Opportunity updatedOpportunityclosed = new Opportunity();
          System.runAs(agentUser) {
              	CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            	byPass.Override_OppBeforeUpdate__c = true;
            	update byPass;
                
                updatedOpportunityclosed.StageName='Closed';
                updatedOpportunityclosed.OppClosedDateTime__c = System.today().addDays(-5);
                updatedOpportunityclosed.id = opportunity.id;    
                update updatedOpportunityclosed;
            }
        	System.runAs(agentUser) {
                CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            	byPass.Override_OppBeforeUpdate__c = false;
            	update byPass;
               
                Opportunity updatedOpportunity = new Opportunity();
                updatedOpportunity.StageName='New';
                updatedOpportunity.id = opportunity.id;    
                update updatedOpportunity;
                System.assertNotEquals(updatedOpportunityclosed.StageName, updatedOpportunity.StageName, 'Stage is updated successfully');
            }
    }

    @isTest
    private static void testILPRFCClosed(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
           List<SalesAttempt__c> salesAttemptList = new List<SalesAttempt__c>();
           salesAttemptMap.put('1213121', salesAttemptList);
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
                opportunity.Opportunity_Originator__c='Internt Lead Provider';
                insert opportunity;
            }
            Opportunity updatedOpportunityclosed = new Opportunity();
          System.runAs(agentUser) {
              	CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            	byPass.Override_OppBeforeUpdate__c = true;
            	update byPass;
           		SalesAttempt__c sc = buildSalesAttemptRecord(opportunity);
              	sc.name= null;
              	insert sc;
                
                
                updatedOpportunityclosed.StageName='Closed';
                updatedOpportunityclosed.OppClosedDateTime__c = System.today().addDays(-5);
                updatedOpportunityclosed.id = opportunity.id;    
                update updatedOpportunityclosed;
            }
        	System.runAs(agentUser) {
                CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            	byPass.Override_OppBeforeUpdate__c = false;
            	update byPass;
                
                Opportunity updatedOpportunity = new Opportunity();
                updatedOpportunity.StageName='New';
                updatedOpportunity.id = opportunity.id;    
                update updatedOpportunity;
                System.assertNotEquals(updatedOpportunityclosed.stageName, updatedOpportunity.StageName, 'Stage is updated successfully');
            }
    }

    @isTest
    private static void testUpdatedOpportunityNNFP(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
           List<SalesAttempt__c> salesAttemptList = new List<SalesAttempt__c>();
           salesAttemptMap.put('1213121', salesAttemptList);
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
            Opportunity updatedOpportunityclosed = new Opportunity();
          System.runAs(agentUser) {
              	CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            	byPass.Override_OppBeforeUpdate__c = true;
            	update byPass;
           		
                
                updatedOpportunityclosed.StageName='Not Now -  Follow Up';
                updatedOpportunityclosed.OppNotNowFollowUpDateTime__c = System.today().addDays(-5);
                updatedOpportunityclosed.id = opportunity.id;    
                update updatedOpportunityclosed;
            }
        	System.runAs(agentUser) {
                CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            	byPass.Override_OppBeforeUpdate__c = false;
            	update byPass;
                
                Opportunity updatedOpportunity = new Opportunity();
                updatedOpportunity.StageName='New';
                updatedOpportunity.id = opportunity.id;    
                update updatedOpportunity;
                System.assertNotEquals(updatedOpportunityclosed.stageName, updatedOpportunity.StageName, 'Stage is updated successfully');
            }
    }
    
    @isTest
    private static void testNotNNFPClosed(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
           List<SalesAttempt__c> salesAttemptList = new List<SalesAttempt__c>();
           salesAttemptMap.put('1213121', salesAttemptList);
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
            Opportunity updatedOpportunityclosed = new Opportunity();
          System.runAs(agentUser) {
              	CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            	byPass.Override_OppBeforeUpdate__c = true;
            	update byPass;
           		
                
                updatedOpportunityclosed.StageName='Not Now -  Follow Up';
                  updatedOpportunityclosed.id = opportunity.id;    
                update updatedOpportunityclosed;
            }
        	System.runAs(agentUser) {
                CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            	byPass.Override_OppBeforeUpdate__c = false;
            	update byPass;
               
                Opportunity updatedOpportunity = new Opportunity();
                updatedOpportunity.StageName='New';
                updatedOpportunity.id = opportunity.id;    
                update updatedOpportunity;
                System.assertNotEquals(updatedOpportunityclosed.stageName, updatedOpportunity.StageName, 'Stage is updated successfully');
            }
    }
    
    @isTest
    private static void testUpdatedOpportunityNotClosed(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Account testAccount;
           List<SalesAttempt__c> salesAttemptList = new List<SalesAttempt__c>();
           salesAttemptMap.put('1213121', salesAttemptList);
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
            Opportunity updatedOpportunityclosed = new Opportunity();
          System.runAs(agentUser) {
              	CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            	byPass.Override_OppBeforeUpdate__c = true;
            	update byPass;
           		
                
                updatedOpportunityclosed.StageName='Closed';
                  updatedOpportunityclosed.id = opportunity.id;    
                update updatedOpportunityclosed;
            }
        	System.runAs(agentUser) {
                CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            	byPass.Override_OppBeforeUpdate__c = false;
            	update byPass;
               
                Opportunity updatedOpportunity = new Opportunity();
                updatedOpportunity.StageName='New';
                updatedOpportunity.id = opportunity.id;    
                update updatedOpportunity;
                System.assertNotEquals(updatedOpportunityclosed.stageName, updatedOpportunity.StageName, 'Stage is updated successfully');
            }
    }
    
     private static SalesAttempt__c buildSalesAttemptRecord(Opportunity oldOpportunity) {
        SalesAttempt__c sc = new SalesAttempt__c();
         	sc.Assigned_To__c = oldOpportunity.Assigned_To__c;
         	sc.CurrentInsurerName__c = oldOpportunity.CurrentInsurerName__c;
         	sc.CurrentPremium__c = oldOpportunity.CurrentPremium__c;
		 	sc.Finance_Charge__c = oldOpportunity.Finance_Charge__c;
         	sc.Investment_Amount__c = oldOpportunity.Investment_Amount__c;
        	sc.LOB__c = oldOpportunity.LOB__c;
         	sc.Product__c=oldOpportunity.Product__c;
         	sc.Marketing_Source__c =oldOpportunity.Marketing_Source__c; 
         	sc.Marketing_Sub_Source__c = oldOpportunity.Marketing_Sub_Source__c;
			sc.Number_of_Units__c= oldOpportunity.Number_of_Units__c ;
        	sc.Number_of_Vehicles__c = oldOpportunity.Number_of_Vehicles__c;
          	sc.OfficeAssigned__c = oldOpportunity.OfficeAssigned__c;
        	sc.Opportunity_Originator__c=oldOpportunity.Opportunity_Originator__c;
         	sc.Relationship_to_State_Farm__c = oldOpportunity.Relationship_to_State_Farm__c;
         	sc.Source_Comments__c=oldOpportunity.Source_Comments__c;
         	sc.Status__c =oldOpportunity.Status__c;
         	sc.Sub_Status__c= oldOpportunity.Sub_Status__c;
         	sc.Temperature__c=oldOpportunity.Temperature__c;
			sc.Total_Calls_Made__c = oldOpportunity.Total_Calls__c;
        	sc.total_Quote_attached__c = oldOpportunity.Total_Quote_Attached__c;
        	sc.Quote_Received__c = oldOpportunity.Quote_Received__c;
        	sc.X_Date__c = oldOpportunity.X_Date__c;

        	sc.OppNewDateTime__c = oldOpportunity.OppNewDateTime__c;
        	sc.OppAssignedDateTime__c = oldOpportunity.OppAssignedDateTime__c;
			sc.OppContactEstablishedDateTime__c=oldOpportunity.OppContactEstablishedDateTime__c;
			sc.OppQuoteInProgressDateTime__c=oldOpportunity.OppQuoteInProgressDateTime__c; 
         	sc.OppQuoteProvidedDateTime__c =oldOpportunity.OppQuoteProvidedDateTime__c;
			sc.OppAppPendingDateTime__c = oldOpportunity.OppAppPendingDateTime__c;	
       	 	sc.OppAppSubmittedDateTime__c= oldOpportunity.OppAppSubmittedDateTime__c;
            sc.OppClosedDateTime__c= oldOpportunity.OppClosedDateTime__c;
         	sc.OppRFCGrantedDateTime__c=oldOpportunity.OppRFCGrantedDateTime__c;
         	sc.OppRFCNotGrantedDateTime__c =oldOpportunity.OppRFCNotGrantedDateTime__c;
         	sc.OppRFCRequestedDateTime__c = oldOpportunity.OppRFCNotGrantedDateTime__c;
			sc.OppAutoCloseWonDatetime__c = oldOpportunity.OppClosedWonDateTime__c; 
         	sc.OppNotNowFollowUpDateTime__c=oldOpportunity.OppNotNowFollowUpDateTime__c;
          	sc.OppReOpenDateTime__c = System.now();
         	sc.OppAutoCloseWonDatetime__c = oldOpportunity.OppAutoCloseWonDateTime__c;
      	 	sc.Opportunity_Name__c = oldOpportunity.Name;
         	sc.Opportunity__c = oldOpportunity.Id;
         return sc; 
    }
}