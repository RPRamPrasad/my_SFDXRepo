/**
Author Team ClubCar
Name - CMP_RetrieveAccountMessages_TEST
@description Test class written for CMP_RetrieveAccountMessages 
========================================================================================================================================+
History
-------
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                12/14/2018              Initial Development
2.0             Team ClubCar                01/15/2019              Added test method to cover Account level Account Messages
3.0             Team ClubCar                03/20/2020              Updated test method to cover exception scenario
******************************************************************************************************************************************/
@isTest()
public with sharing class CMP_RetrieveAccountMessages_TEST {
    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static User systemUser;
    private static User chatterUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static UserRole agentTeamMemberUserRole;    
    private static final String TASK_SUBJECT_MAILING = 'Mailing';
    private static Map<String, Schema.Recordtypeinfo> opportunityRecordTypeMap = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName();
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    private static String recordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId;
    /**
    * @method- Setup method used for building test data (must be called at beginning of test)
    * @description  This helps us to building test data
    * @name-  setUpTriggerAndUserData
	*/
    
    @TestSetup
    private static void setUpTriggerAndUserData() {
        systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();  
        insert systemUser;
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c(Override_All__c= false);
        insert objectBasedByPassTrigger;
        CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
        insert accountByPassTrigger;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);            
        insert sysAdminUserIdSetting;
        CS001_ByPassTriggerGtoZ__c oppByPassTrigger = new CS001_ByPassTriggerGtoZ__c(Override_OppBeforeInsert__c=false);
        insert oppByPassTrigger;
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
            atmUser = new User(alias = 'Alias', email='remCmpMemAgent1@statefarm.com.bad',
                               Associate_ID__c='124test', UserExternalID__c= '124test', Servicing_Agent_Associate_ID__c ='123test',
                               emailencodingkey='UTF-8', lastname='CmpMemProx', languagelocalekey='en_US', 
                               localesidkey='en_US', timezonesidkey='Europe/London', username= 'TestAtmUserForOppTst11@statefarm.com',userRoleId=agentTeamMemberUserRole.id);
            atmUser.ProfileId = UTIL_ProfileId_TEST.getATMProfileId();
            Database.insert(atmUser);
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        }
    }
    
    //To get the Recordtype of opportunity
    
    //method to build Account record with the given parameter value
    private static Account buildAccountRecord(String paramClientIdentifier) {
        Account act = new Account(FirstName = 'rrrrr', LastName = 'tttttttt', ClientIdentifier__c = paramClientIdentifier,RecordTypeId = recordTypeId,Edit_In_VFP__c = true);
        return act;
    }
    
    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String paramAccountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = userInfo.getUserId(), Customer__c = paramAccountId);
        return agentRole;
    }
    
    //method to build Opportunity record with the given parameter value
    private static Opportunity buildOpportunityRecord(String paramAccountId, String paramStageName, String paramRecordTypeId) {
        Opportunity opty = new Opportunity (Name = 'Tst ILP Claimed Opty', AccountId = paramAccountId,
                                            CloseDate = Date.today(), LOB__c = 'Auto',
                                            StageName = paramStageName, RecordTypeId = paramRecordTypeId);
        return opty; 
    }
    //method to build journey record with the given parameter value
    private static Journey__c buildJourneyRecord(Journey__c sampleBuild) {
                                                     Journey__c jny = new Journey__c(JourneyName__c=sampleBuild.JourneyName__c, Journey_External_ID__c =sampleBuild.Journey_External_ID__c,BusinessLineCode__c = 'Auto',CategoryName__c = 'prospect customers',
                                                                                     JourneyDescription__c='Jnydescription', VendorCode__c= 0, JourneyNumber__c = sampleBuild.JourneyNumber__c, 
                                                                                     CreatorRoleCode__c = 'C', CustomDemographicsInd__c = true, JourneyFundingID__c = sampleBuild.JourneyFundingID__c);
                                                     return jny;
                                                 }  
    
    
    //method to build journey steps record with the given parameter value
    private static Journey_Step__c buildJourneyStepsRecord(Journey_Step__c sampleBuildJny) {
        Journey_Step__c jnyStep = new Journey_Step__c(JourneyID__c = sampleBuildJny.JourneyID__c , JourneyStepID__c = sampleBuildJny.JourneyStepID__c,
                                                      VendorCode__c= 0, JourneyNumber__c = sampleBuildJny.JourneyNumber__c, DaysNum__c = sampleBuildJny.DaysNum__c, ContactMethodName__c = TASK_SUBJECT_MAILING);
        return jnyStep;
    }    
    
    //method to create journey with the given journeyList parameter value
    private static void createJourneyRec(List<Journey__c> journeys) {
        if(journeys!= null && !journeys.isEmpty()) {                
            insert journeys;
        }
    }
    
    //Method to test retrieval of AccountMessage records and profile validity through AccMessageQueryWrapper object based on passed opportunityid
    @isTest
    private static void testRetrieveOppAccountMessages() {
        
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'TestAgtUserForOppTst11@statefarm.com'];
        agentUser= queryAgent;
        Account testAccount;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Account act = buildAccountRecord('1213121');
            insert act;            
        }
        
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];    
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;             
        System.runAs(agentUser) { 
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Assigned', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            insert opty;
            List<Journey__c> journeyList=new List<Journey__c>();
            Journey__c buildJny = new Journey__c();
            buildJny.JourneyName__c = 'Jny1';
            buildJny.JourneyNumber__c ='1';
            buildJny.Journey_External_ID__c='101010';
            buildJny.JourneyFundingID__c='111111';
            journeyList.add(buildJourneyRecord(buildJny));
            Journey__c buildJnyInfo = new Journey__c();
            buildJnyInfo.JourneyName__c = 'Jny2';
            buildJnyInfo.JourneyNumber__c ='2';
            buildJnyInfo.Journey_External_ID__c='202020';
            buildJnyInfo.JourneyFundingID__c='222222';
            journeyList.add(buildJourneyRecord(buildJnyInfo));
            createJourneyRec(journeyList);
            Journey__c selectedJourneyInfo=[select id, JourneyName__c, Journey_External_ID__c, JourneyDescription__c, Status__c, CategoryName__c, JourneyFundingID__c, 
                                            CreatorRoleCode__c, CustomDemographicsInd__c from Journey__c where JourneyName__c= 'Jny2' LIMIT 1];             
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            Journey_Step__c buildJnyI = new Journey_Step__c();
            buildJnyI.JourneyID__c =selectedJourneyInfo.id;
            buildJnyI.JourneyStepID__c = 1;
            buildJnyI.JourneyNumber__c = '1';
            buildJnyI.DaysNum__c = 1;
            jnystepsList.add(buildJourneyStepsRecord(buildJnyI));
            Journey_Step__c buildJny1 = new Journey_Step__c();
            buildJny1.JourneyID__c =selectedJourneyInfo.id;
            buildJny1.JourneyStepID__c = 2;
            buildJny1.JourneyNumber__c = '2';
            buildJny1.DaysNum__c = 2;
            jnystepsList.add(buildJourneyStepsRecord(buildJny1));
            Journey_Step__c buildJny2 = new Journey_Step__c();
            buildJny2.JourneyID__c =selectedJourneyInfo.id;
            buildJny2.JourneyStepID__c = 3;
            buildJny2.JourneyNumber__c = '3';
            buildJny2.DaysNum__c = 3;
            jnystepsList.add(buildJourneyStepsRecord(buildJny2));
            insert jnystepsList;
			//Adding random Account Message without Opp Id, this should not be displayed on UI and assert results.
			AccountMessage__c randomAccMessage = new AccountMessage__c (name = 'testAccMessage', Account__c =testAccount.id);
            insert randomAccMessage;
                                     
            //Calling Start Journey on opportunity Apex Class with required parameter        
            AP_Opportunity_StartJourney.oppStartJourney(Opty.Id,selectedJourneyInfo.Id);        
            
            //Verifying Account message data                      
            CMP_RetrieveAccountMessages.AccMessageQueryWrapper accMessageWrap = new CMP_RetrieveAccountMessages.AccMessageQueryWrapper();
            Test.startTest();
            accMessageWrap = CMP_RetrieveAccountMessages.getAccountMessageResults(Opty.id);
            Test.stopTest();
            system.AssertEquals(3, accMessageWrap.accMessageQueryResults.size(),'Account Messages size did not match');
            system.assertEquals(true, accMessageWrap.isValidUser,'Invalid User encountered');            
        }                  
    }
    
    //Method to test retrieval of AccountMessage records and profile validity through AccMessageQueryWrapper object based on passed accountId
    @isTest
    private static void testRetrieveAccountMessages() {        
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'TestAgtUserForOppTst11@statefarm.com'];
        agentUser= queryAgent;
        Account testAccount;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Account act = buildAccountRecord('1213121');
            insert act;           
        }
        
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];    
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;             
        System.runAs(agentUser) { 
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Assigned', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            insert opty;
            List<Journey__c> journeyList=new List<Journey__c>();
            Journey__c buildJny = new Journey__c();
            buildJny.JourneyName__c = 'Jny1';
            buildJny.JourneyNumber__c ='1';
            buildJny.Journey_External_ID__c='101010';
            buildJny.JourneyFundingID__c='111111';
            journeyList.add(buildJourneyRecord(buildJny));
            Journey__c buildJnyInfo = new Journey__c();
            buildJnyInfo.JourneyName__c = 'Jny2';
            buildJnyInfo.JourneyNumber__c ='2';
            buildJnyInfo.Journey_External_ID__c='202020';
            buildJnyInfo.JourneyFundingID__c='222222';
            journeyList.add(buildJourneyRecord(buildJnyInfo));
            createJourneyRec(journeyList);
            Journey__c selectedJourneyInfo=[select id, JourneyName__c, Journey_External_ID__c, JourneyDescription__c, Status__c, CategoryName__c, JourneyFundingID__c, 
                                            CreatorRoleCode__c, CustomDemographicsInd__c from Journey__c where JourneyName__c= 'Jny2' LIMIT 1];             
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            Journey_Step__c buildJnyI = new Journey_Step__c();
            buildJnyI.JourneyID__c =selectedJourneyInfo.id;
            buildJnyI.JourneyStepID__c = 1;
            buildJnyI.JourneyNumber__c = '1';
            buildJnyI.DaysNum__c = 1;
            jnystepsList.add(buildJourneyStepsRecord(buildJnyI));
            Journey_Step__c buildJny1 = new Journey_Step__c();
            buildJny1.JourneyID__c =selectedJourneyInfo.id;
            buildJny1.JourneyStepID__c = 2;
            buildJny1.JourneyNumber__c = '2';
            buildJny1.DaysNum__c = 2;
            jnystepsList.add(buildJourneyStepsRecord(buildJny1));
            Journey_Step__c buildJny2 = new Journey_Step__c();
            buildJny2.JourneyID__c =selectedJourneyInfo.id;
            buildJny2.JourneyStepID__c = 3;
            buildJny2.JourneyNumber__c = '3';
            buildJny2.DaysNum__c = 3;
            jnystepsList.add(buildJourneyStepsRecord(buildJny2));
            insert jnystepsList;                                     
            //Calling Start Journey on opportunity Apex Class with required parameter        
            AP_Opportunity_StartJourney.oppStartJourney(Opty.Id,selectedJourneyInfo.Id);
            Opportunity opty2 = buildOpportunityRecord(testAccount.id, 'Assigned', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            insert opty2;          
            List<AccountMessage__c> accMessRecords = [Select opportunityid__c,Account__c from AccountMessage__c where Account__c = :testAccount.id];
            List<AccountMessage__c> newAccMessRecords = new List<AccountMessage__c>();
            for(AccountMessage__c acctMessage : accMessRecords){
                AccountMessage__c cloneAccMessage = new AccountMessage__c();
                cloneAccMessage = acctMessage.clone();
                cloneAccMessage.opportunityid__c = opty2.id;
                newAccMessRecords.add(cloneAccMessage);               
            }          
            insert newAccMessRecords;
            
            //Verifying Account message data                      
            CMP_RetrieveAccountMessages.AccMessageQueryWrapper accMessageWrap = new CMP_RetrieveAccountMessages.AccMessageQueryWrapper();            
            Test.startTest();
            accMessageWrap = CMP_RetrieveAccountMessages.getAccountMessageResults(testAccount.id);
            Test.stopTest();            
            System.AssertEquals(6, accMessageWrap.accMessageQueryResults.size(),'Account Messages size did not match');
            System.assertEquals(true, accMessageWrap.isValidUser,'Invalid User encountered');            
        }                  
    }
    
    //Method to test retrieval of IndividualEmailResult records and profile validity through AccMessageQueryWrapper object based on passed accountId
    @isTest
    private static void testIndividualEmailResults() {        
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'TestAgtUserForOppTst11@statefarm.com'];
        agentUser= queryAgent;
        Account testAccount;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Account act = buildAccountRecord('1213121');
            insert act;           
        }
        
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];    
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;             
        System.runAs(agentUser) { 
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Assigned', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            insert opty;
                     
            //Verifying Account message data                      
            CMP_RetrieveAccountMessages.AccMessageQueryWrapper accMessageWrap = new CMP_RetrieveAccountMessages.AccMessageQueryWrapper();        
            createIERec('U101-Test','Test journey',opty.Id); 
            Test.startTest();
            accMessageWrap = CMP_RetrieveAccountMessages.getMessagesTimelineResults(opty.id);
            Test.stopTest();  
            System.assertEquals(1, accMessageWrap.messageTimelineDataResp.size(), 'Message timeline size did not match');
            System.assertEquals(true, accMessageWrap.isValidUser,'Invalid User encountered');            
        }                  
    }
    
    //Method to test retrieval of IndividualTextResult records and profile validity through AccMessageQueryWrapper object based on passed accountId
    @isTest
    private static void testIndividualTextResults() {        
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'TestAgtUserForOppTst11@statefarm.com'];
        agentUser= queryAgent;
        Account testAccount;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Account act = buildAccountRecord('1213121');
            insert act;           
        }
        
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];    
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;       
        System.runAs(agentUser) { 
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Assigned', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            insert opty;
            
            CMP_RetrieveAccountMessages.AccMessageQueryWrapper accMessageWrap = new CMP_RetrieveAccountMessages.AccMessageQueryWrapper(); 
            
            IndividualTextResult__c itrRecord = new IndividualTextResult__c(Type__c = 'Text', Status__c = 'Delivered', Method__c = 'SF Connect', ItemNumber__c = 'T101',Initiatedby__c = 'ILP Text',Opportunity__c = opty.Id);
            insert itrRecord;
            
            createIERec('U101-Test','Test journey',opty.Id); 
            
            //Verifying Account message data                          
            Test.startTest();
            accMessageWrap = CMP_RetrieveAccountMessages.getMessagesTimelineResults(opty.id);
            Test.stopTest();
                
            System.assertEquals(2, accMessageWrap.messageTimelineDataResp.size(), 'Message timeline size did not match');
            System.assertEquals(true, accMessageWrap.isValidUser,'Invalid User encountered'); 
        }
    }

    //method to create IndividualEmailResult record
    private static void createIERec(String itemNumber,String initiatedBy,Id oppID) {
        et4ae5__SendDefinition__c sendDef = new et4ae5__SendDefinition__c();		
		insert sendDef;
        
        et4ae5__IndividualEmailResult__c iv = new et4ae5__IndividualEmailResult__c(type__c = 'EMail',
        ItemNumber__c = itemNumber,Initiatedby__c = initiatedBy,Opportunity__c = oppID,
        et4ae5__DateSent__c = system.today(),et4ae5__SendDefinition__c = sendDef.Id);
   	    insert iv;	
        
    }
    
    //method to test Exception
    @isTest
    private static void testRetrieveAccountMessagesException() {  
        User testChatterUser = new User(Alias='OOC1',LastName='LastName',Username=UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='CCCASSOCID1',UserExternalID__c='CCCASSOCID1');      
        chatterUser = UTIL_UserProvisioning_TEST.buildChatterOnlyUser(testChatterUser);
        insert chatterUser;
        Account act = buildAccountRecord('1213121');
        insert act;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(chatterUser);
        System.runAs(chatterUser) {
            //Verifying Account message data            
            CMP_RetrieveAccountMessages.AccMessageQueryWrapper accMessageWrap = new CMP_RetrieveAccountMessages.AccMessageQueryWrapper();
            Test.startTest();      
            accMessageWrap = CMP_RetrieveAccountMessages.getAccountMessageResults(act.id);           
            Test.stopTest();
            List<ExceptionLog__c> exLog = [SELECT Id,name, class__c, exception_Message__c from ExceptionLog__c class__c where class__c = 'CMP_RetrieveAccountMessages'];
            system.assertEquals(1,exLog.size(),'Exception Log Size did not match');
        }                  
    }
    
    //method to test Invalid User
    @isTest
    private static void testInValidUser() {
        User querySysAdmin = [Select id,Alias,lastname,email,profileid,username from User where username = 'systemAdminTest@statefarm.com' LIMIT 1];
        sysAdminUser= querySysAdmin;
        System.runAs(sysAdminUser) {
            system.assertEquals(false, CMP_RetrieveAccountMessages.isUserAnAgent(),'Invalid User encountered');       
        }
    }    
}