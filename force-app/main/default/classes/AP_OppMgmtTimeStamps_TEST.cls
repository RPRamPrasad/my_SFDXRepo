/* 
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     added @isTest annotations 
*/
@isTest()
public class AP_OppMgmtTimeStamps_TEST {
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
    private static void testAllStages(){
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
            // Validating Opp Contact Established Date time
            opportunity.StageName=AP_OppMgmtTimeStamps.ASSIGNED;
            opportunity.status__c=AP_OppMgmtTimeStamps.CONTACT_ESTBLSHD;
            update opportunity;
            opportunity = [select Id, OppContactEstablishedDateTime__c, OppAssignedDateTime__c from Opportunity where Id=:opportunity.Id Limit 1];
            DateTime contactEstablished = Opportunity.OppContactEstablishedDateTime__c;
            System.assertNotEquals(null, opportunity.OppContactEstablishedDateTime__c, 'Contact Established Date time is not updated successfully');
            //Validating Quote and Quote In Progress Date time.
             AP_OpportunityTrigger.runOnce=true;
            opportunity.StageName=AP_OppMgmtTimeStamps.QUOTING;
            opportunity.status__c=AP_OppMgmtTimeStamps.QUOTE_IN_PROGRESS;
            update opportunity;
            opportunity = [select Id, OppContactEstablishedDateTime__c, OppQuoteInProgressDateTime__c,stagename,status__c from Opportunity where Id=:opportunity.Id Limit 1];
            DateTime quoteInProgress = opportunity.OppQuoteInProgressDateTime__c;
            System.assertEquals(contactEstablished, opportunity.OppContactEstablishedDateTime__c, 'Contact Established Date time is updated when it should not be');
        	System.assertNotEquals(null, opportunity.OppQuoteInProgressDateTime__c, 'Quote In progress Date time is not updated successfully');
            System.assertEquals(AP_OppMgmtTimeStamps.QUOTING, opportunity.stageName, 'Stage is not updated correctly');
            System.assertEquals(AP_OppMgmtTimeStamps.QUOTE_IN_PROGRESS, opportunity.Status__c, 'Status is not updated correctly');
            //Validating Quote and Quote ProvidedDateTime.
            AP_OpportunityTrigger.runOnce=true;
            opportunity.StageName=AP_OppMgmtTimeStamps.QUOTING;
            opportunity.status__c=AP_OppMgmtTimeStamps.QUOTE_PROVIDED;
            update opportunity;
            opportunity = [select Id, OppContactEstablishedDateTime__c, OppQuoteInProgressDateTime__c,stagename,status__c,OppQuoteProvidedDateTime__c,Quote_Received__c,TimeToQuoteprovided__c from Opportunity where Id=:opportunity.Id Limit 1];
            DateTime quoteProvided = opportunity.OppQuoteProvidedDateTime__c;
            Date quoteRecieved = opportunity.Quote_Received__c;
            Decimal timeToQuoteProvided = opportunity.TimeToQuoteprovided__c;
            System.assertEquals(contactEstablished, opportunity.OppContactEstablishedDateTime__c, 'Contact Established Date time is updated when it should not be');
        	System.assertEquals(quoteInProgress, opportunity.OppQuoteInProgressDateTime__c, 'Quote In progress Date time is updated when it should not be');
            System.assertNotEquals(null, opportunity.OppQuoteProvidedDateTime__c, 'QuoteProvided Date time is not updated Successfully');
            System.assertNotEquals(null, opportunity.TimeToQuoteprovided__c, 'TimeToQuoteprovided__c value is not updated Successfully');
            System.assertNotEquals(null, opportunity.Quote_Received__c, 'Quote_Received__c Date is not updated Successfully');
            System.assertEquals(AP_OppMgmtTimeStamps.QUOTING, opportunity.stageName, 'Stage is not updated correctly');
            System.assertEquals(AP_OppMgmtTimeStamps.QUOTE_PROVIDED, opportunity.Status__c, 'Status is not updated correctly');
            //Validating Quote and App Pending.
            AP_OpportunityTrigger.runOnce=true;
            opportunity.StageName=AP_OppMgmtTimeStamps.QUOTING;
            opportunity.status__c=AP_OppMgmtTimeStamps.APPLICATION_PENDING;
            update opportunity;
            opportunity = [select Id, OppContactEstablishedDateTime__c,OppAppPendingDateTime__C, OppQuoteInProgressDateTime__c,stagename,status__c,OppQuoteProvidedDateTime__c,Quote_Received__c,TimeToQuoteprovided__c from Opportunity where Id=:opportunity.Id Limit 1];
           	DateTime appPending = opportunity.OppAppPendingDateTime__c;
            System.assertEquals(contactEstablished, opportunity.OppContactEstablishedDateTime__c, 'Contact Established Date time is updated when it should not be');
        	System.assertEquals(quoteInProgress, opportunity.OppQuoteInProgressDateTime__c, 'Quote In progress Date time is updated when it should not be');
            System.assertEquals(quoteProvided, opportunity.OppQuoteProvidedDateTime__c, 'Quote Provided Date time is updated when it should not be');
            System.assertNotEquals(null, opportunity.OppAppPendingDateTime__C, 'Application Pending Date time is not updated Successfully');
            System.assertEquals(timeToQuoteProvided, opportunity.TimeToQuoteprovided__c, 'TimeToQuoteProvided__c is updated when it should not be');
            System.assertEquals(quoteRecieved, opportunity.Quote_Received__c, 'QuoteProvided Date time is updated when it should not be');
            System.assertEquals(AP_OppMgmtTimeStamps.QUOTING, opportunity.stageName, 'Stage is not updated correctly');
            System.assertEquals(AP_OppMgmtTimeStamps.APPLICATION_PENDING, opportunity.Status__c, 'Status is not updated correctly');
            
            //Validating Stage NNFP.
            AP_OpportunityTrigger.runOnce=true;
            opportunity.StageName=AP_OppMgmtTimeStamps.NNFP;
            update opportunity;
            opportunity = [select Id, OppNotNowFollowUpDateTime__c,stagename from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertNotEquals(null, opportunity.OppNotNowFollowUpDateTime__c, 'NNFP Date time is not updated Successfully');
            System.assertEquals(AP_OppMgmtTimeStamps.NNFP, opportunity.stageName, 'Stage is not updated correctly');
            
            //Validating App Submitted.
            AP_OpportunityTrigger.runOnce=true;
            opportunity.StageName=AP_OppMgmtTimeStamps.APP_SUBMITTED;
            update opportunity;
            opportunity = [select Id, OppContactEstablishedDateTime__c,TimeToAppsubmitted__c,OppAppSubmittedDateTime__c,OppAppPendingDateTime__C, OppQuoteInProgressDateTime__c,stagename,status__c,OppQuoteProvidedDateTime__c,Quote_Received__c,TimeToQuoteprovided__c from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertEquals(contactEstablished, opportunity.OppContactEstablishedDateTime__c, 'Contact Established Date time is updated when it should not be');
        	System.assertEquals(quoteInProgress, opportunity.OppQuoteInProgressDateTime__c, 'Quote In progress Date time is updated when it should not be');
            System.assertEquals(quoteProvided, opportunity.OppQuoteProvidedDateTime__c, 'Quote Provided Date time is updated when it should not be');
            System.assertEquals(appPending, opportunity.OppAppPendingDateTime__C, 'App Pending Date time is updated when it should not be');    
            System.assertNotEquals(null, opportunity.OppAppSubmittedDateTime__c, 'Application Submitted Date time is not updated Successfully');
            System.assertEquals(timeToQuoteProvided, opportunity.TimeToQuoteprovided__c, 'TimeToQuoteProvided__c is updated when it should not be');
            System.assertEquals(quoteRecieved, opportunity.Quote_Received__c, 'QuoteProvided Date time is updated when it should not be');
            System.assertEquals(AP_OppMgmtTimeStamps.APP_SUBMITTED, opportunity.stageName, 'Stage is not updated correctly');
            System.assertEquals(timeToQuoteProvided, opportunity.TimeToQuoteprovided__c, 'TimeToQuoteProvided__c is updated when it should not be');
            System.assertNotEquals(null, opportunity.TimeToAppsubmitted__c, 'TimeToAppsubmitted__c value is not updated Successfully');
        }
    }
    
     @isTest
     private static void testQuotingStageAndQIP(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
	
        Account testAccount;
        Opportunity opportunity = new Opportunity();
         System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213e3121');
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
                        opportunity = [select Id, OppContactEstablishedDateTime__c,OppAppPendingDateTime__C, OppQuoteInProgressDateTime__c,stagename,status__c,OppQuoteProvidedDateTime__c,Quote_Received__c,TimeToQuoteprovided__c from Opportunity where Id=:opportunity.Id Limit 1];
            AP_OpportunityTrigger.runOnce=true;
            AP_OpportunityTrigger.isButtonExecuted=true;
            opportunity.StageName=AP_OppMgmtTimeStamps.QUOTING;
            opportunity.status__c=AP_OppMgmtTimeStamps.QUOTE_PROVIDED;
            update opportunity;
            opportunity = [select Id, OppContactEstablishedDateTime__c,OppAppPendingDateTime__C, OppQuoteInProgressDateTime__c,stagename,status__c,OppQuoteProvidedDateTime__c,Quote_Received__c,TimeToQuoteprovided__c from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertNotEquals(null, opportunity.OppContactEstablishedDateTime__c, 'Contact Established Date time is updated when it should not be');
        	System.assertNotEquals(null, opportunity.OppQuoteInProgressDateTime__c, 'Quote In progress Date time is updated when it should not be');
            System.assertNotEquals(null, opportunity.OppQuoteProvidedDateTime__c, 'Quote Provided Date time is updated when it should not be');
            System.assertNotEquals(null, opportunity.TimeToQuoteprovided__c, 'TimeToQuoteProvided__c is updated when it should not be');
            System.assertNotEquals(null, opportunity.Quote_Received__c, 'QuoteProvided Date time is updated when it should not be');
            System.assertEquals(AP_OppMgmtTimeStamps.QUOTING, opportunity.stageName, 'Stage is not updated correctly');
            System.assertEquals(AP_OppMgmtTimeStamps.QUOTE_PROVIDED, opportunity.Status__c, 'Status is not updated correctly');
        }
     }

    @isTest
    private static void testQuotingStageAndQIPRGRESS(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
	
        Account testAccount;
        Opportunity opportunity = new Opportunity();
            System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213e3121');
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
                        opportunity = [select Id, OppContactEstablishedDateTime__c,OppAppPendingDateTime__C, OppQuoteInProgressDateTime__c,stagename,status__c,OppQuoteProvidedDateTime__c,Quote_Received__c,TimeToQuoteprovided__c from Opportunity where Id=:opportunity.Id Limit 1];
            AP_OpportunityTrigger.runOnce=true;
            
            opportunity.StageName=AP_OppMgmtTimeStamps.QUOTING;
            opportunity.status__c=AP_OppMgmtTimeStamps.QUOTE_IN_PROGRESS;
            update opportunity;
            opportunity = [select Id, OppContactEstablishedDateTime__c,OppAppPendingDateTime__C, OppQuoteInProgressDateTime__c,stagename,status__c,OppQuoteProvidedDateTime__c,Quote_Received__c,TimeToQuoteprovided__c from Opportunity where Id=:opportunity.Id Limit 1];
            System.assertNotEquals(null, opportunity.OppContactEstablishedDateTime__c, 'Contact Established Date time is updated when it should not be');
        	System.assertNotEquals(null, opportunity.OppQuoteInProgressDateTime__c, 'Quote In progress Date time is updated when it should not be');
            System.assertEquals(AP_OppMgmtTimeStamps.QUOTING, opportunity.stageName, 'Stage is not updated correctly');
            System.assertEquals(AP_OppMgmtTimeStamps.QUOTE_IN_PROGRESS, opportunity.Status__c, 'Status is not updated correctly');
        }
     }

