/**
* @author Team Stark
* @owner Team Stark
* @name UTIL_AccountCreateEditHelper_TEST
* @createDate 05/31/2020
* @description Common class to access various Account related operations for various Account Create Edit TEST.
* @version 1.0
*/
@isTest(seeAllData=false)
private with sharing class UTIL_AccountCreateEditHelper_TEST {

    private static UTIL_AccountCreateEditHelper doInstanceHelper = new UTIL_AccountCreateEditHelper();
    private static Integer countOfAccountBefore = [SELECT count() FROM Account];
    private static Account acc;
    private static AgentRole__c agentRole;
    private static CustomerGroup__c custGroup;
    private static CustomerGroupMember__c custGrpMember;
    private static AgentContext__c agentContext;
    private static User systemAdmin;

    @testsetup
    static void testSetupData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
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
  
        TestDataFactory_CustomSetting.createDeleteRecordConfig('System Administrator', 'Account'); 
    }

    //Setup the executing user
    private static User setupRunAsUser() {
        return UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
    }

    //@Description: Should update Account successfully
    @isTest static void testInsertAccountResult() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName', ClientIdentifier__c='accDAOTestz');
        acc.Edit_In_VFP__c = true;
        List<Account> accountsToBeInserted = new List<Account>();
        accountsToBeInserted.add(acc);
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            UTIL_AccountDAO.insertAccountResult(accountsToBeInserted);
            doInstanceHelper.getAccountDetails(acc.id);
        }    
        Test.stopTest();
        Account insertedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('testUtilAccDAOFName testUtilAccDAOLName', insertedAccount.Name,'get the account details');
    }
    
    @isTest static void testGetCustomerResource() {
        systemAdmin = setupRunAsUser();
        CM_Customer_Aggregator_Resource__mdt custResource = new CM_Customer_Aggregator_Resource__mdt();
        Test.startTest();
        System.runAs(systemAdmin) {
        	custResource = UTIL_AccountCreateEditHelper.getCustomerResource();
        }
        Test.stopTest();
        System.assertEquals(true, custResource!=null,'customer resource is not empty');
    }

    @isTest static void testGetCustomerAddressResource() {
        systemAdmin = setupRunAsUser();
        CM_Customer_Aggregator_Resource__mdt custAddrResource = new CM_Customer_Aggregator_Resource__mdt();
        Test.startTest();
        System.runAs(systemAdmin) {
        	custAddrResource = UTIL_AccountCreateEditHelper.getCustomerAddressResource();
        }
        Test.stopTest();
        System.assertEquals(true, custAddrResource!=null,'customer address resource is not empty');
    }

    @isTest static void testGetAccountRecordTypes() {
    	systemAdmin = setupRunAsUser();
        List<RecordType> accRT = new List<RecordType>();
        Test.startTest();
        System.runAs(systemAdmin) {
        	accRT = UTIL_AccountCreateEditHelper.getAccountRecordTypes();
        }
        Test.stopTest();
        System.assertEquals('Individual', accRT[0].DeveloperName,'get account record type');
    }

    @isTest static void testGetStateProvinceData() {
        systemAdmin = setupRunAsUser();
        List<CM_US_Canada_State__mdt> stateList = new List<CM_US_Canada_State__mdt>();
        Test.startTest();
        System.runAs(systemAdmin) {
        	stateList = UTIL_AccountCreateEditHelper.getStateProvinceData('US');
        }
        Test.stopTest();
        System.assertEquals(false, stateList.isEmpty(),'state data is not empty');
    }

    @isTest static void testGetMilitaryCityData() {
        systemAdmin = setupRunAsUser();
        List<CM_US_Canada_State__mdt> cityList = new List<CM_US_Canada_State__mdt>();
        Test.startTest();
        System.runAs(systemAdmin) {
        	cityList = UTIL_AccountCreateEditHelper.getMilitaryCityData('Overseas Military');
        }
        Test.stopTest();
        System.assertEquals(false, cityList.isEmpty(),'city list is not empty');
    }

    @isTest static void testGetSuffixData() {
        systemAdmin = setupRunAsUser();
        List<CS_Customer_Suffix__c> suffixList = new List<CS_Customer_Suffix__c>();
        CS_Customer_Suffix__c data = new CS_Customer_Suffix__c();
        data.Name='1ST'; 
        data.Sequence_Number__c = 3;
        insert data;
        Test.startTest();
        System.runAs(systemAdmin) {
        	suffixList = UTIL_AccountCreateEditHelper.getSuffixData();
        }
        Test.stopTest();
        System.assertEquals(false, suffixList.isEmpty(),'suffix data is not empty');
    }

    @isTest static void testGetEnterpriseAppTargetDomain() {
        systemAdmin = setupRunAsUser();
        List<CS_EnterpriseAppsTargetDomain__c> domainList = new List<CS_EnterpriseAppsTargetDomain__c>();
        CS_EnterpriseAppsTargetDomain__c data = new CS_EnterpriseAppsTargetDomain__c();
        data.Name = 'Home Owner';
        data.TargetDomain__c = 'https://sfdevvh65.opr.test.statefarm.org';
        data.isActive__c = true;
        insert data;
        Test.startTest();
        System.runAs(systemAdmin) {
        	domainList = UTIL_AccountCreateEditHelper.getEnterpriseAppTargetDomain();
        }
        Test.stopTest();
        System.assertEquals(false, domainList.isEmpty(),'target domain data is not empty');
    }

    @isTest static void testGetUsersWithStAgtCode() {
        systemAdmin = setupRunAsUser();
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
        agentUser.State_Agent_Code__c = '45-2345';
        agentUser.UserType__c = 'Agent';
        agentUser.SubUserType__c = 'Agent';
        insert agentUser;
        List<User> userList = new List<User>();
        Test.startTest();
        System.runAs(systemAdmin) {
        	userList = doInstanceHelper.getUsersWithStAgtCode('45-2345');
        }
        Test.stopTest();
        System.assertEquals(false, userList.isEmpty(),'user data is not empty');
    }

    @isTest static void testGetLoggedInUser() {
        systemAdmin = setupRunAsUser();
        User usr = new User();
        Test.startTest();
        System.runAs(systemAdmin) {
        	usr = doInstanceHelper.getLoggedInUser();
        }
        Test.stopTest();
        System.assertEquals(true, usr!=null,'user data is not empty');
    }

    @isTest static void testGetUsersWithAssociateId() {
        systemAdmin = setupRunAsUser();
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName_TestName');
        agentUser.State_Agent_Code__c = '45-2345';
        agentUser.UserType__c = 'Agent';
        agentUser.SubUserType__c = 'Agent';
        insert agentUser;
        List<User> userList = new List<User>();
        Test.startTest();
        System.runAs(systemAdmin) {
        	userList = doInstanceHelper.getUsersWithAssociateId('TestName');
        }
        Test.stopTest();
        System.assertEquals(false, userList.isEmpty(),'user data is not empty');
    }

    @isTest static void testGetAgentContextDetails() {
        User cccSalesUser = UTIL_CreateCustomerTestData.createUserWithAssoId('3.00 CCC Licensed', 'TestName', 'TestName','TestName','TestName_TestName');
        cccSalesUser.UserType__c = 'CCC';
        cccSalesUser.SubUserType__c = 'CCC Sales';
        insert cccSalesUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccSalesUser);
        Account acct = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        AgentContext__c agtCtxt = new AgentContext__c();
        agtCtxt.AgentContextIdentifier__c = cccSalesUser.Associate_ID__c+'~'+acct.ClientIdentifier__c;
        agtCtxt.CCCRepresentative__c = cccSalesUser.id;
        agtCtxt.InteractionId__c = '123456790';
        insert agtCtxt;
        List<AgentContext__c> agtCntxList = new List<AgentContext__c>();
        Test.startTest();
        System.runAs(cccSalesUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert acct;
        	agtCntxList = doInstanceHelper.getAgentContextDetails(agtCtxt.AgentContextIdentifier__c);
        }
        Test.stopTest();
        System.assertEquals(false, agtCntxList.isEmpty(),'agent context data is not empty');
    }

    @isTest static void testGetAgentContextAllowedProfile() {
        systemAdmin = setupRunAsUser();
        List<CM_AgentContextAllowedProfile__mdt> profileList = new List<CM_AgentContextAllowedProfile__mdt>();
        Test.startTest();
        System.runAs(systemAdmin) {
        	profileList = UTIL_AccountCreateEditHelper.getAgentContextAllowedProfile();
        }
        Test.stopTest();
        System.assertEquals(false, profileList.isEmpty(),'Allowed Profile data is not empty');
    }

    @isTest
    static void testIsActiveCustomer() {
        systemAdmin = setupRunAsUser();
        Integer agentRoleCount;
        UTIL_AccountCreateEditHelper.mockIsActiveCustomer = 3;
        Test.startTest();
        System.runAs(systemAdmin) {
            agentRoleCount = doInstanceHelper.isActiveCustomer('97PBB1YS000', 'SGGSP81L8XB');
        }
        Test.stopTest();
        System.assertEquals(3, agentRoleCount, 'Query should return 3 results');
    }
    
}
