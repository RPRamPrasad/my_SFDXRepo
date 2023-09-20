/**
* Author : Team AKITA
* Date Created : 10/15/2019
* Description : Test class for HLPR_LWC_NewOpportunityWorkflow_Test - Apex Class.
* @Version 1.0 
* Copyright © StateFarm
*/

/**
 * @description HLPR_LWC_NewOpportunityWorkflow_Test
 */
@isTest(seeAllData=false)
public with sharing class HLPR_LWC_NewOpportunityWorkflow_Test {
        
        public static String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
        public static String agentTeamMemberProfileId = getProfileId(UTIL_Constants.ATM_PROFILE_NAME);
        public static String proxyProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
        public static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
        public static String noAccessProfileId = getProfileId('1.02 No Access');
        public static final String OPPORTUNITY_ORIGINATOR_DEFAULT = 'Agent/Team member';
        
        //CCC
        public static final String CCC_LICENSED_PROFILE_NAME = '3.00 CCC Licensed';
        public static final String DEFAULT_OPPORTUNITY_RECORD_TYPE_NAME = 'Opportunity Management';
        public static final String OPPORTUNITY_ORIGINATOR = 'Customer Care Center';
        public static final String OPPORTUNITY_STAGENAME = 'Quote In Progress';
        public static final String TILDE = '~';
        public static final String HYPEN = '-';
        public static final String SECONDS_FORMAT= 'ssSSS';
        public static final String SYSTEM_DEFAULT_ACCOUNT_OWNER = 'State Farm';
        public static String cccLicensedProfileId = getProfileId(CCC_LICENSED_PROFILE_NAME);
        
        public static User agentUser;
        public static User adminUser;
        public static User cccLicensedUser;
        public static Account acc;
        
        public static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();
        public static Map<String, Schema.Recordtypeinfo> opportunityRecordTypeMap = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName();
        
        //method to bypass Trigger
        private static void byPassTrigger() {
            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
            objectBasedByPassTrigger.Override_All__c = true;
            insert objectBasedByPassTrigger;
        }
        
        //method to get the ProfileId for the given Profile Name
        private static String getProfileId(String profileName) {
            String profileId = [SELECT Id FROM Profile WHERE name =: profileName LIMIT 1].Id;
            return profileId;
        }
        
        //method to build user with the given parameter value
        private static User buildUser(String paramUserName, String paramProfileId, String paramAssociateId, String paramServicingAgentAssociateId) {
            User testUser = new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
                                      languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
                                      username= paramUserName, profileId = paramProfileId,
                                      Associate_ID__c = paramAssociateId, Servicing_Agent_Associate_ID__c = paramServicingAgentAssociateId,
                                      UserExternalID__c = string.isEmpty(paramAssociateId)?'':paramAssociateId+'_'+paramAssociateId
                                     );
            return testUser;
        }
        
        //method to build userrole with the given parameter value
        private static UserRole buildUserRole(String roleName) {
            UserRole role = new UserRole(name = roleName);
            return role;
        }
        
        //method to build userrole with parentRole with the given parameter value
        private static UserRole buildUserRoleWithParent(String roleName, String parentRole) {
            UserRole role = new UserRole(name = roleName, parentRoleId = parentRole);
            return role;
        }
        
        //method to build Agent Role record with the given parameter value
        private static AgentRole__c buildAgentRoleRecord(String paramAccountId, String paramAgentuser) {
            AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                       Agent__c = paramAgentuser, Customer__c = paramAccountId);
            return agentRole;
        }
        
        //method to build Account Owner custom setting record with the given parameter value
        private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
            AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
            return actOwnerCs;
        }
        
        //method to build Account record with the given parameter value
        private static Account buildAccountRecord(String paramClientIdentifier) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            Account act = new Account(FirstName = 'rrrrr', LastName = 'tttttttt',
                                      RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = paramClientIdentifier);
            return act;
        }
        
        //method to build Agent Context Record with the given parameter value
        private static AgentContext__c buildAgentContextRecord(String paramAccountId, String paramAgntContxtIdentifier, String paramAgntUser) {
            AgentContext__c agentContext = new AgentContext__c(Agent__c = paramAgntUser, AgentContextIdentifier__c = paramAgntContxtIdentifier,
                                                               CCCRepresentative__c = userInfo.getUserId(), Customer__c = paramAccountId);
            return agentContext;
        } 
        
        //Agent Methods
        //method to build Account record with Client First Name, Last Name, and Client Id
        private static Account buildAccountRecord(String firstName, String lastName, String clientId, Id owner) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            Account act = new Account(FirstName = firstName, LastName = lastName, ownerId = owner,
                                      RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = clientId);
            return act;
        }
        
        //method to build Agent Role record with Customer Account Id
        private static AgentRole__c buildAgentRoleRecord(String accountId) {
            AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                       Agent__c = userInfo.getUserId(), Customer__c = accountId);
            
            return agentRole;
        }
        
        // End----
        
        /**
         * @description setUp
         */
        @testSetup
        public static void setUp() {
            
            User adminUser = buildUser('TestAdminUser@statefarm.com.bad', adminProfileId, '', '');
            User agentUser;
            User proxyUser; 
            User systemUser;
            User cccLicensedUser;
            
            System.runAs(adminUser) {
                byPassTrigger();
                
                UserRole agentUserRole = buildUserRole('AgentRole');
                insert agentUserRole;
                
                UserRole proxyUserRole = buildUserRoleWithParent('ProxyRole', agentUserRole.id);
                insert proxyUserRole;
                
                agentUser = buildUser('TestAgentUser@statefarm.com.bad', agentProfileId , 'ASSOCID0001', 'AGTASSOCID1');
                agentUser.userRoleId = agentUserRole.id;
                insert agentUser;
                
                proxyUser = buildUser('TestProxyUser@statefarm.com.bad', proxyProfileId, '', '');
                proxyUser.userRoleId = proxyUserRole.id;
                insert proxyUser;
                
                systemUser = buildUser('TestSystemUser@statefarm.com.bad', noAccessProfileId, '', '');
                insert systemUser;

                cccLicensedUser = buildUser('TestCCCUser@statefarm.com.bad', cccLicensedProfileId ,'ppcczz33ttc', '');
                insert cccLicensedUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{cccLicensedUser,agentUser});
            }
            
            Account acc = HLPR_LWC_NewOpportunityWorkflow_Test.buildAccountRecord('TST','TST','111',agentUser.Id);
            insert acc;
            
            
            //Insert agent role to give account access to the Agent
            AgentRole__c agentRole;
            System.runAs(agentUser) {
                agentRole = buildAgentRoleRecord(acc.Id);
            }
            insert agentRole;
            
        }
        
        /**
         * @description queryTestData
         */
        //Query the test data
        public static void queryTestData() {
            agentUser = [Select Id,Associate_ID__c from User where username = 'TestAgentUser@statefarm.com.bad'];
            adminUser = [Select Id,Associate_ID__c from User where username = 'TestAdminUser@statefarm.com.bad'];
            cccLicensedUser = [Select Id,Associate_ID__c,Profile.Name from User where username = 'TestCCCUser@statefarm.com.bad'];
            acc = [Select Id,ClientIdentifier__c from Account where lastname = 'TST'];
            
        }
    
    //Method to query loggedInUser
    @isTest
    private static void queryLoggedInUser() {
        queryTestData();
        System.runAs(cccLicensedUser) {
            Test.startTest();
           User user1 = HLPR_LWC_NewOpportunityWorkflow.getLoggedInUser();
            Test.stopTest();
            system.assertEquals(user1.Associate_ID__c,'ppcczz33ttc','Received InCorrect AssociateID');
        }
    }
    
    //Method to query loggedInUser
    @isTest
    private static void getLoggedInUserInfoAgent() {
        queryTestData();
        System.runAs(agentUser) {
            Test.startTest();
            string profileName = HLPR_LWC_NewOpportunityWorkflow.getLoggedInUserProfileName();
            Test.stopTest();
            system.assertEquals(profileName, '2.00 Agent', 'Received Incorrect Profile Name');
        }
    }
    
    
    
     //Method to get Account Record
    @isTest
    private static void getAccountRecord() {
        queryTestData();
        System.runAs(cccLicensedUser) {
            Test.startTest();
            Account testAcc = HLPR_LWC_NewOpportunityWorkflow.getAccountRecord(acc.Id);
            Test.stopTest();
            system.assertEquals(testAcc.Id,acc.Id,'Received InCorrect AccountID');
        }
    }
    
    //Method to getAgentRoleOptions
    @isTest
    private static void getAgentRoleOptions() {
        queryTestData();
        System.runAs(cccLicensedUser) {
            Test.startTest();
             List<AgentRole__c> agentRoleOptions = HLPR_LWC_NewOpportunityWorkflow.getAgentRoleOptions(acc.Id);
             system.assertEquals(agentRoleOptions.size(),1,'Invalid Agent Role');
            Test.stopTest();
        }
    }
    
    //Method to getAgentContextOptions
    @isTest
    private static void getAgentContextOptions() {
        queryTestData();
        System.runAs(cccLicensedUser) {
            Test.startTest();
             List<AgentContext__c> agentContextOptions = HLPR_LWC_NewOpportunityWorkflow.getAgentContextOptions(acc.Id,cccLicensedUser.id);
            system.assertEquals(agentContextOptions.size(),0,'Invalid Agent Context Options');
            Test.stopTest();
        }
    }
    
    //Method to upsert Agent Context
    @isTest
    private static void upsertAgentContext() {
        queryTestData();
        System.runAs(cccLicensedUser) {
            Integer beforeUpsertAgentContextQuery = [SELECT Count() FROM AgentContext__c WHERE AgentContextIdentifier__c = 'ppcczz33ttc~111'];
            Test.startTest();
            HLPR_LWC_NewOpportunityWorkflow.upsertAgentContext(agentUser.Associate_ID__c,cccLicensedUser.Associate_ID__c,acc);
            Test.stopTest();
            Integer afterUpsertAgentContextQuery = [SELECT Count() FROM AgentContext__c WHERE AgentContextIdentifier__c = 'ppcczz33ttc~111'];
            system.assertEquals(beforeUpsertAgentContextQuery+1, afterUpsertAgentContextQuery, 'Agent Context Upsert Failed');
        }
    }
    
    //Method to get priorityLOB
    @isTest
    private static void getPriorityLob() {
        queryTestData();
        System.runAs(cccLicensedUser) {
            Test.startTest();
            List<CM_LOB_Priority_Mapping__mdt> lobPriorityList = HLPR_LWC_NewOpportunityWorkflow.getPriorityLob();
            Test.stopTest();
            system.assertEquals(lobPriorityList.size(),6,'Invalid lobPriorityList ');
        }
    }
    
    
    
    }