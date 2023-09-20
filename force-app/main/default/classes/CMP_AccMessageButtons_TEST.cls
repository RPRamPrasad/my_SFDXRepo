/**
Author Team ClubCar
Name - CMP_AccMessageButtons_TEST
@description Test class written for CMP_AccMessageButtons 
========================================================================================================================================+
History
-------
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                12/28/2018              Initial Development
2.0             Team ClubCar                01/17/2019              Added new method for test data retrieval through Account id
3.0             Team ClubCar                03/06/2019              Test method for Production Defect Fix
4.0             Team Incognito   			08/24/2022              Code Refactoring
******************************************************************************************************************************************/
@isTest()
public with sharing class CMP_AccMessageButtons_TEST {
    
    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static User systemUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static UserRole agentTeamMemberUserRole;    
    private static String sObjectOpportunity = 'Opportunity';
    private static String sObjectAccount = 'Account';
    private static String jsonString = null;
    private static Map<String, Schema.Recordtypeinfo> opportunityRecordTypeMap = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName();
    private class AccMessageButtonsData {
        public String sObjectType;
        public String servicingAgentExternalId;
        public Id oppOrAccId;      
    }
    
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
        sysAdminuser.Servicing_Agent_Associate_ID__c = '1234';
        sysAdminuser.UserExternalID__c = '1234_1234';
        sysAdminuser.State_Agent_Code__c = '13-3050';
        insert sysAdminuser;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        
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
            User testAgentUser1 = new User(Alias='Alia',LastName='opportunityProxy',Username='TestAgtUserForOppTst11@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test_123test',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.State_Agent_Code__c = '13-3050';
            agentUser.userRoleId= agentStandardUserRole.id;
            Database.insert(agentUser);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        }
    }
    
    //To get the Recordtype of opportunity
    
    //method to build Account record with the given parameter value
    private static Account buildAccountRecord(String paramClientIdentifier) {
        Account act = new Account(FirstName = 'rrrrr', LastName = 'tttttttt', ClientIdentifier__c = paramClientIdentifier, Edit_In_VFP__c = true);
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
   /** @Refactor
    * @method- retriveATMUserMethod
    * @date modified - 24/08/2022
    * @description -  Return Agent User data, method to avoid deplicate code
    * @return - User
    */
 
    public static User  retriveAgentUserMethod() {        
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];
        agentUser= queryAgent;
        System.runAs(agentUser) {
            Account act = buildAccountRecord('1213121');
            insert act;            
        }
        
        return agentUser;
    }
    /**  @Refactor
    * @method- retrieveAccountDataMethod
    * @date modified - 23/08/2022
    * @description - Return Account data, method to avoid deplicate code
    * @param agentid
    * @return - Account
    */
      
     public static Account  retrieveAccountDataMethod(id agentid) { 
        Account  testAccount = [select id, ClientIdentifier__c, ownerId from Account where CreatedbyId =:agentid Limit 1];    
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentid);
        insert newAgentRole;
         return testAccount;
     }
    
    //Method to test retrieval of AccountId, ClientIdentifier, Agentid and ProfileValidty details through AccMessageQueryWrapper object based on passed opportunityid
    @isTest
    private static void testRetrieveDataForCmpWithOppId() {        
        /* @Refactor
         * added 2 method insted of existing code snippet ***
         */
        user agent_User =  retriveAgentUserMethod();
        Account testAccount = retrieveAccountDataMethod(agent_User.id);
        System.runAs(agent_User) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Assigned', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            insert opty;
            AccMessageButtonsData accMessageData = new AccMessageButtonsData();
            accMessageData.oppOrAccId = opty.id;
            accMessageData.sObjectType = sObjectOpportunity;
            //accMessageData.servicingAgentExternalId = agent_User.Servicing_Agent_External_ID__c;            
            jsonString = JSON.serialize(accMessageData);            
            Test.startTest();
            CMP_AccMessageButtons.AccMessageButtonsWrapper buttonDataWrapper = CMP_AccMessageButtons.getLaunchButtonData(sObjectOpportunity, opty.id);            
           //System.assertEquals(true, buttonDataWrapper.isValidProfile,'Not a valid Profile');
            System.assertEquals(testAccount.Id, buttonDataWrapper.sfAccountId,'Account Id did not match');
            System.assertEquals('29133050', buttonDataWrapper.agentId,'Agent Id did not match');
            System.assertEquals(testAccount.clientIdentifier__c, buttonDataWrapper.clientIdentifier,'Client Identifier did not match');
            System.assertEquals(agent_User.Alias,buttonDataWrapper.agentAlias,'Agent Alias did not match');
            Test.stopTest();
        }                  
    }
    
        
    //Method to test retrieval of AccountId, ClientIdentifier, Agentid and ProfileValidty details through AccMessageQueryWrapper object based on passed AccountId
    @isTest
    private static void testRetrieveDataForCmpWithAccId() {        
        /* @Refactor
         * added 2 method insted of existing code snippet ***
         */
        user agentUser =  retriveAgentUserMethod();
        Account testAccount = retrieveAccountDataMethod(agentUser.id);
        System.runAs(agentUser) {
            AccMessageButtonsData accMessageData = new AccMessageButtonsData();
            accMessageData.oppOrAccId = testAccount.id;
            accMessageData.sObjectType = sObjectAccount;
            //accMessageData.servicingAgentExternalId = agentUser.Servicing_Agent_External_ID__c;            
			jsonString = JSON.serialize(accMessageData);
            Test.startTest();
            CMP_AccMessageButtons.AccMessageButtonsWrapper buttonDataWrapper = CMP_AccMessageButtons.getLaunchButtonData(sObjectAccount, testAccount.id);           
            //System.assertEquals(true, buttonDataWrapper.isValidProfile,'Not a valid Profile');
            System.assertEquals(testAccount.Id, buttonDataWrapper.sfAccountId,'Account Id did not match');
            System.assertEquals('29133050', buttonDataWrapper.agentId,'Agent Id did not match');
            System.assertEquals(testAccount.ClientIdentifier__c, buttonDataWrapper.clientIdentifier,'Client Identifier did not match');
            System.assertEquals(agentUser.Alias,buttonDataWrapper.agentAlias,'Agent Alias did not match');
            Test.stopTest();
        }                  
    }
    
    //Method to test Exception
    @isTest
    private static void testRetrieveOpportunityException() {        
        /* @Refactor
         * added a method insted of existing code snippet ***
         */
        User agentUser =  retriveAgentUserMethod();
        System.runAs(agentUser) {
			Journey__c jny = new Journey__c(JourneyName__c='Jny1', JourneyDescription__c = 'JnyDescription');
            insert jny;
            AccMessageButtonsData accMessageData = new AccMessageButtonsData();
            accMessageData.oppOrAccId = jny.id;
            accMessageData.sObjectType = sObjectAccount;
            //accMessageData.servicingAgentExternalId = agentUser.Servicing_Agent_External_ID__c;            
			jsonString = JSON.serialize(accMessageData);
            Test.startTest();                     
            CMP_AccMessageButtons.getLaunchButtonData(sObjectAccount, jny.id);           
            List<ExceptionLog__c> exceptionLog = [SELECT Id from ExceptionLog__c where class__c = 'CMP_AccMessageButtons' LIMIT 1];    
            System.assertEquals(1,exceptionLog.size(),'Unexpected Exception Log Size');
            Test.stopTest();            
        }
    }
    
    //Method to test if ServicingAgentExternalId is Valid
    @isTest
    private static void testInValidServicingAgentExternalId() {
        /* @Refactor
         * added 2 method insted of existing code snippet ***
         */
        user agentUser =  retriveAgentUserMethod();
        Account testAccount = retrieveAccountDataMethod(agentUser.id);
        System.runAs(agentUser) {
            AccMessageButtonsData accMessageData = new AccMessageButtonsData();
            accMessageData.oppOrAccId = testAccount.id;
            accMessageData.sObjectType = sObjectAccount;
            //accMessageData.servicingAgentExternalId = 'DLRT71YS000_DLRT71YS000.12';            
            jsonString = JSON.serialize(accMessageData);
            Test.startTest();
            try{
                CMP_AccMessageButtons.getLaunchButtonData(sObjectAccount, testAccount.id);
            }
            catch (InvalidParameterValueException ex) {
                System.assertEquals('servicingAgentExternalId failed Servicing Agent External Id validation', ex.getMessage(), 'Unexpected Exception Message');
            }
            Test.stopTest();
        }
    }
}