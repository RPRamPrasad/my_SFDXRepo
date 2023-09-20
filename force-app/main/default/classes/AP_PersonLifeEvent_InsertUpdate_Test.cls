/**
* @Author : Team Targaryen
* @Owner: Team Targaryen
* @Date Created : 01/02/2020
* @description : Test Person Life Event apex triggers for preventing SPI data from being entered in free formed text fields and Validation Rule.
* @Version : 1.0
*/

@isTest
(seeAllData=false)
public class AP_PersonLifeEvent_InsertUpdate_Test {
    
    public static User sysAdminUser = TestDataFactory_User.getSysAdminUser();
    public static User userAgent;
    public static User userATM;
    public static User techSupport;
    public static final String SSN_VIOLATION_DATA = UTIL_SPITestConstants.SPI_DATA_SSN_VIOLATION;    
    public static final String KEY_ID_SOBJ = UTIL_SPITestConstants.KEY_IDENTIFIER_SOBJ;
	public static final String PERSON_LIFE_EVENT_EVENT_TYPE = 'Car';
    private static PermissionSetAssignment psassignment;
    private static final String PERSON_LIFE_EVENT_VALIDATION_ERROR='You are not authorized to modify Life Event Name and Life Event Comment.';
        
    /**
    * @description Setup method used for building test data (must be called at beginning of test)
    * @name   setUp
    */
    @testSetup
    public static void setUp(){
        userAgent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678911');
		userAgent.Servicing_Agent_Associate_ID__c = '12345678911';
        userAgent = TestDataFactory_User.insertUser(userAgent);  
        userATM = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('TEST', '12345678912');
		userATM.Servicing_Agent_Associate_ID__c = '12345678911';
        userATM = TestDataFactory_User.insertUser(userATM);
        techSupport = TestDataFactory_User_Wrapper.generateTechnicalSupportUser('TEST', '12345678913');
        techSupport = TestDataFactory_User.insertUser(techSupport);
        TestDataFactory_CustomSetting.createSPIDataCustomSettingsForPersonLifeEvent();
        TestDataFactory_CustomSetting.createSPISecurityControlsData();
    }

