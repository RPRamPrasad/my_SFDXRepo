@isTest
public with sharing class UTIL_OpportunityNotificationManager_TEST {

    public static User agentUser;
    public static User adminUser;
    public static User proxyUser;

    public static Account acc; 
    public static CollaborationGroup chatterGroup;

    private static final String CHATTER_GROUP_NAME = 'NewHotProspectNotifications-'; 
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();

    private static List<Id> collabGroupMemberIds = new List<Id>();
      
    //method to bypass Trigger
    /**
     * @description byPassTrigger
     */
    public static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }
    
    //method to build userrole with the given parameter value
    /**
     * @description buildUserRole
     * @param roleName 
     * @return  `UserRole`
     */
    public static UserRole buildUserRole(String roleName) {
        UserRole role = new UserRole(name = roleName);
        return role;
    }
    
    //method to build userrole with parentRole with the given parameter value
    /**
     * @description buildUserRoleWithParent
     * @param roleName 
     * @param parentRole 
     * @return  `UserRole`
     */
    public static UserRole buildUserRoleWithParent(String roleName, String parentRole) {
        UserRole role = new UserRole(name = roleName, parentRoleId = parentRole);
        return role;
    }
    
    //method to build Agent Role record with Customer Account Id
    /**
     * @description buildAgentRoleRecord
     * @param accountId 
     * @return  `AgentRole__c`
     */
    public static AgentRole__c buildAgentRoleRecord(String accountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = userInfo.getUserId(), Customer__c = accountId);
        return agentRole;
    }
    
    //method to build Agent Context Record with the given parameter value
    /**
     * @description buildAgentContextRecord
     * @param paramAccountId 
     * @param paramAgntContxtIdentifier 
     * @param paramAgntUser 
     * @return  `AgentContext__c`
     */
    public static AgentContext__c buildAgentContextRecord(String paramAccountId, String paramAgntContxtIdentifier, String paramAgntUser) {
        AgentContext__c agentContext = new AgentContext__c(Agent__c = paramAgntUser, AgentContextIdentifier__c = paramAgntContxtIdentifier,
                                                           CCCRepresentative__c = userInfo.getUserId(), Customer__c = paramAccountId);
        return agentContext;
    }
    
    //method to build Account record with Client First Name, Last Name, and Client Id
    /**
     * @description buildAccountRecord
     * @param fstLstName 
     * @param clientId 
     * @param owner 
     * @return  `Account`
     */
    public static Account buildAccountRecord(String fstLstName, String clientId, Id owner) {
        String[] splitFSTLSTName = fstLstName.split(' ');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account act = new Account(FirstName = splitFSTLSTName[0] , LastName = splitFSTLSTName[1], ownerId = owner,
                                  RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = clientId, BillingState = 'MD');
        return act;
    }
    
    /**
     * @description buildOpportunityRecord
     * @param accountId
     * @param lobProduct
     * @param ownerId
     * @return Opportunity
     */
    //method to build Opportunity record with Lob,Product, AccountId and OwnerId
    public static Opportunity buildOpportunityRecord(String accountId, String lobProduct, String ownerId) {
        String[] splitlobProduct = lobProduct.split('-');   
        Opportunity opp = new Opportunity(Name = splitlobProduct[0],
                                          AccountId = accountId, 
                                          LOB__c = splitlobProduct[0], 
                                          Product__c = (splitlobProduct.size()>1)?splitlobProduct[1]:'',
                                          StageName = 'New',
                                          CloseDate = Date.today()+60,
                                          ownerId = ownerId);
        return opp;
    }
    
    /**
     * @description creates and inserts users to run different test operations
     */
    @testSetup
    private static void setUp() {
        
        User adminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile('TestAdminUser@statefarm.com.bad');
        insert adminuser;

        User agentUser;
        User proxyUser; 

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildUserRole('AgentRole');
            insert agentUserRole;
            
            UserRole proxyUserRole = buildUserRoleWithParent('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            User testAgentUser = new User(Alias='X7PZ',LastName='agent,user,75-338-Office',Username='TestAgentUser@statefarm.com.bad',Associate_ID__c='ASSOCID0001',UserExternalID__c='EXTERNALID1',Servicing_Agent_Associate_ID__c='AGTASSOCID1',Territory_Associate_ID__c='',Servicing_Agent_Associate_ID_List__c='',Territory_Associate_ID_List__c='');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
            agentUser.userRoleId = agentUserRole.id;

            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);


            User testProxyUser = new User(Alias='X7PX',LastName='middle,Last,75-338-Office',Username='TestProxyUser@statefarm.com.bad',UserExternalID__c='EXTERNALID2',Servicing_Agent_Associate_ID__c='ASSOCID0001', Territory_Associate_ID__c='');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser(testProxyUser);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
        }
        
        Account acc = buildAccountRecord('FST LST','111', agentUser.Id);
        insert acc;
        
        //Insert agent role to give account access to the Agent
        AgentRole__c agentRole;
        System.runAs(agentUser) {
            agentRole = buildAgentRoleRecord(acc.Id);
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = CHATTER_GROUP_NAME + agentUser.Alias;
            chatterGroup.CollaborationType = 'Private';
            chatterGroup.OwnerId = agentUser.Id;
            insert chatterGroup; 

            CollaborationGroupMember adminGroupMember = new CollaborationGroupMember();
            adminGroupMember.CollaborationGroupId = chatterGroup.Id;
            adminGroupMember.MemberId = adminUser.Id;
            insert adminGroupMember;
        }
        insert agentRole;
    }
    
    /**
     * @description Grabs records from the User and Account SObjects and sets them to Apex objects for running
     * test code as different users.
     */ 
    private static void queryTestData() {
        agentUser = [SELECT Id, Associate_ID__c, Alias, UserExternalID__c, Email FROM User WHERE username = 'TestAgentUser@statefarm.com.bad'];
        adminUser = [SELECT Id, Associate_ID__c, Email FROM User WHERE username = 'TestAdminUser@statefarm.com.bad'];
        proxyUser = [SELECT Id, Associate_ID__c FROM User WHERE Alias = 'X7PXP'];
        acc = [SELECT Id, ClientIdentifier__c, Name FROM Account WHERE lastname = 'LST'];
        chatterGroup = [SELECT Id FROM CollaborationGroup WHERE Name =: CHATTER_GROUP_NAME + agentUser.Alias AND OwnerId = :agentUser.Id LIMIT 1];
    
        collabGroupMemberIds.add(adminUser.Id);
        collabGroupMemberIds.add(agentUser.Id);
    }

    @isTest
    private static void getChatterGroupReturnsCorrectGroupId() {
        queryTestData();
    
        CollaborationGroup mockChatterGroup = chatterGroup;

        List<CollaborationGroup> expectedChatterGroup = new List<CollaborationGroup>();
        expectedChatterGroup.add(mockChatterGroup);

        Test.startTest();
        List<CollaborationGroup> actualChatterGroup = UTIL_OpportunityNotificationManager.getChatterGroup(agentUser);
        Test.stopTest();
        
        System.assertEquals(expectedChatterGroup, actualChatterGroup, 'getChatterGroup() should return the correct Id of the chatter group tied to the agent');
    }

    @isTest
    private static void getChatterMemberIdsReturnsCorrectIds() {
        queryTestData();
        
        //a set bc we dont care about order, just values
        Set<Id> expectedChatterMemberIds = new Set<Id>();
        expectedChatterMemberIds.add(adminUser.Id);
        expectedChatterMemberIds.add(agentUser.Id);

        Test.startTest();
        List<Id> memberIdsFromDb = UTIL_OpportunityNotificationManager.getChatterMemberIds(chatterGroup.Id);
        Set<Id> actualChatterMemberIds = new Set<Id>();
        for(Id memberId: memberIdsFromDb) {
            actualChatterMemberIds.add(memberId);
        }
        
        Test.stopTest();
        System.assertEquals(expectedChatterMemberIds, actualChatterMemberIds, 
        'The lists should be identical between mock list and acutal list');
    }

    @isTest
    private static void getChatterGroupMemberEmailsReturnsCorrectEmails() {
        queryTestData();

        Map<Id, String> expectedEmailMap = new Map<Id, String>();
        expectedEmailMap.put(adminUser.Id, adminUser.Email);
        expectedEmailMap.put(agentUser.Id, agentUser.Email);

        Map<Id, String> actualEmailMap = new Map<Id, String>();

        Test.startTest();
        actualEmailMap = UTIL_OpportunityNotificationManager.getChatterGroupMemberEmails(collabGroupMemberIds);
        Test.stopTest();

        System.assertEquals(expectedEmailMap, actualEmailMap, 
        'Mock map of Id to String for email should equal the actual');
    } 

    /**
     * @description Agent user has Skype to false, admin user has Skype to true
     * So expected email in the set should be the adminUsers email
     */
    @isTest
    private static void getEmailsToRecieveSkypeAgentFalseAdminTrue() {
        queryTestData();

        Opportunity opp;

        System.runAs(agentUser) {

            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(acc.id, 'Auto-GAINSCO', proxyUser.Id);
	        insert opp;
        }

        Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> preferences = new Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference>();
        preferences.put(agentUser.Id,  new OppNotificationPreferenceRetriever.EmailSkypePreference(false, false));
        preferences.put(adminUser.Id,  new OppNotificationPreferenceRetriever.EmailSkypePreference(true, true));

        opp.Opportunity_Originator__c = 'Internet Lead Provider';
        update opp;

        Set<String> expectedEmails = new Set<String>();
        expectedEmails.add(adminUser.Email);

        Set<String> actualEmails = new Set<String>();

        Test.startTest();
        actualEmails = UTIL_OpportunityNotificationManager.getEmailsToRecieveSkype(collabGroupMemberIds, opp, preferences);
        Test.stopTest();

        System.assertEquals(expectedEmails, actualEmails, 'the admin user should be the only email in the set');
    }

    /**
     * @description Agent user has Skype to false, admin user has Skype to false
     * No emails should be in the returned set
     */
    @isTest
    private static void getEmailsToRecieveSkypeAgentFalseAdminFalse() {
        queryTestData();

        Opportunity opp;

        System.runAs(agentUser) {
            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(acc.id, 'Auto-GAINSCO', proxyUser.Id);
	        insert opp;
        }

        Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> preferences = new Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference>();
        preferences.put(agentUser.Id,  new OppNotificationPreferenceRetriever.EmailSkypePreference(false, false));
        preferences.put(adminUser.Id,  new OppNotificationPreferenceRetriever.EmailSkypePreference(false, false));

        opp.Opportunity_Originator__c = 'Internet Lead Provider';
        update opp;

        Set<String> actualEmails = new Set<String>();

        Test.startTest();
        actualEmails = UTIL_OpportunityNotificationManager.getEmailsToRecieveSkype(collabGroupMemberIds, opp, preferences);
        Test.stopTest();

        System.assertEquals(0, actualEmails.size(), 'the admin user should be the only email in the set');
    }

    /**
     * @description Admin user should be @mentioned, not agent
     */
    @isTest
    private static void getUsersToBeMentionedAdminOnly() {
        queryTestData();

        Opportunity opp;

        System.runAs(agentUser) {
            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(acc.id, 'Auto-GAINSCO', proxyUser.Id);
	        insert opp;
        }

        Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> preferences = new Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference>();
        preferences.put(agentUser.Id,  new OppNotificationPreferenceRetriever.EmailSkypePreference(false, false));
        preferences.put(adminUser.Id,  new OppNotificationPreferenceRetriever.EmailSkypePreference(true, false));

        opp.Opportunity_Originator__c = 'Internet Lead Provider';
        update opp;

        List<Id> actualIds = new List<Id>();
        List<Id> expectedIds = new List<Id>();
        expectedIds.add(adminUser.Id);

        Test.startTest();
        actualIds = UTIL_OpportunityNotificationManager.getUsersToBeMentioned(preferences);
        Test.stopTest();

        System.assertEquals(expectedIds, actualIds, 'the admin user should be the only email in the set');
    }
}