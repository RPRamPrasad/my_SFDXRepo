/**
  *    Author          : Trailblazers/Dreambuilders
  *    Date Created    : 05/24/2017
  *    @description     : Apex unit testing for SFCOM_TEST_SFDOTCOM_SPISecurityManager
  *    Version         : 1.0
  */

@isTest
(seeAllData=false)
public class SFDOTCOM_SPISecurityManager_TEST{

    private static User nonAPIUser;
    private static User apiUser;
    private static SFDOTCOM_SPISecurityManager_TestWrapper sfdotcomWrap = new SFDOTCOM_SPISecurityManager_TestWrapper();

    //---- Utility Methods copy 
    public static String ssn_Violation_Data = UTIL_SPITestConstants.SPI_DATA_SSN_VIOLATION;    
    public static String key_Id_Sobj = UTIL_SPITestConstants.KEY_IDENTIFIER_SOBJ;

    /**
    * @method testUsersSetup method used for building test data for the class
    * @description   testUsersSetup
    */        
    @testsetup
    public static void testUsersSetup(){
        nonAPIUser = UTIL_UserProvisioning_TEST.createNonAPITestUser();
        apiUser = UTIL_UserProvisioning_TEST.createAPITestUser();
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(apiUser);        
    }
    
    /**
    * @method getUsers method used to get test users needed for testing the method. Must be called before each test method
    * @description   getUsers
    */
    public static void getUsers(){
        nonAPIUser = UTIL_UserProvisioning_TEST.getNonAPIProfileUser();
        apiUser = UTIL_UserProvisioning_TEST.getAPIProfileUser();
    }

  /**
    * @method Method to test case with SPI violation for No split text
    * @description   testHandleCaseWithSPIViolationForNoSplitText
    */
    @isTest
    static void testHandleCaseWithSPIViolationForNoSplitText(){
       
        getUsers();
        Test.StartTest();
        SFDOTCOM_SPISecurityManager spiSecurityMan = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        
        System.runas(nonAPIUser){    
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForCase(); 
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
            sfdotcomWrap.testHandleCaseWithSPIViolationForNoSplitText(spiSecurityMan);
            List<Case> cases = [select Id from Case];
            System.assert(cases.isEmpty(),'Expected value should be Empty, but actual value is:'+cases.isEmpty());
        }
        Test.StopTest();
    }
    
