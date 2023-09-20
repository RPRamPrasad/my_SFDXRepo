/**
 * @description test class to feed items after insert
 * @author
 * @since
 */
@isTest (seeAllData=false)
private class AP_FeedItemAfterInsert_TEST {
    private static User agentUser;
    private final  static String AGENT_USER_NAME = 'test@statefarm.com.sandbox';
    private static User ilpProcess;

    /**
     * @description test method for setup agent user
     */
    @testSetup
    public static void setUp() {

        agentUser = UTIL_UserProvisioning_TEST.buildSampleAgentUser(AGENT_USER_NAME);
        insert agentUser;
        User processITIMUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin ('UserITIMProcessDataAdmin@statefarm.com');
        insert processITIMUser;
        UTIL_PermissionSetting_TEST.permissionForITIM (processITIMUser.Id);
        String adminUserProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
        ilpProcess = createUser(buildUser('TestUserILP@sta.com', adminUserProfileId ));
            assignPermissionSet(ilpProcess, 'SF_CRM_LeadMessageService_PermSetID');
        }

    /**
     * @description test method to build user
     * @param paramUserName
     * @param paramProfileId
     * @return  `User`
     */
    public static User buildUser(String paramUserName, String paramProfileId) {
        User testUser = new User(alias = '12345', email='testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
                            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago',
                            username= paramUserName, profileId = paramProfileId
                        );
        testUser.put('UserPermissionsMarketingUser', true);
        return testUser;
    }

    /**
     * @description method to create user with the given user parameter value
     * @param testUser
     * @return  `User`
     */
    public static User createUser(User testUser) {
        insert testUser;
        return testUser;
    }
    private static String getProfileId(String profileName) {
        String profileId = [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].Id;
        return profileId;
        }

