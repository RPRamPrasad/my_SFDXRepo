/**
  *    Author          : Golden Spikes Team
  *    Date Created    : 03/29/2016
  *    Description     : Apex unit testing for AP_SPISecurityManager for Chatter
  */

/**
  *    Author          : Loco Motivated Team
  *    Date Created    : 04/01/2017
  *    @description    : Apex unit testing for AP_SPISecurityManager for Chatter
  */
@isTest (seeAllData=false)
public class AP_SPISecurityManagerChatter_TEST {

    private static User nonAPIUser;
    private static User apiUser;

    /**
    * @description Setup method used for building test data (must be called at beginning of test)
    * @name   setUp
    */
    public static void setUp() {
        nonAPIUser = UTIL_TestDataCreationChatter_TEST.createNonAPITestUser('2.00 Agent');
        apiUser = UTIL_TestDataCreationChatter_TEST.createAPITestUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
    }

  /**
    * @description Method to test FeedItem with SPI violation for No split text
    * @name   testHandleFeedItemWithSPIViolationForNoSplitText
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForNoSplitText() {
        UTIL_SPITestDataCreationChatter_TEST.testHandleFeedItemWithSPIViolation('Testing FeedItem with SSN 123-45-6789');
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @description Method to test FeedItem with SPI violation for Rich Text
    * @name   testHandleFeedItemWithSPIViolationWithRichText
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationWithRichText() {
        String richTextForFeedItem = '<p><b>rrrrrr &nbsp; rrrrr</b><i>wwwwww </i><u>vvvvvv</u> <s>rrrrrrr</s> wwww</p><ol><li>1234567 rrrrrrrr</li><li>wwww</li></ol><p> </p><ul><li>rrrrrrrr</li><li>wwww</li></ul>';
        UTIL_SPITestDataCreationChatter_TEST.testHandleFeedItemWithSPIViolation(richTextForFeedItem);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @description Method to test Feed Item with SPI violation for carriageReturn and new line
    * @name   testHandleFeedItemWithSPIViolationForCarriageReturnAndNewLine
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForCarriageReturnAndNewLine() {
        UTIL_SPITestDataCreationChatter_TEST.testHandleFeedItemWithSPIViolation('violation on the spi data \r\n 123-45-6789');
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @description Method to test Feed Item with SPI violation for carriageReturn
    * @name   testHandleFeedItemWithSPIViolationForCarriageReturn
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForCarriageReturn() {
        UTIL_SPITestDataCreationChatter_TEST.testHandleFeedItemWithSPIViolation('violation substituting the spi data \r 123-45-6789');
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @description Method to test Feed Item with SPI violation for New Line
    * @name   testHandleFeedItemWithSPIViolationForNewLine
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForNewLine() {
        UTIL_SPITestDataCreationChatter_TEST.testHandleFeedItemWithSPIViolation('violation the spi data \n 123-45-6789');
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

     /**
    * @description Method to test Feed Item with SPI violation for New Line
    * @name   testHandleFeedItemWithSPIViolationForNewLine
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForNewLineAfterText() {
        UTIL_SPITestDataCreationChatter_TEST.testHandleFeedItemWithSPIViolation('Mr. X called and gave us Mr. Ys SSN:\n 123456789');
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @description Method to test Feed Item with SPI violation for LongText In FirstChunk
    * @name   testHandleFeedItemWithSPIViolationForLongTextInFirstChunk
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForLongTextInFirstChunk(){

        UTIL_SPITestDataCreationChatter_TEST.testHandleFeedItemWithSPIViolation(UTIL_SPITestDataCreationChatter_TEST.createLongSPIDataAndAddSPIdataInFirstChunk());
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @description Method to test Feed Item with SPI violation for LongText In between two Chunks
    * @name   testHandleFeedItemWithSPIViolationForLongTextInEdgeOfChunk
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForLongTextInEdgeOfChunk(){

        UTIL_SPITestDataCreationChatter_TEST.testHandleFeedItemWithSPIViolation(UTIL_SPITestDataCreationChatter_TEST.createLongSPIDataAndAddSPIInEdgeOfChunks());
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
    /**
    * @description Method to test Feed Item with SPI violation for LongText In last Chunk
    * @name   testHandleFeedItemWithSPIViolationForLongTextInLastChunk
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForLongTextInLastChunk(){

        UTIL_SPITestDataCreationChatter_TEST.testHandleFeedItemWithSPIViolation(UTIL_SPITestDataCreationChatter_TEST.createLongSPIDataAndAddSPIAtEndOfString());
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @description Method to test Feed Item with SPI violation for LongText In first Chunk with exact demonimator of chunk size
    * @name   testHandleFeedItemWithSPIViolationForTextWhichIsDenominatorOfChunkSizeAndSPIInFirstChunk
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForTextWhichIsDenominatorOfChunkSizeAndSPIInFirstChunk(){

        UTIL_SPITestDataCreationChatter_TEST.testHandleFeedItemWithSPIViolation(UTIL_SPITestDataCreationChatter_TEST.createLongSPIDataWithExactDemonimatorOfChunkSizeAndAddSPIdataInFirstChunk());
        System.assert(true, 'Mandatory Assert statement on Tests');
    }


  /**
    * @description Method to test Feed Item with SPI violation for MultipleNew Line
    * @name   testHandleFeedItemWithSPIViolationForMultipleNewLine
    */
   @isTest
   static void testHandleFeedItemWithSPIViolationForMultipleNewLine() {
       UTIL_SPITestDataCreationChatter_TEST.testHandleFeedItemWithSPIViolation('123-45-6789 violation the spi data \n\n\n 123-45-6789');
       System.assert(true, 'Mandatory Assert statement on Tests');
    }

