/**
* @author : Team Kraken
* @name InsurancePolicyController_Test
* @description : Test class for the InsurancePolicyController
* Version : 1.0
*/
@isTest
public class InsurancePolicyController_Test extends InsurancePolicyClasses {

    private static final String POLICY_NUMBER = '1234567ABC';
    private static final String WHITE_SPACE_POLICY_NUMBER = '1234 567A BC';
    private static final String PRODUCT_DESC = '2020 BMW';
    private static final String POLICY_NAME = 'My Policy';
    private static final String RISK_NUMBER = 'abcde';
    private static final String PO_ID = '54321';
    private static final String DESCRIPTION = 'I love IPAs';
    private static final String RISK_STATUS_TEXT = 'test risk';
    private static final String VIN = '5TDBT48A04S253049';
    private static final String CLIENT_ID = 'SFFSP81L8XA';
    private static final Id MOCK_ACCOUNT_ID = '0012300000MOCKAAAA';
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();

    @testSetup
    static void setup() {
        Account account = createAccount();
        brewIPA(account);
        insertCaseExperienceCustomSetting();
        insertPLMActivationCustomSetting();
    }

    @isTest
    static void retrieveInsurancePolicyAssetsSuccessfully() {
        InsurancePolicy policy = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = :POLICY_NAME];

        Test.startTest();
        List<InsurancePolicyAsset> ipaList = InsurancePolicyController.getInsurancePolicyAssets(policy.Id);
        Test.stopTest();

        System.assert(ipaList.size() == 1,'Expected '+ipaList.size()+' to be 1');

        InsurancePolicyAsset actual = ipaList.get(0);

