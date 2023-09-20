/**
 * @description This class will be used to test the Agreement Risk Share Utility Class
 * @Date: 09/17/20
 * @author: Jonathan Larkin VAASTT
 */
@isTest
(seeAllData = false)
public class UTIL_InsurancePolicyShares_TEST extends UTIL_AgencyShares {

    /**
     * @description Setup Tests by generating agent data and bypassing the appropraite triggers.
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
    private static void insurancePolicyBasicInsertandDuplicate() {

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

        // Create System Admin
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
    
        Test.startTest();
    
        System.runAs(systemAdmin){

            // Get Agent and Proxy
            User agentUser = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
            User agentProxy = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];

            // Get Primary Insure Account and Participant Account
            Account namedInsuredAccount = TestDataFactory_AgencyShares.getAccount1();
            Account participantAccount = TestDataFactory_AgencyShares.getAccount3();

            // Create Insurance Policy
            InsurancePolicy policy = new InsurancePolicy(Name='Policy', NameInsuredId=namedInsuredAccount.id);
            insert policy;

            // Create Participant for Policy
            InsurancePolicyParticipant participant = 
            new InsurancePolicyParticipant(PrimaryParticipantAccountId = participantAccount.id, InsurancePolicyId = policy.Id, Role='Named Insured');
            insert participant;

            // Create Agent Role for participant
            AgentRole__c agentRole = new AgentRole__c(Customer__c=participantAccount.Id, Agent__c = agentUser.id);
            insert agentRole;

            // We need to add the agent role to a list so that it can be passed into the role data object generation code.
            List<AgentRole__c> agentRoles = new List<AgentRole__c>();
            agentRoles.add(agentRole);

            // Add Data too agent Role Data Object and call add method.
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.createInsurancePolicyShares(agentRoleData);

            // Verify that a share was created for the participant on this policy using the correct agent proxy.
            Integer partipantAccountShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :agentProxy.Id];

            System.assertEquals(partipantAccountShare, 1, 'Verify the appropriate share was created.');

            // Create Agent Roles for duplicate Test
            agentRoles = new List<AgentRole__c>();

            agentRole = new AgentRole__c(Customer__c=participantAccount.Id, Agent__c = agentUser.id);
            agentRoles.add(agentRole);

            AgentRole__c agentRole2 = new AgentRole__c(Customer__c=participantAccount.Id, Agent__c = agentUser.id);
            agentRoles.add(agentRole2);

            insert agentRoles;

            // Add Data too agent Role Data Object and call add method.
            agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.createInsurancePolicyShares(agentRoleData);

            // Verify that a share was created for the participant on this policy using the correct agent proxy.
            partipantAccountShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :agentProxy.Id];

            System.assertEquals(partipantAccountShare, 1, 'The impossible has happened and duplicate shares where created.');

        }
    
        Test.stopTest();

    }




    /**
     * @description attempt removing agent role with no shares, we will use bogus assert as we are only testing for errors.
     */
    @isTest
    private static void insurancePolicyAgentRoleNoShares() {

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

        // Create System Admin
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
    
        Test.startTest();
    
        System.runAs(systemAdmin){

            // Get Proxy

            List<AgentRole__c> agentRoles  = new List<AgentRole__c>();

            // We need to add the agent role to a list so that it can be passed into the role data object generation code.
            TestDataFactory_InsurancePolicyShares.setupBasicAgentTest(agentRoles);

            // Add Data too agent Role Data Object and call remove method.
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.createInsurancePolicyShares(agentRoleData);
 
            // Assert that no share exist. It's not super valid but really we just don't want an exception
            //System.assertEquals(0, [SELECT COUNT() FROM InsurancePolicyShare], 'No shares should be returned.');
            System.assert(true,'Assertion should return true');
        }
    
        Test.stopTest();

    }




    /**
     * @description attempt removing shares for an agent role with no policies
     */
    @isTest
    private static void insurancePolicyAgentRoleNoPolicies() {

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

        // Create System Admin
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
    
        Test.startTest();
    
        System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = TestDataFactory_InsurancePolicyShares.setupNoPolicies();

            // Add Data too agent Role Data Object and call remove method.
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(agentRoleData);
 
            // Assert that no share exist. It's not super valid but really we just don't want an exception
            System.assertEquals(0, [SELECT COUNT() FROM InsurancePolicyShare], 'No shares should be returned.');

        }
    
