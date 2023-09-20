/**
* @author: Targaryen
* @owner Targaryen
* @name: AP_AccountContactRelationshipTrigger_Test
* @createdDate 04/04/2020
* @description The class will perform all backend activities related to ACR records insert or delete.
* @version 1.0
*/

@IsTest(seeAllData=false)
public class AP_AccountContactRelationTrigger_Test {
    private static User systemUser;
    private static User testFSCHHUser;
    public static final String FSC_HOUSEHOLD_PERMISSION_SET_NAME ='SF_CRMDM_FSCHH_PermSetPID';
    public static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy2;
    //private static TestData_SalesRoleHierarchy salesRoleHierarchy3;
    private static final String CLIENT_IDENTIFIER='IAMCLIENTID';
    private static Account accRecord;
    private static Contact conRecord;
    private static Account hhRecord;
    private static AccountContactRelation acrRecord;
    //private static List<Account> accountBulkList;
    
    /*private static account accRecord1=new Account(FirstName='Tracey',LastName='Smith',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHACR123');
    private static account accRecord2=new Account(FirstName='Tim',LastName='Smith',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHACR456');
    private static account accRecord3=new Account(FirstName='Tom',LastName='Smith',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHACR789');
    private static account accRecord4=new Account(FirstName='John',LastName='Smith',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHACR189');        
    private static account accRecord5=new Account(FirstName='Merry',LastName='Smith',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHACR289');        
    private static account accRecord6=new Account(FirstName='Steffi',LastName='Graph',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='FSCHHACR739');            
    private static account accRecord7=new Account(FirstName='George',LastName='Graph',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='FSCHHACR784');        
    private static account accRecord8=new Account(FirstName='Stefen',LastName='Graph',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='FSCHHACR785');        
    private static account accRecord9=new Account(FirstName='Stukle',LastName='Graph',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='FSCHHACR689');        
    private static account accRecord10=new Account(FirstName='Shelly',LastName='Chopra',BillingAddressType__c='US',BillingCity='CA',ClientIdentifier__c='FSCHHACR779');        
    private static account accRecord11=new Account(FirstName='Ravina',LastName='Chopra',BillingAddressType__c='US',BillingCity='CA',ClientIdentifier__c='FSCHHACR889');        
    private static account accRecord12=new Account(FirstName='Akshay',LastName='Chopra',BillingAddressType__c='US',BillingCity='CA',ClientIdentifier__c='FSCHHACR989');        
    private static account accRecord13=new Account(FirstName='Oldy',LastName='Young',BillingAddressType__c='US',BillingCity='IL',ClientIdentifier__c='FSCHHACR089');        
    private static account accRecord14=new Account(FirstName='Newly',LastName='Young',BillingAddressType__c='US',BillingCity='IL',ClientIdentifier__c='FSCHHACR389');        
    private static account accRecord15=new Account(FirstName='FSCHH',LastName='Salesforce',BillingAddressType__c='US',BillingCity='NY',ClientIdentifier__c='FSCHHACR324');      
    private static Account hhRecord1;
    private static Account hhRecord2;
    private static Account hhRecord3;
    private static Account hhRecord4;
    private static Account hhRecord5;
    private static AccountContactRelation acrRecord1;
    private static AccountContactRelation acrRecord2;
    private static AccountContactRelation acrRecord3;
    private static AccountContactRelation acrRecord4;
    private static AccountContactRelation acrRecord5;
    private static AccountContactRelation acrRecord6;
    private static AccountContactRelation acrRecord7;
    private static AccountContactRelation acrRecord8;
    private static AccountContactRelation acrRecord9;
    private static AccountContactRelation acrRecord10;
    private static AccountContactRelation acrRecord11;
    private static AccountContactRelation acrRecord12;
    private static AccountContactRelation acrRecord13;
    private static AccountContactRelation acrRecord14;
    private static AccountContactRelation acrRecord15;*/
    
