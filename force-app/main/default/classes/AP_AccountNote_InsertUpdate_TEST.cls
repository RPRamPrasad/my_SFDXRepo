/**
 * ATLAS APEX AUDIT
 * 8/30/2023
 */

/**
* Author : Hydra Team
* @Owner : Atlas
* Date Created : 12/19/2017
* Description : Account Note class leveraged by apex triggers for preventing SPI data from being entered in free formed text fields.
* Version : 1.0
*/

/**
 * @description AP_AccountNote_InsertUpdate_TEST
 */
@isTest
(seeAllData=false)
public class AP_AccountNote_InsertUpdate_TEST {
    
    public static User sysAdminUser = TestDataFactory_User.getSysAdminUser();
    public static User userAgent;
    public static User userATM;
    public static User techSupport;
    public static String ssn_Violation_Data = UTIL_SPITestConstants.SPI_DATA_SSN_VIOLATION;    
    public static String key_Id_Sobj = UTIL_SPITestConstants.KEY_IDENTIFIER_SOBJ;
    
    
        /**
    * @method Setup method used for building test data (must be called at beginning of test)
    * @name   setUp
    * @description setUp
    */
    @testSetup
    public static void setUp(){
    	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        userAgent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678911');
        userAgent = TestDataFactory_User.insertUser(userAgent);  
        userATM = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('TEST', '12345678912');
        userATM = TestDataFactory_User.insertUser(userATM);
        techSupport = TestDataFactory_User_Wrapper.generateTechnicalSupportUser('TEST', '12345678913');
        techSupport = TestDataFactory_User.insertUser(techSupport);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{techSupport, userAgent, userATM});        
        TestDataFactory_CustomSetting.createSPIDataCustomSettingsForAccountNote();
        TestDataFactory_CustomSetting.createSPISecurityControlsData();
    }
    
    /**
     * @description createAccount
     * @param user
     */
    public static void createAccount(User user){
    	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account account = TestDataFactory_Account.createIndividualCustomer('TestAccountName');
        System.runAs(sysAdminUser){
            account.OwnerId = user.Id;
            TestDataFactory_Account.byPassAccountBeforeTrigger();
            TestDataFactory_Opportunity.byPassOpportunityBeforeTrigger();
            TestDataFactory_Account.insertAccount(account);
        }
    }

     /**
     * @description assigPermSet
     * @param techSupportUser
     */
    public static void assigPermSet(User techSupportUser) {
        PermissionSet permSet1 = [select Id from PermissionSet where Name = 'CoreComponents_AllUsers'];
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet1.Id);
        PermissionSet permSet2 = [select Id from PermissionSet where Name = 'CoreComponents_User_R'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet2.Id);
        PermissionSet permSet3 = [select Id from PermissionSet where Name = 'CustomerView_Support_ModifyAll'];
        PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet3.Id);
        PermissionSet permSet4 = [select Id from PermissionSet where Name = 'AccountNote_ModifyAll'];
        PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet4.Id);
        PermissionSet permSet5 = [select Id from PermissionSet where Name = 'SPI_User'];
        PermissionSetAssignment psa5 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet5.Id);
        List<PermissionSetAssignment> psalist = new List<PermissionSetAssignment> {
            psa1, psa2, psa3, psa4, psa5
        };
        System.runas(sysAdminUser){
            insert psalist;
        }
    }
    
    /**
     * @description Catch error messages when trying to insert account note
     * @param accountNote
     * @return error message
    */
    public static string catchMessage(Account_Note__c accountNote) {
        String message = '';
        try {
            insert accountNote;
        }catch (Exception e) {
            message = e.getMessage();
        }
        return message;
    }

    /**
    * @method Method to test if a Tech Support User will execute the business logic for SPI Security Control
    * @name   testAccountNoteBeforeInsertWithTechSupportUser
    * @description testAccountNoteBeforeInsertWithTechSupportUser
    */
    @isTest
    static void testAccountNoteBeforeInsertWithTechSupportUser() {
    	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        techSupport = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678913'];
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678911'];
        createAccount(userAgent);
        assigPermSet(techSupport);
        Account account = [Select Id, name from Account where lastname= 'TestAccountName'];
        Account_Note__c note = new Account_Note__c(Comments__c= ssn_Violation_Data.replace(key_Id_Sobj,String.valueOf(Account_Note__c.SObjectType).toLowerCase()),
                                                   Account__c=account.Id);
        Test.startTest();
        System.runAs(techSupport) {
            System.assert(catchMessage(note).contains(UTIL_SPITestConstants.ACCOUNT_NOTE_ON_BREACH_ERROR_MSG), 'Error Message');
        }
        Test.stopTest();
    }
    
    /**
    * @method Method to test if a Tech Support User will execute the business logic for SPI Security Control
    * @name   testAccountNoteBeforeUpdateWithTechSupportUser
    * @description testAccountNoteBeforeUpdateWithTechSupportUser
    */
    @isTest
    static void testAccountNoteBeforeUpdateWithTechSupportUser() {
    	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        techSupport = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678913'];
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678911'];
        createAccount(userAgent);
        assigPermSet(techSupport);
        Account account = [Select Id, name from Account where lastname= 'TestAccountName'];
        
        Account_Note__c note = new Account_Note__c(Comments__c= 'the comment',
                                                   Account__c=account.Id);
                                                   
		System.runAs(techSupport) {
			insert note;
		}

        Account_Note__c updateNote = [Select Id, name, Comments__c From Account_Note__c Where Account__c =: account.id];
        updateNote.Comments__c = ssn_Violation_Data.replace(key_Id_Sobj,String.valueOf(Account_Note__c.SObjectType).toLowerCase());
        
        Test.startTest();
        System.runAs(techSupport) {
        	String message = '';
            try {
                update updateNote;
            }catch (Exception e) {
            	message = e.getMessage();
            }
            System.assert(message.contains(UTIL_SPITestConstants.ACCOUNT_NOTE_ON_BREACH_ERROR_MSG), 'Error Message');
        }
        Test.stopTest();
    }
    
        /**
    * @method Method to test if a Agent User will execute the business logic for SPI Security Control
    * @name   testAccountNoteBeforeInsertWithAgentUser
    * @description testAccountNoteBeforeInsertWithAgentUser
    */
    @isTest
    static void testAccountNoteBeforeInsertWithAgentUser() {
    	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678911'];
        createAccount(userAgent);
        Account account = [Select Id, name from Account where lastname= 'TestAccountName'];
        Account_Note__c note = new Account_Note__c(Comments__c= ssn_Violation_Data.replace(key_Id_Sobj,String.valueOf(Account_Note__c.SObjectType).toLowerCase()),
                                                   Account__c=account.Id);
        Test.startTest();
        System.runAs(userAgent) {
            System.assert(catchMessage(note).contains(UTIL_SPITestConstants.ACCOUNT_NOTE_ON_BREACH_ERROR_MSG), 'Error Message');
        }
        Test.stopTest();
    }
    
    /**
    * @method Method to test if a ATM user will execute the business logic for SPI Security Control
    * @name   testAccountNoteBeforeInsertWithATMUser
    * @description testAccountNoteBeforeInsertWithATMUser
    */
    @isTest
    static void testAccountNoteBeforeInsertWithATMUser() {
    	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        userATM = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678912'];
        createAccount(userATM);
        Account account = [Select Id, name from Account where lastname= 'TestAccountName'];
        Account_Note__c note = new Account_Note__c(Comments__c= ssn_Violation_Data.replace(key_Id_Sobj,String.valueOf(Account_Note__c.SObjectType).toLowerCase()),
                                                   Account__c=account.Id);
        Test.startTest();
        System.runAs(userATM) {
            System.assert(catchMessage(note).contains(UTIL_SPITestConstants.ACCOUNT_NOTE_ON_BREACH_ERROR_MSG), 'Error Message');
        }
        Test.stopTest();
    }
    
        /**
    * @method Method to test if a SysAdmin User will execute the business logic for SPI Security Control
    * @name   testAccountNoteBeforeUpdateWithSysAdminUser
    * @description testAccountNoteBeforeUpdateWithSysAdminUser
    */
    @isTest
    static void testAccountNoteBeforeUpdateWithSysAdminUser() {
    	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        createAccount(sysAdminUser);
        Account account = [Select Id, name from Account where lastname= 'TestAccountName'];
        Account_Note__c noteInsert = new Account_Note__c(Comments__c= 'TestNote',
                                                         Account__c=account.Id);
        Test.startTest();
        System.runAs(sysAdminUser){
            insert noteInsert;
        }
        Account_Note__c noteForUpdate = [SELECT Comments__c,Name,Account__c FROM Account_Note__c WHERE Id=:noteInsert.Id];
        noteForUpdate.Comments__c =ssn_Violation_Data.replace(key_Id_Sobj,String.valueOf(Account_Note__c.SObjectType).toLowerCase());
        
        System.runAs(sysAdminUser) {
            String message = '';
            try {
                update noteForUpdate;
            }catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message.contains(UTIL_SPITestConstants.ACCOUNT_NOTE_ON_BREACH_ERROR_MSG), 'Error Message');
            Test.stopTest();
        }
    }
    
}
