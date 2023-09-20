/**
 * @description This class will be used to test the UTIL_BillingAccountShares Class
 * @Date: 10/25/21
 * @author: Stephen White YCDB, Jonathan Larkin VAASTT
 */
@isTest
(seeAllData = false)
public with sharing class UTIL_BillingAccountSharesDeleteTest extends UTIL_AgencyShares {
    private static final String MANUAL_ROW_CAUSE = 'Manual';

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
    private static void getCustomerAccountIdsForAllBillingAccounts(){

        Integer expectedNumberOfCustomerAccounts = 2;
        Integer expectedNumberOfBillingAccountKeys = 2;
       
        // Create Data utilizing code copied from another test class, should generate two shares.
        Map<Id, Set<id>> billingAccountToCustomerIdsMap = new Map<Id, Set<Id>>();
        TestDataFactory_BillingSharesAgentRoles.setupTwoCustAccountsTwoBillAccountsTwoAgent(); 

        // Create List of Billing Accounts
        Set<Id> billingAccountIdsForAllAccounts = new Set<Id>{TestDataFactory_BillingShares.getBillingAccount1().Id,TestDataFactory_BillingShares.getBillingAccount2().Id};

        // Run Test and validate results
        Set<Id> results = UTIL_BillingAccountSharesDelete.getCustomerAccountIdsForAllBillingAccounts(billingAccountIdsForAllAccounts, billingAccountToCustomerIdsMap);

        // Validate Returned
        System.assertEquals(expectedNumberOfCustomerAccounts, results.size(),'');
        System.assert(results.contains(TestDataFactory_BillingShares.getAccount1().Id),'Result set should contain customer Account 1 ID');
        System.assert(results.contains(TestDataFactory_BillingShares.getAccount2().Id),'Result set should contain customer Account 2 ID');

        // Validate Pass by reference
        System.assertEquals(expectedNumberOfBillingAccountKeys, billingAccountToCustomerIdsMap.keySet().size(),'Expected billingAccountToCustomerIdsMap keyset to be of size 2');
        System.assert(billingAccountToCustomerIdsMap.get(TestDataFactory_BillingShares.getBillingAccount1().Id).contains(TestDataFactory_BillingShares.getAccount1().Id),'Expected customer Account 1 ID to be within the Set<Id>');
        System.assert(billingAccountToCustomerIdsMap.get(TestDataFactory_BillingShares.getBillingAccount2().Id).contains(TestDataFactory_BillingShares.getAccount1().Id),'Expected customer Account 1 ID to be within the Set<Id>');
        System.assert(billingAccountToCustomerIdsMap.get(TestDataFactory_BillingShares.getBillingAccount2().Id).contains(TestDataFactory_BillingShares.getAccount2().Id),'Expected customer Account 2 ID to be within the Set<Id>');
    }


    @isTest
    private static void getAllAgentsForCustomerAccounts(){

        Integer expectedAgentsForCustomerAccount1 = 1;
        Integer expectedAgentsForCustomerAccount2 = 2;

        // Create Data utilizing code copied from another test class, should generate two shares.
        TestDataFactory_BillingSharesAgentRoles.setupTwoCustAccountsTwoBillAccountsTwoAgent(); 

        // Create List of Customer Accounts
        Set<Id> accountIds = new Set<Id>{TestDataFactory_BillingShares.getAccount1().Id,TestDataFactory_BillingShares.getAccount2().Id};

        // Run Test and validate results
        Map<Id, Set<Id>> results = UTIL_BillingAccountSharesDelete.getAllAgentsForCustomerAccounts(accountIds);

        System.assertEquals(accountIds.size(), results.keySet().size(),'');
        System.assertEquals(expectedAgentsForCustomerAccount1, results.get(TestDataFactory_BillingShares.getAccount1().Id).size(),'Incorrect number of agents associated with Customer Account');
        System.assertEquals(expectedAgentsForCustomerAccount2, results.get(TestDataFactory_BillingShares.getAccount2().Id).size(),'Incorrect number of agents associated with Customer Account');
    }

    @isTest
    private static void getBillingAccountsFromInsurancePolicy() {
        Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap = new Map<Id, Set<id>>();
        List<AgentRole__c> agentRoles = TestDataFactory_BillingSharesAgentRoles.setupOneAccountTwoInsurancePoliciesAndParticipants(); 
        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);

        UTIL_BillingAccountSharesDelete.getBillingAccountsFromInsurancePolicy(agentRoleData.agentRolesToAccountIds.values(), customerAccountToBillingAccountIdsMap);
        Account customerAccount4 = TestDataFactory_BillingShares.getAccount4();

        System.assertEquals(1, customerAccountToBillingAccountIdsMap.keySet().size(), 'Expected customerAccountToBillingAccountIdsMap keyset to be of size 1');
        System.assert(customerAccountToBillingAccountIdsMap.keySet().contains(customerAccount4.Id), 'expected customerAccount4 ID to be in the customerAccountToBillingAccountIdsMap keyset');

        Set<Id> billingAccountIdSet = customerAccountToBillingAccountIdsMap.get(customerAccount4.Id);

        System.assertEquals(2, billingAccountIdSet.size(), 'billingAccountIdSet should be of size 2');
        System.assert(billingAccountIdSet.contains(TestDataFactory_BillingShares.getBillingAccount1().Id), 'billingAccountIdSet should contain Billing Account 1 ID');
        System.assert(billingAccountIdSet.contains(TestDataFactory_BillingShares.getBillingAccount2().Id), 'billingAccountIdSet should contain Billing Account 2 ID');
    }

    @isTest 
    private static void getCustomerAccountIdsSetFromInsurancePolicy() {
        Id billingAccountId1 = TestDataFactory_BillingShares.getBillingAccount1().Id;
        Id billingAccountId2 = TestDataFactory_BillingShares.getBillingAccount2().Id;

        Set<Id> billingAccountIdsForAllAccounts = new Set<Id>{billingAccountId1, billingAccountId2};

        Set<Id> customerAccountIdsSet = UTIL_BillingAccountSharesDelete.getCustomerAccountIdsSetFromInsurancePolicy(billingAccountIdsForAllAccounts);

        Id customerAccount4Id = TestDataFactory_BillingShares.getAccount4().Id;

        System.assertEquals(1, customerAccountIdsSet.size(), 'Expected customerAccountIdsSet to be of size 1');

        System.assert(customerAccountIdsSet.contains(customerAccount4Id), 'Expected customerAccountIdsSet to contain Customer Account 4 Id');
    }

    @isTest 
    private static void updateMapThroughInsurancePolicyAssociation() {
        Billing_Account__c billingAccount1 = TestDataFactory_BillingShares.getBillingAccount1();
        Billing_Account__c billingAccount2 = TestDataFactory_BillingShares.getBillingAccount2();
        Id customerAccount4Id = TestDataFactory_BillingShares.getAccount4().Id;


        Billing_Participant__c bp1 = new Billing_Participant__c();
        bp1.BillingAccountID__c = billingAccount1.Id;
        bp1.SourceSystemIdentifier__c = billingAccount1.AccountNumber__c + '~' + '00' + '~' + billingAccount1.Id;
        bp1.ParticipantAccountId__c = customerAccount4Id;

        Billing_Participant__c bp2 = new Billing_Participant__c();
        bp2.BillingAccountID__c = billingAccount2.Id;
        bp2.SourceSystemIdentifier__c = billingAccount2.AccountNumber__c + '~' + '00' + '~' + billingAccount2.Id;
        bp2.ParticipantAccountId__c = customerAccount4Id;


        insert bp1;
        insert bp2;

        Map<Id, Set<id>> billingAccountToCustomerIdsMap = new Map<Id, Set<Id>>();

        //ensure the map already has an entry so we can hit the other conditional branch
        billingAccountToCustomerIdsMap.put(billingAccount1.Id, new Set<Id>{});

        Set<Id> billingAccountIdsForAllAccounts = new Set<Id>{billingAccount1.Id, billingAccount2.Id};
        Set<Id> customerAccountIdsForAllBillingAccounts = new Set<Id>();

        UTIL_BillingAccountSharesDelete.updateMapThroughInsurancePolicyAssociation(billingAccountToCustomerIdsMap, billingAccountIdsForAllAccounts,customerAccountIdsForAllBillingAccounts);

        System.assertEquals(2, billingAccountToCustomerIdsMap.keySet().size(), 'Expected billingAccountToCustomerIdsMap keyset to be of size 2');
        System.assertEquals(1, customerAccountIdsForAllBillingAccounts.size(), 'Expected customerAccountIdsForAllBillingAccounts to be of size 1');
        
    }

    @isTest 
    private static void updateMapThroughInsurancePolicyAssociationMissingPolicy() {
        Billing_Account__c billingAccount1 = TestDataFactory_BillingShares.getBillingAccount1();
        Billing_Account__c billingAccount2 = TestDataFactory_BillingShares.getBillingAccount2();
        Id customerAccount4Id = TestDataFactory_BillingShares.getAccount4().Id;


        Billing_Participant__c bp1 = new Billing_Participant__c();
        bp1.BillingAccountID__c = billingAccount1.Id;
        bp1.SourceSystemIdentifier__c = billingAccount1.AccountNumber__c + '~' + '00' + '~' + billingAccount1.Id;
        bp1.ParticipantAccountId__c = customerAccount4Id;

        Billing_Participant__c bp2 = new Billing_Participant__c();
        bp2.BillingAccountID__c = billingAccount2.Id;
        bp2.SourceSystemIdentifier__c = billingAccount2.AccountNumber__c + '~' + '00' + '~' + billingAccount2.Id;
        bp2.ParticipantAccountId__c = customerAccount4Id;


        insert bp1;
        insert bp2;

        // remove the insurance policy from the billing policy so the named insured is not available
        Billing_Policy__c billingPolicy1 = TestDataFactory_BillingSharesPolicy.getBillingPolicy1();
        billingPolicy1.InsurancePolicyId__c = null;
        update billingPolicy1;

        Map<Id, Set<id>> billingAccountToCustomerIdsMap = new Map<Id, Set<Id>>();

        //ensure the map already has an entry so we can hit the other conditional branch
        billingAccountToCustomerIdsMap.put(billingAccount1.Id, new Set<Id>{});

        Set<Id> billingAccountIdsForAllAccounts = new Set<Id>{billingAccount1.Id, billingAccount2.Id};
        Set<Id> customerAccountIdsForAllBillingAccounts = new Set<Id>();

        UTIL_BillingAccountSharesDelete.updateMapThroughInsurancePolicyAssociation(billingAccountToCustomerIdsMap, billingAccountIdsForAllAccounts,customerAccountIdsForAllBillingAccounts);

        System.assertEquals(2, billingAccountToCustomerIdsMap.keySet().size(), 'Expected billingAccountToCustomerIdsMap keyset to be of size 2');
        System.assertEquals(1, customerAccountIdsForAllBillingAccounts.size(), 'Expected customerAccountIdsForAllBillingAccounts to be of size 1');
        
    }


    @isTest 
    private static void getCustomerAccountIdsSetFromInsurancePolicyParticipant() {

        Billing_Account__c billingAccount1 = TestDataFactory_BillingShares.getBillingAccount1();
        Billing_Account__c billingAccount2 = TestDataFactory_BillingShares.getBillingAccount2();
        Billing_Account__c billingAccount3 = TestDataFactory_BillingShares.getBillingAccount3();
        
        Account customerAccount3 = TestDataFactory_BillingShares.getAccount3();

        Set<Id> billingAccountIdsForAllAccounts = new Set<Id>{billingAccount1.Id, billingAccount2.Id, billingAccount3.Id};

        Set<Id> customerAccountIdsFromInsurancePolicyParticipants = UTIL_BillingAccountSharesDelete.getCustomerAccountIdsSetFromInsurancePolicyParticipant(billingAccountIdsForAllAccounts);

        System.assertEquals(1, customerAccountIdsFromInsurancePolicyParticipants.size(), 'Expected customerAccountIdsFromInsurancePolicyParticipants to be of size 1');
        System.assert(customerAccountIdsFromInsurancePolicyParticipants.contains(customerAccount3.Id), 'Expected customerAccountIdsFromInsurancePolicyParticipants to contain Customer Account 3 ID');

    } 

    @isTest 
    private static void updateMapThroughInsurancePolicyParticipantAssociation() {
        Billing_Account__c billingAccount1 = TestDataFactory_BillingShares.getBillingAccount1();
        Billing_Account__c billingAccount2 = TestDataFactory_BillingShares.getBillingAccount2();
        Billing_Account__c billingAccount3 = TestDataFactory_BillingShares.getBillingAccount3();
        
        Account customerAccount3 = TestDataFactory_BillingShares.getAccount3();

        Set<Id> billingAccountIdsForAllAccounts = new Set<Id>{billingAccount1.Id, billingAccount2.Id, billingAccount3.Id};
        Set<Id> customerAccountIdsForAllBillingAccounts = new Set<Id>();
        Map<Id, Set<id>> billingAccountToCustomerIdsMap = new Map<Id, Set<Id>>();


        Billing_Participant__c bp1 = new Billing_Participant__c();
        bp1.BillingAccountID__c = billingAccount1.Id;
        bp1.SourceSystemIdentifier__c = billingAccount1.AccountNumber__c + '~' + '00' + '~' + billingAccount1.Id;
        bp1.ParticipantAccountId__c = customerAccount3.Id;

        Billing_Participant__c bp2 = new Billing_Participant__c();
        bp2.BillingAccountID__c = billingAccount2.Id;
        bp2.SourceSystemIdentifier__c = billingAccount2.AccountNumber__c + '~' + '00' + '~' + billingAccount2.Id;
        bp2.ParticipantAccountId__c = customerAccount3.Id;


        insert bp1;
        insert bp2;


        //ensure the map already has an entry so we can hit the other conditional branch
        billingAccountToCustomerIdsMap.put(billingAccount1.Id, new Set<Id>{});


        UTIL_BillingAccountSharesDelete.updateMapThroughInsurancePolicyParticipantAssociation(billingAccountToCustomerIdsMap, billingAccountIdsForAllAccounts,customerAccountIdsForAllBillingAccounts);

        System.assertEquals(2, billingAccountToCustomerIdsMap.keySet().size(), 'Expected billingAccountToCustomerIdsMap keyset to be of size 2');
        System.assertEquals(1, customerAccountIdsForAllBillingAccounts.size(), 'Expected customerAccountIdsForAllBillingAccounts to be of size 1');

    }

    @isTest
    private static void constructUniqueBillingSharesMapFromIdSet(){

        // Create Data utilizing code copied from another test class, should generate two shares.
        Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap = new Map<Id, Set<Id>>();
        List<AgentRole__c> agentRoles = TestDataFactory_BillingSharesAgentRoles.setupOneCustomerAccountTwoBillingAccounts(); 
        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
        UTIL_BillingAccountShares.getBillingAccountsFromBillingParticipants(agentRoleData.agentRolesToAccountIds.values(), customerAccountToBillingAccountIdsMap);
        UTIL_BillingAccountSharesAdd.createBillingSharesFromCustomerAccountToBillingAccountIdsMap(agentRoleData, customerAccountToBillingAccountIdsMap);

        // Retrieve the list of shares we created for validation purposes.
        List<Billing_Account__Share> billingAccountShares = UTIL_BillingAccountSharesTest.getBillingSharesWhereRowCauseIsManual();

        // Create a List of Billing Accounts to pass into the constructUniqueBillingSharesMapFromIdSet method
        Set<Id> billingAccountsForTest = new Set<Id>();
        for(Set<Id> billingAccounts: customerAccountToBillingAccountIdsMap.values()){
            billingAccountsForTest.addAll(billingAccounts);
        }

        // Run Test and validate results
        Map<String, Billing_Account__Share>  results = UTIL_BillingAccountSharesDelete.constructUniqueBillingSharesMapFromIdSet(billingAccountsForTest);

        System.assertEquals(billingAccountShares.size(), results.size(), 'Incorrect number of billing shares');

        for(Billing_Account__Share billingShare: billingAccountShares){
            List<String> tokens = new List<String>{billingShare.ParentId, billingShare.UserOrGroupId};
            String key = String.format('{0}{1}', tokens);
            System.assertEquals(billingShare, results.get(key), 'billing account shares should match');
        }
        
    } 

    @isTest
    private static void getFlatSetFromMap(){

        Integer expectedNumberOfResults = 3;

        // Create Bogus Map to Flatten using data from Data Factory
        Map<Id, Set<Id>> mapToFlatten = new Map<Id, Set<Id>>();
        mapToFlatten.put(TestDataFactory_BillingShares.getAccount1().Id, new Set<Id>{TestDataFactory_BillingShares.getAgent1().Id,TestDataFactory_BillingShares.getAgent2().Id});
        mapToFlatten.put(TestDataFactory_BillingShares.getAccount2().Id, new Set<Id>{TestDataFactory_BillingShares.getAgent2().Id,TestDataFactory_BillingShares.getAgent3().Id});
        mapToFlatten.put(TestDataFactory_BillingShares.getAccount3().Id, new Set<Id>{});

        Set<Id> results = UTIL_BillingAccountSharesDelete.getFlatSetFromMap(mapToFlatten);

        System.assertEquals(expectedNumberOfResults, results.size(), 'Expected result set to be of size 3');

        System.assert(results.contains(TestDataFactory_BillingShares.getAgent1().Id),'Expected resulting ID set to contain Agent 1 ID');
        System.assert(results.contains(TestDataFactory_BillingShares.getAgent2().Id),'Expected resulting ID set to contain Agent 2 ID');
        System.assert(results.contains(TestDataFactory_BillingShares.getAgent3().Id),'Expected resulting ID set to contain Agent 3 ID');

    }

    @isTest
    private static void isBillingAccountShareDeletableEmptyAllBillingAccountsCustomerAccountIdsSet() {
        Id billingAccountId = TestDataFactory_BillingShares.getBillingAccount4().Id;
        Map<Id, Set<Id>> billingAccountToCustomerIdsMap = new Map<Id, Set<Id>>();
        billingAccountToCustomerIdsMap.put(billingAccountId, new Set<Id>());
        UTIL_BillingAccountSharesDeleteData billingAccountShareData = new UTIL_BillingAccountSharesDeleteData()
        .setBillingAccountToCustomerIdsMap(billingAccountToCustomerIdsMap);
        AgentRole__c agentRole = null;
        UTIL_BillingAccountShareDeleteHelper helper = new UTIL_BillingAccountShareDeleteHelper()
        .setBillingAccountId(billingAccountId)
        .setAgentRole(agentRole)
        .setBillingAccountShareData(billingAccountShareData);

        boolean isBillingAccountShareDeletable = UTIL_BillingAccountSharesDelete.isBillingAccountShareDeletable(helper);

        System.assertEquals(true, isBillingAccountShareDeletable, 'based on having an empty BillingAccountsCustomerAccountIds Set, the Billing Account Share should be deleteable');
    }

    @isTest
    private static void isBillingAccountShareDeletableTrue() {

        Id billingAccountId = TestDataFactory_BillingShares.getBillingAccount4().Id;
        Map<Id, Set<Id>> billingAccountToCustomerIdsMap = new Map<Id, Set<Id>>();
        billingAccountToCustomerIdsMap.put(billingAccountId, new Set<Id>());
        
        Id agentId = TestDataFactory_BillingShares.getAgent2().id;
        Id accountOneId = TestDataFactory_BillingShares.getAccount1().id;
        Id accountTwoId = TestDataFactory_BillingShares.getAccount2().id;
        Id accountThreeId = TestDataFactory_BillingShares.getAccount3().id;

        // Agent will have one relationship to billing account via the customer. 
        AgentRole__c agentRole = new AgentRole__c(Customer__c = accountOneId, Agent__c = agentId);
        insert agentRole;

        // Create Map of Billing Accounts To Agents
        Map<Id,Set<Id>> customerAccountIdToAgentIdsMap = new Map<Id,Set<Id>>();
        customerAccountIdToAgentIdsMap.put(accountOneId, new Set<Id>{agentId});
        customerAccountIdToAgentIdsMap.put(accountTwoId, new Set<Id>{});
        customerAccountIdToAgentIdsMap.put(accountThreeId, null);

        // Create Map of Agents to Accounts which will represent our original Agent Role List
        Map <Id,Set<Id>> agentToAccountsAgentRoleMap = new Map <Id,Set<Id>>();
        agentToAccountsAgentRoleMap.put(agentId, new Set<Id>{accountOneId});

        UTIL_AgencySharesModels.AgentRoleData agentRoleData = new UTIL_AgencySharesModels.AgentRoleData();
        agentRoleData.agentToAccountsAgentRoleMap = agentToAccountsAgentRoleMap;

        UTIL_BillingAccountSharesDeleteData billingAccountShareData = new UTIL_BillingAccountSharesDeleteData()
            .setCustomerAccountIdToAgentIdsMap(customerAccountIdToAgentIdsMap)
            .setBillingAccountToCustomerIdsMap(billingAccountToCustomerIdsMap)
            .setAgentRoleData(agentRoleData);

        UTIL_BillingAccountShareDeleteHelper helper = new UTIL_BillingAccountShareDeleteHelper()
        .setBillingAccountId(billingAccountId)
        .setAgentRole(agentRole)
        .setBillingAccountShareData(billingAccountShareData);

        boolean isDeletable = UTIL_BillingAccountSharesDelete.isBillingAccountShareDeletable(helper);

        System.assert(isDeletable,'Expected isDeletable to be true');
     
    }

    @isTest
    private static void isBillingAccountShareDeletableTrueOneAccount() {
        Id accountId = TestDataFactory_BillingShares.getAccount1().id;
        Id agentId = TestDataFactory_BillingShares.getAgent2().id;


        // Agent will have one relationship to billing account via the customer. 
        AgentRole__c agentRole = new AgentRole__c(Customer__c = accountId, Agent__c = agentId);
        insert agentRole;

        Id billingAccountId = TestDataFactory_BillingShares.getBillingAccount4().Id;
        Map<Id, Set<Id>> billingAccountToCustomerIdsMap = new Map<Id, Set<Id>>();
        billingAccountToCustomerIdsMap.put(billingAccountId, new Set<Id>());

        Map<Id,Set<Id>> customerAccountIdToAgentIdsMap = new Map<Id,Set<Id>>();
        customerAccountIdToAgentIdsMap.put(accountId, new Set<Id>{agentId});

        // Create Map of Agents to Accounts which will represent our original Agent Role List
        Map <Id,Set<Id>> agentToAccountsAgentRoleMap = new Map <Id,Set<Id>>();
        agentToAccountsAgentRoleMap.put(agentId, new Set<Id>{accountId});

        UTIL_AgencySharesModels.AgentRoleData agentRoleData = new UTIL_AgencySharesModels.AgentRoleData();
        agentRoleData.agentToAccountsAgentRoleMap = agentToAccountsAgentRoleMap;

        UTIL_BillingAccountSharesDeleteData billingAccountShareData = new UTIL_BillingAccountSharesDeleteData()
            .setCustomerAccountIdToAgentIdsMap(customerAccountIdToAgentIdsMap)
            .setBillingAccountToCustomerIdsMap(billingAccountToCustomerIdsMap)
            .setAgentRoleData(agentRoleData);

        UTIL_BillingAccountShareDeleteHelper helper = new UTIL_BillingAccountShareDeleteHelper()
        .setBillingAccountId(TestDataFactory_BillingShares.getBillingAccount4().Id)
        .setAgentRole(null)
        .setBillingAccountShareData(billingAccountShareData);
        

        boolean isDeletable = UTIL_BillingAccountSharesDelete.isBillingAccountShareDeletable(helper);

        System.assert(isDeletable,'Expected isDeletable to be true');

    }

    @isTest
    private static void isBillingAccountShareDeletableFalse() {

        Id agentId = TestDataFactory_BillingShares.getAgent1().id;
        Id accountOneId = TestDataFactory_BillingShares.getAccount1().id;
        Id accountTwoId = TestDataFactory_BillingShares.getAccount2().id;        
        Id billingAccountId = TestDataFactory_BillingShares.getBillingAccount4().Id;


        // Agent will have one relationship to billing account via the customer. 
        AgentRole__c agentRole = new AgentRole__c(Customer__c = accountOneId, Agent__c = agentId);
        insert agentRole;

        Map<Id, Set<Id>> billingAccountToCustomerIdsMap = new Map<Id, Set<Id>>();
        billingAccountToCustomerIdsMap.put(billingAccountId, new Set<Id>{accountOneId, accountTwoId});

        // Create Map of Customer Accounts To Agents
        Map<Id,Set<Id>> customerAccountIdToAgentIdsMap = new Map<Id,Set<Id>>();
        customerAccountIdToAgentIdsMap.put(accountOneId, new Set<Id>{agentId});
        customerAccountIdToAgentIdsMap.put(accountTwoId, new Set<Id>{agentId});

        // Create Map of Agents to Accounts which will represent our original Agent Role List
        Map <Id,Set<Id>> agentToAccountsAgentRoleMap = new Map <Id,Set<Id>>();
        agentToAccountsAgentRoleMap.put(agentId, new Set<Id>{accountOneId});

        UTIL_AgencySharesModels.AgentRoleData agentRoleData = new UTIL_AgencySharesModels.AgentRoleData();
        agentRoleData.agentToAccountsAgentRoleMap = agentToAccountsAgentRoleMap;

        UTIL_BillingAccountSharesDeleteData billingAccountShareData = new UTIL_BillingAccountSharesDeleteData()
            .setCustomerAccountIdToAgentIdsMap(customerAccountIdToAgentIdsMap)
            .setBillingAccountToCustomerIdsMap(billingAccountToCustomerIdsMap)
            .setAgentRoleData(agentRoleData);

        UTIL_BillingAccountShareDeleteHelper helper = new UTIL_BillingAccountShareDeleteHelper()
        .setBillingAccountId(TestDataFactory_BillingShares.getBillingAccount4().Id)
        .setAgentRole(agentRole)
        .setBillingAccountShareData(billingAccountShareData);

        boolean isDeletable = UTIL_BillingAccountSharesDelete.isBillingAccountShareDeletable(helper);

        System.assert(!isDeletable,'Expected isDeletable to be false');

    }

    @isTest
    private static void isBillingAccountShareDeletableTrueNullCustomerAccounts() {

        Id agentId = TestDataFactory_BillingShares.getAgent1().id;
        Id accountOneId = TestDataFactory_BillingShares.getAccount1().id;
        Id accountTwoId = TestDataFactory_BillingShares.getAccount2().id;        
        Id billingAccountId = TestDataFactory_BillingShares.getBillingAccount4().Id;


        // Agent will have one relationship to billing account via the customer. 
        AgentRole__c agentRole = new AgentRole__c(Customer__c = accountOneId, Agent__c = agentId);
        insert agentRole;

        Map<Id, Set<Id>> billingAccountToCustomerIdsMap = new Map<Id, Set<Id>>();
        billingAccountToCustomerIdsMap.put(billingAccountId, null);

        // Create Map of Customer Accounts To Agents
        Map<Id,Set<Id>> customerAccountIdToAgentIdsMap = new Map<Id,Set<Id>>();
        customerAccountIdToAgentIdsMap.put(accountOneId, new Set<Id>{agentId});
        customerAccountIdToAgentIdsMap.put(accountTwoId, new Set<Id>{agentId});

        // Create Map of Agents to Accounts which will represent our original Agent Role List
        Map <Id,Set<Id>> agentToAccountsAgentRoleMap = new Map <Id,Set<Id>>();
        agentToAccountsAgentRoleMap.put(agentId, new Set<Id>{accountOneId});

        UTIL_AgencySharesModels.AgentRoleData agentRoleData = new UTIL_AgencySharesModels.AgentRoleData();
        agentRoleData.agentToAccountsAgentRoleMap = agentToAccountsAgentRoleMap;

        UTIL_BillingAccountSharesDeleteData billingAccountShareData = new UTIL_BillingAccountSharesDeleteData()
            .setCustomerAccountIdToAgentIdsMap(customerAccountIdToAgentIdsMap)
            .setBillingAccountToCustomerIdsMap(billingAccountToCustomerIdsMap)
            .setAgentRoleData(agentRoleData);

        UTIL_BillingAccountShareDeleteHelper helper = new UTIL_BillingAccountShareDeleteHelper()
        .setBillingAccountId(TestDataFactory_BillingShares.getBillingAccount4().Id)
        .setAgentRole(agentRole)
        .setBillingAccountShareData(billingAccountShareData);

        boolean isDeletable = UTIL_BillingAccountSharesDelete.isBillingAccountShareDeletable(helper);

        System.assert(isDeletable,'Expected isDeletable to be true');

    }

    @isTest
    private static void isBillingAccountShareDeletableTrueBothRelationships() {

        Id agentId = TestDataFactory_BillingShares.getAgent1().id;
        Id accountOneId = TestDataFactory_BillingShares.getAccount1().id;
        Id accountTwoId = TestDataFactory_BillingShares.getAccount2().id;
        Id billingAccountId = TestDataFactory_BillingShares.getBillingAccount4().Id;


        // Agent will have one relationship to billing account via the customer. 
        AgentRole__c agentRole = new AgentRole__c(Customer__c = accountOneId, Agent__c = agentId);
        insert agentRole;

        // Create Map of Customer Accounts To Agents
        Map<Id,Set<Id>> customerAccountIdToAgentIdsMap = new Map<Id,Set<Id>>();
        customerAccountIdToAgentIdsMap.put(accountOneId, new Set<Id>{agentId});
        customerAccountIdToAgentIdsMap.put(accountTwoId, new Set<Id>{agentId});

        Map<Id, Set<Id>> billingAccountToCustomerIdsMap = new Map<Id, Set<Id>>();
        billingAccountToCustomerIdsMap.put(billingAccountId, new Set<Id>{accountOneId, accountTwoId});

        // Create Map of Agents to Accounts which will represent our original Agent Role List
        Map <Id,Set<Id>> agentToAccountsAgentRoleMap = new Map <Id,Set<Id>>();
        agentToAccountsAgentRoleMap.put(agentId, new Set<Id>{accountOneId, accountTwoId});

        UTIL_AgencySharesModels.AgentRoleData agentRoleData = new UTIL_AgencySharesModels.AgentRoleData();
        agentRoleData.agentToAccountsAgentRoleMap = agentToAccountsAgentRoleMap;

        UTIL_BillingAccountSharesDeleteData billingAccountShareData = new UTIL_BillingAccountSharesDeleteData()
            .setCustomerAccountIdToAgentIdsMap(customerAccountIdToAgentIdsMap)
            .setBillingAccountToCustomerIdsMap(billingAccountToCustomerIdsMap)
            .setAgentRoleData(agentRoleData);

        UTIL_BillingAccountShareDeleteHelper helper = new UTIL_BillingAccountShareDeleteHelper()
        .setBillingAccountId(TestDataFactory_BillingShares.getBillingAccount4().Id)
        .setAgentRole(agentRole)
        .setBillingAccountShareData(billingAccountShareData);

        boolean isDeletable = UTIL_BillingAccountSharesDelete.isBillingAccountShareDeletable(helper);

        System.assert(isDeletable,'Expected isDeletable to be true');

    }

    @isTest
    private static void validateDeleteBillingAccountSharesHappy() {

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

        // Perform the delete
        List<Database.DeleteResult> deleteResultsList = UTIL_BillingAccountSharesDelete.performBillingAccountSharesDelete(new Set<Billing_Account__Share>(billingShares));

        System.assertEquals(2, deleteResultsList.size(), '2 Billing Shares should have been deleted');

        List<Billing_Account__Share> billingSharesAfterDelete = UTIL_BillingAccountSharesTest.getBillingSharesWhereRowCauseIsManual();

        System.assertEquals(0, billingSharesAfterDelete.size(), '0 Billing Shares should remain');

    }

    @isTest
    private static void validateDeleteBillingAccountSharesEmptySharesSet() {

        List<Database.DeleteResult> deleteResultsList = UTIL_BillingAccountSharesDelete.performBillingAccountSharesDelete(null);
        System.assertEquals(0, deleteResultsList.size(), 'No shares should have been delete to the database.');
    }

}