    /**@description test data setup */
    public static void setup() {
        systemUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('Alias','SystemSA','systemUser@statefarm.com');
        insert systemUser;
        testFSCHHUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        insert testFSCHHUser;        

        PermissionSetAssignment psassignment = assignPSet(testFSCHHUser);
        insert psassignment;

        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('U');
        //salesRoleHierarchy3 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('V');

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.Agent);

        CS_ACRTriggerCheckForSyncId__c triggerCheck = new CS_ACRTriggerCheckForSyncId__c(Username__c = 'apiUser');
        System.runAs(systemUser){
            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
            insert sysAdminUserIdSetting;
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,systemUser);
            insert passTriggerAll;
            CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
            objectBasedByPassTrigger.Override_ACRBeforeInsert__c = false;
            objectBasedByPassTrigger.Override_ACRBeforeDelete__c = false;
            insert objectBasedByPassTrigger; 
            insert triggerCheck;
        }
    }
    
    @isTest
    static void testAccountContactRelationshipCreation(){
        setup();
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
        System.runAs(systemUser){
            createAccount();
            insert accRecord;
            List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            AgentRole__c agentRole1 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
            agentRoleList.add(agentRole);
            agentRoleList.add(agentRole1);
            insert agentRoleList;
        }
        System.runAs(testFSCHHUser){
            createHousehold();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
        }
        System.runAs(testFSCHHUser){
            Test.startTest(); 
            createACR(hhRecord.Id,conRecord.Id);
            
            acrRecord.FinServ__PrimaryGroup__c = true;
            insert acrRecord;
            Test.stopTest();
        }
        
        Account updatedAccount = [SELECT Id, Primary_Household__pc from Account WHERE Id=:accRecord.Id];
        system.assertEquals(hhRecord.id, updatedAccount.Primary_Household__pc, 'Primary Household Id is not matched with HH Id');
        List<AgentRole__c> updatedAgentRoleList = [SELECT Id, Primary_Household__c from AgentRole__c WHERE customer__c=:accRecord.Id];
        for (AgentRole__c singleAgentRole:updatedAgentRoleList){
            system.assertEquals(hhRecord.id, singleAgentRole.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        }
        AccountContactRelation acr = [SELECT Id,FinServ__SourceSystemId__c from AccountContactRelation where AccountId = :hhRecord.Id];
        System.assertEquals(null, acr.FinServ__SourceSystemId__c, 'SourceSystemId__c Id of acr object is not null for api user');
        List<Id> agentProxyIds = New List<Id>();
        agentProxyIds.add(salesRoleHierarchy1.AgentOffice.id);
        agentProxyIds.add(salesRoleHierarchy2.AgentOffice.id);
        List<AccountShare> hhAccountShares = [SELECT Id,UserOrGroupId from AccountShare where AccountId=:hhRecord.Id AND RowCause='Manual'AND UserOrGroupId IN :agentProxyIds];
        System.assertEquals(2,hhAccountShares.size(), 'More or less HH share created');
    }

    @isTest
    static void testACRCreationWithAgentRoleAndAccountNote(){
        setup();
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
        System.runAs(systemUser){
            createAccount();
            insert accRecord;
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
        }
        System.runAs(testFSCHHUser){
            createHousehold();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
        }
        System.runAs(testFSCHHUser){
            Test.startTest(); 
            createACR(hhRecord.Id,conRecord.Id);
            insert acrRecord;
            Test.stopTest();
        }
        
        Account updatedAccount = [SELECT Id, Primary_Household__pc from Account WHERE Id=:accRecord.Id];
        system.assertEquals(hhRecord.id, updatedAccount.Primary_Household__pc, 'Primary Household Id is not matched with HH Id');
        
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
        System.assertEquals(2,hhAccountShares.size(), 'More or less HH share created');
        
    }
    
    @isTest
    static void testACRCreationWithAgentRoleAndAccountNoteForAgentUser(){
        setup();
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
        System.runAs(systemUser){
            createAccount();
            insert accRecord;
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
        }
        System.runAs(salesRoleHierarchy1.Agent){
            createHouseholdByAgent();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
            Test.startTest(); 
            createACR(hhRecord.Id,conRecord.Id);
            insert acrRecord;
            Test.stopTest();
        }
        
        Account updatedAccount = [SELECT Id, Primary_Household__pc from Account WHERE Id=:accRecord.Id];
        system.assertEquals(hhRecord.id, updatedAccount.Primary_Household__pc, 'Primary Household Id is not matched with HH Id');
        
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
        System.assertEquals(2,hhAccountShares.size(), 'More or less HH share created');
        
    }
    
    @isTest
    static void testACRCreationWithOnlyAgentRole(){
        setup();
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
        System.runAs(systemUser){
            createAccount();
            insert accRecord;
            List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            AgentRole__c agentRole1 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
            agentRoleList.add(agentRole);
            agentRoleList.add(agentRole1);
            insert agentRoleList;
        }
        System.runAs(testFSCHHUser){
            createHousehold();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
        }
        System.runAs(testFSCHHUser){
            Test.startTest(); 
            createACR(hhRecord.Id,conRecord.Id);
            insert acrRecord;
            Test.stopTest();
        }
        
        Account updatedAccount = [SELECT Id, Primary_Household__pc from Account WHERE Id=:accRecord.Id];
        system.assertEquals(hhRecord.id, updatedAccount.Primary_Household__pc, 'Primary Household Id is not matched with HH Id');
        
        List<AgentRole__c> updatedAgentRoleList = [SELECT Id, Primary_Household__c from AgentRole__c WHERE customer__c=:accRecord.Id];
        for (AgentRole__c singleAgentRole:updatedAgentRoleList){
            system.assertEquals(hhRecord.id, singleAgentRole.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        }
        
        List<Id> agentProxyIds = New List<Id>();
        agentProxyIds.add(salesRoleHierarchy1.AgentOffice.id);
        agentProxyIds.add(salesRoleHierarchy2.AgentOffice.id);
        List<AccountShare> hhAccountShares = [SELECT Id,UserOrGroupId from AccountShare where AccountId=:hhRecord.Id AND RowCause='Manual'AND UserOrGroupId IN :agentProxyIds];
        System.assertEquals(2,hhAccountShares.size(), 'More or less HH share created');
        
    }
    
    @isTest
    static void testACRCreationWithOnlyAccountNote(){
        setup();
        System.runAs(systemUser){
            createAccount();
            insert accRecord;
            List<Account_Note__c> accountNoteList = new List<Account_Note__c>();
            Account_Note__c accountNote1 = new Account_Note__c (Account__c = accRecord.id, Category__c ='Alert', comments__c='This is my first account note');
            Account_Note__c accountNote2 = new Account_Note__c (Account__c = accRecord.id, Category__c ='General',comments__c='This is my second account note');
            accountNoteList.add(accountNote1);
            accountNoteList.add(accountNote2);
            insert accountNoteList;
        }
        System.runAs(testFSCHHUser){
            createHousehold();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
        }
        System.runAs(testFSCHHUser){
            Test.startTest(); 
            createACR(hhRecord.Id,conRecord.Id);
            insert acrRecord;
            Test.stopTest();
        }
        
        Account updatedAccount = [SELECT Id, Primary_Household__pc from Account WHERE Id=:accRecord.Id];
        system.assertEquals(hhRecord.id, updatedAccount.Primary_Household__pc, 'Primary Household Id is not matched with HH Id');
        
        List<Account_Note__c> updatedAccountNoteList = [SELECT Id, Primary_Household__c from Account_Note__c WHERE Account__c=:accRecord.Id];
        for (Account_Note__c singleAccountNote:updatedAccountNoteList){
            system.assertEquals(hhRecord.id, singleAccountNote.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        } 
        
    }
    
    @isTest
    static void testACRCreationWithOnlyAccount(){
        setup();
        System.runAs(systemUser){
            createAccount();
            insert accRecord;
        }
        System.runAs(testFSCHHUser){
            createHousehold();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
        }
        System.runAs(testFSCHHUser){
            Test.startTest(); 
            createACR(hhRecord.Id,conRecord.Id);
            insert acrRecord;
            Test.stopTest();
        }
        
        Account updatedAccount = [SELECT Id, Primary_Household__pc from Account WHERE Id=:accRecord.Id];
        system.assertEquals(hhRecord.id, updatedAccount.Primary_Household__pc, 'Primary Household Id is not matched with HH Id');
        
    }
    
    @isTest
    static void testACRDeleteWithOnlyAccount(){
        setup();
        System.runAs(systemUser){
            createAccount();
            insert accRecord;
        }
        System.runAs(testFSCHHUser){
            createHousehold();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
        }
        System.runAs(testFSCHHUser){
            createACR(hhRecord.Id,conRecord.Id);
            insert acrRecord;
        }
        
        System.runAs(testFSCHHUser){
            Test.startTest(); 
            deleteACR(acrRecord.Id);
            delete acrRecord;
            Test.stopTest();
        }
        Account updatedAccount = [SELECT Id, Primary_Household__pc from Account WHERE Id=:accRecord.Id];
        system.assertEquals(NULL, updatedAccount.Primary_Household__pc, 'Primary Household Id is not removed');
    }   
    
    @isTest
    static void testACRDeleteWithAccountAndAgentRole(){
        setup();
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
        System.runAs(systemUser){
            createAccount();
            insert accRecord;
            List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            AgentRole__c agentRole1 = new AgentRole__c (customer__c = accRecord.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
            agentRoleList.add(agentRole);
            agentRoleList.add(agentRole1);
            insert agentRoleList;
        }
        System.runAs(testFSCHHUser){
            createHousehold();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
        }
        System.runAs(testFSCHHUser){
            createACR(hhRecord.Id,conRecord.Id);
            insert acrRecord;
        }
        
        System.runAs(testFSCHHUser){
            Test.startTest(); 
            deleteACR(acrRecord.Id);
            delete acrRecord;
            Test.stopTest();
        }
        Account updatedAccount = [SELECT Id, Primary_Household__pc from Account WHERE Id=:accRecord.Id];
        system.assertEquals(NULL, updatedAccount.Primary_Household__pc, 'Primary Household Id is not removed');
        
        List<AgentRole__c> updatedAgentRoleList = [SELECT Id, Primary_Household__c from AgentRole__c WHERE customer__c=:accRecord.Id];
        for (AgentRole__c singleAgentRole:updatedAgentRoleList){
            system.assertEquals(NULL, singleAgentRole.Primary_Household__c, 'Primary Household Id is not removed');
        }
        
        List<Id> agentProxyIds = New List<Id>();
        agentProxyIds.add(salesRoleHierarchy1.AgentOffice.id);
        agentProxyIds.add(salesRoleHierarchy2.AgentOffice.id);
        List<AccountShare> hhAccountShares = [SELECT Id,UserOrGroupId from AccountShare where AccountId=:hhRecord.Id AND RowCause='Manual'AND UserOrGroupId IN :agentProxyIds];
        System.assertEquals(0,hhAccountShares.size(), 'Household Shares are not deleted');
    } 
    
    @isTest
    static void testACRDeleteWithAccountAndAgentRoleAndAccountNote(){
        setup();
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
        System.runAs(systemUser){
            createAccount();
            insert accRecord;
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
        }
        System.runAs(testFSCHHUser){
            createHousehold();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
        }
        System.runAs(testFSCHHUser){
            createACR(hhRecord.Id,conRecord.Id);
            insert acrRecord;
        }
        
        System.runAs(testFSCHHUser){
            Test.startTest(); 
            deleteACR(acrRecord.Id);
            delete acrRecord;
            Test.stopTest();
        }
        Account updatedAccount = [SELECT Id, Primary_Household__pc from Account WHERE Id=:accRecord.Id];
        system.assertEquals(NULL, updatedAccount.Primary_Household__pc, 'Primary Household Id is not removed');
        
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
    static void testACRDeleteWithAccountAndAgentRoleAndAccountNoteForAgent(){
        setup();
        UTIL_HouseholdAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.HOUSEHOLD_SHARES, true);
        System.runAs(systemUser){
            createAccount();
            insert accRecord;
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
        }
        System.runAs(salesRoleHierarchy1.Agent){
            createHouseholdByAgent();
            insert hhRecord;
            conRecord = [SELECT id from Contact where AccountId=:accRecord.Id];
            createACR(hhRecord.Id,conRecord.Id);
            insert acrRecord;
            Test.startTest(); 
            deleteACR(acrRecord.Id);
            delete acrRecord;
            Test.stopTest();
        }
        Account updatedAccount = [SELECT Id, Primary_Household__pc from Account WHERE Id=:accRecord.Id];
        system.assertEquals(NULL, updatedAccount.Primary_Household__pc, 'Primary Household Id is not removed');
        
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

    /*static testMethod void testBulkifyACRCreationWithAgentRoleAndAccountNote(){
        setup();
        Map<Id,Id> accountId_contactIdMap = new Map<Id,Id>();
        System.runAs(systemUser){
            createBULKAccounts();
            List<Id> listofAccountIds = new List<Id>();
            for(Account singleAccount:accountBulkList){
                listofAccountIds.add(singleAccount.Id);
            }
            
            accountBulkList = [Select Id, PersonContactId from Account Where Id IN :listofAccountIds];
            
            for (Account acnt:accountBulkList){
                accountId_contactIdMap.put(acnt.Id,acnt.PersonContactId);
            }
            
            dataSetupforAgentRole();*/
            
            /*
List<Account_Note__c> accountNoteList = new List<Account_Note__c>();
Account_Note__c accountNote1 = new Account_Note__c (Account__c = accRecord.id, Category__c ='Alert', comments__c='This is my first account note');
Account_Note__c accountNote2 = new Account_Note__c (Account__c = accRecord.id, Category__c ='General',comments__c='This is my second account note');
accountNoteList.add(accountNote1);
accountNoteList.add(accountNote2);
insert accountNoteList; */
       /* }
        System.runAs(testFSCHHUser){
            createFiveHousehold();
        }
        System.runAs(testFSCHHUser){
            Test.startTest(); 
            createBULKACR(accountId_contactIdMap);
            Test.stopTest();
        }
        
        List<Id> acntIdListforSmithHH = new List<Id>{accRecord1.Id,accRecord2.Id,accRecord3.Id,accRecord4.Id,accRecord5.Id};
            List<Account> updatedAccountforSmithHHList = [SELECT Id, Primary_Household__pc from Account WHERE Id IN :acntIdListforSmithHH];
        for(Account singleUpdatedAcnt : updatedAccountforSmithHHList){
            system.assertEquals(hhRecord1.id, singleUpdatedAcnt.Primary_Household__pc, 'Primary Household Id of Account is not matched with HH Id');
        }
        List<AgentRole__c> updatedAgentRoleforSmithHHList = [SELECT Id, Primary_Household__c from AgentRole__c WHERE customer__c IN:acntIdListforSmithHH];
        for (AgentRole__c singleAgentRole:updatedAgentRoleforSmithHHList){
            system.assertEquals(hhRecord1.id, singleAgentRole.Primary_Household__c, 'Primary Household Id of AgentRole is not matched with HH Id');
        }
        
        List<Id> acntIdListforGraphHH = new List<Id>{accRecord6.Id,accRecord7.Id,accRecord8.Id,accRecord9.Id};
            List<Account> updatedAccountforGraphHHList = [SELECT Id, Primary_Household__pc from Account WHERE Id IN :acntIdListforGraphHH];
        for(Account singleUpdatedAcnt : updatedAccountforGraphHHList){
            system.assertEquals(hhRecord2.id, singleUpdatedAcnt.Primary_Household__pc, 'Primary Household Id of Account is not matched with HH Id');
        }
        List<AgentRole__c> updatedAgentRoleforGraphHHList = [SELECT Id, Primary_Household__c from AgentRole__c WHERE customer__c IN:acntIdListforGraphHH];
        for (AgentRole__c singleAgentRole:updatedAgentRoleforGraphHHList){
            system.assertEquals(hhRecord2.id, singleAgentRole.Primary_Household__c, 'Primary Household Id of AgentRole is not matched with HH Id');
        }
        
        List<Id> acntIdListforChopraHH = new List<Id>{accRecord10.Id,accRecord11.Id,accRecord12.Id};
            List<Account> updatedAccountforChopraHHList = [SELECT Id, Primary_Household__pc from Account WHERE Id IN :acntIdListforChopraHH];
        for(Account singleUpdatedAcnt : updatedAccountforChopraHHList){
            system.assertEquals(hhRecord3.id, singleUpdatedAcnt.Primary_Household__pc, 'Primary Household Id of Account is not matched with HH Id');
        }
        List<AgentRole__c> updatedAgentRoleforChopraHHList = [SELECT Id, Primary_Household__c from AgentRole__c WHERE customer__c IN:acntIdListforChopraHH];
        for (AgentRole__c singleAgentRole:updatedAgentRoleforChopraHHList){
            system.assertEquals(hhRecord3.id, singleAgentRole.Primary_Household__c, 'Primary Household Id of AgentRole is not matched with HH Id');
        }
        
        List<Id> acntIdListforYoungHH = new List<Id>{accRecord13.Id,accRecord14.Id};
            List<Account> updatedAccountforYoungHHList = [SELECT Id, Primary_Household__pc from Account WHERE Id IN :acntIdListforYoungHH];
        for(Account singleUpdatedAcnt : updatedAccountforYoungHHList){
            system.assertEquals(hhRecord4.id, singleUpdatedAcnt.Primary_Household__pc, 'Primary Household Id of Account is not matched with HH Id');
        }
        List<AgentRole__c> updatedAgentRoleforYoungHHList = [SELECT Id, Primary_Household__c from AgentRole__c WHERE customer__c IN:acntIdListforYoungHH];
        for (AgentRole__c singleAgentRole:updatedAgentRoleforYoungHHList){
            system.assertEquals(hhRecord4.id, singleAgentRole.Primary_Household__c, 'Primary Household Id of AgentRole is not matched with HH Id');
        }
        
        Account updatedAccount = [SELECT Id, Primary_Household__pc from Account WHERE Id=:accRecord15.Id];
        system.assertEquals(hhRecord5.id, updatedAccount.Primary_Household__pc, 'Primary Household Id is not matched with HH Id');
        
        List<Account_Note__c> updatedAccountNoteList = [SELECT Id, Primary_Household__c from Account_Note__c WHERE Account__c=:accRecord15.Id];
        for (Account_Note__c singleAccountNote:updatedAccountNoteList){
            system.assertEquals(hhRecord5.id, singleAccountNote.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        } 
        
        
    }*/
    
    /**
    * @description This method is used for assign a particular PermissionSet to a particular User
    * @method assignPSet <This method is used to get Standard testUser>
    * @param testUser
    * @return PermissionSetAssignment
    */     
    public static PermissionSetAssignment assignPSet (User testUser){
        PermissionSet ps = [Select Id, Name FROM PermissionSet WHERE Name=:FSC_HOUSEHOLD_PERMISSION_SET_NAME];
        PermissionSetAssignment assignment = new PermissionSetAssignment(AssigneeId=testUser.Id,PermissionSetId=ps.Id);
        return assignment;
    }
    
    /**
     * @description This method is used to create individual account
     */
    public static void createAccount(){
        accRecord = new Account(FirstName='FSCtest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER);
    }
    
    /**
     * @description this method is used to create household account
     */
    public static void createHousehold(){
        hhRecord = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), FinServ__SourceSystemId__c = '45678');
    }
    
    /**
     * @description this method is used to create household by agent
     */
    public static void createHouseholdByAgent(){
        hhRecord = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), FinServ__SourceSystemId__c = '45678', AllowHousehold__c = true);
    }

    /*private static void createFiveHousehold(){
        hhRecord1 = new Account(Name='Smith Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId());
        hhRecord2 = new Account(Name='Graph Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId());
        hhRecord3 = new Account(Name='Chopra Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId());
        hhRecord4 = new Account(Name='Young Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId());
        hhRecord5 = new Account(Name='Salesforce Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId());
        List<Account> hhList = new List<Account>{hhRecord1,hhRecord2,hhRecord3,hhRecord4,hhRecord5};
            insert hhList;
    }*/
    
    /**
     * @description This method is used to create ACR record
     * @param acntId
     * @param conId
     */
    public static void createACR(Id acntId,Id conId){
        acrRecord = new AccountContactRelation(AccountId=acntId,ContactId=conId,FinServ__PrimaryGroup__c = true);
    }
    
    /*private static void createBULKACR(Map<Id,Id> acntIdContactIdMap){
        
        acrRecord1 = new AccountContactRelation(AccountId=hhRecord1.Id,ContactId=acntIdContactIdMap.get(accRecord1.id));
        acrRecord2 = new AccountContactRelation(AccountId=hhRecord1.Id,ContactId=acntIdContactIdMap.get(accRecord2.id));
        acrRecord3 = new AccountContactRelation(AccountId=hhRecord1.Id,ContactId=acntIdContactIdMap.get(accRecord3.id));
        acrRecord4 = new AccountContactRelation(AccountId=hhRecord1.Id,ContactId=acntIdContactIdMap.get(accRecord4.id));
        acrRecord5 = new AccountContactRelation(AccountId=hhRecord1.Id,ContactId=acntIdContactIdMap.get(accRecord5.id));
        
        acrRecord6 = new AccountContactRelation(AccountId=hhRecord2.Id,ContactId=acntIdContactIdMap.get(accRecord6.id));
        acrRecord7 = new AccountContactRelation(AccountId=hhRecord2.Id,ContactId=acntIdContactIdMap.get(accRecord7.id));
        acrRecord8 = new AccountContactRelation(AccountId=hhRecord2.Id,ContactId=acntIdContactIdMap.get(accRecord8.id));
        acrRecord9 = new AccountContactRelation(AccountId=hhRecord2.Id,ContactId=acntIdContactIdMap.get(accRecord9.id));
        
        acrRecord10 = new AccountContactRelation(AccountId=hhRecord3.Id,ContactId=acntIdContactIdMap.get(accRecord10.id));
        acrRecord11 = new AccountContactRelation(AccountId=hhRecord3.Id,ContactId=acntIdContactIdMap.get(accRecord11.id));
        acrRecord12 = new AccountContactRelation(AccountId=hhRecord3.Id,ContactId=acntIdContactIdMap.get(accRecord12.id));
        
        acrRecord13 = new AccountContactRelation(AccountId=hhRecord4.Id,ContactId=acntIdContactIdMap.get(accRecord13.id));
        acrRecord14 = new AccountContactRelation(AccountId=hhRecord4.Id,ContactId=acntIdContactIdMap.get(accRecord14.id));
        
        acrRecord15 = new AccountContactRelation(AccountId=hhRecord5.Id,ContactId=acntIdContactIdMap.get(accRecord15.id));
        List<AccountContactRelation> acrBulkList = new List<AccountContactRelation>{acrRecord1,acrRecord2,acrRecord3,
        acrRecord4,acrRecord5,acrRecord6,acrRecord7,acrRecord8,acrRecord9,acrRecord10,acrRecord11,acrRecord12,acrRecord13,
        acrRecord14,acrRecord15};
        insert acrBulkList;        
    }*/
    
    private static void deleteACR(Id acrRecordId){
        acrRecord = [SELECT Id from AccountContactRelation Where Id=:acrRecordId];
    }
    /*Private static void createBULKAccounts(){
        accountBulkList= new List<Account>{accRecord1,accRecord2,accRecord3,accRecord4,accRecord5,accRecord6,accRecord7,accRecord8,accRecord9,accRecord10,accRecord11,accRecord12,accRecord13,accRecord14,accRecord15};
        insert accountBulkList;
    }
    private static void dataSetupforAgentRole(){
        AgentRole__c agentRole1 = new AgentRole__c (customer__c = accRecord1.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
        AgentRole__c agentRole2 = new AgentRole__c (customer__c = accRecord1.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole3 = new AgentRole__c (customer__c = accRecord1.id, agent__c = salesRoleHierarchy3.Agent.id, RelationshipNature__c = 'Ex-Customer');
        AgentRole__c agentRole4 = new AgentRole__c (customer__c = accRecord2.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole5 = new AgentRole__c (customer__c = accRecord2.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole6 = new AgentRole__c (customer__c = accRecord3.id, agent__c = salesRoleHierarchy3.Agent.id, RelationshipNature__c = 'Ex-Customer');
        AgentRole__c agentRole7 = new AgentRole__c (customer__c = accRecord3.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole8 = new AgentRole__c (customer__c = accRecord3.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Ex-Customer');
        AgentRole__c agentRole9 = new AgentRole__c (customer__c = accRecord4.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
        AgentRole__c agentRole10 = new AgentRole__c (customer__c = accRecord5.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole11 = new AgentRole__c (customer__c = accRecord5.id, agent__c = salesRoleHierarchy3.Agent.id, RelationshipNature__c = 'Ex-Customer');
        AgentRole__c agentRole12 = new AgentRole__c (customer__c = accRecord6.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
        AgentRole__c agentRole13 = new AgentRole__c (customer__c = accRecord6.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole14 = new AgentRole__c (customer__c = accRecord7.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
        AgentRole__c agentRole15 = new AgentRole__c (customer__c = accRecord7.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Ex-Customer');
        AgentRole__c agentRole16 = new AgentRole__c (customer__c = accRecord7.id, agent__c = salesRoleHierarchy3.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole17 = new AgentRole__c (customer__c = accRecord8.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
        AgentRole__c agentRole18= new AgentRole__c (customer__c = accRecord8.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Ex-Customer');
        AgentRole__c agentRole19= new AgentRole__c (customer__c = accRecord9.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole20= new AgentRole__c (customer__c = accRecord10.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
        AgentRole__c agentRole21= new AgentRole__c (customer__c = accRecord10.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole22= new AgentRole__c (customer__c = accRecord11.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Ex-Customer');
        AgentRole__c agentRole23= new AgentRole__c (customer__c = accRecord11.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
        AgentRole__c agentRole24 = new AgentRole__c (customer__c = accRecord11.id, agent__c = salesRoleHierarchy3.Agent.id, RelationshipNature__c = 'Ex-Customer');
        AgentRole__c agentRole25 = new AgentRole__c (customer__c = accRecord12.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole26 = new AgentRole__c (customer__c = accRecord12.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
        AgentRole__c agentRole27 = new AgentRole__c (customer__c = accRecord13.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole28 = new AgentRole__c (customer__c = accRecord13.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
        AgentRole__c agentRole29 = new AgentRole__c (customer__c = accRecord13.id, agent__c = salesRoleHierarchy3.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole30= new AgentRole__c (customer__c = accRecord14.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Ex-Customer');
        AgentRole__c agentRole31 = new AgentRole__c (customer__c = accRecord14.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
        AgentRole__c agentRole32 = new AgentRole__c (customer__c = accRecord14.id, agent__c = salesRoleHierarchy3.Agent.id, RelationshipNature__c = 'Ex-Customer');
        AgentRole__c agentRole33= new AgentRole__c (customer__c = accRecord15.id, agent__c = salesRoleHierarchy2.Agent.id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole34= new AgentRole__c (customer__c = accRecord15.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
        AgentRole__c agentRole35= new AgentRole__c (customer__c = accRecord15.id, agent__c = salesRoleHierarchy3.Agent.id, RelationshipNature__c = 'Ex-Customer');
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>{agentRole1,agentRole2,agentRole3,agentRole4,agentRole5,agentRole6,agentRole7,
            agentRole8,agentRole9,agentRole10,agentRole11,agentRole13,agentRole14,agentRole15,agentRole16,agentRole17,agentRole18,agentRole19,agentRole20,
            agentRole21,agentRole22,agentRole23,agentRole24,agentRole25,agentRole26,agentRole27,agentRole28,agentRole29,agentRole30,agentRole31,
            agentRole32,agentRole33,agentRole34,agentRole35};
            insert agentRoleList;
    }*/

}