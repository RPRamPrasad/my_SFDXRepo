/** 
* @description case trigger test for agents
* @Owner: CATS
*/
@isTest
(seeAllData=false)
private class CaseTriggerTestAgent {
	
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
    private static void testCustomerServiceRequestInsert(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Case csrCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
       		csrCase = CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, agentUser.Id);
            insert csrCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(csrCase);
        System.assert(insertResult.OwnerId == proxyUser.Id, 'The owner was not updated to the proxy');
        System.assert(insertResult.Assigned_To__c == agentUser.Id, 'The assigned to was not set to the logged in agent');
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST, 'The record type was not set to CSR');
        System.assert(insertResult.Status == CaseHandlerConstants.CASE_STATUS_PENDING, 'The status is not set to pending');
        Test.stopTest();
    }
    
    @isTest
    private static void testCustomerServiceRequestUpdate(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Case csrCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
       		csrCase = CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, agentUser.Id);
            insert csrCase;
        }
        Case retrievedCase = CaseTestDataUtility.retrieveCaseAfterInsert(csrCase);
        System.assert(retrievedCase.OwnerId == proxyUser.Id, 'The owner was not updated to the proxy on insert');
        System.runAs(agentUser){
            retrievedCase.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
            update retrievedCase;
        }
        Case updatedCaseResult = CaseTestDataUtility.retrieveCaseAfterInsert(retrievedCase);
        System.assert(updatedCaseResult.Status == CaseHandlerConstants.CASE_STATUS_CLOSED, 'case did not close');
        System.assert(updatedCaseResult.OwnerId == proxyUser.Id , 'Owner was not meant to be changed on the update');
        Test.stopTest();
    }

    @isTest
    private static void testCustomerOnboardingInsert(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Case customerOnboardingCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
       		customerOnboardingCase = CaseTestDataUtility.buildCustomerOnboarding(accountRecord, agentUser.Id);
            insert customerOnboardingCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(customerOnboardingCase);
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_ONBOARDING, 'Record type was not corretly');
        System.assert(insertResult.Status == CaseHandlerConstants.CASE_STATUS_WELCOME, 'Status was not set to welcome');
        System.assert(insertResult.OwnerId == proxyUser.Id, 'case owner was not set to the proxy');
        Test.stopTest();
    }
    
    @isTest
    private static void testCustomerOnboardingUpdate(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User agentUser = TestUserSetupUtility.getAgentUser();
        Test.startTest();
        TestUserSetupUtility.getProxyUser();
        Case customerOnboardingCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
       		customerOnboardingCase = CaseTestDataUtility.buildCustomerOnboarding(accountRecord, agentUser.Id);
            insert customerOnboardingCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(customerOnboardingCase);
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_ONBOARDING, 'Record type was not corretly');
        System.runAs(agentUser){
      		insertResult.Status = CaseHandlerConstants.CASE_STATUS_KEEP;
            update insertResult;
        }
        Case updateResult = CaseTestDataUtility.retrieveCaseAfterInsert(insertResult);
        System.assert(updateResult.Status == CaseHandlerConstants.CASE_STATUS_KEEP, 'status was not updated to Keep');
        Test.stopTest();
    }

    @isTest
    private static void testRetentionCaseUpdate(){
       	Account accountRecord = CaseTestDataUtility.getAccount();
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User apiUser = TestUserSetupUtility.getApiOnlyUser();
        Test.startTest();
        Case retentionCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(apiUser){
            retentionCase = CaseTestDataUtility.buildRetentionCase(accountRecord, proxyUser.Id);
            insert retentionCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(retentionCase);
        System.assert(insertResult.Status == 'New', 'msg');
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_RETENTION, 'case record type was not retention');
        System.assert(insertResult.OwnerId == proxyUser.Id, 'case owner was not the proxy');
        System.runAs(agentUser){
			insertResult.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
			update insertResult;           
        }
		Case updateResult = CaseTestDataUtility.retrieveCaseAfterInsert(insertResult);
        System.assert(updateResult.Status == CaseHandlerConstants.CASE_STATUS_CLOSED, 'case was not updated to closed');
        Test.stopTest();
    }
    
    @isTest
    private static void testBulkUpdate(){ //Mock of Inline Edit
       	Account accountRecord = CaseTestDataUtility.getAccount();
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User apiUser = TestUserSetupUtility.getApiOnlyUser();
        Test.startTest();
        List<Case> caseList = new List<Case>();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(apiUser){
            caseList.add(CaseTestDataUtility.buildRetentionCase(accountRecord, proxyUser.Id));
            caseList.add(CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, proxyUser.Id));
            insert caseList;
        }
        List<Case> insertedCases = CaseTestDataUtility.retrieveCaseListAfterInsert(caseList);
        System.assert(insertedCases.size() == 2, 'expected 2 cases to be inserted');
        List<Case> casesToUpdate = new List<Case>();
        System.runAs(agentUser){
            for(Case caseToUpdate : insertedCases){
                caseToUpdate.Status = CaseHandlerConstants.CASE_STATUS_PENDING;
                caseToUpdate.Assigned_To__c = agentUser.Id;
                casesToUpdate.add(caseToUpdate);
            }
			update casesToUpdate;           
        }
		List<Case> updateResults = CaseTestDataUtility.retrieveCaseListAfterInsert(casesToUpdate);
        for(Case caseRecord : updateResults){
            System.assert(caseRecord.Status == CaseHandlerConstants.CASE_STATUS_PENDING, 'case was not updated to pending');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testAgentUpdatingACaseOwnedByAnotherProxy(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User agentUser2 = TestUserSetupUtility.getSecondaryAgentUser();
        TestUserSetupUtility.getSecondaryProxyUser();
        User apiUser = TestUserSetupUtility.getApiOnlyUser();
        String errorMessage = '';
        Test.startTest();
        Case caseRecord = new Case();
        System.runAs(apiUser){
            caseRecord = CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, proxyUser.Id);
            insert caseRecord;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(caseRecord);
        System.assert(insertResult.OwnerId == proxyUser.Id, 'owner was not the proxy');
        System.runAs(agentUser2){
            insertResult.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
            try{
                update insertResult;
            }catch(Exception ex){
                errorMessage = ex.getMessage();
            }
        }
        System.assert(errorMessage.contains('insufficient access rights'), 'agent user 2 was able to edit a case belonging to another office');
        Case updateResult = CaseTestDataUtility.retrieveCaseAfterInsert(insertResult);
        System.assert(updateResult.OwnerId == proxyUser.Id, 'owner was not the proxy');
        System.assert(updateResult.Status != CaseHandlerConstants.CASE_STATUS_CLOSED, 'update was successful');
        Test.stopTest();
    }
}