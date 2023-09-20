/**
* @Author  Team AKITA
* @Date Created  10/21/2021
* @description  Test class for ProductCartCanvasComponent - Apex Class.
* @Version 3.0 
* Copyright © StateFarm
*/

@isTest
public with sharing class ProductCartCanvasComponent_Test {
    static final String AUTO_POLICYCENTER_PRODUCTSYSTEMNAME = 'PP_VEH_POLICYCENTER';
    
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();
    
    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }
    
    //method to build userrole with the given parameter value
    private static UserRole buildUserRole(String roleName) {
        return new UserRole(name = roleName);
    }
    
    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildUserRoleWithParent(String roleName, String parentRole) {
        return new UserRole(name = roleName, parentRoleId = parentRole);
       
    }
    
    //method to build Agent Role record with Customer Account Id
    private static AgentRole__c buildAgentRoleRecord(String accountId) {
        return new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = userInfo.getUserId(), Customer__c = accountId);
    }
    
    //method to build Account record with Client First Name, Last Name, and Client Id
    private static Account buildAccountRecord(String fstLstName, String clientId, Id owner) {
        String[] splitFSTLSTName = fstLstName.split(' ');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        return new Account(FirstName = splitFSTLSTName[0] , LastName = splitFSTLSTName[1], ownerId = owner,
                                  RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = clientId, BillingState = 'MD');
       
    }
    
    //method to build Opportunity record with Lob,Product, AccountId and OwnerId
    private static Opportunity buildOpportunityRecord(String accountId, String lobProduct, String ownerId) {
        String[] splitlobProduct = lobProduct.split('-');   
        return new Opportunity(Name = splitlobProduct[0],
                                          AccountId = accountId, 
                                          LOB__c = splitlobProduct[0], 
                                          Product__c = (splitlobProduct.size()>1)?splitlobProduct[1]:'',
                                          Requested_Effective_Date__c = Date.today(),
                                          StageName = 'New',
                                          CloseDate = Date.today()+60,
                                          ownerId = ownerId,
                                          Product_System_Name__c = AUTO_POLICYCENTER_PRODUCTSYSTEMNAME);
      
    }
    
    /**
     * @description setUp
     */
    @testSetup
    public static void setUp() {
        
        User adminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile('TestAdminUser@statefarm.com.bad');
        insert adminuser;
        User agentUser;
        User proxyUser; 
        
        System.runAs(adminUser) {
            byPassTrigger();
            
            UserRole agentUserRole = buildUserRole('AgentRole');
            insert agentUserRole;
            
            UserRole proxyUserRole = buildUserRoleWithParent('ProxyRole', agentUserRole.id);
            insert proxyUserRole;
            User testAgentUser = new User(Alias='X7PZ',LastName='agent,user,75-338-Office',Username='TestAgentUser@statefarm.com.bad',Associate_ID__c='ASSOCID0001',UserExternalID__c='EXTERNALID1',Servicing_Agent_Associate_ID__c='AGTASSOCID1',Territory_Associate_ID__c='',Servicing_Agent_Associate_ID_List__c='',Territory_Associate_ID_List__c='');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser (testAgentUser);
            agentUser.userRoleId = agentUserRole.id;
            agentUser.state_agent_code__c = '20-7185';
            agentUser.state_agent_code_list__c = '20-7185,05-7185,32-7185';
            agentUser.SubUserType__c = 'Agent';
            agentUser.UserExternalID__c = 'SERVICINID1_SERVICINID1';
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            User agentIdForPermSetAssign = [select id from user where alias = 'X7PZ' limit 1];
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentIdForPermSetAssign.Id, 'ECRM_ARIA_Participant_PermSetPID');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentIdForPermSetAssign.Id, 'ECRM_ARIA_Auto_PrivatePassenger_PC_PermSet');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentIdForPermSetAssign.Id, 'ECRM_ARIA_Fire_PermSetPID');
            User testProxyUser1 = new User(Alias='X7PX',LastName='middle,Last,75-338-Office',Username='TestProxyUser@statefarm.com.bad',UserExternalID__c='EXTERNALID1_EXTERNALID1',Servicing_Agent_Associate_ID__c='SERVICINID1');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
        }
        
        Account acc = ProductCartCanvasComponent_Test.buildAccountRecord('FST LST','111',agentUser.Id);
        insert acc;
        
        
        //Insert agent role to give account access to the Agent
        AgentRole__c agentRole;
        System.runAs(agentUser) {
            agentRole = buildAgentRoleRecord(acc.Id);
        }
        insert agentRole;
        
    }
    
    //Method to get the required parammeters as an Agent
    @isTest
    private static void getCartParamsAsAgent() {
        User agentUser1 = [Select Id,Associate_ID__c, UserExternalID__c from User where username = 'TestAgentUser@statefarm.com.bad'];
        User proxyUser1 = [Select Id,Associate_ID__c from User where username = 'TestProxyUser@statefarm.com.bad'];
        Account acc1 = [Select Id,ClientIdentifier__c, Name from Account where lastname = 'LST'];
        System.runAs(agentUser1) {
            Opportunity opp1 = ProductCartCanvasComponent_Test.buildOpportunityRecord(acc1.id,'Auto-Private Passenger',proxyUser1.Id);
            insert opp1; 
            Test.startTest();
            String serializedData = ProductCartCanvasComponent.getRequiredCartParams(opp1.Id);
            Test.stopTest();
            ProductCartCanvasComponent.CartParameters data = (ProductCartCanvasComponent.CartParameters)JSON.deserialize(serializedData, ProductCartCanvasComponent.CartParameters.class);
            User user1 = [SELECT Id,Associate_ID__c, State_Agent_Code_List__c FROM User WHERE UserExternalID__c = 'SERVICINID1_SERVICINID1'];
            Opportunity queriedOpp = [SELECT Id, Account.ClientIdentifier__c,Owner.Servicing_Agent_Associate_ID__c FROM Opportunity WHERE Id =: opp1.Id];
            List<String> userRecordBookCodeList = user1.State_Agent_Code_List__c.split(',');
            System.assertEquals(data.bookCodeList,userRecordBookCodeList, 'Expected bookCodeList not equal to original');
            System.assertEquals(data.clientId,queriedOpp.Account.ClientIdentifier__c, 'Expected clientId not equal to original');
        } 
    }

    //Method to get the required parammeters as an Agent with oppOwnerResult failure
    @isTest
    private static void getCartParamsAsAgentWithOppOwnerResultFailure() {
        User agentUser2 = [Select Id,Associate_ID__c, UserExternalID__c from User where username = 'TestAgentUser@statefarm.com.bad'];
        User proxyUser2 = [Select Id,Associate_ID__c from User where username = 'TestProxyUser@statefarm.com.bad'];
        Account acc2 = [Select Id,ClientIdentifier__c, Name from Account where lastname = 'LST'];
        System.runAs(agentUser2) {
            Opportunity opp2 = ProductCartCanvasComponent_Test.buildOpportunityRecord(acc2.id,'Auto-Private Passenger',proxyUser2.Id);
            insert opp2;
            Test.startTest();
            agentUser2.UserExternalID__c = '';
            update agentUser2;
            try {
                ProductCartCanvasComponent.getRequiredCartParams(opp2.Id);
            }
            catch (AuraHandledException e) {
                System.assertEquals('Script-thrown exception', e.getMessage(), 'Failed to serializeData for Account with OppOwnerResult failure');
            }
            Test.stopTest();
        } 
    }
}