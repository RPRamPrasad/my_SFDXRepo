/**
  * @name AP_CaseCommentBeforeInsert_TEST
  * @author Golden Spikes Team and Akita Team
  * @createdDate 07/16/2015  
  * @description Apex unit testing for CaseCommentBeforeInsert Trigger
  */
@isTest
(seeAllData=false)
private class AP_CaseCommentBeforeInsert_TEST {
    
    private static User apiUser;
    private static User nonAPIUser;
    
    /**
      * @description Setup method used for building test data (must be called at beginning of test)
      * @name   setUp
      */
    public static void setUp(){
        apiUser = UTIL_UserProvisioning_TEST.createAPITestUser();
        nonAPIUser = UTIL_UserProvisioning_TEST.createNonAPITestUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{apiUser,nonAPIUser});
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(apiUser);
    }
    
    /**
      * @description Method to test if a non API user will execute the business logic for SPI Security Control
      * @name   testCaseCommentBeforeInsertWithNonAPIUserAfterBreach
      */
    @isTest
    static void testCaseCommentBeforeInsertWithNonAPIUserAfterBreach() {
        
        setUp();
        Test.StartTest();
        
        System.runas(nonAPIUser){
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForCaseComment();            
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
			UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1, 'SpiSecurityControls size should be 1');
                try{
                    UTIL_SPITestDataCreation_TEST.createCaseCommentWithSSNViolationOnSecurityBreach();
                } catch(Exception e) {
                    System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_COMMENT_ON_BREACH_ERROR_MSG),'Error Message');
                }
            List<CaseComment> caseComments = [select Id from CaseComment];
            System.assert(caseComments.isEmpty(), 'caseComments is empty');
        }
        Test.StopTest();
    }
     
    /**
      * @description Method to test that an API user WILL NOT execute the business logic for SPI Security Control
      * @name   testCaseCommentBeforeInsertWithAPIUserAfterBreach    
      */
    @isTest
    static void testCaseCommentBeforeInsertWithAPIUserAfterBreach() {
        
        setUp();
        Test.StartTest();
        
        System.runas(apiUser){
            UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
			UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1, 'SpiSecurityControls size should be 1');
            
            UTIL_SPITestDataCreation_TEST.createCaseCommentWithSSNViolationOnSecurityBreach();
            List<CaseComment> caseComments = [select Id from CaseComment];
            System.assert(!caseComments.isEmpty(), 'caseComments should no be empty');
        }
        Test.StopTest();
    }
}