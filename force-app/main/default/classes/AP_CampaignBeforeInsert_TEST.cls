/**
  * @name AP_CampaignBeforeInsert_TEST
  * @author Golden Spikes Team & Akita Team 
  * @createdDate 07/16/2015  
  * @description Apex unit testing for CampaignBeforeInsert Trigger
  */
@isTest
(seeAllData=false)
private class AP_CampaignBeforeInsert_TEST {  
    private static User apiUser;
    private static User nonAPIUser;
    
  /**
    * @method Setup method used for building test data (must be called at beginning of test)
    * @description   setUp     
    */
    public static void setUp(){
        apiUser = UTIL_UserProvisioning_TEST.createAPITestUser();
        nonAPIUser = UTIL_UserProvisioning_TEST.createNonAPITestUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{apiUser, nonAPIUser});
    }
    
  /**
    * @method Method to test if a non API user will execute the business logic for SPI Security Control
    * @description   testCampaignBeforeInsertWithNonAPIUserAfterBreach     
    */
   @isTest
    static void testCampaignBeforeInsertWithNonAPIUserAfterBreach() {        
        setUp();
        Test.StartTest();
        
        System.runas(nonAPIUser){
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForCampaign();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
			UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1,'The size of spi Security Controls should be 1');
                try{
                    UTIL_SPITestDataCreation_TEST.createCampaignWithSSNViolationOnSecurityBreach();
                } catch(Exception e){
                    System.assert(e.getMessage().contains(UTIL_SPITestConstants.CAMPAIGN_ON_BREACH_ERROR_MSG),'Exception message should contain the String passed as parameter');
                }
            List<Campaign> campaigns = [select Id from Campaign];
            System.assert(campaigns.isEmpty(),'campaigns should not be empty');
        }
        Test.StopTest();
    }
    
    /**
      * @method Method to test that an API user WILL NOT execute the business logic for SPI Security Control
      * @description  testCampaignBeforeInsertWithAPIUserAfterBreach
      */
     @isTest
     static void testCampaignBeforeInsertWithAPIUserAfterBreach() {        
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
            System.assert(!campaigns.isEmpty(),'campaigns should not be empty');
        }
        Test.StopTest();
    }
}