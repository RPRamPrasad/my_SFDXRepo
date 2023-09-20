/**
* @Author Team Impact Force
* @Owner Team Stark
* @name UTIL_AgentRoleDAO_Test
* @CreateDate 10/6/2016
* @description This test class provides test coverage for UTIL_AgentRoleDAO class.
* @Version : 1.0
*/
@isTest(SeeAllData = false)
private class UTIL_AgentRoleDAO_TEST {

    private static Integer countOfAgentRoleBefore = [SELECT count() FROM AgentRole__c];
    private static AgentRole__c agr;
    private static User runAsUser;
    private static Account customerAcc;
    private static User agentUser;
    
    @testsetup
    private static void testSetupData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;  
    }
    //Setup the executing user
    private static User setupRunAsUser() {
        User systemUserTemp = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemUserTemp;
        CS001_ByPassTriggerAll__c bypassTriggerAll = new CS001_ByPassTriggerAll__c();
        bypassTriggerAll.Override_All__c = true;
        bypassTriggerAll.SetupOwnerId = systemUserTemp.id;
        insert bypassTriggerAll;
        return systemUserTemp;
    }
    //Setup the executing user
    private static User setupAgentUser() {
        User testAgentUser1 = new User(Alias='agen',LastName='testagroledaoLName',Username='testAgRoDaoTest@statefarm.com.bad',Associate_ID__c='testagdao',UserExternalID__c='testagdao',Servicing_Agent_Associate_ID__c='testagdao');
        agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
        insert agentUser;
        CS001_ByPassTriggerAll__c bypassTriggerAll = new CS001_ByPassTriggerAll__c();
        bypassTriggerAll.Override_All__c = true;
        bypassTriggerAll.SetupOwnerId = agentUser.id;
        insert bypassTriggerAll;
        return agentUser;
    }
    //Setup the customer Account
    private static Account setupCustomerAccount() {
        Account acc = new Account(FirstName = 'testUtilAgrDAOFName', LastName = 'testUtilAgrDAOLName',ClientIdentifier__c = 'SFFSP81L8XB');
        insert acc;
        return acc;
    }
    
    //method to assign permissionset for the given user in parameter value
    private static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }
    
    //Description: Should insert AgentRole successfully
    @isTest
    private static void testInsertAgentRoleSuccess() {
        runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        agr = new AgentRole__c(Agent__c=agentUser.Id, Customer__c=customerAcc.Id, AgentRoleIdentifier__c='agrDAOTestIdentifiier');
        
        Test.startTest();
        System.runAs(runAsUser) {
            UTIL_AgentRoleDAO.insertAgentRoles(new List<AgentRole__c>{agr});
        }    
        Test.stopTest();
        System.assertEquals(countOfAgentRoleBefore+1, [SELECT count() FROM AgentRole__c], 'Count of Agent Role: '+countOfAgentRoleBefore+1);

    }
   //Description: Should not insert AgentRole since required field (Agent__c is missing)
   @isTest
   private static void testInsertAgentRoleFailInvalidAgent() {
     runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        agr = new AgentRole__c(Customer__c=customerAcc.Id, AgentRoleIdentifier__c='agrDAOTestIdentifiier');
        
        Test.startTest();
        System.runAs(runAsUser) {
            try {
                 UTIL_AgentRoleDAO.insertAgentRoles(new List<AgentRole__c>{agr});
                 System.assert(false, 'Exception should be thrown invalid agent');
            } catch(Exception ex) {
                System.assert(true, 'Exception should be thrown invalid agent');
            }
        }    
        Test.stopTest();
        System.assertEquals(countOfAgentRoleBefore, [SELECT count() FROM AgentRole__c], 'Count of Agent Role '+countOfAgentRoleBefore);
    }
    //Description: Should not insert AgentRole since required field (Customer is missing)
    @isTest
    private static void testInsertAgentRoleFailInvalidCustomer() {
     runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        agr = new AgentRole__c(Agent__c=agentUser.Id, AgentRoleIdentifier__c='agrDAOTestIdentifiier');
        
        Test.startTest();
        System.runAs(runAsUser) {
            try {
                 UTIL_AgentRoleDAO.insertAgentRoles(new List<AgentRole__c>{agr});
                 System.assert(false, 'Exception should be thrown invalid customer acc');
            } catch(Exception ex) {
                System.assert(true, 'Exception should be thrown invalid customer acc');
            }
        }    
        Test.stopTest();
        System.assertEquals(countOfAgentRoleBefore, [SELECT count() FROM AgentRole__c], 'Count of Agent Role: '+countOfAgentRoleBefore);
    }
    //Description: Should upsert AgentRole successfully
    @isTest
    private static void testUpsertAgentRoleInsertSuccess() {
        runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        agr = new AgentRole__c(Agent__c=agentUser.Id, Customer__c=customerAcc.Id, AgentRoleIdentifier__c='agrDAOTestIdentifiier');
        
        Test.startTest();
        System.runAs(runAsUser) {
            UTIL_AgentRoleDAO.upsertAgentRoles(new List<AgentRole__c>{agr});
        }    
        Test.stopTest();
        System.assertEquals(countOfAgentRoleBefore+1, [SELECT count() FROM AgentRole__c], 'Count of Agent Role: '+countOfAgentRoleBefore+1);
    }
    //Description: Should not upsert AgentRole successfully
    @isTest
    private static void testUpsertAgentRoleInsertFailure() {
        runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        agr = new AgentRole__c(AgentRoleIdentifier__c='agrDAOTestIdentifiier');
        
        Test.startTest();
        System.runAs(runAsUser) {
            try {
                UTIL_AgentRoleDAO.upsertAgentRoles(new List<AgentRole__c>{agr});
                System.assert(false, 'Exception should be thrown missing required fields');
            } catch(Exception ex) {
                System.assert(true, 'Exception should be thrown missing required fields');
            }
        }    
        Test.stopTest();
        System.assertEquals(countOfAgentRoleBefore, [SELECT count() FROM AgentRole__c], 'Count of Agent Role: '+countOfAgentRoleBefore);
    }
    //Description: Should upsert AgentRole successfully
    @isTest
    private static void testUpsertAgentRoleUpdateSuccess() {
        runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        Test.startTest();
        System.runAs(runAsUser) {
            agr = new AgentRole__c(Agent__c=agentUser.Id, Customer__c=customerAcc.Id, AgentRoleIdentifier__c='agrDAOTestIdentifiier');
            insert agr;
            agr.AgentRoleIdentifier__c='updatedagrDaoIdentifier';
            UTIL_AgentRoleDAO.upsertAgentRoles(new List<AgentRole__c>{agr});
        }    
        Test.stopTest();
        AgentRole__c updatedAgr = [SELECT id, AgentRoleIdentifier__c, Agent__c, Customer__c FROM AgentRole__c LIMIT 1];
        System.assertEquals('updatedagrDaoIdentifier', updatedAgr.AgentRoleIdentifier__c, 'Agent Role Updated');
    }
    //Description: Should update AgentRole successfully
    @isTest
    private static void testUpdateAgentRoleSuccess() {
        runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        Test.startTest();
        System.runAs(runAsUser) {
             agr = new AgentRole__c(Agent__c=agentUser.Id, Customer__c=customerAcc.Id, AgentRoleIdentifier__c='agrDAOTestIdentifiier');        
            insert agr;
            agr.AgentRoleIdentifier__c='updatedagrDaoIdentifier';
            UTIL_AgentRoleDAO.updateAgentRoles(new List<AgentRole__c>{agr});
        }    
        Test.stopTest();
        AgentRole__c updatedAgr = [SELECT id, AgentRoleIdentifier__c, Agent__c, Customer__c FROM AgentRole__c LIMIT 1];
        System.assertEquals('updatedagrDaoIdentifier', updatedAgr.AgentRoleIdentifier__c, 'Agent Role Updated');
    }
   //Description: Should not update AgentRole successfully
   @isTest
    private static void testUpdateAgentRoleFailure() {
        runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        Test.startTest();
        System.runAs(runAsUser) {
            agr = new AgentRole__c(Agent__c=agentUser.Id, Customer__c=customerAcc.Id, AgentRoleIdentifier__c='agrDAOTestIdentifiier');
            insert agr;
            agr.AgentRoleIdentifier__c='updatedagrDaoIdentifier';
            UTIL_AgentRoleDAO.updateAgentRoles(null);
        }    
        Test.stopTest();
        AgentRole__c updatedAgr = [SELECT id, AgentRoleIdentifier__c, Agent__c, Customer__c FROM AgentRole__c LIMIT 1];
        System.assertEquals('agrDAOTestIdentifiier', updatedAgr.AgentRoleIdentifier__c, 'Agent Role DAO Identifier');
    }
    //Description: Should delete Agent Role successfully
    @isTest
    private static void testDeleteAgentRoleSuccess() {
        runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        Test.startTest();
        System.runAs(runAsUser) {
            agr = new AgentRole__c(Agent__c=agentUser.Id, Customer__c=customerAcc.Id, AgentRoleIdentifier__c='agrDAOTestIdentifiier');
            insert agr;
            UTIL_AgentRoleDAO.deleteAgentRoles(new List<AgentRole__c>{agr});
        }    
        Test.stopTest();
        List<AgentRole__c> deletedAgr = [SELECT id, Agent__c, Customer__c FROM AgentRole__c WHERE AgentRoleIdentifier__c='agrDAOTestIdentifiier' LIMIT 1];
        System.assert(deletedAgr.isEmpty(), 'Agent Role is empty');
        System.assertEquals(countOfAgentRoleBefore, [SELECT count() FROM AgentRole__c], 'Count of Agent Role: '+countOfAgentRoleBefore);
    }
    //Description: Should not delete Agent Role successfully
    @isTest
    private static void testDeleteAgentRoleFailure() {
        runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();
  
        Test.startTest();
        System.runAs(runAsUser) {
            agr = new AgentRole__c(Agent__c=agentUser.Id, Customer__c=customerAcc.Id, AgentRoleIdentifier__c='agrDAOTestIdentifiier');
            insert agr;
            UTIL_AgentRoleDAO.deleteAgentRoles(null);
        }    
        Test.stopTest();
        List<AgentRole__c> deletedAgr = [SELECT id, Agent__c, Customer__c FROM AgentRole__c WHERE AgentRoleIdentifier__c='agrDAOTestIdentifiier' LIMIT 1];
        System.assert(!deletedAgr.isEmpty(), 'Agent Role is not empty');
        System.assertEquals(countOfAgentRoleBefore+1, [SELECT count() FROM AgentRole__c], 'Count of Agent Role: '+countOfAgentRoleBefore+1);
    }
    //Description: Should upsert Agent Role successfully by External id
    @isTest
    private static void testUpsertAgentRoleExternalIdSuccessList() {
         runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        agr = new AgentRole__c(Agent__c=agentUser.Id, Customer__c=customerAcc.Id, AgentRoleIdentifier__c='agrDAOTestIdentifiier');
        
        Test.startTest();
        System.runAs(runAsUser) {
            UTIL_AgentRoleDAO.upsertUserAgentRoles(new List<AgentRole__c>{agr});
        }    
        Test.stopTest();
        System.assertEquals(countOfAgentRoleBefore+1, [SELECT count() FROM AgentRole__c], 'Count of Agent Role: '+countOfAgentRoleBefore+1);
    }
    //Description: Should upsert Agent Role successfully by external id
    @isTest
    private static void testUpsertAgentRoleExternalIdSuccessSingle() {
         runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        agr = new AgentRole__c(Agent__c=agentUser.Id, Customer__c=customerAcc.Id, AgentRoleIdentifier__c='agrDAOTestIdentifiier');
        
        Test.startTest();
        System.runAs(runAsUser) {
            UTIL_AgentRoleDAO.upsertUserAgentRole(agr);
        }    
        Test.stopTest();
        System.assertEquals(countOfAgentRoleBefore+1, [SELECT count() FROM AgentRole__c], 'Count of Agent Role: '+countOfAgentRoleBefore+1);
    }    
    //Description: Should Not upsert Agent Role successfully by external id
    @isTest
    private static void testUpsertAgentRoleExternalIdFailureSingle() {
         runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        agr = new AgentRole__c(Agent__c=agentUser.Id, Customer__c=customerAcc.Id);
        
        Test.startTest();
        System.runAs(runAsUser) {
            try {
                UTIL_AgentRoleDAO.upsertUserAgentRole(agr);
                System.assert(false, 'Exception should be thrown for missing agent role identifier');
            } catch(Exception ex) {
                System.assert(true, 'Exception should be thrown for missing agent role identifier');
            }
        }    
        Test.stopTest();
        System.assertEquals(countOfAgentRoleBefore, [SELECT count() FROM AgentRole__c], 'Count of Agent Role: '+countOfAgentRoleBefore);
    }
    //Description: Should Not upsert Agent Role successfully by external id
    @isTest
    private static void testUpsertAgentRoleExternalIdFailureList() {
         runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        agr = new AgentRole__c(Agent__c=agentUser.Id, Customer__c=customerAcc.Id);
        
        Test.startTest();
        System.runAs(runAsUser) {
            try {
                UTIL_AgentRoleDAO.upsertUserAgentRoles(new List<AgentRole__c>{agr});
                System.assert(false, 'Exception should be thrown for missing agent role identifier');
            } catch(Exception ex) {
                System.assert(true, 'Exception should be thrown for missing agent role identifier');
            }
        }    
        Test.stopTest();
        System.assertEquals(countOfAgentRoleBefore, [SELECT count() FROM AgentRole__c], 'Count of Agent Role: '+countOfAgentRoleBefore);
    }
    //Description: Should upsert AgentRole successfully
    @isTest
    private static void testUpsertAgentRoleExternalIdUpdateSuccess() {
        runAsUser = setupRunAsUser();
        agentUser = setupAgentUser();
        customerAcc = setupCustomerAccount();

        Test.startTest();
        System.runAs(runAsUser) {
            agr = new AgentRole__c(Agent__c=agentUser.Id, Customer__c=customerAcc.Id, AgentRoleIdentifier__c='agrDAOTestIdentifiier', RelationshipNature__c='Customer');
            insert agr;
            agr.RelationshipNature__c='Prospect';
            UTIL_AgentRoleDAO.upsertUserAgentRoles(new List<AgentRole__c>{agr});
        }    
        Test.stopTest();
        AgentRole__c updatedAgr = [SELECT id, AgentRoleIdentifier__c, Agent__c, Customer__c, RelationshipNature__c FROM AgentRole__c WHERE AgentRoleIdentifier__c='agrDAOTestIdentifiier' LIMIT 1];
        System.assertEquals('Prospect', updatedAgr.RelationshipNature__c, 'Relationship Nature is Prospect');
    }
}