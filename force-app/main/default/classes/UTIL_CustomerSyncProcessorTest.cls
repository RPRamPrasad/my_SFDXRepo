/**
* @Name: UTIL_CustomerSyncProcessorTest
* @Author: Loco Motivated
* @Description: This class contains unit tests for CustomerSyncProcessor
*
*/
/**
 *@description This class contains unit tests for CustomerSyncProcessor
 */
@isTest(seeAllData=false)
public class UTIL_CustomerSyncProcessorTest {

    private static User systemUser;
    private static User testAPIUser;
    private static final String CLIENT_IDENTIFIER='IAMCLIENT12';
    private static final String AGENT_IDENTIFIER_1='1111111111C~IAMCLIENT12';
	private static final String AGENT_IDENTIFIER_10CHAR='1111111111 ~IAMCLIENT12';

    private static Account accrecord;
    private static Account orgrecord;
    private static AgentRole__c agRole;
    private static AgentRole__c aR1;
    private static PermissionSetAssignment psassignment;
    private static CS_StageOrchestration_Counts__c counts;
    private static List<User> agentUserList = new List<User>();
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy2;
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static StageOrchestration__c testRecord= new StageOrchestration__c();
    private static List<StageOrchestration__c> stageOrchList=new List<StageOrchestration__c>();

