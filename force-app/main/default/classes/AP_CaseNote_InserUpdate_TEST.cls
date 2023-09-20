/**
* Author : ITIC Team
* Date Created : 08/24/2017
* @description  Case Note class leveraged by apex triggers for preventing SPI data from being entered in free formed text fields.
*/
@isTest
(seeAllData=false)
private class AP_CaseNote_InserUpdate_TEST {
    private static Account account;
    private static Id accountId;
    private static User sysAdminUser = TestDataFactory_User.getSysAdminUser();
    private static User systemRecordOwner = TestDataFactory_User_Wrapper.getSystemRecordOwner();
    private static User userAgent;
    private static User userATM;
    private static User cccLicensed;
    private static String ssnViolationData = UTIL_SPITestConstants.SPI_DATA_SSN_VIOLATION;    
    private static String keyIdSobj = UTIL_SPITestConstants.KEY_IDENTIFIER_SOBJ;
    /**
     * @description caze
     */
    public static Case caze { get; private set; }
    /**
     * @description note
     */
    public static Case_Note__c note { get; private set; }

  /**
    * @description Setup method used for building test data (must be called at beginning of test)
    * @name   setUp
    */
    @testSetup
    public static void setUp(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    	userAgent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678911');
        userAgent = TestDataFactory_User.insertUser(userAgent);  
        userATM = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('TEST', '12345678912');
        userATM = TestDataFactory_User.insertUser(userATM); 
        cccLicensed = TestDataFactory_User_Wrapper.generateActiveCCCLicensedUser('alias', '12345678913');
  		cccLicensed = TestDataFactory_User.insertUser(cccLicensed);
        TestDataFactory_CustomSetting.createSPIDataCustomSettingsForCaseNote();
        TestDataFactory_CustomSetting.createSPISecurityControlsData();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{userAgent,userATM,cccLicensed});
        createAccount();
    }
    /**
     * @description createAccount - Create Account in the test context
     */
    public static void createAccount(){
        account = TestDataFactory_Account.createIndividualCustomer('TestAccountName');
        System.runAs(sysAdminUser){
            TestDataFactory_Account.byPassAccountBeforeTrigger();
            TestDataFactory_Opportunity.byPassOpportunityBeforeTrigger();
            TestDataFactory_Account.insertAccount(account);
        }
        accountId = account.Id;
    }
    /**
     * @description createCase - Create Case in the test context
     * @param proxyUser 
     */
    public static void createCase(User proxyUser){
    	TestDataFactory_Case.byPassCaseBeforeTrigger();   	
    	caze = TestDataFactory_Case.generateCase(accountId);
    	caze.OwnerId = systemRecordOwner.Id; 
    	TestDataFactory_Case.insertCase(caze);
    	System.runAs(TestDataFactory_User.getSysAdminUser()) {     		
    		caze.OwnerId = systemRecordOwner.Id;  
    	}
    }
   
    /**
    * @description Method to test if a Agent User will execute the business logic for SPI Security Control
    */
    @isTest
   	static void testCaseNoteBeforeInsertWithAgentUser() {
   		
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c = '12345678911'];
        createCase(userAgent);
        caze = [Select Id from Case where AccountId = :accountId];
		Case_Note__c note1 = new Case_Note__c(Name = ssnViolationData.replace(keyIdSobj,String.valueOf(Case_Note__c.SObjectType).toLowerCase()),
                                          Comments__c = ssnViolationData.replace(keyIdSobj,String.valueOf(Case_Note__c.SObjectType).toLowerCase()),
                                          Case__c = caze.Id);
       	Test.startTest();
       	System.runAs(userAgent) {
        	try {
           		insert note1;
        	}catch (Exception e) {
        	 	System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_NOTE_ON_BREACH_ERROR_MSG),'Error Message');
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_NOTE_SUBJECT_ON_BREACH_ERROR_MSG), 'Error Message');
        	}
       	}
        Test.stopTest();
   	}
   
    /**
    * @description Method to test if a ATM user will execute the business logic for SPI Security Control
    */
    @isTest
  	static void testCaseNoteBeforeInsertWithATMUser() {
        userATM = [Select Id, Associate_Id__c from User where Associate_Id__c = '12345678912'];
        createCase(userATM);
        caze = [Select Id from Case where AccountId = :accountId];
		Case_Note__c note2 = new Case_Note__c(Name =ssnViolationData.replace(keyIdSobj,String.valueOf(Case_Note__c.SObjectType).toLowerCase()),
                                          Comments__c= ssnViolationData.replace(keyIdSobj,String.valueOf(Case_Note__c.SObjectType).toLowerCase()),
                                          Case__c = caze.Id);
       	Test.startTest();
       	System.runAs(userATM) {
        	try {
           		insert note2;
        	}catch (Exception e) {
        	 	System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_NOTE_ON_BREACH_ERROR_MSG), 'Error Message');
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_NOTE_SUBJECT_ON_BREACH_ERROR_MSG), 'Error Message');
        	}
       	}
        Test.stopTest();  	
   	}
    
      
    /**
    * @description Method to test if a SysAdmin User will execute the business logic for SPI Security Control
    */
    @isTest
   	static void testCaseNoteOnInsertWithSysAdminUser() {   	
        createCase(sysAdminUser);
        caze = [Select Id from Case where AccountId = :accountId];
		Case_Note__c noteInsert = new Case_Note__c(Name =ssnViolationData.replace(keyIdSobj,String.valueOf(Case_Note__c.SObjectType).toLowerCase()),
                                          Comments__c = ssnViolationData.replace(keyIdSobj,String.valueOf(Case_Note__c.SObjectType).toLowerCase()),
                                          Case__c = caze.Id);
       	Test.startTest();
       	System.runAs(sysAdminUser) {
        	try {
           		insert noteInsert;
        	}catch (Exception e) {
        	 	System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_NOTE_ON_BREACH_ERROR_MSG), 'Error Message');
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_NOTE_SUBJECT_ON_BREACH_ERROR_MSG), 'Error Message');
        	}
       	}
        Test.stopTest(); 
               
   	} 
    /**
    * @description Method to test if a SysAdmin User will execute the business logic for SPI Security Control
    */
    @isTest
   	static void testCaseNoteOnUpdateWithSysAdminUser() {   	
        createCase(sysAdminUser);
        caze = [Select Id from Case where AccountId = :accountId];
		Case_Note__c noteInsert = new Case_Note__c(Name ='TestNoteName',
                                          Comments__c = 'Note Comment',
                                          Case__c = caze.Id);       	
       	System.runAs(sysAdminUser) {       	
           	insert noteInsert;        	
       	}
               
        Case_Note__c noteForUpdate = [SELECT Comments__c, Name, Case__c FROM Case_Note__c WHERE Id=:noteInsert.Id];
        noteForUpdate.Comments__c =ssnViolationData.replace(keyIdSobj,String.valueOf(Case_Note__c.SObjectType).toLowerCase());
        noteForUpdate.Name =ssnViolationData.replace(keyIdSobj,String.valueOf(Case_Note__c.SObjectType).toLowerCase());
       	Test.startTest();
        System.runAs(sysAdminUser) {
            try {
                update noteForUpdate;
            }catch (Exception e) {
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_NOTE_ON_BREACH_ERROR_MSG), 'Error Message');
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_NOTE_SUBJECT_ON_BREACH_ERROR_MSG), 'Error Message');
            }       
       	}
       	Test.stopTest(); 
   	}  
   
    /**
    * @description Method to test if a CCC Licensed user will execute the business logic for SPI Security Control
    */
    @isTest
  	static void testCaseNoteOnInsertSPIcheckCCCLicensed() {
        cccLicensed = [Select Id, Associate_Id__c from User where Associate_Id__c = '12345678913'];
        userATM = [Select Id, Associate_Id__c from User where Associate_Id__c = '12345678912'];
        createCase(cccLicensed);
        caze = [Select Id from Case where AccountId = :accountId];
		Case_Note__c note3 = new Case_Note__c(Name =ssnViolationData.replace(keyIdSobj,String.valueOf(Case_Note__c.SObjectType).toLowerCase()),
                                          Comments__c= ssnViolationData.replace(keyIdSobj,String.valueOf(Case_Note__c.SObjectType).toLowerCase()),
                                          Case__c = caze.Id);
       	Test.startTest();
       	System.runAs(cccLicensed) {
        	try {
           		insert note3;
        	}catch (Exception e) {
        	 	System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_NOTE_ON_BREACH_ERROR_MSG), 'Error Message');
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_NOTE_SUBJECT_ON_BREACH_ERROR_MSG), 'Error Message');
        	}
       	}
        Test.stopTest();  	
   	}
}