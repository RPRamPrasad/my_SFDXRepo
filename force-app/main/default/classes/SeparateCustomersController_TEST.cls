/**
  *    Author          : Garvit (ywk1)
  *    Team            : Targaryen (CMM)
  *    Date Created    : 07/25/2019
  *    @description     : Apex unit testing for    SeparateCustomersController
  *    Version         : 1.0
  */

@isTest
(seeAllData=false)
public class SeparateCustomersController_TEST {
    private static final String CUSTOMER = 'Customer';

    /**
     * @description Test Setup Data
     */
    public static void testSetupData() {
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;

        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,SystemUser);
        insert passTriggerAll;

        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;

        insert objectBasedByPassTrigger;

        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);
        insert sysAdminUserIdSetting;
    }

    /**
     * @description Get Details NonAgency Profile Test
     */
     @isTest
    public static void getDetailsNonAgencyProfileTest(){
        testSetupData();
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        RecordType recType = [Select Id From RecordType Where DeveloperName = 'Individual' AND SobjectType = 'Account'];
        TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
        Account accountForAgentRole = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ',RecordTypeId=recType.Id);
        system.runAs(systemAdmin){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountForAgentRole;
        }

        test.startTest();
        try{
            SeparateCustomersController.getDetails(accountForAgentRole.Id);
            System.assertNotEquals('should not get here', 'should not get here','Expected String should not be equals to the given String');
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Exception message should be \'Script-thrown exception\'');
        }
        test.StopTest();

    }

    /**
     * @description Get Details Mobile Test
     */
     @isTest
    public static void getDetailsMobileTest(){
        testSetupData();
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        RecordType recType = [Select Id From RecordType Where DeveloperName = 'Individual' AND SobjectType = 'Account'];
        TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
        Account accountForAgentRole = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ',RecordTypeId=recType.Id);
        system.runAs(systemAdmin){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountForAgentRole;
        }

        test.startTest();
        try{
            SeparateCustomersController.isSalesforce1Theme = true;
            SeparateCustomersController.getDetails(accountForAgentRole.Id);
            System.assertNotEquals('should not get here', 'should not get here', 'Expected String should be equals to the given String');
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Exception message should be \'Script-thrown exception\'');
        }
        test.StopTest();

    }

    /**
     * @description Get Details Agency Profile Test
     */
     @isTest
    public static void getDetailsAgencyProfileTest(){
        testSetupData();
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        RecordType recType = [Select Id From RecordType Where DeveloperName = 'Individual' AND SobjectType = 'Account'];
        TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
        Account accountForAgentRole = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ',RecordTypeId=recType.Id);
        system.runAs(systemAdmin){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountForAgentRole;
        }

        test.startTest();
            SeparateCustomersController.loggedInProfile = Label.CL_Agent_Profile;
            Account acc = SeparateCustomersController.getDetails(accountForAgentRole.Id);
        test.StopTest();
        System.assertEquals(accountForAgentRole.Id, acc.Id, 'Expected id is not equals to the actual id');
    }

    /**
     * @description Get State Agent Code_Agent Test
     */
     @isTest
    public static void getStateAgentCodeAgentTest(){
        User testAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='accOwnerAgent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test_123test',Servicing_Agent_Associate_ID__c='123test');
    	User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        insert agentUser;
        string stateCode;
        test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        system.runAs(agentUser){
            stateCode = SeparateCustomersController.getStateAgentCode();
        }

    	test.StopTest();
        System.assertEquals(agentUser.State_Agent_Code__c, stateCode, 'Expected parameter should be equals to the actual parameter');

    }

    /**
     * @description Get State Agent Code_ATM Test
     */
     @isTest
    public static void getStateAgentCodeATMTest(){
        User testAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='accOwnerAgent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test_123test',Servicing_Agent_Associate_ID__c='123test');
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        insert agentUser;
    	User atmtUser = UTIL_UserProvisioning_TEST.buildAgentTeamUser('alias','accOwner','accOwnerATM@statefarm.com');
        atmtUser.Servicing_Agent_Associate_ID__c = '123test';
        atmtUser.UserExternalID__C = '1234test';
        insert atmtUser;
        string stateCode;
        test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmtUser);

        system.runAs(atmtUser){
            stateCode = SeparateCustomersController.getStateAgentCode();
        }

    	test.StopTest();
        System.assertEquals(agentUser.State_Agent_Code__c, stateCode, 'Expected parameter should be equals to the actual parameter');

    }

    /**
     * @description Get Custom Setting Details Test
     */
     @isTest
    public static void getCustomSettingDetailsTest(){
    	CS_HpsmWebService__c csHpsm= new CS_HpsmWebService__c(Name='separate',area__c='area', assignmentWorkgroup__c='WG08987',category__c='incident',
                                                              configItem__c='Reconcile',esclationGroup__c='WG008976',handedByGroup__c='WG007896',
                                                              handedByPerson__c='ecrm',impact__c='impact',service__c='service',subArea__c='subarea',urgency__c='4');
        insert csHpsm;
        test.startTest();
            CS_HpsmWebService__c hpsmCS = SeparateCustomersController.getCustomSettingDetails();
    	test.StopTest();
        System.assertEquals(csHpsm.Name, hpsmCS.Name, 'Expected Name should be equals to the actual Name');

    }

    /**
     * @description Check For Spi Test
     */
     @isTest
    public static void checkForSpiTest(){
    	String comments = 'SSN 678-78-9345';
        String textlable = 'comments';
        String errorMsg = '';
        test.startTest();
        	UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        	List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        	System.assert(spiSecurityControls.size()==1, 'Size of List<SPI_Security_Control__c> should be 1');
        	UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForCase();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            errorMsg = SeparateCustomersController.checkForSpi(comments,textlable);
        	system.debug(LoggingLevel.WARN, 'errorMsg'+errorMsg);
    	test.StopTest();
        System.assertEquals('Sensitive Personal Information (SPI) is not allowed to be entered in the comments field.', errorMsg, 'Expected error message should be equals to the actual error message');

    }

}