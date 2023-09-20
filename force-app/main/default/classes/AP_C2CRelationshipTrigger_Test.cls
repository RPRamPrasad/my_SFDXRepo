/**
* @author: Targaryen
* @owner: Targaryen
* @name: AP_C2CRelationshipTrigger_Test
* @createdDate: 08/05/2020
* @description The test class will cover the code for AP_C2CRelationshipTrigger.
* @version 1.0
*/

@isTest(seeAllData = false)
public class AP_C2CRelationshipTrigger_Test {
    private static User systemUser;
    private static User testFSCHHUser;
    public static final String FSC_HOUSEHOLD_PERMISSION_SET_NAME ='SF_CRMDM_FSCHH_PermSetPID';
    public static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static PermissionSetAssignment psassignment;
    private static AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting;
    private static User agentUser;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;
   // private static TestData_SalesRoleHierarchy salesRoleHierarchy2;
    
    private static account accRecord1=new Account(FirstName='Tracey',LastName='Watson',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHC2C132');
    private static account accRecord2=new Account(FirstName='Tim',LastName='Watson',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHC2C765');
    private static account accRecord3=new Account(FirstName='Tom',LastName='Lopez',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHC2C564');
    private static account accRecord4=new Account(FirstName='John',LastName='Jonas',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHC2C987');        
    private static Account hhRecord1;
    private static Account hhRecord2;
    private static Account hhRecord3;
    
    /**
     * @description This method will setup test data
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
        //salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('U');
        System.runAs(systemUser){
            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
            insert sysAdminUserIdSetting;
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,systemUser);
            insert passTriggerAll;
            CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
            objectBasedByPassTrigger.Override_C2CRelationshipBeforeInsert__c = false;
            insert objectBasedByPassTrigger; 
        }
    }

    public static void testDataSetup(boolean isAddlData) {
        System.runAs(systemUser){

            if(isAddlData){
                System.runAs(testFSCHHUser){
                    hhRecord1 = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId());
                    insert hhRecord1;
        
                }

                accRecord1.Primary_Household__pc = hhRecord1.id;
                accRecord2.Primary_Household__pc = hhRecord1.id;    
            }

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
            Relationship__c oneWayRelation = new Relationship__c(AccountTwo__c = accRecord1.Id, RelationshipType__c = 'Spouse', AccountOne__c = accRecord2.Id, RelationshipIdentifier__c ='FSCHHC2C132~FSCHHC2C987');
            Relationship__c twoWayRelation = new Relationship__c(AccountTwo__c = accRecord2.Id, RelationshipType__c = 'Spouse', AccountOne__c = accRecord1.Id, RelationshipIdentifier__c ='FSCHHC2C987~FSCHHC2C132');
            List<Relationship__c> relationshipList = new List<Relationship__c>();
            relationshipList.add(oneWayRelation);
            relationshipList.add(twoWayRelation);
            Test.startTest(); 
            insert relationshipList;
            Test.stopTest();
        }
    }
    
    @isTest
    static void testC2CRelationshipWithSameHousehold(){
        setup();

        testDataSetup(true);

        Relationship__c createdRelationship1 = [SELECT Primary_Household__c from Relationship__c where AccountTwo__c = :accRecord1.Id ];
        system.assertEquals(hhRecord1.id, createdRelationship1.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        Relationship__c createdRelationship2 = [SELECT Primary_Household__c from Relationship__c where AccountTwo__c = :accRecord2.Id ];
        system.assertEquals(hhRecord1.id, createdRelationship2.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
    }
    
    @isTest
    static void testC2CRelationshipWithDifferentHousehold(){
        setup();
        System.runAs(testFSCHHUser){            
            hhRecord2 = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId());
            hhRecord3 = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId());
           
            insert hhRecord2;
            insert hhRecord3;

        }
        System.runAs(systemUser){
            accRecord3.Primary_Household__pc = hhRecord2.id;
            insert accRecord3;
            accRecord4.Primary_Household__pc = hhRecord3.id;
            insert accRecord4;
            
            List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accRecord3.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            AgentRole__c agentRole1 = new AgentRole__c (customer__c = accRecord4.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Prospect');
            agentRoleList.add(agentRole);
            agentRoleList.add(agentRole1);
            insert agentRoleList;

        }
        
           System.runAs(salesRoleHierarchy1.Agent){          
            Relationship__c oneWayRelation = new Relationship__c(AccountTwo__c = accRecord3.Id, RelationshipType__c = 'Co-worker', AccountOne__c = accRecord4.Id, RelationshipIdentifier__c ='FSCHHC2C564~FSCHHC2C765');
            Relationship__c twoWayRelation = new Relationship__c(AccountTwo__c = accRecord4.Id, RelationshipType__c = 'Co-worker', AccountOne__c = accRecord3.Id, RelationshipIdentifier__c ='FSCHHC2C765~FSCHHC2C564');
            List<Relationship__c> relationshipList = new List<Relationship__c>();
            relationshipList.add(oneWayRelation);
            relationshipList.add(twoWayRelation);
            Test.startTest(); 
            insert relationshipList;
            Test.stopTest();
           }
        Relationship__c createdRelationship3 = [SELECT Primary_Household__c from Relationship__c where AccountTwo__c = :accRecord3.Id ];
        system.assertEquals(hhRecord2.id, createdRelationship3.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
        Relationship__c createdRelationship4 = [SELECT Primary_Household__c from Relationship__c where AccountTwo__c = :accRecord4.Id ];
        system.assertEquals(hhRecord3.id, createdRelationship4.Primary_Household__c, 'Primary Household Id is not matched with HH Id');
    }
    
    @isTest
    static void testC2CRelationshipWithNoHousehold(){
        setup();

        testDataSetup(false);

        Relationship__c createdRelationship1 = [SELECT Primary_Household__c from Relationship__c where AccountTwo__c = :accRecord1.Id ];
        system.assertEquals(NULL, createdRelationship1.Primary_Household__c, 'Primary Household Id is not NULL');
        Relationship__c createdRelationship2 = [SELECT Primary_Household__c from Relationship__c where AccountTwo__c = :accRecord2.Id ];
        system.assertEquals(NULL, createdRelationship2.Primary_Household__c, 'Primary Household Id is not NULL');
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