/**
* @name AP_Opportunity_StopJourney_Test
* @author TGV Team   
* @description Apex Unit testing for AP_Opportunity_StopJourney Class
* @Version
*           1.0 -   TGV - Initial Development
*           2.0 -   TGV - Added new Test Methods for verifying Account Messages only with Status 'Scheduled' should get deleted
*           3.0 -   TGV - Added new Test Method for Stop Journey on Default Opportunity
*           4.0 -   QuadCore - Removed logic to switch record type on Opportunity
*           5.0 -   Incognito - Refactored the code added methods createJourney, retrieveAccountDataMethod, retrieveAgentUserMethod - 08-25-2022
*/
@IsTest(SeeAllData = false)

public class AP_Opportunity_StopJourney_Test{
    
    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static User systemUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static UserRole agentTeamMemberUserRole;
    private static final String JOURNEYTASK_DESCRIPTION = 'Follow up or Determine next marketing step';
    private static final String TASK_PRIORITY_NO  = 'No';
    private static final String TASK_TASKTYPE_SALES  = 'Sales';
    private static final String TASK_APPCODE_SFDCILPJOURNEY  = 'SFDC ILP Journey';
    private static final String TASK_CATEGORY_JOURNEY  = 'Journey';
    private static final String TASK_STATUS_CANCELLED  = 'Cancelled';
    private static final String TASK_STATUS_NOTSTARTED  = 'Not Started';
    private static final String TASK_STATUS_COMPLETED = 'Completed';
    private static final String TASK_SUBJECT_CALL = 'Call';
    private static final String TASK_SUBJECT_MAILING = 'Mailing';
    private static final String ACCOUNT_MESSAGE_STATUS_CANCELLED_STOPJOURNEY = 'Cancelled - stopped journey';
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();
        
    /**
    * @description Setup method used for building test data (must be called at beginning of test)
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
        }
    }

    //To get the Recordtype of opportunity

    //method to build Account record with the given parameter value
    private static Account buildAccountRecord(String paramClientIdentifier) {
        Account act = new Account(Edit_In_VFP__c=true,FirstName = 'rrrrr', LastName = 'tttttttt', ClientIdentifier__c = paramClientIdentifier);
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
    private static Journey__c buildJourneyRecord(Journey__c sampleUser) {
        Journey__c jny = new Journey__c(JourneyName__c=sampleUser.JourneyName__c, Journey_External_ID__c =sampleUser.Journey_External_ID__c,BusinessLineCode__c = 'Auto',CategoryName__c = 'prospect customers',
                            JourneyDescription__c='Jnydescription', VendorCode__c= 0, JourneyNumber__c = sampleUser.JourneyNumber__c, 
                            CreatorRoleCode__c = 'C', CustomDemographicsInd__c = true, JourneyFundingID__c = sampleUser.JourneyFundingID__c);
        return jny;
    }  
    
    
    //method to create journey with the given journeyList parameter value
    private static void createJourneyRec(List<Journey__c> journeys) {
        if(journeys!= null && !journeys.isEmpty()) {                
            insert journeys;
        }
    } 

    /* @Refactor
    * @method- createJourney
    * @date modified - 24/08/2022
    * @description -Return Journey__c data, method to avoid deplicate code
    * @return - Journey__c
    */
    private static Journey__c createJourney(){
        List<Journey__c> journeyList=new List<Journey__c>();
            Journey__c jny = new Journey__c();
            jny.JourneyName__c = 'Jny1';
            jny.JourneyNumber__c = '1';
            jny.Journey_External_ID__c = '101010';
            jny.JourneyFundingID__c = '111111';
            journeyList.add(buildJourneyRecord(jny));
            Journey__c jny1 = new Journey__c();
            jny1.JourneyName__c = 'Jny2';
            jny1.JourneyNumber__c = '2';
            jny1.Journey_External_ID__c = '2020202';
            jny1.JourneyFundingID__c = '222222';
            journeyList.add(buildJourneyRecord(jny1));
            createJourneyRec(journeyList);
            Journey__c selectedJourneyInfo=[select id, JourneyName__c, Journey_External_ID__c, JourneyDescription__c, Status__c, CategoryName__c, JourneyFundingID__c, 
                                            CreatorRoleCode__c, CustomDemographicsInd__c from Journey__c where JourneyName__c= 'Jny2' LIMIT 1];             

            return selectedJourneyInfo;
    }
    
