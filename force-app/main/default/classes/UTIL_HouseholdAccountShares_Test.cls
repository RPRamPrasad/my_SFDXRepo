/** @description This is a test class for UTIL_HouseholdAccountShares.
  * This class is used to test the utility methods for inserts and deleting Household Account Shares as used by the Agent Role and ACR Triggers.
  * @author Team Stark
  * @owner Team Stark
  * @createdDate 04/10/2021
*/
@isTest
(seeAllData = false)
public class UTIL_HouseholdAccountShares_Test extends UTIL_AgencyShares {
    /**
     * @description Setup Tests by generating data and bypassing all triggers.
     */
    @testsetup
    public static void testSetupData() {

        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        
        // create initial test data, set agent role creation to false.
        TestDataFactory_AgencyShares.createDataForSharesTesting(false);

    }
    
    /**
     * @description Perform a simple test which will determine if shares are being inserted correctly. A second
     * insert has been added to verify that we cannot create duplicates.
     */
    @isTest
    private static void testInsertHouseholdSharesIncludingDuplicates() {
            //Toggle Household_shares set to true
            UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);

            // Create System Admin
            User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            insert systemAdmin;
    
            Test.startTest();
    
            System.runAs(systemAdmin){

                // Get Agent and Proxy
                User agentUser = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
                User agentProxy = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];

                // Get Household Account
                Account householdAccount = TestDataFactory_AgencyShares.gethousehold1();
                // Get Customer Account (individual or Organization)
                Account customer = TestDataFactory_AgencyShares.getAccount1();
                Account customerWithHH = TestDataFactory_AgencyShares.getAccount3();

                // Create Agent Role with or without primary household
                AgentRole__c agentRole = new AgentRole__c(Customer__c=customer.Id, Agent__c = agentUser.id);
                AgentRole__c agentRole1 = new AgentRole__c(Customer__c=customerWithHH.Id, Agent__c = agentUser.id, Primary_Household__c=householdAccount.Id);

                // We need to add the agent role to a list so that it can be passed into the agent role data object generation code.
                List<AgentRole__c> agentRoles = new List<AgentRole__c>();
                agentRoles.add(agentRole);
                agentRoles.add(agentRole1);
                insert agentRoles;

                // Add Data to agent Role Data Object and call add method.
                AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
                UTIL_HouseholdAccountShares.createHouseholdShares(agentRoleData);

