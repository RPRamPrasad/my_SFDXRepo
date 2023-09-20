/**
* @author : ACCSE Claims Team
* @name ClaimAdaFTSelectPolicyControllerTest
* @description : Test class for the ClaimAdaFTSelectPolicyController
*/
@isTest
(seeAllData = false)
private class ClaimAdaFTSelectPolicyControllerTest {
    // Auto Policy
    private static final String AUTO_PRODUCT_DESC = '2020 BMW';
    private static final String AUTO_POLICY_NAME = '1234567ABC';
    private static final Date AUTO_EFFECTIVE_DATE = Date.newInstance(2020,2,2);
    private static final Date AUTO_CANCELLATION_DATE = Date.newInstance(2020, 3,3);
    private static final String LOB_AUTO = 'A';
    private static final String POLICY_TYPE_AUTO = 'Auto';
    private static final String STATUS_TERMINATED = 'Terminated';
    
    // Auto Asset
    private static final String AUTO_RISK_NUMBER = 'abcde';
    private static final String AUTO_PO_ID = '54321';
    private static final String VIN = '5TDBT48A04S253049';
    
    // Fire Policy
    private static final String FIRE_PRODUCT_DESC = '123 ABC St.';
    private static final String FIRE_POLICY_NAME = '1234567CDE';
    private static final Date FIRE_EFFECTIVE_DATE = Date.newInstance(2020,2,2);
    private static final String LOB_FIRE = 'F';
    private static final String POLICY_TYPE_FIRE = 'Fire';
    private static final String STATUS_IN_FORCE = 'In Force';
    
    // Fire Asset
    private static final String FIRE_RISK_NUMBER = 'edcba';
    private static final String FIRE_PO_ID = '12345';
    
    // Asset
    private static final String RISK_DESCRIPTION = 'risk description';
    private static final String RISK_STATUS_TEXT = 'test risk';
    private static final String CITY = 'City name';
    private static final String STATE = 'AZ';
    private static final String STREET = 'ABC Street';
    private static final String POSTALCODE = '85281';
    
    private static final String CLIENT_ID = 'SFFSP81L8XA';

    private static final String FIELDVALUE = '678-78-9345';
    private static final String FIELDNAME = 'Loss Description';
    
    //tpar callout mock variables
    private static String jsonInput = '{}';
    private static String fakeResponseJSON = '{}';
    
    
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();

    @testSetup static void setup() {
        createAccount();
        createPoliciesAndAssets();
    }

