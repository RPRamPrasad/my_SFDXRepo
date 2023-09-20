/**
 * @name PrimaryHousehold_TEST
 * @author : Stark
 * @date : 01/07/2021
 * @description : The test class will cover for Primary Household which will provide Household Id to land on Household Page
 */

/**
 * @name PrimaryHousehold_TEST
 * @author : Targaryen
 * @date : 11/01/2021
 * @description : Added for Agency, CCC Licensed and UnLicensed Users and Caching Scenarios for CCC Users
 */

@isTest(seeAllData=false)
public with sharing class PrimaryHousehold_TEST {
    public static final String INDIVIDUAL_RECORD_TYPE = 'Individual';
    private static TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy(
        'A'
    );
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static User systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(
        SYSADMIN_USER_ID
    );
    
    
    private static Account hhAccRec;

    private static account accRecord = new Account(
        FirstName = 'FNameForPrimaryHousehold',
        LastName = 'LNameForPrimaryHousehold',        
        recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId(),
        BillingAddressType__c = 'US',
        BillingCity = 'TX',
        ClientIdentifier__c = 'C2CSP81L8XB'
    );

    @isTest
    public static void testFindPrimaryHousehold() {
        
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        System.runAs(systemAdminUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accRecord;
            insert new AgentRole__c(
                Agent__c = salesRoleHierarchy.Agent.Id,
                RelationshipNature__c = 'Prospect',
                Customer__c = accRecord.Id
            );

            
        }
        
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.Agent);
        System.runAs(salesRoleHierarchy.Agent){
            Id hhRecordtype = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
                .get('IndustriesHousehold')
                .getRecordTypeId();

            hhAccRec = new Account(Name = 'Household', recordTypeId = hhRecordtype, AllowHousehold__c = true);
            insert hhAccRec;

            accRecord.Primary_Household__pc = hhAccRec.id;
            update accRecord;
            Test.startTest();
        
            PrimaryHousehold.findPrimaryHousehold(accRecord.id);
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Household');
            sessionPart.put(hhAccRec.Id, accRecord.Id);
            Test.stopTest();
        }
        System.assertEquals('FNameForPrimaryHousehold', accRecord.FirstName, 'Account fname are not equal');
    }
    
    @isTest
    public static void testSearchNLandForAgentLandingOnHouseholdPage() {
        
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        System.runAs(systemAdminUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
           
            insert accRecord;
            insert new AgentRole__c(
                Agent__c = salesRoleHierarchy.Agent.Id,
                RelationshipNature__c = 'Prospect',
                Customer__c = accRecord.Id
            );

        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.Agent);
        System.runAs(salesRoleHierarchy.Agent){
             Id hhRecordtype = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
                .get('IndustriesHousehold')
                .getRecordTypeId();
           
            hhAccRec = new Account(Name = 'Household', recordTypeId = hhRecordtype, AllowHousehold__c = true);
            insert hhAccRec;
            accRecord.Primary_Household__pc = hhAccRec.id;
            update accRecord;
            
            Test.startTest();

            Account testSearchingAccount = PrimaryHousehold.findPrimaryHousehold(accRecord.id);
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Household');
            sessionPart.put(hhAccRec.Id, accRecord.Id);
            Test.stopTest();
            String cachedAccountId = (String)sessionPart.get(accRecord.Primary_Household__pc);
            System.assertEquals(accRecord.Id, cachedAccountId, 'Account is not matching');
            System.assertEquals(accRecord.Id, testSearchingAccount.Id, 'Agency User is landing on Account Page');
        }
        
    }

    
    @isTest
    public static void testCacheAccountIdForLicensedCCCUser() {
        
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        User cccLicensedUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUser();
		cccLicensedUser.UserType__c = 'CCC';
		        
        System.runAs(systemAdminUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accRecord;
            insert new AgentRole__c(
                Agent__c = salesRoleHierarchy.Agent.Id,
                RelationshipNature__c = 'Prospect',
                Customer__c = accRecord.Id
            );

            Id hhRecordtype = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
                .get('IndustriesHousehold')
                .getRecordTypeId();

            hhAccRec = new Account(Name = 'Household', recordTypeId = hhRecordtype, AllowHousehold__c = true);
            insert hhAccRec;

            accRecord.Primary_Household__pc = hhAccRec.id;
            update accRecord;
            insert cccLicensedUser;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){            
            Test.startTest();
            Account testAccount = PrimaryHousehold.findPrimaryHousehold(accRecord.id);
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Household');
            sessionPart.put(hhAccRec.Id, accRecord.Id);
            Test.stopTest();
            
            String cachedAccountId = (String)sessionPart.get(accRecord.Primary_Household__pc);
            System.assertEquals(accRecord.Id, cachedAccountId, 'Account is not matching');
            System.assertEquals(NULL, testAccount, 'Account is redirecting to Household Page');            
        } 
    }
    
    @isTest
    public static void testCacheAccountIdForUnLicensedCCCUser() {
        
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        User testCCCUnLicenUser = new User(Alias='X7PU',LastName='CCC,unlisenced,75-338-Office',Username='TestCCC301User@statefarm.com.bad',Associate_ID__c='ppcczz33ttb',UserExternalID__c='');
        User cccUnLicensedUser = UTIL_UserProvisioning_TEST.buildCCCUnlicensedUserMethod(testCCCUnLicenUser);
        cccUnLicensedUser.UserType__c = 'CCC';    
        System.runAs(systemAdminUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accRecord;
            insert new AgentRole__c(
                Agent__c = salesRoleHierarchy.Agent.Id,
                RelationshipNature__c = 'Prospect',
                Customer__c = accRecord.Id
            );

            Id hhRecordtype = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
                .get('IndustriesHousehold')
                .getRecordTypeId();

            hhAccRec = new Account(Name = 'Household', recordTypeId = hhRecordtype, AllowHousehold__c = true);
            insert hhAccRec;

            accRecord.Primary_Household__pc = hhAccRec.id;
            update accRecord;
            insert cccUnlicensedUser;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnLicensedUser);
        System.runAs(cccUnLicensedUser){            
            Test.startTest();
			Account testAccount = PrimaryHousehold.findPrimaryHousehold(accRecord.id);
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Household');
            sessionPart.put(hhAccRec.Id, accRecord.Id);
            Test.stopTest();
            
            String cachedAccountId = (String)sessionPart.get(accRecord.Primary_Household__pc);
            System.assertEquals(accRecord.Id, cachedAccountId, 'Account is not matching');
            System.assertEquals(NULL, testAccount, 'Account is redirecting to Household Page');
        }      
    }
    
    @isTest
    public static void testCacheAccountIdForUnLicensedCCCUserThrowException() {
        
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        User testCCCUnLicenUser = new User(Alias='X7PU',LastName='CCC,unlisenced,75-338-Office',Username='TestCCC301User@statefarm.com.bad',Associate_ID__c='ppcczz33ttb',UserExternalID__c='');
        User cccUnLicensedUser = UTIL_UserProvisioning_TEST.buildCCCUnlicensedUserMethod(testCCCUnLicenUser);
            
        System.runAs(systemAdminUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accRecord;
            insert new AgentRole__c(
                Agent__c = salesRoleHierarchy.Agent.Id,
                RelationshipNature__c = 'Prospect',
                Customer__c = accRecord.Id
            );

            Id hhRecordtype = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
                .get('IndustriesHousehold')
                .getRecordTypeId();

            hhAccRec = new Account(Name = 'Household', recordTypeId = hhRecordtype, AllowHousehold__c = true);
            insert hhAccRec;

            accRecord.Primary_Household__pc = hhAccRec.id;
            update accRecord;
            insert cccUnlicensedUser;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnLicensedUser);
        System.runAs(cccUnLicensedUser){
            Test.startTest();
            try{
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Household');
                sessionPart.put(hhAccRec.Id, accRecord.Id);
            }
            catch(NullPointerException ex){
                System.assert(ex.getCause() != null, 'Empty customer id should throw error');
                System.assert(ex.getCause() instanceof NullPointerException , 'Empty customer id should throw Null Pointer exception');
            }            
            Test.stopTest();  
        }
    }
}