        System.assertEquals(RISK_NUMBER, actual.RiskNumber__c, 'RiskNumber__c was invalid');
        System.assertEquals(PO_ID, actual.PhysicalObjectId__c, 'PhysicalObjectId__c was invalid');
        System.assertEquals(DESCRIPTION, actual.Description__c, 'Description__c was invalid');
        System.assertEquals(RISK_STATUS_TEXT, actual.RiskStatusText__c, 'RiskStatusText__c was invalid');
        System.assertEquals(VIN, actual.VIN__c, 'VIN__c was invalid');
    }

    @isTest
    static void retrieveInsurancePolicyAssets() {      
        List<InsurancePolicyAsset> ipaList;
        Test.startTest();
        InsurancePolicyController.isCatch = true;
        ipaList = InsurancePolicyController.getInsurancePolicyAssets('');
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
    
    @isTest
    static void retrieveInsurancePolicyAssetsReturnsNoResults() {

        Test.startTest();
        List<InsurancePolicyAsset> ipaList = InsurancePolicyController.getInsurancePolicyAssets('abc');
        Test.stopTest();

        System.assert(ipaList.size() == 0,'Expected '+ipaList.size()+' to be 0');
    }

    @isTest
    static void retrieveInsurancePolicyParticipantPolicyNotFound() {

        Test.startTest();
        InsurancePolicyParticipant participant = InsurancePolicyController.getPrimaryInsurancePolicyParticipant('0YTP0000001bRiFAKE', 'A');
        Test.stopTest();

        System.assertEquals(null, participant, 'Expected to get null back when InsurancePolicy was not found');
    }

    @isTest
    static void retrieveInsurancePolicyParticipantParticipantNotFound() {
        InsurancePolicy policy = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = :POLICY_NAME];

        Test.startTest();
        InsurancePolicyParticipant participant = InsurancePolicyController.getPrimaryInsurancePolicyParticipant(policy.Id, 'A');
        Test.stopTest();

        System.assertEquals(null, participant, 'Expected to get null back when InsurancePolicy was not found');
    }

    @isTest
    static void retrieveInsurancePolicyParticipantPolicy() {      
        InsurancePolicyParticipant participant;
        Test.startTest();
        InsurancePolicyController.isCatch = true;
        participant = InsurancePolicyController.getPrimaryInsurancePolicyParticipant('','');
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    @isTest
    static void retrieveAccountData() {
        List<String> clientIds = new List<String>();
        clientIds.add(CLIENT_ID);

        Test.startTest();
        List<AccountWrapper> accounts = InsurancePolicyController.getAccountData(clientIds);
        Test.stopTest();

        System.assert(accounts.size() == 1, 'Expected to find only one account');
    }

    @isTest
    static void retrieveAccountDataForCatch() {
        List<AccountWrapper> accounts;
        Test.startTest();
        accounts = InsurancePolicyController.getAccountData(null);
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');

    }

    @isTest
    static void testCreatePolicyTransactionCase() {
        String actual;
        InsurancePolicyData insurancePolicyData = new InsurancePolicyData();
        insurancePolicyData.accountRecordId = '0YTP0000001bRiFAKE';
        insurancePolicyData.lob = 'Auto';
        insurancePolicyData.actionValue = 'Policy Change';
        insurancePolicyData.policyNumber = POLICY_NUMBER;
        insurancePolicyData.productDescription = PRODUCT_DESC;

        PA_CaseUtil caseUtilMock = (PA_CaseUtil) Test.createStub(PA_CaseUtil.class, new PA_CaseUtilMockProvider());

        InsurancePolicyController.caseUtil = caseUtilMock;
        
        Test.startTest();
        actual = InsurancePolicyController.createPolicyTransactionCase(insurancePolicyData);
        Test.stopTest();

        System.assertEquals('[lob = Auto lob = policyNumber = 1234567ABC reason = Policy Change productionDescription = 2020 BMW parentRecordId = null agentAssociateId = null]', actual,'Expected value is [lob = Auto lob = policyNumber = 1234567ABC reason = Policy Change productionDescription = 2020 BMW parentRecordId = null agentAssociateId = null], but actual value is '+actual);
    }

    @isTest
    static void testCreatePolicyTransactionCaseCatch() {   
        String actual;     
        Test.startTest();
        actual = InsurancePolicyController.createPolicyTransactionCase(null);
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    @isTest
    public static void testGetPrimaryInsurancePolicyParticipantLoBLife() {
        InsurancePolicy policy = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = :POLICY_NAME];

        Test.startTest();
        InsurancePolicyParticipant participant = InsurancePolicyController.getPrimaryInsurancePolicyParticipant(policy.Id, 'L');
        Test.stopTest();

        System.assert(participant != null,'Expected '+participant+' not to be null');
        System.assertEquals(CLIENT_ID, participant.PrimaryParticipantAccount.ClientIdentifier__c, 'Unexpected client identifier');
    }

    @isTest
    public static void testGetPrimaryInsurancePolicyParticipantLoBAuto() {
        InsurancePolicy policy = [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = :POLICY_NAME];

        Test.startTest();
        InsurancePolicyParticipant particpant = InsurancePolicyController.getPrimaryInsurancePolicyParticipant(policy.Id, 'A');
        Test.stopTest();

        System.assert(particpant == null,'Expected '+particpant+' to be null');
    }

    @isTest
    public static void testGroupPolicyInListFalse() {
        String componentName = 'not found name';
        
        Test.startTest();
        Boolean returnVal = InsurancePolicyController.groupPolicyInList(componentName);
        Test.stopTest();
        
        System.assertEquals(false, returnVal, 'returnVal should be false');
    }

    @isTest
    public static void testGroupPolicyInListTrue() {
        String componentName = 'fleet';
        
        Test.startTest();
        Boolean returnVal = InsurancePolicyController.groupPolicyInList(componentName);
        Test.stopTest();
        
        System.assertEquals(true, returnVal, 'returnVal should be true');
    }

    @isTest
    public static void testGetGroupPolicyStatus() {
        Boolean result;

        Test.startTest();
        result = InsurancePolicyController.getGroupPolicyStatus('this is a test');
        Test.stopTest();

        System.assertEquals(false, result,'Expected value is false, but actual value is '+result);
    }

    @isTest
    public static void testGetGroupPolicyStatusForCatch() {
        Boolean result;
        Test.startTest();
        InsurancePolicyController.isCatch = true;
        result = InsurancePolicyController.getGroupPolicyStatus('');
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    @isTest
    public static void testEncodeProductDescription() {
        String encodedProductDescription;

        Test.startTest();
        encodedProductDescription = InsurancePolicyController.encodeProductDescription('Frank & Sons @ Phoenix');
        Test.stopTest();

        System.assertEquals('Frank+%26+Sons+%40+Phoenix', encodedProductDescription, 'description not encoded correctly');
    }

    @isTest
    public static void testEncodeProductDescriptionForCatch() {
        Test.startTest();
        InsurancePolicyController.isCatch = true;
        InsurancePolicyController.encodeProductDescription('');
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    @isTest
    private static void testPLMCustomSetting() {
        Test.startTest();
        CS_PLM_Case_Config__c plmConfig = InsurancePolicyController.getPLMStatus();
        Test.stopTest();
        System.assertEquals(true, plmConfig.PLM_Auto_Launch_PC_Active__c, 'auto launch cs did not come back correctly');
        System.assertEquals(true, plmConfig.PLM_Opp_Redirect_Active__c, 'opp redirect cs did not come back correctly');
        System.assertEquals(true, plmConfig.PLM_Policy_Actions_Active__c, 'policy actions cs did not come back correctly');
    }

    @isTest
    private static void testPLMCustomSettingForCatch() {
        Test.startTest();
        InsurancePolicyController.isCatch = true;
        InsurancePolicyController.getPLMStatus();
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    @isTest
    private static void testGetPLMStatusActive() {
  		Test.startTest();
        boolean isPLMActive = InsurancePolicyController.getPLMStatusForState('01');
        Test.stopTest();
        System.assertEquals(true, isPLMActive, 'PLM was unexpectedly inactive');
    }
    
    @isTest
    private static void testGetPLMStatusInactive() {
  		Test.startTest();
        boolean isPLMActive = InsurancePolicyController.getPLMStatusForState('02');
        Test.stopTest();
        System.assertEquals(false, isPLMActive, 'PLM was unexpectedly active');
    }

    @isTest
    private static void testGetPLMStatusForStateCatch() {
  		Test.startTest();
        InsurancePolicyController.isCatch = true;
        InsurancePolicyController.getPLMStatusForState('');
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    @isTest
    private static void testGetTargetPolicyWithoutMod() {
        InsurancePolicy mockLegacyPolicy = new InsurancePolicy();
        mockLegacyPolicy.AgreSourceSysCd__c = '1';
        List<InsurancePolicy> mockPolicyList = new List<InsurancePolicy>();
        mockPolicyList.add(mockLegacyPolicy);
        InsurancePolicyController.mockPolicies = mockPolicyList;
        Test.startTest();
        boolean hasTargetPolicy = InsurancePolicyController.getTargetAutoPolicyForState('00MOCK', MOCK_ACCOUNT_ID);
        Test.stopTest();
        System.assertEquals(false, hasTargetPolicy, 'unexpectedly received a target policy');
    }

    @isTest
    private static void testGetTargetPolicyWithoutModForCatch() {
        Test.startTest();
        InsurancePolicyController.isCatch = true;
        InsurancePolicyController.getTargetAutoPolicyForState(null, null);
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    private static void createParticipants(String policyId, String accountId) {
        InsurancePolicyParticipant participant =  new InsurancePolicyParticipant(
            RoleNameCd__c = '12',
            SecondaryRoleNameCd__c = '29',
            PrimaryParticipantAccountId = accountId,
            InsurancePolicyId = policyId,
            Role = 'Insured Party'
        );

        insert participant;

        participant = new InsurancePolicyParticipant(
            RoleNameCd__c = '13',
            SecondaryRoleNameCd__c = '30',
            InsurancePolicyId = policyId,
            Role = 'Insured Party'
        );

        insert participant;
    }

    private static void brewIPA(Account account) {

        InsurancePolicy policy = new InsurancePolicy(Name = POLICY_NAME, NameInsuredId = account.Id);
        insert policy;

        CustomerProperty custProp = new CustomerProperty(PrimaryOwnerId = account.id);
        insert custProp;

        InsurancePolicyAsset ipa = new InsurancePolicyAsset(
            InsurancePolicyId = policy.Id, 
            RiskNumber__c = RISK_NUMBER, 
            Description__c = DESCRIPTION, 
            PhysicalObjectId__c = PO_ID,
            RiskStatusText__c = RISK_STATUS_TEXT, 
            VIN__c = vin);

        insert ipa;

        createParticipants(policy.Id, account.Id);
    }

    private static Account createAccount() {
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
            account = new Account(RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, firstname ='Will', lastname='Riker', ClientIdentifier__c = CLIENT_ID);
            insert account;
            account = [SELECT Id, name, lastname FROM Account WHERE lastname = 'Riker'].get(0);
        }

        return account;
    }
    
    private static void insertCaseExperienceCustomSetting() {
        CS_PLM_Case_Config__c config = new CS_PLM_Case_Config__c();
        config.PLM_Auto_Launch_PC_Active__c = true;
        config.PLM_Opp_Redirect_Active__c  = true;
        config.PLM_Policy_Actions_Active__c = true;
		insert config;
    }
    
    private static void insertPLMActivationCustomSetting() {
        CS_Case_PLM_Activation__c plmActive = new CS_Case_PLM_Activation__c();
        plmActive.Activation_Day__c = 1;
        plmActive.Activation_Month__c = 1;
        plmActive.Activation_Year__c = 2020;
        plmActive.Name = '01';
        plmActive.State_Code__c = '01';
        CS_Case_PLM_Activation__c plmInactive = new CS_Case_PLM_Activation__c();
        plmInactive.Activation_Day__c = 2;
        plmInactive.Activation_Month__c = 2;
        plmInactive.Activation_Year__c = 4020;
        plmInactive.Name = '02';
        plmInactive.State_Code__c = '02';
        List<CS_Case_PLM_Activation__c> plmConfig = new List<CS_Case_PLM_Activation__c>();
        plmConfig.add(plmActive);
        plmConfig.add(plmInactive);
        insert plmConfig;
    }
}