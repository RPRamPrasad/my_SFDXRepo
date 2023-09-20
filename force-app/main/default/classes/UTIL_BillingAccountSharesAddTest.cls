/**
 * @description This class will be used to test the UTIL_BillingAccountSharesAdd Class
 * @Date: 10/25/21
 * @author: Stephen White YCDB, Jonathan Larkin VAASTT
 */
@isTest
(seeAllData = false)
public with sharing class UTIL_BillingAccountSharesAddTest extends UTIL_AgencyShares {
    /**
     * @description Setup Tests by generating agent data and bypassing the appropraite triggers.
     */
    @testsetup
    public static void testSetupData() {

        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        
        TestDataFactory_BillingShares.generateBillingShareTestData();
    }

    @isTest
    public static void getBillingAccountsFromPrimaryInsured() {
        List<AgentRole__c> agentRoles = TestDataFactory_BillingSharesAgentRoles.setupOneAccountTwoInsurancePoliciesAndParticipants();

        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);

        Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap = new Map<Id, Set<Id>>();

        UTIL_BillingAccountSharesAdd.getBillingAccountsFromPrimaryInsured(agentRoleData, customerAccountToBillingAccountIdsMap);

        System.assertEquals(2, customerAccountToBillingAccountIdsMap.size(), 'customerAccountToBillingAccountIdsMap should have two entries');

        List<Id> customerAccountIdsList = new List<Id>(customerAccountToBillingAccountIdsMap.keySet());
        List<Set<Id>> billingAccountIdsList = new List<Set<Id>>(customerAccountToBillingAccountIdsMap.values());

        System.assert(customerAccountIdsList.contains(TestDataFactory_BillingShares.getAccount3().Id),'Expected Customer Account Id to be in customerAccountToBillingAccountIds KeySet');
        System.assert(customerAccountIdsList.contains(TestDataFactory_BillingShares.getAccount4().Id),'Expected Customer Account Id to be in customerAccountToBillingAccountIds KeySet');

        System.assert(billingAccountIdsList.get(0).contains(TestDataFactory_BillingShares.getBillingAccount1().Id),'Billing Account Id was expected to be in the customerAccountToBillingAccountIds Values Set');
        System.assert(billingAccountIdsList.get(0).contains(TestDataFactory_BillingShares.getBillingAccount2().Id),'Billing Account Id was expected to be in the customerAccountToBillingAccountIds Values Set');

        System.assert(billingAccountIdsList.get(1).contains(TestDataFactory_BillingShares.getBillingAccount1().Id),'Billing Account Id was expected to be in the customerAccountToBillingAccountIds Values Set');
        System.assert(billingAccountIdsList.get(1).contains(TestDataFactory_BillingShares.getBillingAccount2().Id),'Billing Account Id was expected to be in the customerAccountToBillingAccountIds Values Set');

    }


    @isTest
    private static void getBillingAccountsFromBillingParticipantsSingleBillingAccount() {

        // Create Data For Test
        Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap = new Map<Id, Set<Id>>();
        List<AgentRole__c> agentRoles = new List<AgentRole__c>();
        TestDataFactory_BillingSharesAgentRoles.setupBasicAgentTest(agentRoles);
        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);

        UTIL_BillingAccountShares.getBillingAccountsFromBillingParticipants(agentRoleData.agentRolesToAccountIds.values(), customerAccountToBillingAccountIdsMap);

        System.assertEquals(1, customerAccountToBillingAccountIdsMap.size(), 'One billing account should found in the map');
    
    }

    
    @isTest
    private static void getBillingAccountsFromBillingParticipantsNoBillingAccount() {

       // Create Data For Test
        Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap = new Map<Id, Set<Id>>();
        List<AgentRole__c> agentRoles = TestDataFactory_BillingSharesAgentRoles.setupNoBillingAccounts();

        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);

        UTIL_BillingAccountShares.getBillingAccountsFromBillingParticipants(agentRoleData.agentRolesToAccountIds.values(), customerAccountToBillingAccountIdsMap);

        UTIL_BillingAccountSharesAdd.createBillingSharesFromCustomerAccountToBillingAccountIdsMap(agentRoleData, customerAccountToBillingAccountIdsMap);

        System.assertEquals(0, customerAccountToBillingAccountIdsMap.size(), 'customerAccountToBillingAccountIdsMap should be empty.');
        System.assertEquals(0, UTIL_BillingAccountSharesTest.countBillingSharesWhereRowCauseIsManual(), 'No Billing Account Shares should have been created.');
    }
    

    @isTest
    private static void getBillingAccountsFromBillingParticipantsTwoBillingAccountOneCustomer() {

        // Create Data For Test
        Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap = new Map<Id, Set<Id>>();
        List<AgentRole__c> agentRoles = TestDataFactory_BillingSharesAgentRoles.setupOneCustomerAccountTwoBillingAccounts(); 
        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);

        UTIL_BillingAccountShares.getBillingAccountsFromBillingParticipants(agentRoleData.agentRolesToAccountIds.values(), customerAccountToBillingAccountIdsMap);

        System.assertEquals(1, customerAccountToBillingAccountIdsMap.size(), 'Test should only  one customer account entry in the Map');
        System.assertEquals(2, customerAccountToBillingAccountIdsMap.get(customerAccountToBillingAccountIdsMap.keySet().iterator().next()).size(), 
            'Test should have 2 billing account entries in the accounts set');

    }

    @isTest
    public static void updateMapWithInsurancePolicyDataTest() {
        List<AgentRole__c> agentRoles = TestDataFactory_BillingSharesAgentRoles.setupOneAccountTwoInsurancePoliciesAndParticipants();

        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
        Map<Id, Set<id>> customerAccountsToPoliciesMap = new Map<Id, Set<Id>>();
        Set<Id> insurancePolicyIds = new Set<Id>();

        UTIL_BillingAccountSharesAdd.updateMapWithInsurancePolicyData(agentRoleData, customerAccountsToPoliciesMap, insurancePolicyIds);

        System.assertEquals(1, customerAccountsToPoliciesMap.size(), 'customerAccountsToPoliciesMap should have one entry');

        System.assertEquals(TestDataFactory_BillingShares.getAccount4().Id, customerAccountsToPoliciesMap.keySet().iterator().next(), 'Incorrect account Id in customerAccountsToPoliciesMap keyset.');

        System.assertEquals(2, customerAccountsToPoliciesMap.get(customerAccountsToPoliciesMap.keySet().iterator().next()).size(), 'customerAccountsToPoliciesMap should contain a set of size 2');

        System.assertEquals(2, insurancePolicyIds.size(), 'insurancePolicyIds set should be of size 2');

        List<Id> insurancePolicyIdsList= new List<Id>(insurancePolicyIds);

        System.assert(insurancePolicyIdsList.contains(TestDataFactory_BillingSharesPolicy.getInsurancePolicy1().Id), 'Policy Id should be in the insurancePolicyIdsList');

        System.assert(insurancePolicyIdsList.contains(TestDataFactory_BillingSharesPolicy.getInsurancePolicy2().Id), 'Policy Id should be in the insurancePolicyIdsList');
    }

    
    @isTest
    public static void updateMapWithInsurancePolicyParticipantDataTest() {
        List<AgentRole__c> agentRoles = TestDataFactory_BillingSharesAgentRoles.setupOneAccountTwoInsurancePoliciesAndParticipants();

        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
        Map<Id, Set<id>> customerAccountsToPoliciesMap = new Map<Id, Set<Id>>();
        Set<Id> insurancePolicyIds = new Set<Id>();

        UTIL_BillingAccountSharesAdd.updateMapWithInsurancePolicyParticipantData(agentRoleData, customerAccountsToPoliciesMap, insurancePolicyIds);

        System.assertEquals(1, customerAccountsToPoliciesMap.size(), 'customerAccountsToPoliciesMap should have one entry');

        System.assertEquals(TestDataFactory_BillingShares.getAccount3().Id, customerAccountsToPoliciesMap.keySet().iterator().next(), 'Incorrect account Id in customerAccountsToPoliciesMap keyset.');

        System.assertEquals(2, customerAccountsToPoliciesMap.get(customerAccountsToPoliciesMap.keySet().iterator().next()).size(), 'customerAccountsToPoliciesMap should contain a set of size 2');

        System.assertEquals(2, insurancePolicyIds.size(), 'insurancePolicyIds set should be of size 2');

        List<Id> insurancePolicyIdsList= new List<Id>(insurancePolicyIds);

        System.assert(insurancePolicyIdsList.contains(TestDataFactory_BillingSharesPolicy.getInsurancePolicyParticipant1().InsurancePolicyId), 'InsurancePolicyId should be in the insurancePolicyIdsList');

        System.assert(insurancePolicyIdsList.contains(TestDataFactory_BillingSharesPolicy.getInsurancePolicyParticipant2().InsurancePolicyId), 'InsurancePolicyId should be in the insurancePolicyIdsList');
    }


    @isTest
    public static void updateMapWithBillingPolicyDataTest() {
        List<AgentRole__c> agentRoles = TestDataFactory_BillingSharesAgentRoles.setupOneAccountTwoInsurancePoliciesAndParticipants();

        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);

        Map<Id, Set<id>> customerAccountsToPoliciesMap = new Map<Id, Set<id>>(); 
        Map<Id, Set<id>> policiesToBillingAccountsMap = new Map<Id, Set<Id>>();
        Set<Id> insurancePolicyIds = new Set<Id>();

        UTIL_BillingAccountSharesAdd.updateMapWithInsurancePolicyData(agentRoleData, customerAccountsToPoliciesMap, insurancePolicyIds);

        UTIL_BillingAccountSharesAdd.updateMapWithBillingPolicyData(policiesToBillingAccountsMap, insurancePolicyIds);

        System.assertEquals(1, policiesToBillingAccountsMap.size(), 'policiesToBillingAccountsMap should have one entry');

        List<Set<Id>> idSets = policiesToBillingAccountsMap.values();

        List<Id> idGroupOne = new List<Id>(idSets.get(0));

        System.assert(idGroupOne.contains(TestDataFactory_BillingShares.getBillingAccount1().Id), 'policiesToBillingAccountsMap values must contain the appropriate billing account number');

        System.assert(idGroupOne.contains(TestDataFactory_BillingShares.getBillingAccount2().Id), 'policiesToBillingAccountsMap values must contain the appropriate billing account number');
    }


    @isTest
    private static void validateInsertBillingAccountSharesHappy() {

        // Reuse Logic from a previous test, to create list of stuff we need to add
        Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap = new Map<Id, Set<Id>>();
        List<AgentRole__c> agentRoles = TestDataFactory_BillingSharesAgentRoles.setupOneCustomerAccountTwoBillingAccounts(); 
        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
        UTIL_BillingAccountShares.getBillingAccountsFromBillingParticipants(agentRoleData.agentRolesToAccountIds.values(), customerAccountToBillingAccountIdsMap);

        // Run Test
        UTIL_BillingAccountSharesAdd.createBillingSharesFromCustomerAccountToBillingAccountIdsMap(agentRoleData, customerAccountToBillingAccountIdsMap);

        // Validate Share Creation
        List<Billing_Account__Share> billingShares = UTIL_BillingAccountSharesTest.getBillingSharesWhereRowCauseIsManual();

        System.assertEquals(2, billingShares.size(), '2 Billing Shares should have been created');

        System.assertEquals(TestDataFactory_BillingShares.getAgentProxy1().Id, billingShares[0].UserOrGroupId, 'Incorrect UserOrGroupId');
        System.assertEquals(TestDataFactory_BillingShares.getAgentProxy1().Id, billingShares[1].UserOrGroupId, 'Incorrect UserOrGroupId');

        // Create Hashest of Billing Accounts used for test
        Set<Id> testBillingAccounts = new Set<Id>{TestDataFactory_BillingShares.getBillingAccount1().Id, TestDataFactory_BillingShares.getBillingAccount2().Id};

        System.assert(testBillingAccounts.contains(billingShares[0].ParentId),'testBillingAccounts did not contain the ParentId.');
        System.assert(testBillingAccounts.contains(billingShares[1].ParentId),'testBillingAccounts did not contain the ParentId.');
    }

    @isTest
    private static void validateInsertBillingAccountSharesEmptySharesSet() {

        List<Database.SaveResult> saveResultList = UTIL_BillingAccountSharesAdd.insertBillingAccountShares(null);

        System.assertEquals(0, saveResultList.size(), 'No shares should have been saved to the database.');
    }
}