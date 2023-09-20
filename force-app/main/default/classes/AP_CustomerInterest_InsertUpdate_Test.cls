/**
* Author : Team QuadCore
* Owner  :	Team Stark
* Date Created : 4/11/2018
* @description Test Customer Interst apex triggers for preventing SPI data from being entered in free formed text fields.
* Version : 1.0
*/
@isTest
(seeAllData=false)
public class AP_CustomerInterest_InsertUpdate_Test {
    
    public static User sysAdminUser = TestDataFactory_User.getSysAdminUser();
    public static User userAgent;
    public static User userATM;
    public static User techSupport;
    public static String sSNVIOLATIONDATA = UTIL_SPITestConstants.SPI_DATA_SSN_VIOLATION;    
    public static String kEYIDSOBJ = UTIL_SPITestConstants.KEY_IDENTIFIER_SOBJ;
        
    /**
    * @description Setup method used for building test data (must be called at beginning of test)
    * @name setUp
    */
    @testSetup
    public static void setUp(){
        userAgent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678911');
        userAgent = TestDataFactory_User.insertUser(userAgent);  
        userATM = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('TEST', '12345678912');
        userATM = TestDataFactory_User.insertUser(userATM);
        techSupport = TestDataFactory_User_Wrapper.generateTechnicalSupportUser('TEST', '12345678913');
        techSupport = TestDataFactory_User.insertUser(techSupport);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{techSupport, userAgent, userATM});
        TestDataFactory_CustomSetting.createSPIDataCustomSettingsForCustomerInterest();
        TestDataFactory_CustomSetting.createSPISecurityControlsData();
    }
    
    /**
    * @description Create test account record.
    * @name createAccount
    * @param  user
    */
    public static void createAccount(User user){
        Account account = TestDataFactory_Account.createIndividualCustomer('TestAccountName');
        System.runAs(sysAdminUser){
            account.OwnerId = user.Id;
            TestDataFactory_Account.byPassAccountBeforeTrigger();
            TestDataFactory_Opportunity.byPassOpportunityBeforeTrigger();
            TestDataFactory_Account.insertAccount(account);
        }
    }

    /**
    * @description Create test permission set record.
    * @name assigPermSet
    * @param  techSupportUser
    */
    public static void assigPermSet(User techSupportUser) {
        PermissionSet permSet1 = [select Id from PermissionSet where Name = 'CoreComponents_AllUsers'];
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet1.Id);
        PermissionSet permSet2 = [select Id from PermissionSet where Name = 'CoreComponents_User_R'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet2.Id);
        PermissionSet permSet3 = [select Id from PermissionSet where Name = 'CustomerView_Support_ModifyAll'];
        PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet3.Id);
        PermissionSet permSet4 = [select Id from PermissionSet where Name = 'CustomerInterest_ModifyAll'];
        PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet4.Id);
        System.runas(sysAdminUser){
            insert psa1;
            insert psa2;
            insert psa3;
            insert psa4;
        }
    }
    
    /**
    * @description Method to test if a Tech Support User will execute the business logic for SPI Security Control
    * @name testCustomerInterestBeforeInsertWithTechSupportUser
    */
    @isTest
    static void testCustomerInterestBeforeInsertWithTechSupportUser() {
        techSupport = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678913'];
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678911'];
        createAccount(userAgent);
        assigPermSet(techSupport);
        Account account = [Select Id, name from Account where lastname= 'TestAccountName'];
        CustomerInterest__c custInt = new CustomerInterest__c(CustomerInterest__c='Art',
												Comment__c= sSNVIOLATIONDATA.replace(kEYIDSOBJ,String.valueOf(CustomerInterest__c.SObjectType).toLowerCase()),
                                                Account__c=account.Id);
        Test.startTest();
        System.runAs(techSupport) {
        	String message = '';
            try {
                insert custInt;
            }catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message.contains(UTIL_SPITestConstants.CUSTOMER_INTEREST_ON_BREACH_ERROR_MSG), 'Error Message');
        }
        Test.stopTest();
    }
    
    /**
    * @description Method to test if a Tech Support User will execute the business logic for SPI Security Control
    * @name testCustomerInterestBeforeUpdateWithTechSupportUser
    */
    @isTest
    static void testCustomerInterestBeforeUpdateWithTechSupportUser() {
        techSupport = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678913'];
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678911'];
        createAccount(userAgent);
        assigPermSet(techSupport);
        Account account = [Select Id, name from Account where lastname= 'TestAccountName'];
        
        CustomerInterest__c custInt = new CustomerInterest__c(CustomerInterest__c='Art',
                                                   Comment__c= 'the comment',
                                                   Account__c=account.Id);
                                                   
		System.runAs(techSupport) {
			insert custInt;
		}

        custInt = [Select Id, name, Comment__c From CustomerInterest__c Where Account__c =: account.id];
        custInt.Comment__c = sSNVIOLATIONDATA.replace(kEYIDSOBJ,String.valueOf(CustomerInterest__c.SObjectType).toLowerCase());
        
        Test.startTest();
        System.runAs(techSupport) {
        	String message = '';
            try {
                update custInt;
            }catch (Exception e) {
            	message = e.getMessage();
            }
            System.assert(message.contains(UTIL_SPITestConstants.CUSTOMER_INTEREST_ON_BREACH_ERROR_MSG), 'Error Message');
        }
        Test.stopTest();
    }
    
    /**
    * @description Method to test if a Agent User will execute the business logic for SPI Security Control
    * @name testCustomerInterestBeforeInsertWithAgentUser
    */
    @isTest
    static void testCustomerInterestBeforeInsertWithAgentUser() {
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678911'];
        createAccount(userAgent);
        Account account = [Select Id, name from Account where lastname= 'TestAccountName'];
        CustomerInterest__c custInt = new CustomerInterest__c(CustomerInterest__c='Art',
                                                   Comment__c= sSNVIOLATIONDATA.replace(kEYIDSOBJ,String.valueOf(CustomerInterest__c.SObjectType).toLowerCase()),
                                                   Account__c=account.Id);
        Test.startTest();
        System.runAs(userAgent) {
            String message = '';
            try {
                insert custInt;
            }catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message.contains(UTIL_SPITestConstants.CUSTOMER_INTEREST_ON_BREACH_ERROR_MSG), 'Error Message');
        }
        Test.stopTest();
    }
    
    /**
    * @description Method to test if a ATM user will execute the business logic for SPI Security Control
    * @name testCustomerInterestBeforeInsertWithATMUser
    */
    @isTest
    static void testCustomerInterestBeforeInsertWithATMUser() {
        userATM = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678912'];
        createAccount(userATM);
        Account account = [Select Id, name from Account where lastname= 'TestAccountName'];
        CustomerInterest__c custInt = new CustomerInterest__c(CustomerInterest__c='Art',
                                                   Comment__c= sSNVIOLATIONDATA.replace(kEYIDSOBJ,String.valueOf(CustomerInterest__c.SObjectType).toLowerCase()),
                                                   Account__c=account.Id);
        Test.startTest();
        System.runAs(userATM) {
            String message = '';
            try {
                insert custInt;
            }catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message.contains(UTIL_SPITestConstants.CUSTOMER_INTEREST_ON_BREACH_ERROR_MSG), 'Error Message');
        }
        Test.stopTest();
    }
    
    /**
    * @description Method to test if a SysAdmin User will execute the business logic for SPI Security Control
    * @name testCustomerInterestBeforeUpdateWithSysAdminUser
    */
    @isTest
    static void testCustomerInterestBeforeUpdateWithSysAdminUser() {
        createAccount(sysAdminUser);
        Account account = [Select Id, name from Account where lastname= 'TestAccountName'];
        CustomerInterest__c custIntInsert = new CustomerInterest__c(CustomerInterest__c='Art',
                                                         comment__c= 'TestcustInt',
                                                         Account__c=account.Id);
        Test.startTest();
        System.runAs(sysAdminUser){
            insert custIntInsert;
        }
        CustomerInterest__c custIntForUpdate = [SELECT comment__c,Name,Account__c FROM CustomerInterest__c WHERE Id=:custIntInsert.Id];
        custIntForUpdate.comment__c =sSNVIOLATIONDATA.replace(kEYIDSOBJ,String.valueOf(CustomerInterest__c.SObjectType).toLowerCase());
        
        System.runAs(sysAdminUser) {
            String message = '';
            try {
                update custIntForUpdate;
            }catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message.contains(UTIL_SPITestConstants.CUSTOMER_INTEREST_ON_BREACH_ERROR_MSG), 'Error Message');
            Test.stopTest();
        }
    }
}