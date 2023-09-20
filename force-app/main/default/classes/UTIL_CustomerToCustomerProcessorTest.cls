/**
* @Name: UTIL_CustomerToCustomerProcessorTest
* @Author: Loco Motivated
* @Description: This class contains unit tests for CustomerToCustomerProcessor
*
*/
/**
 * @description This class contains unit tests for CustomerToCustomerProcessor
 */
@isTest(seeAllData=false)
public class UTIL_CustomerToCustomerProcessorTest {

    private static User systemUser;
    private static User testAPIUser;
    private static final String CLIENT_IDENTIFIER='IAMCLIENT12';
    private static final String CLIENT_IDENTIFIER1='IAMCLIENT15';
    private static final String AGENT1_ASSOCID='IAMASSCID1A';
    private static Account accrecord;
    private static Account accrecord1;
    private static List<Account> accrecordlst= new List<Account>();
    private static PermissionSetAssignment psassignment;
    private static CS_StageOrchestration_Counts__c counts;
    private static CS001_ByPassTriggerAtoF__c accountbypass;
    private static List<User> agentUserList = new List<User>();
    private static final Datetime DATE_VALUE=Datetime.now();

    /**
     * @description test method is used to store the records of accounts
     */
    public static void setup() {
        systemUser = UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');
        testAPIUser = UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','test@statefarm.com');
        insert systemUser;
        insert testAPIUser;
        psassignment=UTIL_StageOrchestrationTestUtils.assignPSet(testAPIUser);
        insert psassignment;

        counts= new CS_StageOrchestration_Counts__c(Retry_Count__c=3,Chunk_Size__c=5);

        accountbypass=new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=true,Override_AccountBeforeUpdate__c=true,Override_AgentRoleAfterInsert__c=true);