    /**
    * @description Method to test Feed Item with SPI violation for No split text
    * @name   testHandleFeedItemsWithSPIViolationForMultipleFields
    */
   @isTest
   static void testHandleFeedItemsWithSPIViolationForMultipleFields(){
        setUp();
        AP_SPISecurityManager spiSecurityManager = new AP_SPISecurityManager();
        UTIL_SPITestDataCreationChatter_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1, 'Size of the spiSecurityControls should be equal to 1');
        UTIL_SPITestDataCreationChatter_TEST.createMultipleSPIDataPreventionFieldsForFeedItems();
        UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
        Test.StartTest();
        System.runas(nonAPIUser){
            try{
               spiSecurityManager.handle(UTIL_TestDataCreationChatter_TEST.createFeedItem('Testing FeedItem with SSN 123-45-6789'));
            } catch(Exception e){
               System.assert(e.getMessage().contains(UTIL_SPITestConstants.FEED_ITEM_NO_LABEL_BREACH_ERROR_MSG), 'Exception message contains from UTIL_SPITestConstants.FEED_ITEM_NO_LABEL_BREACH_ERROR_MSG');
            }
        }
        Test.StopTest();
    }

    /**
    * @description Method to test Feed Item with SPI violation for No split text
    * @name   testHandleFeedItemWithSPIViolationForException
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForException(){
        setUp();
        AP_SPISecurityManager spiSecurityManager = new AP_SPISecurityManager();
        UTIL_SPITestDataCreationChatter_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1, 'Size of spisecuritycontrols should be equal to 1');
        UTIL_SPITestDataCreationChatter_TEST.createSPIDataPreventionFieldsForFeedItemsWithoutObjectLabel();
        UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
        Test.StartTest();
        System.runas(nonAPIUser){
            try{
                spiSecurityManager.handle(UTIL_TestDataCreationChatter_TEST.createFeedItem('Testing FeedItem with SSN 123-45-6789'));
            } catch(Exception e){
                System.assert(!e.getMessage().contains(UTIL_SPITestConstants.FEED_ITEM_ON_BREACH_ERROR_MSG), 'Exception message contains from UTIL_SPITestConstants.FEED_ITEM_ON_BREACH_ERROR_MSG');
            }
        }
        Test.StopTest();
    }
}