    /**
     * @description This method is used to setup the test data
     */
    @TestSetup
	public static void setup() {
        User systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('C');
        salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('');
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        systemUser=UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');
        testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','test@statefarm.com');
        insert systemUser;
        insert testAPIUser;
        System.runas(systemUser){
        psassignment=UTIL_StageOrchestrationTestUtils.assignPSet(testAPIUser);
        insert psassignment;
        counts= new CS_StageOrchestration_Counts__c(Retry_Count__c=3,Chunk_Size__c=5);
        insert counts;
        }
        accrecord = new Account(FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER);
        accrecord.ExternalSourceSyncTime__c=Datetime.now();
        insert accrecord;
        aR1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.id,Customer__c=accrecord.id,RelationshipNature__c='Prospect',AgentRoleIdentifier__c=AGENT_IDENTIFIER_1);
        insert aR1;
    }

    @isTest
    static void testAccountandAgentRoleCreationScenario(){

        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='remCmpMemSysAd@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='testuser@statefarm.com' ];

        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
		system.runAs(systemUser){

                    counts=[Select Id from CS_StageOrchestration_Counts__c where Retry_Count__c=3 and Chunk_Size__c=5];

            testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
            testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION;
            testRecord.VersionNumber__c=1.0;
            //testRecord.Value__c=buildJsonString(CLIENT_IDENTIFIER,String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')),'DODODOD',salesRoleHierarchy1.Agent.Associate_ID__c);
			JsonStringWrapperList accountAndAgentRoleCreationWrap = new JsonStringWrapperList();
				accountAndAgentRoleCreationWrap.clientId = CLIENT_IDENTIFIER;
				accountAndAgentRoleCreationWrap.externalSourceSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
				accountAndAgentRoleCreationWrap.lastName = 'DODODOD';
				accountAndAgentRoleCreationWrap.assocId = salesRoleHierarchy1.Agent.Associate_ID__c;
			testRecord.Value__c = buildJsonString(accountAndAgentRoleCreationWrap);
        }
        stageOrchList.add(testRecord);
        System.runAs(testAPIUser){
            Test.startTest();
            insert stageOrchList;
            Test.stopTest();
        }
        Account acc=[select lastname from Account where clientidentifier__c=:CLIENT_IDENTIFIER];
        system.assertEquals('DODODOD', acc.lastname, 'Expected LastName is not equals to the actual LastName');
        AgentRole__c agRole1=[Select id, Customer__c, RelationshipNature__c from AgentRole__c Where AgentRoleIdentifier__c=:AGENT_IDENTIFIER_1];
        system.assertEquals('Customer', agRole1.RelationshipNature__c, 'Expected RelationshipNature__c is not equals to the actual RelationshipNature__c');
    }

    @isTest
    static void testAccountandAgentRoleErrorScenario(){

       systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='remCmpMemSysAd@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='testuser@statefarm.com' ];

       salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
		system.runAs(systemUser){

                    counts=[Select Id from CS_StageOrchestration_Counts__c where Retry_Count__c=3 and Chunk_Size__c=5];

            testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
            testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION;
            testRecord.VersionNumber__c=1.0;
            //testRecord.Value__c=buildJsonString('',String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')),'DODODOD',salesRoleHierarchy1.Agent.Associate_ID__c);
            JsonStringWrapperList accountandAgentRoleErrorWrap = new JsonStringWrapperList();
				accountandAgentRoleErrorWrap.clientId = '';
				accountandAgentRoleErrorWrap.externalSourceSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
				accountandAgentRoleErrorWrap.lastName = 'DODODOD';
				accountandAgentRoleErrorWrap.assocId = salesRoleHierarchy1.Agent.Associate_ID__c;
			testRecord.Value__c = buildJsonString(accountandAgentRoleErrorWrap);
        }
        stageOrchList.add(testRecord);
        System.runAs(testAPIUser){
            Test.startTest();
            insert stageOrchList;
            Test.stopTest();
        }
        StageOrchestration__c stageORCH = [select Id,status__c, Error__c from StageOrchestration__c where IdentifierValue__c=:CLIENT_IDENTIFIER limit 1];
        system.assertEquals('Failed', stageORCH.status__c, 'Expected status__c is not equals to the actual status__c') ;
        System.assertNotEquals('', stageORCH.Error__c, 'Error__c is an empty String');
    }

    @isTest
    static void testAccountandAgentRoleUpdationScenario(){

        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='remCmpMemSysAd@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='testuser@statefarm.com' ];

       salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');


        system.runAs(systemUser){

             counts=[Select Id from CS_StageOrchestration_Counts__c where Retry_Count__c=3 and Chunk_Size__c=5];

            aR1=[Select id, Customer__c, RelationshipNature__c from AgentRole__c Where AgentRoleIdentifier__c=:AGENT_IDENTIFIER_1];
        }

        testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
        testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION;
        testRecord.VersionNumber__c=1.0;
        //testRecord.Value__c=buildJsonString(CLIENT_IDENTIFIER,String.valueOf(Datetime.now().addMinutes(1).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')),'BDCFS','1111111111C');
        JsonStringWrapperList accountAndAgentRoleUpdationWrap = new JsonStringWrapperList();
			accountAndAgentRoleUpdationWrap.clientId = CLIENT_IDENTIFIER;
			accountAndAgentRoleUpdationWrap.externalSourceSyncTime = String.valueOf(Datetime.now().addMinutes(1).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			accountAndAgentRoleUpdationWrap.lastName = 'BDCFS';
			accountAndAgentRoleUpdationWrap.assocId = '1111111111C';
		testRecord.Value__c = buildJsonString(accountAndAgentRoleUpdationWrap);
        stageOrchList.add(testRecord);
        System.runAs(testAPIUser){
            Test.startTest();
            insert stageOrchList;
            Test.stopTest();
        }

        Account acc=[select LastName,IsHealthSourced__pc,PaperlessPrivacyNotice__c from Account where clientidentifier__c=:CLIENT_IDENTIFIER];
        system.assertEquals('BDCFS', acc.LastName, 'Expected LastName is not equals to the actual LastName');
        system.assertEquals(false, acc.IsHealthSourced__pc, 'IsHealthSourced__pc is true');
        system.assertEquals(null, acc.PaperlessPrivacyNotice__c, 'PaperlessPrivacyNotice__c is not null');
        AgentRole__c agRole1=[Select RelationshipNature__c from AgentRole__c Where AgentRoleIdentifier__c=:AGENT_IDENTIFIER_1];
        system.assertEquals('Customer', agRole1.RelationshipNature__c, 'Expected RelationshipNature__c is not equals to \'Customer\'');

    }

    @isTest
    static void testAccountandAgentRoleUpdationErrorScenario(){

        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='remCmpMemSysAd@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='testuser@statefarm.com' ];

       salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');


        system.runAs(systemUser){

                    counts=[Select Id from CS_StageOrchestration_Counts__c where Retry_Count__c=3 and Chunk_Size__c=5];

            aR1=[Select id, Customer__c, RelationshipNature__c from AgentRole__c Where AgentRoleIdentifier__c=:AGENT_IDENTIFIER_1];
        }

        testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
        testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION;
        testRecord.VersionNumber__c=1.0;
        //testRecord.Value__c=buildJsonString(CLIENT_IDENTIFIER,String.valueOf(Datetime.now().addMinutes(1).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')),'','');
        JsonStringWrapperList accountAndAgentRoleUpdationErrorWrap = new JsonStringWrapperList();
			accountAndAgentRoleUpdationErrorWrap.clientId = CLIENT_IDENTIFIER;
			accountAndAgentRoleUpdationErrorWrap.externalSourceSyncTime = String.valueOf(Datetime.now().addMinutes(1).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			accountAndAgentRoleUpdationErrorWrap.lastName = '';
			accountAndAgentRoleUpdationErrorWrap.assocId = '';
		testRecord.Value__c = buildJsonString(accountAndAgentRoleUpdationErrorWrap);
        stageOrchList.add(testRecord);
        System.runAs(testAPIUser){
            Test.startTest();
            insert stageOrchList;
            Test.stopTest();
        }

        StageOrchestration__c stageORCH = [select Id,status__c, Error__c from StageOrchestration__c where IdentifierValue__c=:CLIENT_IDENTIFIER limit 1];
        system.assertEquals('Failed', stageORCH.status__c, 'Expected LastName is not equals to \'Failed\'') ;
        System.assertNotEquals('', stageORCH.Error__c, 'Error__c is an empty String');
    }

    @isTest
    static void testAgentRoleErrorScenario(){

        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='remCmpMemSysAd@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='testuser@statefarm.com' ];

       salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');


        system.runAs(systemUser){

                    counts=[Select Id from CS_StageOrchestration_Counts__c where Retry_Count__c=3 and Chunk_Size__c=5];

            aR1=[Select id, Customer__c, RelationshipNature__c from AgentRole__c Where AgentRoleIdentifier__c=:AGENT_IDENTIFIER_1];
        }

        testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
        testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION;
        testRecord.VersionNumber__c=1.0;
        //testRecord.Value__c=buildJsonString(CLIENT_IDENTIFIER,String.valueOf(Datetime.now().addMinutes(1).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')),'BDCFS','1111111111X');
        JsonStringWrapperList agentRoleErrorWrap = new JsonStringWrapperList();
			agentRoleErrorWrap.clientId = CLIENT_IDENTIFIER;
			agentRoleErrorWrap.externalSourceSyncTime = String.valueOf(Datetime.now().addMinutes(1).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			agentRoleErrorWrap.lastName = 'BDCFS';
			agentRoleErrorWrap.assocId = '1111111111X';
		testRecord.Value__c = buildJsonString(agentRoleErrorWrap);
        stageOrchList.add(testRecord);
        System.runAs(testAPIUser){
            Test.startTest();
            insert stageOrchList;
            Test.stopTest();
        }

        StageOrchestration__c stageORCH = [select Id,status__c, Error__c from StageOrchestration__c where IdentifierValue__c=:CLIENT_IDENTIFIER limit 1];
        system.assertEquals('Failed With User Not Found', stageORCH.status__c, 'status__c not equals to \'Failed With User Not Found\'') ;
        System.assertNotEquals('', stageORCH.Error__c, 'Error__c is an empty String');
    }

    @isTest
    static void testAccountAgentRoleFailedScenario(){

        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='remCmpMemSysAd@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='testuser@statefarm.com' ];

       salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');


        system.runAs(systemUser){

                    counts=[Select Id from CS_StageOrchestration_Counts__c where Retry_Count__c=3 and Chunk_Size__c=5];

            aR1=[Select id, Customer__c, RelationshipNature__c from AgentRole__c Where AgentRoleIdentifier__c=:AGENT_IDENTIFIER_1];
        }

        testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
        testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION;
        testRecord.VersionNumber__c=1.0;
        testRecord.Value__c=buildInvalidJsonString(CLIENT_IDENTIFIER,String.valueOf(Datetime.now().addMinutes(1).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')));
        stageOrchList.add(testRecord);
        System.runAs(testAPIUser){
            Test.startTest();
            insert stageOrchList;
            Test.stopTest();
        }

        StageOrchestration__c stageORCH = [select Id,status__c, Error__c from StageOrchestration__c where IdentifierValue__c=:CLIENT_IDENTIFIER limit 1];
        system.assertEquals('Failed', stageORCH.status__c, 'status__c is not equals to \'Failed\'') ;
        System.assertNotEquals('', stageORCH.Error__c, 'Error__c is an empty String');
    }

    @isTest
    static void testAccountandAgentRoleCreationScenarioWith10CharAssocId(){
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='remCmpMemSysAd@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='testuser@statefarm.com' ];
        salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('');
        stageOrchList = new List<StageOrchestration__c>();
		system.runAs(systemUser){

            counts=[Select Id from CS_StageOrchestration_Counts__c where Retry_Count__c=3 and Chunk_Size__c=5];
           testRecord= new StageOrchestration__c();
            testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
            testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION;
            testRecord.VersionNumber__c=1.0;
            //testRecord.Value__c=buildJsonString(CLIENT_IDENTIFIER,String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')),'DODODOD','1111111111 ');
            JsonStringWrapperList accountAndAgentRoleCreationScenarioWith10CharWrap = new JsonStringWrapperList();
				accountAndAgentRoleCreationScenarioWith10CharWrap.clientId = CLIENT_IDENTIFIER;
				accountAndAgentRoleCreationScenarioWith10CharWrap.externalSourceSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
				accountAndAgentRoleCreationScenarioWith10CharWrap.lastName = 'DODODOD';
				accountAndAgentRoleCreationScenarioWith10CharWrap.assocId = '1111111111 ';
			testRecord.Value__c = buildJsonString(accountAndAgentRoleCreationScenarioWith10CharWrap);
        }
        stageOrchList.add(testRecord);
        System.runAs(testAPIUser){
            Test.startTest();
            insert stageOrchList;
            Test.stopTest();
        }
        Account acc=[select lastname from Account where clientidentifier__c=:CLIENT_IDENTIFIER];
        system.assertEquals('DODODOD', acc.lastname, 'Expected LastName is not equals to the actual LastName');
        AgentRole__c agRole1=[Select id, Customer__c, RelationshipNature__c from AgentRole__c Where AgentRoleIdentifier__c=:AGENT_IDENTIFIER_10CHAR];
        system.assertEquals('Customer', agRole1.RelationshipNature__c, 'Expected RelationshipNature__c is not equals to \'Customer\'');
    }

    @isTest
    static void testAccountOnlyUpdationScenario(){

        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='remCmpMemSysAd@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='testuser@statefarm.com' ];


        system.runAs(systemUser){

           counts=[Select Id from CS_StageOrchestration_Counts__c where Retry_Count__c=3 and Chunk_Size__c=5];

        }

        testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
        testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION;
        testRecord.VersionNumber__c=1.0;
        testRecord.Value__c=buildJsonAccountOnlyString(CLIENT_IDENTIFIER,String.valueOf(Datetime.now().addMinutes(1).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')),'SSLLSS');
        stageOrchList.add(testRecord);
        System.runAs(testAPIUser){
            Test.startTest();
            insert stageOrchList;
            Test.stopTest();
        }
        Account acc=[select lastname,IsNotShareable__pc,DoNotMail__c,PersonDoNotCall,IsProtectedPerson__c,
                     IsPrivacyOptionsShared__c,IsHearingImpaired__pc,IsHealthSourced__pc,PaperlessPrivacyNotice__c,PreferredSpokenLanguage__pc,IsSubjecttoCASL__c,
                     HasPermissionToServiceEmail__c,HasPermissionToServiceText__c,HasPermissionToMarketingEmail__c,HasPermissionToClaimEmail__c,HasPermissionToClaimText__c
                     from Account where clientidentifier__c=:CLIENT_IDENTIFIER];
        system.assertEquals('SSLLSS', acc.lastname, 'Expected LastName is not equals to the actual LastName');
        system.assertEquals(true, acc.IsHearingImpaired__pc, 'IsHearingImpaired__pc is false');

        system.assertEquals(true, acc.IsNotShareable__pc, 'IsNotShareable__pc is false');
        system.assertEquals(true, acc.DoNotMail__c, 'DoNotMail__c is false');
        system.assertEquals(true, acc.PersonDoNotCall, 'PersonDoNotCall is false');
        system.assertEquals(true, acc.IsProtectedPerson__c, 'IsProtectedPerson__c is false');
        system.assertEquals(false, acc.IsPrivacyOptionsShared__c, 'IsPrivacyOptionsShared__c is true');
        system.assertEquals(false, acc.IsHealthSourced__pc, 'IsHealthSourced__pc is true');
        system.assertEquals('Yes', acc.PaperlessPrivacyNotice__c, 'PaperlessPrivacyNotice__c is not equals to \'Yes\'');
        system.assertEquals('English', acc.PreferredSpokenLanguage__pc, 'PreferredSpokenLanguage__pc is not equals to \'English\'');
        system.assertEquals('Yes', acc.IsSubjecttoCASL__c, 'IsSubjecttoCASL__c is not equals to \'Yes\'');
        system.assertEquals('No', acc.HasPermissionToServiceText__c, 'HasPermissionToServiceText__c is not equals to \'No\'');
        system.assertEquals('Yes', acc.HasPermissionToServiceEmail__c, 'HasPermissionToServiceEmail__c is not equals to \'Yes\'');
        system.assertEquals('Waiting for Confirmation', acc.HasPermissionToMarketingEmail__c, 'HasPermissionToMarketingEmail__c is not equals to \'Waiting for Confirmation\'');
        system.assertEquals('Waiting for Confirmation', acc.HasPermissionToClaimEmail__c, 'HasPermissionToClaimEmail__c is not equals to \'Waiting for Confirmation\'');
        system.assertEquals('Yes', acc.HasPermissionToClaimText__c, 'HasPermissionToClaimText__c is not equals to \'Yes\'');
    }

    /**
     * @description This method is for build json for orchestration account string
     * @param orgAccountStringWrapper
     * @return  `String`
     */
    public static String buildJsonForOrgAccountString(JsonForOrgAccountStringWrapperList orgAccountStringWrapper) {
		String clientId = orgAccountStringWrapper.clientId;
		String externalSourceSyncTime = orgAccountStringWrapper.externalSourceSyncTime;
		String lastName = orgAccountStringWrapper.lastName;
		string revenueAmount = orgAccountStringWrapper.revenueAmount;
			return '{'+
				'	"orchestrationInfo" : {'+
				'	"jsonVersionNumber" : "1.0",'+
				'	"orchestrationDataName" : [ {'+
				'	"orchestrationNameDetail" : {'+
				'	"dataName" : "Account",'+
				'	"dataDeleteIndicator" : false,'+
				'	"dataExternalKey" : "clientId",'+
				'   "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            	'   "dataExternalKeyValue":"'+clientId+'",'+
				'	"orchestrationDataValues" : {'+
				'	"BillingAddressType" : "USAddress",'+
				'	"preferences" : [ {'+
				'	"customerId" : "'+clientId+'",'+
				'	"preferenceType" : "preferredSpokenLanguage",'+
				'	"preferenceValue" : "",'+
				'	"preferenceStartDate" : null,'+
				'	"preferenceEndDate" : null,'+
				'	"termsAndConditionVersion" : null,'+
				'	"termsAndConditionType" : null,'+
				'	"sourceId" : null,'+
				'	"sourceType" : null,'+
				'	"audit" : null'+
				'	}, {'+
				'	"customerId" : "'+clientId+'",'+
				'	"preferenceType" : "doNotShareIndicator",'+
				'	"preferenceValue" : "Y",'+
				'	"preferenceStartDate" : null,'+
				'	"preferenceEndDate" : null,'+
				'	"termsAndConditionVersion" : null,'+
				'	"termsAndConditionType" : null,'+
				'	"sourceId" : null,'+
				'	"sourceType" : null,'+
				'	"audit" : null'+
				'	}, {'+
				'	"customerId" : "'+clientId+'",'+
				'	"preferenceType" : "isSubjectToCASL",'+
				'	"preferenceValue" : "N",'+
				'	"preferenceStartDate" : null,'+
				'	"preferenceEndDate" : null,'+
				'	"termsAndConditionVersion" : null,'+
				'	"termsAndConditionType" : null,'+
				'	"sourceId" : null,'+
				'	"sourceType" : null,'+
				'	"audit" : null'+
				'	}, {'+
				'	"customerId" : "'+clientId+'",'+
				'	"preferenceType" : "paperlessPrivacyNoticeIndicator",'+
				'	"preferenceValue" : "N",'+
				'	"preferenceStartDate" : null,'+
				'	"preferenceEndDate" : null,'+
				'	"termsAndConditionVersion" : null,'+
				'	"termsAndConditionType" : null,'+
				'	"sourceId" : null,'+
				'	"sourceType" : null,'+
				'	"audit" : null'+
				'	}, {'+
				'	"customerId" : "'+clientId+'",'+
				'	"preferenceType" : "providedPrivacyOptions",'+
				'	"preferenceValue" : "N",'+
				'	"preferenceStartDate" : null,'+
				'	"preferenceEndDate" : null,'+
				'	"termsAndConditionVersion" : null,'+
				'	"termsAndConditionType" : null,'+
				'	"sourceId" : null,'+
				'	"sourceType" : null,'+
				'	"audit" : null'+
				'	}, {'+
				'	"customerId" : "'+clientId+'",'+
				'	"preferenceType" : "isProtectedPerson",'+
				'	"preferenceValue" : "N",'+
				'	"preferenceStartDate" : null,'+
				'	"preferenceEndDate" : null,'+
				'	"termsAndConditionVersion" : null,'+
				'	"termsAndConditionType" : null,'+
				'	"sourceId" : null,'+
				'	"sourceType" : null,'+
				'	"audit" : null'+
				'	}, {'+
					'"customerId" : "'+clientId+'",'+
					'"preferenceType" : "isHealthSource",'+
					'"preferenceValue" : "N",'+
					'"preferenceStartDate" : null,'+
					'"preferenceEndDate" : null,'+
				'	"termsAndConditionVersion" : null,'+
					'"termsAndConditionType" : null,'+
					'"sourceId" : null,'+
				'	"sourceType" : null,'+
					'"audit" : null'+
					'}, {'+
					'"customerId" : "'+clientId+'",'+
					'"preferenceType" : "doNotCallIndicator",'+
					'"preferenceValue" : "N",'+
					'"preferenceStartDate" : null,'+
					'"preferenceEndDate" : null,'+
					'"termsAndConditionVersion" : null,'+
					'"termsAndConditionType" : null,'+
					'"sourceId" : null,'+
					'"sourceType" : null,'+
					'"audit" : null'+
					'}, {'+
					'"customerId" : "'+clientId+'",'+
					'"preferenceType" : "doNotMailIndicator",'+
					'"preferenceValue" : "N",'+
					'"preferenceStartDate" : null,'+
					'"preferenceEndDate" : null,'+
					'"termsAndConditionVersion" : null,'+
					'"termsAndConditionType" : null,'+
					'"sourceId" : null,'+
					'"sourceType" : null,'+
					'"audit" : null'+
					'} ],'+
					'"BillingCity" : "AURORA",'+
					'"HasConfirmedNoEmail" : true,'+
					'"Citizenship" : "UnKnown",'+
					'"ShippingAddressType" : "",'+
					'"organizationType" : null,'+
					'"BillingCountry" : "UNITED STATES",'+
					'"BillingStreet" : "3105 SOLITUDE LN",'+
					'"TIN" : "",'+
					'"RecordTypeId" : "Organization",'+
					'"BillingPostalCode" : "60502",'+
					'"MailingAttention" : "",'+
					'"LastName" : "'+lastName+'",'+
					'"BillingState" : "IL",'+
					'"Industry" : "Other",'+
					'"revenueAmount" : '+revenueAmount+
					'}'+
					'}'+
					'}, {'+
					'"orchestrationNameDetail" : {'+
					'"dataName" : "Agent Role",'+
					'"dataDeleteIndicator" : false,'+
					'"dataExternalKey" : "AgentRoleIdentifier",'+
					'"externalSourceSyncTime" : "2018-08-03T11:59:27.573+0000",'+
					'"dataExternalKeyValue" : "GZL871YS000~'+clientId+'",'+
					'"orchestrationDataValues" : {'+
					'"StartDate" : "2018-08-02",'+
					'"Agent" : "GZL871YS000",'+
					'"RelationshipNature" : "Prospect",'+
					'"Customer" : "'+clientId+'",'+
					'"HouseholdGroupId" : "GSHGZ8YWRXB"'+
					'}'+
					'}'+
					'} ],'+
					'"orchestrationEventName" : {'+
					'"orchestrationEventType" : "Customer Sync",'+
					'"orchestrationEventDetail" : null'+
					'}'+
					'}'+
					'}';

 				}

    /**
     * @description json for org account string wrapper list
     */
    public class JsonForOrgAccountStringWrapperList{
        public String clientId;
        public String externalSourceSyncTime;
        public String lastName;
		public String revenueAmount;
    }

    /**
     * @description method is for build json string
     * @param buildJsonWrapper
     * @return  `String`
     */
    public static String buildJsonString(JsonStringWrapperList buildJsonWrapper) {
		String clientId = buildJsonWrapper.clientId;
		String externalSourceSyncTime = buildJsonWrapper.externalSourceSyncTime;
		String lastName = buildJsonWrapper.lastName;
		string assocId = buildJsonWrapper.assocId;
        return
            '{'+
            '   "orchestrationInfo":{'+
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+clientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":"Valid",'+
            '                  "Phone":0,'+
            '                  "PersonMobilePhone":2259070877,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsHearingImpaired" :true,'+
            '                  "ShippingState":"",'+
            '                  "deathdate":"",'+
            '                  "LastName":"'+lastName+'",'+
            '                  "BillingState":"LA",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"70769",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"BOBBY ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":"3215 ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"36339 LORENA DR ",'+
            '                  "PersonBirthdate":"1971-10-14",'+
            '                  "DriversLicenseStateProvince":"LOUISIANA ",'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":" ",'+
            '                  "MailingInCareOf":"",'+
            '                  "PersonHomePhone":2256738477,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"PRAIRIEVILLE ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+assocId+'~'+clientId+'",'+
            '               "orchestrationDataValues":{'+
            '               "Customer":"'+clientId+'",'+
            '               "RelationshipNature":"Customer",'+
            '               "StartDate":"2008-08-01",'+
            '               "Agent":"'+assocId+'",'+
            '               "HouseholdGroupId":"HouseholdA1"'+
            '               }'+
            '            }'+
            '         }'+
            '      ],'+
            '      "orchestrationEventName":{'+
            '         "orchestrationEventType":"Customer Sync",'+
            '         "orchestrationEventDetail":'+null+
            '      }'+
            '   }'+
            '}';
    }

    /**
     * @description json string wrapper list
     */
    public class JsonStringWrapperList{
        public String clientId;
        public String externalSourceSyncTime;
        public String lastName;
		public string assocId;
    }

    /**
     * @description method is for build invalid json string
     * @param clientId
     * @param externalSourceSyncTime
     * @return  `String`
     */
    public static String buildInvalidJsonString(String clientId,String externalSourceSyncTime) {
        return
            '{'+
            '   "orchestrationInfo":{'+
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+clientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":"Valid",'+
            '                  "Phone":0,'+
            '                  "PersonMobilePhone":2259070877,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsHearingImpaired" :true,'+
            '                  "ShippingState":"",'+
            '                  "deathdate":"",'+
            '                  "LastName":"SMITH ",'+
            '                  "BillingState":"LA",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"70769",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"BOBBY ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":"3215 ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"36339 LORENA DR ",'+
            '                  "PersonBirthdate":"1971-10-14",'+
            '                  "DriversLicenseStateProvince":"LOUISIANA ",'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":" ",'+
            '                  "MailingInCareOf":"",'+
            '                  "PersonHomePhone":2256738477,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"PRAIRIEVILLE ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"XXXXXXXXXXX~11111111111",'+
            '               "orchestrationDataValues":{'+
            '               "Customer":"'+clientId+'",'+
            '               "RelationshipNature":"Customer",'+
            '               "StartDate":"2008-08-01",'+
            '               "Agent":"XXXXXXXXXXX",,'+
            '               "HouseholdGroupId":"HouseholdA1"'+
            '               }'+
            '            }'+
            '         }'+
            '      ],'+
            '      "orchestrationEventName":{'+
            '         "orchestrationEventType":"Customer Sync",'+
            '         "orchestrationEventDetail":'+null+
            '      }'+
            '   }'+
            '}';
    }

    /**
     * @description method is for build json account only string
     * @param clientId
     * @param externalSourceSyncTime
     * @param lastName
     * @return  `String`
     */
	public static String buildJsonAccountOnlyString(String clientId,String externalSourceSyncTime,String lastName) {
        return
            '{'+
            '   "orchestrationInfo":{'+
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+clientId+'",'+
            '               "orchestrationDataValues":{'+
			'          		"preferences" : [ {'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "doNotMailIndicator",'+
            '            	"preferenceValue" : "Y",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "isHealthSource",'+
            '            	"preferenceValue" : "N",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "doNotShareIndicator",'+
            '            	"preferenceValue" : "Y",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "providedPrivacyOptions",'+
            '            	"preferenceValue" : "N",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "isProtectedPerson",'+
            '            	"preferenceValue" : "Y",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "paperlessPrivacyNoticeIndicator",'+
            '            	"preferenceValue" : "Y",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "preferredSpokenLanguage",'+
            '            	"preferenceValue" : "English",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "isSubjectToCASL",'+
            '            	"preferenceValue" : "Y",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "serviceEmail",'+
            '            	"preferenceValue" : "Y",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "serviceText",'+
            '            	"preferenceValue" : "N",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "marketingEmail",'+
            '            	"preferenceValue" : "P",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "claimAlertEmail",'+
            '            	"preferenceValue" : "P",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "claimAlertText",'+
            '            	"preferenceValue" : "Y",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
            '          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "donotcallIndicator",'+
            '            	"preferenceValue" : "Y",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
			'          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "billingPaperless",'+
            '            	"preferenceValue" : "Y",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
			'          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "accountPolicyNotification",'+
            '            	"preferenceValue" : "Y",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
			'          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "billAlertEmail",'+
            '            	"preferenceValue" : "P",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
			'          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "policyPaperless",'+
            '            	"preferenceValue" : "P",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
			'          		}],'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":"Valid",'+
            '                  "Phone":0,'+
            '                  "PersonMobilePhone":2259070877,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsHearingImpaired" :true,'+
            '                  "ShippingState":"",'+
            '                  "deathdate":"",'+
            '                  "LastName":"'+lastName+'",'+
            '                  "BillingState":"LA",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"70769",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"BOBBY ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":"3215 ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"36339 LORENA DR ",'+
            '                  "PersonBirthdate":"1971-10-14",'+
            '                  "DriversLicenseStateProvince":"LOUISIANA ",'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":" ",'+
            '                  "MailingInCareOf":"",'+
            '                  "PersonHomePhone":2256738477,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"PRAIRIEVILLE ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
            '                  "Designation":" ",'+
            '				   "BusinessOwnerIndicator":true'+
            '               }'+
            '            }'+
            '         }'+
            '      ],'+
            '      "orchestrationEventName":{'+
            '         "orchestrationEventType":"Customer Sync",'+
            '         "orchestrationEventDetail":'+null+
            '      }'+
            '   }'+
            '}';
    }

}