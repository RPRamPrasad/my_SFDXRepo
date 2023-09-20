/*
 * @author Team NSYNC (YCDB)
 * @description Used to generate data for Billing Shares Tests
 * @version 1.0
 * @dateCreated 10/21/2021
 */
@isTest
public with sharing class TestDataFactory_BillingSharesAgentRoles extends UTIL_AgencyShares{

    /**
     * @name setupBasicAgentTest
     * @description : Setup a basic agent test which will only create a Billing Account with One Agent Role
     * @param agentRoles
     * @return Billing_Account__c
     */
    public static Billing_Account__c setupBasicAgentTest(List<AgentRole__c> agentRoles) { 

        // Get Agent
        User agentUser = TestDataFactory_BillingShares.getAgent1();

        Account customerAccount = TestDataFactory_BillingShares.getAccount1();

        Billing_Participant__c billingParticipant = TestDataFactory_BillingShares.getBillingParticipant1();
        
        AgentRole__c agentRole1 = new AgentRole__c(Customer__c=customerAccount.Id, Agent__c = agentUser.id);
        agentRoles.add(agentRole1);

        AgentRole__c agentRole2 = new AgentRole__c(Customer__c=billingParticipant.ParticipantAccountId__c, Agent__c = agentUser.id);
        agentRoles.add(agentRole2);

        insert agentRoles;

        return TestDataFactory_BillingShares.getBillingAccount1();

   }

    /**
     * @description Create an Agent Role for an account with no billing accounts, we will use an account and
     * agent created by initial test setup.
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> setupNoBillingAccounts() { 

        // Get Agent
        User agentUser = TestDataFactory_BillingShares.getAgent3();

        // Get Account
        Account account = TestDataFactory_BillingShares.getAccount4();

        List<AgentRole__c> agentRoles = new List<AgentRole__c>();

        AgentRole__c agentRole = new AgentRole__c(Customer__c=account.Id, Agent__c = agentUser.id);
        agentRoles.add(agentRole);

        // Insert New Agent Roles
        insert agentRoles;

        return agentRoles;

   }

   /**
     *  @description method will create a policy with two participants sharing the same agent, and generate the agent roles.
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> setupTwoCustomerAccountsOneBillingAccount() { 

        // Get Agent
        User agentUser = TestDataFactory_BillingShares.getAgent1();

        // The Accounts Retrieved are both created by the same agent in the TestDataFactory, this is key to this test.
        TestDataFactory_BillingShares.getAccount1();
        TestDataFactory_BillingShares.getAccount2();

        TestDataFactory_BillingShares.getBillingAccount1();

        /**************************** Create Billing Participants ***************************/

        Billing_Participant__c billingParticipant1 = TestDataFactory_BillingShares.getBillingParticipant1();
        Billing_Participant__c billingParticipant2 = TestDataFactory_BillingShares.getBillingParticipant2();

        /**************************** Create Agent Roles ***************************/

        // Create Agent Roles
        List<AgentRole__c> agentRoles = new List<AgentRole__c>();

        AgentRole__c newAgentRole1 = new AgentRole__c(Customer__c=billingParticipant1.ParticipantAccountId__c, Agent__c = agentUser.id);
        agentRoles.add(newAgentRole1);

        AgentRole__c newAgentRole2 = new AgentRole__c(Customer__c=billingParticipant2.ParticipantAccountId__c, Agent__c = agentUser.id);
        agentRoles.add(newAgentRole2);

        // Insert New Agent Roles
        insert agentRoles;

        return agentRoles;

   }

   /**
     * @description will create three agent roles, see below for detail:
     * Agent 1/Account 1(Billing Account 1,2)
     * Agent 1/Account 2(Billing Account 2)
     * Agent 2/Account 2(Billing Account 2)
     * 
     * 3 Manual Shares should be created by this test:
     * Agent 1/Billing Account 1 && Agent 1/Billing Account 2
     * Agent 2/Billing Account 2
     *  
     * @return List<AgentRole__c>
     */
     
    public static List<AgentRole__c> setupTwoCustAccountsTwoBillAccountsTwoAgent() { 

        User agentUser1 = TestDataFactory_BillingShares.getAgent1();
        User agentUser2 = TestDataFactory_BillingShares.getAgent2();

        Account account1 = TestDataFactory_BillingShares.getAccount1();
        Account account2 = TestDataFactory_BillingShares.getAccount2();


        /**************************** Create Agent Roles **************************/

        List<AgentRole__c> agentRoles = new List<AgentRole__c>();

        AgentRole__c newAgentRole1 = new AgentRole__c(Customer__c = account1.id, Agent__c = agentUser1.id);
        agentRoles.add(newAgentRole1);

        AgentRole__c newAgentRole2 = new AgentRole__c(Customer__c = account2.id, Agent__c = agentUser1.id);
        agentRoles.add(newAgentRole2);

        AgentRole__c newAgentRole3 = new AgentRole__c(Customer__c = account2.id, Agent__c = agentUser2.id);
        agentRoles.add(newAgentRole3);

        insert agentRoles;

        return agentRoles;

    } 

     /**
     *  @description method will create two billing accounts and assign them to one account using a single agent.
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> setupOneCustomerAccountTwoBillingAccounts() { 

        // Get Agent
        User agentUser = TestDataFactory_BillingShares.getAgent1();

        // The Accounts Retrieved are both created by the same agent in the TestDataFactory, this is key to this test.
        Account account = TestDataFactory_BillingShares.getAccount1();
        
        // Create Agent Roles
        List<AgentRole__c> agentRoles = new List<AgentRole__c>();

        AgentRole__c newAgentRole = new AgentRole__c(Customer__c=account.Id, Agent__c = agentUser.id);
        agentRoles.add(newAgentRole);

        // Insert New Agent Roles
        insert agentRoles;

        return agentRoles;

   }

   /**
     *  @description method will create two billing accounts and assign them to one account using a single agent.
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> setupOneAccountTwoInsurancePoliciesAndParticipants() { 

        // Get Agent
        User agentUser = TestDataFactory_BillingShares.getAgent3();

        // The Accounts Retrieved are both created by the same agent in the TestDataFactory, this is key to this test.
        Account account1 = TestDataFactory_BillingShares.getAccount4();
        Account account2 = TestDataFactory_BillingShares.getAccount3();
        
        // Create Agent Roles
        List<AgentRole__c> agentRoles = new List<AgentRole__c>();

        AgentRole__c newAgentRole1 = new AgentRole__c(Customer__c=account1.Id, Agent__c = agentUser.id);
        AgentRole__c newAgentRole2 = new AgentRole__c(Customer__c=account2.Id, Agent__c = agentUser.id);
        agentRoles.add(newAgentRole1);
        agentRoles.add(newAgentRole2);

        // Insert New Agent Roles
        insert agentRoles;

        return agentRoles;

   }
}
