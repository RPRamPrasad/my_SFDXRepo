/**
* @name AP_Opportunity_StartJourney_Test
* @author TGV Team   
* @description Apex Unit testing for AP_Opportunity_StartJourney Class
* @Version - 
*           1.0 -   TGV - Initial Development
*           2.0 -   TGV - Added new TestMethods to cover Xdate scenarios    
*           3.0 -   TGV - Added new Test Method for Start Journey on Default Opportunity
*           4.0 -   TGV - Fix for R3 Test failure.
*           5.0 -   TGV - Added New Journey Start Date logic to fix Prod Defect 20585
*           6.0 & 7.0 -   TGV - Journey Start Date fix for future Xdate - Prod Defect 21541 & Defect 22785
*           8.0 -   TGV - Added new Test Method for verifying script field value being populated in Task Description when Script__c is not equal to null. 
*           9.0 -   QuadCore - Updated test class to remove logic for opportunity stop journey record type switch
*           10.0-   ClubCar -  Removed references to Task - Journey recordtype check
*           11.0-   Team Incognito - Remove duplicate code /Refactor
*/
@IsTest(SeeAllData = false)
Public class AP_Opportunity_StartJourney_Test{
    
    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static User systemUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static UserRole agentTeamMemberUserRole;
    private static final String JOURNEYTASK_DESCRIPTION = 'Follow up or Determine next marketing step';
    private static final String TASK_PRIORITY_NONE  = 'None';
    private static final String TASK_TASKTYPE_SALES  = 'Sales';
    private static final String TASK_APPCODE_SFDCILPJOURNEY  = 'SFDC ILP Journey';
    private static final String TASK_CATEGORY_JOURNEY  = 'Journey';
    private static final String TASK_STATUS_NOTSTARTED  = 'Not Started';
    private static final String TASK_SUBJECT_CALL = 'Call';
    private static final String TASK_SUBJECT_MAILING = 'Mailing';
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
    private static Journey__c buildJourneyRecord(Journey__c sampleJny) {
        Journey__c jny = new Journey__c(JourneyName__c=sampleJny.JourneyName__c, Journey_External_ID__c =sampleJny.Journey_External_ID__c,BusinessLineCode__c = 'Auto',CategoryName__c = 'prospect customers',
                                        JourneyDescription__c='Jnydescription', VendorCode__c= 0, JourneyNumber__c = sampleJny.JourneyNumber__c, 
                                        CreatorRoleCode__c = 'C', CustomDemographicsInd__c = true, JourneyFundingID__c = sampleJny.JourneyFundingID__c);
        return jny;
    }  
    
    
     //method to build journey steps record with the given parameter value
    private static Journey_Step__c buildJourneyStepsRecord(Journey_Step__c sampleJnyStep) {
        Journey_Step__c jnyStep = new Journey_Step__c(JourneyID__c = sampleJnyStep.JourneyID__c , JourneyStepID__c = sampleJnyStep.JourneyStepID__c,
                                                      VendorCode__c= sampleJnyStep.VendorCode__c, JourneyNumber__c = sampleJnyStep.JourneyNumber__c, DaysNum__c = sampleJnyStep.DaysNum__c, ContactMethodName__c = sampleJnyStep.ContactMethodName__c);
        return jnyStep;
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
    * @description - Return Journey data, method to avoid deplicate code
    * @return - Journey__c
    */
    private static Journey__c createJourney() {
        
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
    * @method- retriveATMUserMethod
    * @date modified - 22/08/2022
    * @description - Return Users data, method to avoid deplicate code
    * @return -User
    */
	private static User  retriveATMUserMethod() {        
        User queryAtm = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'TestAtmUserForOppTst11@statefarm.com'];
        atmUser= queryAtm;       
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings(); 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUser);            
        System.runAs(atmUser) {
            Account act = buildAccountRecord('1213124');
            insert act;
        }
        return atmUser;
    }
     
    /* @Refactor
    * @method- retriveAgentUserMethod
    * @date modified - 24/08/2022
    * @description -Return agent Users data, method to avoid deplicate code
    * @return - User
    */
	private static User  retriveAgentUserMethod() { 
         User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'TestAgtUserForOppTst11@statefarm.com'];
        agentUser= queryAgent;
        
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        return agentUser;
      }
    
     
    /** @Refactor
    * @description - retrieveAccountDataMethod
    * @date modified - 24/08/2022
    * @description - To return cAcount data, method to avoid deplicate code
    * @param atmUserId
    * @param agentUserId
    * @return - Account
    */
     public static Account  retrieveAccountDataMethod(string atmUserId, string agentUserId) {
         
       Account testAccount = [select id, ownerId from Account where CreatedbyId =:atmUserId];
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUserId);
        insert newAgentRole;
         return testAccount;
     }
        
    /**
    * @description  Testing Start Journey flow on Opportunity as an Agent User on ILP Claimed Recortype,
                Journey fields on opportunity should get updated, Corresponding Journey Tasks should be created when ContactMethodName__c='Call' and Accountmessages should be created when ContactMethodName__c='Mailing' 
    * @name-   testIlpClaimedSelectJourneyByAgent
    */
    @isTest
    private static void testIlpClaimedSelectJourneyByAgent() {
        Account testAccount;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();   
        agentUser = retriveAgentUserMethod();  
        System.runAs(agentUser) {
            Account act = buildAccountRecord('1213121');
            insert act;            
        }
		    
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];    
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;  
        System.runAs(agentUser) { 
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Assigned', optyRecordTypeId);
            insert opty;
           
            Journey__c selectedJourneyInfo = createJourney();
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            Journey_Step__c jnyStep0 = new Journey_Step__c();
            jnyStep0.JourneyID__c = selectedJourneyInfo.id;
            jnyStep0.JourneyStepID__c = 1;
            jnyStep0.JourneyNumber__c = '1';
            jnyStep0.VendorCode__c = 11111;
            jnyStep0.DaysNum__c = 1;
            jnyStep0.ContactMethodName__c = TASK_SUBJECT_CALL;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep0));
            Journey_Step__c jnyStep1 = new Journey_Step__c();
            jnyStep1.JourneyID__c = selectedJourneyInfo.id;
            jnyStep1.JourneyStepID__c = 2;
            jnyStep1.JourneyNumber__c = '2';
            jnyStep1.VendorCode__c = 22222;
            jnyStep1.DaysNum__c = 2;
            jnyStep1.ContactMethodName__c = TASK_SUBJECT_MAILING;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep1));
            Journey_Step__c jnyStep2 = new Journey_Step__c();
            jnyStep2.JourneyID__c = selectedJourneyInfo.id;
            jnyStep2.JourneyStepID__c = 3;
            jnyStep2.JourneyNumber__c = '3';
            jnyStep2.VendorCode__c = 33333;
            jnyStep2.DaysNum__c = 3;
            jnyStep2.ContactMethodName__c = TASK_SUBJECT_CALL;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep2));
            insert jnystepsList;            
                         
            Opportunity oppDetailsBefore = [select id,  Assigned_To__c, Journey_Name__c, Journey_ID__c, Journey_Description__c, Journey_Start_Date__c, RecordType.DeveloperName
                                            from Opportunity where id =: Opty.id LIMIT 1];            
            system.AssertEquals(null, oppDetailsBefore.Journey_Name__c, 'Opportunity JourneyName is not Null');
            system.AssertEquals(null, oppDetailsBefore.Journey_ID__c, 'Opportunity JourneyId is not Null');
            system.AssertEquals(null, oppDetailsBefore.Journey_Description__c, 'Opportunity JourneyDescription is not Null');
            system.AssertEquals(null, oppDetailsBefore.Journey_Start_Date__c, 'Opportunity JourneyStartDate is not Null');
            system.AssertEquals('Opportunity_Management', oppDetailsBefore.RecordType.DeveloperName, 'Unexpected Opportunity RecordType');
            
            Test.startTest();                     
            //Calling Start Journey on opportunity Apex Class with required parameter        
            AP_Opportunity_StartJourney.oppStartJourney(Opty.Id, selectedJourneyInfo.Id);                                   
            Test.stopTest();
            
            Opportunity oppDetailsAfter = [select id, Accountid, Account.FirstName, Journey_Name__c, Journey_ID__c, Assigned_To__c, Journey_Description__c,
                                           Journey_Start_Date__c, RecordType.DeveloperName, ownerid, LOB__c 
                                           from Opportunity where id =: Opty.id LIMIT 1];             
            //Verifying Opportunity Journey fields data with Selected Journey data                                
            system.AssertEquals(selectedJourneyInfo.JourneyName__c, oppDetailsAfter.Journey_Name__c, 'Unexpected Opportunity JourneyName');
            system.AssertEquals(selectedJourneyInfo.Journey_External_ID__c, oppDetailsAfter.Journey_ID__c, 'Unexpected Opportunity Journey Id');
            system.AssertEquals(selectedJourneyInfo.JourneyDescription__c, oppDetailsAfter.Journey_Description__c, 'Unexpected Opportunity Journey Description');
            system.AssertEquals(calculateOppStartDate(), oppDetailsAfter.Journey_Start_Date__c, 'Unexpected Opportunity Journey Start Date');
            
            List<Task> taskRecords =  [Select Id, AssignedTo__c, ActivityDate, whoid, ownerid, Description, JourneyId__c, Priority, Whatid, Status,
                                       Subject, AppCode__c, JourneyName__c, LineofBusiness__c, StepNumber__c, 
                                       TaskCategory__c, Task_Type__c,RecordType.DeveloperName from Task 
                                       where JourneyId__c = : selectedJourneyInfo.id AND Whatid = :Opty.id];
            system.AssertEquals(2, taskRecords.size(), 'Unexpected Task Record Size');
            //Verifying Journey Task data with Journey and Journey Step
            Id opportunityContactId = [Select id from contact where accountid =:oppDetailsAfter.Accountid Limit 1].id;
            List<Journey_Step__c> listJourneyStep = [Select id, ContactMethodName__c, JourneyStepID__c,JourneyNumber__c, DaysNum__c From Journey_Step__c where 
                                                     JourneyId__c =:selectedJourneyInfo.id];                                               
            //Creating new Map with Journey Step and Acc Mess/ Task Journey Step Id
            Map<Decimal, Journey_Step__c> jnyStepToNumberMap = new Map<Decimal, Journey_Step__c>();
            addingJnyStepToJnyStepNumMap(listJourneyStep, jnyStepToNumberMap);

            AssertTaskWrapper assertTaskWrap = new AssertTaskWrapper();
            assertTaskWrap.jnyStepToNumberMap = jnyStepToNumberMap;
            assertTaskWrap.oppDetailsAfter = oppDetailsAfter;
            assertTaskWrap.opportunityContactId = opportunityContactId;
            assertTaskWrap.selectedJourneyInfo = selectedJourneyInfo;
            assertTask(assertTaskWrap, taskRecords);
            
            List<AccountMessage__c> accMesRecords = [Select Id, TransmissionDate__c, name, Account__c,JourneyID__c,OpportunityId__c,BusinessLineCode__c,
                                                     JourneyStepID__c, JourneyNumber__c, Status__c, CategoryName__c, JourneyFundingID__c,
                                                     CreatorRoleCode__c, CustomDemographicsID__c,AssociateID__c
                                                     from AccountMessage__c where Account__c = : oppDetailsAfter.Accountid];
            List<User> agentAssociateId = [Select id, Servicing_Agent_Associate_ID__c from User where id =: oppDetailsAfter.Ownerid Limit 1];                                                                              
            system.AssertEquals(1, accMesRecords.size(), 'Unexpected Account Messages Record size');
            //Verifying Account message data with Journey and Journey Step 
            for(AccountMessage__c createAccMessage :accMesRecords){
                system.AssertEquals(oppdetailsAfter.id, createAccMessage.OpportunityId__c,'Unexpected Account Message Opportunity Id');
                system.AssertEquals((jnyStepToNumberMap.get(createAccMessage.JourneyStepID__c)).JourneyStepID__c, createAccMessage.JourneyStepID__c,'Unexpected Account Message Journey StepId');
                system.AssertEquals((jnyStepToNumberMap.get(createAccMessage.JourneyStepID__c)).JourneyNumber__c, createAccMessage.JourneyNumber__c,'Unexpected Account Message Journey Number');
                system.AssertEquals(oppDetailsAfter.Accountid, createAccMessage.Account__c, 'Unexpected Account Id');
                system.AssertEquals('Scheduled', createAccMessage.Status__c, 'Unexpected Account Message Status');
                system.AssertEquals(selectedJourneyInfo.CategoryName__c, createAccMessage.CategoryName__c, 'Unexpected Account Message CategoryName');
                system.AssertEquals(selectedJourneyInfo.JourneyFundingID__c, createAccMessage.JourneyFundingID__c, 'Unexpected Account Message Journey FundingId');
                system.AssertEquals(selectedJourneyInfo.CreatorRoleCode__c, createAccMessage.CreatorRoleCode__c, 'Unexpected Account Message Creator RoleCode');
                system.AssertEquals(selectedJourneyInfo.CustomDemographicsInd__c, createAccMessage.CustomDemographicsID__c, 'Unexpected Account Message CustomDemographicsId');
                system.AssertEquals(agentAssociateId[0].Servicing_Agent_Associate_ID__c, createAccMessage.AssociateID__c, 'Unexpected Account Message AssociateId');
                system.AssertEquals(selectedJourneyInfo.Journey_External_ID__c, createAccMessage.JourneyID__c,'Unexpected Account Message JourneyId');
                system.AssertEquals(oppDetailsAfter.LOB__c, createAccMessage.BusinessLineCode__c,'Unexpected Account Message LOB');
                system.AssertEquals(oppDetailsAfter.Account.FirstName, createAccMessage.name,'Account Message name did not match');
                system.AssertEquals(oppDetailsAfter.Journey_Start_Date__c.AddDays((jnyStepToNumberMap.get(createAccMessage.JourneyStepID__c)).DaysNum__c.intValue()), createAccMessage.TransmissionDate__c, 'Unexpected Account Message TransmissionDate');            
            }                                
        }                  
    }
    
    /**
     * @description addingJnyStepToJnyStepNumMap
     * @param listJourneyStep 
     * @param jnyStepToNumberMap 
     */
    private static void addingJnyStepToJnyStepNumMap(List<Journey_Step__c> listJourneyStep, Map<Decimal, Journey_Step__c> jnyStepToNumberMap){
        for (Journey_Step__c jnyStep : listJourneyStep) {
            jnyStepToNumberMap.put(jnyStep.JourneyStepID__c, jnyStep);                          
        }
    }

    private class AssertTaskWrapper{
        Map<Decimal, Journey_Step__c> jnyStepToNumberMap;
        Opportunity oppDetailsAfter;
        Id opportunityContactId;
        Journey__c selectedJourneyInfo;
    }
    private static void assertTask(AssertTaskWrapper taskWrap, List<Task> taskRecords){
        for(Task createTask :taskRecords){
            //      system.AssertEquals(taskWrap.oppDetailsAfter.Assigned_To__c, createTask.AssignedTo__c, 'Unexpected Task AssignedTo');
                  system.AssertEquals(taskWrap.opportunityContactId, createTask.whoid, 'Task WhoId did not match with Opportunity Contact Id');
                  system.AssertEquals(taskWrap.oppDetailsAfter.ownerid, createTask.ownerid, 'Task Owner Id did not match');
                  system.AssertEquals(JOURNEYTASK_DESCRIPTION, createTask.Description, 'Unexpected Task Description');
                  system.AssertEquals(taskWrap.selectedJourneyInfo.id, createTask.JourneyId__c, 'Unexpected Task Journey Id');
                  system.AssertEquals(TASK_PRIORITY_NONE, createTask.Priority, 'Unexpected Task Priority Id');
                  system.AssertEquals(taskWrap.oppDetailsAfter.id, createTask.Whatid, 'Task What Id did not match with Opportunity Id');
                  system.AssertEquals(TASK_STATUS_NOTSTARTED, createTask.Status, 'Unexpected Task Status');
                  system.AssertEquals(taskWrap.jnyStepToNumberMap.get(createTask.StepNumber__c).ContactMethodName__c, createTask.Subject, 'Task Subject did not match with the Journey Contactmethodname');
                  system.AssertEquals('Task', createTask.RecordType.DeveloperName, 'Unexpected Task Recordtype');
                  system.AssertEquals(TASK_APPCODE_SFDCILPJOURNEY, createTask.AppCode__c, 'Unexpected Task Appcode');
                  system.AssertEquals(taskWrap.selectedJourneyInfo.JourneyName__c, createTask.JourneyName__c, 'Unexpected Task Journey Name');
                  system.AssertEquals(taskWrap.oppDetailsAfter.LOB__c, createTask.LineofBusiness__c,'Unexpected Task LOB');
                  system.AssertEquals(taskWrap.jnyStepToNumberMap.get(createTask.StepNumber__c).JourneyStepID__c, createTask.StepNumber__c, 'Unexpected Task Journey StepNumber');
                  system.AssertEquals(TASK_CATEGORY_JOURNEY, createTask.TaskCategory__c, 'Unexpected Task Category');
                  system.AssertEquals(TASK_TASKTYPE_SALES, createTask.Task_Type__c, 'Unexpected Task Type');
                  system.AssertEquals(taskWrap.oppDetailsAfter.Journey_Start_Date__c.AddDays(taskWrap.jnyStepToNumberMap.get(createTask.StepNumber__c).DaysNum__c.intValue()), createTask.ActivityDate, 'Unexpected Task Activity date');
              }
    } 

    /**
    * @description Testing Start Journey flow on Opportunity as an Atm User on ILP Claimed Recortype,
                Journey fields on opportunity should get updated and 
    * @name- testIlpClaimedSelectJourneyByAtm
    */
    @isTest
    private static void testIlpClaimedSelectJourneyByAtm() {
       agentUser = retriveAgentUserMethod();  
         atmUser = retriveATMUserMethod();
         Account testAccount  = retrieveAccountDataMethod(atmUser.id,agentUser.id);
        System.runAs(atmUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Assigned', optyRecordTypeId);
            insert opty;
           
            Opportunity oppDetailsBefore = [select id,  Journey_Name__c, Journey_ID__c, Journey_Description__c, Journey_Start_Date__c,
                                            RecordType.DeveloperName from Opportunity where id =: Opty.id LIMIT 1];            
            system.AssertEquals(null, oppDetailsBefore.Journey_Name__c,'Opportunity JourneyName is not null');
            system.AssertEquals(null, oppDetailsBefore.Journey_ID__c,'Opportunity JourneyId is not null');
            system.AssertEquals(null, oppDetailsBefore.Journey_Description__c,'Opportunity Journey Description is not null');
            system.AssertEquals(null, oppDetailsBefore.Journey_Start_Date__c,'Opportunity Journey StartDate is not null');
            system.AssertEquals('Opportunity_Management', oppDetailsBefore.RecordType.DeveloperName,'Unexpected Opportunity Recordtype');
            Test.startTest();
            Journey__c selectedJourneyInfo = createJourney();
            //Calling Start Journey on opportunity Apex Class with required parameter          
            AP_Opportunity_StartJourney.oppStartJourney(Opty.Id, selectedJourneyInfo.Id);
            Test.stopTest();
            
            Opportunity oppDetailsAfter = [select id,  Journey_Name__c, Journey_ID__c, Journey_Description__c, Journey_Start_Date__c,
                                           RecordType.DeveloperName from Opportunity where id =: Opty.id LIMIT 1];            
            //Verifying Opportunity Journey fields data with Selected Journey data                                
            system.AssertEquals(selectedJourneyInfo.JourneyName__c, oppDetailsAfter.Journey_Name__c, 'Unexpected Opportunity Journey Name');
            system.AssertEquals(selectedJourneyInfo.Journey_External_ID__c, oppDetailsAfter.Journey_ID__c, 'Unexpected Opportunity Journey Id');
            system.AssertEquals(selectedJourneyInfo.JourneyDescription__c, oppDetailsAfter.Journey_Description__c, 'Unexpected Opportunity Journey Description');
            system.AssertEquals(calculateOppStartDate(), oppDetailsAfter.Journey_Start_Date__c, 'Unexpected Opportunity Journey Start Date');
        }
    }
       
    /**
    * @description Testing Start Journey flow on Opportunity as an ATM user on Default Opportunity RecordType,
               Journey fields on opportunity should get updated, Corresponding Journey Tasks should be created when ContactMethodName__c='Appointment' & 'Others' and if "Script__c" field is not blank
               in JourneyStep__c then Task_Description value should be script value, and if "Script__c" field is blank then use default description value and
    * @name - testSelJrnyByAtmScriptToComment
    */     
    @isTest   
    private static void testSelJrnyByAtmScriptToComment() {
        agentUser = retriveAgentUserMethod();  
         atmUser = retriveATMUserMethod();
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings(); 
        Account testAccount  = retrieveAccountDataMethod(atmUser.id,agentUser.id);
        System.runAs(atmUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Assigned', optyRecordTypeId);
            insert opty;
            opty.LOB__c= 'Fire';
            opty.Product__c = 'Business Insurance';
            update opty;
            List<Journey__c> journeyList=new List<Journey__c>();
            Journey__c jrnySmall = new Journey__c(JourneyName__c= '2017SmallBusinessfollow-upSMP', Journey_External_ID__c ='12345', BusinessLineCode__c = 'Small Business',
                                                  CategoryName__c = 'prospect customers', JourneyDescription__c='Jrnydescription1', VendorCode__c= 11111, 
                                                  JourneyNumber__c = '1010101', CreatorRoleCode__c = 'C', CustomDemographicsInd__c = false);
            Journey__c jrnyGeneral = new Journey__c(JourneyName__c= '2017FundedAAPKorean', Journey_External_ID__c ='123456', BusinessLineCode__c = 'General',
                                                    CategoryName__c = 'prospect customers',JourneyDescription__c='Jrnydescription2', VendorCode__c= 22222,
                                                    JourneyNumber__c = '2020202', CreatorRoleCode__c = 'C', CustomDemographicsInd__c = false);
            journeyList.add(jrnySmall);
            journeyList.add(jrnyGeneral);
            createJourneyRec(journeyList);
            Journey__c selectedJourneyInfo=[select id, JourneyName__c, Journey_External_ID__c, JourneyDescription__c, Status__c, CategoryName__c, JourneyFundingID__c, BusinessLineCode__c,
                                            CreatorRoleCode__c, CustomDemographicsInd__c from Journey__c where JourneyName__c= '2017SmallBusinessfollow-upSMP' LIMIT 1];             
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            
            Journey_Step__c jrnystep1 = new Journey_Step__c(JourneyID__c = selectedJourneyInfo.id , JourneyStepID__c = 1, CategoryName__c = 'prospect customers', BusinessLineCode__c = 'Small business',
                                                            Script__c = 'Send an email', VendorCode__c= 11111, JourneyNumber__c = '1', DaysNum__c = 35, ContactMethodName__c = 'Appointment'); 
            Journey_Step__c jrnystep2 = new Journey_Step__c(JourneyID__c = selectedJourneyInfo.id , JourneyStepID__c = 2, CategoryName__c = 'prospect customers', BusinessLineCode__c = 'Small business',
                                                            Script__c = '', VendorCode__c= 2222, JourneyNumber__c = '2', DaysNum__c = 55, ContactMethodName__c = 'Other');
            jnystepsList.add(jrnystep1);
            jnystepsList.add(jrnystep2);
            insert jnystepsList;                       
            Test.startTest();                     
            //Calling Start Journey on opportunity Apex Class with required parameter        
            AP_Opportunity_StartJourney.oppStartJourney(Opty.Id, selectedJourneyInfo.Id);                                
            Test.stopTest();
            
            Opportunity oppDetailsAfter = [select id, Accountid, Account.FirstName, Journey_Name__c, Journey_ID__c, Assigned_To__c, Journey_Description__c,
                                           Journey_Start_Date__c, RecordType.DeveloperName, ownerid, LOB__c 
                                           from Opportunity where id =: Opty.id LIMIT 1];                         
            List<Task> taskRecords =  [Select Id, whoid, ActivityDate, ownerid, Description, JourneyId__c, Priority, Whatid, Status,
                                       Subject, AppCode__c, JourneyName__c, LineofBusiness__c, StepNumber__c, 
                                       TaskCategory__c, Task_Type__c,RecordType.DeveloperName, AssignedTo__c from Task 
                                       where JourneyId__c = : selectedJourneyInfo.id AND Whatid = :Opty.id];
            system.AssertEquals(2, taskRecords.size(), 'Unexpected Task Record Size');
            //Verifying Journey Task data with Journey and Journey Step
            Id opportunityContactId = [Select id from contact where accountid =:oppDetailsAfter.Accountid Limit 1].id;
            List<Journey_Step__c> listJourneyStep = [Select id, ContactMethodName__c, JourneyStepID__c,JourneyNumber__c, DaysNum__c, Script__c From Journey_Step__c where 
                                                     JourneyId__c =:selectedJourneyInfo.id];                                                         
            //Creating new Map with Journey Step and Acc Mess/ Task Journey Step Id
            Map<Decimal, Journey_Step__c> jnyStepToNumberMap = new Map<Decimal, Journey_Step__c>();
            for (Journey_Step__c jnyStep : listJourneyStep) {
                jnyStepToNumberMap.put(jnyStep.JourneyStepID__c, jnyStep);                           
            }
            for(Task createTask :taskRecords){
                system.AssertEquals(oppDetailsAfter.Assigned_To__c, createTask.AssignedTo__c, 'Unexpected Task AssignedTo');
                system.AssertEquals(opportunityContactId, createTask.whoid, 'Task WhoId did not match with Opportunity Contact Id');
                system.AssertEquals(oppDetailsAfter.ownerid, createTask.ownerid, 'Task Owner Id did not match');
                if ((jnyStepToNumberMap.get(createTask.StepNumber__c).Script__c) != null) {
                    system.AssertEquals(jnyStepToNumberMap.get(createTask.StepNumber__c).Script__c, createTask.Description, 'Unexpected Task Description');}
                else { system.AssertEquals(JOURNEYTASK_DESCRIPTION, createTask.Description, 'Unexpected Task Description');}
                system.AssertEquals(selectedJourneyInfo.id, createTask.JourneyId__c, 'Unexpected Task Journey Id');
                system.AssertEquals(TASK_PRIORITY_NONE, createTask.Priority, 'Unexpected Task Priority Id');
                system.AssertEquals(oppDetailsAfter.id, createTask.Whatid, 'Task What Id did not match');
                system.AssertEquals(TASK_STATUS_NOTSTARTED, createTask.Status, 'Unexpected Task Status');
                system.AssertEquals(jnyStepToNumberMap.get(createTask.StepNumber__c).ContactMethodName__c, createTask.Subject, 'Task Subject did not match with the Journey Contactmethodname');
                system.AssertEquals('Task', createTask.RecordType.DeveloperName, 'Unexpected Task Recordtype');
                system.AssertEquals(TASK_APPCODE_SFDCILPJOURNEY, createTask.AppCode__c, 'Unexpected Task Appcode');
                system.AssertEquals(selectedJourneyInfo.JourneyName__c, createTask.JourneyName__c, 'Unexpected Task Journey Name');
                system.AssertEquals(oppDetailsAfter.LOB__c, createTask.LineofBusiness__c,'Unexpected Task LOB');
                system.AssertEquals(jnyStepToNumberMap.get(createTask.StepNumber__c).JourneyStepID__c, createTask.StepNumber__c, 'Unexpected Task Journey StepNumber');
                system.AssertEquals(TASK_CATEGORY_JOURNEY, createTask.TaskCategory__c, 'Unexpected Task Category');
                system.AssertEquals(TASK_TASKTYPE_SALES, createTask.Task_Type__c, 'Unexpected Task Type');
                system.AssertEquals(oppDetailsAfter.Journey_Start_Date__c.AddDays(jnyStepToNumberMap.get(createTask.StepNumber__c).DaysNum__c.intValue()), createTask.ActivityDate, 'Unexpected Task Activity date');
            }
        }
    }
    
    /**
    * @description Helper method to calculate Journey Start Date. If Journey is started on any day before Saturday 12PM , Start date shoud be current week Sunday.
    *           If after Saturday 12 PM, Start date should be next week Sunday 
    * @name - calculateOppStartDate
    * @return toBeUpdatedDate -Date - Opportunity - Journey Start Date
    */
    private static Date calculateOppStartDate() {
        
        Integer sunday = 7;
        Integer saturday = 6;
        Integer nextSunday = 14;
        Integer hourOfDayTwelve = 12;
        DateTime currentDate = DateTime.now();
        DateTime updateddate;
        Integer dayOfWeek = Integer.valueOf(currentDate.format('u'));
        Integer hourOfDay = Integer.valueOf(currentDate.hour());
        
        if(dayOfWeek < saturday || (dayOfWeek == saturday && (hourOfDay < hourOfDayTwelve))) {
            updateddate = currentDate.addDays(sunday - dayOfWeek);   //current week
        }
        else {
            updateddate = currentDate.addDays(nextSunday - dayOfWeek); //current week
        }
        Date toBeUpdatedDate = updateddate.date();
        return toBeUpdatedDate;            
    }   
}