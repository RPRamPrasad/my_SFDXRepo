/*
 * @author Team STARK
 * @description Used to generate data for Account (Household) Shares Tests
 * @version 1.0
 * @dateCreated 05/01/2021
 */
@isTest
public with sharing class TestDataFactory_HouseholdAccountShares extends UTIL_AgencyShares {
    /**
     *  @description method will create a household with only one account and agent
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> setupHouseholdWithOnlyOneCustomer() { 

        // Get Agent
        User agentUser = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
        //Get Account
        Account account = TestDataFactory_AgencyShares.getAccount1();
        //Get Household
		Account household = TestDataFactory_AgencyShares.getHousehold1();

        /**************************** Create Agent Roles ***************************/

        AgentRole__c newAgentRole = new AgentRole__c(Customer__c=account.Id, Agent__c = agentUser.id, Primary_Household__c=household.Id);

        // Insert New Agent Roles
        insert newAgentRole;

        // Generate Shares for new Agent Roles.
        UTIL_HouseholdAccountShares.createHouseholdShares(TestDataFactory_AgencyShares.populateAgentRoleDataObject(new List<AgentRole__c>{newAgentRole}));
        
        //Delete agent roles which are needed to be deleted and send them across as list
        delete newAgentRole;
        return new List<AgentRole__c>{newAgentRole};

   }
    
    /**
     *  @description method will have one household with three accounts with different agents and have one common agent
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> setupHouseholdWithThreeCustomers() { 

        // Get Agent
        User agentUser1 = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
         User agentUser2 = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_TWO_EMAIL];
         
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount2();
        Account account3 = TestDataFactory_AgencyShares.getAccount3();
		Account household1 = TestDataFactory_AgencyShares.getHousehold1();

        /**************************** Create Agent Roles ***************************/

        // Create Agent Roles
        List<AgentRole__c> agentRoles = new List<AgentRole__c>();

        AgentRole__c newAgentRole1 = new AgentRole__c(Customer__c=account1.Id, Agent__c = agentUser1.id, Primary_Household__c=household1.Id);
        agentRoles.add(newAgentRole1);


        AgentRole__c newAgentRole2 = new AgentRole__c(Customer__c=account2.Id, Agent__c = agentUser1.id, Primary_Household__c=household1.Id);
        agentRoles.add(newAgentRole2);
        
        AgentRole__c newAgentRole3 = new AgentRole__c(Customer__c=account3.Id, Agent__c = agentUser2.id, Primary_Household__c=household1.Id);
        agentRoles.add(newAgentRole3);

        // Insert New Agent Roles
        insert agentRoles;

        // Generate Shares for new Agent Roles.
        UTIL_HouseholdAccountShares.createHouseholdShares(TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles));
        
        //Delete agent roles which are needed to be deleted and send them across as list
        delete newAgentRole3;
        return new List<AgentRole__c>{newAgentRole3};

   }
    
    /**
     *  @description method will have one household with three accounts with different agents and have one common agent
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> setupHouseholdWithTwoCustomers() { 

        // Get Agent
        User agentUser1 = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount2();
		Account household1 = TestDataFactory_AgencyShares.getHousehold1();

        /**************************** Create Agent Roles ***************************/

        // Create Agent Roles
        List<AgentRole__c> agentRoles = new List<AgentRole__c>();

        AgentRole__c newAgentRole1 = new AgentRole__c(Customer__c=account1.Id, Agent__c = agentUser1.id, Primary_Household__c=household1.Id);
        agentRoles.add(newAgentRole1);


        AgentRole__c newAgentRole2 = new AgentRole__c(Customer__c=account2.Id, Agent__c = agentUser1.id, Primary_Household__c=household1.Id);
        agentRoles.add(newAgentRole2);

        // Insert New Agent Roles
        insert agentRoles;

        // Generate Shares for new Agent Roles.
        UTIL_HouseholdAccountShares.createHouseholdShares(TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles));
        
        //Delete agent roles which are needed to be deleted and send them across as list
        delete newAgentRole2;
        return new List<AgentRole__c>{newAgentRole2};

   }

   /**
     * @description method will have multiple household with different customers with different agents having some common agents
     * between households or customers
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> setupHouseholdsWithBulkCustomersAndAgents() { 
        // Get All Agent
        User agentUser1 = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
		User agentUser2 = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_TWO_EMAIL];
        User agentUser3 = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_THREE_EMAIL];
        User agentUser4 = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_FOUR_EMAIL];
        User agentUser5 = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_FIVE_EMAIL];
        User agentUser6 = [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_SIX_EMAIL];
        //Get All Accounts
        Account account1 = TestDataFactory_AgencyShares.getAccount1();
        Account account2 = TestDataFactory_AgencyShares.getAccount2();
        Account account3 = TestDataFactory_AgencyShares.getAccount3();
        Account account4 = TestDataFactory_AgencyShares.getAccount4();
        Account account5 = TestDataFactory_AgencyShares.getAccount5();
        //Get All Households
		Account household1 = TestDataFactory_AgencyShares.getHousehold1();
        Account household2 = TestDataFactory_AgencyShares.getHousehold2();
        Account household3 = TestDataFactory_AgencyShares.getHousehold3();
        
        /**************************** Create Agent Roles ***************************/
        
        AgentRole__c newAgentRole1 = new AgentRole__c(Customer__c=account1.Id, Agent__c = agentUser1.id, Primary_Household__c=household1.Id);
        AgentRole__c newAgentRole2 = new AgentRole__c(Customer__c=account1.Id, Agent__c = agentUser2.id, Primary_Household__c=household1.Id);
        AgentRole__c newAgentRole3 = new AgentRole__c(Customer__c=account1.Id, Agent__c = agentUser4.id, Primary_Household__c=household1.Id);
       	AgentRole__c newAgentRole4 = new AgentRole__c(Customer__c=account2.Id, Agent__c = agentUser1.id, Primary_Household__c=household1.Id);
        
        AgentRole__c newAgentRole5 = new AgentRole__c(Customer__c=account3.Id, Agent__c = agentUser3.id, Primary_Household__c=household3.Id);
        
        AgentRole__c newAgentRole6 = new AgentRole__c(Customer__c=account4.Id, Agent__c = agentUser2.id, Primary_Household__c=household2.Id);
        AgentRole__c newAgentRole7 = new AgentRole__c(Customer__c=account4.Id, Agent__c = agentUser6.id, Primary_Household__c=household2.Id);
        
        AgentRole__c newAgentRole8 = new AgentRole__c(Customer__c=account5.Id, Agent__c = agentUser5.id);
        
        List<AgentRole__c> agentRoles = new List<AgentRole__c>{newAgentRole1,newAgentRole2,newAgentRole3,
            newAgentRole4,newAgentRole5,newAgentRole6,newAgentRole7,newAgentRole8};
        // Insert New Agent Roles
        insert agentRoles;
        
        // Generate Shares for new Agent Roles.
        UTIL_HouseholdAccountShares.createHouseholdShares(TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles));
        
        //Delete agent roles which are needed to be deleted and send them across as list
        List<AgentRole__c> deletedAgentRoles = new List<AgentRole__c>{newAgentRole1,newAgentRole5,newAgentRole3,newAgentRole6,newAgentRole8};
        delete deletedAgentRoles;
        return deletedAgentRoles;
    }

}
