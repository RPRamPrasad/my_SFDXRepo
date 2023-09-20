/**
* @author: Targaryen
* @owner: Targaryen
* @name: AP_ProductsServicedByMeHandler_Test
* @createdDate: 11/10/2020
* @description The test class will cover the code for AP_AccountNotesHandler.
* @version 1.0
*/
@isTest(seeAllData = false)
public class AP_ProductsServicedByMeHandler_Test {
    private static User systemUser;
    private static User testFSCHHUser;
    public static final String FSC_HOUSEHOLD_PERMISSION_SET_NAME ='SF_CRMDM_FSCHH_PermSetPID';
    public static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static PermissionSetAssignment psassignment;
    private static AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting;
    private static User agentUser;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;

    
    private static account accRecord1=new Account(FirstName='Tracey',LastName='Watson',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHC2C132');
    private static account accRecord2=new Account(FirstName='Tim',LastName='Watson',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHC2C765');
    private static account accRecord3=new Account(FirstName='Tim',LastName='Lopez',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHANO564');
    private static account accRecord4=new Account(FirstName='Jim',LastName='Lopez',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHANO987'); 
    private static Account hhRecord1;
    private static Account hhRecord2;
    
    /**
     * @description This method will create test data
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
            CS001_ByPassTriggerGtoZ__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerGtoZ(systemUser);
            objectBasedByPassTrigger.Override_ProductServicedByMeBeforeInsert__c = false;
            insert objectBasedByPassTrigger; 
        }
    }
    
    @isTest
    static void testProductsServicedByMeWithSameHousehold(){
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
            ProductsServicedByMe__c psbm1 = new ProductsServicedByMe__c(customer__c=accRecord1.Id,ProductType__c='Disability Income',
                                                                    CarrierName__c='Trupanion',ProductLine__c='Health',Agent__c=salesRoleHierarchy1.Agent.id);
            ProductsServicedByMe__c psbm2 = new ProductsServicedByMe__c(customer__c=accRecord2.Id,ProductType__c='Motorcycle',
                                                                    CarrierName__c='Assigned Risk/JUA',ProductLine__c='Auto',Agent__c=salesRoleHierarchy1.Agent.id);
            List<ProductsServicedByMe__c> psbmList = new List<ProductsServicedByMe__c>();
            psbmList.add(psbm1);
            psbmList.add(psbm2);
            Test.startTest(); 
            insert psbmList;
            Test.stopTest();
           }
        ProductsServicedByMe__c createdpsbm1 = [SELECT Primary_Household__c from ProductsServicedByMe__c where customer__c = :accRecord1.Id ];        
        system.assertEquals(hhRecord1.id, createdpsbm1.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        ProductsServicedByMe__c createdpsbm2 = [SELECT Primary_Household__c from ProductsServicedByMe__c where customer__c = :accRecord2.Id ];
        system.assertEquals(hhRecord1.id, createdpsbm2.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
    }
    
    @isTest
    static void testProductsServicedByMeWithDifferentHousehold(){
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
            ProductsServicedByMe__c psbm1 = new ProductsServicedByMe__c(customer__c=accRecord1.Id,ProductType__c='Motorcycle',
                                                                        CarrierName__c='Assigned Risk/JUA',ProductLine__c='Auto',Agent__c=salesRoleHierarchy1.Agent.id);
            ProductsServicedByMe__c psbm2 = new ProductsServicedByMe__c(customer__c=accRecord2.Id,ProductType__c='Disability Income',
                                                                        CarrierName__c='Trupanion',ProductLine__c='Health',Agent__c=salesRoleHierarchy1.Agent.id);
            ProductsServicedByMe__c psbm3 = new ProductsServicedByMe__c(customer__c=accRecord3.Id,ProductType__c='School & Church Bus',
                                                                        CarrierName__c='Assigned Risk/JUA',ProductLine__c='Auto',Agent__c=salesRoleHierarchy1.Agent.id);
            ProductsServicedByMe__c psbm4 = new ProductsServicedByMe__c(customer__c=accRecord4.Id,ProductType__c='Disability Income',
                                                                        CarrierName__c='Trupanion',ProductLine__c='Health',Agent__c=salesRoleHierarchy1.Agent.id);   
            List<ProductsServicedByMe__c> psbmList = new List<ProductsServicedByMe__c>();
            psbmList.add(psbm1);
            psbmList.add(psbm2);
            psbmList.add(psbm3);
            psbmList.add(psbm4);
            Test.startTest(); 
            insert psbmList;
            Test.stopTest();
        }
        ProductsServicedByMe__c createdpsbm1 = [SELECT Primary_Household__c from ProductsServicedByMe__c where customer__c = :accRecord1.Id ];
        system.assertEquals(hhRecord1.id, createdpsbm1.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        ProductsServicedByMe__c createdpsbm2 = [SELECT Primary_Household__c from ProductsServicedByMe__c where customer__c = :accRecord2.Id ];
        system.assertEquals(hhRecord1.id, createdpsbm2.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        ProductsServicedByMe__c createdpsbm3 = [SELECT Primary_Household__c from ProductsServicedByMe__c where customer__c = :accRecord3.Id ];
        system.assertEquals(hhRecord2.id, createdpsbm3.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        ProductsServicedByMe__c createdpsbm4 = [SELECT Primary_Household__c from ProductsServicedByMe__c where customer__c = :accRecord4.Id ];
        system.assertEquals(hhRecord2.id, createdpsbm4.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
    }
    
    @isTest
    static void testProductsServicedByMeWithNoHousehold(){
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
            ProductsServicedByMe__c psbm1 = new ProductsServicedByMe__c(customer__c=accRecord1.Id,ProductType__c='Motorcycle',
                                                                        CarrierName__c='Assigned Risk/JUA',ProductLine__c='Auto',Agent__c=salesRoleHierarchy1.Agent.id);
            ProductsServicedByMe__c psbm2 = new ProductsServicedByMe__c(customer__c=accRecord2.Id,ProductType__c='Disability Income',
                                                                        CarrierName__c='Trupanion',ProductLine__c='Health',Agent__c=salesRoleHierarchy1.Agent.id);
            List<ProductsServicedByMe__c> psbmList = new List<ProductsServicedByMe__c>();
            psbmList.add(psbm1);
            psbmList.add(psbm2);
            Test.startTest(); 
            insert psbmList;
            Test.stopTest();
        }
        ProductsServicedByMe__c createdpsbm1 = [SELECT Primary_Household__c from ProductsServicedByMe__c where customer__c = :accRecord1.Id ];
        system.assertEquals(NULL, createdpsbm1.Primary_Household__c, 'Primary Household Id is not NULL');
        ProductsServicedByMe__c createdpsbm2 = [SELECT Primary_Household__c from ProductsServicedByMe__c where customer__c = :accRecord2.Id ];
        system.assertEquals(NULL, createdpsbm2.Primary_Household__c, 'Primary Household Id is not NULL');
    }
    
    @isTest
    static void testProductsServicedByMeUpdateCustomer(){
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
            ProductsServicedByMe__c psbm1 = new ProductsServicedByMe__c(customer__c=accRecord1.Id,ProductType__c='Motorcycle',
                                                                        CarrierName__c='Assigned Risk/JUA',ProductLine__c='Auto',Agent__c=salesRoleHierarchy1.Agent.id);
            ProductsServicedByMe__c psbm2 = new ProductsServicedByMe__c(customer__c=accRecord2.Id,ProductType__c='Disability Income',
                                                                        CarrierName__c='Trupanion',ProductLine__c='Health',Agent__c=salesRoleHierarchy1.Agent.id);
            ProductsServicedByMe__c psbm3 = new ProductsServicedByMe__c(customer__c=accRecord3.Id,ProductType__c='School & Church Bus',
                                                                        CarrierName__c='Assigned Risk/JUA',ProductLine__c='Auto',Agent__c=salesRoleHierarchy1.Agent.id);
            ProductsServicedByMe__c psbm4 = new ProductsServicedByMe__c(customer__c=accRecord4.Id,ProductType__c='Disability Income',
                                                                        CarrierName__c='Trupanion',ProductLine__c='Health',Agent__c=salesRoleHierarchy1.Agent.id);   
            List<ProductsServicedByMe__c> psbmList = new List<ProductsServicedByMe__c>();
            psbmList.add(psbm1);
            psbmList.add(psbm2);
            psbmList.add(psbm3);
            psbmList.add(psbm4);
            
            insert psbmList;
           
        }
        
        System.runAs(salesRoleHierarchy1.Agent){ 
            List<ProductsServicedByMe__c> updatedPsbmList = new List<ProductsServicedByMe__c>();
            ProductsServicedByMe__c updatepsbm3 = [SELECT Id, Customer__c,Primary_Household__c from ProductsServicedByMe__c where customer__c = :accRecord3.Id ];
            updatepsbm3.Customer__c = accRecord1.Id;
            ProductsServicedByMe__c updatepsbm4 = [SELECT Id, Primary_Household__c from ProductsServicedByMe__c where customer__c = :accRecord4.Id ];
            updatepsbm4.Customer__c = accRecord2.Id;
            updatedPsbmList.add(updatepsbm3);
            updatedPsbmList.add(updatepsbm4);
            
            Test.startTest(); 
            update updatedPsbmList;
            Test.stopTest(); 
        }
        
        
        List<ProductsServicedByMe__c> createdpsbm1 = [SELECT Primary_Household__c from ProductsServicedByMe__c where customer__c = :accRecord1.Id ];
        system.assertEquals(hhRecord1.id, createdpsbm1.get(0).Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        system.assertEquals(hhRecord1.id, createdpsbm1.get(1).Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        List<ProductsServicedByMe__c> createdpsbm3 = [SELECT Primary_Household__c from ProductsServicedByMe__c where customer__c = :accRecord2.Id ];
        system.assertEquals(hhRecord1.id, createdpsbm3.get(0).Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        system.assertEquals(hhRecord1.id, createdpsbm3.get(1).Primary_Household__c, 'Primary Household Id is not matched with HH Id');
    }
  /**
    * This method is used for assign a particular PermissionSet to a particular User
    * @Method: assignPSet <This method is used to get Standard testUser>
    * @description Assign PSet
    * @param testUser
    * @return PermissionSetAssignment
    */     
    private static PermissionSetAssignment assignPSet (User testUser){
        PermissionSet ps = [Select Id, Name FROM PermissionSet WHERE Name=:FSC_HOUSEHOLD_PERMISSION_SET_NAME];
        return new PermissionSetAssignment(AssigneeId=testUser.Id,PermissionSetId=ps.Id);
    }
}