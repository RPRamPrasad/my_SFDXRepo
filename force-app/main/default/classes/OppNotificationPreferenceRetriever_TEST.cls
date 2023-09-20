/**
 * @description Test class for Apex class OppNotificationPreferenceRetriever.cls
 */
@isTest
public with sharing class OppNotificationPreferenceRetriever_TEST {  

    private static User agentUser;
    private static User adminUser;
    private static User proxyUser;

    private static Account acc; 
    private static Opportunity opp;

    //TRYDO: PUT THESE IN A MAP
    private static final Id ILP_SCENARIO_ID = '0050n000003WFTBAA1'; // for ilp originator opps, email true skype false
    private static final Id ATM_SCENARIO_ID = '0050n000003WFufAA2'; // for atm originator opps, email false skype true 
    private static final Id SFCOM_ONLINE_BROWSE_TRUE_ID = '0050n0000046td4AA3'; // for sfCom originator opps, email true skype true
    private static final Id SFCOM_EMAIL_SKYPE_FALSE_WARM_ID = '0050n0000046td5AA4'; // for sfCom originator opps, email true skype true, warm true, online browsing disabled
    private static final Id SFCOM_EMAIL_SKYPE_TRUE_URGENT_ID = '0050n0000046td5AA5'; // for sfCom originator opps, email true, skype true, urgent true, online browsing disabled
    private static final Id SFCOM_WARM_DISABLED_ID = '0050n0000046td5AA6'; // for sfCom originator opps, email false, skype false, warm true, warm preference disabled, online browsing disabled
    private static final Id SFCOM_EMAIL_SKYPE_COLD_TRUE_ID = '0050n0000046td5AA7'; // for sfCom originator opps, email true, skype true, cold true, cold preference true, online browsing disabled
    private static final Id HAS_NO_PREFRENCE_ID = '0050n0000046td5AA8'; // !IMPORTANT! ALWAYS KEEP THIS Id IN LIST AS IT SHOWS THAT NOT ALL USERS WILL HAVE A NotificationPreference__c record

    // !IMPORTANT! ALWAYS HAVE AT LEAST ONE Id IN THIS LIST THAT IS NOT ASSOCIATED TO A NotificationPreference__c RECORD !IMPORTANT!
    private static List<Id> collabGroupMemberIds = new List<Id>();//collaborationGroupMember memberId's (aka userId's)

    private static Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> expectedRetVal = new Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference>();
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();
    
    /**
     * @description byPassTrigger
     */
    //method to bypass Trigger
    public static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }
    
    /**
     * @description buildUserRole
     * @param roleName
     * @return UserRole
     */
    //method to build userrole with the given parameter value
    public static UserRole buildUserRole(String roleName) {
        UserRole role = new UserRole(name = roleName);
        return role;
    }
    
    /**
     * @description buildUserRoleWithParent
     * @param roleName
     * @param parentRole
     * @return UserRole
     */
    //method to build userrole with parentRole with the given parameter value
    public static UserRole buildUserRoleWithParent(String roleName, String parentRole) {
        UserRole role = new UserRole(name = roleName, parentRoleId = parentRole);
        return role;
    }
    
    /**
     * @description buildAgentRoleRecord
     * @param accountId
     * @return AgentRole__c
     */
    //method to build Agent Role record with Customer Account Id
    public static AgentRole__c buildAgentRoleRecord(String accountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = userInfo.getUserId(), Customer__c = accountId);
        return agentRole;
    }
    
    /**
     * @description buildAgentContextRecord
     * @param paramAccountId
     * @param paramAgntContxtIdentifier
     * @param paramAgntUser
     * @return AgentContext__c
     */
    //method to build Agent Context Record with the given parameter value
    public static AgentContext__c buildAgentContextRecord(String paramAccountId, String paramAgntContxtIdentifier, String paramAgntUser) {
        AgentContext__c agentContext = new AgentContext__c(Agent__c = paramAgntUser, AgentContextIdentifier__c = paramAgntContxtIdentifier,
                                                           CCCRepresentative__c = userInfo.getUserId(), Customer__c = paramAccountId);
        return agentContext;
    }
    
    /**
     * @description buildAccountRecord
     * @param fstLstName
     * @param clientId
     * @param owner
     * @return Account
     */
    //method to build Account record with Client First Name, Last Name, and Client Id
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
    public static void setUp() {
        
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
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser (testAgentUser);
            agentUser.userRoleId = agentUserRole.id;

            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);


            User testProxyUser = new User(Alias='X7PX',LastName='middle,Last,75-338-Office',Username='TestProxyUser@statefarm.com.bad',UserExternalID__c='EXTERNALID2',Servicing_Agent_Associate_ID__c='ASSOCID0001', Territory_Associate_ID__c='');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser(testProxyUser);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
        }
        
        Account acc = buildAccountRecord('FST LST','111',agentUser.Id);
        insert acc;
        
        //Insert agent role to give account access to the Agent
        AgentRole__c agentRole;
        System.runAs(agentUser) {
            agentRole = buildAgentRoleRecord(acc.Id);
        }
        insert agentRole;
    }
    
    /**
     * @description Grabs records from the User and Account SObjects and sets them to Apex objects for running
     * test code as different users.
     */ 
    private static void queryAndSetTestData() {
        agentUser = [SELECT Id, Associate_ID__c, UserExternalID__c FROM User WHERE username = 'TestAgentUser@statefarm.com.bad'];
        adminUser = [SELECT Id, Associate_ID__c FROM User WHERE username = 'TestAdminUser@statefarm.com.bad'];
        proxyUser = [SELECT Id, Associate_ID__c FROM User WHERE Alias = 'X7PXP'];
        acc = [SELECT Id, ClientIdentifier__c, Name FROM Account WHERE lastname = 'LST'];

        collabGroupMemberIds.add(ILP_SCENARIO_ID); 
        collabGroupMemberIds.add(ATM_SCENARIO_ID); 
        collabGroupMemberIds.add(SFCOM_ONLINE_BROWSE_TRUE_ID);
        collabGroupMemberIds.add(SFCOM_EMAIL_SKYPE_FALSE_WARM_ID); 
        collabGroupMemberIds.add(SFCOM_EMAIL_SKYPE_TRUE_URGENT_ID); 
        collabGroupMemberIds.add(SFCOM_WARM_DISABLED_ID); 
        collabGroupMemberIds.add(SFCOM_EMAIL_SKYPE_COLD_TRUE_ID); 
        collabGroupMemberIds.add(HAS_NO_PREFRENCE_ID); // will not get a NotificationPreference__c record

        expectedRetVal.put(ILP_SCENARIO_ID, new OppNotificationPreferenceRetriever.EmailSkypePreference(true, false));
        expectedRetVal.put(ATM_SCENARIO_ID, new OppNotificationPreferenceRetriever.EmailSkypePreference(true, true));
        expectedRetVal.put(SFCOM_ONLINE_BROWSE_TRUE_ID, new OppNotificationPreferenceRetriever.EmailSkypePreference(true, true));
        expectedRetVal.put(SFCOM_EMAIL_SKYPE_FALSE_WARM_ID, new OppNotificationPreferenceRetriever.EmailSkypePreference(false, false));
        expectedRetVal.put(SFCOM_EMAIL_SKYPE_TRUE_URGENT_ID, new OppNotificationPreferenceRetriever.EmailSkypePreference(true, true));
        expectedRetVal.put(SFCOM_WARM_DISABLED_ID, new OppNotificationPreferenceRetriever.EmailSkypePreference(false, false));
        expectedRetVal.put(SFCOM_EMAIL_SKYPE_COLD_TRUE_ID, new OppNotificationPreferenceRetriever.EmailSkypePreference(true, true));
        expectedRetVal.put(HAS_NO_PREFRENCE_ID, new OppNotificationPreferenceRetriever.EmailSkypePreference(false, true));
    }

    //test NotificationPreference__c records for expected return mock data
    private static void insertNotificationPrefs(){
        List<NotificationPreference__c> recordsToInsert = new List<NotificationPreference__c>();

        //ilp email true skype false
        NotificationPreference__c ilpEmailTrueSkypeFalse = new NotificationPreference__c();
        ilpEmailTrueSkypeFalse.enableILPEmail__c = true;
        ilpEmailTrueSkypeFalse.enableILPSkype__c = false;
        ilpEmailTrueSkypeFalse.notificationGroupMemberId__c = ILP_SCENARIO_ID;        
        recordsToInsert.add(ilpEmailTrueSkypeFalse);

        //atm email false skype true
        NotificationPreference__c atmEmailFalseSkypeTrue = new NotificationPreference__c();
        atmEmailFalseSkypeTrue.enableSFComEmail__c = false;
        atmEmailFalseSkypeTrue.enableSFComSkype__c = true;
        atmEmailFalseSkypeTrue.defaultEmailSelection__c = true;
        atmEmailFalseSkypeTrue.notificationGroupMemberId__c = ATM_SCENARIO_ID;        
        recordsToInsert.add(atmEmailFalseSkypeTrue);

        //SFCom email true Skype true, online browsing enabled
        NotificationPreference__c sfComOnlineBrowsingEmailSkypeTrue = new NotificationPreference__c();
        sfComOnlineBrowsingEmailSkypeTrue.enableSFComEmail__c = true;
        sfComOnlineBrowsingEmailSkypeTrue.enableSFComSkype__c = true;
        sfComOnlineBrowsingEmailSkypeTrue.enableOnlineBrowsing__c = true;
        sfComOnlineBrowsingEmailSkypeTrue.notificationGroupMemberId__c = SFCOM_ONLINE_BROWSE_TRUE_ID;        
        recordsToInsert.add(sfComOnlineBrowsingEmailSkypeTrue);

        //SFCom email false, Skype false, online browsing disabled, opp temp Warm
        NotificationPreference__c sfComEmailSkypeFalseWarm = new NotificationPreference__c();
        sfComEmailSkypeFalseWarm.enableSFComSkype__c = false;
        sfComEmailSkypeFalseWarm.enableSFComEmail__c = false;
        sfComEmailSkypeFalseWarm.enableOnlineBrowsing__c = false; // will bring us into switch inside enableSFComNotification
        sfComEmailSkypeFalseWarm.enableTempHotWarm__c = true; // will set the enablement of the firing of the sfcom notification to be true bc the temp warm is enable in np record
        sfComEmailSkypeFalseWarm.notificationGroupMemberId__c = SFCOM_EMAIL_SKYPE_FALSE_WARM_ID;
        recordsToInsert.add(sfComEmailSkypeFalseWarm);

        NotificationPreference__c sfComEmailSkypeTrueUrgent = new NotificationPreference__c();
        sfComEmailSkypeTrueUrgent.enableSFComSkype__c = true;
        sfComEmailSkypeTrueUrgent.enableSFComEmail__c = true;
        sfComEmailSkypeTrueUrgent.enableOnlineBrowsing__c = false; // will bring us into switch inside enableSFComNotification
        sfComEmailSkypeTrueUrgent.enableTempUrgent__c = true; // will set the enablement of the firing of the sfcom notification to be true bc the temp urgent is enable in np record
        sfComEmailSkypeTrueUrgent.notificationGroupMemberId__c = SFCOM_EMAIL_SKYPE_TRUE_URGENT_ID;
        recordsToInsert.add(sfComEmailSkypeTrueUrgent);

        NotificationPreference__c sfComWarmDisabled = new NotificationPreference__c();
        sfComWarmDisabled.enableSFComSkype__c = false;
        sfComWarmDisabled.enableSFComEmail__c = false;
        sfComWarmDisabled.enableOnlineBrowsing__c = true; 
        sfComWarmDisabled.enableTempHotWarm__c = false; // will set the enablement of the firing of the sfcom notification to be true bc the temp warm is enable in np record
        sfComWarmDisabled.notificationGroupMemberId__c = SFCOM_WARM_DISABLED_ID;
        recordsToInsert.add(sfComWarmDisabled);

        NotificationPreference__c sfComEmailSkypeColdTrue = new NotificationPreference__c();
        sfComEmailSkypeColdTrue.enableSFComSkype__c = true;
        sfComEmailSkypeColdTrue.enableSFComEmail__c = true;
        sfComEmailSkypeColdTrue.enableOnlineBrowsing__c = false; // will bring us into switch inside enableSFComNotification
        sfComEmailSkypeColdTrue.enableTempColdNoTemp__c = true; // will set the enablement of the firing of the sfcom notification to be true bc the temp warm is enable in np record
        sfComEmailSkypeColdTrue.notificationGroupMemberId__c = SFCOM_EMAIL_SKYPE_COLD_TRUE_ID;
        recordsToInsert.add(sfComEmailSkypeColdTrue);

        insert recordsToInsert;
    }

    // BEGIN TESTS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    @isTest
    public static void agentSetsILPEmailTrueSkypeFalse() {
        queryAndSetTestData();

        Opportunity opp;
        System.runAs(agentUser) {
            opp = buildOpportunityRecord(acc.id,'Auto-GAINSCO', proxyUser.Id);
            insertNotificationPrefs();
            insert opp;
        }

        //updates in System context
        opp.Opportunity_Originator__c = 'Internet Lead Provider';
        update opp;

        Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> actualRetVal = new Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference>();
        actualRetVal = OppNotificationPreferenceRetriever.getNotificationPreferences(opp, collabGroupMemberIds);

        // have the same keys
        System.assertEquals(expectedRetVal.keySet(),  actualRetVal.keySet(),
         'Method getNotificationPreferences() returns the proper Ids as keys in map.');

        //collab group members size needs to equal the return map count, so that all users have either defaulted preferences or 
        //preferences based on Notification_Preference__c records 
        System.assertEquals(collabGroupMemberIds.size(), actualRetVal.size(), 'return value size should be smaller than the total collab group member in parameter Id set');
        
        // this Id has no Notification_Preference__c record, so test their defaults for true
        System.assertEquals(expectedRetVal.get(HAS_NO_PREFRENCE_ID).shouldSendEmailNotification(),
        actualRetVal.get(HAS_NO_PREFRENCE_ID).shouldSendEmailNotification(),
         'Method getNotificationPreferences() returns the proper ILP email preference.');

        // this Id has no Notification_Preference__c record, so test their defaults for true
        System.assertEquals(expectedRetVal.get(HAS_NO_PREFRENCE_ID).shouldSendSkypeNotification(),
        actualRetVal.get(HAS_NO_PREFRENCE_ID).shouldSendSkypeNotification(),
        'Method getNotificationPreferences() returns the proper ILP Skype preference.');

        // have the same email boolean
        System.assertEquals(expectedRetVal.get(ILP_SCENARIO_ID).shouldSendEmailNotification(),
        actualRetVal.get(ILP_SCENARIO_ID).shouldSendEmailNotification(),
         'Method getNotificationPreferences() returns the proper ILP email preference.');

        // have the same skype boolean
        System.assertEquals(expectedRetVal.get(ILP_SCENARIO_ID).shouldSendSkypeNotification(),
        actualRetVal.get(ILP_SCENARIO_ID).shouldSendSkypeNotification(),
        'Method getNotificationPreferences() returns the proper ILP Skype preference.');
    }

    @isTest
    public static void setNotifPrefWithATMOriginator(){
        queryAndSetTestData();

        Opportunity opp;
        System.runAs(agentUser) {
            opp = buildOpportunityRecord(acc.id,'Auto-GAINSCO', proxyUser.Id);
            insertNotificationPrefs();
            insert opp;
        }

        //updates in System context
        opp.Opportunity_Originator__c = 'Agent/Team Member';
        update opp;

        Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> actualRetVal = new Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference>();
        actualRetVal = OppNotificationPreferenceRetriever.getNotificationPreferences(opp, collabGroupMemberIds);

        // have the same email boolean
        System.assertEquals(expectedRetVal.get(ATM_SCENARIO_ID).shouldSendEmailNotification(),
        actualRetVal.get(ATM_SCENARIO_ID).shouldSendEmailNotification(),
         'Method getNotificationPreferences() returns the proper ATM email preference.');

        // have the same skype boolean
        System.assertEquals(expectedRetVal.get(ATM_SCENARIO_ID).shouldSendSkypeNotification(),
        actualRetVal.get(ATM_SCENARIO_ID).shouldSendSkypeNotification(),
        'Method getNotificationPreferences() returns the proper ATM Skype preference.');
    }

    @isTest
    public static void sfComOnlineBrowsingEmailSkypeTrue(){
        queryAndSetTestData();

        Opportunity opp;
        System.runAs(agentUser) {
            opp = buildOpportunityRecord(acc.id,'Auto-GAINSCO', proxyUser.Id);
            opp.Marketing_Sub_Source__c = 'Online Browsing';
            insertNotificationPrefs();
            insert opp;
        }

        //updates in System context
        opp.Opportunity_Originator__c = 'Statefarm.com';
        update opp;

        Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> actualRetVal = new Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference>();
        actualRetVal = OppNotificationPreferenceRetriever.getNotificationPreferences(opp, collabGroupMemberIds);

        // have the same email boolean
        System.assertEquals(expectedRetVal.get(SFCOM_ONLINE_BROWSE_TRUE_ID).shouldSendEmailNotification(),
        actualRetVal.get(SFCOM_ONLINE_BROWSE_TRUE_ID).shouldSendEmailNotification(),
         'Method getNotificationPreferences() returns the proper SFCom email preference.');

        // have the same skype boolean
        System.assertEquals(expectedRetVal.get(SFCOM_ONLINE_BROWSE_TRUE_ID).shouldSendSkypeNotification(),
        actualRetVal.get(SFCOM_ONLINE_BROWSE_TRUE_ID).shouldSendSkypeNotification(),
        'Method getNotificationPreferences() returns the proper SFCom Skype preference.');
    }
 
    @isTest
    public static void warmOppOppNotificationsEnabledIsTrue(){
        queryAndSetTestData();

        Opportunity opp;
        System.runAs(agentUser) {
            opp = buildOpportunityRecord(acc.id,'Auto-GAINSCO', proxyUser.Id);
            opp.Marketing_Sub_Source__c = 'Online Browsing';
            opp.Temperature__c = 'Warm';
            insertNotificationPrefs();
            insert opp;
        }

        //updates in System context
        opp.Opportunity_Originator__c = 'Statefarm.com';
        update opp;

        Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> actualRetVal = new Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference>();
        actualRetVal = OppNotificationPreferenceRetriever.getNotificationPreferences(opp, collabGroupMemberIds);

        // have the same email boolean
        System.assertEquals(expectedRetVal.get(SFCOM_EMAIL_SKYPE_FALSE_WARM_ID).shouldSendEmailNotification(),
        actualRetVal.get(SFCOM_EMAIL_SKYPE_FALSE_WARM_ID).shouldSendEmailNotification(),
         'Method getNotificationPreferences() returns the proper SFCom email preference.');

        // have the same skype boolean
        System.assertEquals(expectedRetVal.get(SFCOM_EMAIL_SKYPE_FALSE_WARM_ID).shouldSendSkypeNotification(),
        actualRetVal.get(SFCOM_EMAIL_SKYPE_FALSE_WARM_ID).shouldSendSkypeNotification(),
        'Method getNotificationPreferences() returns the proper SFCom Skype preference.');
    }

     @isTest
    public static void urgentOppOppNotificationsEnabledIsTrue(){
        queryAndSetTestData();

        Opportunity opp;
        System.runAs(agentUser) {
            opp = buildOpportunityRecord(acc.id,'Auto-GAINSCO', proxyUser.Id);
            opp.Marketing_Sub_Source__c = 'Online Browsing';
            opp.Temperature__c = 'Urgent';
            insertNotificationPrefs();
            insert opp;
        }

        //updates in System context
        opp.Opportunity_Originator__c = 'Statefarm.com';
        update opp;

        Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> actualRetVal = new Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference>();
        actualRetVal = OppNotificationPreferenceRetriever.getNotificationPreferences(opp, collabGroupMemberIds);

        // have the same email boolean
        System.assertEquals(expectedRetVal.get(SFCOM_EMAIL_SKYPE_TRUE_URGENT_ID).shouldSendEmailNotification(),
        actualRetVal.get(SFCOM_EMAIL_SKYPE_TRUE_URGENT_ID).shouldSendEmailNotification(),
         'Method getNotificationPreferences() returns the proper SFCom email preference.');

        // have the same skype boolean
        System.assertEquals(expectedRetVal.get(SFCOM_EMAIL_SKYPE_TRUE_URGENT_ID).shouldSendSkypeNotification(),
        actualRetVal.get(SFCOM_EMAIL_SKYPE_TRUE_URGENT_ID).shouldSendSkypeNotification(),
        'Method getNotificationPreferences() returns the proper SFCom Skype preference.');
    }

    @isTest
    public static void warmOppOppNotificationsEnabledIsFalse(){
        queryAndSetTestData();

        Opportunity opp;
        System.runAs(agentUser) {
            opp = buildOpportunityRecord(acc.id,'Auto-GAINSCO', proxyUser.Id);
            opp.Marketing_Sub_Source__c = 'Twitch';
            opp.Temperature__c = 'Warm';
            insertNotificationPrefs();
            insert opp;
        }

        //updates in System context
        opp.Opportunity_Originator__c = 'Statefarm.com';
        update opp;

        Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> actualRetVal = new Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference>();
        actualRetVal = OppNotificationPreferenceRetriever.getNotificationPreferences(opp, collabGroupMemberIds);

        // have the same email boolean
        System.assertEquals(expectedRetVal.get(SFCOM_WARM_DISABLED_ID).shouldSendEmailNotification(),
        actualRetVal.get(SFCOM_WARM_DISABLED_ID).shouldSendEmailNotification(),
         'Method getNotificationPreferences() returns the proper SFCom email preference.');

        // have the same skype boolean
        System.assertEquals(expectedRetVal.get(SFCOM_WARM_DISABLED_ID).shouldSendSkypeNotification(),
        actualRetVal.get(SFCOM_WARM_DISABLED_ID).shouldSendSkypeNotification(),
        'Method getNotificationPreferences() returns the proper SFCom Skype preference.');
    }

    @isTest
    public static void coldOppOppNotificationsEnabledIsTrue(){
        queryAndSetTestData();

        Opportunity opp;
        System.runAs(agentUser) {
            opp = buildOpportunityRecord(acc.id,'Auto-GAINSCO', proxyUser.Id);
            opp.Marketing_Sub_Source__c = 'Online Browsing';
            opp.Temperature__c = 'Cold';
            insertNotificationPrefs();
            insert opp;
        }

        //updates in System context
        opp.Opportunity_Originator__c = 'Statefarm.com';
        update opp;

        Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> actualRetVal = new Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference>();
        actualRetVal = OppNotificationPreferenceRetriever.getNotificationPreferences(opp, collabGroupMemberIds);

        // have the same email boolean
        System.assertEquals(expectedRetVal.get(SFCOM_EMAIL_SKYPE_COLD_TRUE_ID).shouldSendEmailNotification(),
        actualRetVal.get(SFCOM_EMAIL_SKYPE_COLD_TRUE_ID).shouldSendEmailNotification(),
         'Method getNotificationPreferences() returns the proper SFCom email preference.');

        // have the same skype boolean
        System.assertEquals(expectedRetVal.get(SFCOM_EMAIL_SKYPE_COLD_TRUE_ID).shouldSendSkypeNotification(),
        actualRetVal.get(SFCOM_EMAIL_SKYPE_COLD_TRUE_ID).shouldSendSkypeNotification(),
        'Method getNotificationPreferences() returns the proper SFCom Skype preference.');
    }
}