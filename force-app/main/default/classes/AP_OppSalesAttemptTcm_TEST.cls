/*
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     added @isTest annotations
*/

@IsTest
public class AP_OppSalesAttemptTcm_TEST {
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
        return new Account(FirstName = 'rrrrr', LastName = 'tttttttt',billingstate='IL', ClientIdentifier__c = paramClientIdentifier,RecordTypeId = acctRecordTypeId,Edit_In_VFP__c = true
                                         );
    
    }
    
    
    private static Opportunity buildOpportunityRecord(Account testAccount) {
        Opportunity opptyRecord = new Opportunity ();
        opptyRecord.Name = 'Tst Opportunity';
        opptyRecord.AccountId = testAccount.id;
        opptyRecord.CloseDate = System.today().addDays(10);
        opptyRecord.LOB__c = 'Fire';
        opptyRecord.StageName = 'New';
       
        return opptyRecord; 
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
   
    @isTest
    private static void insertSalesAttempt(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        
        User proxyAs = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];      
        proxyUser = proxyAs;
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
            Opportunity opportunity = buildOpportunityRecord(testAccount);
            insert opportunity;   
            
            SalesAttempt__c sc = [select id, name,isShellRecord__c,owner.name, SA_TCM__c,Total_Email__c,Total_Text__c,Total_calls__c from salesattempt__c where opportunity__c=:opportunity.id];
            
            salesAttemptList.add(sc);
            salesAttemptMap.put(opportunity.id, salesAttemptList);
            AP_OppSalesAttempt.salesAttemptMap = salesAttemptMap;

            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity newStage = new Opportunity();
            newStage.id = opportunity.id;
            newStage.Total_Calls_Made__c = 2;
            newStage.Total_Email__c = 1;
            newStage.Total_Calls__c = 1;
            newStage.Total_Text__c = 0;
            newStage.Total_New_Calls__c=0;
            newStage.Total_New_Email__c=0;
            update newStage;
            
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
            nnfpStage.Total_Calls_Made__c = 4;
            nnfpStage.Total_Email__c = 2;
            nnfpStage.Total_Calls__c = 2;
            nnfpStage.Total_Text__c = 0;
            nnfpStage.Total_New_Calls__c=1;
            nnfpStage.Total_New_Email__c=1;
            update nnfpStage;
            
            Test.startTest();
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity nnfpStageTCMNew = new Opportunity();
            nnfpStageTCMNew.id = opportunity.id;
            nnfpStageTCMNew.StageName='New';
            nnfpStageTCMNew.OppNotNowFollowUpDateTime__c=System.Today()-2;
            update nnfpStageTCMNew;
          
            
            Test.stopTest();
            SalesAttempt__c sc1 = [select id, name,SA_TCM__c,Total_Email__c,Total_Text__c,Total_calls__c from SalesAttempt__c where opportunity__c=:opportunity.id order by name desc limit 1];
            Opportunity opp = [SELECT Id, TCM_New__c, Total_New_Calls__c, Total_New_Email__c, Total_New_Text__c FrOm Opportunity WHERE Id = :opportunity.Id];
            System.assertEquals(2, sc1.SA_TCM__c,'Sales attempt was not updated successfully!');
            System.assertEquals(1, sc1.Total_Email__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, sc1.Total_Text__c,'Sales attempt was not updated successfully!');
            System.assertEquals(1, sc1.Total_calls__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, opp.TCM_New__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, opp.Total_New_Calls__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, opp.Total_New_Email__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, opp.Total_New_Text__c,'Sales attempt was not updated successfully!');
            
        }
                    
    }
    
    @isTest
     private static void testsalessattemptsinsert(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        
        User proxyAs = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];      
        proxyUser = proxyAs;
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
            Opportunity opportunity = buildOpportunityRecord(testAccount);
            insert opportunity;            
            SalesAttempt__c sc = [select id, name,isShellRecord__c,owner.name, SA_TCM__c,Total_Email__c,Total_Text__c,Total_calls__c from salesattempt__c where opportunity__c=:opportunity.id];
            
            salesAttemptList.add(sc);
            salesAttemptMap.put(opportunity.id, salesAttemptList);
            AP_OppSalesAttempt.salesAttemptMap = salesAttemptMap;

            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity newStage = new Opportunity();
            newStage.id = opportunity.id;
            newStage.Total_Calls_Made__c = 2;
            newStage.Total_Email__c = 1;
            newStage.Total_Calls__c = 1;
            newStage.Total_Text__c = 0;
            newStage.Total_New_Calls__c=0;
            newStage.Total_New_Email__c=0;
            update newStage;
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            
            Opportunity assignedStageOpp = new Opportunity();
            assignedStageOpp.id=opportunity.id;
            assignedStageOpp.StageName = 'Not Now -  Follow Up';
            update assignedStageOpp;
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity nnfpStage = new Opportunity();
            nnfpStage.id = opportunity.id;
            nnfpStage.Total_Calls_Made__c = 4;
            nnfpStage.Total_Email__c = 2;
            nnfpStage.Total_Calls__c = 2;
            nnfpStage.Total_Text__c = 0;
            nnfpStage.Total_New_Calls__c=1;
            nnfpStage.Total_New_Email__c=1;
            update nnfpStage;
            
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity nnfpStageTCMNew = new Opportunity();
            nnfpStageTCMNew.id = opportunity.id;
            nnfpStageTCMNew.StageName='New';
            update nnfpStageTCMNew;
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity reopennew = new Opportunity();
            reopennew.id = opportunity.id;
            reopennew.Total_Calls_Made__c = 4;
            reopennew.Total_Email__c = 2;
            reopennew.Total_Calls__c = 2;
            reopennew.Total_Text__c = 0;
            reopennew.Total_New_Calls__c=0;
            reopennew.Total_New_Email__c=0;
            update reopennew;
            
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            
            Opportunity nnfustageopp = new Opportunity();
            nnfustageopp.id=opportunity.id;
            nnfustageopp.StageName = 'Not Now -  Follow Up';
            nnfustageopp.OppNotNowFollowUpDateTime__c=System.Today()-2;
            update nnfustageopp;
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity nnfpStageinc = new Opportunity();
            nnfpStageinc.id = opportunity.id;
            nnfpStageinc.Total_Calls_Made__c = 6;
            nnfpStageinc.Total_Email__c = 3;
            nnfpStageinc.Total_Calls__c = 3;
            nnfpStageinc.Total_Text__c = 0;
            nnfpStageinc.Total_New_Calls__c=1;
            nnfpStageinc.Total_New_Email__c=1;
            update nnfpStageinc;
            
            Test.startTest();
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity assignedreopenopp = new Opportunity();
            assignedreopenopp.id = opportunity.id;
            assignedreopenopp.StageName='New';
            assignedreopenopp.OppNotNowFollowUpDateTime__c=System.Today()-2;
            update assignedreopenopp;
            Test.stopTest();
            
            SalesAttempt__c sc1 = [select id, name,SA_TCM__c,Total_Email__c,Total_Text__c,Total_calls__c from SalesAttempt__c where opportunity__c=:opportunity.id order by name desc limit 1];
            Opportunity opp = [SELECT Id, TCM_New__c, Total_New_Calls__c, Total_New_Email__c, Total_New_Text__c FrOm Opportunity WHERE Id = :opportunity.Id];
            System.assertEquals(4, sc1.SA_TCM__c,'Sales attempt was not updated successfully!');
            System.assertEquals(2, sc1.Total_Email__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, sc1.Total_Text__c,'Sales attempt was not updated successfully!');
            System.assertEquals(2, sc1.Total_calls__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, opp.TCM_New__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, opp.Total_New_Calls__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, opp.Total_New_Email__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, opp.Total_New_Text__c,'Sales attempt was not updated successfully!');
            
        }
                    
    }
     
    @isTest
    private static void testsalesattemptaccumulatemethod(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        
        User proxyAs = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];      
        proxyUser = proxyAs;
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
            Opportunity opportunity = buildOpportunityRecord(testAccount);
            insert opportunity;            
            SalesAttempt__c sc = [select id, name,isShellRecord__c,owner.name, SA_TCM__c,Total_Email__c,Total_Text__c,Total_calls__c from salesattempt__c where opportunity__c=:opportunity.id];
            
            salesAttemptList.add(sc);
            salesAttemptMap.put(opportunity.id, salesAttemptList);
            AP_OppSalesAttempt.salesAttemptMap = salesAttemptMap;

            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity newStage = new Opportunity();
            newStage.id = opportunity.id;
            newStage.Total_Calls_Made__c = 2;
            newStage.Total_Email__c = 1;
            newStage.Total_Calls__c = 1;
            newStage.Total_Text__c = 0;
            newStage.Total_New_Calls__c=0;
            newStage.Total_New_Email__c=0;
            update newStage;
            
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
            nnfpStage.Total_Calls_Made__c = 4;
            nnfpStage.Total_Email__c = 2;
            nnfpStage.Total_Calls__c = 2;
            nnfpStage.Total_Text__c = 0;
            nnfpStage.Total_New_Calls__c=1;
            nnfpStage.Total_New_Email__c=1;
            update nnfpStage;
            
          
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity nnfpStageTCMNew = new Opportunity();
            nnfpStageTCMNew.id = opportunity.id;
            nnfpStageTCMNew.StageName='closed';
            nnfpStageTCMNew.OppNotNowFollowUpDateTime__c=System.Today()-2;
            update nnfpStageTCMNew;
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity reopennew = new Opportunity();
            reopennew.id = opportunity.id;
            reopennew.Total_Calls_Made__c = 6;
            reopennew.Total_Email__c = 3;
            reopennew.Total_Calls__c = 3;
            reopennew.Total_Text__c = 0;
            reopennew.Total_New_Calls__c=2;
            reopennew.Total_New_Email__c=2;
            update reopennew;
            
           
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            
            Opportunity nnfustageopp = new Opportunity();
            nnfustageopp.id=opportunity.id;
            nnfustageopp.StageName = 'Assigned';
            nnfustageopp.OppNotNowFollowUpDateTime__c=System.Today()-2;
            update nnfustageopp;
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity nnfpStageinc = new Opportunity();
            nnfpStageinc.id = opportunity.id;
            nnfpStageinc.Total_Calls_Made__c = 8;
            nnfpStageinc.Total_Email__c = 4;
            nnfpStageinc.Total_Calls__c = 4;
            nnfpStageinc.Total_Text__c = 0;
            nnfpStageinc.Total_New_Calls__c=3;
            nnfpStageinc.Total_New_Email__c=3;
            update nnfpStageinc;
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            
            Opportunity closedstageopp = new Opportunity();
            closedstageopp.id=opportunity.id;
            closedstageopp.StageName = 'Not Now -  Follow Up';
            closedstageopp.OppNotNowFollowUpDateTime__c=System.Today()-2;
            update closedstageopp;
            
            
            Test.startTest();
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity closedstageoppinc = new Opportunity();
            closedstageoppinc.id = opportunity.id;
            closedstageoppinc.Total_Calls_Made__c = 10;
            closedstageoppinc.Total_Email__c = 5;
            closedstageoppinc.Total_Calls__c = 5;
            closedstageoppinc.Total_Text__c = 0;
            closedstageoppinc.Total_New_Calls__c=4;
            closedstageoppinc.Total_New_Email__c=4;
            update closedstageoppinc;
            
            AP_OpportunityTrigger.isButtonExecuted=true;
            AP_OpportunityTrigger.runOnce=true;
            Opportunity assignedreopenopp = new Opportunity();
            assignedreopenopp.id = opportunity.id;
            assignedreopenopp.StageName='New';
            assignedreopenopp.OppNotNowFollowUpDateTime__c=System.Today()-2;
            update assignedreopenopp;
            Test.stopTest();
            
            SalesAttempt__c sc1 = [select id, name,SA_TCM__c,Total_Email__c,Total_Text__c,Total_calls__c from SalesAttempt__c where opportunity__c=:opportunity.id order by name desc limit 1];
            Opportunity opp = [SELECT Id, TCM_New__c, Total_New_Calls__c, Total_New_Email__c, Total_New_Text__c FrOm Opportunity WHERE Id = :opportunity.Id];
            System.assertEquals(2, sc1.SA_TCM__c,'Sales attempt was not updated successfully!');
            System.assertEquals(1, sc1.Total_Email__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, sc1.Total_Text__c,'Sales attempt was not updated successfully!');
            System.assertEquals(1, sc1.Total_calls__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, opp.TCM_New__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, opp.Total_New_Calls__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, opp.Total_New_Email__c,'Sales attempt was not updated successfully!');
            System.assertEquals(0, opp.Total_New_Text__c,'Sales attempt was not updated successfully!');
            
        }
                    
    }
                                         
}