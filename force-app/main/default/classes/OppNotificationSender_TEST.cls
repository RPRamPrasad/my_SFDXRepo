@isTest(SeeAllData = false)
public with sharing class OppNotificationSender_TEST {
    
    private static User agentUser;
    private static User processId;
    private static User agentProxy;
    private static Account accountOnOpp; 

    private static final String UNITTEST_CUSTOM_SETTING_URL = 'ICP_TP_ENV';
    private static final String UNITTEST_SETUP_URL = 'unittest.statefarm.com';
    private static final String CLASS_NAME = 'UTIL_OpportunityNotificationManager_TEST';
    private static final String SETUP_METHOD_NAME = 'setupUserData';

    private static final String TEST_AGENT_USERNAME = 'testPostNewILPMsgTestAgent@statefarm.com.bad';
    private static final String TEST_PROCESS_ID_USERNAME = 'testPostNewILPMsgTestProcessId@statefarm.com.bad';
    private static final String TEST_AGENT_PROXY_USERNAME = 'testPostNewILPMsgTestAgentProxy@statefarm.com.bad';
    private static final String TEST_AGENT_PROXY_USERNAME_TESTDATA = '19ccww22zzcP@statefarm.com';
    private static final String CHATTER_GROUP_NAME = 'NewHotProspectNotifications-';
    private static final String SF_CRM_SFCOM_PERM_SET = 'SF_CRM_SFCOMLeadMsgSrvcs_PermSetPID';
    private static final String AGENT_ASSOCIATE_ID = 'ZEEVJON';

    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    private static String recordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId;
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();
    
    /**
     * @description mock web service calls for insertion of FeedItem objects
     */
    private class WebServiceMockImpl implements WebServiceMock {

        /**
         * @description doInvoke
         * @param stub 
         * @param request 
         * @param response 
         * @param endpoint 
         * @param soapAction 
         * @param requestName 
         * @param responseNS 
         * @param responseName 
         * @param responseType 
         */
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) {
            if(request instanceof  WSAP_SyncSkypeService.SendMessage_element) {
                response.put('response_x', new WSAP_SyncSkypeService.SendMessageResponse_element());
            }
            return;
        }
    }
    
    //Setup Users for Test
    @testSetup
    private static void setupUserData() {
        User adminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile('TestAdminUser@statefarm.com.bad');
        insert adminuser;
        User agentUser;
        
        System.runAs(adminUser) {
            OppNotificationPreferenceRetriever_TEST.byPassTrigger();
            
            UserRole agentUserRole = new UserRole(name = 'AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = new UserRole(name = 'ProxyRole', parentRoleId = agentUserRole.id);
            insert proxyUserRole;

            User testAgentUser = new User(Alias='X7PZ',LastName='agent,user,75-338-Office', Username= TEST_AGENT_PROXY_USERNAME, Associate_ID__c='ASSOCID0001',UserExternalID__c='EXTERNALID1',Servicing_Agent_Associate_ID__c='AGTASSOCID1',Territory_Associate_ID__c='',Servicing_Agent_Associate_ID_List__c='',Territory_Associate_ID_List__c='');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser (testAgentUser);
            agentUser.userRoleId = agentUserRole.id;

            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);


            User proxyUser = new User(alias = 'Prox',LastName='optyPrxy',Username=TEST_AGENT_PROXY_USERNAME_TESTDATA, UserExternalID__c='19ccww22zzc',Associate_ID__c='19ccww22zzc',Territory_Associate_ID__c='19ccww22zzc');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser(proxyUser);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            CS_EnvironmentURLCustomSetting__c baseURLCustomSetting = new CS_EnvironmentURLCustomSetting__c();
            baseUrlCustomSetting.Name = 'ICP_TP_ENV';
            baseUrlCustomSetting.Value__c = '.statefarm.com';
            baseUrlCustomSetting.EXT_ID__c= 'ECRM_6';

            insert baseURLCustomSetting;
        }
      
        processId = setupProcessUser(adminUser);
        insert processId;
        assignPermissionSet(processID, SF_CRM_SFCOM_PERM_SET);
    }
    
    /**
     * @description Sets up the process Id 'user' for testing
     * @param sysAdminUser The adminUser, dev sys profile
     * @return The User object for processId 'user'
     */
    public static User setupProcessUser(User sysAdminUser) {
        User procIDUser;
        System.runAs(sysAdminUser) {
            procIDUser = buildProcessIdUser(TEST_PROCESS_ID_USERNAME);
        } 
        return procIdUser;
    }
    
    //method to build generic user with the given parameter value
    private static User buildProcessIdUser(String param_UserName) {
        User testUser = new User(alias = '12345', email='testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
                                 languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
                                 username= param_UserName, profileId = '00eo00000013x2TAAQ');
        return testUser;
    }
    
    //method to assign permissionset for the given user in parameter value
    private static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [SELECT id FROM PermissionSet WHERE Name =: permissionSetName LIMIT 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }
    
    private static void queryTestDataInsertAccountOnOpp() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        agentUser = [SELECT id, Associate_ID__c, Alias FROM User WHERE Username =: TEST_AGENT_PROXY_USERNAME LIMIT 1];
        processId = [SELECT id FROM User WHERE Username =: TEST_PROCESS_ID_USERNAME LIMIT 1];
        agentProxy = [SELECT id, Alias, Associate_ID__c, Username FROM User WHERE Username =: TEST_AGENT_PROXY_USERNAME_TESTDATA LIMIT 1];

        //create an account for opps and insert it
        Account acc = OppNotificationPreferenceRetriever_TEST.buildAccountRecord('Steve Blunier','111', agentUser.Id);
        insert acc;
        accountOnOpp = [SELECT Id, ClientIdentifier__c, Name FROM Account WHERE lastname = 'Blunier'];
    }
    
    //Description: Test to see if ILP Chatter Group was not inserted
    @isTest(seeAllData=false)
    private static void invalidChatterGroupResultsToNoFeedItems() {
        queryTestDataInsertAccountOnOpp();
        Opportunity opp;

        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = 'invalidPostNewILPMsgTestName';
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;

            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountOnOpp.id,'Auto-GAINSCO', agentProxy.Id);
	        insert opp;
        }
        
        System.runAs(processId) {
            List<String> opportunityId = new List<String>();
            opportunityId.add(opp.id);
            Test.startTest();
            OppNotificationSender.sendOppNotifications(opp, agentUser);
            Test.stopTest();
        }
        
        Integer actualCountOfChatterPosts = [SELECT count() FROM FeedItem];   
        Integer expectedChatterPostCount = 0;
        System.assertEquals(expectedChatterPostCount, actualCountOfChatterPosts, 'should be no chatter posts');      
    }
    
    @isTest(seeAllData=false)
    private static void testHappyPathInsertedChatterMessageForUpdate() {
        queryTestDataInsertAccountOnOpp();
        Opportunity opp;

        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = CHATTER_GROUP_NAME + agentUser.Alias;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;

            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountOnOpp.id,'Auto-GAINSCO', agentProxy.Id);
	        insert opp;
        }
        
        opp.Opportunity_Originator__c = 'Statefarm.com';
        opp.stageName = 'In Progress'; 
        opp.Assigned_To__c = agentUser.Id;
        update opp;
        
        System.runAs(processId) {           
            List<String> opportunityId = new List<String>();
            opportunityId.add(opp.id);
            Test.startTest();
            OppNotificationSender.sendOppNotifications(opp, agentUser);
            Test.stopTest();
        }
        
        Integer actualCountOfChatterPosts = [SELECT count() FROM FeedItem];
        Integer expectedChatterPostCount = 1;
        System.assertEquals(expectedChatterPostCount, actualCountOfChatterPosts, 'should be one chatter post');       
    }

    @isTest(seeAllData=false)
    private static void newStageAndAssignedToForGetUsersToBeNotified() {
        queryTestDataInsertAccountOnOpp();
        Opportunity opp;

        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = CHATTER_GROUP_NAME + agentUser.Alias;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;

            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountOnOpp.id,'Auto-GAINSCO', agentProxy.Id);
	        insert opp;
        }

        opp.Opportunity_Originator__c = 'Agent/Team Member';
        opp.stageName = 'Qouting'; 
        opp.Assigned_To__c = agentUser.Id;
        update opp;
                
        System.runAs(processId) {           
            List<String> opportunityId = new List<String>();
            opportunityId.add(opp.id);
            Test.startTest();
            OppNotificationSender.sendOppNotifications(opp, agentUser);
            Test.stopTest();
        }
        
        Integer actualCountOfChatterPosts = [SELECT count() FROM FeedItem];
        Integer expectedChatterPostCount = 1;
        System.assertEquals(expectedChatterPostCount, actualCountOfChatterPosts, 'Should have one chatter post');        
    }

    // ADDED TO COVER MORE DELETE THIS COMMENT LATER --------------------------------------------
     
    //Description: Test to see if ILP Chatter Message was inserted
    @isTest(seeAllData=false)
    private static void chatterMessageInserted() {
        queryTestDataInsertAccountOnOpp();
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Opportunity opp;

        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = CHATTER_GROUP_NAME + agentUser.Alias;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;

            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountOnOpp.id,'Auto-GAINSCO', agentProxy.Id);
            insert opp;
        }

        opp.Opportunity_Originator__c = 'Statefarm.com';
        opp.stageName = 'New'; 
        opp.Assigned_To__c = agentUser.Id;
        update opp;
        
        System.runAs(processId) {
            List<String> opportunityId = new List<String>();
            opportunityId.add(opp.id);
            Test.startTest();
            OppNotificationSender.sendOppNotifications(opp, agentUser);
            Test.stopTest();
        }
        
        Integer actualCountOfChatterPosts = [SELECT count() FROM FeedItem];
        Integer expectedChatterPostCount = 1;
        System.assertEquals(expectedChatterPostCount, actualCountOfChatterPosts, 'Should be no chatter post');        
    }

    @isTest(seeAllData=false)
    private static void testHappyPathInsertedChatterMessageForChatterPostMessage() {
        queryTestDataInsertAccountOnOpp();
        Opportunity opp;

        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = CHATTER_GROUP_NAME + agentUser.Alias;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;

            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountOnOpp.id,'Auto-GAINSCO', agentProxy.Id);
            insert opp;
        }
        
        System.runAs(processId) {           
            List<String> opportunityId = new List<String>();
            opportunityId.add(opp.id);
            Test.startTest();
            OppNotificationSender.sendOppNotifications(opp, agentUser);
            Test.stopTest();
        }
        
        Integer actualCountOfChatterPosts = [SELECT count() FROM FeedItem];
        Integer expectedChatterPostCount = 1;
        System.assertEquals(expectedChatterPostCount, actualCountOfChatterPosts, 'should have one chatter post');        
    }

    @isTest(seeAllData=false)
    private static void testHappyPathInsertedChatterMessageForChatterPostCreateMessage() {
        queryTestDataInsertAccountOnOpp();
        Opportunity opp;

        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = CHATTER_GROUP_NAME + agentUser.Alias;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;

            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountOnOpp.id,'Auto-GAINSCO', agentProxy.Id);
            insert opp;
        }

        opp.Opportunity_Originator__c = 'Internet Lead Provider';
        opp.stageName = 'New'; 
        opp.Assigned_To__c = agentUser.Id;
        update opp;
                
        System.runAs(processId) {           
            List<String> opportunityId = new List<String>();
            opportunityId.add(opp.id);
            Test.startTest();
            OppNotificationSender.sendOppNotifications(opp, agentUser);
            Test.stopTest();
        }
        
        Integer actualCountOfChatterPosts = [SELECT count() FROM FeedItem];
        Integer expectedChatterPostCount = 1;
        System.assertEquals(expectedChatterPostCount, actualCountOfChatterPosts, 'should have no chatter post');        
    }

    @isTest(seeAllData=false)
    private static void sendToAllNonATMNotNewStageNoAssignedUser() {
        queryTestDataInsertAccountOnOpp();
        Opportunity opp;

        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = CHATTER_GROUP_NAME + agentUser.Alias;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;

            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountOnOpp.id,'Auto-GAINSCO', agentProxy.Id);
            insert opp;
        }

        opp.Opportunity_Originator__c = 'Statefarm.com';
        opp.stageName = 'Qouting'; 
        opp.Assigned_To__c = null;
        update opp;
                
        System.runAs(processId) {           
            List<String> opportunityId = new List<String>();
            opportunityId.add(opp.id);
            Test.startTest();
            OppNotificationSender.sendOppNotifications(opp, agentUser);
            Test.stopTest();
        }
        
        Integer actualCountOfChatterPosts = [SELECT count() FROM FeedItem];
        Integer expectedChatterPostCount = 1;
        System.assertEquals(expectedChatterPostCount, actualCountOfChatterPosts, 'should have no chatter post');        
    }

    //additional ATM test scenario expect 0 chatter posts
    @isTest(seeAllData=false)
    private static void sendNothingATMNewAssigned() {
        queryTestDataInsertAccountOnOpp();
        Opportunity opp;

        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = CHATTER_GROUP_NAME + agentUser.Alias;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;

            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountOnOpp.id,'Auto-GAINSCO', agentProxy.Id);
            insert opp;
        }

        opp.Opportunity_Originator__c = 'Agent/Team Member';
        opp.stageName = 'New'; 
        opp.Assigned_To__c = agentUser.Id;
        update opp;
                
        System.runAs(processId) {           
            List<String> opportunityId = new List<String>();
            opportunityId.add(opp.id);
            Test.startTest();
            OppNotificationSender.sendOppNotifications(opp, agentUser);
            Test.stopTest();
        }
        
        Integer actualCountOfChatterPosts = [SELECT count() FROM FeedItem];
        Integer expectedChatterPostCount = 0;
        System.assertEquals(expectedChatterPostCount, actualCountOfChatterPosts, 'should have no chatter post');        
    }
}
