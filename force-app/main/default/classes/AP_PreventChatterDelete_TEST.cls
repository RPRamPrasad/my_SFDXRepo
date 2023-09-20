/**
  * @name AP_PreventChatterDelete_TEST
  * @author  Golden Spikes Team
  * @createdDate 03/29/2016
  * @description Apex Unit Testing For AP_PreventChatterDelete Class
  */
@isTest (seeAllData=false)
public class AP_PreventChatterDelete_TEST {

    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;

    /**
    * @description Setup method used for building test data (must be called at beginning of test)
    * @name   setUp
    */
    public static void setUp(){
        sysAdminuser = UTIL_TestDataCreationChatter_TEST.createAPITestUser();
        agentUser = UTIL_TestDataCreationChatter_TEST.createNonAPITestUser('2.00 Agent');
        atmUser = UTIL_TestDataCreationChatter_TEST.createNonAPITestUser('2.01 Agent Team Member');
    }

    /*
    *   @Method <Method to test Agent user should not be able to delete the chatter FeedItem>
    *   @name testPreventChatterFeedDeleteWithAgentUser
    *   @param NONE
    *   @return void
    */
    @isTest
    static void testPreventChatterFeedDeleteWithAgentUser() {
        setUp();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        Test.StartTest();
        System.runas(agentUser) {
            AP_PreventChatterDelete.isBatch = true;
            UTIL_TestDataCreationChatter_TEST.createFeedItem('Testing Feed Item');
            List<UserFeed> userFeedItems = [Select id from UserFeed where ParentId =: Userinfo.getUserId()];
            System.assert(!userFeedItems.isEmpty(), 'User Feed Items Should not be empty');
            try {
                delete userFeedItems;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(label.CL_FeedItem_Prevent_Delete_Message), 'Exception message should contain label.CL_FeedItem_Prevent_Delete_Message');
            }
        }
        Test.StopTest();
    }

   /*
    *   @Method <Method to test Agent Team Member should not be able to delete the chatter FeedItem>
    *   @name testPreventChatterFeedDeleteWithAtmUser
    *   @param NONE
    *   @return void
    */
    @isTest
    static void testPreventChatterFeedDeleteWithAtmUser() {
        setUp();
        Test.StartTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUser);
        System.runas(atmUser) {
            UTIL_TestDataCreationChatter_TEST.createFeedItem('Testing Feed Item');
            List<UserFeed> userFeedItems = [Select id from UserFeed where ParentId =: Userinfo.getUserId()];
            System.assert(!userFeedItems.isEmpty(), 'User Feed Items Should not be Empty');
            try {
                delete userFeedItems;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(label.CL_FeedItem_Prevent_Delete_Message), 'Exception message should contain From label.CL_FeedItem_Prevent_Delete_Message');
            }
        }
        Test.StopTest();
    }

    /*
    *   @Method <Method to test System Admin user should be able to bypass the FeedItemBeforeDelete trigger and delete the Chatter FeedItem>
    *   @name testPreventChatterFeedDeleteWithSysAdminUser
    *   @param NONE
    *   @return void
    */
    @isTest
    static void testPreventChatterFeedDeleteWithSysAdminUser() {
        setUp();
        Test.StartTest();
        System.runas(sysAdminuser) {
            UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();
            UTIL_TestDataCreationChatter_TEST.createFeedItem('Testing Feed Item');
            List<UserFeed> userFeedItems = [Select id from UserFeed where ParentId =: Userinfo.getUserId()];
            System.assert(!userFeedItems.isEmpty(), 'User Feed Items Should not be Empty');
            delete userFeedItems;
            List<UserFeed> afterDeleteUserFeedItems = [Select id from UserFeed where ParentId =: Userinfo.getUserId()];
            System.assert(afterDeleteUserFeedItems.isEmpty(), 'After Delete User Feed Items is Empty');
        }
        Test.StopTest();
    }

   /*
    *   @Method <Method to test Agent user should not be able to delete the chatter FeedComment>
    *   @name testPreventChatterFeedCommentDeleteWithAgentUser
    *   @param NONE
    *   @return void
    */
    @isTest
    static void testPreventChatterFeedCommentDeleteWithAgentUser() {
        setUp();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        List<FeedComment> feedComments;
        Test.StartTest();
        System.runas(agentUser) {
            UTIL_TestDataCreationChatter_TEST.createFeedComment('Testing Feed Comment');
        }
        System.runas(sysAdminuser) {
            feedComments = [Select id from FeedComment];
            System.assert(!feedComments.isEmpty(), 'Feed Comments Should not be Empty');
        }
        System.runas(agentUser) {
            try {
                delete feedComments;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(label.CL_FeedComment_Prevent_Delete_Message), 'Exception message contains from label.CL_FeedComment_Prevent_Delete_Message');
            }
        }
        Test.StopTest();
    }

    /*
    *   @Method <Method to test Agent Team Member should not be able to delete the chatter FeedComment>
    *   @name testPreventChatterFeedCommentDeleteWithAtmUser
    *   @param NONE
    *   @return void
    */
    @isTest
    static void testPreventChatterFeedCommentDeleteWithAtmUser() {
        setUp();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUser);
        List<FeedComment> feedComments;
        Test.StartTest();
        System.runas(atmUser) {
            UTIL_TestDataCreationChatter_TEST.createFeedComment('Testing Feed Comment');
        }
        System.runas(sysAdminuser) {
            feedComments = [Select id from FeedComment];
            System.assert(!feedComments.isEmpty(), 'Feed Comments Should not be Empty');
        }
        System.runas(atmUser) {
            try {
                delete feedComments;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(label.CL_FeedComment_Prevent_Delete_Message), 'Exception message contains from label.CL_FeedComment_Prevent_Delete_Message');
            }
        }
        Test.StopTest();
    }

   /*
    *   @Method <Method to test System Admin user should be able to bypass the FeedCommentBeforeDelete trigger and delete the Chatter FeedComment>
    *   @name testPreventChatterFeedCommentDeleteWithSysAdminUser
    *   @param NONE
    *   @return void
    */
    @isTest
    static void testPreventChatterFeedCommentDeleteWithSysAdminUser() {
        setUp();
        Test.StartTest();
        System.runas(sysAdminuser) {
            UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();
            UTIL_TestDataCreationChatter_TEST.createFeedComment('Testing Feed Comment');
            List<FeedComment> feedComments = [Select id from FeedComment];
            System.assert(!feedComments.isEmpty(), 'Feed Comments should not be Empty');
            delete feedComments;
            List<FeedComment> afterDeleteFeedComments = [Select id from FeedComment];
            System.Assert(afterDeleteFeedComments.IsEmpty(), 'After Delete Feed Comments is Empty');
        }
        Test.StopTest();
    }
}