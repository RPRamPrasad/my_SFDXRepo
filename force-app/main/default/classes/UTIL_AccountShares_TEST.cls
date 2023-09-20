/**
 * @description This class will be used to test the Agreement Risk Share Utility Class
 * @Date: 09/17/20
 * @author: Kalen Wood-Wardlow/Jonathan Larkin
 */
@isTest
(seeAllData = false)
public class UTIL_AccountShares_TEST extends UTIL_AgencyShares{

    /**
    * @description Setup method used for building test data (must be called at beginning of test)
    */
    @testsetup
    public static void testSetupData() {

        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        TestDataFactory_AgencyShares.createDataForSharesTesting();
    }    
    
    /**
    * @description Account Share, Insert, Delete
    */
    @isTest
    public static void testAccountShareInsertAndDelete() {

        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('1701B','systemAdmin','systemAdminTest@statefarm.com'); 

        Test.startTest();

        System.RunAs(systemAdmin) {

            // Select agent roles only the three we created should exist.
            List<AgentRole__c> agentRoles = [SELECT id, Customer__c, Agent__c, Primary_Household__c FROM AgentRole__c];
            System.assertEquals(TestDataFactory_AgencyShares.AGENT_ROLE_COUNT, agentRoles.size(), 'List of size is not matching');

            /**************************** Add Accounts ****************************/
            Integer initialAccountShareCount = [SELECT COUNT() FROM AccountShare];
            Integer initialCaseCount = [SELECT COUNT() FROM Case];
            System.assertEquals(initialCaseCount, 2, 'Case count is not matching');
            
            // Use Agent Role Data object to limit parameters
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
  
            UTIL_AccountShares.createAccountShares(agentRoleData);

            Integer accountAccountShareCount = [SELECT COUNT() FROM AccountShare];
            Integer updatedCaseCount = [SELECT COUNT() FROM CaseShare];

            System.assertEquals(initialAccountShareCount + agentRoles.size(), accountAccountShareCount, 'Account share count is not matching');
            System.assertEquals(initialCaseCount + 2, updatedCaseCount, 'List of size is not matching');

            List<AccountShare>  accountShares = [ SELECT accountId, UserOrGroupId 
                FROM AccountShare 
                WHERE accountId=:agentRoles.get(0).Customer__c 
                AND UserOrGroupId=:agentRoleData.agentToProxyIds.get(agentRoles.get(0).Agent__c)
            ];

            System.assertEquals(1, accountShares.size(), 'List of records is not matching');

            /**************************** Delete Accounts ****************************/
            UTIL_AccountShares.deleteAccountShares(agentRoleData);

            accountAccountShareCount = [SELECT COUNT() FROM AccountShare];
            System.assertEquals(initialAccountShareCount, accountAccountShareCount, 'Count is not matching');

            accountShares = [SELECT accountId, UserOrGroupId 
                FROM AccountShare 
                WHERE accountId=:agentRoles.get(0).Customer__c 
                AND UserOrGroupId=:agentRoleData.agentToProxyIds.get(agentRoles.get(0).Agent__c)
            ];
            
            System.assert(accountShares.isEmpty(), 'Account Share is not empty');
        }

        Test.stopTest();

    }




    /**
    * @description Account Share, Insert, Delete
    */
    @isTest
    public static void agentRoleNoShares() {

        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('1701B','systemAdmin','systemAdminTest@statefarm.com'); 

        Test.startTest();

        System.RunAs(systemAdmin) {

            // Select agent roles only the three we created should exist.
            List<AgentRole__c> agentRoles = [SELECT id,Customer__c, Agent__c, Primary_Household__c FROM AgentRole__c];
            
            // Use Agent Role Data object to limit parameters
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
            System.assert(agentRoleData!=null, 'agentRoleData is not empty');
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
                List<AccountShare> accountShares = new List<AccountShare>();
                UTIL_AccountShares.insertAccountShareAndLogFailures(accountShares);
                UTIL_AccountShares.deleteAccountShareAndLogFailures(accountShares);
                system.assert(true,'accountShares list is empty');

                // Test Null Values
                accountShares = null;
                UTIL_AccountShares.insertAccountShareAndLogFailures(accountShares);
                UTIL_AccountShares.deleteAccountShareAndLogFailures(accountShares);
                system.assert(true,'accountShares list is null');

            }

            Test.stopTest();
        }
}