   /* @Refactor
    * @method- retrieveAccountDataMethod
    * @date modified - 24/08/2022
    * @description -Return Account data, method to avoid deplicate code
    * @return - Account
    */
    private static Account  retrieveAccountDataMethod(id agentid) { 
        Account  testAccount = [select id, ClientIdentifier__c, ownerId from Account where CreatedbyId =:agentid Limit 1];    
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentid);
        insert newAgentRole;
        return testAccount;
    }    
	/* @Refactor
    * @method- retrieveAgentUserMethod
    * @date modified - 24/08/2022
    * @description -Return User data, method to avoid deplicate code
    * @return - User
    */
    private static User  retrieveAgentUserMethod(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'TestAgtUserForOppTst11@statefarm.com'];
        agentUser= queryAgent;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings(); 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);           
        System.runAs(agentUser) {
            Account act = buildAccountRecord('1213121');
            insert act;            
        }
        return agentUser;
    }

    /**
    * @description Testing Stop Journey flow on Opportunity as an Agent User on ILP Claimed RecordType,
              Journey fields on opportunity should get updated as blank , corresponding Journey Tasks "Status" should get updated to "Cancelled" and Account Messages should get deleted if "Status" is "Scheduled", 
    * @name-  testIlpClaimedStopJourneyByAgent 
    */
    @isTest
    private static void testOpportunityStopJourneyByAgent() {
    
        agentUser = retrieveAgentUserMethod();
        Account testAccount = retrieveAccountDataMethod(agentUser.id);             
        System.runAs(agentUser) { 
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Assigned', optyRecordTypeId);
            insert opty;
        
            Journey__c selectedJourneyInfo = createJourney();             
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            Journey_Step__c jnyI =new Journey_Step__c();
            jnyI.JourneyID__c = selectedJourneyInfo.id;
            jnyI.JourneyStepID__c = 1;
            jnyI.JourneyNumber__c = '1';
            jnyI.VendorCode__c = 11111;
            jnyI.DaysNum__c = 1;
            jnyI.ContactMethodName__c = TASK_SUBJECT_CALL;
            jnystepsList.add(jnyI);
            Journey_Step__c jnyS =new Journey_Step__c();
            jnyS.JourneyID__c = selectedJourneyInfo.id;
            jnyS.JourneyStepID__c = 2;
            jnyS.JourneyNumber__c = '2';
            jnyS.VendorCode__c = 22222;
            jnyS.DaysNum__c = 2;
            jnyS.ContactMethodName__c = TASK_SUBJECT_MAILING;
            jnystepsList.add(jnyS);
            Journey_Step__c jny2 = new Journey_Step__c();
            jny2.JourneyID__c = selectedJourneyInfo.id;
            jny2.JourneyStepID__c = 4;
            jny2.JourneyNumber__c = '4';
            jny2.VendorCode__c = 44444;
            jny2.DaysNum__c = 4;
            jny2.ContactMethodName__c = TASK_SUBJECT_MAILING;
            jnystepsList.add(jny2);
            Journey_Step__c jnyInfo =new Journey_Step__c();
            jnyInfo.JourneyID__c = selectedJourneyInfo.id;
            jnyInfo.JourneyStepID__c = 5;
            jnyInfo.JourneyNumber__c = '5';
            jnyInfo.VendorCode__c = 55555;
            jnyInfo.DaysNum__c = 5;
            jnyInfo.ContactMethodName__c = TASK_SUBJECT_MAILING;
            jnystepsList.add(jnyInfo);
            Journey_Step__c jnyStep =new Journey_Step__c();
            jnyStep.JourneyID__c = selectedJourneyInfo.id;
            jnyStep.JourneyStepID__c = 3;
            jnyStep.JourneyNumber__c = '3';
            jnyStep.VendorCode__c = 33333;
            jnyStep.DaysNum__c = 3;
            jnyStep.ContactMethodName__c = TASK_SUBJECT_CALL;
            jnystepsList.add(jnyStep);
            insert jnystepsList;            
                                     
            //Calling Start Journey on opportunity Apex Class with required parameter        
            AP_Opportunity_StartJourney.oppStartJourney(Opty.Id,selectedJourneyInfo.Id);
            Opportunity oppDetailsAfterStartJourney = [select id, Accountid, Journey_Name__c, Journey_ID__c, Assigned_To__c, Journey_Description__c,
                                            Journey_Start_Date__c, RecordType.DeveloperName, ownerid, LOB__c 
                                            from Opportunity where id =: Opty.id LIMIT 1];      
            List<Task> taskrecords =  [Select Id from Task where JourneyId__c = : selectedJourneyInfo.id AND Whatid = :oppDetailsAfterStartJourney.id];
            system.AssertEquals(2, taskrecords.size(), 'Unexpected Task Record Size'); 
            List<AccountMessage__c> accmesrecords = [Select Id, Status__c from AccountMessage__c where Account__c = :oppDetailsAfterStartJourney.Accountid];                   
            system.AssertEquals(3, accmesrecords.size(),'Unexpected Account Messages Record Size'); 
            User querysysAdminuser = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'systemAdminTest@statefarm.com'];
            sysAdminuser = querysysAdminuser;
            //Updating 2 Account messages as sent,both should not be deleted by the Stop Journey Flow 
             System.runAs(sysAdminuser){
             List<AccountMessage__c> accmesstoUpdate = [select id, Status__c from AccountMessage__c Limit 2];
                for(AccountMessage__c accmessages: accmesstoUpdate ){
                    accmessages.Status__c = 'Sent';
                    } 
                 update accmesstoUpdate;
                } 
            Test.startTest();                     
            //Calling Stop Journey on Opportunity Apex Class with required parameter        
            AP_Opportunity_StopJourney.oppStopJourneyFromLWC(Opty.id);                                   
            Test.stopTest();
            Opportunity oppDetailsAfterStopJourney = [select id, AccountId, Journey_Name__c, Journey_ID__c, Journey_Description__c, Journey_Start_Date__c, RecordType.DeveloperName
                                            from Opportunity where id =: Opty.id LIMIT 1];
                                            
            //Verifying Task records should not be deleted and Status should be changed to Cancelled
            List<Task> taskRecordsAfterStop =  [Select Id, Status from Task where JourneyId__c = : selectedJourneyInfo.id AND Whatid = :oppDetailsAfterStopJourney.id];
            system.AssertEquals(2, taskRecordsAfterStop.size() , 'Unexpected Task Record Size after Journey stop');
            for(integer i=0; i<taskRecordsAfterStop.size();i++){
                system.AssertEquals(taskRecordsAfterStop[i].Status , TASK_STATUS_CANCELLED, 'Task Status was not changed to Cancelled');
            }
             
            //Verifying 2 out of 3 Account Messages records are not deleted since Status equals to 'Sent'
            List<AccountMessage__c> accmesRecordsAfterStop = [Select Id, Status__c  from AccountMessage__c where Account__c = :oppDetailsAfterStopJourney.Accountid];                      
            system.AssertEquals(2, accmesRecordsAfterStop.size(), 'Unexpected Account Messages Record Size after Journey stop');
            
            //Verifying Journey fields on Opportunity are updated as null
            system.AssertEquals(null, oppDetailsAfterStopJourney.Journey_Name__c, 'Opportunity JourneyName is not null');
            system.AssertEquals(null, oppDetailsAfterStopJourney.Journey_ID__c, 'Opportunity JourneyId is not null');
            system.AssertEquals(null, oppDetailsAfterStopJourney.Journey_Description__c, 'Opportunity Journey Description is not null');
            system.AssertEquals(null, oppDetailsAfterStopJourney.Journey_Start_Date__c, 'Opportunity Journey StartDate is not null');
          }
        } 
    
  

    /**
    * @description Testing Stop Journey flow on Opportunity as an Atm User on SFCom Claimed Recordtype,
               Journey fields on opportunity should get updated as blank, corresponding Journey Tasks "Status" should get updated to "Cancelled" and Account Messages should get deleted if "Status" is "Scheduled", 
    * @name-   testSfcomClaimedStopJourneyByAtm
    */
    @isTest
    private static void testOpportunityStopJourneyByAtm() {
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'TestAgtUserForOppTst11@statefarm.com'];
        agentUser= queryAgent;
        User queryAtm = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'TestAtmUserForOppTst11@statefarm.com'];
        atmUser= queryAtm; 
        // Account testAccount;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings(); 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUser);           
        System.runAs(atmUser) {
            Account act = buildAccountRecord('1213121');
            insert act;            
        }
        Account testAccount = [select id, ownerId from Account where CreatedbyId =:atmUser.id];    
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;             
        System.runAs(atmUser) { 
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Assigned', optyRecordTypeId);
            insert opty;
            Journey__c selectedJourneyInfo = createJourney();    
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            Journey_Step__c jnyI =new Journey_Step__c();
            jnyI.JourneyID__c = selectedJourneyInfo.id;
            jnyI.JourneyStepID__c = 1;
            jnyI.JourneyNumber__c = '1';
            jnyI.VendorCode__c = 11111;
            jnyI.DaysNum__c = 1;
            jnyI.ContactMethodName__c = TASK_SUBJECT_CALL;
            jnystepsList.add(jnyI);
            Journey_Step__c jnyS =new Journey_Step__c();
            jnyS.JourneyID__c = selectedJourneyInfo.id;
            jnyS.JourneyStepID__c = 2;
            jnyS.JourneyNumber__c = '2';
            jnyS.VendorCode__c = 22222;
            jnyS.DaysNum__c = 2;
            jnyS.ContactMethodName__c = TASK_SUBJECT_MAILING;
            jnystepsList.add(jnyS);
            Journey_Step__c jnyStep =new Journey_Step__c();
            jnyStep.JourneyID__c = selectedJourneyInfo.id;
            jnyStep.JourneyStepID__c = 3;
            jnyStep.JourneyNumber__c = '3';
            jnyStep.VendorCode__c = 33333;
            jnyStep.DaysNum__c = 3;
            jnyStep.ContactMethodName__c = TASK_SUBJECT_CALL;
            jnystepsList.add(jnyStep);
            Journey_Step__c jny2 = new Journey_Step__c();
            jny2.JourneyID__c = selectedJourneyInfo.id;
            jny2.JourneyStepID__c = 4;
            jny2.JourneyNumber__c = '4';
            jny2.VendorCode__c = 44444;
            jny2.DaysNum__c = 4;
            jny2.ContactMethodName__c = TASK_SUBJECT_MAILING;
            jnystepsList.add(jny2);
            insert jnystepsList;            
                                    
            //Calling Start Journey on opportunity Apex Class with required parameter        
            AP_Opportunity_StartJourney.oppStartJourney(Opty.Id,selectedJourneyInfo.Id);
            Opportunity oppDetailsAfterStartJourney = [select id, Accountid, Journey_Name__c, Journey_ID__c, Assigned_To__c, Journey_Description__c,
                                            Journey_Start_Date__c, RecordType.DeveloperName, ownerid, LOB__c 
                                            from Opportunity where id =: Opty.id LIMIT 1];      
            List<Task> taskrecords =  [Select Id from Task where JourneyId__c = : selectedJourneyInfo.id AND Whatid = :oppDetailsAfterStartJourney.id];
            system.AssertEquals(2, taskrecords.size(), 'Unexpected Task Record Size'); 
            List<AccountMessage__c> accmesrecords = [Select Id from AccountMessage__c where Account__c = : oppDetailsAfterStartJourney.Accountid];                   
            system.AssertEquals(2, accmesrecords.size(), 'Unexpected Account Messages Record Size'); 
                       
            Test.startTest();                     
            //Calling Stop Journey on Opportunity Apex Class with required parameter        
            AP_Opportunity_StopJourney.oppStopJourneyFromLWC(Opty.id);                                   
            Test.stopTest();
            Opportunity oppDetailsAfterStopJourney = [select id, AccountId, Journey_Name__c, Journey_ID__c, Journey_Description__c, Journey_Start_Date__c, RecordType.DeveloperName
                                            from Opportunity where id =: Opty.id LIMIT 1];
                                            
            //Verifying Task records should not be deleted and Status should be changed to Cancelled
         
            List<Task> taskRecordsAfterStop =  [Select Id, Status from Task where JourneyId__c = : selectedJourneyInfo.id AND Whatid = :oppDetailsAfterStopJourney.id];
            system.AssertEquals(2, taskRecordsAfterStop.size(), 'Unexpected Task Record Size after Journey stop');
            for(integer i=0; i<taskRecordsAfterStop.size();i++){
                system.AssertEquals(taskRecordsAfterStop[i].Status , TASK_STATUS_CANCELLED, 'Task Status was not changed to Cancelled');
            }
          
            //Verifying Account Message records are deleted since Status is 'Scheduled'
            List<AccountMessage__c> accmesRecordsAfterStop = [Select Id from AccountMessage__c where Account__c = :oppDetailsAfterStopJourney.Accountid];                      
            system.AssertEquals(0, accmesRecordsAfterStop.size(), 'Unexpected Account Messages Record Size after Journey stop');
            
            //Verifying Journey fields on Opportunity are updated as null
            system.AssertEquals(null, oppDetailsAfterStopJourney.Journey_Name__c, 'Opportunity JourneyName is not null');
            system.AssertEquals(null, oppDetailsAfterStopJourney.Journey_ID__c, 'Opportunity JourneyId is not null');
            system.AssertEquals(null, oppDetailsAfterStopJourney.Journey_Description__c, 'Opportunity Journey Description is not null');
            system.AssertEquals(null, oppDetailsAfterStopJourney.Journey_Start_Date__c, 'Opportunity Journey StartDate is not null');
        }
    }
    

    /*****************Test Methods for RFC Granted scenarios as Agent and ATM ***********************************/
    
    /**
    * @description This method is used to test the opportunityBeforeUpdate and opportunityAfterUpdate Trigggers when the opportunity Stage changes to "RFC Granted". Testing as an Agent User,
              Journey fields on opportunity should get updated as blank, corresponding Journey Tasks "Status" should get updated to "Cancelled" and Account Messages should get deleted if "Status" is "Scheduled", 
    * @name-  testdeleteAccMesgAndTaskRFCGrantedByAgent
    */
    @isTest
    private static void testdeleteAccMesgAndTaskByAgent() {
    
        agentUser = retrieveAgentUserMethod();
        Account testAccount = retrieveAccountDataMethod(agentUser.id);    
             
        System.runAs(agentUser) { 
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Assigned', optyRecordTypeId);
            insert opty;
            Journey__c selectedJourneyInfo = createJourney();              
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            Journey_Step__c jnyI =new Journey_Step__c();
            jnyI.JourneyID__c = selectedJourneyInfo.id;
            jnyI.JourneyStepID__c = 1;
            jnyI.JourneyNumber__c = '1';
            jnyI.VendorCode__c = 11111;
            jnyI.DaysNum__c = 1;
            jnyI.ContactMethodName__c = TASK_SUBJECT_CALL;
            jnystepsList.add(jnyI);
            Journey_Step__c jnyS =new Journey_Step__c();
            jnyS.JourneyID__c = selectedJourneyInfo.id;
            jnyS.JourneyStepID__c = 2;
            jnyS.JourneyNumber__c = '2';
            jnyS.VendorCode__c = 22222;
            jnyS.DaysNum__c = 2;
            jnyS.ContactMethodName__c = TASK_SUBJECT_MAILING;
            jnystepsList.add(jnyS);
            Journey_Step__c jny2 = new Journey_Step__c();
            jny2.JourneyID__c = selectedJourneyInfo.id;
            jny2.JourneyStepID__c = 4;
            jny2.JourneyNumber__c = '4';
            jny2.VendorCode__c = 44444;
            jny2.DaysNum__c = 4;
            jny2.ContactMethodName__c = TASK_SUBJECT_MAILING;
            jnystepsList.add(jny2);
            Journey_Step__c jnyInfo =new Journey_Step__c();
            jnyInfo.JourneyID__c = selectedJourneyInfo.id;
            jnyInfo.JourneyStepID__c = 5;
            jnyInfo.JourneyNumber__c = '5';
            jnyInfo.VendorCode__c = 55555;
            jnyInfo.DaysNum__c = 5;
            jnyInfo.ContactMethodName__c = TASK_SUBJECT_MAILING;
            jnystepsList.add(jnyInfo);
            Journey_Step__c jnyStep =new Journey_Step__c();
            jnyStep.JourneyID__c = selectedJourneyInfo.id;
            jnyStep.JourneyStepID__c = 3;
            jnyStep.JourneyNumber__c = '3';
            jnyStep.VendorCode__c = 33333;
            jnyStep.DaysNum__c = 3;
            jnyStep.ContactMethodName__c = TASK_SUBJECT_CALL;
            jnystepsList.add(jnyStep);
            insert jnystepsList;            
    
            //Calling Start Journey on opportunity Apex Class with required parameter        
            AP_Opportunity_StartJourney.oppStartJourney(Opty.Id,selectedJourneyInfo.Id);
            Opportunity oppDetailsAfterStartJourney = [select id, Accountid, Journey_Name__c, Journey_ID__c, Assigned_To__c, Journey_Description__c,
                                            Journey_Start_Date__c, RecordType.DeveloperName, ownerid, LOB__c 
                                            from Opportunity where id =: Opty.id LIMIT 1];      
            List<Task> taskrecords =  [Select Id from Task where JourneyId__c = : selectedJourneyInfo.id AND Whatid = :oppDetailsAfterStartJourney.id];
            system.AssertEquals(2, taskrecords.size(), 'Unexpected Task Record Size'); 
            List<AccountMessage__c> accmesrecords = [Select Id, Status__c from AccountMessage__c where Account__c = :oppDetailsAfterStartJourney.Accountid];                   
            system.AssertEquals(3, accmesrecords.size(), 'Unexpected Account Messages Record Size'); 
            User querysysAdminuser = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'systemAdminTest@statefarm.com'];
            sysAdminuser = querysysAdminuser;
            HLPR_SignedWrittenConsent.byPassOpportunityBeforeUpdate = false;
            //Updating StageName to "RFC Granted", and updating the RecordType to "RFC"
             System.runAs(sysAdminuser){
                Opty.Credit_Status__c = 'RFC Requested';
                update opty;
             //List<AccountMessage__c> accmesstoUpdate = [select id, Status__c from AccountMessage__c where JourneyNumber__c = '2' or JourneyNumber__c = '4'];
               
             Opty.RecordTypeid = optyRecordTypeId;
                Opty.Credit_Status__c = 'RFC Granted';
             update Opty;
             }
             Test.startTest();           
                                                
             Test.stopTest();
             Opportunity oppDetailsAfterStopJourney = [select id, AccountId, Journey_Name__c, Journey_ID__c, Journey_Description__c, Journey_Start_Date__c, RecordType.DeveloperName
                                                       from Opportunity where id =: Opty.id LIMIT 1];
                                                
             //Verifying Task records should not be deleted and Status should be changed to Cancelled
                List<Task> taskRecordsAfterStop =  [Select Id, Status from Task where JourneyId__c = : selectedJourneyInfo.id AND Whatid = :oppDetailsAfterStopJourney.id];
                system.AssertEquals(2, taskRecordsAfterStop.size(), 'Unexpected Task Record Size after Journey stop');
                for(integer i=0; i<taskRecordsAfterStop.size();i++){
                system.AssertEquals(taskRecordsAfterStop[i].Status , TASK_STATUS_CANCELLED, 'Task Status was not changed to Cancelled');
                }
                 
             //Verifying Account Messages records should get deleted where Status equals to 'Scheduled'
                List<AccountMessage__c> accmesRecordsAfterStop = [Select Id, Status__c  from AccountMessage__c where Account__c = :oppDetailsAfterStopJourney.Accountid];                      
                system.AssertEquals(0, accmesRecordsAfterStop.size(), 'Unexpected Account Messages Record Size after Journey stop');
          
             //Verifying Journey fields on Opportunity are updated as null
               system.AssertEquals(null, oppDetailsAfterStopJourney.Journey_Name__c,'Opportunity JourneyName is not null');
               system.AssertEquals(null, oppDetailsAfterStopJourney.Journey_ID__c, 'Opportunity JourneyId is not null');
               system.AssertEquals(null, oppDetailsAfterStopJourney.Journey_Description__c, 'Opportunity Journey Description is not null');
               system.AssertEquals(null, oppDetailsAfterStopJourney.Journey_Start_Date__c, 'Opportunity Journey StartDate is not null');
          } 
    }
                     
    /**
    * @description Test method to verfiy to move the ILP Claimed opportunity back to Start journey from Stop journey when it's Closed
    * @name-  testUpdatesonILPClaimedOpportunitiesWhenSetToClosedWon
    */    
    @isTest
     private static void testUpdatesOnOpportunitiesWhenSetToClosedWon() {
        agentUser = retrieveAgentUserMethod();
        Account testAccount = retrieveAccountDataMethod(agentUser.id);
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;             
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Assigned', optyRecordTypeId);
            insert opty;
            
            Journey__c selectedJourneyInfo = createJourney(); 
            
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            Journey_Step__c jnyI =new Journey_Step__c();
            jnyI.JourneyID__c = selectedJourneyInfo.id;
            jnyI.JourneyStepID__c = 1;
            jnyI.JourneyNumber__c = '1';
            jnyI.VendorCode__c = 11111;
            jnyI.DaysNum__c = 1;
            jnyI.ContactMethodName__c = TASK_SUBJECT_CALL;
            jnystepsList.add(jnyI);
            Journey_Step__c jnyS =new Journey_Step__c();
            jnyS.JourneyID__c = selectedJourneyInfo.id;
            jnyS.JourneyStepID__c = 2;
            jnyS.JourneyNumber__c = '2';
            jnyS.VendorCode__c = 22222;
            jnyS.DaysNum__c = 2;
            jnyS.ContactMethodName__c = TASK_SUBJECT_MAILING;
            jnystepsList.add(jnyS);
            Journey_Step__c jny2 =new Journey_Step__c();
            jny2.JourneyID__c = selectedJourneyInfo.id;
            jny2.JourneyStepID__c = 4;
            jny2.JourneyNumber__c = '4';
            jny2.VendorCode__c = 44444;
            jny2.DaysNum__c = 4;
            jny2.ContactMethodName__c = TASK_SUBJECT_MAILING;
            jnystepsList.add(jny2);
            Journey_Step__c jnyInfo =new Journey_Step__c();
            jnyInfo.JourneyID__c = selectedJourneyInfo.id;
            jnyInfo.JourneyStepID__c = 5;
            jnyInfo.JourneyNumber__c = '5';
            jnyInfo.VendorCode__c = 55555;
            jnyInfo.DaysNum__c = 5;
            jnyInfo.ContactMethodName__c = TASK_SUBJECT_MAILING;
            jnystepsList.add(jnyInfo);
            Journey_Step__c jnyStep =new Journey_Step__c();
            jnyStep.JourneyID__c = selectedJourneyInfo.id;
            jnyStep.JourneyStepID__c = 3;
            jnyStep.JourneyNumber__c = '3';
            jnyStep.VendorCode__c = 33333;
            jnyStep.DaysNum__c = 3;
            jnyStep.ContactMethodName__c = TASK_SUBJECT_CALL;
            jnystepsList.add(jnyStep);
            insert jnystepsList;     
            
           
            //Calling Start Journey on opportunity Apex Class with required parameter        
            AP_Opportunity_StartJourney.oppStartJourney(Opty.Id,selectedJourneyInfo.Id);

            Opportunity oppDetailsAfterStartJourney =[Select id,Journey_ID__c,Journey_Name__c,Journey_Description__c,Journey_Start_Date__c,RecordType.Developername from Opportunity where ID=:Opty.id];
            System.assertNotEquals(oppDetailsAfterStartJourney.Journey_ID__c , null, 'Opportunity JourneyId is not null' );
            System.assertNotEquals(oppDetailsAfterStartJourney.Journey_Name__c , null, 'Opportunity JourneyName is not null');
            System.assertNotEquals(oppDetailsAfterStartJourney.Journey_Description__c , null, 'Opportunity Journey Description is not null');
            System.assertNotEquals(oppDetailsAfterStartJourney.Journey_Start_Date__c , null, 'Opportunity Journey StartDate is not null');
                       
            Test.startTest();
            // Update of opportunity to 'Closed Won' stage shoud fire OpportunityBeforeUpdate Trigger
            // and invoke updateOpportunityList method to reset all journey information
            oppDetailsAfterStartJourney.StageName ='Closed Won';
            HLPR_SignedWrittenConsent.byPassOpportunityBeforeUpdate = false;
            update oppDetailsAfterStartJourney;
            Test.stopTest();
            Opportunity oppDetailsAfterUpdate =[Select id,AccountId,Journey_ID__c,Journey_Name__c,Journey_Description__c,Journey_Start_Date__c,StageName,RecordType.DeveloperName from Opportunity where ID=:Opty.id];
            System.assertEquals(oppDetailsAfterUpdate.Journey_ID__c , null, 'Opportunity JourneyId is not null');
            System.assertEquals(oppDetailsAfterUpdate.Journey_Name__c , null, 'Opportunity JourneyName is not null');
            System.assertEquals(oppDetailsAfterUpdate.Journey_Description__c , null, 'Opportunity Journey Description is not null');
            System.assertEquals(oppDetailsAfterUpdate.Journey_Start_Date__c , null, 'Opportunity Journey StartDate is not null');
            System.assertEquals('Opportunity_Management', oppDetailsAfterUpdate.RecordType.Developername, 'Unexpected Opportunity Recordtype');
            
            //Verifying Task records status is changed to Completed
            List<Task> taskRecordsAfterUpdate =  [Select Id, Status from Task where JourneyId__c = : selectedJourneyInfo.id AND Whatid = :oppDetailsAfterUpdate.id];
            System.AssertEquals(2, taskRecordsAfterUpdate.size(), 'Unexpected Task Record Size after updating the Task');
            for(integer i=0; i<taskRecordsAfterUpdate.size();i++){
               system.AssertEquals(taskRecordsAfterUpdate[i].Status , TASK_STATUS_COMPLETED, 'Task Status was not changed to Completed');
            }
                 
            //Verifying Account Message records status is changed to Cancelled - stopped journey
            List<AccountMessage__c> accmesRecordsAfterUpdate = [Select Id, Status__c  from AccountMessage__c where Account__c = :oppDetailsAfterUpdate.Accountid];                      
            system.AssertEquals(3, accmesRecordsAfterUpdate.size(), 'Unexpected Account Messages Record Size after Journey stop');
            for(integer i=0; i<accmesRecordsAfterUpdate.size();i++){
               system.AssertEquals(accmesRecordsAfterUpdate[i].Status__c , ACCOUNT_MESSAGE_STATUS_CANCELLED_STOPJOURNEY, 'Account Message Status was not changed to Cancelled - stop journey');
            }
        }
    }
}