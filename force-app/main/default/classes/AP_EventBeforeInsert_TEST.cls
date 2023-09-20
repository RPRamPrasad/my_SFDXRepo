/**
  * @name AP_EventBeforeInsert_TEST
  * @author Golden Spikes Team and Akita Team
  * @createdDate 07/16/2015
  * @description Apex unit testing for EventBeforeInsert Trigger
  */
@isTest
(seeAllData=false)
private class AP_EventBeforeInsert_TEST {
    
    private static User apiUser;
    private static User nonAPIUser;
    
    /**
      * @description Setup method used for building test data (must be called at beginning of test)
      * @name   setUp
      */
    public static void setUp(){
        apiUser = UTIL_UserProvisioning_TEST.createAPITestUser();
        nonAPIUser = UTIL_UserProvisioning_TEST.createNonAPITestUser();
    }
    
    /**
      * @description Method to test if a non API user will execute the business logic for SPI Security Control
      * @name   testEventBeforeInsertWithNonAPIUserAfterBreach
      */

    @isTest
    static void testEventBeforeInsertWithNonAPIUserAfterBreach() {
        
        setUp();
        Test.StartTest();
        
        System.runas(nonAPIUser){
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForEvent();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1, 'spiSecurityControls size is not 1');
                try{
                    UTIL_SPITestDataCreation_TEST.createEventWithSSNViolationOnSecurityBreach();
                } catch(Exception e){
                    System.assert(e.getMessage().contains(UTIL_SPITestConstants.EVENT_ON_BREACH_ERROR_MSG), e.getMessage());
                }
            List<Event> events = [select Id from Event];
            System.assert(events.isEmpty(), 'events is not empty');
        }
        Test.StopTest(); 
    }
    
    /**
      * @description Method to test that an API user WILL NOT execute the business logic for SPI Security Control
      * @name   testEventBeforeInsertWithAPIUserAfterBreach
      */
    
    @isTest
    static void testEventBeforeInsertWithAPIUserAfterBreach() {
        
        setUp();
        Test.StartTest();
        
        System.runas(apiUser){   
            UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1, 'spiSecurityControls size is not 1');
            
            UTIL_SPITestDataCreation_TEST.createEventWithSSNViolationOnSecurityBreach();
            List<Event> events = [select Id from Event];
            System.assert(!events.isEmpty(), 'event is empty');
        }
        Test.StopTest();
    }
}