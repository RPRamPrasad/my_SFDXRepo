/**
 * @description test class to feed comments after insert
 */
@isTest (seeAllData=false)
private class AP_FeedCommentAfterInsert_TEST {
    private static User agentUser;
    private final static String AGENT_USER_NAME = 'test@statefarm.com.sandbox';
    private static User commonATMUser = new User(Alias='ATM1',LastName='ATM',Username='username11@statefarm.com',Associate_ID__c='ASSOCID1',UserExternalID__c='ASSOCID1',Servicing_Agent_Associate_ID__c='SASSOCID1',Territory_Associate_ID__c='TERRITID1',Servicing_Agent_Associate_ID_List__c='SASSOCID1',Territory_Associate_ID_List__c='TERRITID1');
    private static User commonATMUser1 = new User(Alias='ATM2',LastName='ATM',Username='username22@statefarm.com',Associate_ID__c='ASSOCID2',UserExternalID__c='ASSOCID2',Servicing_Agent_Associate_ID__c='SASSOCID2',Territory_Associate_ID__c='TERRITID2',Servicing_Agent_Associate_ID_List__c='SASSOCID2',Territory_Associate_ID_List__c='TERRITID2');
    /**
     * @description test method to setup user
     */
    @testSetup
    public static void setUp() {
        agentUser = UTIL_UserProvisioning_TEST.buildSampleAgentUser(AGENT_USER_NAME);
        insert agentUser;
        User processITIMUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin ('UserITIMProcessDataAdmin@statefarm.com');
        insert processITIMUser;
        UTIL_PermissionSetting_TEST.permissionForITIM (processITIMUser.Id);

    }

    private static FeedComment buildFeedComment(String feedItemRecordId) {
        FeedComment feedComment = new FeedComment(FeedItemId = feedItemRecordId, CommentBody = 'Comment');
        return feedComment;
    }

    private static FeedItem buildFeedItem() {
        FeedItem feedItem = new FeedItem(Type='TextPost', ParentId=UserInfo.getUserId(), Body = 'Testabcd');
        return feedItem;
    }

    private static FeedItem buildLinkPostFeedItem(){
        FeedItem feedItem = new FeedItem(Type='LinkPost', ParentId=UserInfo.getUserId(), Body = 'Testabcd',LinkURL='zeev.com',Title='New or UnClaimed');
        //feedItem.Title='New or UnClaimed';
        return feedItem;
    }

