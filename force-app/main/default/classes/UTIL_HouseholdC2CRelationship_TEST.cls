@isTest(seeAllData=false)
public with sharing class UTIL_HouseholdC2CRelationship_TEST {
    private static User systemUser;
    private static final String CLIENT_IDENTIFIER1 = 'IAMCLIENT11';
    private static final String CLIENT_IDENTIFIER2 = 'IAMCLIENT12';
    private static final String AGENT1_ASSOCID = 'IAMASSCID1A';
    private static Account accrecord;
    private static Account accrecord1;
    private static Account accrecord2;
    private static Account hhAccRec;
    private static CS001_ByPassTriggerAll__c accountbypass;
    private static List<Account> accountLst = new List<Account>();
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;
    private static User testFSCHHUser;
    
        
/**
 *@description Setup method used for building test data (must be called at beginning of test)
* @name   testDataSetup
*/
    public static void testDataSetup() {
        systemUser = UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');        
        accountbypass = new CS001_ByPassTriggerAll__c(Override_All__c = true);
        insert accountbypass;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');        
        testFSCHHUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        insert testFSCHHUser;
    }
    
    @isTest
    static void testfindHouseholdMembers() {
        testDataSetup();        
        System.runAs(systemUser) {
            createAccounts();
            insert accountLst;            
            AgentRole__c agentRole = new AgentRole__c(
                customer__c = accRecord.id,
                agent__c = salesRoleHierarchy1.Agent.id,
                RelationshipNature__c = 'Customer');
            insert agentRole;
            createHousehold();
            insert hhAccRec;
            updateAccountsWithHHId();
            update accountlst;            
            Relationship__c relationshipRecord = new Relationship__c();
            relationshipRecord.AccountTwo__c = accrecord.id;
            relationshipRecord.AccountOne__c = accrecord1.id;
            relationshipRecord.RelationshipType__c = 'Parent';
            relationshipRecord.RelationshipIdentifier__c =
                accrecord.ClientIdentifier__c +
                '~' +
                accrecord1.ClientIdentifier__c;
            relationshipRecord.Primary_Household__c = hhAccRec.id;
            insert relationshipRecord;
            List<AccountContactRelation> acrs = new List<AccountContactRelation>();           
            for (Account acc : [SELECT id, (SELECT id FROM Contacts)
                                FROM Account
                                WHERE Primary_Household__pc = :hhAccRec.id]) {
                                    AccountContactRelation acr = new AccountContactRelation(
                                        ContactId = acc.Contacts.get(0).Id,
                                        AccountId = hhAccRec.id,
                                        IsActive = true,
                                        FinServ__PrimaryGroup__c = true);
                                    acrs.add(acr);
                                }
            insert acrs;            
        }        
        Test.startTest();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.household');
        sessionPart.put(hhAccRec.id, accRecord.Id);  
        //List<Contact> accountcontacts = AP_C2CRelationship.findHouseholdMembers(hhAccRec.id);
        UTIL_HouseholdC2CRelationship.MembershipWrap accountcontacts = UTIL_HouseholdC2CRelationship.findHouseholdMembers(hhAccRec.id);
        Test.stopTest();        
        System.assertEquals(2, accountcontacts.conRecs.size(), 'Customer Group Members are not found');         
    }
    
    @isTest
    static void testfindHouseholdMembersWithNoCache() {
        testDataSetup();        
        System.runAs(systemUser) {
            createAccounts();
            insert accountLst;
            AgentRole__c agentRole = new AgentRole__c(
                customer__c = accRecord.id,
                agent__c = salesRoleHierarchy1.Agent.id,
                RelationshipNature__c = 'Customer'
            );
            insert agentRole;
            createHousehold();
            insert hhAccRec;
            updateAccountsWithHHId();
            update accountlst;
            
            Relationship__c relationshipRecord = new Relationship__c();
            relationshipRecord.AccountTwo__c = accrecord.id;
            relationshipRecord.AccountOne__c = accrecord1.id;
            relationshipRecord.RelationshipType__c = 'Parent';
            relationshipRecord.RelationshipIdentifier__c =
                accrecord.ClientIdentifier__c +
                '~' +
                accrecord1.ClientIdentifier__c;
            relationshipRecord.Primary_Household__c = hhAccRec.id;
            insert relationshipRecord;
            
            List<AccountContactRelation> acrs = new List<AccountContactRelation>();
            for (Account acc : [
                SELECT id, (SELECT id FROM Contacts)
                FROM Account
                WHERE Primary_Household__pc = :hhAccRec.id
            ]) {
                AccountContactRelation acr = new AccountContactRelation(
                    ContactId = acc.Contacts.get(0).Id,
                    AccountId = hhAccRec.id,
                    IsActive = true,
                    FinServ__PrimaryGroup__c = true
                );
                acrs.add(acr);
            }
            insert acrs;            
            
            Test.startTest();
            UTIL_HouseholdC2CRelationship.MembershipWrap accountcontacts = UTIL_HouseholdC2CRelationship.findHouseholdMembers(hhAccRec.id);
            Test.stopTest();
            System.assertEquals(2, accountcontacts.conRecs.size(), 'Customer Group Members are not found');          
        }        
    }
    
   
    private static void createAccounts() {
        accrecord = new Account(
            FirstName = 'Ftest1',
            LastName = 'Ltest1',
            BillingAddressType__c = 'US',
            ClientIdentifier__c = CLIENT_IDENTIFIER1
        );
        accrecord1 = new Account(
            FirstName = 'Ftest2',
            LastName = 'Ltest2',
            BillingAddressType__c = 'US',
            ClientIdentifier__c = CLIENT_IDENTIFIER2
        );
        
        accountLst.add(accrecord);
        accountLst.add(accrecord1);
    }
    
    private static void createHousehold() {        
        Id hhRecordtype = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
            .get('IndustriesHousehold')
            .getRecordTypeId();
        hhAccRec = new Account(Name = 'Household', recordTypeId = hhRecordtype, AllowHousehold__c = true);
    }
    
    private static void updateAccountsWithHHId() {
        for (Account acc : accountLst) {
            acc.Primary_Household__pc = hhAccRec.id;
        }
    }
}
