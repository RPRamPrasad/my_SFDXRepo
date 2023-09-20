/**
  *    Author          : Golden Spikes Team
  *    Date Created    : 03/29/2016
  *    Description     : Utility class used by Test Methods.
  */

/**
  *    Author          : Loco Motivated
  *    Date Created    : 04/01/2017
  *    Description     : Utility class used by Test Methods.
  */


/**
  *    Author          : Loco Motivated
  *    Date Created    : 04/21/2017
  *    @description     : Utility class used by Test Methods for SPI.
  */
@isTest (seeAllData=false)
public class UTIL_SPITestDataCreationChatter_TEST {

   /**
    *   @description <This method is used to insert record into SPI Data Prevention Fields Custom settings for Feed Item object>
    *   @name createSPIDataPreventionFieldsForFeedItem
    */
    public static void createSPIDataPreventionFieldsForFeedItem(){
        List<CS_SPI_Data_Prevention_Fields__c> customSettings = new List<CS_SPI_Data_Prevention_Fields__c>();
        CS_SPI_Data_Prevention_Fields__c setting =  new CS_SPI_Data_Prevention_Fields__c(Name = '1', Object_Api_Name__c = 'FeedItem',
        Field_Api_Name__c = 'Body',  Field_Label__c='Feed Post', Object_Label__c='Chatter', Is_Rich_Text__c = true);
        customSettings.add(setting);
        insert customSettings;
        List<CS_SPI_Data_Prevention_Fields__c> cs = CS_SPI_Data_Prevention_Fields__c.getAll().values();
        System.assert(cs.size() == 1, '');
    }

   /**
    *   @description <This method is used to insert record into SPI Data Prevention Fields Custom Settings for Feed Item object with no object label>
    *   @name createSPIDataPreventionFieldsForFeedItemsWithoutObjectLabel
    */
    public static void createSPIDataPreventionFieldsForFeedItemsWithoutObjectLabel(){
        List<CS_SPI_Data_Prevention_Fields__c> customSettings = new List<CS_SPI_Data_Prevention_Fields__c>();
        CS_SPI_Data_Prevention_Fields__c setting =  new CS_SPI_Data_Prevention_Fields__c(Name = '1', Object_Api_Name__c = 'FeedItem',
        Field_Api_Name__c = 'Body', Field_Label__c='Feed Post',Object_Label__c='');
        customSettings.add(setting);
        insert customSettings;
        List<CS_SPI_Data_Prevention_Fields__c> cs = CS_SPI_Data_Prevention_Fields__c.getAll().values();
        System.assert(cs.size() == 1, 'List of cs is equal to 1');
    }

   /**
    *   @description <This method is used to insert multiple records into SPI Data Prevention Fields for a FeedItem object>
    *   @name createMultipleSPIDataPreventionFieldsForFeedItems
    */
    public static void createMultipleSPIDataPreventionFieldsForFeedItems(){
        List<CS_SPI_Data_Prevention_Fields__c> customSettings = new List<CS_SPI_Data_Prevention_Fields__c>();
        CS_SPI_Data_Prevention_Fields__c setting1 =  new CS_SPI_Data_Prevention_Fields__c(Name = '1', Object_Api_Name__c = 'FeedItem',
        Field_Api_Name__c = 'Body', Field_Label__c='',Object_Label__c='Chatter');
        CS_SPI_Data_Prevention_Fields__c setting2 =  new CS_SPI_Data_Prevention_Fields__c(Name = '2', Object_Api_Name__c = 'FeedItem',
        Field_Api_Name__c = 'Title', Field_Label__c='Feed Post',Object_Label__c='Chatter');

        customSettings.add(setting1);
        customSettings.add(setting2);
        insert customSettings;
        List<CS_SPI_Data_Prevention_Fields__c> cs = CS_SPI_Data_Prevention_Fields__c.getAll().values();
        System.assert(cs.size() == 2, 'Size of the list of cs is equal to 2');
    }

   /**
    *   @description <This method is used to insert record into SPI Data Prevention Fields for Feed Comment object>
    *   @name createSPIDataPreventionFieldsForFeedComment
    */
    public static void createSPIDataPreventionFieldsForFeedComment(){
        List<CS_SPI_Data_Prevention_Fields__c> customSettings = new List<CS_SPI_Data_Prevention_Fields__c>();
        CS_SPI_Data_Prevention_Fields__c setting =  new CS_SPI_Data_Prevention_Fields__c(Name = '1', Object_Api_Name__c = 'FeedComment',
        Field_Api_Name__c = 'CommentBody',Field_Label__c='Feed Comment',Object_Label__c='Chatter');
        customSettings.add(setting);
        insert customSettings;
        List<CS_SPI_Data_Prevention_Fields__c> cs = CS_SPI_Data_Prevention_Fields__c.getAll().values();
        System.assert(cs.size() == 1, 'size of the list cs is equal to 1');
    }

