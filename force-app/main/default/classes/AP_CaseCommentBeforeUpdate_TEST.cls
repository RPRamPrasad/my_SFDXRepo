/**
  * @name AP_CaseCommentBeforeUpdate_TEST
  * @author Golden Spikes Team and Akita Team
  * @createdDate 07/16/2015
  * @description Apex unit testing for CaseCommentBeforeUpdate Trigger
  */
@isTest
(seeAllData=false)
private class AP_CaseCommentBeforeUpdate_TEST {
    
    private static User apiUser;
    private static User nonAPIUser;
    
    private static String ssnViolation = UTIL_SPITestConstants.SPI_DATA_SSN_VIOLATION;
    private static String keyIdSobj = UTIL_SPITestConstants.KEY_IDENTIFIER_SOBJ;
    
    /**
      * @description Setup method used for building test data (must be called at beginning of test)
      * @name   setUp
      */
    public static void setUp(){
        apiUser = UTIL_UserProvisioning_TEST.createAPITestUser();
        nonAPIUser = UTIL_UserProvisioning_TEST.createNonAPITestUser();
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(apiUser);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{apiUser,nonAPIUser});
    }
    
    /**
      * @description Method to test if a non API user will execute the business logic for SPI Security Control
      * @name   testCampaignBeforeUpdateWithNonAPIUserAfterBreach
      */
    @isTest
    static void testCaseCommentBeforeUpdateWithNonAPIUserAfterBreach() {
        
        setUp();
        Test.StartTest();
        
        System.runas(nonAPIUser){
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForCampaign();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1, 'spiSecurityControls size should be 1');
             
            UTIL_TestDataCreation_TEST.createCaseComment();
             
            List<CaseComment> caseComments = [select CommentBody from CaseComment];
            System.assert(!caseComments.isEmpty(), 'caseComments should not be empty');
            caseComments[0].CommentBody = ssnViolation.replace(keyIdSobj,String.valueOf(CaseComment.SOBjectType).toLowerCase());
            try{
                update caseComments;
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_COMMENT_ON_BREACH_ERROR_MSG), 'Error Message');
            }
        }
        Test.StopTest();
    }
    
    /**
      * @description Method to test that an API user WILL NOT execute the business logic for SPI Security Control
      * @name   testCaseCommentBeforeUpdateWithAPIUserAfterBreach
      */
    @isTest
    static void testCaseCommentBeforeUpdateWithAPIUserAfterBreach() {
        
        setUp();
        Test.StartTest();
        
        System.runas(apiUser){
            UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();                 
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
            System.assert(spiSecurityControls.size()==1,'spiSecurityControls size should be 1');
            
            UTIL_SPITestDataCreation_TEST.createCaseCommentWithSSNViolationOnSecurityBreach();
            List<CaseComment> caseComments = [select Id from CaseComment];
            caseComments[0].CommentBody = ssnViolation.replace(keyIdSobj,String.valueOf(CaseComment.SOBjectType).toLowerCase());
            update caseComments;
            System.assert(!caseComments.isEmpty(),'caseComments shouldnot be empty');
        }
        Test.StopTest();
    }
}