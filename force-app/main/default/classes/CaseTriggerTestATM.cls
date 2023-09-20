/**
 * @description : case trigger test for 2.01 profile users
 * @Owner: CATS
*/
@isTest
(seeAllData=false)
private class CaseTriggerTestATM {
    
	@testSetup
    private static void testSetUp(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CaseTestDataUtility.createAccount();
            CaseTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), CaseTestDataUtility.getAccount());
            CaseTestDataUtility.addUserToCaseAPI(TestUserSetupUtility.getApiOnlyUser());
        }
    }

    @isTest
    private static void testCustomerServiceRequestInsertAndUpdate(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User atmUser = TestUserSetupUtility.getAtmUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Case csrCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUser);
        System.runAs(atmUser){
       		csrCase = CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, atmUser.Id);
            insert csrCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(csrCase);
        System.assert(insertResult.OwnerId == proxyUser.Id, 'The owner was not updated to the proxy on insert');
        System.assert(insertResult.Assigned_To__c == atmUser.Id, 'The assigned to was not set to the logged in atm');
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST, 'The record type was not set to CSR on insert');
        System.assert(insertResult.Status == CaseHandlerConstants.CASE_STATUS_PENDING, 'The status is not set to pending on insert');

        System.runAs(atmUser){
            insertResult.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
            update insertResult;
        }
        Case updatedCaseResult = CaseTestDataUtility.retrieveCaseAfterInsert(insertResult);
        System.assert(updatedCaseResult.Status == CaseHandlerConstants.CASE_STATUS_CLOSED, 'case did not close on update');
        System.assert(updatedCaseResult.OwnerId == proxyUser.Id , 'Owner was not meant to be changed on the update');
        Test.stopTest();
    }

    @isTest
    private static void testCustomerOnboardingInsertAndUpdate(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User atmUser = TestUserSetupUtility.getAtmUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Case customerOnboardingCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUser);
        System.runAs(atmUser){
       		customerOnboardingCase = CaseTestDataUtility.buildCustomerOnboarding(accountRecord, atmUser.Id); 
            insert customerOnboardingCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(customerOnboardingCase);
        System.assert(insertResult.OwnerId == proxyUser.Id, 'The owner was not updated to the proxy');
        System.assert(insertResult.Assigned_To__c == atmUser.Id, 'The assigned to was not set to the logged in atm');
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_ONBOARDING, 'The record type was not set to Customer Onboarding');
        System.assert(insertResult.Status == CaseHandlerConstants.CASE_STATUS_WELCOME, 'The status is not set to welcome');
        System.runAs(atmUser){
            insertResult.Status = CaseHandlerConstants.CASE_STATUS_KEEP;
            update insertResult;
        }
        Case updatedCaseResult = CaseTestDataUtility.retrieveCaseAfterInsert(insertResult);
        System.assert(updatedCaseResult.Status == CaseHandlerConstants.CASE_STATUS_KEEP, 'case did not move to keep on update');
        System.assert(updatedCaseResult.OwnerId == proxyUser.Id , 'Owner was not meant to be changed on the update');
        Test.stopTest();
    }
    
    @isTest
    private static void testRetentionCaseUpdate(){
       	Account accountRecord = CaseTestDataUtility.getAccount();
        User atmUser = TestUserSetupUtility.getAtmUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User apiUser = TestUserSetupUtility.getApiOnlyUser();
        Test.startTest();
        Case retentionCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUser);
        System.runAs(apiUser){
            retentionCase = CaseTestDataUtility.buildRetentionCase(accountRecord, proxyUser.Id);
            insert retentionCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(retentionCase);
        System.assert(insertResult.Status == 'New', 'status was not set to new');
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_RETENTION, 'case record type was not retention');
        System.assert(insertResult.OwnerId == proxyUser.Id, 'case owner was not the proxy');
        System.runAs(atmUser){
			insertResult.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
			update insertResult;           
        }
		Case updateResult = CaseTestDataUtility.retrieveCaseAfterInsert(insertResult);
        System.assert(updateResult.Status == CaseHandlerConstants.CASE_STATUS_CLOSED, 'case was not updated to closed');
        Test.stopTest();
    }
    
    @isTest
    private static void testBulkUpdate(){
       	Account accountRecord = CaseTestDataUtility.getAccount();
        User atmUser = TestUserSetupUtility.getAtmUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User apiUser = TestUserSetupUtility.getApiOnlyUser();
        Test.startTest();
        List<Case> caseList = new List<Case>();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atmUser);
        System.runAs(apiUser){
            caseList.add(CaseTestDataUtility.buildRetentionCase(accountRecord, proxyUser.Id));
            caseList.add(CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, proxyUser.Id));
            insert caseList;
        }
        List<Case> insertedCaseList = CaseTestDataUtility.retrieveCaseListAfterInsert(caseList);
        System.assert(insertedCaseList.size() == 2, 'expected 2 cases to be insertd');
        List<Case> casesToUpdateList = new List<Case>();
        for(Case caseRecord : insertedCaseList){
            System.assert(caseRecord.OwnerId == proxyUser.Id, 'case owner was not the proxy');
        }
        System.runAs(atmUser){
            for(Case caseToUpdate : insertedCaseList){
                caseToUpdate.Status = CaseHandlerConstants.CASE_STATUS_PENDING;
                caseToUpdate.Assigned_To__c = atmUser.Id;
                casesToUpdateList.add(caseToUpdate);
            }
			update casesToUpdateList;           
        }
		List<Case> updateResults = CaseTestDataUtility.retrieveCaseListAfterInsert(casesToUpdateList);
        for(Case caseRecord : updateResults){
            System.assert(caseRecord.Status == CaseHandlerConstants.CASE_STATUS_PENDING, 'case was not updated to pending');
        }
        Test.stopTest();
    }
}