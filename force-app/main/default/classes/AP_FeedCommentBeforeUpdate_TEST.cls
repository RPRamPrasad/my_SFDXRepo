/**
  * @name AP_FeedCommentBeforeUpdate_TEST
  * @author Golden Spikes Team
  * @createdDate 07/16/2015
  * @description Apex unit testing for FeedCommentBeforeUpdate Trigger
  */
@isTest (seeAllData=false)
private class AP_FeedCommentBeforeUpdate_TEST {

    private static User apiUser;
    private static User nonAPIUser;

    /**
      * @description method Setup method used for building test data (must be called at beginning of test)
      * @name   setUp
      */
    public static void setUp() {
        apiUser = UTIL_TestDataCreationChatter_TEST.createAPITestUser();
        nonAPIUser = UTIL_TestDataCreationChatter_TEST.createNonAPITestUser('2.00 Agent');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
    }

    /**
      * @description Method to test if a non API user will execute the business logic for SPI Security Control
      * @name   testFeedCommentBeforeUpdateWithNonAPIUserAfterBreach
      */
     @isTest
    static void testFeedCommentBeforeUpdateWithNonAPIUserAfterBreach() {
        setUp();
        String feedCommentId;
        UTIL_SPITestDataCreationChatter_TEST.createSPIDataPreventionFieldsForFeedComment();
        UTIL_SPITestDataCreationChatter_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1, 'Size of the spi security controls should be equal to 1');
        Test.StartTest();
        System.runas(nonAPIUser){
            UTIL_TestDataCreationChatter_TEST.createFeedComment('Testing without SSN violation');
        }
        System.runas(apiUser){
            List<FeedComment> feedComments = [select id, CommentBody from FeedComment];
            System.assert(!feedComments.isEmpty(), 'feed comments should not be empty');
            feedCommentId = feedComments[0].id;
        }
        System.runas(nonAPIUser){
            FeedComment feedCommentUpdate = new FeedComment(id=feedCommentId, CommentBody ='Testing with SSN violation substituting the spi data \r\n 123-45-6789');
            try{
                update feedCommentUpdate;
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.FEED_COMMENT_ON_BREACH_ERROR_MSG), 'Exception message contains UTIL_SPITestConstants.FEED_COMMENT_ON_BREACH_ERROR_MSG');
            }
        }
        Test.StopTest();
    }

    /**
      * @description Method to test that an API user WILL NOT execute the business logic for SPI Security Control
      * @name   testFeedCommentBeforeUpdateWithAPIUserAfterBreach
      */
     @isTest
    static void testFeedCommentBeforeUpdateWithAPIUserAfterBreach() {
        setUp();
        UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();
        UTIL_SPITestDataCreationChatter_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1, 'Size of the spi security controls should be equal to 1');
        Test.StartTest();
        System.runas(apiUser){
            UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();
            UTIL_TestDataCreationChatter_TEST.createFeedComment('Testing without SSN violation');
            List<FeedComment> feedComments = [select Id,CommentBody from FeedComment];
            feedComments[0].CommentBody = 'Testing with SSN violation substituting the spi data \r\n 123-45-6789';
            update feedComments;
            List<FeedComment> updatedFeedComments = [select id, CommentBody from FeedComment];
            System.assertEquals('Testing with SSN violation substituting the spi data \r\n 123-45-6789', updatedFeedComments[0].CommentBody, 'Comment Body will be Updated feed comments');
        }
        Test.StopTest();
    }
}