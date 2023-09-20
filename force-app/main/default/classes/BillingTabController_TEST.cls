/**
* Author : Team Kraken
* Date Created : 2/12/21
* @description : Serves as the test class for the BillingTabController class
*/

@isTest
(seeAllData = false)
public with sharing class BillingTabController_TEST extends BillingTabModels {
    @TestSetup
    static void setup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('1701A','systemUser','systemUserTest@statefarm.com'); 
        insert systemAdmin;

        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false, systemAdmin);
        insert passTriggerAll;

        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdmin.id);            
        insert sysAdminUserIdSetting; 

        // We will use the Accounts/InsurancePolicy capabilities of this class in order to insert Billing Accounts
        TestDataFactory_AgencyShares.createDataForSharesTesting();
    }

    private static Billing_Account__c createBillingAccount(String billingAccountNumber, String servicingAgentStateAgentCode) {
                // Mock data for creating external id, will be unique in prod, but can be fake in our tests
        String roCode = '00';

        Billing_Account__c account = new Billing_Account__c();
        account.SourceSystemIdentifier__c = billingAccountNumber + '~' + roCode;
        account.AccountNumber__c = billingAccountNumber;
        account.ServicingAgent__c = servicingAgentStateAgentCode;
        insert account;

        return [SELECT Id, SourceSystemIdentifier__c, AccountNumber__c FROM Billing_Account__c WHERE AccountNumber__c = :billingAccountNumber];
    }

    private static Billing_Policy__c createBillingPolicy(Id insurancePolicyId, Id billingAccountId) {
        // Mock data for creating external id, will be unique in prod, but can be fake in our tests
        String roCode = '00';

        Billing_Policy__c bp = new Billing_Policy__c();
        bp.InsurancePolicyId__c = insurancePolicyId;
        bp.SourceSystemIdentifier__c = billingAccountId + '~' + roCode + '~' + insurancePolicyId;
        bp.BillingAccountID__c = billingAccountId;
        bp.PolicyActive__c = true;
        bp.PolicyStatus__c = 'Active';
        insert bp;

        return [
            SELECT Id, SourceSystemIdentifier__c, InsurancePolicyId__c, BillingAccountID__c, PolicyActive__c, PolicyStatus__c, CancellationDate__c
            FROM Billing_Policy__c 
            WHERE InsurancePolicyId__c = :insurancePolicyId AND BillingAccountID__c = :billingAccountId
        ];
    }

    private static Billing_Participant__c createBillingParticipant(Id accountId, Id billingAccountId) {
                // Mock data for creating external id, will be unique in prod, but can be fake in our tests
        String roCode = '00';
        String clientId = 'ABCDEFGHIJKL';
        String billingAccountNumber = '09876654321';

        Billing_Participant__c bp = new Billing_Participant__c();
        bp.BillingAccountID__c = billingAccountId;
        bp.SourceSystemIdentifier__c = billingAccountNumber + '~' + roCode + '~' + clientId;
        bp.ParticipantAccountId__c = accountId;
        insert bp;

        return [
            SELECT Id, SourceSystemIdentifier__c, ParticipantAccountId__c, BillingAccountID__c 
            FROM Billing_Participant__c 
            WHERE ParticipantAccountId__c = :accountId AND BillingAccountID__c = :billingAccountId
        ];
    }

    @IsTest
    public static void validateLOBAccount() {
        String servicingAgentStateAgentCode = '01-9999';
        String bilingAccountNum = '1234567890';
        User agent1 = [SELECT Id, State_Agent_Code__c, Name, LastName FROM User WHERE State_Agent_Code__c = :servicingAgentStateAgentCode];

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount2();
        Account account3 = TestDataFactory_AgencyShares.getAccount4();


        InsurancePolicy ip1 = TestDataFactory_AgencyShares.insertPolicy('My Policy', account1.Id);
        ip1.PolicyDescription = '2022 Mercedes C250';
        ip1.ProdLineCd__c = 'A';
        ip1.AgreAccessKey__c = 'key-01';
        ip1.Servicing_Agent__r = agent1;
        ip1.AgreDisplayPartyName__c = 'Test Kirk';
        update ip1;

        InsurancePolicy ip2 = TestDataFactory_AgencyShares.insertPolicy('LOB Policy', account2.Id);
        ip2.PolicyDescription = '2023 Jeep';
        ip2.ProdLineCd__c = 'A';
        ip2.AgreAccessKey__c = 'key-02';
        ip2.Servicing_Agent__r = agent1;
        ip2.AgreDisplayPartyName__c = 'Test John';
        update ip2;

        InsurancePolicy ip3 = TestDataFactory_AgencyShares.insertPolicy('Life Policy', account3.Id);
        ip3.PolicyDescription = 'Life Insurance';
        ip3.ProdLineCd__c = 'L';
        ip3.AgreAccessKey__c = 'key-03';
        ip3.Servicing_Agent__r = agent1;
        ip3.AgreDisplayPartyName__c = 'Test Loda';
        update ip3;

        Billing_Account__c ba = createBillingAccount(bilingAccountNum, servicingAgentStateAgentCode);
        Billing_Policy__c bp1 = createBillingPolicy(ip1.Id, ba.Id);
        bp1.InsurancePolicyId__c = ip1.Id;
        update bp1;

        List<BillingAccountData> billingAccounts = new List<BillingAccountData>();

        Map<Id, InsurancePolicyData> insurancePolicyIdToData = new Map<Id, InsurancePolicyData>();
        insurancePolicyIdToData.put(ip1.Id, new InsurancePolicyData(ip1));
        insurancePolicyIdToData.put(ip2.Id, new InsurancePolicyData(ip2));
        insurancePolicyIdToData.put(ip3.Id, new InsurancePolicyData(ip3));


        List<Billing_Policy__c> billingPolicies = new List<Billing_Policy__c>();
        billingPolicies.add(bp1);

        Test.startTest();

        List<BillingAccountData> billingAccountList = BillingTabController.addLobAccounts(billingPolicies, insurancePolicyIdToData, billingAccounts);

        Test.stopTest();

        System.assertEquals(1, billingAccountList.size(), 'The size of the list should be 1');
        System.assertEquals(billingAccountList.get(0).insurancePolicies.get(0).productLineCode, 'A', 
            'Policy must be a F or A, but the test will check for A');
        System.assertNotEquals(billingAccountList.get(0).insurancePolicies.get(0).insurancePolicyDescription, ip1.PolicyDescription, 
            'IP in Billing Account List should not have the same IP description as in IP 1');
    }

    @IsTest
    public static void validateAccountsRetrievedFromBillingParticipant() {
        String servicingAgentStateAgentCode = '01-9999';
        String billingAccountNum = '1234567890';
        User agent1 = [SELECT Id, State_Agent_Code__c, Name, LastName, MasterUserRecord__c, isActive FROM User WHERE State_Agent_Code__c = :servicingAgentStateAgentCode];

        Account account1 = TestDataFactory_AgencyShares.getAccount1();        

        InsurancePolicy ip1 = TestDataFactory_AgencyShares.insertPolicy('My Policy', account1.Id);
        ip1.PolicyDescription = '2022 Mercedes C250';
        ip1.ProdLineCd__c = 'A';
        ip1.AgreAccessKey__c = 'key-01';
        ip1.Servicing_Agent__c = agent1.Id;
        update ip1;

        Billing_Account__c billingAccount = createBillingAccount(billingAccountNum, servicingAgentStateAgentCode);
        createBillingParticipant(account1.Id, billingAccount.Id);

        Test.startTest();

        List<BillingAccountData> billingData = BillingTabController.getBillingAccounts(new List<String> { account1.Id });
        
        Test.stopTest();

        System.assertEquals(billingData.size(), 2, 'There should be 2 Billing Account object');
        System.assertEquals(billingData[0].billingAccountNumber, billingAccount.AccountNumber__c, 'The billing accounts should match');
        System.assertEquals(agent1.LastName.split(',')[0], billingData[0].agentData.servicingAgentName, 'Expected Agent name does not match');
        System.assert(billingData[0].insurancePolicies.isEmpty(), 'Insurance Policy should not exist for this scenario');
    }

    @IsTest
    public static void validateAccountsRetrievedFromInsurancePolicy() {
        String servicingAgentStateAgentCode = '01-9999';
        String billingAccountNum = '1234567890';

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        User agent1 = [SELECT Id, State_Agent_Code__c, Name, LastName FROM User WHERE State_Agent_Code__c = :servicingAgentStateAgentCode];

        Test.startTest();

        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('My Policy', account1.Id);


        Billing_Account__c billingAccount = createBillingAccount(billingAccountNum, servicingAgentStateAgentCode);
        createBillingPolicy(policy.Id, billingAccount.Id);

        Test.stopTest();

        List<BillingAccountData> billingData = BillingTabController.getBillingAccounts(new List<String> { account1.Id });

        System.assertEquals(2,billingData.size(), 'There should be 2 Billing Account object');
        System.assertEquals(billingData[0].billingAccountNumber, billingAccount.AccountNumber__c, 'The billing accounts should match');
        System.assertEquals(agent1.LastName.split(',')[0], billingData[0].agentData.servicingAgentName, 'Expected Agent name does not match');
        System.assertEquals(policy.Name, billingData[0].insurancePolicies[0].insurancePolicyNumber, 'Insurance Policy should have been retrieved');
    }


    @IsTest
    public static void validateAccountsRetrievedFromInsurancePolicyParticipant() {
        String servicingAgentStateAgentCode = '01-9999';
        String billingAccountNum = '1234567890';

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount2();
        User agent1 = [SELECT Id, State_Agent_Code__c, Name, LastName FROM User WHERE State_Agent_Code__c = :servicingAgentStateAgentCode];

        Test.startTest();

        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('My Policy', account1.Id);
        TestDataFactory_AgencyShares.insertParticipant(account2.Id, policy.Id);

        Billing_Account__c billingAccount = createBillingAccount(billingAccountNum, servicingAgentStateAgentCode);
        createBillingParticipant(account1.Id, billingAccount.Id);
        createBillingPolicy(policy.Id, billingAccount.Id);

        Test.stopTest();

        List<BillingAccountData> billingData = BillingTabController.getBillingAccounts(new List<String> { account2.Id });

        System.assertEquals(billingData.size(), 2, 'There should be 2 Billing Account objects');
        System.assertEquals(billingData[0].billingAccountNumber, billingAccount.AccountNumber__c, 'The billing accounts should match');
        System.assertEquals(agent1.LastName.split(',')[0], billingData[0].agentData.servicingAgentName, 'Expected Agent name does not match');
        System.assertEquals(policy.Name, billingData[0].insurancePolicies[0].insurancePolicyNumber, 'Insurance Policy should have been retrieved');
    }

    @IsTest
    public static void validateAccountsRetrievedFromBothInsuranceAndBillingPrticipant() {
        String servicingAgentStateAgentCode1 = '01-9999';
        String servicingAgentStateAgentCode2 = '02-9999'; 
        String billingAccountNum1 = '1234567890';
        String billingAccountNum2 = '2222222222';

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        User agent1 = [SELECT Id, State_Agent_Code__c, Name, LastName FROM User WHERE State_Agent_Code__c = :servicingAgentStateAgentCode1];
        User agent2 = [SELECT Id, State_Agent_Code__c, Name, LastName FROM User WHERE State_Agent_Code__c = :servicingAgentStateAgentCode2];

        Test.startTest();

        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('My Policy', account1.Id);
        TestDataFactory_AgencyShares.insertParticipant(account1.Id, policy.Id);

        Billing_Account__c billingAccount1 = createBillingAccount(billingAccountNum1, servicingAgentStateAgentCode1);
        createBillingPolicy(policy.Id, billingAccount1.Id);

        Billing_Account__c billingAccount2 = createBillingAccount(billingAccountNum2, servicingAgentStateAgentCode2);
        createBillingParticipant(account1.Id, billingAccount2.Id);

        Test.stopTest();

        List<BillingAccountData> billingData = BillingTabController.getBillingAccounts(new List<String> { account1.Id });

        System.assertEquals(billingData.size(), 3, 'There should be three billing accounts returned');

        BillingAccountData billingData1;
        BillingAccountData billingData2;

        for (BillingAccountData accountData : billingData) {
            if (accountData.billingAccountId == billingAccount1.Id) {
                billingData1 = accountData;
            } else if (accountData.billingAccountId == billingAccount2.Id) {
                billingData2 = accountData;
            }
        }

        System.assertEquals(billingData1.billingAccountNumber, billingAccount1.AccountNumber__c, 'Billing Account Data 1 billing accounts should match');
        System.assertEquals(billingData2.billingAccountNumber, billingAccount2.AccountNumber__c, 'Billing Account Data 1 billing accounts should match');
        System.assertEquals(billingData1.insurancePolicies[0].insurancePolicyNumber, policy.Name, 'Billing Account Data 1 should have an associated Insurance Policy');
        System.assert(billingData2.insurancePolicies.isEmpty(), 'Billing Account Data 2 should not have an associated Insurance Policy');
        System.assertEquals(agent1.LastName.split(',')[0], billingData1.agentData.servicingAgentName, 'Billing account data 1 expected Agent name does not match');
        System.assertEquals(agent2.LastName.split(',')[0], billingData2.agentData.servicingAgentName, 'Billing account data 1 expected Agent name does not match');
    }

    @IsTest
    public static void validateAccountsRetrievedFromParticipantNotInvolvedOnInsurancePolicy() {
        String servicingAgentStateAgentCode1 = '01-9999';
        String billingAccountNum1 = '1234567890';

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount2();
        User agent1 = [SELECT Id, State_Agent_Code__c, Name, LastName FROM User WHERE State_Agent_Code__c = :servicingAgentStateAgentCode1];

        Test.startTest();

        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('My Policy', account2.Id);

        Billing_Account__c billingAccount1 = createBillingAccount(billingAccountNum1, servicingAgentStateAgentCode1);
        createBillingPolicy(policy.Id, billingAccount1.Id);
        createBillingParticipant(account1.Id, billingAccount1.Id);

        Test.stopTest();

        List<BillingAccountData> billingData = BillingTabController.getBillingAccounts(new List<String> { account1.Id });

        System.assertEquals(2, billingData.size(), 'There should be 2 Billing Account objects');

        System.assertEquals(billingData[0].billingAccountNumber, billingAccount1.AccountNumber__c, 'Billing Account Data 1 billing accounts should match');
        System.assertEquals(billingData[0].insurancePolicies[0].insurancePolicyNumber, policy.Name, 'Billing Account Data 1 should have an associated Insurance Policy');
        System.assertEquals(agent1.LastName.split(',')[0], billingData[0].agentData.servicingAgentName, 'Billing account data 1 expected Agent name does not match');
    }

    @IsTest
    public static void validateAccountsRetrievedFromPolicyAndUninvolvedParticipant() {
        String servicingAgentStateAgentCode1 = '05-9999';

        String billingAccountNum1 = '1234567890';

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account5 = TestDataFactory_AgencyShares.getAccount5();

        Test.startTest();

        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('My Policy', account1.Id);
        InsurancePolicy policy2 = TestDataFactory_AgencyShares.insertPolicy('My Policy 2', account5.Id);

        Billing_Account__c billingAccount1 = createBillingAccount(billingAccountNum1, servicingAgentStateAgentCode1);
        createBillingPolicy(policy.Id, billingAccount1.Id);
        createBillingPolicy(policy2.Id, billingAccount1.Id);

        createBillingParticipant(account1.Id, billingAccount1.Id);

        Test.stopTest();

        List<BillingAccountData> billingData = BillingTabController.getBillingAccounts(new List<String> { account1.Id });

        System.assertEquals(2, billingData.size(), 'There should be 2 Billing Account objects');
        System.assertEquals(billingData[0].insurancePolicies.size(), 2, 'There should be 2 insurance policies');
    }

    @IsTest
    public static void validateAgentDataIsFoundForNonPrimaryStateOfMultiStateAgent() {
        String primaryStateAgentCode = '06-9999';

        String nonPrimaryStateAgentCode1 = '11-1111';
        String nonPrimaryStateAgentCode2 = '22-2222';

        String billingAccountNum1 = '1234567890';
        String billingAccountNum2 = '0000000000';

        Account account6 = TestDataFactory_AgencyShares.getAccount6();

        User agent6 = [SELECT Id, State_Agent_Code__c, Name, isActive, MasterUserRecord__c FROM User WHERE State_Agent_Code__c = :primaryStateAgentCode];

        Test.startTest();

        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('My Policy', account6.Id);
        InsurancePolicy policy2 = TestDataFactory_AgencyShares.insertPolicy('My Policy 2', account6.Id);

        Billing_Account__c billingAccount1 = createBillingAccount(billingAccountNum1, nonPrimaryStateAgentCode1);
        createBillingPolicy(policy.Id, billingAccount1.Id);

        Billing_Account__c billingAccount2 = createBillingAccount(billingAccountNum2, nonPrimaryStateAgentCode2);
        createBillingPolicy(policy2.Id, billingAccount2.Id);
        createBillingParticipant(account6.Id, billingAccount1.Id);

        Test.stopTest();

        List<BillingAccountData> billingData = BillingTabController.getBillingAccounts(new List<String> { account6.Id });

        System.assertEquals(3, billingData.size(), 'There should be 3 Billing Account objects');
        System.assertEquals(billingData[0].insurancePolicies.size(), 1, 'There should be 1 insurance policy per billing account');
        System.assertEquals(billingData[1].insurancePolicies.size(), 1, 'There should be 1 insurance policy per billing account');
        System.assertEquals('FRED', billingData[0].agentData.servicingAgentName, 'The agent data should not return null');
        System.assertNotEquals(agent6.State_Agent_Code__c, billingData[0].agentData.agentCode, 'The agent data code should not be the primary.');
        System.assertEquals('FRED', billingData[1].agentData.servicingAgentName, 'The agent data should not return null');
        System.assertNotEquals(agent6.State_Agent_Code__c, billingData[1].agentData.agentCode, 'The agent data code should not be the primary.');
    }

    @IsTest
    public static void validateBillingParticipantInformationRetrievedFromBillingAccount() {
        String servicingAgentStateAgentCode = '01-9999';
        String billingAccountNum = '1234567890';
        
        Account account1 = TestDataFactory_AgencyShares.getAccount1();

        Billing_Account__c billingAccount = createBillingAccount(billingAccountNum, servicingAgentStateAgentCode);

        Billing_Participant__c billingParticipant = createBillingParticipant(account1.Id, billingAccount.Id);
        billingParticipant.SFPolicyRoleId__c = 'PAH';
        update billingParticipant;

        Test.startTest();

        List<Billing_Participant__c> billingParticipantData = BillingTabController.getParticipantInformationFromBillingAccount( billingAccount.Id );

        Test.stopTest();

        System.assertEquals(billingParticipantData.size(), 1, 'There should be 1 Billing Participant object');
        System.assertEquals(billingParticipantData[0].SFPolicyRoleId__c, billingParticipant.SFPolicyRoleId__c, 'The role should match');

    }

    @IsTest
    public static void validateBillingPolicyRetrievedFromBillingAccount() {
        String servicingAgentStateAgentCode = '01-9999';
        String billingAccountNum = '1234567890';

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('My Policy', account1.Id);
        policy.PolicyDescription = '2009 Chevrolet Malibu 4dr';
        policy.ProdLineCd__c = 'A';
        update policy;

        Billing_Account__c billingAccount = createBillingAccount(billingAccountNum, servicingAgentStateAgentCode);
        Billing_Policy__c billingPolicy = createBillingPolicy(policy.Id, billingAccount.Id);
        billingPolicy.BillingFrequency__c = 'Monthly';
        billingPolicy.CurrentAmountDue__c = 245.12;
        billingPolicy.PolicyActive__c = false;
        update billingPolicy;

        Test.startTest();

        List<Billing_Policy__c> billingPolicyData = BillingTabController.getBillingPolicyInformationFromBillingAccount( billingAccount.Id );

        Test.stopTest();

        System.assertEquals(billingPolicyData.size(), 1, 'There should be 1 Billing Policy object');
        System.assertEquals(billingPolicyData[0].BillingFrequency__c, billingPolicy.BillingFrequency__c, 'The billing frequency should match');
        System.assertEquals(billingPolicyData[0].InsurancePolicyId__r.PolicyDescription, policy.PolicyDescription, 'The policy description should match');
        System.assertEquals(billingPolicyData[0].InsurancePolicyId__r.ProdLineCd__c, policy.ProdLineCd__c, 'The product line cd should match');
        System.assertEquals(billingPolicyData[0].InsurancePolicyId__r.Name, policy.Name, 'The policy name should match');
        System.assertEquals(billingPolicyData[0].CurrentAmountDue__c, billingPolicy.CurrentAmountDue__c, 'The current amount due should match');


    }

    @IsTest
    public static void validateBackoutPolicies() {
        String servicingAgentStateAgentCode = '01-9999';
        String billingAccountNum = '1234567890';

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        User agent1 = [SELECT Id, State_Agent_Code__c, Name, LastName FROM User WHERE State_Agent_Code__c = :servicingAgentStateAgentCode];

        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('My Policy', account1.Id);  
        Billing_Account__c billingAccount = createBillingAccount(billingAccountNum, servicingAgentStateAgentCode);

        Billing_Policy__c bp = createBillingPolicy(policy.Id, billingAccount.Id);
        bp.PolicyActive__c = false;
        bp.PolicyStatus__c = 'BACKOUT';
        update bp;

        Test.startTest();

        List<BillingAccountData> billingData = BillingTabController.getBillingAccounts(new List<String> { account1.Id });

        Test.stopTest();

        System.assertEquals(1,billingData.size(), 'There should be 1 Billing Account object');
        System.assertEquals(billingData[0].billingAccountNumber, null, 'The billing account should not return');
        System.assertEquals(policy.Name, billingData[0].insurancePolicies[0].insurancePolicyNumber, 'Insurance Policy should have been retrieved');

    }

    @IsTest
    public static void validateMultipleAccountsWithOnePolicyBackoutDisplaysCorrectly() {
        String servicingAgentStateAgentCode = '01-9999';
        String billingAccountNum1 = '1234567890';
        String billingAccountNum2 = '0987654321';

        Account account1 = TestDataFactory_AgencyShares.getAccount1();  //  Create two 
        Account account2 = TestDataFactory_AgencyShares.getAccount2();  //customer Accounts
        User agent = [SELECT Id, State_Agent_Code__c, Name, LastName FROM User WHERE State_Agent_Code__c = :servicingAgentStateAgentCode]; //Both accounts are with same agency

        InsurancePolicy policy1 = TestDataFactory_AgencyShares.insertPolicy('My Policy', account1.Id);  // Only create one insurance policy

        Billing_Account__c billingAccount1 = createBillingAccount(billingAccountNum1, servicingAgentStateAgentCode); //       Create two
        Billing_Account__c billingAccount2 = createBillingAccount(billingAccountNum2, servicingAgentStateAgentCode); // billing accounts for agency

        Billing_Policy__c bp1 = createBillingPolicy(policy1.Id, billingAccount1.Id); //        Create two billing policies
        Billing_Policy__c bp2 = createBillingPolicy(policy1.Id, billingAccount2.Id); //  to tie the policy and billing accounts together

        bp2.PolicyActive__c = false;     //     The second one should be backout 
        bp2.PolicyStatus__c = 'BACKOUT'; // to test that it does not duplicate or display

        update bp1;
        update bp2;

        Test.startTest();

        List<BillingAccountData> billingData1 = BillingTabController.getBillingAccounts(new List<String> { account1.Id });
        List<BillingAccountData> billingData2 = BillingTabController.getBillingAccounts(new List<String> { account2.Id });

        Test.stopTest();
        
        System.assertEquals(2,billingData1.size(), 'There should be 2 Billing Account object');
        System.assertEquals(billingData1[0].billingAccountNumber, billingAccount1.AccountNumber__c, 'The billing accounts should match');
        System.assertNotEquals(billingData1[1].billingAccountNumber, billingAccount1.AccountNumber__c, 'The backout policy should not duplicate');
        System.assertEquals(agent.LastName.split(',')[0], billingData1[0].agentData.servicingAgentName, 'Expected Agent name does not match');
        System.assertEquals(policy1.Name, billingData1[0].insurancePolicies[0].insurancePolicyNumber, 'Insurance Policy should have been retrieved');

        System.assertEquals(1,billingData2.size(), 'There should be 1 Billing Account object');
        System.assertNotEquals(billingData2[0].billingAccountNumber, billingAccount2.AccountNumber__c, 'The 2nd account should not return due to backout');
        System.assertNotEquals(billingData1[0].insurancePolicies, billingData2[0].insurancePolicies, 'No Duplicate Insurance policy should return');
    }

    @IsTest
    public static void validatePayFrequencyRetrievedFromInsurancePolicy() {
        String servicingAgentStateAgentCode = '01-9999';
        String billingAccountNum1 = '1234567890';
        String billingAccountNum2 = '1234567899';

        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        InsurancePolicy policy1 = TestDataFactory_AgencyShares.insertPolicy('My Policy', account1.Id);
        policy1.PolicyDescription = '2009 Chevrolet Malibu 4dr';
        policy1.ProdLineCd__c = 'A';
        policy1.AgreAccessKey__c = 'key1';
        policy1.AgreDisplayPartyName__c = 'Test Kirk';
        
        update policy1;

        Billing_Account__c billingAccount1 = createBillingAccount(billingAccountNum1, servicingAgentStateAgentCode);
        Billing_Policy__c billingPolicy1 = createBillingPolicy(policy1.id, billingAccount1.Id);
        billingPolicy1.BillingFrequency__c = 'Monthly';
        billingPolicy1.InsurancePolicyId__c = policy1.Id;

        update billingPolicy1;

        Billing_Account__c billingAccount2 = createBillingAccount(billingAccountNum2, servicingAgentStateAgentCode);
        Billing_Policy__c billingPolicy2 = createBillingPolicy(policy1.id, billingAccount2.Id);
        billingPolicy2.BillingFrequency__c = 'Yearly';
        billingPolicy2.InsurancePolicyId__c = policy1.Id;
        update billingPolicy2;

        List<Billing_Policy__c> billingPolicies = new List<Billing_Policy__c>();
        billingPolicies.add(billingPolicy1);
        billingPolicies.add(billingPolicy2);

        InsurancePolicyData ipData1 = new InsurancePolicyData(policy1);
        InsurancePolicyData ipData2 = new InsurancePolicyData(policy1);

        Map<Id, InsurancePolicyData> insurancePolicyIdToData = new Map<Id, InsurancePolicyData>();
        insurancePolicyIdToData.put(billingPolicy1.InsurancePolicyId__c, ipData1);
        insurancePolicyIdToData.put(billingPolicy2.InsurancePolicyId__c, ipData2);

        Test.startTest();

        Map<Id, Map<Id, InsurancePolicyData>> testInsurancePolicyData = billingTabController.getBillingAccountIdsFromInsurancePolicies(billingPolicies, insurancePolicyIdToData);

        Test.stopTest();
        
        System.assertEquals(testInsurancePolicyData.get(billingAccount1.Id).get(billingPolicy1.InsurancePolicyId__c).billingFrequency.get(billingAccount1.Id), billingPolicy1.BillingFrequency__c, 'testIsurancePolicyData: ' + testInsurancePolicyData);
        System.assertEquals(testInsurancePolicyData.get(billingAccount2.Id).get(billingPolicy2.InsurancePolicyId__c).billingFrequency.get(billingAccount2.Id), billingPolicy2.BillingFrequency__c,'Assertion failed. Given two parameters must be equal');
        System.assertNotEquals(testInsurancePolicyData.get(billingAccount1.Id).get(billingPolicy1.InsurancePolicyId__c).billingFrequency.get(billingAccount1.Id), billingPolicy2.BillingFrequency__c,'Assertion failed. Given two parameters must not be equal'); 


    }
    
    @IsTest
    public static void validateAgentInformationRetrievedFromBillingAccount() {
        String servicingAgentStateAgentCode = '01-9999';
        String billingAccountNum = '1234567890';
        Billing_Account__c billingAccount = createBillingAccount(billingAccountNum, servicingAgentStateAgentCode);

        Test.startTest();

        AgentData agentData = BillingTabController.getServicingAgent(billingAccount.Id);

        Test.stopTest();


         System.assertEquals(agentData.stateAgentCode, '01-9999', 'The state agent code should not return null');

    }

    @IsTest
    public static void validateBillingDataRetrievedFromBillingAccount() {
        String servicingAgentStateAgentCode = '01-9999';
        String billingAccountNum = '1234567890';

        Billing_Account__c billingAccount = createBillingAccount(billingAccountNum, servicingAgentStateAgentCode);
        billingAccount.CalculatedCurrentAmountDue__c = Decimal.valueOf('245.12');
        update billingAccount;

        Test.startTest();

        Billing_Account__c billingAccountData = BillingTabController.getBillingData( billingAccount.Id );

        Test.stopTest();

        System.assertEquals(billingAccountData.CalculatedCurrentAmountDue__c, billingAccount.CalculatedCurrentAmountDue__c, 'The amount due should match');
        System.assertEquals(billingAccountData.AccountNumber__c, billingAccount.AccountNumber__c, 'The account number should match');
    }

    @IsTest
    public static void validateIsValidBillingAccountId() {
        String invalidBillingAccountId = '12345ABCD';

        Test.startTest();

        BillingTabController.isValidBillingAccountId('validateisValidBillingAccountId', invalidBillingAccountId);

        Test.stopTest();

        List<ExceptionLog__c> expectedLogs = [
            SELECT Class__c, Method__c, Exception_Message__c 
            FROM ExceptionLog__c
        ];

        String expectedExceptionMessage = 'billingAccountId failed Salesforce ID validation';

        System.assertEquals(1, expectedLogs.size(), 'One exception log record should be found');
        System.assertEquals(expectedLogs[0].Exception_Message__c, expectedExceptionMessage, 'Exception message should match.');
    }

    @IsTest
    public static void forceErrorOnGetBillingAccount() {
        Boolean exceptionOccurred = false;
        Test.startTest();
        try{
            BillingTabController.getBillingAccounts(null);
        }catch (Exception e){
            exceptionOccurred = true;
        }   
        Test.stopTest();     

        System.assert(exceptionOccurred, 'Exception was thrown correctly');
    }

    @IsTest
    public static void forceErrorOnAddLOBAccounts() {
        Boolean exceptionOccurred = false;
        Test.startTest();
        try{
            BillingTabController.addLobAccounts(null, null, null);
        }catch (Exception e){
            exceptionOccurred = true;
        }   
        Test.stopTest();     

        System.assert(exceptionOccurred, 'Exception was thrown correctly');
    }

    @IsTest
    public static void forceErrorOnIsValidBillingAccount() {
        Boolean exceptionOccurred = false;
        Test.startTest();
        try{
            BillingTabController.getParticipantInformationFromBillingAccount( null );
        }catch (Exception e){
            exceptionOccurred = true;
        }   
        Test.stopTest();     

        System.assert(exceptionOccurred, 'Exception was thrown correctly');
    }      
}