    /**
    * @method Method to test task with SPI violation for carriageReturn and new line
    * @description   testHandleTaskWithSPIViolationForCarriageReturnAndNewLine
    */
    @isTest
    static void testHandleTaskWithSPIViolationForCarriageReturnAndNewLine(){
        
        getUsers();
        Test.StartTest();
        SFDOTCOM_SPISecurityManager spiSecurityMan = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
        System.runas(nonAPIUser){    
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForTask();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
            sfdotcomWrap.testHandleTaskWithSPIViolationForCarriageReturnAndNewLine(spiSecurityMan);
            List<Task> tasks = [select Id from Task];
            System.assert(tasks.isEmpty(),'Expected value should be Empty, but actual value is:'+tasks.isEmpty());
        }
        Test.StopTest();
    }
    /**
    * @method Method to test task with SPI violation for Big String
    * @description   testHandleTaskWithSPIViolationWithBigDescriptionField
    */    
    @isTest
    static void testHandleTaskWithSPIViolationWithBigDescriptionField(){
        
        getUsers();
        Test.StartTest();
        SFDOTCOM_SPISecurityManager spiSecurityMan = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
        System.runas(nonAPIUser){    
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForTask(); 
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
            sfdotcomWrap.testHandleTaskWithSPIViolationWithBigDescriptionField(spiSecurityMan);
            List<Task> tasks = [select Id from Task];
            System.assert(tasks.isEmpty(),'Expected value should be Empty, but actual value is:'+tasks.isEmpty());
        }
        Test.StopTest();
    }
    /**
    * @method Method to test task with SPI violation for Big String in between two chunks
    * @description   testHandleTaskWithSPIViolationInBetweenChunksWithBigDescriptionField
    */ 
    @isTest
    static void testHandleTaskWithSPIViolationInBetweenChunksWithBigDescriptionField(){
        
        getUsers();
        Test.StartTest();
        SFDOTCOM_SPISecurityManager spiSecurityMan = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreachNew();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
        System.runas(nonAPIUser){    
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForTask(); 
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
            sfdotcomWrap.testHandleTaskWithSPIViolationInBetweenChunksWithBigDescriptionField(spiSecurityMan);
            List<Task> tasks = [select Id from Task];
            System.assert(tasks.isEmpty(),'Expected value should be Empty, but actual value is:'+tasks.isEmpty());
        }
        Test.StopTest();
    }
    /**
    * @method Method to test task with SPI violation for Exact Denominator Of Chunk Size With Big String
    * @description   testHandleTaskWithSPIViolationExactDenominatorOfChunkWithBigDescriptionField
    */   
    @isTest
    static void testHandleTaskWithSPIViolationExactDenominatorOfChunkWithBigDescriptionField(){
        
        getUsers();
        Test.StartTest();
        SFDOTCOM_SPISecurityManager spiSecurityMan = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
        System.runas(nonAPIUser){    
            sfdotcomWrap.testHandleTaskWithSPIViolationExactDenominatorOfChunkWithBigDescriptionField(spiSecurityMan);
            List<Task> tasks = [select Id from Task];
            System.assert(tasks.isEmpty(),'Expected value should be Empty, but actual value is:'+tasks.isEmpty());
        }
        Test.StopTest();
    }    
    
    
    /**
    * @method Method to test Case Comment with SPI violation for carriageReturn
    * @description   testHandleCaseCommentWithSPIViolationForCarriageReturn
    */
    @isTest
    static void testHandleCaseCommentWithSPIViolationForCarriageReturn(){
        
        getUsers();
        Test.StartTest();
        SFDOTCOM_SPISecurityManager spiSecurityMan = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
        System.runas(nonAPIUser){    
            sfdotcomWrap.testHandleCaseCommentWithSPIViolationForCarriageReturn(spiSecurityMan);
            List<CaseComment> casecomments = [select Id from CaseComment];
            System.assert(casecomments.isEmpty(),'Expected value should be Empty, but actual value is:'+casecomments.isEmpty());
        }
        Test.StopTest();
    }
        
