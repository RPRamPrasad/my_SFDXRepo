/**
* Author : ITIC Team
* Date Created : 08/09/2017
* @description : AP_OpportunityNote_InsertUpdate_TEST - Opportunity Note class leveraged by apex triggers for preventing SPI data from being entered in free formed text fields.
* Version : 1.0
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     added @isTest annotations
*/ 
@isTest
(seeAllData=false)
private class AP_OpportunityNote_InsertUpdate_TEST {
    static Account account;
    public static User sysAdminUser = TestDataFactory_User.getSysAdminUser();
    public static User userAgent;
    public static User userATM;
    public static String ssn_Violation_Data = UTIL_SPITestConstants.SPI_DATA_SSN_VIOLATION;    
    public static String key_Id_Sobj = UTIL_SPITestConstants.KEY_IDENTIFIER_SOBJ;
    /**
     * @description Opportunity
     */
    public static Opportunity opportunity { get; private set; }
    /**
     * @description Note
     */
    public static Opportunity_Note__c note { get; private set; }

    /**
      * @method Setup method used for building test data (must be called at beginning of test)
      * @description   setUp
      */
    @testSetup
    public static void setUp(){
    	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        userAgent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678911');
        userAgent = TestDataFactory_User.insertUser(userAgent); 
        userATM = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('TEST', '12345678912');
        userATM = TestDataFactory_User.insertUser(userATM); 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{userAgent,userATM});
        TestDataFactory_CustomSetting.createSPIDataCustomSettingsForOpportunityNote();
        TestDataFactory_CustomSetting.createSPISecurityControlsData();
        createAccount();
    }
    
    /**
     * @description createAccount
     */
    public static void createAccount(){
        account = TestDataFactory_Account.createIndividualCustomer('TestAccountName');
        System.runAs(sysAdminUser){
            TestDataFactory_Account.byPassAccountBeforeTrigger();
            TestDataFactory_Opportunity.byPassOpportunityBeforeTrigger();
            TestDataFactory_Account.insertAccount(account);
        }
    }
    
    /**
     * @description createOpportunity
     * @param user 
     */
    public static void createOpportunity(User user){
        Account account = [Select Id, name from account where firstname='TestAccountName'];
        opportunity = TestDataFactory_Opportunity.generateOpportunity('TestOpportunityForNote');
        opportunity.AccountId = account.Id;
        opportunity.OwnerId = user.Id; 
        System.runAs(sysAdminUser){
            TestDataFactory_Opportunity.insertOpportunity(Opportunity); 
        }
    }
   
    /**
      * @method Method to test if a Agent User will execute the business logic for SPI Security Control
      * @description   testOpportunityNoteBeforeInsertWithAgentUser
      */
    @isTest
   static void testOpportunityNoteBeforeInsertWithAgentUser() {
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678911'];
        createOpportunity(userAgent);
        Opportunity opportunity = [Select Id, name from Opportunity where name= 'TestOpportunityForNote'];
		Opportunity_Note__c note = new Opportunity_Note__c(Name='TestNoteName',
                                          Comments__c= ssn_Violation_Data.replace(key_Id_Sobj,String.valueOf(Opportunity_Note__c.SObjectType).toLowerCase()),
                                          Opportunity__c=opportunity.Id);
       Test.startTest();
       System.runAs(userAgent) {
        try {
            insert note;
        }catch (Exception e) {
        	 System.assert(e.getMessage().contains(UTIL_SPITestConstants.OPPORTUNITY_NOTE_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value '+UTIL_SPITestConstants.OPPORTUNITY_NOTE_ON_BREACH_ERROR_MSG);
        }
       }
        Test.stopTest();
   }
   
    /**
      * @method Method to test if a ATM user will execute the business logic for SPI Security Control
      * @description   testOpportunityNoteBeforeInsertWithATMUser
      */
    @isTest
   static void testOpportunityNoteBeforeInsertWithATMUser() {
        userATM = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678912'];
    	createOpportunity(userATM);
        Opportunity opportunity = [Select Id, name from Opportunity where name= 'TestOpportunityForNote'];
        Opportunity_Note__c note = new Opportunity_Note__c(Name='TestNoteName',
                                          Comments__c= ssn_Violation_Data.replace(key_Id_Sobj,String.valueOf(Opportunity_Note__c.SObjectType).toLowerCase()),
                                          Opportunity__c=opportunity.Id);
        Test.startTest();
        System.runAs(userATM) {
            try {
                insert note; 
            }catch (Exception e) {
                 System.assert(e.getMessage().contains(UTIL_SPITestConstants.OPPORTUNITY_NOTE_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value ' +UTIL_SPITestConstants.OPPORTUNITY_NOTE_ON_BREACH_ERROR_MSG);
            }
       }
       Test.stopTest();
   }
    
    
    /**
      * @method Method to test if a SysAdmin User will execute the business logic for SPI Security Control
      * @description testOpportunityNoteBeforeUpdateWithSysAdminUser
      */
    @isTest
   static void testOpportunityNoteBeforeUpdateWithSysAdminUser() {
    	createOpportunity(sysAdminUser);
        Opportunity opportunity = [Select Id, name from Opportunity where name= 'TestOpportunityForNote'];
        Opportunity_Note__c noteInsert = new Opportunity_Note__c(Name='TestNoteName',
                                          Comments__c= 'TestNote',
                                          Opportunity__c=opportunity.Id);
        Test.startTest();
       	System.runAs(sysAdminUser){
        	insert noteInsert;   
       	}
        Opportunity_Note__c noteForUpdate = [SELECT Comments__c,Name,Opportunity__c FROM Opportunity_Note__c WHERE Id=:noteInsert.Id];
        noteForUpdate.Comments__c =ssn_Violation_Data.replace(key_Id_Sobj,String.valueOf(Opportunity_Note__c.SObjectType).toLowerCase());
       
        System.runAs(sysAdminUser) {
            try {
                update noteForUpdate;
            }catch (Exception e) {
                 System.assert(e.getMessage().contains(UTIL_SPITestConstants.OPPORTUNITY_NOTE_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value '+UTIL_SPITestConstants.OPPORTUNITY_NOTE_ON_BREACH_ERROR_MSG);
            }
        Test.stopTest();
       }
   }
}