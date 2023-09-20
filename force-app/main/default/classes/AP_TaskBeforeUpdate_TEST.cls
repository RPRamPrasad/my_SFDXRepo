/**
  * @name AP_TaskBeforeUpdate_TEST
  * @author Golden Spikes Team and Akita Team
  * @createdDate 07/16/2015
  * @description Apex unit testing for TaskBeforeUpdate Trigger
  */
@isTest
(seeAllData=false)
private class AP_TaskBeforeUpdate_TEST {
    
    private static User apiUser;
    private static User nonAPIUser;
    private static User agentUser;
    
    private static String ssn_Violation = UTIL_SPITestConstants.SPI_DATA_SSN_VIOLATION;
    private static String key_Id_Sobj = UTIL_SPITestConstants.KEY_IDENTIFIER_SOBJ;
    
    /**
      * @description Setup method used for building test data (must be called at beginning of test)
      * @name   setUp
      */
    public static void setUp(){
        apiUser = UTIL_UserProvisioning_TEST.createAPITestUser();
        nonAPIUser = UTIL_UserProvisioning_TEST.createNonAPITestUser();
        agentUser = UTIL_UserProvisioning_TEST.setUpAgentUser();
    }
    
    /**
      * @description Method to test if a non API user will execute the business logic for SPI Security Control
      * @name   testTaskBeforeUpdateWithNonAPIUserAfterBreach
      */
    
    @isTest
    static void testTaskBeforeUpdateWithNonAPIUserAfterBreach() {
        
        setUp();
        Test.StartTest();
        
        System.runas(nonAPIUser){
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForTask();            
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1, 'spiSecurityControls size is not 1');
             
            UTIL_TestDataCreation_TEST.createTask();  
             
            List<Task> tasks = [select Description from Task];
            System.assert(!tasks.isEmpty(), 'tasks is empty');
            tasks[0].Description = ssn_Violation.replace(key_Id_Sobj,String.valueOf(Task.SOBjectType).toLowerCase());
            try{
                update tasks;
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.TASK_ON_BREACH_ERROR_MSG), e.getMessage());
            }
        }
        Test.StopTest(); 
    }
    
    /**
      * @description Method to test that an API user WILL NOT execute the business logic for SPI Security Control
      * @name   testTaskBeforeUpdateWithAPIUserAfterBreach   
      */
      
    @isTest
    static void testTaskBeforeUpdateWithAPIUserAfterBreach() {        
        setUp();
        Test.StartTest();

        System.runas(apiUser){
            UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1, 'spiSecurityControls size is not 1');
            
            UTIL_SPITestDataCreation_TEST.createTaskWithSSNViolationOnSecurityBreach(agentUser);
            List<Task> tasks = [select Id from Task];
            tasks[0].Description = ssn_Violation.replace(key_Id_Sobj,String.valueOf(Task.SOBjectType).toLowerCase());
            update tasks;
            System.assert(!tasks.isEmpty(), 'tasks is empty');
        }
        Test.StopTest(); 
    }
    
}