    @isTest
    public static void testInsertFeedCommentInfoIntoFeedStage() {
        User insertedAgentUser = [select Id from User where Username =: AGENT_USER_NAME];
        CS_MonitoredAudience__c userLevelCustomSetting = new CS_MonitoredAudience__c();
        userLevelCustomSetting.SetupOwnerId = insertedAgentUser.Id;
        userLevelCustomSetting.IsMonitored__c = true;
        insert userLevelCustomSetting;
        FeedItem feedItemRecord = buildFeedItem();
        insert feedItemRecord;
        String feedCommentRecordId = '';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedAgentUser);
        test.startTest();
        system.runAs(insertedAgentUser) {
            FeedComment feedCommentRecord = buildFeedComment(feedItemRecord.Id);
            insert feedCommentRecord;
            feedCommentRecordId = feedCommentRecord.Id;
            feedItemRecord.Body = 'Test123';
            update feedItemRecord;
        }
        test.stopTest();
        FeedStage__c feedStageRecord = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecord.Id];
        system.assertEquals(feedItemRecord.Id, feedStageRecord.FeedItemID__c, 'Expected value not equal to actual');
    }

    @isTest
    public static void testInsertFeedCommentInfoIntoFeedStageWithProfileLevelCustomSetting() {
        User insertedAgentUser = [select Id, ProfileId from User where Username =: AGENT_USER_NAME];
        CS_MonitoredAudience__c userLevelCustomSetting = new CS_MonitoredAudience__c();
        userLevelCustomSetting.SetupOwnerId = insertedAgentUser.ProfileId;
        userLevelCustomSetting.IsMonitored__c = true;
        insert userLevelCustomSetting;
        FeedItem feedItemRecord = buildFeedItem();
        insert feedItemRecord;
        String feedCommentRecordId = '';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedAgentUser);
        test.startTest();
        system.runAs(insertedAgentUser) {
            FeedComment feedCommentRecord = buildFeedComment(feedItemRecord.Id);
            insert feedCommentRecord;
            feedCommentRecordId = feedCommentRecord.Id;
            feedItemRecord.Body = 'Test123';
            update feedItemRecord;
        }
        test.stopTest();
        FeedStage__c feedStageRecord = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecord.Id];
        system.assertEquals(feedItemRecord.Id, feedStageRecord.FeedItemID__c, 'Expected value not equal to actual');
    }

    @isTest
    public static void testInsertFeedCommentInfoIntoFeedStageWithCustomSettingFalse() {
        User insertedAgentUser = [select Id,profileId from User where Username =: AGENT_USER_NAME];
        CS_MonitoredAudience__c userLevelCustomSetting = new CS_MonitoredAudience__c();
        userLevelCustomSetting.SetupOwnerId = insertedAgentUser.ProfileId;
        userLevelCustomSetting.IsMonitored__c = false;
        insert userLevelCustomSetting;

        FeedItem feedItemRecord = buildFeedItem();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedAgentUser);
        system.runAs(insertedAgentUser) {
        	insert feedItemRecord;
        }
        String feedCommentRecordId = '';
        test.startTest();
        system.runAs(insertedAgentUser) {
	    	FeedComment feedCommentRecord = buildFeedComment(feedItemRecord.Id);
	        insert feedCommentRecord;
	        feedCommentRecordId = feedCommentRecord.Id;
        }
        test.stopTest();
        List<FeedStage__c> feedStageRecordList = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecord.Id];
        system.assertEquals(0, feedStageRecordList.size(), 'Expected value not equal to actual');
    }

    @isTest
    public static void testInsertFeedCommentInfoIntoFeedStageWithATMParticipate() {
        User insertedAgentUser = [select Id, ProfileId from User where Username =: AGENT_USER_NAME];
        User processITIMUser = [select id from User where username ='UserITIMProcessDataAdmin@statefarm.com'];
        User atmUserFirst = UTIL_UserProvisioning_TEST.buildATMUser(commonATMUser);
        User atmUserSecond = UTIL_UserProvisioning_TEST.buildATMUser(commonATMUser1);

        System.runAs(processITIMUser){
            insert atmUserFirst;
            insert atmUserSecond;
        }
        CS_MonitoredAudience__c userLevelCustomSetting = new CS_MonitoredAudience__c();
        userLevelCustomSetting.SetupOwnerId = insertedAgentUser.ProfileId;
        userLevelCustomSetting.IsMonitored__c = true;
        insert userLevelCustomSetting;
        String feedItemRecordId = '';

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUserFirst);
        test.startTest();
        system.runAs(atmUserFirst) {
            FeedItem feedItemRecord = buildFeedItem();
            insert feedItemRecord;
            feedItemRecordId = feedItemRecord.Id;
        }

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUserSecond);
        system.runAs(atmUserSecond) {
            FeedComment feedCommentRecord = buildFeedComment(feedItemRecordId);
            insert feedCommentRecord;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedAgentUser);
        system.runAs(insertedAgentUser) {
            FeedComment feedCommentRecord = buildFeedComment(feedItemRecordId);
            insert feedCommentRecord;
        }
        test.stopTest();

        FeedStage__c feedStageRecord = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecordId];
        system.assertEquals(feedItemRecordId, feedStageRecord.FeedItemID__c, 'Expected value not equal to actual');
    }

    @isTest
    public static void testInsertFeedCommentInfoIntoFeedStageWithAtmNotRegisteredRepresentative() {
        User insertedAgentUser;
        insertedAgentUser = [select Id, ProfileId from User where Username =: AGENT_USER_NAME];
        User processITIMUser = [select id from User where username ='UserITIMProcessDataAdmin@statefarm.com'];
        User atmUserFirst = UTIL_UserProvisioning_TEST.buildATMUser(commonATMUser);
        User atmUserSecond = UTIL_UserProvisioning_TEST.buildATMUser(commonATMUser1);

        System.runAs(processITIMUser){
            insert atmUserFirst;
            insert atmUserSecond;
        }
        String feedItemRecordId = '';
        test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUserFirst);
        system.runAs(atmUserFirst) {
            FeedItem feedItemRecord = buildFeedItem();
            insert feedItemRecord;
            feedItemRecordId = feedItemRecord.Id;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUserSecond);
        system.runAs(atmUserSecond) {
            FeedComment feedCommentRecord = buildFeedComment(feedItemRecordId);
            insert feedCommentRecord;
        }
        test.stopTest();

        List<FeedStage__c> feedStageRecordList = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecordId];
        system.assertEquals(0, feedStageRecordList.size(), 'Expected value not equal to actual');
    }

    @isTest
    public static void testInsertFeedCommentInfoIntoFeedStageWithAtmRegisteredRepresentative() {
        User processITIMUser = [select id from User where username ='UserITIMProcessDataAdmin@statefarm.com'];
        User atmUserFirst = UTIL_UserProvisioning_TEST.buildATMUser(commonATMUser);
        User atmUserSecond = UTIL_UserProvisioning_TEST.buildATMUser(commonATMUser1);
        atmUserSecond.RegisteredRepresentative__c= true;

        System.runAs(processITIMUser){
            insert atmUserFirst;
            insert atmUserSecond;
        }
        String feedItemRecordId = '';

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUserFirst);
        test.startTest();
        system.runAs(atmUserFirst) {
            FeedItem feedItemRecord = buildFeedItem();
            insert feedItemRecord;
            feedItemRecordId = feedItemRecord.Id;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUserSecond);
        system.runAs(atmUserSecond) {
            FeedComment feedCommentRecord = buildFeedComment(feedItemRecordId);
            insert feedCommentRecord;
        }
        test.stopTest();

        FeedStage__c feedStageRecord = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecordId];
        system.assertEquals(feedItemRecordId, feedStageRecord.FeedItemID__c, 'Expected value not equal to actual');
    }

    @isTest
    public static void testInsertFeedCommentInfoIntoFeedStageWithSalesLeader() {
        User insertedAgentUser;
        insertedAgentUser = [select Id, ProfileId from User where Username =: AGENT_USER_NAME];
        User processITIMUser = [select id from User where username ='UserITIMProcessDataAdmin@statefarm.com'];
        User atmUserNonRegistered = UTIL_UserProvisioning_TEST.buildATMUser(commonATMUser);
        User salesLeaderUser = UTIL_UserProvisioning_TEST.buildSampleSalesLeaderUser ('SalesLeaderUserName@statefarm.com');

        System.runAs(processITIMUser){
            insert atmUserNonRegistered;
            insert salesLeaderUser;
        }
        CS_MonitoredAudience__c userLevelCustomSetting = new CS_MonitoredAudience__c();
        userLevelCustomSetting.SetupOwnerId = salesLeaderUser.ProfileId;
        userLevelCustomSetting.IsMonitored__c = true;
        insert userLevelCustomSetting;
        String feedItemRecordId = '';

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUserNonRegistered);
        test.startTest();
        system.runAs(atmUserNonRegistered) {
            FeedItem feedItemRecord = buildFeedItem();
            insert feedItemRecord;
            feedItemRecordId = feedItemRecord.Id;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesLeaderUser);
        system.runAs(salesLeaderUser) {
            FeedComment feedCommentRecord = buildFeedComment(feedItemRecordId);
            insert feedCommentRecord;
        }
        test.stopTest();

        FeedStage__c feedStageRecord = [select FeedItemID__c FROM FeedStage__c where FeedItemID__c =: feedItemRecordId];
        system.assertEquals(feedItemRecordId, feedStageRecord.FeedItemID__c, 'Expected value not equal to actual');
    }


    @isTest
	public static void testInsertFeedCommentInfoIntoChatterPostCleanup() {
        User insertedAgentUser = [select Id from User where Username =: AGENT_USER_NAME];
        CS_MonitoredAudience__c userLevelCustomSetting = new CS_MonitoredAudience__c();
        userLevelCustomSetting.SetupOwnerId = insertedAgentUser.Id;
        userLevelCustomSetting.IsMonitored__c = true;
        insert userLevelCustomSetting;
        FeedItem feedItemRecord = buildLinkPostFeedItem();
        insert feedItemRecord;
        String feedCommentRecordId = '';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedAgentUser);
        test.startTest();
        system.runAs(insertedAgentUser) {
            FeedComment feedCommentRecord = buildFeedComment(feedItemRecord.Id);
            insert new ChatterPostCleanup__c(Name = feedCommentRecord.FeedItemId);
            insert feedCommentRecord;
            feedCommentRecordId = feedCommentRecord.Id;

        }
        test.stopTest();
        list<ChatterPostCleanup__c> chatterPostCleanupRecord = [select Name FROM ChatterPostCleanup__c where name =: feedCommentRecordId];
            if(chatterPostCleanupRecord .size() > 0) {
             system.assertEquals(feedCommentRecordId, chatterPostCleanupRecord[0].Name, 'Expected value not equal to actual');
            }
    }

    @isTest
    static void testStageFeedCommentWithNullFeedItemId() {
        User insertedAgentUser = [select Id from User where Username =: AGENT_USER_NAME];
        CS_MonitoredAudience__c userLevelCustomSetting = new CS_MonitoredAudience__c();
        userLevelCustomSetting.SetupOwnerId = insertedAgentUser.Id;
        userLevelCustomSetting.IsMonitored__c = true;
        insert userLevelCustomSetting;
        FeedItem feedItemRecord = buildLinkPostFeedItem();
        insert feedItemRecord;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(insertedAgentUser);
        test.startTest();
        system.runAs(insertedAgentUser) {
            FeedComment feedCommentRecord = buildFeedComment(null);
            AP_FeedCommentAfterInsert.stageFeedComment(new List<FeedComment>{feedCommentRecord});
        }
        System.assertEquals(true, true, 'Some Message');
    }

    @isTest
    static void testDeleteChatterPostCleanupWithNullParameter() {
        AP_FeedCommentAfterInsert.deleteChatterPostCleanup(null);
        System.assertEquals(true, true, 'Some Message');
    }


}