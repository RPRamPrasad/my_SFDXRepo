/****************************************************************************************
Name: CMP_CaseStartStopJourney_TEST
@description Test class written for code coverage for CMP_CaseStartStopJourney class
========================================================================================================================================+
History
-------
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                03/12/2019              Initial Development
2.0             Team ClubCar                06/14/2019              Removed references to Task - Journey recordtype check
3.0             Team ClubCar                05/14/2020              Added @TestSetup on setup() method
4.0				Team Incognito				08/26/2022				Refactor and added code coverage
******************************************************************************************************************************************/
@IsTest(SeeAllData = false)
public with sharing class CMP_CaseStartStopJourney_TEST {
    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static User systemUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static UserRole agentTeamMemberUserRole; 
    private static final String TASK_SUBJECT_CALL = 'Call';    
    
    /**
* @method Setup method used for building test data (must be called at beginning of test)
* @description Setup method used for building test data
* @name  setup
*/    
    @TestSetup
    private static void setup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
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
            atmUser = new User(alias = 'Alias', email='remCmpMemAgent1@statefarm.com.bad',
                               Associate_ID__c='124test', UserExternalID__c= '124test', Servicing_Agent_Associate_ID__c ='123test',
                               emailencodingkey='UTF-8', lastname='CmpMemProx', languagelocalekey='en_US', 
                               localesidkey='en_US', timezonesidkey='Europe/London', username= 'TestAtmUserForOppTst11@statefarm.com',userRoleId=agentTeamMemberUserRole.id);
            atmUser.ProfileId = UTIL_ProfileId_TEST.getATMProfileId();
            Database.insert(atmUser);
        }
    }
    
    /**
* @method method to build Account record with the given parameter value
* @description build Account record with the given parameter value
* @param  paramClientIdentifier - ClientIdentifier passed to the method
* @return Returns Account Object
*/
    private static Account buildAccountRecord(String paramClientIdentifier) {
        Account act = new Account(FirstName = 'rrrrr', LastName = 'tttttttt', ClientIdentifier__c = paramClientIdentifier,shippingState = 'IL');
        return act;
    }
    
    /**
* @method method to build journey record with the given parameter value
* @description build journey record with the given parameter value
* @param  sampleBuild
* @return Returns Journey Record
*/
    private static Journey__c buildJourneyRecord(Journey__c sampleBuild) {
        Journey__c jny = new Journey__c(JourneyName__c=sampleBuild.JourneyName__c, Journey_External_ID__c =sampleBuild.Journey_External_ID__c,BusinessLineCode__c = 'Auto',CategoryName__c = 'Cases',
                                        JourneyDescription__c='Jnydescription', VendorCode__c= 0, JourneyNumber__c = sampleBuild.JourneyNumber__c, 
                                        CreatorRoleCode__c = 'C', CustomDemographicsInd__c = true, JourneyFundingID__c = sampleBuild.JourneyFundingID__c,StateCode__c='13',
                                        EffectiveDate__c = date.today(), ExpirationDate__c = date.today());
        return jny;
    }
    
    /**
* @method method to build journey steps record with the given parameter value
* @description build journey steps record with the given parameter value
* @param  sampleBuild
* @return Returns JourneyStep Record
*/
    private static Journey_Step__c buildJourneyStepsRecord(Journey_Step__c sampleBuild) {
        Journey_Step__c jnyStep = new Journey_Step__c(JourneyID__c = sampleBuild.JourneyID__c , JourneyStepID__c = sampleBuild.JourneyStepID__c, VendorCode__c= 0, JourneyNumber__c = sampleBuild.JourneyNumber__c,
                                                      DaysNum__c = sampleBuild.DaysNum__c, ContactMethodName__c = TASK_SUBJECT_CALL , LetterName__c = 'Send Email', script__c =  'promotion email');
        return jnyStep;
    }    
    
    /**
* @method method to create journey with the given journeyList parameter value
* @description create journey with the given journeyList parameter value
* @param  journeys List
*/
    private static void createJourneyRec(List<Journey__c> journeys) {
        if(journeys!= null && !journeys.isEmpty()) {                
            insert journeys;
        }
    }
    
    /* @Refactor
    * @method- retrieveAgentUserMethod
    * @date modified - 26/08/2022
    * @description -Return agent Users data, method to avoid deplicate code
    * @return - User
    */
	private static User  retrieveAgentUserMethod() { 
        agentUser = [SELECT Id From User Where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];
        Account testAccount;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            testAccount = buildAccountRecord('1213121');
            insert testAccount;
        }
        
        return agentUser;
      }
    
     
    /* @Refactor
    * @method- retrieveAccountDataMethod
    * @date modified - 26/08/2022
    * @description - To return cAcount data, method to avoid deplicate code
    * @return - Account
    */
     private static Account  retrieveAccountDataMethod( string agentUserId) {
         
       Account  testAccount = [select id,personContactId from Account where CreatedbyId =:agentUserId Limit 1];
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUserId);
        insert newAgentRole;
         
         return testAccount;
     }
    /* @Refactor
    * @method- passJourney
    * @date modified - 26/08/2022
    * @description - To return Journey__c data, method to avoid deplicate code
    * @return - Journey__c
    */
    private static Journey__c passJourney() {
        
        List<Journey__c> journeyList=new List<Journey__c>();
            Journey__c jny = new Journey__c();
            jny.JourneyName__c = 'Jny1';
            jny.JourneyNumber__c = '1';
            jny.Journey_External_ID__c = '101010';
            jny.JourneyFundingID__c= '111111';
            journeyList.add(buildJourneyRecord(jny));
            Journey__c jnyInfo = new Journey__c();
            jnyInfo.JourneyName__c = 'Jny2';
            jnyInfo.JourneyNumber__c = '2';
            jnyInfo.Journey_External_ID__c = '202020';
            jnyInfo.JourneyFundingID__c= '222222';
            journeyList.add(buildJourneyRecord(jnyInfo));
            createJourneyRec(journeyList);
            Journey__c selectedJourneyInfo=[select id, JourneyName__c, Journey_External_ID__c, JourneyDescription__c, Status__c, CategoryName__c, JourneyFundingID__c, 
                                            CreatorRoleCode__c, CustomDemographicsInd__c from Journey__c LIMIT 1];             
           return selectedJourneyInfo;
    }
         
    
    /**
* @method method to verify retrieveJourneyDetails method returns applicable Journey list
* @description verify retrieveJourneyDetails method returns applicable Journey list
*/
    @isTest
    private static void testCaseStartJourneysWithValidProfile() {
        agentUser = retrieveAgentUserMethod();
        Account  testAccount = retrieveAccountDataMethod(agentUser.id);        
        System.runAs(agentUser){
            Case testCase1 = new Case(Description = 'Cases Received',Case_Originator__c = 'Agent Office',contactId = testAccount.personcontactId,AccountId = testAccount.Id);
            insert testCase1;
           List<Journey__c> journeyList=new List<Journey__c>();
            Journey__c jny = new Journey__c();
            jny.JourneyName__c = 'Jny1';
            jny.JourneyNumber__c = '1';
            jny.Journey_External_ID__c = '101010';
            jny.JourneyFundingID__c= '111111';
            journeyList.add(buildJourneyRecord(jny));
            Journey__c jnyInfo = new Journey__c();
            jnyInfo.JourneyName__c = 'Jny2';
            jnyInfo.JourneyNumber__c = '2';
            jnyInfo.Journey_External_ID__c = '202020';
            jnyInfo.JourneyFundingID__c= '222222';
            journeyList.add(buildJourneyRecord(jnyInfo));
            createJourneyRec(journeyList);
            Journey__c selectedJourneyInfo=[select id, JourneyName__c, Journey_External_ID__c, JourneyDescription__c, Status__c, CategoryName__c, JourneyFundingID__c, 
                                            CreatorRoleCode__c, CustomDemographicsInd__c from Journey__c LIMIT 1];             
            
            lstJourney(selectedJourneyInfo);
            Test.startTest();
            CMP_CaseStartStopJourney.CaseStartStopJourneyWrapper caseWrapper  = CMP_CaseStartStopJourney.retrieveJourneyDetails(testCase1.id);             
            System.AssertEquals(journeyList.size(), caseWrapper.journeyList.size(),'Case Journey List size did not match');
            System.AssertEquals(false, caseWrapper.exceptionOccured,'Case exceptionOccured  is not false');
            System.AssertEquals(true, caseWrapper.showJourneySelection,'Case showJourneySelection is not true');
            System.AssertEquals(null, caseWrapper.errorMessage,'Case errorMessage is not null');
            Test.stopTest();            
        }
    }
    
    /**
* @method method to verify retrieveJourneyDetails method returns empty Journey List
* @description verify retrieveJourneyDetails method returns empty Journey List
*/
    @isTest
    private static void testStartStopCaseJourneyWithoutJourneys() {
         agentUser = retrieveAgentUserMethod();
        Account  testAccount = retrieveAccountDataMethod(agentUser.id);
        System.runAs(agentUser){
            Case testCase = new Case(Description = 'Cases Received',Case_Originator__c = 'Agent Office',contactId = testAccount.personcontactId,AccountId = testAccount.Id);
            insert testCase;
            Test.startTest();
            CMP_CaseStartStopJourney.CaseStartStopJourneyWrapper caseWrapper  = CMP_CaseStartStopJourney.retrieveJourneyDetails(testCase.id);
            system.AssertEquals(false, caseWrapper.exceptionOccured,'Case exceptionOccured did not match');
            system.AssertEquals(false, caseWrapper.showJourneySelection,'Case showJourneySelection did not match');
            system.AssertEquals('NOJOURNEYS', caseWrapper.errorMessage,'Case errorMessage did not match');
            Test.stopTest();
        }
    }
    
    /**
* @method method to verify exception scenario for retrieveJourneyDetails method
* @description verify exception scenario for retrieveJourneyDetails method
*/
    @isTest
    private static void testStartStopCaseJourneyWithException() {
        agentUser = [SELECT Id From User Where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];
        List<Journey__c> journeyList=new List<Journey__c>();
        Journey__c selectedJourneyInfo = passJourney();
        lstJourney(selectedJourneyInfo);
        Account act = buildAccountRecord('1213121');
        insert act;            
        case newCase= new Case(Status = 'New', Case_Originator__c='Agent Office', AgentAssociateId__c = null,AccountId = act.Id);
        insert newCase;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            Test.startTest();
            CMP_CaseStartStopJourney.CaseStartStopJourneyWrapper caseWrapper  = CMP_CaseStartStopJourney.retrieveJourneyDetails(newCase.id);
            system.AssertEquals(true, caseWrapper.exceptionOccured,'Case exceptionOccured did not match');
            system.AssertEquals(false, caseWrapper.showJourneySelection,'Case showJourneySelection did not match');
            system.AssertEquals('EXCEPTIONOCCURRED', caseWrapper.errorMessage,'Case errorMessage did not match');
            system.AssertEquals(null, caseWrapper.journeyList,'Case journeyList is not null');
            system.AssertEquals(null, caseWrapper.jrnyIdAndStepMap,'Case jrnyIdAndStepMap is not null');
            Test.stopTest();
        }
    }   
    
    /**
* @method method to verify applyCaseJourney method updates Case with selected Journey details and creates required Journey Tasks.
* @description verify applyCaseJourney method updates Case with selected Journey details and creates required Journey Tasks.
*/
    @isTest
    private static void testapplyCaseJourenyWithValidProfile() {
        agentUser = retrieveAgentUserMethod();
        Account  testAccount = retrieveAccountDataMethod(agentUser.id);
        System.runAs(agentUser){
            Case testCase1 = new Case(Description = 'Cases Received',Case_Originator__c = 'Agent Office',contactId = testAccount.personcontactId,AccountId = testAccount.Id, Lob__c = 'Auto');
            insert testCase1;
            Journey__c selectedJourneyInfo = passJourney();
            List<Journey_Step__c> jnystepsList = lstJourney(selectedJourneyInfo);
            Test.startTest();
            CMP_CaseStartStopJourney.applyCaseJourneyLWC(testCase1.Id, selectedJourneyInfo.id);
            
            Case caseToVerify = [Select id, JourneyId__c, JourneyName__c, JourneyStartDate__c, JourneyDescription__c from Case where id =:testCase1.id];
            List<Task> createdJrnyTaskList = [Select id, whatid, whoid, subject, Description, AppCode__c, JourneyId__c, Task_Type__c, TaskCategory__c,
                                              RecordType.DeveloperName from Task where JourneyId__c =: selectedJourneyInfo.id AND whatId =:testCase1.id];            
            system.AssertEquals(System.today(), caseToVerify.JourneyStartDate__c,'Journey start date is not matched with the system');
            system.AssertEquals(selectedJourneyInfo.Journey_External_ID__c, caseToVerify.JourneyId__c,'Case Journey External Id didnt match');
            system.AssertEquals(selectedJourneyInfo.JourneyName__c, caseToVerify.JourneyName__c,'Case JourneyName didnt match');
            system.AssertEquals(selectedJourneyInfo.JourneyDescription__c, caseToVerify.JourneyDescription__c,'Case JourneyDescription didnt match');
            system.AssertEquals(jnystepsList.size(), createdJrnyTaskList.size(),'Case jnystepsList size didnt match');
            
            for (Task createdTask : createdJrnyTaskList) {
                System.AssertEquals(testCase1.id, createdTask.WhatId,'Case WhatId did not match');
                System.AssertEquals('Task', createdTask.RecordType.DeveloperName, 'Task DeveloperName did not match');
                System.AssertEquals('Send Email', createdTask.Subject, 'Task Subject did not match');
                System.AssertEquals('promotion email', createdTask.Description, 'Task Description did not match');
                System.AssertEquals('Case Journey', createdTask.AppCode__c, 'Task AppCode did not match');
                System.AssertEquals(selectedJourneyInfo.id, createdTask.JourneyId__c, 'Task JourneyId did not match');
                System.AssertEquals('Service', createdTask.Task_Type__c, 'Task Task_Type__c did not match');
                System.AssertEquals('Journey', createdTask.TaskCategory__c, 'Task TaskCategory__c did not match');
            }
            Test.stopTest();
        }
    }
    
    /**
* @method method to verify applyCaseJourney method exception when Case owner is not valid
* @description verify applyCaseJourney method exception when Case owner is not valid
*/
    @isTest
    private static void testapplyCaseJourenyException() {
        List<User> usrList = [SELECT Id From User Where username IN ('TestAgtUserForOppTst11@statefarm.com', 'systemAdminTest@statefarm.com') ORDER BY Username ASC];
        agentUser = usrList.get(1);
        sysAdminuser = usrList.get(0);
        Account act = buildAccountRecord('1213121');
        insert act;
        Case testCase1 = new Case(Description = 'Cases Received',Case_Originator__c = 'Agent Office',AccountId = act.Id);
        testCase1.OwnerId= sysAdminuser.id;
        insert testCase1;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            Journey__c selectedJourneyInfo = passJourney();
            lstJourney(selectedJourneyInfo);
            Test.startTest();
            CMP_CaseStartStopJourney.applyCaseJourneyLWC(testCase1.Id, selectedJourneyInfo.id);
            List<ExceptionLog__c> exceptionLog = [Select Id,name, class__c, exception_Message__c from ExceptionLog__c where class__c = 'CMP_CaseStartStopJourney' LIMIT 1];
            System.AssertEquals(1,exceptionLog.size(), 'Exception Log Size did not match');
            Test.stopTest();            
        }
    }
    
    /**
* @method method to verify StopCaseJourney method updates Case Journey fields as null and cancels Case Journey Tasks.
* @description verify StopCaseJourney method updates Case Journey fields as null and cancels Case Journey Tasks.
*/
    @isTest
    private static void testStopCaseJourneyWithValidProfile() {
        agentUser = retrieveAgentUserMethod();
        Account  testAccount = retrieveAccountDataMethod(agentUser.id);
        System.runAs(agentUser){
            Case testCase1 = new Case(Description = 'Cases Received',Case_Originator__c = 'Agent Office',contactId = testAccount.personcontactId,AccountId = testAccount.Id, Lob__c = 'Auto');
            insert testCase1;
            Journey__c selectedJourneyInfo = passJourney();
            lstJourney(selectedJourneyInfo);
            Test.startTest();
            CMP_CaseStartStopJourney.stopCaseJourney(testCase1.Id);
            Case caseToVerify = [Select id, JourneyId__c, JourneyName__c, JourneyStartDate__c, JourneyDescription__c from Case where id =:testCase1.id];
            system.AssertEquals(null, caseToVerify.JourneyStartDate__c,'Case JourneyStartDate is not null');
            system.AssertEquals(null, caseToVerify.JourneyId__c,'Case JourneyId is not null');
            system.AssertEquals(null, caseToVerify.JourneyName__c,'Case JourneyName is not null');
            system.AssertEquals(null, caseToVerify.JourneyDescription__c,'Case JourneyDescription is not null');
            List<Task> createdJrnyTaskList = [Select id, whatid, JourneyId__c, Status
                                              from Task where JourneyId__c =: selectedJourneyInfo.id AND whatId =:testCase1.id];
            for (Task createdTask : createdJrnyTaskList) {
                System.AssertEquals('Cancelled', createdTask.Status,'Case Task Status is not matched');
            }
            Test.stopTest();
        }
    }
    
    /**
* @method method to verify stopCaseJourney method exception when Case owner is not valid
* @description verify stopCaseJourney method exception when Case owner is not valid
*/
    @isTest
    private static void testStopCaseJourenyException() {
        List<User> usrList = [SELECT Id From User Where username IN ('TestAgtUserForOppTst11@statefarm.com', 'systemAdminTest@statefarm.com') ORDER BY Username ASC];
        agentUser = usrList.get(1);
        sysAdminuser = usrList.get(0);
        Account act = buildAccountRecord('1213121');
        insert act;
        Case testCase1 = new Case(Description = 'Cases Received',Case_Originator__c = 'Agent Office',AccountId = act.Id);
        testCase1.OwnerId= sysAdminuser.id;
        insert testCase1;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            Journey__c selectedJourneyInfo = passJourney();
            lstJourney(selectedJourneyInfo);
            
            Test.startTest();
            CMP_CaseStartStopJourney.stopCaseJourney(testCase1.Id);
            List<ExceptionLog__c> exceptionLog = [Select Id,name, class__c, exception_Message__c from ExceptionLog__c where class__c = 'CMP_CaseStartStopJourney' LIMIT 1];
            System.AssertEquals(1,exceptionLog.size(), 'Exception Log Size did not match');
            Test.stopTest();
        }
    } 
    
    ///new
    /**
	* @method method to verify stopCaseJourney method exception when Case owner is not valid
	* @description verify stopCaseJourney method exception when Case owner is not valid
	*/
      @isTest
      private static void testRetrieveJourneyPreviewData() {
        agentUser = retrieveAgentUserMethod();
        Account  testAccount = retrieveAccountDataMethod(agentUser.id);
        System.runAs(agentUser){
            Case testCase1 = new Case(JourneyName__c = 'Jny1' , Description = 'Cases Received',Case_Originator__c = 'Agent Office',contactId = testAccount.personcontactId,AccountId = testAccount.Id);
            insert testCase1;
            //List<Journey__c> journeyList=new List<Journey__c>();
            Journey__c selectedJourneyInfo = passJourney();
            lstJourney(selectedJourneyInfo);
            
            CMP_CaseStartStopJourney.CaseStartStopJourneySteps wrapperVal = returnWrap();
            Test.startTest();
            List<CMP_CaseStartStopJourney.CaseStartStopJourneySteps> caseWrapper  = CMP_CaseStartStopJourney.retrieveJourneyPreviewData(selectedJourneyInfo.id);             
            caseWrapper.add(wrapperVal);
             Case caseToVerify = [Select id, JourneyId__c, JourneyName__c, JourneyStartDate__c, JourneyDescription__c from Case where id =:testCase1.id];
            //System.AssertEquals(journeyList.size(), wrapperVal.size(),'Case Journey Step List size did not match');
              system.AssertEquals(selectedJourneyInfo.JourneyName__c, caseToVerify.JourneyName__c,'Case JourneyName didnt match');
            Test.stopTest();            
        }
    }
    private static  CMP_CaseStartStopJourney.CaseStartStopJourneySteps returnWrap(){
    	CMP_CaseStartStopJourney.CaseStartStopJourneySteps wrap = new CMP_CaseStartStopJourney.CaseStartStopJourneySteps();
            wrap.calculatedDate = system.today();
        	wrap.description = 'Hai value';
        	wrap.journeyStepId = 2.0;
            wrap.methodName = 'New Mthod';
                
          return wrap;
            }
    /* @Refactor
    * @method- lstJourney
    * @date modified - 26/08/2022
    * @description - To return List<Journey_Step__c> data, method to avoid deplicate code
    * @return - List<Journey_Step__c>
    */
    private static List<Journey_Step__c> lstJourney(Journey__c selectedJourneyInfo) {
        
        List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            Journey_Step__c jnyStep = new Journey_Step__c ();
            jnyStep.JourneyID__c = selectedJourneyInfo.id;
            jnyStep.JourneyStepID__c = 1;
            jnyStep.JourneyNumber__c = '1';
            jnyStep.DaysNum__c = 1;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep));
            Journey_Step__c jny1 = new Journey_Step__c ();
            jny1.JourneyID__c = selectedJourneyInfo.id;
            jny1.JourneyStepID__c = 2;
            jny1.JourneyNumber__c = '2';
            jny1.DaysNum__c = 2;
            jnystepsList.add(buildJourneyStepsRecord(jny1));
            Journey_Step__c jnyStepInfo = new Journey_Step__c ();
            jnyStepInfo.JourneyID__c = selectedJourneyInfo.id;
            jnyStepInfo.JourneyStepID__c = 3;
            jnyStepInfo.JourneyNumber__c = '3';
            jnyStepInfo.DaysNum__c = 3;
            jnystepsList.add(buildJourneyStepsRecord(jnyStepInfo));
            Journey_Step__c jnyStepInfo1 = new Journey_Step__c ();
            jnyStepInfo1.JourneyID__c = selectedJourneyInfo.id;
            jnyStepInfo1.JourneyStepID__c = 3;
            jnyStepInfo1.JourneyNumber__c = '3';
            jnyStepInfo1.DaysNum__c = 3;
            jnystepsList.add(buildJourneyStepsRecord(jnyStepInfo1));
            insert jnystepsList;
        return jnystepsList;
    }
}