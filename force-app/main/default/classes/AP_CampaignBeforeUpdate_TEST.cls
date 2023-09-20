/**
  * @name AP_CampaignBeforeUpdate_TEST
  * @author Golden Spikes Team and Akita Team
  * @createdDate 07/16/2015
  * @description Apex unit testing for CampaignBeforeUpdate Trigger
  */
@isTest
(seeAllData=false)
private class AP_CampaignBeforeUpdate_TEST {
    
    private static User apiUser;
    private static User nonAPIUser;
    private static String ssn_Violation = UTIL_SPITestConstants.SPI_DATA_SSN_VIOLATION;
    private static String key_Id_Sobj = UTIL_SPITestConstants.KEY_IDENTIFIER_SOBJ;
    
    /**
      * @method Setup method used for building test data (must be called at beginning of test)
      * @description  setUp    
      */
    public static void setUp(){
        apiUser = UTIL_UserProvisioning_TEST.createAPITestUser();
        nonAPIUser = UTIL_UserProvisioning_TEST.createNonAPITestUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{apiUser, nonAPIUser});
    }
    
    /**
      * @method Method to test if a non API user will execute the business logic for SPI Security Control
      * @description  testCampaignBeforeUpdateWithNonAPIUserAfterBreach
      */
     @isTest
    static void testCampaignBeforeUpdateWithNonAPIUserAfterBreach() {
        setUp();
        Test.StartTest();
        System.runas(nonAPIUser){
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForCampaign();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
			UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1,'The size of spi Security Controls should be 1');
             
            UTIL_TestDataCreation_TEST.createCampaign();
             
            List<Campaign> campaigns = [select Description from Campaign];
            System.assert(!campaigns.isEmpty(),'campaigns should not be empty');
            campaigns[0].Description = ssn_Violation.replace(key_Id_Sobj,String.valueOf(Campaign.SOBjectType).toLowerCase());
            try{
                update campaigns;
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CAMPAIGN_ON_BREACH_ERROR_MSG),'Exception message should contain the String passed as parameter');
            }
        }
        Test.StopTest();
    }
    
   /**
    * @method Method to test that an API user WILL NOT execute the business logic for SPI Security Control
    * @description  testCampaignBeforeUpdateWithAPIUserAfterBreach
    */
   @isTest
    static void testCampaignBeforeUpdateWithAPIUserAfterBreach() {
        setUp();
        Test.StartTest();
        System.runas(apiUser){
            UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
			UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1,'The size of spi Security Controls should be 1');
            
            UTIL_SPITestDataCreation_TEST.createCampaignWithSSNViolationOnSecurityBreach();
            List<Campaign> campaigns = [select Id from Campaign];
            campaigns[0].Description = ssn_Violation.replace(key_Id_Sobj,String.valueOf(Account.SOBjectType).toLowerCase());
            update campaigns;
            
            System.assert(!campaigns.isEmpty(),'campaigns should not be empty');
        }
        Test.StopTest();
    }
}