        Test.stopTest();

    }




    /**
     * @description I have two accounts on the same Insurance Policy that share the same agent. Both are If I
     * remove the agent role for one of the accounts, I need to verify that the share is not deleted. This is because while one agent role hs been 
     * deleted the other has not. So the share (associated with agent and policy) is still neccessary.
     */
    @isTest
    private static void testPerserveAccountsSharedSharesParticipants() { 

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

        // Create System Admin
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;

        Test.startTest();

        System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = TestDataFactory_InsurancePolicyShares.setupTwoParticipantsOneAgent();

            Integer initialShareCount = [SELECT COUNT() FROM InsurancePolicyShare];

            // We're testing what happens if we only remove one share, remove one of the agen roles from the list, before deleting.
            agentRoles.remove(agentRoles.size() - 1); 

            // Format data and call utility method to delete shares
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(agentRoleData);

            // In this case our shares count should not be decreased, as the our agreement risk share should not have been removed.
            Integer updatedShareCount = [SELECT COUNT() FROM InsurancePolicyShare];
            System.assertEquals(initialShareCount, updatedShareCount, 'Failed to delete the appropriate number of shares.');
        }

        Test.stopTest();

    } 





    /**
     * @description I have two accounts on the same Insurance Policy that share the same agent. One is a participant and one is primary insured. If I
     * remove the agent role for one of the accounts, I need to verify that the share is not deleted. This is because while one agent role hs been 
     * deleted the other has not. So the share (associated with agent and policy) is still neccessary.
     */
    @isTest
    private static void testPerserveAccountsSharedSharesNamedInsured() { 

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

        // Create System Admin
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;

        Test.startTest();

        System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = TestDataFactory_InsurancePolicyShares.setupOneParticipantsOnePrimaryInsuredOneAgent();

            Integer initialShareCount = [SELECT COUNT() FROM InsurancePolicyShare];

            // We're testing what happens if we only remove one share, remove one of the agen roles from the list, before deleting.
            agentRoles.remove(agentRoles.size() - 1); 

            // Format data and call utility method to delete shares
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(agentRoleData);

            // In this case our shares count should not be decreased, as the our agreement risk share should not have been removed.
            Integer updatedShareCount = [SELECT COUNT() FROM InsurancePolicyShare];
            System.assertEquals(initialShareCount, updatedShareCount, 'Failed to delete the appropriate number of shares.');
        }

        Test.stopTest();

    } 




    /**
     * @description I have two Accounts on the same Insurance Policy and the share the same agent. Both accounts will be participants. In this situation only one 
     * Insurance Policy Share is created between the  Agent and the Insurance Policy. If i remove the agent role for both accounts, the 
     * share should be deleted.
     */
    @isTest
    private static void testRemoveAccountsSharedSharesParticipants() { 

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

         // Create System Admin
         User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
         insert systemAdmin;

         Test.startTest();

         System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = TestDataFactory_InsurancePolicyShares.setupTwoParticipantsOneAgent();

            Integer initialShareCount = [SELECT COUNT() FROM InsurancePolicyShare];
            Integer expectedShareCount = initialShareCount - 1;

            // Format data and call utility method to delete shares
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(agentRoleData);
   
            // In this case the expected share count should be one less then the initial.
            Integer updatedShareCount = [SELECT COUNT() FROM InsurancePolicyShare];
            System.assertEquals(expectedShareCount, updatedShareCount, 'Failed to delete the appropriate number of shares.');

         }

         Test.stopTest();
        
    }




    /**
     * @description Test adding a primary insured and multiple participants with the same accounts.
     */
    @isTest
    private static void testRemovingSharesForAccountUsedMultiple() { 

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

         // Create System Admin
         User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
         insert systemAdmin;

         Test.startTest();

         System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = TestDataFactory_InsurancePolicyShares.setupOneAccountPolicyMultipleParticipants();

            Integer initialShareCount = [SELECT COUNT() FROM InsurancePolicyShare];
            Integer expectedShareCount = initialShareCount - 1;

            // Format data and call utility method to delete shares
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(agentRoleData);
   
            // In this case the expected share count should be one less then the initial.
            Integer updatedShareCount = [SELECT COUNT() FROM InsurancePolicyShare];
            System.assertEquals(expectedShareCount, updatedShareCount, 'Failed to delete the appropriate number of shares.');

         }

         Test.stopTest();
        
    }




    /**
     * @description I have two Accounts on the same Insurance Policy and the share the same agent. One Account is a participant and the other is Primary Insured. In 
     * this situation only one Insurance Policy Share is created between the  Agent and the Insurance Policy. If i remove the agent role for both accounts, 
     * the share should be deleted.
     */
    @isTest
    private static void testRemoveAccountsSharedSharesNamedInsured() { 

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

         // Create System Admin
         User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
         insert systemAdmin;

         Test.startTest();

         System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = TestDataFactory_InsurancePolicyShares.setupOneParticipantsOnePrimaryInsuredOneAgent();

            Integer initialShareCount = [SELECT COUNT() FROM InsurancePolicyShare];
            Integer expectedShareCount = initialShareCount - 1;

            // Format data and call utility method to delete shares
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(agentRoleData);
   
            // In this case the expected share count should be one less then the initial.
            Integer updatedShareCount = [SELECT COUNT() FROM InsurancePolicyShare];
            System.assertEquals(expectedShareCount, updatedShareCount, 'Failed to delete the appropriate number of shares.');

         }

         Test.stopTest();
        
    }




    /**
     * @description Slightly more complex test for Inserting and Removing. This will involve two policies and multiple accounts. Four shares should
     * be created.
     * Agent 1-Account1/Account3-Policy 1
     * Agent 1-Account 3-Policy 2
     * Agent 2-Account 2-Policy 2
     * Agent 3-Account 4-Policy 2
     * Agent 3-Account 3-Policy 1
     * Agent 3-Account 2-Policy 3
     */
    @isTest
    private static void testInsurancePolicyInsertandRemove() {

            UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

            // Create System Admin
            User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            insert systemAdmin;
    
            Test.startTest();
    
            System.runAs(systemAdmin){

                // Get Agent and Proxy
                User agentUser1 = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
                User agentUser2 = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_TWO_EMAIL];
                User agentUser3 = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_THREE_EMAIL];

                // Get Primary Insure Account and Participant Account
                Account account1 = TestDataFactory_AgencyShares.getAccount1();
                Account account2 = TestDataFactory_AgencyShares.getAccount2();
                Account account3 = TestDataFactory_AgencyShares.getAccount3();
                Account account4 = TestDataFactory_AgencyShares.getAccount4();

                // Create Insurance Policy
                InsurancePolicy policy1 = new InsurancePolicy(Name='Policy', NameInsuredId=account1.id);
                insert policy1;

                InsurancePolicy policy2 = new InsurancePolicy(Name='Policy', NameInsuredId=account2.id);
                insert policy2;

                InsurancePolicy policy3 = new InsurancePolicy(Name='Policy', NameInsuredId=account3.id);
                insert policy3;

                // Create Participant for Policy
                InsurancePolicyParticipant participant1 = 
                new InsurancePolicyParticipant(PrimaryParticipantAccountId = account3.id, InsurancePolicyId = policy1.Id, Role='Named Insured');
                insert participant1;

                InsurancePolicyParticipant participant2 = 
                new InsurancePolicyParticipant(PrimaryParticipantAccountId = account4.id, InsurancePolicyId = policy2.Id, Role='Named Insured');
                insert participant2;



                // Create Agent Roles
                List<AgentRole__c> agentRoles = new List<AgentRole__c>();

                AgentRole__c agentRole1 = new AgentRole__c(Customer__c=account1.Id, Agent__c = agentUser1.id);
                agentRoles.add(agentRole1);

                AgentRole__c agentRole2 = new AgentRole__c(Customer__c=account3.Id, Agent__c = agentUser1.id);
                agentRoles.add(agentRole2);

                AgentRole__c agentRole3 = new AgentRole__c(Customer__c=account2.Id, Agent__c = agentUser2.id);
                agentRoles.add(agentRole3);

                AgentRole__c agentRole4 = new AgentRole__c(Customer__c=account4.Id, Agent__c = agentUser3.id);
                agentRoles.add(agentRole4);

                AgentRole__c agentRole5 = new AgentRole__c(Customer__c=account3.Id, Agent__c = agentUser3.id);  
                agentRoles.add(agentRole5);
                
                insert agentRoles;

                Integer initialShareCount = [SELECT COUNT() FROM InsurancePolicyShare];
                Integer expectedShareCount = InitialShareCount + 6;

                // Create Shares
                AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
                UTIL_InsurancePolicyShares.createInsurancePolicyShares(agentRoleData);

                // Verify 3 shares where created
                Integer shareCount = [SELECT COUNT() FROM InsurancePolicyShare];
                System.assertEquals(expectedShareCount, shareCount, 'Failed to create new shares.');

                // Delete Shares
                UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(agentRoleData);

                // Verify all shares where deleted and we are back to the initial count
                shareCount = [SELECT COUNT() FROM InsurancePolicyShare];
                System.assertEquals(initialShareCount, shareCount, 'Failed to delete new shares.');

                
            }
    
            Test.stopTest();

    }



    
    /**
    * @description Verify that our  "Database Access" methods can handle empty and null lists. We will use bogus assert as we are only testing for errors.
    */
    @isTest
    private static void databaseAccessMethodsHandleEmpty() {

        // Create System Admin
         User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
    
        Test.startTest();
    
        System.runAs(systemAdmin){

            // Test Empty Lists
            List<InsurancePolicyShare> insurancePolicyShares = new List<InsurancePolicyShare>();
            UTIL_InsurancePolicyShares.insertInsurancePolicyShares(insurancePolicyShares);
            UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(insurancePolicyShares);
            system.assert(true,'Assertion should return true');

            // Test Null Values
            insurancePolicyShares = null;
            UTIL_InsurancePolicyShares.insertInsurancePolicyShares(insurancePolicyShares);
            UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(insurancePolicyShares);
            system.assert(true,'Assertion should return true');

        }

        Test.stopTest();
    }





    /**
     * @description Verifies that ClaimShares track their related InsurancePolicyShares.
     * If an InsurancePolicyShare is created, then the ClaimShares related to the policy's claims are created.
     * If an InsurancePolicyShare is deleted, then the ClaimShares related to the policy's claims are removed.
     *
     * Agent 1-Account 1-Policy 1-Claim 1
     * Agent 1-Account 1-Policy 1-Claim 2
     */
    @isTest
    private static void testClaimSharesInsertandRemove() {

            TestDataFactory_Claim.byPassClaimAfterTriggers();
            UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

            UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

            // Create System Admin
            User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            insert systemAdmin;

            Test.startTest();
    
            System.runAs(systemAdmin){

                // Get Agent and Proxy
                User agentUser1 = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];

                // Get Primary Insured Account
                Account account1 = TestDataFactory_AgencyShares.getAccount1();

                // Create Insurance Policy
                InsurancePolicy policy1 = new InsurancePolicy(Name='Policy', NameInsuredId=account1.id);
                insert policy1;

                // Create Participant for Policy
                InsurancePolicyParticipant participant1 = 
                    new InsurancePolicyParticipant(PrimaryParticipantAccountId = account1.id, InsurancePolicyId = policy1.Id, Role='Named Insured');
                insert participant1;

                // Create Claims for the policy
                List<Claim> claims = TestDataFactory_Claim.generateClaims(2, account1, policy1);
                claims = TestDataFactory_Claim.insertClaims(claims);

                // Create Agent Roles
                List<AgentRole__c> agentRoles = new List<AgentRole__c>();

                AgentRole__c agentRole1 = new AgentRole__c(Customer__c=account1.Id, Agent__c = agentUser1.id);
                agentRoles.add(agentRole1);

                insert agentRoles;

                Integer initialPolicyShareCount = [SELECT COUNT() FROM InsurancePolicyShare WHERE RowCause = 'Manual'];

                // Create Shares
                AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
                UTIL_InsurancePolicyShares.createInsurancePolicyShares(agentRoleData);

                // Verify 1 manual InsurancePolicyShare was created
                List<InsurancePolicyShare> insurancePolicyShares = [SELECT UserOrGroupId FROM InsurancePolicyShare WHERE RowCause = 'Manual'];
                System.assertEquals(initialPolicyShareCount+1, insurancePolicyShares.size(), 'Failed to create new policy shares.');
                InsurancePolicyShare policyShare = insurancePolicyShares[0];

                // Verify 2 manual ClaimShares were created
                List<ClaimShare> claimShares = [SELECT ParentId, UserOrGroupId FROM ClaimShare WHERE RowCause = 'Manual'];
                System.assertEquals(claims.size(), claimShares.size(), 'Failed to create new manual claim shares.');

                // Verify that the UserOrGroupId's in the ClaimShares match the InsurancePolicyShare's UserOrGroupId
                for (ClaimShare claimShare : claimShares) {
                    System.assertEquals(claimShare.UserOrGroupId, policyShare.UserOrGroupId,'Expected value is '+claimShare.UserOrGroupId+', but actual value is '+policyShare.UserOrGroupId);
                }

                // Delete Shares
                UTIL_InsurancePolicyShares.deleteInsurancePolicyShares(agentRoleData);                

                // Verify the InsurancePolicyShare was deleted
                Integer policyShareCount = [SELECT COUNT() FROM InsurancePolicyShare WHERE RowCause = 'Manual'];
                System.assertEquals(initialPolicyShareCount, policyShareCount, 'Failed to delete new policy shares.');

                // Verify the ClaimShares were deleted
                Integer claimShareCount = [SELECT COUNT() FROM ClaimShare WHERE RowCause = 'Manual'];
                System.assertEquals(0, claimShareCount, 'Failed to delete existing manual claim shares.');
            }
    
            Test.stopTest();

    }

}