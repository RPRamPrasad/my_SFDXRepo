/**
 * @description This is a temporary class that will test when the Insurance Policy Toggle is turned off. Once we decide
 * we no longer need then we can delete this class. Stole the idea of having a seperate class from Mike Hambleton. I like
 * that it keeps things seperate.
 * @Date: 04/15/21
 * @author: Jonathan Larkin VAASTT
 */
@isTest
(seeAllData = false)
public class UTIL_InsurancePolicyShares_Off_TEST extends UTIL_AgencyShares {

    /**
     * @description Setup Tests by generating agent data and bypassing the appropriate triggers.
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
     * @description Start with testing the create method, we'll attempt to add a share and verify with the toggle off
     * it is not created.
     */
    @isTest
    private static void insurancePolicyBasicInsertAttempt() {

        // Set toggle too false for this test
        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, false);

        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
    
        Test.startTest();
    
        System.runAs(systemAdmin){

            // Get Proxy for testing purposes
            User agentProxy = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];

            // Create Data for test
            List<AgentRole__c> agentRoles = new List<AgentRole__c>();
            InsurancePolicy policy =TestDataFactory_InsurancePolicyShares.setupBasicAgentTest(agentRoles);

            // Add Data to agent Role Data Object and call add method.
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.createInsurancePolicyShares(agentRoleData);

            // Verify that a share was created for the participant on this policy using the correct agent proxy.
            Integer partipantAccountShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :agentProxy.Id];

            System.assertEquals(0, partipantAccountShare, 'Verify the appropriate share was created.');

        }
    
        Test.stopTest();

    }




    /**
     * @description verify delete is disabled for method taking Agent Role Data.
     */
    @isTest
    private static void insurancePolicyDeleteByAgentRoleData() {

        // Toggle on Insurance Policies temporarily so that we can create a policy before we test that the delete code is offline
        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
    
        Test.startTest();
    
        System.runAs(systemAdmin){

            User agentProxy = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];

            // Create Data For Test
            List<AgentRole__c> agentRoles = new List<AgentRole__c>();
            InsurancePolicy policy =TestDataFactory_InsurancePolicyShares.setupBasicAgentTest(agentRoles);

            // Insert Data for Test and verify it was created
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.createInsurancePolicyShares(agentRoleData);

            Integer partipantAccountShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :agentProxy.Id];
            System.assertEquals(1, partipantAccountShare, 'Verify the appropriate share was created.');

            // Turn off toggle so we can verify that no policies are deleted
            UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, false);

            // Delete Insurance Shares and verify that none where deleted with toggle off.
            UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(agentRoleData);

            partipantAccountShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :agentProxy.Id];
            System.assertEquals(1, partipantAccountShare, 'Verify not deleted share was created.');
     
        }
    
        Test.stopTest();

    }




    /**
     * @description verify delete is disabled for method taking Policy ID.
     */
    @isTest
    private static void insurancePolicyDeleteByPolicyId() {

         // Toggle on Insurance Policies temporarily so that we can create a policy before we test that the delete code is offline
        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
    
        Test.startTest();
    
        System.runAs(systemAdmin){

            User agentProxy = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];

            // Create Data For Test
            List<AgentRole__c> agentRoles = new List<AgentRole__c>();
            InsurancePolicy policy =TestDataFactory_InsurancePolicyShares.setupBasicAgentTest(agentRoles);

            // Insert Data for Test and verify it was created
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.createInsurancePolicyShares(agentRoleData);

            Integer partipantAccountShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :agentProxy.Id];
            System.assertEquals(1, partipantAccountShare, 'Verify the appropriate share was created.');

            // Turn off toggle so we can verify that no policies are deleted
            UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, false);

            //  Create List of Insurance Policies that we can pass into the delete shares by Policy ID method..
            Set<Id> insurancePolicies = new Set<Id>();
            insurancePolicies.add(policy.Id);

            // Delete Insurance Shares and verify that none where deleted with toggle off.
            UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(insurancePolicies);

            partipantAccountShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :agentProxy.Id];
            System.assertEquals(1, partipantAccountShare, 'Verify not deleted share was created.');
     
        }
    
        Test.stopTest();

    }




    /**
     * @description verify delete is disabled for method taking Insurance Policy using Policy ID and Proxy.
     */
    @isTest
    private static void insurancePolicyDeleteByPolicyIdAndProxy() {

         // Toggle on Insurance Policies temporarily so that we can create a policy before we test that the delete code is offline
        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
    
        Test.startTest();
    
        System.runAs(systemAdmin){

            User agentProxy = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];

            // Create Data For Test
            List<AgentRole__c> agentRoles = new List<AgentRole__c>();
            InsurancePolicy policy =TestDataFactory_InsurancePolicyShares.setupBasicAgentTest(agentRoles);

            // Insert Data for Test and verify it was created
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.createInsurancePolicyShares(agentRoleData);

            Integer partipantAccountShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :agentProxy.Id];
            System.assertEquals(1, partipantAccountShare, 'Verify the appropriate share was created.');

            // Turn off toggle so we can verify that no policies are deleted
            UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, false);

            // Create List of Insurance Policy and Agent Proxy Id's that we can pass into the delete shares method.
            Set<Id> insurancePolicies = new Set<Id>();
            insurancePolicies.add(policy.Id);

            List<Id> agentProxies = new List<Id>();
            agentProxies.add(agentProxy.Id);

            // Delete Insurance Shares and verify that none where deleted with toggle off.
            UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(insurancePolicies, agentProxies);

            partipantAccountShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :agentProxy.Id];
            System.assertEquals(1, partipantAccountShare, 'Verify not deleted share was created.');
     
        }
    
        Test.stopTest();

    }

}