    @isTest
    static void getPoliciesAndParticipantsTest(){
        User testAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='accAgent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test_123test',Servicing_Agent_Associate_ID__c='123test');
        Id accountId = [SELECT Id FROM Account WHERE lastname = 'Last'].get(0).Id;
        Map<String, ClaimAdaFTSelectPolicyController.InsurancePolicyAndParticipants> policyAndParticipants = null;
        Test.startTest();
        policyAndParticipants = ClaimAdaFTSelectPolicyController.getPoliciesAndParticipants(accountId,testAgentUser1.Servicing_Agent_Associate_ID__c);
        Test.stopTest();
        System.assertEquals(1, policyAndParticipants.size(), 'policyAndParticipants size not matched');
    }
    
    @isTest
    static void getAutoInsurancePolicyAssetsTest(){
        List<InsurancePolicyAsset> policyAssets = null;
        InsurancePolicy autoPolicy = [SELECT Id FROM InsurancePolicy WHERE ProdLineCd__c =:LOB_AUTO];
        Test.startTest();
        policyAssets = ClaimAdaFTSelectPolicyController.getInsurancePolicyAssets(autoPolicy.Id);
        Test.stopTest();
        System.assertEquals(1, policyAssets.size(), 'Auto policyAssets size not matched');
    }
    
    @isTest
    static void getFireInsurancePolicyAssetsTest(){
        List<InsurancePolicyAsset> policyAssets = null;
        InsurancePolicy firePolicy = [SELECT Id FROM InsurancePolicy WHERE ProdLineCd__c =:LOB_FIRE];
        Test.startTest();
        policyAssets = ClaimAdaFTSelectPolicyController.getInsurancePolicyAssets(firePolicy.Id);
        Test.stopTest();
        System.assertEquals(1, policyAssets.size(), 'Fire policyAssets size not matched');
    }

    @isTest
    static void handleSpiTest(){
        String errorMsg = '';
        User sysAdminUser = TestDataFactory_User.getSysAdminUser();
        System.runAs(sysAdminUser){
        	UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        	List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        	System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        	UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForCase(); 
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            errorMsg = ClaimAdaFTSelectPolicyController.handleSpi(FIELDVALUE,FIELDNAME);
            System.assertEquals('Sensitive Personal Information (SPI) is not allowed to be entered in the Loss Description field.', errorMsg,'Expected value is Sensitive Personal Information (SPI) is not allowed to be entered in the Loss Description field. but actual value is '+errorMsg);
    	}
    }
    
    private class TestException extends Exception {
    }
    
    @isTest
    static void logExceptionTest(){
        Exception ex = new TestException('ExceptionDescription');
        String exString = String.valueOf(ex);
        Test.startTest();
        ClaimAdaFTSelectPolicyController.logException(exString, 'handleDVLErrorResponse - statusCode 400 - no errorDate');
        ExceptionLog__c querylog = [
            SELECT IsHandled__c, Class__c, Method__c, Exception_Message__c
            FROM ExceptionLog__c
            ORDER BY systemmodstamp DESC
            LIMIT 1
        ];
        Test.stopTest();
        System.assertEquals('ClaimAdaFTSelectPolicyController', querylog.Class__c, 'class name did not match expected value.');
        System.assertEquals('handleDVLErrorResponse - statusCode 400 - no errorDate', querylog.Method__c, 'method name did not match expected value.');
        System.assertEquals(true, querylog.IsHandled__c, 'isHandled value did not match');
        System.assertEquals('TestException:[]: ExceptionDescription', querylog.Exception_Message__c, 'message value did not match');
    }
    
    @isTest
    static void httpReqTest(){
        jsonInput = '{searchByPhone(reqObj: "{\'inputs\' : {\'phoneNumber\': \'searchKey\', \'includeOutOfBusiness\' : \'Y\'}}") {'
                                + ' statusCode'
                                + ' transactionId'
                                + ' errors'
                                + ' message { info error warning }'
                                + ' data {'
                                + '     thirdPartyId'
                                + '     walletDetails {'
                                + '         names { lastName usage }'
                                + '         postalAddresses { address city state postalZipCode addressUsage }'
                                + '         telephones { areaCode lineNumber extensionNumber usage equipmentType }'
                                + '     }'
                                + '     partyExternalReferences { externalReferenceId externalReferenceType externalReferenceValue }'
                                + ' } } }';
        Test.setMock(HttpCalloutMock.class, new TPARCalloutMock());
        Test.startTest();
        List<String> response = ClaimAdaFTSelectPolicyController.httpReq('searchKey');
        Test.stopTest();
        System.assertEquals('200', response[0], 'call failed');
        System.assertEquals('{}', response[1], 'unexpected value in [1] list index'); 
    }
    
    private static void createParticipants(String policyId) {
        Id accountId = [SELECT Id FROM Account WHERE lastname = 'Last'].get(0).Id;
        List <InsurancePolicyParticipant> participants = new List <InsurancePolicyParticipant>();
        participants.add(new InsurancePolicyParticipant(
            RoleNameCd__c = '12',
            SecondaryRoleNameCd__c = '29',
            PrimaryParticipantAccountId = accountId,
            InsurancePolicyId = policyId,
            Role = 'Named Insured'
        ));

        participants.add(new InsurancePolicyParticipant(
            RoleNameCd__c = '13',
            SecondaryRoleNameCd__c = '30',
            InsurancePolicyId = policyId,
            Role = 'Named Insured'
        ));

        insert participants;
    }

    private static void createPoliciesAndAssets() {
        Id accountId = [SELECT Id FROM Account WHERE lastname = 'Last'].get(0).Id;
        User svcAgentUser1 = new User(Alias='alias',LastName='svcAgent',Username='svcAgent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test_123test',Servicing_Agent_Associate_ID__c='123test');
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(svcAgentUser1);
        insert agentUser;
        CustomerProperty custProp = new CustomerProperty(PrimaryOwnerId = accountId);
        insert custProp;

        InsurancePolicy autoPolicy = new InsurancePolicy(Name = AUTO_POLICY_NAME, 
                                                     NameInsuredId = accountId, 
                                                     Servicing_Agent__c = agentUser.Id,
                                                     PolicyDescription = AUTO_PRODUCT_DESC,
                                                     EffectiveDate = AUTO_EFFECTIVE_DATE,
                                                     CancellationDate = AUTO_CANCELLATION_DATE,
                                                     ProdLineCd__c = LOB_AUTO,
                                                     PolicyType = POLICY_TYPE_AUTO,
                                                     Status = STATUS_TERMINATED);
        insert autoPolicy;
        createParticipants(autoPolicy.Id);

        InsurancePolicy firePolicy = new InsurancePolicy(Name = FIRE_POLICY_NAME, 
                                                     NameInsuredId = accountId,
                                                     Servicing_Agent__c = agentUser.Id, 
                                                     PolicyDescription = FIRE_PRODUCT_DESC,
                                                     EffectiveDate = FIRE_EFFECTIVE_DATE,
                                                     ProdLineCd__c = LOB_FIRE,
                                                     PolicyType = POLICY_TYPE_FIRE,
                                                     Status = STATUS_IN_FORCE);
        insert firePolicy;
        createParticipants(firePolicy.Id);

        List<InsurancePolicyAsset> assets = new List<InsurancePolicyAsset>();
        assets.add(new InsurancePolicyAsset(
            InsurancePolicyId = autoPolicy.Id, 
            RiskNumber__c = AUTO_RISK_NUMBER, 
            Description__c = RISK_DESCRIPTION, 
            PhysicalObjectId__c = AUTO_PO_ID,
            RiskStatusText__c = RISK_STATUS_TEXT, 
            VIN__c = VIN,
        	City__c = CITY,
        	PostalCode__c = POSTALCODE,
        	State__c = STATE,
        	Street__c = STREET));

        assets.add(new InsurancePolicyAsset(
            InsurancePolicyId = firePolicy.Id, 
            RiskNumber__c = FIRE_RISK_NUMBER, 
            Description__c = RISK_DESCRIPTION, 
            PhysicalObjectId__c = FIRE_PO_ID,
            RiskStatusText__c = RISK_STATUS_TEXT,
            City__c = CITY,
        	PostalCode__c = POSTALCODE,
        	State__c = STATE,
        	Street__c = STREET));

        insert assets;
    }

    private static void createAccount() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('1701B','systemUserTest2','systemUserTest2@statefarm.com');

        insert systemAdmin;

        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,systemAdmin);
        insert passTriggerAll;

        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemAdmin);
        objectBasedByPassTrigger.Override_AccountBeforeInsert__c = false;
        insert objectBasedByPassTrigger;

        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdmin.id);
        insert sysAdminUserIdSetting;

        Account account;
        System.RunAs(systemAdmin) {
            account = new Account(RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, firstname ='First', lastname='Last', ClientIdentifier__c = CLIENT_ID);
            insert account;
        }
    }
    
    public class TPARCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            System.assertEquals('callout:CcfaClaimsExperience/tpar-api/thirdparties', req.getEndpoint(), 'Endpoint was not configured to call Shipment Order');
            System.assertEquals('POST', req.getMethod(), 'Post method was not used');
            System.assertEquals('application/graphql', req.getHeader('Content-Type'), 'Content type header was not json');
            System.assertEquals(jsonInput, req.getBody(), 'Content type header was not json');

            HttpResponse res = new HttpResponse();       
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fakeResponseJSON);
            res.setStatusCode(200);
            return res;       
        }
    }
}