    /**
    * @method Method to test Feed Item with SPI violation for New Line
    * @description   testHandleFeedItemWithSPIViolationForNewLine
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForNewLine(){
        
        getUsers();
        Test.StartTest();
        SFDOTCOM_SPISecurityManager spiSecurityMan = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
        System.runas(nonAPIUser){    
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForFeedItem();  
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();             
            try{
                spiSecurityMan.handle(createFeedItemWithSSNViolationOnNewLine());
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.FEED_ITEM_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value '+UTIL_SPITestConstants.FEED_ITEM_ON_BREACH_ERROR_MSG);
            }
        }
        Test.StopTest();
    }   
    
    
  /**
    * @method Method to test Feed Item with SPI violation for MultipleNew Line
    * @description   testHandleFeedItemWithSPIViolationForNewLin
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForMultipleNewLine(){
        
        getUsers();
        Test.StartTest();
        SFDOTCOM_SPISecurityManager spiSecurityMan = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
        System.runas(nonAPIUser){    
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForFeedItem(); 
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
            try{
                spiSecurityMan.handle(createFeedItemWithSSNViolationOnMultipleLine());
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.FEED_ITEM_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value '+UTIL_SPITestConstants.FEED_ITEM_ON_BREACH_ERROR_MSG);
            }
        }
        Test.StopTest();
    }  
        
    /**
    * @method Method to test case with SPI violation for No split text
    * @description   testHandleCaseWithSPIViolationForNoSplitText
    */
    @isTest
    static void testHandleCaseWithSPIViolationForMultipleFields(){
        
        getUsers();
        Test.StartTest();
        SFDOTCOM_SPISecurityManager spiSecurityMan = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreachNew();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
        System.runas(nonAPIUser){    
            UTIL_SPITestDataCreation_TEST.createMultipleSPIDataPreventionFieldsForCase();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
            try{
                spiSecurityMan.handle(createCaseWithSSNViolationForMultipleField());
            } catch(Exception e){
                system.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_ON_BREACH_ERROR_MSG)||e.getMessage().contains(UTIL_SPITestConstants.CASE_SUBJECT_ON_BREACH_ERROR_MSG),'Exception Message does not contain either the value '+UTIL_SPITestConstants.CASE_ON_BREACH_ERROR_MSG+' or the value '+ UTIL_SPITestConstants.CASE_SUBJECT_ON_BREACH_ERROR_MSG);
            }
            List<Case> cases = [select Id from Case];
            System.assert(cases.isEmpty(),'Expected value should be Empty, but actual value is:'+cases.isEmpty());
        }
        Test.StopTest();
    }  
    
    /**
    * @method Method to test case with SPI violation for NewLine
    * @description   testHandleCaseWithSPIViolationForFieldAssociatedWithNewLine
    */
    @isTest
    static void testHandleCaseWithSPIViolationForFieldAssociatedWithNewLine(){
        
        getUsers();
        Test.StartTest();
        SFDOTCOM_SPISecurityManager spiSecurityMan = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreachNew();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
        System.runas(nonAPIUser){    
            UTIL_SPITestDataCreation_TEST.createMultipleSPIDataPreventionFieldsForCase();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
            try{
                spiSecurityMan.handle(createCaseWithSSNViolationForNewLineAfterSSNText());
            } catch(Exception e){

                system.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_ON_BREACH_ERROR_MSG)||e.getMessage().contains(UTIL_SPITestConstants.CASE_SUBJECT_ON_BREACH_ERROR_MSG),'Exception Message does not contain either the value ' +UTIL_SPITestConstants.CASE_ON_BREACH_ERROR_MSG+' or the value ' +UTIL_SPITestConstants.CASE_SUBJECT_ON_BREACH_ERROR_MSG);
            }
            List<Case> cases = [select Id from Case];
            System.assert(cases.isEmpty(),'Expected value should be Empty, but actual value is:'+cases.isEmpty());
        }
        Test.StopTest();
    }  
    

    
    /**
    * @method Method to test case with SPI violation for No split text
    * @description   testHandleCaseWithSPIViolationForNoSplitText
    */
    @isTest
    static void testHandleCaseWithSPIViolationForException(){
        
        getUsers();
        Test.StartTest();
        SFDOTCOM_SPISecurityManager spiSecurityMan = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
        System.runas(nonAPIUser){  
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForCaseWithoutObjectLabel();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
            try{
                spiSecurityMan.handle(createCaseWithSSNViolationForNoSplitText());
            } catch(Exception e){
                System.assert(!e.getMessage().contains(UTIL_SPITestConstants.CASE_ON_BREACH_ERROR_MSG),'Exception Message should not contain the value ' +UTIL_SPITestConstants.CASE_ON_BREACH_ERROR_MSG);
            }            
        }
        Test.StopTest();
    }
    
    //Additional for Chatter
    /**
    * @method Method to test Feed Item with SPI violation for No split text
    * @description   testHandleFeedItemsWithSPIViolationForMultipleFields
    */
   @isTest
   static void testHandleFeedItemsWithSPIViolationForMultipleFields(){        
        getUsers();        
        SFDOTCOM_SPISecurityManager spiSecurityManager = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreationChatter_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        UTIL_SPITestDataCreationChatter_TEST.createMultipleSPIDataPreventionFieldsForFeedItems();
        UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser); 
        Test.StartTest();
        System.runas(nonAPIUser){                              
            try{
               spiSecurityManager.handle(createFeedItem('Testing FeedItem with SSN 123-45-6789'));
            } catch(Exception e){
               System.assert(e.getMessage().contains(UTIL_SPITestConstants.FEED_ITEM_NO_LABEL_BREACH_ERROR_MSG),'Exception Message does not contain the value ' +UTIL_SPITestConstants.FEED_ITEM_NO_LABEL_BREACH_ERROR_MSG);
            }
        }
        Test.StopTest();
    }
       
    /**
    * @method Method to test Feed Item with SPI violation for No split text
    * @description   testHandleFeedItemWithSPIViolationForException
    */
    @isTest
    static void testHandleFeedItemWithSPIViolationForException(){        
        getUsers();        
        SFDOTCOM_SPISecurityManager spiSecurityManager = new SFDOTCOM_SPISecurityManager();
        UTIL_SPITestDataCreationChatter_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        UTIL_SPITestDataCreationChatter_TEST.createSPIDataPreventionFieldsForFeedItemsWithoutObjectLabel();
        UTIL_SPITestDataCreation_TEST.createSPIChunkSize();  
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(nonAPIUser);
        Test.StartTest();
        System.runas(nonAPIUser){                          
            try{
                spiSecurityManager.handle(createFeedItem('Testing FeedItem with SSN 123-45-6789'));
            } catch(Exception e){
                System.assert(!e.getMessage().contains(UTIL_SPITestConstants.FEED_ITEM_ON_BREACH_ERROR_MSG),'Exception Message should not contain the value ' +UTIL_SPITestConstants.FEED_ITEM_ON_BREACH_ERROR_MSG);
            }
        }
        Test.StopTest();
    }  
    
 
        
   /**
    *   @description <This method is used to insert TEST SPI Case record with no SSN violation on Security Breach>
    *   @return List<Case> - List of Case
    */
    public static List<Case> createCaseWithNoSSNViolationOnSecurityBreach() {
        //UTIL_TestDataCreationChatter_TEST.createSPIChunkSize(); 
        List<Case> cases = new List<Case>();
        cases.add(new Case(Subject = 'tst case',Case_Originator__c = 'CCC Sales', Description = 'Testing case with no SSN '+'violation substituting the spi data \r\n 00000'));
        return cases;
    }
      
    /**
    *   @description <This method is used to insert TEST SPI Feed Item record with SSN violation on Security Breach>
    *   @return List<FeedItem> - List of FeedItem
    */
    public static List<FeedItem> createFeedItemWithSSNViolationOnSecurityBreach() {
        //UTIL_TestDataCreationChatter_TEST.createSPIChunkSize(); 
        List<Case> caseList = createCaseWithNoSSNViolationOnSecurityBreach();       
        List<FeedItem> feedItems = new List<FeedItem>();
        feedItems.add(new FeedItem(ParentId = caseList[0].Id, Body = ssn_Violation_Data.replace(key_Id_Sobj,String.valueOf(FeedItem.SObjectType).toLowerCase())));
        return feedItems;
    }
    
   /**
    *   @description <This method is used to insert TEST SPI Feed Comment record with SSN violation on Security Breach>
    *   @return List<FeedComment> - List of FeedComment
    */
    public static List<FeedComment> createFeedCommentWithSSNViolationOnSecurityBreach() {
        //UTIL_TestDataCreationChatter_TEST.createSPIChunkSize(); 
        List<FeedItem> feedItems = createFeedItemWithSSNViolationOnSecurityBreach();
        List<FeedComment> feedComments = new List<FeedComment>();
        feedComments.add(new FeedComment(FeedItemId = feedItems[0].Id,CommentBody = ssn_Violation_Data.replace(key_Id_Sobj,String.valueOf(FeedItem.SObjectType).toLowerCase())));
        return feedComments;
    }
    
   /**
    *   @description <This method is used to insert TEST SPI Feed Item record with SSN violation on New Line>
    *   @return List<FeedItem> - List of FeedItem
    */
    public static List<FeedItem> createFeedItemWithSSNViolationOnNewLine() {
        //UTIL_TestDataCreationChatter_TEST.createSPIChunkSize(); 
        List<Case> caseList = createCaseWithNoSSNViolationOnSecurityBreach();       
        List<FeedItem> feedItems = new List<FeedItem>();
        feedItems.add(new FeedItem(ParentId = caseList[0].Id, Body = 'violation the spi data \n 123-45-6789'));
        return feedItems;
    }
    
    /**
    *   @description <This method is used to insert TEST SPI Feed Item record with SSN violation on Multiple Line>
    *   @return List<FeedItem> - List of FeedItem
    */
    public static List<FeedItem> createFeedItemWithSSNViolationOnMultipleLine() {
        //UTIL_TestDataCreationChatter_TEST.createSPIChunkSize(); 
        List<Case> caseList = createCaseWithNoSSNViolationOnSecurityBreach();       
        List<FeedItem> feedItems = new List<FeedItem>();
        feedItems.add(new FeedItem(ParentId = caseList[0].Id, Body = '123-45-6789 violation the spi data \n 123-45-6789'));
        return feedItems;
    }
    
   /**
    *   @description <This method is used to insert TEST SPI CaseComment record with SSN violation on Carriage Return on Security Breach>
    *   @return List<CaseComment> - List of CaseComment
    */    
    public static List<CaseComment> createCaseCommentWithSSNViolationOnCarriageReturn() {
        //UTIL_TestDataCreationChatter_TEST.createSPIChunkSize(); 
        List<Case> caseList = UTIL_TestDataCreation_TEST.createCase();
        List<CaseComment> caseComments = new List<CaseComment>();
        caseComments.add(new CaseComment(ParentId = caseList[0].Id, CommentBody = 'violation substituting the spi data \r 123-45-6789'));
        return caseComments;
    }
        
   /**
    *   @description <This method is used to insert TEST SPI Case record with SSN violation on SplitText by no New Line>
    *   @return List<Case> - List of Case
    */
    public static List<Case> createCaseWithSSNViolationForNoSplitText() {
        //UTIL_TestDataCreationChatter_TEST.createSPIChunkSize();         
        List<Case> cases = new List<Case>();
        cases.add(new Case(Subject = 'tst case',Case_Originator__c = 'CCC Sales', Description = 'Testing account with SSN 123-45-6789'));                
        return cases;
    }
   /**
    *   @description <This method is used to insert TEST SPI Case record with SSN violation on Multiple fields by no New Line>
    *   @return List<Case> - List of Case
    */    
    public static List<Case> createCaseWithSSNViolationForMultipleField() { 
        //UTIL_TestDataCreationChatter_TEST.createSPIChunkSize(); 
        List<Case> cases = new List<Case>();
        cases.add(new Case(Subject = 'ssn: 123456789',Case_Originator__c = 'CCC Sales', Description = 'Testing account with SSN 123-45-6789'));                
        return cases;
    }
    
    /**
    *   @description <This method is used to insert TEST SPI Case record with SSN violation on New Line>
    *   @return List<Case> - List of Case
    */
    public static List<Case> createCaseWithSSNViolationForNewLineAfterSSNText() {
        //UTIL_TestDataCreationChatter_TEST.createSPIChunkSize();         
        List<Case> cases = new List<Case>();
        cases.add(new Case(Subject = 'ssn: 123456789',Case_Originator__c = 'CCC Sales', Description = 'Mr. X called and gave us Mr. Ys SSN \n 123456789'));                
        return cases;
    }
    
   /**
    *   @description <This method is used to insert TEST SPI Task record with SSN violation on Security Breach>
    *   @return List<Task> - List of Task
    */
    public static List<Task> createTaskWithSSNViolationForCarriageReturnAndNewLine() { 
        //UTIL_TestDataCreationChatter_TEST.createSPIChunkSize(); 
        List<Task> tasks = new List<Task>();
        tasks.add(new Task(Description = 'violation on the spi data \r\n 123-45-6789' ));
        return tasks;
    }

   /**
    *   @description <This method is used to create big string with SPI data in first chunk>
    *   @return List<Task> - List of Task
    */    
    public static List<Task> createTaskWithSSNViolationWithBigDescriptionField() {        
        List<Task> tasks = new List<Task>();
        String bigStr='';
        String spiStr=' We got the SSN : 234-45-7364 from one of the customer ';
        String smallStr='SPI validation feature will restrict agents to enter SPI data in freeform';
        sfdotcomWrap.bigStr = bigStr;
        sfdotcomWrap.spiStr = spiStr;
        sfdotcomWrap.smallStr = smallStr;
        sfdotcomWrap.createTaskWithSSNViolationWithBigDescriptionField(tasks, sfdotcomWrap);
        return tasks;
    }
   /** 
    *   @description <This method is used to create big string with SPI data in between two chunks>
    *   @return List<Task> - List of Task
    */     
    public static List<Task> createTaskWithSSNViolationInBetweenChunksWithBigDescriptionField() {        
        List<Task> tasks = new List<Task>();
        String fullStr='';
        String spiData='  SSN have received  123456789 from one of the customer ';
        String smallData='SPI validation feature will restrict agents to enter SPI data in freeform';
        integer i=1;
            do {
                fullStr=fullStr+smallData;
                i++;
            }While(i<42);

        fullStr=fullStr+spiData;
        system.assert(fullStr.indexOf('SSN')<3000 && fullStr.indexOf('SSN')>2994 && fullStr.indexOf('123456789')>3000,'Index of fullStr is not less than 3000 and not greater than 2994 and 3000');     
        tasks.add(new Task(Subject= 'This is t3st',TaskCategory__c='Marketing',Task_Type__C='Sales',ActivityDate=Date.today()+1,Description = fullStr ));

        return tasks;
    }
   /** 
    *   @description <This method is used to create big string with SPI data in first chunk and exact demonimator of size chunk>
    *   @return List<Task> - List of Task
    */     
    public static List<Task> createTaskWithSSNViolationByExactDenominatorOfChunkWithBigDescriptionField() {        
        List<Task> tasks = new List<Task>();
        String bigStr='';
        String spiStr=' We got the SSN : 234-45-7364 from one of the customer ';
        String smallStr='SPI validation feature will restrict agents to enter SPI data in freeform';
        sfdotcomWrap.bigStr = bigStr;
        sfdotcomWrap.spiStr = spiStr;
        sfdotcomWrap.smallStr = smallStr;
        sfdotcomWrap.createTaskWithSSNViolationByExactDenominatorOfChunkWithBigDescriptionField(tasks, sfdotcomWrap);
        return tasks;
    }
    
    /** 
    *   @Method <This method is used to insert TEST FeedItem record>
    *   @description createFeedItem
    *   @param feedItemBody
    *   @return List<FeedItem> - List of FeedItem
    */ 
    public static List<FeedItem> createFeedItem(String feedItemBody) { 
        
        List<FeedItem> feedItems = new List<FeedItem>();
        feedItems.add(new FeedItem(ParentId = UserInfo.getUserId(), Body = feedItemBody, IsRichText=true));
        return feedItems;
    }
    
    private class SFDOTCOM_SPISecurityManager_TestWrapper{
        String bigStr;
        String spiStr;
        String smallStr;

        private void createTaskWithSSNViolationWithBigDescriptionField(List<Task> tasks, SFDOTCOM_SPISecurityManager_TestWrapper sfdotWrap){
            do{
                if (sfdotWrap.bigStr.length()>444 && sfdotWrap.bigStr.length()<544){
                    sfdotWrap.bigStr=sfdotWrap.bigStr+sfdotWrap.spiStr;
                }  
                sfdotWrap.bigStr=sfdotWrap.bigStr+sfdotWrap.smallStr;
            }while(sfdotWrap.bigStr.length()<31090);
    
            tasks.add(new Task(Subject= 'This is t3st',TaskCategory__c='Marketing',Task_Type__C='Sales',ActivityDate=Date.today()+1,Description = sfdotWrap.bigStr )); 
        }

        private void createTaskWithSSNViolationByExactDenominatorOfChunkWithBigDescriptionField(List<Task> tasks, SFDOTCOM_SPISecurityManager_TestWrapper sfdotWrap){
            do{
                if (sfdotWrap.bigStr.length()>444 && sfdotWrap.bigStr.length()<544){
                    sfdotWrap.bigStr=sfdotWrap.bigStr+sfdotWrap.spiStr;
                }  
                sfdotWrap.bigStr=sfdotWrap.bigStr+sfdotWrap.smallStr;
            }while(sfdotWrap.bigStr.length()<31090);
            sfdotWrap.bigStr=sfdotWrap.bigStr.left(30000);
            
            tasks.add(new Task(Subject= 'This is t3st',TaskCategory__c='Marketing',Task_Type__C='Sales',ActivityDate=Date.today()+1,Description = sfdotWrap.bigStr ));
        }

        private void testHandleCaseCommentWithSPIViolationForCarriageReturn(SFDOTCOM_SPISecurityManager spiSecurityMan){
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForCaseComment(); 
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
            try{
                spiSecurityMan.handle(createCaseCommentWithSSNViolationOnCarriageReturn());
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_COMMENT_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value '+UTIL_SPITestConstants.CASE_COMMENT_ON_BREACH_ERROR_MSG);
            }
        }

        private void testHandleTaskWithSPIViolationExactDenominatorOfChunkWithBigDescriptionField(SFDOTCOM_SPISecurityManager spiSecurityMan){
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForTask(); 
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize(); 
            try{
                spiSecurityMan.handle(createTaskWithSSNViolationByExactDenominatorOfChunkWithBigDescriptionField());
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.TASK_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value '+UTIL_SPITestConstants.TASK_ON_BREACH_ERROR_MSG);
            }
        }

        private void testHandleTaskWithSPIViolationInBetweenChunksWithBigDescriptionField(SFDOTCOM_SPISecurityManager spiSecurityMan){
            try{
                spiSecurityMan.handle(createTaskWithSSNViolationInBetweenChunksWithBigDescriptionField());
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.TASK_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value '+UTIL_SPITestConstants.TASK_ON_BREACH_ERROR_MSG);
            } 
        }

        private void testHandleTaskWithSPIViolationWithBigDescriptionField(SFDOTCOM_SPISecurityManager spiSecurityMan){
            try{
                spiSecurityMan.handle(createTaskWithSSNViolationWithBigDescriptionField());
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.TASK_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value '+UTIL_SPITestConstants.TASK_ON_BREACH_ERROR_MSG);
            }
        }

        private void testHandleTaskWithSPIViolationForCarriageReturnAndNewLine(SFDOTCOM_SPISecurityManager spiSecurityMan){
            try{
                spiSecurityMan.handle(createTaskWithSSNViolationForCarriageReturnAndNewLine());
            } catch(Exception e){
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.TASK_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value '+UTIL_SPITestConstants.TASK_ON_BREACH_ERROR_MSG);
                system.assert(e.getMessage().contains(UTIL_Constants.RICH_TEXT_NEW_LINE),'Exception Message does not contain the value '+UTIL_Constants.RICH_TEXT_NEW_LINE);
            }
        }

        private void testHandleCaseWithSPIViolationForNoSplitText(SFDOTCOM_SPISecurityManager spiSecurityMan){
            try{
                spiSecurityMan.handle(UTIL_SPITestDataCreation_TEST.createCaseWithSSNViolationForNoSplitText());
            } catch(Exception e){

                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value '+UTIL_SPITestConstants.CASE_ON_BREACH_ERROR_MSG);
            }
        }
    }          
}