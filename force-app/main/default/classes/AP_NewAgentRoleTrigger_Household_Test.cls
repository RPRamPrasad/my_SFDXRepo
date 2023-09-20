/** @description This is a test class for UTIL_HouseholdAccountShares.
* This class is used to test the utilitiy methods for inserts and deleting Household Account Shares as used by the Agent Role and ACR Triggers.
* @author Team Stark
* @owner Team Stark
* @createdDate 05/17/2021
*/

@isTest
(seeAllData = false)
public class AP_NewAgentRoleTrigger_Household_Test extends UTIL_AgencyShares {
    
    private static User agentUser; 
    private static final String CUSTOMER = 'Customer';
    private static final String EXCUSTOMER = 'Ex-Customer';
    private static final String PROSPECT = 'Prospect';
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
      
    /**
    * @description Setup method used for building test data
    * @name setUp
    */
    @testsetup
    public static void testSetupData() {
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,SystemUser);
        insert passTriggerAll;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;
        objectBasedByPassTrigger.Override_AgentRoleAfterDelete__c = false;
        objectBasedByPassTrigger.Override_AgentRoleAfterUpdate__c = false;
        insert objectBasedByPassTrigger;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting; 
    }
      
    /**
    * @description insert household account shares 
    * @name testAgentRoleInsertForInsurancePolicy
    */ 
    @isTest
    public static void testAgentRoleInsertForHouseholdShares(){
        //Toggle Household_shares set to true
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
  
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
            
        // get data from TestDataFactory
        TestDataFactory_AgencyShares.createDataForSharesTesting(false);
        Account householdAccount = TestDataFactory_AgencyShares.gethousehold1();
        User agentUser = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
        User agentProxy = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
            
        // create individual account manually to add primary HH
        Account individualAccount = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
        System.runAs(systemAdmin) {
            individualAccount.Primary_Household__pc = householdAccount.Id;
            insert individualAccount;
        }
     
        AgentRole__c newAgentRole = new AgentRole__c(Customer__c = individualAccount.Id, Agent__c = agentUser.Id, RelationshipNature__c = PROSPECT);
          
        Test.startTest();
            List<AccountShare> accountShareBefore = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy.Id];
            System.assertEquals(0, accountShareBefore.size(),'Household shares should be empty');    
            System.runAs(systemAdmin){
                insert newAgentRole;
            }
        Test.stopTest();
        List<AccountShare> accountShareAfter = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy.Id];
        System.assertEquals(1,accountShareAfter.size(),'Household shares should not be empty');    
    }
  
    /**
    * @description insert multiple household account shares 
    * @name testAgentRoleInsertForInsurancePolicyBulk
    */ 
    @isTest
    public static void testAgentRoleInsertForHouseholdSharesBulk(){
        //Toggle Household_shares set to true
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
  
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
          
        // get data from TestDataFactory
        TestDataFactory_AgencyShares.createDataForSharesTesting(false);
        Account householdAccount = TestDataFactory_AgencyShares.gethousehold1();
        User agentUser1 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
        User agentUser2 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_TWO_EMAIL];
        User agentProxy2 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_TWO_EMAIL];
        User agentUser3 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_THREE_EMAIL];
        User agentProxy3 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_THREE_EMAIL];
  
        Account individualAccount = new Account(FirstName='fExistingAccount',LastName='lExistingAccount',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
        System.runAs(systemAdmin){
          individualAccount.Primary_Household__pc = householdAccount.Id;
          insert individualAccount;
        }
  
        AgentRole__c existingAgentRole = new AgentRole__c(Customer__c = individualAccount.Id, Agent__c = agentUser1.Id, RelationshipNature__c = CUSTOMER);
        System.runAs(systemAdmin){
          insert existingAgentRole;
        }
  
        AgentRole__c newAgentRole1 = new AgentRole__c(Customer__c = individualAccount.Id, Agent__c = agentUser2.Id, RelationshipNature__c = PROSPECT);
        AgentRole__c newAgentRole2 = new AgentRole__c(Customer__c = individualAccount.Id, Agent__c = agentUser3.Id, RelationshipNature__c = PROSPECT);
        List<AgentRole__c> newAgentRolesList = new List<AgentRole__c>{newAgentRole1,newAgentRole2};
  
        Test.startTest();
          List<AccountShare> hhAccountShareAgent2Before = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy2.Id];
          System.assertEquals(0,hhAccountShareAgent2Before.size(),'Household share with Agent 2 should not exist');
          List<AccountShare> hhAccountShareAgent3Before = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy3.Id];
          System.assertEquals(0,hhAccountShareAgent3Before.size(),'Household share with Agent 3 should not exist');
          System.runAs(systemAdmin){
                insert newAgentRolesList;
            }
        Test.stopTest();
          List<AccountShare> hhAccountShareAgent2After = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy2.Id];
          System.assertEquals(1, hhAccountShareAgent2After.size(),'Household share with Agent 2 should exist');
          List<AccountShare> hhAccountShareAgent3After = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy3.Id];
          System.assertEquals(1, hhAccountShareAgent3After.size(),'Household share with Agent 3 should exist');
    }
      
    /**
    * @description delete household account shares 
    * @name testAgentRoleDeleteForInsurancePolicy
    */ 
    @isTest
    public static void testAgentRoleDeleteForHouseholdShares(){
        //Toggle Household_shares set to true
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
  
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        
        // get data from TestDataFactory
        TestDataFactory_AgencyShares.createDataForSharesTesting(false);
        Account householdAccount = TestDataFactory_AgencyShares.gethousehold1();
        User agentUser1 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
        User agentUser2 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_TWO_EMAIL];
        User agentProxy2 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_TWO_EMAIL];
        
        Account individualAccount = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
        System.runAs(systemAdmin) {
          individualAccount.Primary_Household__pc = householdAccount.Id;
          insert individualAccount;
        }
        
        AgentRole__c agentRole1 = new AgentRole__c(Customer__c = individualAccount.Id, Agent__c = agentUser1.Id, RelationshipNature__c = PROSPECT);
        AgentRole__c agentRole2 = new AgentRole__c(Customer__c = individualAccount.Id, Agent__c = agentUser2.Id, RelationshipNature__c = PROSPECT);
        List<AgentRole__c> agentRolesList = new List<AgentRole__c>{agentRole1,agentRole2};
        System.runAs(systemAdmin){
          insert agentRolesList;
        }
  
        Test.startTest();
          List<AccountShare> accountShareBefore = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy2.Id];
          System.assertEquals(1, accountShareBefore.size(),'Household shares should not be empty');
          System.runAs(systemAdmin){
            delete agentRole2;
          } 
        Test.stopTest();
        List<AccountShare> accountShareAfter = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy2.Id];
        System.assertEquals(0, accountShareAfter.size(),'Household shares should be empty');    
    }
  
    /**
    * @description delete multiple household account shares 
    * @name testAgentRoleDeleteForInsurancePolicyBulk
    */ 
    @isTest
    public static void testAgentRoleDeleteForHouseholdSharesBulk(){
        //Toggle Household_shares set to true
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
  
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
       
        TestDataFactory_AgencyShares.createDataForSharesTesting(false);
        Account householdAccount = TestDataFactory_AgencyShares.gethousehold1();
        User agentUser1 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
        User agentProxy1 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User agentUser2 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_TWO_EMAIL];
        User agentProxy2 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_TWO_EMAIL];
        User agentUser3 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_THREE_EMAIL];
        User agentProxy3 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_THREE_EMAIL];
        User agentUser4 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_FOUR_EMAIL];
        User agentProxy4 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FOUR_EMAIL];
        User agentUser5 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_FIVE_EMAIL];
        User agentProxy5 = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_FIVE_EMAIL];
  
        Account individualAccount = new Account(FirstName='fExistingAccount',LastName='lExistingAccount',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
        System.runAs(systemAdmin){
          individualAccount.Primary_Household__pc = householdAccount.Id;
          insert individualAccount;
        }
  
        AgentRole__c agentRole1 = new AgentRole__c(Customer__c = individualAccount.Id, Agent__c = agentUser1.Id, RelationshipNature__c = PROSPECT);
        AgentRole__c agentRole2 = new AgentRole__c(Customer__c = individualAccount.Id, Agent__c = agentUser2.Id, RelationshipNature__c = PROSPECT);
        AgentRole__c agentRole3 = new AgentRole__c(Customer__c = individualAccount.Id, Agent__c = agentUser3.Id, RelationshipNature__c = PROSPECT);
        AgentRole__c agentRole4 = new AgentRole__c(Customer__c = individualAccount.Id, Agent__c = agentUser4.Id, RelationshipNature__c = PROSPECT);
        AgentRole__c agentRole5 = new AgentRole__c(Customer__c = individualAccount.Id, Agent__c = agentUser5.Id, RelationshipNature__c = PROSPECT);
        List<AgentRole__c> agentRolesList = new List<AgentRole__c>{agentRole1, agentRole2, agentRole3, agentRole4, agentRole5};
        System.runAs(systemAdmin) {
          insert agentRolesList;
        }
        List<AgentRole__c> agentRolesToBeRemovedList = new List<AgentRole__c>{agentRole2,agentRole3,agentRole4}; // leaves agent roles 1 and 5
  
        Test.startTest();
          List<AccountShare> hhAccountShareAgent2Before = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy2.Id];
          System.assertEquals(1, hhAccountShareAgent2Before.size(),'Household share with Agent 2 should exist');
          List<AccountShare> hhAccountShareAgent3Before = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy3.Id];
          System.assertEquals(1, hhAccountShareAgent3Before.size(),'Household share with Agent 3 should exist');
          List<AccountShare> hhAccountShareAgent4Before = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy4.Id];
          System.assertEquals(1, hhAccountShareAgent4Before.size(),'Household share with Agent 4 should exist');
          List<AccountShare> hhAccountShareAgent5Before = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy5.Id];
          System.assertEquals(1, hhAccountShareAgent5Before.size(),'Household share with Agent 5 should exist');
          System.runAs(systemAdmin){
              delete agentRolesToBeRemovedList;
            }
        Test.stopTest();
        List<AccountShare> hhAccountShareAgent1After = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy1.Id];
        System.assertEquals(1, hhAccountShareAgent1After.size(),'Household share with Agent 1 should exist');
        List<AccountShare> hhAccountShareAgent2After = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy2.Id];
        System.assertEquals(0, hhAccountShareAgent2After.size(),'Household share with Agent 2 should not exist');
        List<AccountShare> hhAccountShareAgent3After = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy3.Id];
        System.assertEquals(0, hhAccountShareAgent3After.size(),'Household share with Agent 3 should not exist');
        List<AccountShare> hhAccountShareAgent4After = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy4.Id];
        System.assertEquals(0, hhAccountShareAgent4After.size(),'Household share with Agent 4 should not exist');
        List<AccountShare> hhAccountShareAgent5After = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy5.Id];
        System.assertEquals(1, hhAccountShareAgent5After.size(),'Household share with Agent 5 should exist');
    }
      
    /**
    * @description retain HH share when agent still has customer in HH after delete
    * @name testAgentRoleDeleteForHouseholdSharesMultCustomersInHousehold
    */ 
    @isTest
    public static void testAgentRoleDeleteForHouseholdSharesMultCustomersInHousehold(){
        //Toggle Household_shares set to true
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
          
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
          
        // get data from TestDataFactory
        TestDataFactory_AgencyShares.createDataForSharesTesting(false);
        Account householdAccount = TestDataFactory_AgencyShares.gethousehold1();
        User agentUser = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
        User agentProxy = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
          
        Account individualAccount1 = new Account(FirstName='Joseph',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
        Account individualAccount2 = new Account(FirstName='Mary',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYA');
        List<Account> customersInSameHH = new List<Account>{individualAccount1,individualAccount2};
        System.runAs(systemAdmin) {
            individualAccount1.Primary_Household__pc = householdAccount.Id;
            individualAccount2.Primary_Household__pc = householdAccount.Id;
            insert customersInSameHH;
        }
          
        AgentRole__c agentRoleCust1 = new AgentRole__c(Customer__c = individualAccount1.Id, Agent__c = agentUser.Id, RelationshipNature__c = PROSPECT);
        AgentRole__c agentRoleCust2 = new AgentRole__c(Customer__c = individualAccount2.Id, Agent__c = agentUser.Id, RelationshipNature__c = PROSPECT);
        List<AgentRole__c> agentRolesList = new List<AgentRole__c>{agentRoleCust1,agentRoleCust2};
        System.runAs(systemAdmin){
            insert agentRolesList;
        }
    
        Test.startTest();
            List<AccountShare> accountShareBefore = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy.Id];
            System.assertEquals(1, accountShareBefore.size(),'Household shares should not be empty');
            System.runAs(systemAdmin){
              delete agentRoleCust2;
            } 
        Test.stopTest();
        List<AccountShare> accountShareAfter = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy.Id];
        System.assertEquals(1, accountShareAfter.size(),'Household shares should be retained');    
    }
  
    /**
    * @description add members to household and do either remove member / delete relationship 
    * update agent role is trigger by Account Contact Relation delete so perform removal of household Account Shares
    * @name testAgentRoleUpdateForHouseholdShares
    */ 
    @isTest
    public static void testAgentRoleUpdateForHouseholdShares(){
        //Toggle Household_shares set to true
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
  
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        
        // get data from TestDataFactory
        TestDataFactory_AgencyShares.createDataForSharesTesting(false);
        Account householdAccount = TestDataFactory_AgencyShares.gethousehold1();
        User agentUser = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
        User agentProxy = [SELECT id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        
        Account individualAccount = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
        System.runAs(systemAdmin) {
          individualAccount.Primary_Household__pc = householdAccount.Id;
          insert individualAccount;
        }
          
        AgentRole__c agentRole = new AgentRole__c(Customer__c = individualAccount.Id, Agent__c = agentUser.Id, RelationshipNature__c = PROSPECT);
        System.runAs(systemAdmin){
          insert agentRole;
        }
          
        Test.startTest();
          List<AccountShare> accountShareBefore = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy.Id];
          System.assertEquals(1, accountShareBefore.size(),'Household shares should not be empty');
          
          //setting variable isDeleteFromACR to true such that it mimic ACR delete scenario to update Agent Role with Primary household as null
          AP_NewAgentRoleTrigger.isDeleteFromACR = true;
     
          System.runAs(systemAdmin){
            agentRole.Primary_Household__c = null;
            update agentRole;
          } 
        Test.stopTest();
        List<AccountShare> accountShareAfter = [SELECT id FROM AccountShare WHERE AccountId = :householdAccount.Id AND UserOrGroupId = :agentProxy.Id];
        System.assertEquals(0, accountShareAfter.size(),'Household shares should be empty');    
    }
    
}