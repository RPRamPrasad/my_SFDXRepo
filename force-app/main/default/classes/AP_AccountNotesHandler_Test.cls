/**
* @author: Targaryen
* @owner: Targaryen
* @name: AP_AccountNotesHandler_Test
* @createdDate: 08/24/2020
* @description The test class will cover the code for AP_AccountNotesHandler.
* @version 1.0
*/
@isTest(seeAllData = false)
public class AP_AccountNotesHandler_Test {
    private static User systemUser;
    private static User testFSCHHUser;
    public static final String FSC_HOUSEHOLD_PERMISSION_SET_NAME ='SF_CRMDM_FSCHH_PermSetPID';
    public static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static PermissionSetAssignment psassignment;
    private static AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting;
    private static User agentUser;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;
    
    private static account accRecord1=new Account(FirstName='Monalisa',LastName='Watson',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHANO132');
    private static account accRecord2=new Account(FirstName='Neeta',LastName='Watson',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHANO765');
    private static account accRecord3=new Account(FirstName='Tim',LastName='Lopez',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHANO564');
    private static account accRecord4=new Account(FirstName='Jim',LastName='Lopez',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHANO987');        
    private static Account hhRecord1;
    private static Account hhRecord2;
    
    /** 
     * @description This method used setup test data
    */
    public static void setup() {
        systemUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('Alias','SystemSA','systemUser@statefarm.com');
        insert systemUser;
        testFSCHHUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        insert testFSCHHUser;
        psassignment = assignPSet(testFSCHHUser);
        insert psassignment;
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.Agent);

        System.runAs(systemUser){
            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
            insert sysAdminUserIdSetting;
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,systemUser);
            insert passTriggerAll;
            CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
            objectBasedByPassTrigger.Override_AccountNoteBeforeInsert__c = false;
            insert objectBasedByPassTrigger; 
        }
    }
    
    @isTest
    static void testAccountNoteWithSameHousehold(){
        setup();
        System.runAs(testFSCHHUser){
            hhRecord1 = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId());
            insert hhRecord1;

        }
        System.runAs(systemUser){
            accRecord1.Primary_Household__pc = hhRecord1.id;
            insert accRecord1;
            accRecord2.Primary_Household__pc = hhRecord1.id;
            insert accRecord2;
            
            List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accRecord1.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            AgentRole__c agentRole1 = new AgentRole__c (customer__c = accRecord2.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Prospect');
            agentRoleList.add(agentRole);
            agentRoleList.add(agentRole1);
            insert agentRoleList;

        }
        
           System.runAs(salesRoleHierarchy1.Agent){          
            Account_Note__c accountNote1 = new Account_Note__c(Account__c = accRecord1.Id, Category__c = 'Alert', Comments__c = 'Here is my comments');
            Account_Note__c accountNote2 = new Account_Note__c(Account__c = accRecord2.Id, Category__c = 'General', Comments__c = 'Here is my second comments');
            List<Account_Note__c> accountNoteList = new List<Account_Note__c>();
            accountNoteList.add(accountNote1);
            accountNoteList.add(accountNote2);
            Test.startTest(); 
            insert accountNoteList;
            Test.stopTest();
           }
        Account_Note__c createdAccountNote1 = [SELECT Primary_Household__c from Account_Note__c where Account__c = :accRecord1.Id ];
        system.assertEquals(hhRecord1.id, createdAccountNote1.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        Account_Note__c createdAccountNote2 = [SELECT Primary_Household__c from Account_Note__c where Account__c = :accRecord2.Id ];
        system.assertEquals(hhRecord1.id, createdAccountNote2.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
    }
    
    @isTest
    static void testAccountNoteWithDifferentHousehold(){
        setup();
        System.runAs(testFSCHHUser){
            hhRecord1 = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId());
            hhRecord2 = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId());
            insert hhRecord1;
            insert hhRecord2;

        }
        System.runAs(systemUser){
            accRecord1.Primary_Household__pc = hhRecord1.id;
            insert accRecord1;
            accRecord2.Primary_Household__pc = hhRecord1.id;
            insert accRecord2;
            accRecord3.Primary_Household__pc = hhRecord2.id;
            insert accRecord3;
            accRecord4.Primary_Household__pc = hhRecord2.id;
            insert accRecord4;
            
            List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accRecord1.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            AgentRole__c agentRole1 = new AgentRole__c (customer__c = accRecord2.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Prospect');
            AgentRole__c agentRole2 = new AgentRole__c (customer__c = accRecord3.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            AgentRole__c agentRole3 = new AgentRole__c (customer__c = accRecord4.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Prospect');
            agentRoleList.add(agentRole);
            agentRoleList.add(agentRole1);
            agentRoleList.add(agentRole2);
            agentRoleList.add(agentRole3);
            insert agentRoleList;

        }
        
           System.runAs(salesRoleHierarchy1.Agent){          
            Account_Note__c accountNote1 = new Account_Note__c(Account__c = accRecord1.Id, Category__c = 'Alert', Comments__c = 'Here is my comments');
            Account_Note__c accountNote2 = new Account_Note__c(Account__c = accRecord2.Id, Category__c = 'General', Comments__c = 'Here is my second comments');
            Account_Note__c accountNote3 = new Account_Note__c(Account__c = accRecord3.Id, Category__c = 'Alert', Comments__c = 'Here is my third comments');
            Account_Note__c accountNote4 = new Account_Note__c(Account__c = accRecord4.Id, Category__c = 'General', Comments__c = 'Here is my fourth comments');   
            List<Account_Note__c> accountNoteList = new List<Account_Note__c>();
            accountNoteList.add(accountNote1);
            accountNoteList.add(accountNote2);
            accountNoteList.add(accountNote3);
            accountNoteList.add(accountNote4);
            Test.startTest(); 
            insert accountNoteList;
            Test.stopTest();
           }
        Account_Note__c createdAccountNote1 = [SELECT Primary_Household__c from Account_Note__c where Account__c = :accRecord1.Id ];
        system.assertEquals(hhRecord1.id, createdAccountNote1.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        Account_Note__c createdAccountNote2 = [SELECT Primary_Household__c from Account_Note__c where Account__c = :accRecord2.Id ];
        system.assertEquals(hhRecord1.id, createdAccountNote2.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        Account_Note__c createdAccountNote3 = [SELECT Primary_Household__c from Account_Note__c where Account__c = :accRecord3.Id ];
        system.assertEquals(hhRecord2.id, createdAccountNote3.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        Account_Note__c createdAccountNote4 = [SELECT Primary_Household__c from Account_Note__c where Account__c = :accRecord4.Id ];
        system.assertEquals(hhRecord2.id, createdAccountNote4.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
    }
    
        @isTest
        static void testAccountNoteWithNoHousehold(){
        setup();

        System.runAs(systemUser){
            insert accRecord1;
            insert accRecord2;
            
            List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accRecord1.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            AgentRole__c agentRole1 = new AgentRole__c (customer__c = accRecord2.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Prospect');
            agentRoleList.add(agentRole);
            agentRoleList.add(agentRole1);
            insert agentRoleList;

        }
        
           System.runAs(salesRoleHierarchy1.Agent){          
            Account_Note__c accountNote1 = new Account_Note__c(Account__c = accRecord1.Id, Category__c = 'Alert', Comments__c = 'Here is my comments');
            Account_Note__c accountNote2 = new Account_Note__c(Account__c = accRecord2.Id, Category__c = 'General', Comments__c = 'Here is my second comments');
            List<Account_Note__c> accountNoteList = new List<Account_Note__c>();
            accountNoteList.add(accountNote1);
            accountNoteList.add(accountNote2);
            Test.startTest(); 
            insert accountNoteList;
            Test.stopTest();
           }
        Account_Note__c createdAccountNote1 = [SELECT Primary_Household__c from Account_Note__c where Account__c = :accRecord1.Id ];
        system.assertEquals(NULL, createdAccountNote1.Primary_Household__c, 'Primary Household Id is not NULL');
        Account_Note__c createdAccountNote2 = [SELECT Primary_Household__c from Account_Note__c where Account__c = :accRecord2.Id ];
        system.assertEquals(NULL, createdAccountNote2.Primary_Household__c, 'Primary Household Id is not NULL');
    }

    /**
    * @description This method is used for assign a particular PermissionSet to a particular User
    * @Method: assignPSet <This method is used to get Standard testUser>
    * @param testUser
    * @return PermissionSetAssignment
    */     
    private static PermissionSetAssignment assignPSet (User testUser){
        PermissionSet ps = [Select Id, Name FROM PermissionSet WHERE Name=:FSC_HOUSEHOLD_PERMISSION_SET_NAME];
        return new PermissionSetAssignment(AssigneeId=testUser.Id,PermissionSetId=ps.Id);
        
    }
}