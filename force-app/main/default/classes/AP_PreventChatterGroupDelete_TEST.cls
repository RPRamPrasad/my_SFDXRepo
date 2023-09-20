/**
  * @name AP_PreventChatterGroupDelete_TEST
  * @author  Golden Spikes Team
  * @createdDate 06/24/2016
  * @description Apex Unit Testing For AP_PreventChatterGroupDelete Class
  */
@isTest (seeAllData=false)
public class AP_PreventChatterGroupDelete_TEST {

    private static User sysAdminuser;
    private static User agentUser;
    private static User businessSupportUser;

    /**
    * @description Setup method used for building test data (must be called at beginning of test)
    * @name   setUp
    */
    public static void setUp() {
        sysAdminuser = UTIL_TestDataCreationChatter_TEST.createAPITestUser();
        agentUser = UTIL_TestDataCreationChatter_TEST.createNonAPITestUser('2.00 Agent');
        businessSupportUser =  UTIL_TestDataCreationChatter_TEST.createNonAPITestUser('1.06 Business Reporting and Analytics');
    }

   /*
    *   @Method <Method to test Agent user should not be able to delete a Chatter Group when it has atleast one Group Post>
    *   @name testPreventChatterGroupDeleteWithAgentUserWithPost
    *   @param NONE
    *   @return void
    */
    @isTest
    static void testPreventChatterGroupDeleteWithAgentUserWithPost() {
        setUp();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        Test.StartTest();
        System.runas(agentUser) {
            UTIL_TestDataCreationChatter_TEST.createChatterGroupFeed();
            List<CollaborationGroup> chatterGrouptest = [Select id from CollaborationGroup where OwnerId =:Userinfo.getUserId()];
            System.assert(!chatterGrouptest.isEmpty(), 'Chatter Group Test should not be Empty');
            try {
                delete chatterGrouptest;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(label.CL_ChatterGroup_Prevent_Delete_Message), 'Exception message contains from label.CL_ChatterGroup_Prevent_Delete_Message');
            }
        }
       Test.StopTest();
    }

   /*
    *   @Method <Method to test Agent user should be able to delete a Chatter Group with no Group Posts>
    *   @name testChatterGroupDeleteWithAgentUserWithNoPost
    *   @param NONE
    *   @return void
    */
    @isTest
    static void testChatterGroupDeleteWithAgentUserWithNoPost() {
        setUp();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        Test.StartTest();
        System.runas(agentUser) {
            UTIL_TestDataCreationChatter_TEST.createChatterGroup();
            List<CollaborationGroup> chatterGrouptest = [Select id from CollaborationGroup where OwnerId =:Userinfo.getUserId()];
            System.assert(!chatterGrouptest.isEmpty(), 'Chatter group test should not be empty');
            delete chatterGrouptest;
            List<CollaborationGroup> afterDeleteChatterGroup = [Select id from CollaborationGroup where OwnerId =:Userinfo.getUserId()];
            System.assert(afterDeleteChatterGroup.isEmpty(), 'After delete chatter group is empty');
        }
        Test.StopTest();
    }

   /*
    *   @Method <Method to test Business Support user should be able to delete a Chatter Group with no Group Posts>
    *   @name testChatterGroupDeleteWithBusinessUserWithNoPost
    *   @param NONE
    *   @return void
    */
    @isTest
    static void testChatterGroupDeleteWithBusinessUserWithNoPost() {
        setUp();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(businessSupportUser);
        Test.StartTest();
        System.runas(businessSupportUser) {
            UTIL_TestDataCreationChatter_TEST.createChatterGroup();
            List<CollaborationGroup> chatterGrouptest = [Select id from CollaborationGroup where OwnerId =:Userinfo.getUserId()];
            System.assert(!chatterGrouptest.isEmpty(), 'Chatter group test should not be empty');
            delete chatterGrouptest;
            List<CollaborationGroup> afterDeleteChatterGroup = [Select id from CollaborationGroup where OwnerId =:Userinfo.getUserId()];
            System.assert(afterDeleteChatterGroup.isEmpty(), 'After delete chatter group is empty');
        }
        Test.StopTest();
    }

   /*
    *   @Method <Method to test System Admin user should be able to overide the prevent Group delete trigger and able to delete a Chatter Group, with posts in it.>
    *   @name testChatterGroupDeleteWithSysAdminUserWithPost
    *   @param NONE
    *   @return void
    */
    @isTest
    static void testChatterGroupDeleteWithSysAdminUserWithPost() {
        setUp();
        Test.StartTest();
        System.runas(sysAdminuser) {
            UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();
            UTIL_TestDataCreationChatter_TEST.createChatterGroupFeed();
            List<CollaborationGroup> chatterGrouptest = [Select id from CollaborationGroup where OwnerId =:Userinfo.getUserId()];
            System.assert(!chatterGrouptest.isEmpty(), 'chatter group test should not be empty');
            delete chatterGrouptest;
            List<CollaborationGroup> afterDeleteChatterGroup = [Select id from CollaborationGroup where OwnerId =:Userinfo.getUserId()];
            System.assert(afterDeleteChatterGroup.isEmpty(), 'After delete chatter group is empty');
        }
        Test.StopTest();
    }
}