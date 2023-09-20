/**
  * @name AP_FeedItemBeforeInsert_TEST
  * @author  Golden Spikes Team
  * @createdDate 07/16/2015
  * @description Apex unit testing for FeedItemBeforeInsert Trigger
  */
@isTest (seeAllData=false)
private class AP_FeedItemBeforeInsert_TEST {

    private static User apiUser;
    private static User nonAPIUser;

    /**
      * @description Setup method used for building test data (must be called at beginning of test)
      * @name   setUp
      */
    public static void setUp(){
        apiUser = UTIL_TestDataCreationChatter_TEST.createAPITestUser();
        nonAPIUser = UTIL_TestDataCreationChatter_TEST.createNonAPITestUser('2.00 Agent');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
    }

    /**
      * @description Method to test if a non API user will execute the business logic for SPI Security Control
      * @name   testFeedItemBeforeInsertWithNonAPIUserAfterBreach
      */
     @isTest
     static void testFeedItemBeforeInsertWithNonAPIUserAfterBreach() {
        setUp();
        UTIL_SPITestDataCreationChatter_TEST.createSPIDataPreventionFieldsForFeedItem();
        UTIL_SPITestDataCreationChatter_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1, 'size of the spi security controls should be equal to 1');
        Test.StartTest();
        System.runas(nonAPIUser){
            try {
                UTIL_TestDataCreationChatter_TEST.createFeedItem('violation on the spi data \r\n 123-45-6789');
            } catch(Exception e) {
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.FEED_ITEM_ON_BREACH_ERROR_MSG), 'Exception message should contain UTIL_SPITestConstants.FEED_ITEM_ON_BREACH_ERROR_MSG');
            }
        }
        Test.StopTest();
    }

    /**
      * @description Method to test that an API user WILL NOT execute the business logic for SPI Security Control
      * @name   testFeedItemBeforeInsertWithAPIUserAfterBreach
      */
     @isTest
     static void testFeedItemBeforeInsertWithAPIUserAfterBreach() {
        setUp();
        UTIL_SPITestDataCreationChatter_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1, 'Size of the spi security controls should be equal to 1');
        Test.StartTest();
        System.runas(apiUser) {
            UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();
            UTIL_TestDataCreationChatter_TEST.createFeedItem('violation on the spi data \r\n 123-45-6789');
            List<FeedItem> feedItems = [select Id from FeedItem where ParentId =: Userinfo.getUserId()];
            System.assert(!feedItems.isEmpty(), 'Feed items should not be empty');
        }
        Test.StopTest();
    }
}