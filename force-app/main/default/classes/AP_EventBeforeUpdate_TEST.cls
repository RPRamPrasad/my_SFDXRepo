/**
  * @name AP_EventBeforeUpdate_TEST
  * @author Golden Spikes Team and Akita Team
  * @createdDate 07/16/2015
  * @description Apex unit testing for EventBeforeUpdate Trigger
  */
@isTest
(seeAllData=false)
private class AP_EventBeforeUpdate_TEST {
    
    private static User apiUser;
    private static User nonAPIUser;
    
    private static String ssn_Violation = UTIL_SPITestConstants.SPI_DATA_SSN_VIOLATION;
    private static String key_Id_Sobj = UTIL_SPITestConstants.KEY_IDENTIFIER_SOBJ;
    
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
      * @name   testEventBeforeUpdateWithNonAPIUserAfterBreach
      */

    @isTest
    static void testEventBeforeUpdateWithNonAPIUserAfterBreach() {
        
        setUp();
        Test.StartTest();
        
        System.runas(nonAPIUser){
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1, 'spiSecurityControls size is not 1');
             
            UTIL_TestDataCreation_TEST.createEvent();
             
            List<Event> events = [select Description from Event];
            System.assert(!events.isEmpty(), 'events is empty');
            events[0].Description = ssn_Violation.replace(key_Id_Sobj,String.valueOf(Event.SOBjectType).toLowerCase());
            try{
                update events;
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.EVENT_ON_BREACH_ERROR_MSG), e.getMessage());
            }
        }
        Test.StopTest();
    }
    
    /**
      * @description Method to test that an API user WILL NOT execute the business logic for SPI Security Control
      * @name   testEventBeforeUpdateWithAPIUserAfterBreach 
      */
      
    @isTest
    static void testEventBeforeUpdateWithAPIUserAfterBreach() {
        
        setUp();
        Test.StartTest();
        
        System.runas(apiUser){
            UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1, 'spiSecurityControls is not 1');
            
            UTIL_SPITestDataCreation_TEST.createEventWithSSNViolationOnSecurityBreach();
            List<Event> events = [select Id from Event];
            events[0].Description = ssn_Violation.replace(key_Id_Sobj,String.valueOf(Account.SOBjectType).toLowerCase());
            update events;            
            System.assert(!events.isEmpty(), 'event is empty');
        }
        Test.StopTest(); 
    }
    
}