   /**
    *   @description <This method is used to insert TEST SPI Security Control record for US SSN Pattern to prevent on Breach>
    *   @name createSPISecurityControlForUSSSNPatternPreventOnBreach
    */
    public static void createSPISecurityControlForUSSSNPatternPreventOnBreach() {

        SPI_Security_Control__c spiControl = new SPI_Security_Control__c();
        spiControl.Name = 'US SSN';
        spiControl.Active__c = true;
        spiControl.Unique_Error_Message__c = 'Sensitive Personal Information (SPI) is not allowed to be entered in the {!object} {!field} field.';
        spiControl.Regex_Pattern__c = '(?!000|666|9\\d{2})\\d{3}[_\\W]?(?!00)\\d{2}[_\\W]?(?!0000)\\d{4}';
        insert spiControl;
    }

   /**
    *   @description <This method is used to create long text with SPI data in first chunk>
    *   @name createLongSPIDataAndAddSPIdataInFirstChunk
    *   @return Big String text with SPI data in First Chunk
    */
    public static String createLongSPIDataAndAddSPIdataInFirstChunk(){
        String bigStr='';
        String spiStr=' We got the SSN : 234-45-7364 from one of the customer ';
        String smallStr='SPI validation feature will restrict agents to enter SPI data in freeform';
        do{
            if (bigStr.length()>444 && bigStr.length()<544){
                bigStr=bigStr+spiStr;
            }
            bigStr=bigStr+smallStr;
        }while(bigStr.length()<2890);
        return bigStr;
    }

   /**
    *   @description <This method is used to create long text with SPI data in First chunk with exact demonimator of chunk size>
    *   @name createLongSPIDataWithExactDemonimatorOfChunkSizeAndAddSPIdataInFirstChunk
    *   @return Big String text with SPI data in first chunk with exact demonimator text of chunk size
    */
    public static String createLongSPIDataWithExactDemonimatorOfChunkSizeAndAddSPIdataInFirstChunk(){
        String mediumStr='';
        String spiStr=' We got the SSN : 234-45-7364 from one of the customer ';
        String smallStr='SPI validation feature will restrict agents to enter SPI data in freeform';
        do{
            if (mediumStr.length()>444 && mediumStr.length()<544){
                mediumStr=mediumStr+spiStr;
            }
            mediumStr=mediumStr+smallStr;
        }while(mediumStr.length()<3000);
        return mediumStr.left(3000);
    }

   /**
    *   @description <This method is used to create long text with SPI data in between two chunks>
    *   @name createLongSPIDataAndAddSPIInEdgeOfChunks
    *   @return Big String text with SPI data in in between two chunks
    */

    public static String createLongSPIDataAndAddSPIInEdgeOfChunks(){
        String firstChunk='';
        String fullStr='';
        String spiData='We got the SSN : 234-45-7364 from one of the customer ';
        String smallData='SPI validation feature will restrict agents to enter SPI data in freeform ';

        do {
            firstChunk=firstChunk+smallData;
        }while(firstChunk.length()<1480);

        fullStr=firstChunk+spiData;

        do {
            fullStr=fullStr+smallData;
        }while(fullStr.length()<2890);
        return fullStr;
    }

   /**
    *   @description <This method is used to create long text with SPI data at the end chunk of long string>
    *   @name createLongSPIDataAndAddSPIAtEndOfString
    *   @return Big String text with SPI data at the end chunk of long string
    */
    public static String createLongSPIDataAndAddSPIAtEndOfString(){
        String growingStr='';
        String finalStr='';
        String spiData=' We got the SSN : 234-45-7364 from one of the customer ';
        String smallStr='SPI validation feature will restrict agents to enter SPI data in freeform';

        do{
            growingStr=growingStr+smallStr;
        }while(growingStr.length()<2500);
        finalStr=growingStr+spiData;
        return finalStr;
    }

   /**
    *   @description <This method is used to test the create feed items with SPI Data's>
    *   @name testHandleFeedItemWithSPIViolation
    *   @param feedSPIData
    */
    public static void testHandleFeedItemWithSPIViolation(String feedSPIData) {
        User nonAPIUser = UTIL_TestDataCreationChatter_TEST.createNonAPITestUser('2.00 Agent');
        AP_SPISecurityManager spiSecurityManager = new AP_SPISecurityManager();
        createSPISecurityControlForUSSSNPatternPreventOnBreach();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1, 'size of the spi security control is equal to 1');
        createSPIDataPreventionFieldsForFeedItem();
        UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
        Test.StartTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
        System.runas(nonAPIUser) {
            try {
                spiSecurityManager.handle(UTIL_TestDataCreationChatter_TEST.createFeedItem(feedSPIData));
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.FEED_ITEM_ON_BREACH_ERROR_MSG), 'Get message contains UTIL_SPITestConstants.FEED_ITEM_ON_BREACH_ERROR_MSG');
                system.assert(!e.getMessage().contains(UTIL_Constants.RICH_TEXT_NEW_LINE), 'Get message contains UTIL_Constants.RICH_TEXT_NEW_LINE');
            }
        }
        Test.StopTest();
    }
}