        accrecord = new Account(FirstName='Ftest1',LastName='Ltest1',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER);
        accrecord1 = new Account(FirstName='Ftest2',LastName='Ltest2',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER1);
        accrecordlst.add(accrecord);
        accrecordlst.add(accrecord1);
    }

    @isTest
    static void testRelationshipCreationScenario(){
        StageOrchestration__c testRecord;
        setup();
        system.runAs(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert counts;
            insert accountbypass;
            insert accrecordlst;
            testRecord=new StageOrchestration__c();
            testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
            testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.RELATIONSHIP_TRANSACTION;
            testRecord.VersionNumber__c=1.0;
            //testRecord.Value__c=buildJsonRelatioshipString('false',DATE_VALUE.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'),CLIENT_IDENTIFIER,CLIENT_IDENTIFIER1,'Father');
            JsonRelatioshipStringWrapperList relationshipCreationWrap = new JsonRelatioshipStringWrapperList();
				relationshipCreationWrap.delIndicator = 'false';
				relationshipCreationWrap.externalSourceSyncTime = DATE_VALUE.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
				relationshipCreationWrap.clientId1 = CLIENT_IDENTIFIER;
				relationshipCreationWrap.clientId2 = CLIENT_IDENTIFIER1;
				relationshipCreationWrap.nature = 'Father';
			testRecord.Value__c = buildJsonRelatioshipString(relationshipCreationWrap);
        }
        System.runAs(testAPIUser){
            Test.startTest();
            insert testRecord;
            Test.stopTest();
        }
        Account acc=[select id from Account where id=:accrecord.Id];
        Relationship__c testRelationship=[select ExternalSourceSyncTime__c,accounttwo__c,accountOne__c,RelationshipType__c
                               from Relationship__c where accountTwo__c=:acc.Id];

        system.assertEquals(DATE_VALUE, testRelationship.ExternalSourceSyncTime__c, 'Expected DateTime is not equals to the actual DateTime');
        system.assertEquals('Father', testRelationship.RelationshipType__c, 'Relationship type is not Father');
        system.assertEquals(accrecord.id, testRelationship.AccountTwo__c, 'Expected Account id is not equals to the actual Account id');
       	system.assertEquals(accrecord1.id, testRelationship.AccountOne__c, 'Expected Account id is not equals to the actual Account id');
    }

    @isTest
    static void testRelationshipUpdateScenario(){
        StageOrchestration__c testRecord;
        Relationship__c testRelationship;
        setup();
        system.runAs(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert counts;
            insert accountbypass;
            insert accrecordlst;
            testRelationship=new Relationship__c(accountone__r=new account(clientIdentifier__c=CLIENT_IDENTIFIER),
                                                 ExternalSourceSyncTime__c=Datetime.now()-1,
                                                 RelationshipIdentifier__c=CLIENT_IDENTIFIER1+'~'+CLIENT_IDENTIFIER,
                                                 accounttwo__r=new account(clientIdentifier__c=CLIENT_IDENTIFIER1),
                                                 RelationshipType__c='Son');
            insert testRelationship;
            testRecord=new StageOrchestration__c();
            testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
            testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.RELATIONSHIP_TRANSACTION;
            testRecord.VersionNumber__c=1.0;
            //testRecord.Value__c=buildJsonRelatioshipString('false',DATE_VALUE.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'),CLIENT_IDENTIFIER1,CLIENT_IDENTIFIER,'Father');
            JsonRelatioshipStringWrapperList relationshipUpdateWrap = new JsonRelatioshipStringWrapperList();
				relationshipUpdateWrap.delIndicator = 'false';
				relationshipUpdateWrap.externalSourceSyncTime = DATE_VALUE.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
				relationshipUpdateWrap.clientId1 = CLIENT_IDENTIFIER1;
				relationshipUpdateWrap.clientId2 = CLIENT_IDENTIFIER;
				relationshipUpdateWrap.nature = 'Father';
			testRecord.Value__c = buildJsonRelatioshipString(relationshipUpdateWrap);
        }
        System.runAs(testAPIUser){
            Test.startTest();
            insert testRecord;
            Test.stopTest();
        }
        Relationship__c test1=[select ExternalSourceSyncTime__c,RelationshipIdentifier__c,accounttwo__c,
                               accountOne__c,RelationshipType__c  from Relationship__c where id=:testRelationship.Id];
        system.assertNotEquals(testRelationship.RelationshipType__c, test1.RelationshipType__c, 'Expected relationship type should not be equals to the actual relationship type');
        system.assertEquals('Father', test1.RelationshipType__c, 'Relationship type is not Father');
        system.assertEquals(accrecord1.id, test1.AccountTwo__c, 'Expected Account id is not equals to the actual Account id');
        system.assertEquals(accrecord.id, test1.AccountOne__c, 'Expected Account id is not equals to the actual Account id');
    }

    @isTest
    static void testRelationshipDeleteScenario(){
        StageOrchestration__c testRecord;
        Relationship__c testRelationship;
        setup();
        system.runAs(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert counts;
            insert accountbypass;
            insert accrecordlst;
            testRelationship=new Relationship__c(accountone__r=new account(clientIdentifier__c=CLIENT_IDENTIFIER),
                                                 ExternalSourceSyncTime__c=Datetime.now()-1,
                                                 RelationshipIdentifier__c=CLIENT_IDENTIFIER+'~'+CLIENT_IDENTIFIER1,
                                                 accounttwo__r=new account(clientIdentifier__c=CLIENT_IDENTIFIER1),RelationshipType__c='Son');
            insert testRelationship;
            testRecord=new StageOrchestration__c();
            testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
            testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.RELATIONSHIP_TRANSACTION;
            testRecord.VersionNumber__c=1.0;
            //testRecord.Value__c=buildJsonRelatioshipString('true',DATE_VALUE.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'),CLIENT_IDENTIFIER,CLIENT_IDENTIFIER1,'');
            JsonRelatioshipStringWrapperList relationshipDeleteWrap = new JsonRelatioshipStringWrapperList();
				relationshipDeleteWrap.delIndicator = 'true';
				relationshipDeleteWrap.externalSourceSyncTime = DATE_VALUE.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
				relationshipDeleteWrap.clientId1 = CLIENT_IDENTIFIER;
				relationshipDeleteWrap.clientId2 = CLIENT_IDENTIFIER1;
				relationshipDeleteWrap.nature = '';
			testRecord.Value__c = buildJsonRelatioshipString(relationshipDeleteWrap);
        }
        System.runAs(testAPIUser){
            Test.startTest();
            insert testRecord;
            Test.stopTest();
        }

        List<Relationship__c> test1=[select ExternalSourceSyncTime__c,RelationshipIdentifier__c,accounttwo__c,
                                     accountOne__c,RelationshipType__c  from Relationship__c where id=:testRelationship.Id];
        system.assert(test1.isEmpty(), 'List<Relationship__c> is not empty');
        system.assertEquals(0, test1.size(), 'Size of List<Relationship__c> is not equals to 0');
    }

    @isTest
    static void testNoRelationshipUpdateScenario(){
        StageOrchestration__c testRecord;
        Relationship__c testRelationship;
        setup();
        system.runAs(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert counts;
            insert accountbypass;
            insert accrecordlst;
            testRelationship=new Relationship__c(accountone__r=new account(clientIdentifier__c=CLIENT_IDENTIFIER),
                                                 ExternalSourceSyncTime__c=Datetime.now().addMinutes(1),
                                                 RelationshipIdentifier__c=CLIENT_IDENTIFIER+'~'+CLIENT_IDENTIFIER1,
                                                 accounttwo__r=new account(clientIdentifier__c=CLIENT_IDENTIFIER1),RelationshipType__c='Son');
            insert testRelationship;
            testRecord=new StageOrchestration__c();
            testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
            testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.RELATIONSHIP_TRANSACTION;
            testRecord.VersionNumber__c=1.0;
            //testRecord.Value__c=buildJsonRelatioshipString('false',DATE_VALUE.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'),CLIENT_IDENTIFIER1,CLIENT_IDENTIFIER,'Father');
            JsonRelatioshipStringWrapperList noRelationshipUpdateWrap = new JsonRelatioshipStringWrapperList();
				noRelationshipUpdateWrap.delIndicator = 'false';
				noRelationshipUpdateWrap.externalSourceSyncTime = DATE_VALUE.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
				noRelationshipUpdateWrap.clientId1 = CLIENT_IDENTIFIER1;
				noRelationshipUpdateWrap.clientId2 = CLIENT_IDENTIFIER;
				noRelationshipUpdateWrap.nature = 'Father';
			testRecord.Value__c = buildJsonRelatioshipString(noRelationshipUpdateWrap);
        }
        System.runAs(testAPIUser){
            Test.startTest();
            insert testRecord;
            Test.stopTest();
        }
        Relationship__c test1=[select RelationshipType__c from Relationship__c where id=:testRelationship.Id];
        system.assertEquals(testRelationship.RelationshipType__c, test1.RelationshipType__c, 'Expected relationship type is not equals to the actual relationship type');
    }

    @isTest
    static void testRelationshipDMLExceptionScenario(){
        setup();
        system.runAs(systemUser){
            insert counts;
            insert accountbypass;
        }
        List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
        StageOrchestration__c testRecord=new StageOrchestration__c();
        testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
        testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.RELATIONSHIP_TRANSACTION;
        testRecord.VersionNumber__c=1.0;
        //testRecord.Value__c=buildJsonRelatioshipString('false',DATE_VALUE.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'),'CLIENT_IDENTIFIER',CLIENT_IDENTIFIER1,'Father');
        JsonRelatioshipStringWrapperList relationshipDMLExceptionWrap = new JsonRelatioshipStringWrapperList();
			relationshipDMLExceptionWrap.delIndicator = 'false';
			relationshipDMLExceptionWrap.externalSourceSyncTime = DATE_VALUE.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			relationshipDMLExceptionWrap.clientId1 = 'CLIENT_IDENTIFIER';
			relationshipDMLExceptionWrap.clientId2 = CLIENT_IDENTIFIER1;
			relationshipDMLExceptionWrap.nature = 'Father';
		testRecord.Value__c = buildJsonRelatioshipString(relationshipDMLExceptionWrap);
        stgOrchList.add(testRecord);
        System.runAs(testAPIUser){
            Test.startTest();
            try{
                new UTIL_CustomerToCustomerProcessor().execute(stgOrchList);
            }
            catch(StageProcessorException ex){
                System.assert(ex.getCause() instanceof DmlException, 'Cause of exception is not an instance of DmlException');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testRelationshipUpdationForNullExSynctimeBoth(){
        StageOrchestration__c testRecord;
        setup();
        Relationship__c testRelationship;
        system.runAs(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert counts;
            insert accountbypass;
            insert accrecordlst;
            testRelationship=new Relationship__c(accountone__r=new account(clientIdentifier__c=CLIENT_IDENTIFIER),
                                                 ExternalSourceSyncTime__c=null,
                                                 RelationshipIdentifier__c=CLIENT_IDENTIFIER+'~'+CLIENT_IDENTIFIER1,
                                                 accounttwo__r=new account(clientIdentifier__c=CLIENT_IDENTIFIER1),RelationshipType__c='Son');
            insert testRelationship;
            testRecord=new StageOrchestration__c();
            testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
            testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.RELATIONSHIP_TRANSACTION;
            testRecord.VersionNumber__c=1.0;
            //stRecord.Value__c=buildJsonRelatioshipString('false',null,CLIENT_IDENTIFIER,CLIENT_IDENTIFIER1,'Spouse');
            JsonRelatioshipStringWrapperList relationshipUpdationWrap = new JsonRelatioshipStringWrapperList();
				relationshipUpdationWrap.delIndicator = 'false';
				relationshipUpdationWrap.externalSourceSyncTime = null;
				relationshipUpdationWrap.clientId1 = 'CLIENT_IDENTIFIER';
				relationshipUpdationWrap.clientId2 = CLIENT_IDENTIFIER1;
				relationshipUpdationWrap.nature = 'Spouse';
			testRecord.Value__c = buildJsonRelatioshipString(relationshipUpdationWrap);
        }
        System.runAs(testAPIUser){
            Test.startTest();
            insert testRecord;
            Test.stopTest();
        }
        Relationship__c testrel=[select RelationshipType__c,RelationshipIdentifier__c from Relationship__c where id=:testRelationship.id];
        system.assertEquals(testRelationship.RelationshipType__c, testrel.RelationshipType__c, 'Expected relationship type is not equals to the actual relationship type');
        system.assertEquals(testRelationship.RelationshipIdentifier__c, testrel.RelationshipIdentifier__c, 'Expected relationship identifier is not equals to the actual relationship identifier');
    }

    @isTest
    static void testC2CProcessorNullException(){
        setup();
        System.runAs(testAPIUser) {
            Test.startTest();
            List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RELATIONSHIP_TRANSACTION;
            stgorc.VersionNumber__c=1.0;
            stgorc.Value__c=null;
            stgOrchList.add(stgorc);
            try{
                new UTIL_CustomerToCustomerProcessor().execute(stgOrchList);
            }
            catch(StageProcessorException ex){
                System.assert(ex.getCause() instanceof InvalidInputException, 'Cause of exception is not an instance of InvalidInputException');
                System.assertEquals(UTIL_StageOrchestrationConstants.EMPTY_JSON_EXCEPTION_MESSAGE, ex.getMessage(), 'Expected exception message is not equals to the actual exception message');
            }
            Test.stopTest();
        }
    }

    /**
     * @description test method used to build json relationship string
     * @param jsonRelatioshipWrapper
     * @return  `String`
     */
    public static String buildJsonRelatioshipString(JsonRelatioshipStringWrapperList jsonRelatioshipWrapper) {
		String delIndicator = jsonRelatioshipWrapper.delIndicator;
		string externalSourceSyncTime = jsonRelatioshipWrapper.externalSourceSyncTime;
		String clientId1 = jsonRelatioshipWrapper.clientId1;
		String clientId2 = jsonRelatioshipWrapper.clientId2;
		string nature = jsonRelatioshipWrapper.nature;
        return
            '{'+
            '   "orchestrationInfo":{'+
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+
            '         {'+
            '               "orchestrationNameDetail":{'+
            '               "dataName":"Customer2Customer",'+
            '               "dataDeleteIndicator":'+delIndicator+','+
            '               "dataExternalKey":"RelationshipIdentifier",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+clientId1+'~'+clientId2+'",'+
            '               "orchestrationDataValues":{'+
            '               "Customer":"'+clientId1+'",'+
            '               "relationwith":"'+clientId2+'",'+
            '               "RelationshipNature":"'+nature+'",'+
            '               "StartDate":"2008-08-01"'+
            '               }'+
            '            }'+
            '         }'+
            '      ],'+
            '         "orchestrationEventName":{'+
            '         "orchestrationEventType":"Customer2Customer",'+
            '         "orchestrationEventDetail":'+null+
            '      }'+
            '   }'+
            '}';
    }

    /**
     * @description build json relation string wrapper list
     */
    public class JsonRelatioshipStringWrapperList{
        public String delIndicator;
        public string externalSourceSyncTime;
        public String clientId1;
		public String clientId2;
		public string nature;
    }
}