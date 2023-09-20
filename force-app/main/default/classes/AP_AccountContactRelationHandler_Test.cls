/**
* @author: Targaryen
* @owner Targaryen
* @name: AP_AccountContactRelationHandler_Test
* @createdDate 04/04/2020
* @description The class will perform all backend activities related to ACR records update or delete.
* @version 1.0
*/

@IsTest(seeAllData=false)
public class AP_AccountContactRelationHandler_Test {
    
    private static User systemUser;
    private static User testFSCHHUser;
    private static Account accRecord;
    private static Contact conRecord;
    private static Account hhRecord;
    private static AccountContactRelation acrRecord;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy2;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy3;
    private static PermissionSetAssignment psassignment;
    private static CS_ACRTriggerCheckForSyncId__c syncId;
    
    /**@description test data setup */
     public static void setup() {
        systemUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('Alias','SystemSA','systemUser@statefarm.com');
        insert systemUser;
        testFSCHHUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        insert testFSCHHUser;

        psassignment = AP_AccountContactRelationTrigger_Test.assignPSet(testFSCHHUser);
        insert psassignment;

        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('U');
        salesRoleHierarchy3 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('V');

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent, salesRoleHierarchy1.agentTeamMember});

        System.runAs(systemUser){
            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
            insert sysAdminUserIdSetting;
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,systemUser);
            insert passTriggerAll;
            CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
            objectBasedByPassTrigger.Override_ACRBeforeInsert__c = false;
            objectBasedByPassTrigger.Override_ACRAfterInsert__c = false;
            objectBasedByPassTrigger.Override_ACRAfterUpdate__c = false;
            objectBasedByPassTrigger.Override_ACRBeforeDelete__c = false;
            insert objectBasedByPassTrigger;
        }
        syncId= new CS_ACRTriggerCheckForSyncId__c(username__c = 'apiUser');
    }
    
    @isTest
    static void testInactiveACRUpdateWithAccountAndAgentRoleAndAccountNote(){
        setup();
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);        
        System.runAs(salesRoleHierarchy1.Agent){
            createAccount();
            insert accRecord;
        }
        System.runAs(systemUser){
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            AgentRole__c agentRole1 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
            agentRoleList.add(agentRole);
            agentRoleList.add(agentRole1);
            insert agentRoleList;
            List<Account_Note__c> accountNoteList = new List<Account_Note__c>();
            Account_Note__c accountNote1 = new Account_Note__c (Account__c = accRecord.id, Category__c ='Alert', comments__c='This is my first account note');
            Account_Note__c accountNote2 = new Account_Note__c (Account__c = accRecord.id, Category__c ='General',comments__c='This is my second account note');
            accountNoteList.add(accountNote1);
            accountNoteList.add(accountNote2);
            insert accountNoteList;
            insert syncId;
    	}
    
        System.runAs(testFSCHHUser){
            createHousehold();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
        }
        System.runAs(testFSCHHUser){
            createACR(hhRecord.Id,conRecord.Id);
            insert acrRecord;
            acrRecord.isActive = false;
            Test.startTest(); 
            update acrRecord;
            Test.stopTest();
        }
        List<AgentRole__c> updatedAgentRoleList = [SELECT Id, Primary_Household__c from AgentRole__c WHERE customer__c=:accRecord.Id];
        for (AgentRole__c singleAgentRole:updatedAgentRoleList){
            system.assertEquals(NULL, singleAgentRole.Primary_Household__c, 'Primary Household Id is not removed');
        }
        List<Account_Note__c> updatedAccountNoteList = [SELECT Id, Primary_Household__c from Account_Note__c WHERE Account__c=:accRecord.Id];
        for (Account_Note__c singleAccountNote:updatedAccountNoteList){
            system.assertEquals(NULL, singleAccountNote.Primary_Household__c, 'Primary Household Id is not removed');
        }
        
        List<Id> agentProxyIds = New List<Id>();
        agentProxyIds.add(salesRoleHierarchy1.AgentOffice.id);
        agentProxyIds.add(salesRoleHierarchy2.AgentOffice.id);
        List<AccountShare> hhAccountShares = [SELECT Id,UserOrGroupId from AccountShare where AccountId=:hhRecord.Id AND RowCause='Manual'AND UserOrGroupId IN :agentProxyIds];
        System.assertEquals(0,hhAccountShares.size(), 'Household Shares are not deleted');
    } 

    @isTest
    static void testInactiveACRUpdateWithAccountAndAgentRoleAndAccountNoteForAgent(){
        setup();
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
        System.runAs(salesRoleHierarchy1.Agent){
            createAccount();
            insert accRecord;
        }
        System.runAs(systemUser){
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            AgentRole__c agentRole1 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
            agentRoleList.add(agentRole);
            agentRoleList.add(agentRole1);
            insert agentRoleList;
            List<Account_Note__c> accountNoteList = new List<Account_Note__c>();
            Account_Note__c accountNote1 = new Account_Note__c (Account__c = accRecord.id, Category__c ='Alert', comments__c='This is my first account note');
            Account_Note__c accountNote2 = new Account_Note__c (Account__c = accRecord.id, Category__c ='General',comments__c='This is my second account note');
            accountNoteList.add(accountNote1);
            accountNoteList.add(accountNote2);
            insert accountNoteList;
            insert syncId;
    	}
    
        System.runAs(salesRoleHierarchy1.Agent){
            createHouseholdByAgent();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
       		createACR(hhRecord.Id,conRecord.Id);
            insert acrRecord;
            acrRecord.isActive = false;
            Test.startTest(); 
            update acrRecord;
            Test.stopTest();
        }
        List<AgentRole__c> updatedAgentRoleList = [SELECT Id, Primary_Household__c from AgentRole__c WHERE customer__c=:accRecord.Id];
        for (AgentRole__c singleAgentRole:updatedAgentRoleList){
            system.assertEquals(NULL, singleAgentRole.Primary_Household__c, 'Primary Household Id is not removed');
        }
        List<Account_Note__c> updatedAccountNoteList = [SELECT Id, Primary_Household__c from Account_Note__c WHERE Account__c=:accRecord.Id];
        for (Account_Note__c singleAccountNote:updatedAccountNoteList){
            system.assertEquals(NULL, singleAccountNote.Primary_Household__c, 'Primary Household Id is not removed');
        }
        List<Id> agentProxyIds = New List<Id>();
        agentProxyIds.add(salesRoleHierarchy1.AgentOffice.id);
        agentProxyIds.add(salesRoleHierarchy2.AgentOffice.id);
        List<AccountShare> hhAccountShares = [SELECT Id,UserOrGroupId from AccountShare where AccountId=:hhRecord.Id AND RowCause='Manual'AND UserOrGroupId IN :agentProxyIds];
        System.assertEquals(0,hhAccountShares.size(), 'Household Shares are not deleted');
    } 
    
    @isTest
    static void testActiveACRUpdateWithAccountAndAgentRoleAndAccountNoteForAgent(){
        setup();
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
        System.runAs(salesRoleHierarchy1.Agent){
            createAccount();
            insert accRecord;
        }
        System.runAs(systemUser){
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            AgentRole__c agentRole1 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
            agentRoleList.add(agentRole);
            agentRoleList.add(agentRole1);
            insert agentRoleList;
            List<Account_Note__c> accountNoteList = new List<Account_Note__c>();
            Account_Note__c accountNote1 = new Account_Note__c (Account__c = accRecord.id, Category__c ='Alert', comments__c='This is my first account note');
            Account_Note__c accountNote2 = new Account_Note__c (Account__c = accRecord.id, Category__c ='General',comments__c='This is my second account note');
            accountNoteList.add(accountNote1);
            accountNoteList.add(accountNote2);
            insert accountNoteList;
            insert syncId;
    	}
    
        System.runAs(salesRoleHierarchy1.agentTeamMember){
            createHouseholdByAgent();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
            createACR(hhRecord.Id,conRecord.Id);
            acrRecord.isActive = false;
            insert acrRecord;
            acrRecord.isActive = true;
            Test.startTest(); 
            update acrRecord;
            Test.stopTest();
        }
        List<AgentRole__c> updatedAgentRoleList = [SELECT Id, Primary_Household__c from AgentRole__c WHERE customer__c=:accRecord.Id];
        for (AgentRole__c singleAgentRole:updatedAgentRoleList){
            system.assertEquals(hhRecord.id, singleAgentRole.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        }
        List<Account_Note__c> updatedAccountNoteList = [SELECT Id, Primary_Household__c from Account_Note__c WHERE Account__c=:accRecord.Id];
        for (Account_Note__c singleAccountNote:updatedAccountNoteList){
            system.assertEquals(hhRecord.id, singleAccountNote.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        }
        
        List<Id> agentProxyIds = New List<Id>();
        agentProxyIds.add(salesRoleHierarchy1.AgentOffice.id);
        agentProxyIds.add(salesRoleHierarchy2.AgentOffice.id);
        List<AccountShare> hhAccountShares = [SELECT Id,UserOrGroupId from AccountShare where AccountId=:hhRecord.Id AND RowCause='Manual'AND UserOrGroupId IN :agentProxyIds];
        System.assertEquals(2,hhAccountShares.size(), 'Household Shares are still exist');
    }
    
    @isTest
    static void testActiveACRUpdateWithAccountAndAgentRoleAndAccountNote(){
        setup();
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
        System.runAs(salesRoleHierarchy1.Agent){
            createAccount();
            insert accRecord;
        }
        System.runAs(systemUser){
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            AgentRole__c agentRole1 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
            agentRoleList.add(agentRole);
            agentRoleList.add(agentRole1);
            insert agentRoleList;
            List<Account_Note__c> accountNoteList = new List<Account_Note__c>();
            Account_Note__c accountNote1 = new Account_Note__c (Account__c = accRecord.id, Category__c ='Alert', comments__c='This is my first account note');
            Account_Note__c accountNote2 = new Account_Note__c (Account__c = accRecord.id, Category__c ='General',comments__c='This is my second account note');
            accountNoteList.add(accountNote1);
            accountNoteList.add(accountNote2);
            insert accountNoteList;
            insert syncId;
    	}
    
        System.runAs(testFSCHHUser){
            createHousehold();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
        }
        System.runAs(testFSCHHUser){
            createACR(hhRecord.Id,conRecord.Id);
            acrRecord.isActive = false;
            insert acrRecord;
            acrRecord.isActive = true;
            Test.startTest(); 
            update acrRecord;
            Test.stopTest();
        }
        List<AgentRole__c> updatedAgentRoleList = [SELECT Id, Primary_Household__c from AgentRole__c WHERE customer__c=:accRecord.Id];
        for (AgentRole__c singleAgentRole:updatedAgentRoleList){
            system.assertEquals(hhRecord.id, singleAgentRole.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        }
        List<Account_Note__c> updatedAccountNoteList = [SELECT Id, Primary_Household__c from Account_Note__c WHERE Account__c=:accRecord.Id];
        for (Account_Note__c singleAccountNote:updatedAccountNoteList){
            system.assertEquals(hhRecord.id, singleAccountNote.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        }
        
        List<Id> agentProxyIds = New List<Id>();
        agentProxyIds.add(salesRoleHierarchy1.AgentOffice.id);
        agentProxyIds.add(salesRoleHierarchy2.AgentOffice.id);
        List<AccountShare> hhAccountShares = [SELECT Id,UserOrGroupId from AccountShare where AccountId=:hhRecord.Id AND RowCause='Manual'AND UserOrGroupId IN :agentProxyIds];
        System.assertEquals(2,hhAccountShares.size(), 'Household Shares are still exist');
    } 
    
    private static void createAccount(){
        accRecord = new Account(FirstName='FSCtest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c='IAMCLIENTID');
    }
    
    private static void createHousehold(){
        hhRecord = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesHousehold').getRecordTypeId(), FinServ__SourceSystemId__c = '45678');
    }
    
     private static void createHouseholdByAgent(){
        hhRecord = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesHousehold').getRecordTypeId(), FinServ__SourceSystemId__c = '45678', AllowHousehold__c = true);
    }
    
    private static void createACR(Id acntId,Id conId){
        acrRecord = new AccountContactRelation(AccountId=acntId,ContactId=conId, FinServ__PrimaryGroup__c = true, FinServ__Primary__c = true, FinServ__RollUps__c = 'All');
    }

}