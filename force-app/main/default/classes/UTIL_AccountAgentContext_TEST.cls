/**
* @author Team Stark
* @owner Team Stark
* @name UTIL_AccountAgentContext_TEST
* @createDate 06/19/2020
* @description Common class to access various Account related CCC Agent Context operations TEST.
* @version 1.0
*/
@isTest(seeAllData=false)
private with sharing class UTIL_AccountAgentContext_TEST {
    
	private static DAOMock_AccountCreateEditHelper daoMockHelperInstance = new DAOMock_AccountCreateEditHelper();
    @TestSetup
    static void makeData() {
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

        insertTechnicalPlatformDetails();
    }
    
    /**
    * @description Inner class is used wrapper for Servicing Agent
    * @name : ServicingAgent
    */
    public class ServicingAgent {
        Id servicingAgentUserId;
        String servicingAgentAssocId;
        String servicingAgentName;
    }
    
    @isTest static void testGetTargetDomains() {
        
        String expected = 'http://targaryentestapp.app-71a.opr.test.statefarm.org,http://targaryentestapp.app-71b.opr.test.statefarm.org';
        CS_EnterpriseAppsTargetDomain__c domain1 = new CS_EnterpriseAppsTargetDomain__c();
        domain1.Name = 'Test App';
        domain1.isActive__c  = true;
        domain1.TargetDomain__c   = 'http://targaryentestapp.app-71a.opr.test.statefarm.org';
        
        CS_EnterpriseAppsTargetDomain__c domain2 = new CS_EnterpriseAppsTargetDomain__c();
        domain2.Name = 'Test App2';
        domain2.isActive__c  = true;
        domain2.TargetDomain__c   = 'http://targaryentestapp.app-71b.opr.test.statefarm.org';
        
        List<CS_EnterpriseAppsTargetDomain__c> domainlist = new List<CS_EnterpriseAppsTargetDomain__c>();
        domainlist.add(domain1);
        domainlist.add(domain2);
        insert domainlist;
        
        Test.startTest();
        	String result = UTIL_AccountAgentContext.getTargetDomains();
        	System.assertEquals(result, expected,'Target Domains Found');
        Test.stopTest();
    }
    
    @isTest static void testQueryForUserWithStAgtCode() {
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
        agentUser.UserExternalID__c = 'TestName_TestName';
        agentUser.State_Agent_Code__c = '45-2345';
        agentUser.UserType__c = 'Agent';
        agentUser.SubUserType__c = 'Agent';
        insert agentUser;
        Test.startTest();
            Object result = UTIL_AccountAgentContext.queryForUserWithStAgtCode(agentUser.State_Agent_Code__c);
            ServicingAgent servAgent = (ServicingAgent) JSON.deserialize(String.valueOf(result), ServicingAgent.class);
            System.assertEquals('TestName', servAgent.servicingAgentAssocId,'User is found');
        Test.stopTest();
    }

    @isTest static void testPopulateAgentDetailsFromAgentContext() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
        agentUser.UserExternalID__c = 'TestName_TestName';
        agentUser.State_Agent_Code__c = '45-2345';
        agentUser.UserType__c = 'Agent';
        agentUser.SubUserType__c = 'Agent';
        insert agentUser;
       
        User cccUser = UTIL_CreateCustomerTestData.createUserWithAssoId('3.00 CCC Licensed', 'TeCCCNa', 'TestCCCName','TestCCCName','TestCCCName_TestCCCName');
        cccUser.UserType__c = 'CCC';
        cccUser.SubUserType__c = 'CCC Sales';
        insert cccUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUser);
        Account acct = createIndividualWithValues();
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        insert acct;
        
        AgentContext__c agtCtxt = new AgentContext__c();
        agtCtxt.AgentContextIdentifier__c = cccUser.Associate_ID__c+'~'+acct.ClientIdentifier__c;
        agtCtxt.CCCRepresentative__c = cccUser.id;
        agtCtxt.InteractionId__c = '123456790';
        agtCtxt.Agent__c = agentUser.id;
        insert agtCtxt;
                
        Test.startTest();
        	System.runAs(cccUser){
                String result = UTIL_AccountAgentContext.populateAgentDetailsFromAgentContext(acct.ClientIdentifier__c);
                ServicingAgent servAgent = (ServicingAgent) JSON.deserialize(String.valueOf(result), ServicingAgent.class);
                System.assertEquals('TestName', servAgent.servicingAgentAssocId,'User is found');
            }
        Test.stopTest();
    }

    @isTest private static void testCreateIndCCCSalesUserContextUpdate() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AgtName', 'AgentName','AgentName','AgentName_AgentName');
        agentUser.UserType__c = 'Agent';
        agentUser.SubUserType__c = 'Agent';
        insert agentUser;

        User cccUser = UTIL_CreateCustomerTestData.createUserWithAssoId('3.00 CCC Licensed', 'TestName', 'TestName','TestName','TestName_TestName');
        cccUser.UserType__c = 'CCC';
        cccUser.SubUserType__c = 'CCC Sales';
        insert cccUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUser);
        AgentContext__c agtCtxt = new AgentContext__c();
        agtCtxt.AgentContextIdentifier__c = 'TestName~';
        agtCtxt.CCCRepresentative__c = cccUser.id;
        agtCtxt.InteractionId__c = '123456790';
        insert agtCtxt;
        
        Account acct = createIndividualWithValues();
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        
        String userJSON = '{"agentAssociateId":"AgentName","loggedInUserProfileName":"3.00 CCC Licensed"}';

        Test.startTest();
        System.runAs(cccUser){
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            UTIL_AccountCreateEditHelper.mockAccount = new Account(Id=acct.Id, ClientIdentifier__c=acct.ClientIdentifier__c);
            try {
            	String callTrackerURL = UTIL_AccountAgentContext.createAgentContextForCCCUser(acct.Id, true, userJSON);
                System.assertEquals(false, String.isEmpty(callTrackerURL), 'callTrackerURL is not empty');
            } catch (exception e) {
                System.assertEquals('System.DmlException', e.getTypeName(), 'Exception occur');
            }
        }
        Test.stopTest();
    }
    
    @isTest private static void testEditIndCCCSalesUserContextUpdate() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AgtName', 'AgentName','AgentName','AgentName_AgentName');
        agentUser.UserType__c = 'Agent';
        agentUser.SubUserType__c = 'Agent';
        insert agentUser;

        User cccUser = UTIL_CreateCustomerTestData.createUserWithAssoId('3.00 CCC Licensed', 'TestName', 'TestName','TestName','TestName_TestName');
        cccUser.UserType__c = 'CCC';
        cccUser.SubUserType__c = 'CCC Sales';
        insert cccUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUser);
        AgentContext__c agtCtxt = new AgentContext__c();
        agtCtxt.AgentContextIdentifier__c = 'TestName~';
        agtCtxt.CCCRepresentative__c = cccUser.id;
        agtCtxt.InteractionId__c = '123456790';
        insert agtCtxt;
        
        Account acct = createIndividualWithValues();
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
		
        String userJSON = '{"agentAssociateId":"AgentName","loggedInUserProfileName":"3.00 CCC Licensed"}';
        
        Test.startTest();
        System.runAs(cccUser){
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            UTIL_AccountCreateEditHelper.mockAccount = new Account(Id=acct.Id);
            try {
            	String callTrackerURL = UTIL_AccountAgentContext.createAgentContextForCCCUser(acct.Id, false, userJSON);
                System.assertEquals(false, String.isEmpty(callTrackerURL), 'callTrackerURL is not empty');
            } catch (exception e) {
                System.debug(LoggingLevel.INFO, 'Exception'+e);
                //System.assertEquals('System.DmlException', e.getTypeName(), 'Exception occur');
            }
        }
        Test.stopTest();
    }
    
    @isTest private static void testCreateIndCCCSalesUserContextInsert() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AgtName', 'AgentName','AgentName','AgentName_AgentName');
        agentUser.UserType__c = 'Agent';
        agentUser.SubUserType__c = 'Agent';
        insert agentUser;

        User cccUser = UTIL_CreateCustomerTestData.createUserWithAssoId('3.00 CCC Licensed', 'TestName', 'TestName','TestName','TestName_TestName');
        cccUser.UserType__c = 'CCC';
        cccUser.SubUserType__c = 'CCC Sales';
        insert cccUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUser);
        Account acct = createIndividualWithValues();
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
		
        String userJSON = '{"agentAssociateId":"AgentName","loggedInUserProfileName":"3.00 CCC Licensed"}';
        
        Test.startTest();
        System.runAs(cccUser){
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            UTIL_AccountCreateEditHelper.mockAccount = new Account(Id=acct.Id);
            String callTrackerURL = UTIL_AccountAgentContext.createAgentContextForCCCUser(acct.Id, true, userJSON);
            System.assertEquals(false, String.isEmpty(callTrackerURL), 'callTrackerURL is null or empty');
        }
        Test.stopTest();
    }

    private static Account createIndividualWithValues() {
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acc.FirstName = 'Test First Name';
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.BillingCity = 'Bloomington';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '61704';
        acc.BillingCountry = 'US';
        acc.MailingAttention__c= 'Attn';
        acc.ShippingAddressType__c = 'US';
        acc.ShippingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.ShippingCity = 'Bloomington';
        acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '61704';
        acc.ShippingCountry = 'US';
        return acc;
    }

    private static  void insertTechnicalPlatformDetails(){
        CS_TechnicalPlatform__c srKey = new CS_TechnicalPlatform__c();
        srKey.Name = 'SR_API_KEY';
        srKey.Value__c = 'Test Key';

        CS_TechnicalPlatform__c srCategory = new CS_TechnicalPlatform__c();
        srCategory.Name = 'SR_CATEGORY';
        srCategory.Value__c = 'a';
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};

        CS_EnvironmentURLCustomSetting__c envURL = new CS_EnvironmentURLCustomSetting__c(Name = 'S1BaseUrl', Value__c = 'TestURL');
        insert envURL;
    }
}