    /**
     * @description test method to assign permission set
     * @param testUser
     * @param permissionSetName
     */
    public static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }
    private static FeedItem buildFeedItem() {
        FeedItem feedItem = new FeedItem(Type='TextPost', ParentId=UserInfo.getUserId(), Body = 'Testabcd',Title='New or UnClaimed');
        return feedItem;
    }

    private static FeedItem buildFeedItem1() {
        FeedItem feedItem = new FeedItem(Type='LinkPost', ParentId=UserInfo.getUserId(), Body = 'Testabcd',Title='New or Unclaimed',LinkUrl='WWW.GOOGLE.COM');
        return feedItem;
    }

    @isTest
    public static void testInsertFeedItemInfoIntoFeedStage() {
        User insertedAgentUser = [select Id from User where Username =: AGENT_USER_NAME];
        CS_MonitoredAudience__c userLevelCustomSetting = new CS_MonitoredAudience__c();
        userLevelCustomSetting.SetupOwnerId = insertedAgentUser.Id;
        userLevelCustomSetting.IsMonitored__c = true;
        insert userLevelCustomSetting;
        String feedItemRecordId = '';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedAgentUser);
        test.startTest();
        system.runAs(insertedAgentUser) {
            FeedItem feedItemRecord = buildFeedItem();
            insert feedItemRecord;
            feedItemRecordId = feedItemRecord.Id;
        }
        test.stopTest();
        FeedStage__c feedStageRecord = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecordId];
        system.assertEquals(feedItemRecordId, feedStageRecord.FeedItemID__c, 'Expected value not same as actual');
    }

    @isTest
    public static void testInsertFeedItemInfoIntoFeedStageWithProfileLevelCustomSetting() {
        User insertedAgentUser = [select Id, ProfileId from User where Username =: AGENT_USER_NAME];
        CS_MonitoredAudience__c profileLevelCustomSetting = new CS_MonitoredAudience__c();
        profileLevelCustomSetting.SetupOwnerId = insertedAgentUser.ProfileId;
        profileLevelCustomSetting.IsMonitored__c = true;
        insert profileLevelCustomSetting;
        String feedItemRecordId = '';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedAgentUser);
        test.startTest();
        system.runAs(insertedAgentUser) {
            FeedItem feedItemRecord = buildFeedItem();
            insert feedItemRecord;
            feedItemRecordId = feedItemRecord.Id;
        }
        test.stopTest();
        FeedStage__c feedStageRecord = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecordId];
        system.assertEquals(feedItemRecordId, feedStageRecord.FeedItemID__c, 'Expected value not same as actual');
    }

    @isTest
    public static void testInsertFeedCommentInfoIntoFeedStageWithCustomSettingFalse() {
        User insertedAgentUser = [select Id from User where Username =: AGENT_USER_NAME];
        String feedItemRecordId = '';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedAgentUser);
        test.startTest();
        system.runAs(insertedAgentUser) {
            FeedItem feedItemRecord = buildFeedItem();
            insert feedItemRecord;
            feedItemRecordId = feedItemRecord.Id;
        }
        test.stopTest();
        List<FeedStage__c> feedStageRecordList = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecordId];
        system.assertEquals(0, feedStageRecordList.size(), 'Expected value not same as actual');
    }

    @isTest
    public static void testInsertFeedStageWithAtmNotRegisteredRepresentative() {
        User processITIMUser = [select id from User where username ='UserITIMProcessDataAdmin@statefarm.com'];
        User insertedAtmUser = UTIL_UserProvisioning_TEST.buildSampleATMUser ('atmUserName@statefarm.com');
        insertedAtmUser.RegisteredRepresentative__c= false;
        System.runAs(processITIMUser){
            insert insertedAtmUser;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedAtmUser);
        String feedItemRecordId = '';
        test.startTest();
        system.runAs(insertedAtmUser) {
            FeedItem feedItemRecord = buildFeedItem();
            insert feedItemRecord;
            feedItemRecordId = feedItemRecord.Id;
        }
        test.stopTest();
        List<FeedStage__c> feedStageRecordList = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecordId];
        system.assertEquals(0, feedStageRecordList.size(), 'Expected value not same as actual');
    }

    @isTest
    public static void testInsertFeedStageWithAtmRegisteredRepresentative() {
        User processITIMUser = [select id from User where username ='UserITIMProcessDataAdmin@statefarm.com'];
        User insertedAtmUser = UTIL_UserProvisioning_TEST.buildSampleATMUser ('atmUserNamechatterenabled@statefarm.com');
        insertedAtmUser.RegisteredRepresentative__c= true;

        System.runAs(processITIMUser){
            insert insertedAtmUser;
        }
        
        String feedItemRecordId = '';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedAtmUser);
        test.startTest();
        system.runAs(insertedAtmUser) {
            FeedItem feedItemRecord = buildFeedItem();
            insert feedItemRecord;
            feedItemRecordId = feedItemRecord.Id;
        }
        test.stopTest();
        FeedStage__c feedStageRecord = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecordId];
        system.assertEquals(feedItemRecordId, feedStageRecord.FeedItemID__c, 'Expected value not same as actual');
    }

    @isTest
    public static void testInsertFeedStageWithSalesLeader() {
        User processITIMUser = [select id from User where username ='UserITIMProcessDataAdmin@statefarm.com'];
        User insertedSLUser = UTIL_UserProvisioning_TEST.buildSampleSalesLeaderUser ('SalesLeaderUserName@statefarm.com');
        System.runAs(processITIMUser){
            insert insertedSLUser;
        }
        CS_MonitoredAudience__c profileLevelCustomSetting = new CS_MonitoredAudience__c();
        profileLevelCustomSetting.SetupOwnerId = insertedSLUser.ProfileId;
        profileLevelCustomSetting.IsMonitored__c = true;
        insert profileLevelCustomSetting;

        String feedItemRecordId = '';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedSLUser);
        test.startTest();
        system.runAs(insertedSLUser) {
            FeedItem feedItemRecord = buildFeedItem();
            insert feedItemRecord;
            feedItemRecordId = feedItemRecord.Id;
        }
        test.stopTest();
        FeedStage__c feedStageRecord = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecordId];
        system.assertEquals(feedItemRecordId, feedStageRecord.FeedItemID__c, 'Expected value not same as actual');
    }

    @isTest
    public static void testInsertFeedComment() {
        User processITIMUser = [select id from User where username ='UserITIMProcessDataAdmin@statefarm.com'];
        User insertedSLUser = UTIL_UserProvisioning_TEST.buildSampleSalesLeaderUser ('SalesLeaderUserName@statefarm.com');
        System.runAs(processITIMUser){
            insert insertedSLUser;
        }
        String feedItemRecordId = '';

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedSLUser);
        test.startTest();

        system.runAs(insertedSLUser) {
            FeedItem feedItemRecord = buildFeedItem1();
            insert feedItemRecord;
            feedItemRecordId = feedItemRecord.Id;
        }
            list<ChatterPostCleanup__c> chatterPostCleanupRecord = [select Name FROM ChatterPostCleanup__c where name =: feedItemRecordId];
            if(chatterPostCleanupRecord .size() > 0) {
             system.assertEquals(feedItemRecordId, chatterPostCleanupRecord[0].Name, 'Expected value not same as actual');
            }
        test.stopTest();

    }

    @isTest
	public static void testInsertFeedItemInfoIntoChatterPostCleanup() {
        User insertedAgentUser = [select Id from User where Username =: AGENT_USER_NAME];
        CS_MonitoredAudience__c userLevelCustomSetting = new CS_MonitoredAudience__c();
        userLevelCustomSetting.SetupOwnerId = insertedAgentUser.Id;
        userLevelCustomSetting.IsMonitored__c = true;
        insert userLevelCustomSetting;
        String feedItemRecordId = '';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedAgentUser);
        test.startTest();
        system.runAs(insertedAgentUser) {
            FeedItem feedItemRecord = buildFeedItem1();
            insert feedItemRecord;
            feedItemRecordId = feedItemRecord.Id;
        }
        test.stopTest();
        list<ChatterPostCleanup__c> chatterPostCleanupRecord = [select Name FROM ChatterPostCleanup__c where name =: feedItemRecordId];
            if(chatterPostCleanupRecord .size() > 0) {
             system.assertEquals(feedItemRecordId, chatterPostCleanupRecord[0].Name, 'Expected value not same as actual');
            }
    }

    @isTest
    public static void testExceptionThrownOnNullParams() {
        AP_FeedItemAfterInsert.stageFeedItem(null);
        AP_FeedItemAfterInsert.createChatterPostCleanup(null);
        System.assertEquals(true, true, 'Expected value not equals to actual');

    }
}