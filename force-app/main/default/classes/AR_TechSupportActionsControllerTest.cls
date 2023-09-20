/**
* Author : Team Kraken
* Date Created : 4/20/2020
* @description : Test class for AR_TechSupportActionsController Apex class
* Version : 1.0
*/
@isTest(SeeAllData=false)
public class AR_TechSupportActionsControllerTest {
    
    @TestSetup
    static void setupData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('1701A','systemUser','systemUserTest@statefarm.com'); 
        insert systemAdmin;

        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false, systemAdmin);
        insert passTriggerAll;

        CS001_ByPassTriggerAtoF__c objectBasedByPassTriggerAtoF = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemAdmin);
        insert objectBasedByPassTriggerAtoF;

        CS001_ByPassTriggerGtoZ__c objectBasedByPassTriggerGtoZ = UTIL_ByPassTrigger_TEST.buildBypassTriggerGtoZ(systemAdmin);
        objectBasedByPassTriggerGtoZ.Override_InsurancePolicyTriggers__c = false;
        objectBasedByPassTriggerGtoZ.Override_IPParticipantTriggers__c = false;
        insert objectBasedByPassTriggerGtoZ;

        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdmin.id);            
        insert sysAdminUserIdSetting; 
        
        TestDataFactory_AgencyShares.createDataForSharesTesting();
    }
    
    @isTest
    private static void testHasPolicySyncAccessTrue(){
        Boolean returnValue;
		AT_ProfileAccess.mockCustomerSummaryView = new CS_CustomerSummaryView__c(
            Policy_Sync_Access__c = true
        );
        
        Test.startTest();
        User technicalSupport = TestDataFactory_User_Wrapper.generateTechSupportUser('TEST', '12345678913');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(technicalSupport);
        System.runAs(technicalSupport){
        returnValue = AR_TechSupportActionsController.getUserAccessForPolicySync();
        }
        Test.stopTest();
        
        System.assertEquals(true, returnValue, 'Access should be true');
    }
    
    @isTest
    private static void testHasPolicySyncAccessFalse(){
        Boolean returnValue;
		AT_ProfileAccess.mockCustomerSummaryView = new CS_CustomerSummaryView__c(
            Policy_Sync_Access__c = false
        );
        
        Test.startTest();
        User technicalSupport = TestDataFactory_User_Wrapper.generateTechSupportUser('TEST', '12345678913');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(technicalSupport);
        System.runAs(technicalSupport){
        returnValue = AR_TechSupportActionsController.getUserAccessForPolicySync();
        }
        Test.stopTest();
        
        System.assertEquals(false, returnValue, 'Access should be false');
    }
    
    @isTest
    private static void testGetAgreementIndexIdForInsurancePolicy(){
        String returnedAgreIndexId;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        
        Account account = new Account(FirstName = 'tst1', LastName='Ltst', ClientIdentifier__c  = 'test123');
        insert account;
        InsurancePolicy testPolicy = new InsurancePolicy(SourceSystemIdentifier = '12345678901', NameInsuredId = account.id, Name = '123ABC');
        insert testPolicy;
        
        String recordId = testPolicy.Id;
        Test.startTest();
        User systemAdminUser = TestDataFactory_User_Wrapper.generateSystemAdministratorUser('TEST', '12345678913');
        System.runAs(systemAdminUser){
        returnedAgreIndexId = AR_TechSupportActionsController.getAgreementIndexId(recordId);
        }
        Test.stopTest();
      	
        System.assertEquals(testPolicy.SourceSystemIdentifier, returnedAgreIndexId, 'AgreIndexId mismatch');
    }
    
    @isTest
    private static void testSyncShares() {
        InsurancePolicy policy;
        // Get one of the accounts we inserted during setup
        Account account1 = TestDataFactory_AgencyShares.getAccount1();

        Test.startTest();
        User systemAdminUser = TestDataFactory_User_Wrapper.generateSystemAdministratorUser('TEST', '12345678913');
        System.runAs(systemAdminUser){
        // Assign that account to an insurance policy and insert it
        policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        
        String recordId = policy.Id;
        AR_TechSupportActionsController.syncSharesForAgreement(recordId);
        }
        Test.stopTest();

        // Now get the shares that should be inserted
        List<InsurancePolicyShare> sharesAfter = [SELECT ParentId, UserOrGroupId FROM InsurancePolicyShare WHERE ParentId = :policy.id];

        User proxy1 = [SELECT Id, email FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        
        // Find the share that is tied to our new policy and get it's associated proxy id
        List<String> proxyIds = new List<String>();
        for (InsurancePolicyShare share : sharesAfter) { 
            proxyIds.add(share.UserOrGroupId);
        }

        System.assert(!proxyIds.isEmpty(), 'No share found tied to inserted InsurancePolicy');
        System.assert(proxyIds.contains(proxy1.Id), 'InsurancePolicyShare is not mapped to the correct Proxy Id');
    }
    
    @isTest
    public static void testGetPolicyShares() {
        List<AR_TechSupportActionsController.ReturnObject> returnObjects;
        Account account1 = TestDataFactory_AgencyShares.getAccount1();

        Test.startTest();
        User systemAdminUser = TestDataFactory_User_Wrapper.generateSystemAdministratorUser('TEST', '12345678913');
        System.runAs(systemAdminUser){
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        
        String recordId = policy.Id;
        AR_TechSupportActionsController.syncSharesForAgreement(recordId);
        
        returnObjects = AR_TechSupportActionsController.getPolicyShares(recordId);
        }
        Test.stopTest();
        
        User proxy1 = [SELECT Id, Name FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        
        System.assert(!returnObjects.isEmpty(), 'shares should be returned');
        System.assert(returnObjects.get(0).name.equals(proxy1.Name), 'Shares should match policy');
    }
    
    @isTest
    public static void testGetPolicyClientRoles() {
        List<AR_TechSupportActionsController.ReturnObject> returnObjects;
        Account account1 = TestDataFactory_AgencyShares.getAccount1();

        Test.startTest();
        User systemAdminUser = TestDataFactory_User_Wrapper.generateSystemAdministratorUser('TEST', '12345678913');
        System.runAs(systemAdminUser){
        InsurancePolicy policy = TestDataFactory_AgencyShares.insertPolicy('Policy1', account1.Id);
        
        String recordId = policy.Id;
        AR_TechSupportActionsController.syncSharesForAgreement(recordId);
        
        returnObjects = AR_TechSupportActionsController.getClientAgentRoles(recordId);
        }
        Test.stopTest();
        
        User proxy1 = [SELECT Id, Name FROM User WHERE email = :TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        
        System.assert(!returnObjects.isEmpty(), 'roles should be returned');
        System.assert(returnObjects.get(0).name.equals(proxy1.Name), 'Roles should match policy');
    }
}