    @isTest
    private static void testQuotingAppPending(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
	
        Account testAccount;
        Opportunity opportunity = new Opportunity();
        System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213e3121');
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
             
            
            opportunity.StageName=AP_OppMgmtTimeStamps.QUOTING;
            opportunity.status__c=AP_OppMgmtTimeStamps.APPLICATION_PENDING;
            update opportunity;
            opportunity = [select Id, OppContactEstablishedDateTime__c,OppAppPendingDateTime__C, OppQuoteInProgressDateTime__c,stagename,status__c,OppQuoteProvidedDateTime__c,Quote_Received__c,TimeToQuoteprovided__c from Opportunity where Id=:opportunity.Id Limit 1];
           	
            System.assertNotEquals(null, opportunity.OppContactEstablishedDateTime__c, 'Contact Established Date time is updated when it should not be');
        	System.assertNotEquals(null, opportunity.OppQuoteInProgressDateTime__c, 'Quote In progress Date time is updated when it should not be');
            System.assertNotEquals(null, opportunity.OppQuoteProvidedDateTime__c, 'Quote Provided Date time is updated when it should not be');
            System.assertNotEquals(null, opportunity.OppAppPendingDateTime__C, 'Application Pending Date time is not updated Successfully');
            System.assertNotEquals(null, opportunity.TimeToQuoteprovided__c, 'TimeToQuoteProvided__c is updated when it should not be');
            System.assertNotEquals(null, opportunity.Quote_Received__c, 'QuoteProvided Date time is updated when it should not be');
            System.assertEquals(AP_OppMgmtTimeStamps.QUOTING, opportunity.stageName, 'Stage is not updated correctly');
            System.assertEquals(AP_OppMgmtTimeStamps.APPLICATION_PENDING, opportunity.Status__c, 'Status is not updated correctly');
        }
     }

     @isTest
     private static void testNNFP(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
	
        Account testAccount;
        Opportunity opportunity = new Opportunity();
            System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213e3121');
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
             
            
            opportunity.StageName=AP_OppMgmtTimeStamps.NNFP;

            update opportunity;
            opportunity = [select Id, OppNotNowFollowUpDateTime__c,OppAppPendingDateTime__C, OppQuoteInProgressDateTime__c,stagename,status__c,OppQuoteProvidedDateTime__c,Quote_Received__c,TimeToQuoteprovided__c from Opportunity where Id=:opportunity.Id Limit 1];
           	
            System.assertNotEquals(null, opportunity.OppNotNowFollowUpDateTime__c, 'NNFP is not updated which should be updated');
            System.assertEquals(AP_OppMgmtTimeStamps.NNFP, opportunity.stageName, 'Stage is not updated correctly');

        }
     }

    @isTest
    private static void testAppSubmitted(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
	
        Account testAccount;
        Opportunity opportunity = new Opportunity();
        System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213e3121');
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
             
            
            opportunity.StageName=AP_OppMgmtTimeStamps.APP_SUBMITTED;

            update opportunity;
            opportunity = [select Id, OppContactEstablishedDateTime__c,TimeToAppsubmitted__c,OppAppPendingDateTime__C, OppQuoteInProgressDateTime__c,stagename,status__c,OppQuoteProvidedDateTime__c,Quote_Received__c,TimeToQuoteprovided__c from Opportunity where Id=:opportunity.Id Limit 1];
           	
            System.assertNotEquals(null, opportunity.OppContactEstablishedDateTime__c, 'Contact Established Date time is not updated');
        	System.assertNotEquals(null, opportunity.OppQuoteInProgressDateTime__c, 'Quote In progress Date time is not updated');
            System.assertNotEquals(null, opportunity.OppQuoteProvidedDateTime__c, 'Quote Provided Date time is not updated');
            System.assertNotEquals(null, opportunity.OppAppPendingDateTime__C, 'Application Pending Date time is not updated Successfully');
            System.assertNotEquals(null, opportunity.TimeToQuoteprovided__c, 'TimeToQuoteProvided__c is not updated');
            System.assertNotEquals(null, opportunity.Quote_Received__c, 'QuoteProvided Date time is not updated ');
             System.assertNotEquals(null, opportunity.TimeToAppsubmitted__c, 'App Submitted Date time is not updated');
            System.assertEquals(AP_OppMgmtTimeStamps.APP_SUBMITTED, opportunity.stageName, 'Stage is not updated correctly');

        }
     }
    
    @isTest
    private static void testClosedWon(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
	
        Account testAccount;
        Opportunity opportunity = new Opportunity();
            System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213e3121');
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
             
            
            opportunity.StageName=AP_OppMgmtTimeStamps.CLOSED_WON;

            update opportunity;
            opportunity = [select Id, OppContactEstablishedDateTime__c,TimetoCloseDays__c,OppClosedWonDateTime__c,TimeToAppsubmitted__c,OppAppPendingDateTime__C, OppQuoteInProgressDateTime__c,stagename,status__c,OppQuoteProvidedDateTime__c,Quote_Received__c,TimeToQuoteprovided__c from Opportunity where Id=:opportunity.Id Limit 1];
           	
            System.assertNotEquals(null, opportunity.OppContactEstablishedDateTime__c, 'Contact Established Date time is not updated');
        	System.assertNotEquals(null, opportunity.OppQuoteInProgressDateTime__c, 'Quote In progress Date time is not updated');
            System.assertNotEquals(null, opportunity.OppQuoteProvidedDateTime__c, 'Quote Provided Date time is not updated');
            System.assertNotEquals(null, opportunity.OppAppPendingDateTime__C, 'Application Pending Date time is not updated Successfully');
            System.assertNotEquals(null, opportunity.TimeToQuoteprovided__c, 'TimeToQuoteProvided__c is not updated');
            System.assertNotEquals(null, opportunity.Quote_Received__c, 'QuoteProvided Date time is not updated ');
             System.assertNotEquals(null, opportunity.TimeToAppsubmitted__c, 'App Submitted Date time is not updated');
              System.assertNotEquals(null, opportunity.OppClosedWonDateTime__c, 'Closed Won Date time is not updated Successfully');
             System.assertNotEquals(null, opportunity.TimetoCloseDays__c, 'Time To Close Days is not updated Successfully');
            
            System.assertEquals(AP_OppMgmtTimeStamps.CLOSED_WON, opportunity.stageName, 'Stage is not updated correctly');

        }
     }
    
    @isTest
    private static void testClosed(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
	
        Account testAccount;
        Opportunity opportunity = new Opportunity();
            System.runAs(agentUser) {
            Account acctRecord = buildAccountRecord('1213e3121');
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
             
            
            opportunity.StageName=AP_OppMgmtTimeStamps.CLOSED;

            update opportunity;
            opportunity = [select Id, OppClosedDateTime__c,TimetoCloseDays__c, OppQuoteInProgressDateTime__c,stagename,status__c,OppQuoteProvidedDateTime__c,Quote_Received__c,TimeToQuoteprovided__c from Opportunity where Id=:opportunity.Id Limit 1];
           	
            System.assertNotEquals(null, opportunity.TimetoCloseDays__c, 'Time To Close is not updated Successfully');
            System.assertNotEquals(null, opportunity.OppClosedDateTime__c, 'Closed Date is not updated Successfully');
            System.assertEquals(AP_OppMgmtTimeStamps.CLOSED, opportunity.stageName, 'Stage is not updated correctly');

        }
     }
}