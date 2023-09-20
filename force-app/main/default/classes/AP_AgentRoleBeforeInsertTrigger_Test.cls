/** @description This test class is for AgentRoleBeforeInsertTrigger apex class.
  * @Author: Team Targaryen
  * @Owner: Team Targaryen 
  * @createdDate: 04/20/2020
  */

@isTest
(seeAllData = false)
public class AP_AgentRoleBeforeInsertTrigger_Test {
    private static User agentUser;
    private static User systemAdminUser;
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static PermissionSetAssignment psassignment;
    private static User testFSCHHUser;
    public static final String FSC_HOUSEHOLD_PERMISSION_SET_NAME ='SF_CRMDM_FSCHH_PermSetPID';
    
    /**
      * @description Setup method used for building test data
      * @name setUp
      */
    @testsetup
    public static void testSetupData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        systemAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('Alias','SystemSA','systemUser@statefarm.com');
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        User testAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='accOwnerAgent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test123te',Servicing_Agent_Associate_ID__c='123test');
        agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        User testProxyUser1 = new User(Alias='Proxy',LastName='ProxyAccOwner',Username='proxyAgent@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
        User proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);         
        insert new User[]{systemUser, agentUser, proxyUser, systemAdminUser};
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        testFSCHHUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        insert testFSCHHUser;     
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,SystemUser);
        insert passTriggerAll;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeInsert__c = false;
        insert objectBasedByPassTrigger;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;   
    } 
    
    /**
      * @description Test Agent Role Insertion and verifies the Household id inserted into agent role from ACR.
      * @name testAgentRoleBeforeInsert
      */
    @isTest
    static void testAgentRoleBeforeInsert() {
        agentUser = [SELECT Id, Username, Associate_ID__c FROM User where lastname='accOwner' ];
        systemAdminUser = [SELECT Id, Username, Associate_ID__c FROM User where lastname='SystemSA'];      
        testFSCHHUser = [SELECT Id, Username, Associate_ID__c FROM User where lastname='apiUser' ];
		Account account  = new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'SFFSP81L8XB');
        Account householdAccount  = new Account(Name='Household',recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), AllowHousehold__c = true);
        List<Account> accountList = new List<Account>();
        accountList.add(account);
        accountList.add(householdAccount);      
        AccountContactRelation acr = new AccountContactRelation();
        psassignment = assignPSet(testFSCHHUser);
        insert psassignment;
		System.RunAs(agentUser) {
        	insert accountList;
        }
        List<Account> savedAccounts = [select id, ownerId, Primary_Household__pc, recordType.DeveloperName, personContactId from Account];  
        for(Account acc : savedAccounts) {
            if(acc.recordType.DeveloperName.equals(HOUSEHOLD_RECORD_TYPE)){
                acr.AccountId = acc.id;
            } else {
                acr.contactId = acc.PersonContactId;
                acr.IsActive = TRUE;
                acr.FinServ__PrimaryGroup__c = TRUE;
            }
        }
        System.runAs(testFSCHHUser){
        insert acr;
        }
        
        Test.startTest();
        String agentroleidentifier = agentUser.Associate_ID__c+'~'+account.ClientIdentifier__c;
        AgentRole__c ar1 = new AgentRole__c(customer__c = account.id, Agent__c = agentUser.ID,  RelationshipNature__c = 'Prospect', agentroleidentifier__c = agentroleidentifier);
        System.runAs(systemAdminUser){
            insert ar1;
        }
        Test.stopTest();
        AgentRole__c ar = [SELECT Id, Name, CreatedDate, Customer__c, AgentRoleIdentifier__c, Agent__c, RelationshipNature__c, Primary_Household__c FROM AgentRole__c where Customer__c = :account.id Limit 1];
        System.assertEquals(acr.AccountId, ar.Primary_Household__c, 'Invalid Household');
       
     }
    
	/**
      * @description Test Mutltiple Agent Roles Insertion and verifies the Household id inserted into agent role from ACR.
      * @name testAgentRoleBeforeInsertWithMultipleAgents
      */    
    @isTest
    static void testAgentRoleBeforeInsertWithMultipleAgents() {
        systemAdminUser = [SELECT Id, Username, Associate_ID__c FROM User where lastname='SystemSA'];
        testFSCHHUser = [SELECT Id, Username, Associate_ID__c FROM User where lastname='apiUser' ];
        User testAgentUser1 = new User(Alias='alias2',LastName='accOwner2',Username='accOwnerAgent2@statefarm.com',Associate_ID__c='123test2',UserExternalID__c='123test123te2',Servicing_Agent_Associate_ID__c='123test');
        User agentUser2 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        User testProxyUser1 = new User(Alias='Proxy2',LastName='ProxyAccOwner2',Username='proxyAgent2@statefarm.com',UserExternalID__c='123test2P',Servicing_Agent_Associate_ID__c='123test2');
        User proxyUser2 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);         
        insert new User[]{agentUser2, proxyUser2};
        agentUser = [SELECT Id, Username, Associate_ID__c FROM User where lastname='accOwner' ];
		Account account  = new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'SFFSP81L8XB');
        Account householdAccount  = new Account(Name='Household',recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), AllowHousehold__c = true);
        List<Account> accountList = new List<Account>();
        accountList.add(account);
        accountList.add(householdAccount);      
        AccountContactRelation acr = new AccountContactRelation();
        psassignment = assignPSet(testFSCHHUser);
        insert psassignment;
        
		System.RunAs(agentUser) {
        	insert accountList;
        }
        List<Account> savedAccounts = [select id, ownerId, Primary_Household__pc, recordType.DeveloperName, personContactId from Account];  
        for(Account acc : savedAccounts) {
            if(acc.recordType.DeveloperName.equals(HOUSEHOLD_RECORD_TYPE)){
                acr.AccountId = acc.id;
            } else {
                acr.contactId = acc.PersonContactId;
                acr.IsActive = TRUE;
                acr.FinServ__PrimaryGroup__c = TRUE;
            }
        }
        System.RunAs(testFSCHHUser) {
        	insert acr;
        }
        
        List<AgentRole__c> arList = new List<AgentRole__c>();
        Test.startTest();
        String agentroleidentifier = agentUser.Associate_ID__c+'~'+account.ClientIdentifier__c;
        AgentRole__c ar1 = new AgentRole__c(customer__c = account.id, Agent__c = agentUser.ID,  RelationshipNature__c = 'Prospect', agentroleidentifier__c = agentroleidentifier);
        AgentRole__c ar2 = new AgentRole__c(customer__c = account.id, Agent__c = agentUser2.ID,  RelationshipNature__c = 'Prospect', agentroleidentifier__c = agentUser2.Associate_ID__c+'~'+account.ClientIdentifier__c);
        arList.add(ar1);
        arList.add(ar2);
        System.runAs(systemAdminUser){
        insert arList;
        }
        Test.stopTest();
        List<AgentRole__c> savedARList = [SELECT Id, Name, CreatedDate, Customer__c, AgentRoleIdentifier__c, Agent__c, RelationshipNature__c, Primary_Household__c FROM AgentRole__c];
        for(AgentRole__c savedAgent : savedARList){
			System.assertEquals(acr.AccountId, savedAgent.Primary_Household__c, 'Invalid Household');
        }
        
     }
    
     /**
      * @description Test BUlk Agent Role Insertion and verifies the Household id inserted into agent role from ACR.
      * @name testAgentRoleBeforeInsertBulk
      */
    @isTest
    static void testAgentRoleBeforeInsertBulk() {
        systemAdminUser = [SELECT Id, Username, Associate_ID__c FROM User where lastname='SystemSA'];
        testFSCHHUser = [SELECT Id, Username, Associate_ID__c FROM User where lastname='apiUser' ];
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
        agentUser = [SELECT Id, Username, Associate_ID__c FROM User where lastname='accOwner' ];
		List<Account> accountList = buildAccounts(10);
        Account householdAccount  = new Account(Name='Household',recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), AllowHousehold__c = true);
        accountList.add(householdAccount);
		System.RunAs(agentUser) {
        	insert accountList;
        }
        
        List<Account> savedAccounts = [select id, ownerId, recordType.DeveloperName, personContactId, ClientIdentifier__c from Account];
        String householdAccountId = buildACRAndAgentRoleList(savedAccounts, acrList, agentRoleList);
      	psassignment = assignPSet(testFSCHHUser);
        insert psassignment;
         System.RunAs(testFSCHHUser) {
            insert acrList;
        }

        Test.startTest();
        System.RunAs(systemAdminUser) {
            insert agentRoleList;
        }
        Test.stopTest();
        List<AgentRole__c> savedARList = [SELECT Id, Name, CreatedDate, Customer__c, AgentRoleIdentifier__c, Agent__c, RelationshipNature__c, Primary_Household__c FROM AgentRole__c];
        
        for(AgentRole__c savedAR : savedARList) {
			System.assertEquals(householdAccountId, savedAR.Primary_Household__c, 'Invalid Household');
        }
     }
    
    private static List<Account> buildAccounts(Integer count){
		List<Account> accountList = new List<Account>();
        for(Integer i=0; i<count; i++) {
            Account account  = new Account(firstname ='SSSHHHH'+i, lastname='SSSSSHHHH'+i, ClientIdentifier__c = 'SFFSP81L8X'+i);
            accountList.add(account);
        }
        return accountList;
    }
    
    private static String buildACRAndAgentRoleList(List<Account> savedAccounts, List<AccountContactRelation> acrList, List<AgentRole__c> agentRoleList) {
        
        String householdAccountId;
        for(Account acc : savedAccounts) {
            if(acc.recordType.DeveloperName.equals(HOUSEHOLD_RECORD_TYPE)){
                householdAccountId = acc.id;
                break;
            }
        }
        
        for(Account acc : savedAccounts) {
            if(!acc.recordType.DeveloperName.equals(HOUSEHOLD_RECORD_TYPE)){
                String agentroleidentifier = agentUser.Associate_ID__c+'~'+acc.ClientIdentifier__c;
                AccountContactRelation acr = new AccountContactRelation(AccountId = householdAccountId, contactId = acc.PersonContactId, IsActive = TRUE,
                FinServ__PrimaryGroup__c = TRUE);
                AgentRole__c ar = new AgentRole__c(customer__c = acc.id, Agent__c = agentUser.ID,  RelationshipNature__c = 'Prospect', agentroleidentifier__c = agentroleidentifier);
                acrList.add(acr);
                agentRoleList.add(ar);
            }
        }
        return householdAccountId;
    }
    
	/**
    * This method is used for assign a particular PermissionSet to a particular User
    * @description assignPSet <This method is used to get Standard testUser>
    * @param testUser
    * @return PermissionSetAssignment
    */     
    private static PermissionSetAssignment assignPSet (User testUser){
        PermissionSet ps = [Select Id, Name FROM PermissionSet WHERE Name=:FSC_HOUSEHOLD_PERMISSION_SET_NAME];
        return new PermissionSetAssignment(AssigneeId=testUser.Id,PermissionSetId=ps.Id);
    }

}