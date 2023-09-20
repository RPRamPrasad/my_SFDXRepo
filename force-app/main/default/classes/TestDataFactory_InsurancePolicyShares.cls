/*
 * @author Team Kraken (VAASTT)
 * @description Used to generate data for Agreement Risk Tests
 * @version 1.0
 * @dateCreated 11/02/2020
 */
@isTest
public with sharing class TestDataFactory_InsurancePolicyShares extends UTIL_AgencyShares {

    /**
     *  @description method will create a policy with two participants sharing the same agent, and generate the agent roles.
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> setupTwoParticipantsOneAgent() { 

        // Get Agent
        User agentUser = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];

        // The Accounts Retrieved are both created by the same agent in the TestDataFactory, this is key to this test.
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount2();
        Account account3 = TestDataFactory_AgencyShares.getAccount3();


        InsurancePolicy policy = new InsurancePolicy(Name='Policy', NameInsuredId=account3.id);
        insert policy;

        /**************************** Create Insurance Policy Participants ***************************/

        InsurancePolicyParticipant participant1 = 
            new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Named Insured');
        insert participant1;

        InsurancePolicyParticipant participant2 = 
            new InsurancePolicyParticipant(PrimaryParticipantAccountId = account2.Id, InsurancePolicyId = policy.Id, Role='Named Insured');
        insert participant2;

        /**************************** Create Agent Roles ***************************/

        // Create Agent Roles
        List<AgentRole__c> agentRoles = new List<AgentRole__c>();

        AgentRole__c newAgentRole1 = new AgentRole__c(Customer__c=account1.Id, Agent__c = agentUser.id);
        agentRoles.add(newAgentRole1);


        AgentRole__c newAgentRole2 = new AgentRole__c(Customer__c=account2.Id, Agent__c = agentUser.id);
        agentRoles.add(newAgentRole2);

        // Insert New Agent Roles
        insert agentRoles;

        // Generate Shares for new Agent Roles.
        UTIL_InsurancePolicyShares.createInsurancePolicyShares(TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles));

        return agentRoles;

   }




    /**
     * @description method will create a policy with one participant and one primary insured sharing the same agent, and generate the agent roles.
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> setupOneParticipantsOnePrimaryInsuredOneAgent() { 

        // Get Agent
        User agentUser = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];

        // The Accounts Retrieved are both created by the same agent in the TestDataFactory, this is key to this test.
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount2();
  


        InsurancePolicy policy = new InsurancePolicy(Name='Policy', NameInsuredId=account2.id);
        insert policy;

        /**************************** Create Insurance Policy Participants ***************************/

        InsurancePolicyParticipant participant = 
            new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.Id, InsurancePolicyId = policy.Id, Role='Named Insured');
        insert participant;


        /**************************** Create Agent Roles ***************************/

        List<AgentRole__c> agentRoles = new List<AgentRole__c>();

        AgentRole__c newAgentRole1 = new AgentRole__c(Customer__c=account1.Id, Agent__c = agentUser.id);
        agentRoles.add(newAgentRole1);

        AgentRole__c newAgentRole2 = new AgentRole__c(Customer__c=account2.Id, Agent__c = agentUser.id);
        agentRoles.add(newAgentRole2);

        // Insert New Agent Roles
        insert agentRoles;

        // Generate Shares for new Agent Roles.
        UTIL_InsurancePolicyShares.createInsurancePolicyShares(TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles));

        return agentRoles;

   }

   /**
     * @description Create an Agent Role for an account with no policies, we will use an account and
     * agent created by initial test setup.
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> setupNoPolicies() { 

        // Get Agent
        User agentUser = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];

        // Get Account
        Account account = TestDataFactory_AgencyShares.getAccount1();

        List<AgentRole__c> agentRoles = new List<AgentRole__c>();

        AgentRole__c agentRole = new AgentRole__c(Customer__c=account.Id, Agent__c = agentUser.id);
        agentRoles.add(agentRole);

        // Insert New Agent Roles
        insert agentRoles;

        return agentRoles;

   }



   /**
     * @description setup a test in which use 1 Account with 1 Agent as the primary insured and also as multiple participants.
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> setupOneAccountPolicyMultipleParticipants() { 

        // Get Agent
        User agentUser = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];

        // The Accounts Retrieved are both created by the same agent in the TestDataFactory, this is key to this test.
        Account account = TestDataFactory_AgencyShares.getAccount1();


        InsurancePolicy policy = new InsurancePolicy(Name='Policy', NameInsuredId=account.id);
        insert policy;

        /**************************** Create Insurance Policy Participants ***************************/

        InsurancePolicyParticipant participant1 = 
            new InsurancePolicyParticipant(PrimaryParticipantAccountId = account.Id, InsurancePolicyId = policy.Id, Role='Named Insured');
        insert participant1;

        InsurancePolicyParticipant participant2 = 
            new InsurancePolicyParticipant(PrimaryParticipantAccountId = account.Id, InsurancePolicyId = policy.Id, Role='Named Insured');
        insert participant2;

        /**************************** Create Agent Roles ***************************/

        List<AgentRole__c> agentRoles = new List<AgentRole__c>();

        AgentRole__c newAgentRole = new AgentRole__c(Customer__c=account.Id, Agent__c = agentUser.id);
        agentRoles.add(newAgentRole);

        // Insert New Agent Roles
        insert agentRoles;

        // Generate Shares for new Agent Roles.
        UTIL_InsurancePolicyShares.createInsurancePolicyShares(TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles));

        return agentRoles;
    }



    /**
     * @description : Setup a basic agent test which will create only create Insurance Policy with One Agent Role
     * @param agentRoles
     * @return InsurancePolicy
     */
    public static InsurancePolicy setupBasicAgentTest(List<AgentRole__c> agentRoles) { 

        // Get Agent
        User agentUser = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];

        // Get Primary Insure Account and Participant Account
        Account namedInsuredAccount = TestDataFactory_AgencyShares.getAccount1();
        Account participantAccount = TestDataFactory_AgencyShares.getAccount3();

        // We will only be using one Insurance Policy for this test
        InsurancePolicy policy = new InsurancePolicy(Name='Policy', NameInsuredId=namedInsuredAccount.id);
        insert policy;

        // Create Participant for Policy
        InsurancePolicyParticipant participant = 
        new InsurancePolicyParticipant(PrimaryParticipantAccountId = participantAccount.id, InsurancePolicyId = policy.Id, Role='Named Insured');
        insert participant;
        
        AgentRole__c agentRole1 = new AgentRole__c(Customer__c=namedInsuredAccount.Id, Agent__c = agentUser.id);
        agentRoles.add(agentRole1);

        AgentRole__c agentRole2 = new AgentRole__c(Customer__c=participantAccount.Id, Agent__c = agentUser.id);
        agentRoles.add(agentRole2);

        insert agentRoles;

        return policy;

   }





}