    /**
    * @description This method will create Individual Account
    * @name   setUp
    * @param user
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
    * @description Method to test if a Tech Support User will execute the business logic for SPI Security Control
    * @name   testCustomerInterestBeforeInsertWithTechSupportUser    
    */
    @isTest
    static void testPersonLifeEventBeforeInsertWithTechSupportUser() {
        techSupport = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678913'];
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678911'];
        createAccount(userAgent);
        psassignment = assignPSet(techSupport);
        insert psassignment;
        Contact contact = [Select Id, name from Contact where lastname= 'TestAccountName'];
        Datetime myEventDate = Datetime.newInstance(2019, 12, 1, 12, 30, 2);
        PersonLifeEvent personlifeEvt = new PersonLifeEvent(EventType=PERSON_LIFE_EVENT_EVENT_TYPE,
                                                Name=SSN_VIOLATION_DATA.replace(KEY_ID_SOBJ,String.valueOf(PersonLifeEvent.SObjectType).toLowerCase()),
                                                EventDescription='My New Car Rolls Royce',
                                                EventDate=myEventDate,
                                                PrimaryPersonId =contact.Id);
        Test.startTest();
        System.runAs(techSupport) {
        	String message = '';
            try {
                insert personlifeEvt;
            }catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message.contains(UTIL_SPITestConstants.PERSON_LIFE_EVENT_ON_EVENT_NAME_BREACH_ERROR_MSG), 'Exception message should contain the given String parameter');
        }
        Test.stopTest();
    }
    
    
        /**
    * @description Method to test if a Tech Support User can able to update Event Date, Event Name and Event Descrption
    * @name   testPersonLifeEventBeforeUpdateWithTechSupportUser
    */
    @isTest
    static void testPersonLifeEventBeforeUpdateWithTechSupportUser() {
        techSupport = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678913'];
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678911'];
        createAccount(userAgent);
        psassignment = assignPSet(techSupport);
        insert psassignment;
        assigPermSetTech(techSupport);
        Contact contact = [Select Id, name from Contact where lastname= 'TestAccountName'];
        Datetime myEventDate = Datetime.newInstance(2019, 12, 1, 12, 30, 2);
        PersonLifeEvent personlifeEvt = new PersonLifeEvent(EventType=PERSON_LIFE_EVENT_EVENT_TYPE,Name='Rolls Royce',
                                                EventDescription='My New Car Rolls Royce',
                                                EventDate=myEventDate,
                                                PrimaryPersonId =contact.Id);
                                                   
		System.runAs(techSupport) {
			insert personlifeEvt;
		}
        
        Datetime myUpdatedEventDate = Datetime.newInstance(2020, 12, 2, 00, 00, 00);

        personlifeEvt = [Select Id, Name, EventDescription, EventDate From PersonLifeEvent Where PrimaryPersonId =: contact.Id];
        personlifeEvt.EventDate=myUpdatedEventDate;
        personlifeEvt.Name='BMW';
        personlifeEvt.EventDescription='My New BMW';
        Test.startTest();
        System.runAs(techSupport) {
        	String message = '';
            try {
                update personlifeEvt;
            }catch (Exception e) {
            	message = e.getMessage();
            }
         personlifeEvt = [Select Id, Name, EventDescription, EventDate From PersonLifeEvent Where PrimaryPersonId =: contact.Id];
         String newUpdatedDate= String.valueOf(personlifeEvt.EventDate);
         system.assertEquals('BMW', personlifeEvt.Name,'Event Name is not matching');
         system.assertEquals('My New BMW', personlifeEvt.EventDescription,'Event Description is not matching');
         system.assert(newUpdatedDate.contains('2020-12-02'), 'String should contain the \'2020-12-02\'');
        }
        Test.stopTest();
    }

  /**
    * @description Method to test if a Agent User will execute the business logic for SPI Security Control
    * @name   testPersonLifeEventBeforeInsertWithAgentUser
    */
    @isTest
    static void testPersonLifeEventBeforeInsertWithAgentUser() {
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678911'];
        createAccount(userAgent);
        psassignment = assignPSet(userAgent);
        insert psassignment;
        Contact contact = [Select Id, name from Contact where lastname= 'TestAccountName'];
        Datetime myEventDate = Datetime.newInstance(2019, 12, 1, 12, 30, 2);
        PersonLifeEvent personlifeEvt = new PersonLifeEvent(EventType=PERSON_LIFE_EVENT_EVENT_TYPE,
                                                Name=SSN_VIOLATION_DATA.replace(KEY_ID_SOBJ,String.valueOf(PersonLifeEvent.SObjectType).toLowerCase()),
                                                EventDescription=SSN_VIOLATION_DATA.replace(KEY_ID_SOBJ,String.valueOf(PersonLifeEvent.SObjectType).toLowerCase()),
                                                EventDate=myEventDate,
                                                PrimaryPersonId =contact.Id);
        Test.startTest();
        System.runAs(userAgent) {
        	String message = '';
            try {
                insert personlifeEvt;
            }catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message.contains(UTIL_SPITestConstants.PERSON_LIFE_EVENT_ON_EVENT_NAME_BREACH_ERROR_MSG), 'Exception message should contain the given String parameter');
            System.assert(message.contains(UTIL_SPITestConstants.PERSON_LIFE_EVENT_ON_EVENT_COMMENT_BREACH_ERROR_MSG), 'Exception message should contain the given String parameter');
        }
        Test.stopTest();
    }

    /**
    * @description Method to test if a ATM user will execute the business logic for SPI Security Control
    * @name   testPersonLifeEventBeforeInsertWithATMUser
    */
    @isTest
    static void testPersonLifeEventBeforeInsertWithATMUser() {
        userATM = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678912'];
        createAccount(userATM);
        psassignment = assignPSet(userATM);
        insert psassignment;
        Contact contact = [Select Id, name from Contact where lastname= 'TestAccountName'];
        Datetime myEventDate = Datetime.newInstance(2019, 12, 1, 12, 30, 2);
        PersonLifeEvent personlifeEvt = new PersonLifeEvent(EventType=PERSON_LIFE_EVENT_EVENT_TYPE,
                                                Name=SSN_VIOLATION_DATA.replace(KEY_ID_SOBJ,String.valueOf(PersonLifeEvent.SObjectType).toLowerCase()),
                                                EventDescription='My New Car Rolls Royce',
                                                EventDate=myEventDate,
                                                PrimaryPersonId =contact.Id);
        Test.startTest();
        System.runAs(userATM) {
        	String message = '';
            try {
                insert personlifeEvt;
            }catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message.contains(UTIL_SPITestConstants.PERSON_LIFE_EVENT_ON_EVENT_NAME_BREACH_ERROR_MSG), 'Exception message should contain the given String parameter');
        }
        Test.stopTest();
    }

  /**
    * @description Method to test if a Agent User will not able to update Name and Event Description
    * @name   testPersonLifeEventBeforeUpdateEventNameAndDescriptionWithAgentUser
    */
    @isTest
    static void testPersonLifeEventBeforeUpdateEventNameAndDescriptionWithAgentUser() {
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678911'];
        createAccount(userAgent);
        psassignment = assignPSet(userAgent);
        insert psassignment;
        Contact contact = [Select Id, name from Contact where lastname= 'TestAccountName'];
        Datetime myEventDate = Datetime.newInstance(2019, 12, 1, 12, 30, 2);
        PersonLifeEvent personlifeEvt = new PersonLifeEvent(EventType=PERSON_LIFE_EVENT_EVENT_TYPE,
                                                Name='Audi',
                                                EventDescription='My New Audi Q7',
                                                EventDate=myEventDate,
                                                PrimaryPersonId =contact.Id);
        Test.startTest();
        System.runAs(userAgent) {        	
                insert personlifeEvt;
        }
        
        Datetime myUpdatedEventDate = Datetime.newInstance(2020, 12, 2, 00, 00, 00);

        personlifeEvt = [Select Id, Name, EventDescription From PersonLifeEvent Where PrimaryPersonId =: contact.Id];
        personlifeEvt.EventDate=myUpdatedEventDate;
        personlifeEvt.Name='BMW';
        personlifeEvt.EventDescription='My New BMW';
        System.runAs(userAgent) {
            String message = '';
            try {
                update personlifeEvt;
            }catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message.contains(PERSON_LIFE_EVENT_VALIDATION_ERROR), 'Exception message should contain the given String parameter'); 
        }  
                       
        Test.stopTest();
    }
    
      /**
    * @description Method to test if a Agent User will able to update Event Date
    * @name   testPersonLifeEventBeforeUpdateEventDateWithAgentUser
    */
    @isTest
    static void testPersonLifeEventBeforeUpdateEventDateWithAgentUser() {
        userAgent = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678911'];
        createAccount(userAgent);
        psassignment = assignPSet(userAgent);
        insert psassignment;
        Contact contact = [Select Id, name from Contact where lastname= 'TestAccountName'];
        Datetime myEventDate = Datetime.newInstance(2019, 12, 1, 12, 30, 2);
        PersonLifeEvent personlifeEvt = new PersonLifeEvent(EventType=PERSON_LIFE_EVENT_EVENT_TYPE,
                                                Name='Audi',
                                                EventDescription='My New Audi Q7',
                                                EventDate=myEventDate,
                                                PrimaryPersonId =contact.Id);
        Test.startTest();
        System.runAs(userAgent) {        	
                insert personlifeEvt;
        }
        
        Datetime myUpdatedEventDate = Datetime.newInstance(2020, 12, 2, 00, 00, 00);

        personlifeEvt = [Select Id, Name, EventDescription,EventDate From PersonLifeEvent Where PrimaryPersonId =: contact.Id];
        personlifeEvt.EventDate=myUpdatedEventDate;

        System.runAs(userAgent) {
            String message = '';
            try {
                update personlifeEvt;
            }catch (Exception e) {
                message = e.getMessage();
            }
            
         personlifeEvt = [Select Id, Name, EventDescription, EventDate From PersonLifeEvent Where PrimaryPersonId =: contact.Id];
         String newUpdatedDate= String.valueOf(personlifeEvt.EventDate);
         system.assert(newUpdatedDate.contains('2020-12-02'), 'Exception message should contain the \'2020-12-02\'');
         system.assertEquals('Audi', personlifeEvt.Name,'Event Name is not matching');
         system.assertEquals('My New Audi Q7', personlifeEvt.EventDescription,'Event Description is not matching');
        }  
        Test.stopTest();
    }
    
      /**
    * @description Method to test if a ATM User will not able to update Name and Event Description
    * @name   testPersonLifeEventBeforeUpdateEventNameAndDescriptionWithAgentUser
    */
    @isTest
    static void testPersonLifeEventBeforeUpdateEventNameAndDescriptionWithATMUser() {
        userATM = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678912'];
        createAccount(userATM);
        psassignment = assignPSet(userATM);
        insert psassignment;
        Contact contact = [Select Id, name from Contact where lastname= 'TestAccountName'];
        Datetime myEventDate = Datetime.newInstance(2019, 12, 1, 12, 30, 2);
        PersonLifeEvent personlifeEvt = new PersonLifeEvent(EventType=PERSON_LIFE_EVENT_EVENT_TYPE,
                                                Name='Audi',
                                                EventDescription='My New Audi Q7',
                                                EventDate=myEventDate,
                                                PrimaryPersonId =contact.Id);
        Test.startTest();
        System.runAs(userATM) {        	
                insert personlifeEvt;
        }
        
        Datetime myUpdatedEventDate = Datetime.newInstance(2020, 12, 2, 00, 00, 00);

        personlifeEvt = [Select Id, Name, EventDescription From PersonLifeEvent Where PrimaryPersonId =: contact.Id];
        personlifeEvt.EventDate=myUpdatedEventDate;
        personlifeEvt.Name='BMW';
        personlifeEvt.EventDescription='My New BMW';
        System.runAs(userATM) {
            String message = '';
            try {
                update personlifeEvt;
            }catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message.contains(PERSON_LIFE_EVENT_VALIDATION_ERROR), 'Exception message should contain the given String parameter'); 
        }  
                       
        Test.stopTest();
    }
    
      /**
    * @description Method to test if a ATM User will able to update Event Date
    * @name   testPersonLifeEventBeforeUpdateEventDateWithATMUser
    */
    @isTest
    static void testPersonLifeEventBeforeUpdateEventDateWithATMUser() {
        userATM = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678912'];
        createAccount(userATM);
        psassignment = assignPSet(userATM);
        insert psassignment;
        Contact contact = [Select Id, name from Contact where lastname= 'TestAccountName'];
        Datetime myEventDate = Datetime.newInstance(2019, 12, 1, 12, 30, 2);
        PersonLifeEvent personlifeEvt = new PersonLifeEvent(EventType=PERSON_LIFE_EVENT_EVENT_TYPE,
                                                Name='Audi',
                                                EventDescription='My New Audi Q7',
                                                EventDate=myEventDate,
                                                PrimaryPersonId =contact.Id);
        Test.startTest();
        System.runAs(userATM) {        	
                insert personlifeEvt;
        }
        
        Datetime myUpdatedEventDate = Datetime.newInstance(2020, 12, 2, 00, 00, 00);

        personlifeEvt = [Select Id, Name, EventDescription,EventDate From PersonLifeEvent Where PrimaryPersonId =: contact.Id];
        personlifeEvt.EventDate=myUpdatedEventDate;

        System.runAs(userATM) {
            String message = '';
            try {
                update personlifeEvt;
            }catch (Exception e) {
                message = e.getMessage();
            }
            
         personlifeEvt = [Select Id, Name, EventDescription, EventDate From PersonLifeEvent Where PrimaryPersonId =: contact.Id];
         String newUpdatedDate= String.valueOf(personlifeEvt.EventDate);
         system.assert(newUpdatedDate.contains('2020-12-02'), 'Exception message should contain 2020-12-02');
         system.assertEquals('Audi', personlifeEvt.Name,'Event Name is not matching');
         system.assertEquals('My New Audi Q7', personlifeEvt.EventDescription,'Event Description is not matching');
        }  
        Test.stopTest();
    }
 
  /**
    * @description Method to test if a CCCLicensed user will execute the business logic for SPI Security Control
    * @name   testPersonLifeEventBeforeInsertWithCCCLicensedUser
    */
    @isTest
    static void testPersonLifeEventBeforeInsertWithCCCLicensedUser() {
        User cccLicensed = TestDataFactory_User_Wrapper.generateActiveCCCLicensedUser('alias', '12345678915');
  		cccLicensed = TestDataFactory_User.insertUser(cccLicensed);
        cccLicensed = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678915'];
        createAccount(cccLicensed);
        psassignment = assignPSet(cccLicensed);
        insert psassignment;
        Contact contact = [Select Id, name from Contact where lastname= 'TestAccountName'];
        Datetime myEventDate = Datetime.newInstance(2019, 12, 1, 12, 30, 2);
        PersonLifeEvent personlifeEvt = new PersonLifeEvent(EventType=PERSON_LIFE_EVENT_EVENT_TYPE,
                                                Name=SSN_VIOLATION_DATA.replace(KEY_ID_SOBJ,String.valueOf(PersonLifeEvent.SObjectType).toLowerCase()),
                                                EventDescription='My New Car Rolls Royce',
                                                EventDate=myEventDate,
                                                PrimaryPersonId =contact.Id);
        Test.startTest();
        System.runAs(cccLicensed) {
        	String message = '';
            try {
                insert personlifeEvt;
            }catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message.contains(UTIL_SPITestConstants.PERSON_LIFE_EVENT_ON_EVENT_NAME_BREACH_ERROR_MSG), 'Exception message should contain the given String parameter');
        }
        Test.stopTest();
    } 
    
      /**
    * @description Method to test if a CCCUnLicensed user will execute the business logic for SPI Security Control
    * @name   testPersonLifeEventBeforeInsertWithCCCUnLicensedUser
    */
    @isTest
    static void testPersonLifeEventBeforeInsertWithCCCUnLicensedUser() {
        User cccUnLicensed = TestDataFactory_User_Wrapper.generateActiveCCCLicensedUser('alias', '12345678920');
  		cccUnLicensed = TestDataFactory_User.insertUser(cccUnLicensed);
        cccUnLicensed = [Select Id, Associate_Id__c from User where Associate_Id__c= '12345678920'];
        createAccount(cccUnLicensed);
        psassignment = assignPSet(cccUnLicensed);
        insert psassignment;
        Contact contact = [Select Id, name from Contact where lastname= 'TestAccountName'];
        Datetime myEventDate = Datetime.newInstance(2019, 12, 1, 12, 30, 2);
        PersonLifeEvent personlifeEvt = new PersonLifeEvent(EventType=PERSON_LIFE_EVENT_EVENT_TYPE,
                                                Name=SSN_VIOLATION_DATA.replace(KEY_ID_SOBJ,String.valueOf(PersonLifeEvent.SObjectType).toLowerCase()),
                                                EventDescription='My New Car Rolls Royce',
                                                EventDate=myEventDate,
                                                PrimaryPersonId =contact.Id);
        Test.startTest();
        System.runAs(cccUnLicensed) {
        	String message = '';
            try {
                insert personlifeEvt;
            }catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message.contains(UTIL_SPITestConstants.PERSON_LIFE_EVENT_ON_EVENT_NAME_BREACH_ERROR_MSG), 'Exception message should contain the given String parameter');
        }
        Test.stopTest();
    } 
  /**
    * @description This description is used for assign a particular PermissionSet to a particular User
    * @Method assignPSet <This method is used to get Standard testUser>
    * @param testUser
    * @return PermissionSetAssignment
    */     
    public static PermissionSetAssignment assignPSet (User testUser){
        PermissionSet ps = [Select Id, Name FROM PermissionSet WHERE Name='FSCInsurance'];
        return new PermissionSetAssignment(AssigneeId=testUser.Id,PermissionSetId=ps.Id);
    }

    /**
    * @description This description is used for assign a particular PermissionSet to a particular tech support User
    * @Method assignPSet <This method is used to get Standard testUser>
    * @param techSupportUser
    */     
    public static void assigPermSetTech(User techSupportUser) {
        PermissionSet permSet1 = [select Id from PermissionSet where Name = 'CoreComponents_AllUsers'];
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet1.Id);
        PermissionSet permSet2 = [select Id from PermissionSet where Name = 'CoreComponents_User_R'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet2.Id);
        PermissionSet permSet3 = [select Id from PermissionSet where Name = 'CustomerView_Support_ModifyAll'];
        PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet3.Id);
        PermissionSet permSet4 = [select Id from PermissionSet where Name = 'AccountNote_ModifyAll'];
        PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet4.Id);
        System.runas(sysAdminUser){
            insert psa1;
            insert psa2;
            insert psa3;
            insert psa4;
        }
    }
    
}