                // Verify that a share was created for the household account using the correct agent proxy.
                List<AccountShare> householdAccountShare = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy.Id AND RowCause = 'Manual'];

                System.assertEquals(householdAccountShare.size(), 1, 'Verify the appropriate share was created.');

                // Create Agent Roles for duplicate Test
                agentRoles = new List<AgentRole__c>();

                agentRole = new AgentRole__c(Customer__c=customerWithHH.Id, Agent__c = agentUser.id,Primary_Household__c=householdAccount.Id);
                agentRoles.add(agentRole);

                AgentRole__c agentRole2 = new AgentRole__c(Customer__c=customerWithHH.Id, Agent__c = agentUser.id,Primary_Household__c=householdAccount.Id);
                agentRoles.add(agentRole2);

                insert agentRoles;

                // Add Data to agent Role Data Object and call add method.
                agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
                UTIL_HouseholdAccountShares.createHouseholdShares(agentRoleData);

                // Verify that a share was created for the household account using the correct agent proxy.
                householdAccountShare = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy.Id AND RowCause = 'Manual'];

                System.assertEquals(householdAccountShare.size(), 1, 'Duplicate shares were created.');

            }
    
            Test.stopTest();

    }
    
    /**
     * @description I have a household account with single member (customer account) having a single relation with Agent. In this situation, 
     * Account Share is created between Agent and Household account. If i remove the Agent Role, respective Account Share with household
     * should be deleted.
     */
    @isTest
    private static void testDeleteHouseholdShareHouseholdHavingSingleMember() { 
         //Toggle Household_shares set to true
         UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);

         // Create System Admin
         User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
         insert systemAdmin;

         Test.startTest();

         System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = TestDataFactory_HouseholdAccountShares.setupHouseholdWithOnlyOneCustomer();

            List<AccountShare> initialShareCount = [SELECT id FROM AccountShare WHERE RowCause = 'Manual'];
            Integer expectedShareCount = initialShareCount.size() - 1;//only a share delete

            // Format data and call utility method to delete shares
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_HouseholdAccountShares.deleteHouseholdAccountShares(agentRoleData);
   
            // In this case the expected share count should be one less then the initial.
            List<AccountShare> updatedShareCount = [SELECT id FROM AccountShare WHERE RowCause = 'Manual'];
            System.assertEquals(expectedShareCount, updatedShareCount.size(), 'Failed to delete the appropriate number of shares.');

         }

         Test.stopTest();
        
    }
    
    /**
     * @description I have a household account with multiple members (customer account) having a different Agents. In this situation, 
     * Account Shares are created between all agents and Household account. If i remove the Agent Role such that a agent doesn't have any relation with 
     * other customers, respective Account Share with household should be deleted.
     */
    @isTest
    private static void testDeleteHouseholdShareHouseholdHavingMultipleCustomerWithDifferentAgents() { 
         //Toggle Household_shares set to true
         UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);

         // Create System Admin
         User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
         insert systemAdmin;

         Test.startTest();

         System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = TestDataFactory_HouseholdAccountShares.setupHouseholdWithThreeCustomers();

            List<AccountShare> initialShareCount = [SELECT id FROM AccountShare WHERE RowCause = 'Manual'];
            Integer expectedShareCount = initialShareCount.size() - 1;// only a share delete

            // Format data and call utility method to delete shares
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_HouseholdAccountShares.deleteHouseholdAccountShares(agentRoleData);
   
            // In this case the expected share count should be one less then the initial.
            List<AccountShare> updatedShareCount = [SELECT id FROM AccountShare WHERE RowCause = 'Manual'];
            System.assertEquals(expectedShareCount, updatedShareCount.size(), 'Failed to delete the appropriate number of shares.');

         }

         Test.stopTest();
        
    }
    
    /**
     * @description I have a household account with multiple members (customer account) having a different or same Agents. In this situation, 
     * Account Shares are created between all agents and Household account. If i remove the Agent Role such that an agent having a relation with 
     * other customers, respective Account Share with household should not be deleted.
     */
    @isTest
    private static void testRemoveHouseholdSharesHouseholdWithMultipleCustomerWithSameAgents() { 
         //Toggle Household_shares set to true
         UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);

         // Create System Admin
         User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
         insert systemAdmin;

         Test.startTest();

         System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = TestDataFactory_HouseholdAccountShares.setupHouseholdWithTwoCustomers();

            List<AccountShare> initialShareCount = [SELECT id FROM AccountShare WHERE RowCause = 'Manual'];
            Integer expectedShareCount = initialShareCount.size() - 0;//No share delete

            // Format data and call utility method to delete shares
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_HouseholdAccountShares.deleteHouseholdAccountShares(agentRoleData);
   
            // In this case the expected share count should be one less then the initial.
            List<AccountShare> updatedShareCount = [SELECT id FROM AccountShare WHERE RowCause = 'Manual'];
            System.assertEquals(expectedShareCount, updatedShareCount.size(), 'Failed to delete the appropriate number of shares.');

         }

         Test.stopTest();
        
    }

    /**
     * @description I have multiple household accounts with multiple members (customer account) having a different or same Agents. In this situation, 
     * Account Shares are created between all agents and Household accounts. If i remove the Agent Role such that an agent having a relation with 
     * other customers, respective Account Share with household should not be deleted.
     * If i remove the Agent Role such that agent(s) having no relationship with other customer(s) in same or different household(s),
     * respective Account Shares with household should be deleted.
     * If i remove the Agent Role such household have only one member (customer), respective Account Shares with household
     * should be deleted.
     */
    @isTest
    private static void testDeleteHouseholdSharesWithBulkData() { 
         //Toggle Household_shares set to true
         UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);

         // Create System Admin
         User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
         insert systemAdmin;

         Test.startTest();

         System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = TestDataFactory_HouseholdAccountShares.setupHouseholdsWithBulkCustomersAndAgents();

            List<AccountShare> initialShareCount = [SELECT id FROM AccountShare WHERE RowCause = 'Manual'];
            Integer expectedShareCount = initialShareCount.size() - 3;// three shares delete

            // Format data and call utility method to delete shares
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_HouseholdAccountShares.deleteHouseholdAccountShares(agentRoleData);
   
            // In this case the expected share count should be one less then the initial.
            List<AccountShare> updatedShareCount = [SELECT id FROM AccountShare WHERE RowCause = 'Manual'];
            System.assertEquals(expectedShareCount, updatedShareCount.size(), 'Failed to delete the appropriate number of shares.');

         }

         Test.stopTest();
        
    }

    /**
     * @description We will attempt to create share when toggle is off to verify insert share code should not work.
     */
    @isTest
    private static void testInsertHouseholdShareAttempt() { 
         //Toggle Household_shares set to false
         UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, false);
         // Create System Admin
         User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
         insert systemAdmin;

         Test.startTest();

         System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = new List<AgentRole__c>();
            agentRoles = TestDataFactory_HouseholdAccountShares.setupHouseholdWithOnlyOneCustomer();

            List<AccountShare> actualShareCount = [SELECT id FROM AccountShare WHERE RowCause = 'Manual'];
            System.assertEquals(0, actualShareCount.size(), 'Negative test: insert the appropriate number of shares.');

         }

         Test.stopTest();   
    }
    
    /**
     * @description We will attempt to delete share when toggle is off to verify delete share code should not work.
     */
    @isTest
    private static void testDeleteHouseholdShareAttempt() { 
         //Toggle Household_shares set to true
         UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
         // Create System Admin
         User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
         insert systemAdmin;

         Test.startTest();

         System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = TestDataFactory_HouseholdAccountShares.setupHouseholdWithOnlyOneCustomer();

            List<AccountShare> initialShareCount = [SELECT id FROM AccountShare WHERE RowCause = 'Manual'];
            System.assertEquals(1, initialShareCount.size(), 'Failed to insert the appropriate number of shares.');
            
           	// Format data and call utility method to delete shares before calling set toggle to OFF
           	UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, false);
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_HouseholdAccountShares.deleteHouseholdAccountShares(agentRoleData);
   
            // In this case the expected share count should be one less then the initial.
            List<AccountShare> updatedShareCount = [SELECT id FROM AccountShare WHERE RowCause = 'Manual'];
            System.assertEquals(initialShareCount.size(), updatedShareCount.size(), 'Negative test: delete the appropriate number of shares.');

         }

         Test.stopTest();
        
    }


}
