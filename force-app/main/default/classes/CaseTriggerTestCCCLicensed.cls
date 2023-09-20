/** 
* @description case trigger test - CCC Licensed
* @Owner: Grumpycats
*/
@isTest
(seeAllData=false)
private class CaseTriggerTestCCCLicensed {
    private static final String AGENT_ROLE_VALIDATION_ERROR_MESSAGE = Label.ObjectOwnerErrorMessage;
    
    @testSetup
    private static void testSetUp(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CaseTestDataUtility.createAccount();
            CaseTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), CaseTestDataUtility.getAccount());
        }
    }
    
    @isTest
    private static void testCustomerServiceRequestInsert(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Case csrCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
       		csrCase = CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, null);
            csrCase.Case_Owner__c = agentUser.Id;
            insert csrCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(csrCase);
        System.assert(insertResult.OwnerId == proxyUser.Id, 'The owner was not updated to the Case Owner');
        System.assert(insertResult.OwnerId == insertResult.Case_Owner__c, 'The case owner fields are not in sync');
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST, 'The record type was not set to CSR');
        System.assert(insertResult.Status == CaseHandlerConstants.CASE_STATUS_NEW, 'The status is not set to new');
        Test.stopTest();
    }
    
    @isTest
    private static void testDataAccessRequest(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        Test.startTest();
        Case darCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
       		darCase = CaseTestDataUtility.buildDataAccessRequest(accountRecord);
            insert darCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(darCase);
        System.assert(insertResult.OwnerId == CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID, 'The owner was not updated to the DAR Case Queue');
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_DATA_ACCESS_REQUEST, 'The record type was not set to DAR');
        System.assert(insertResult.Status == CaseHandlerConstants.CASE_STATUS_RECEIVED, 'The status is not set to pending');
        Test.stopTest();
    }
    
    @isTest
    private static void testCustomerServiceRequestUpdate(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Case csrCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
       		csrCase = CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, null);
            csrCase.Case_Owner__c = agentUser.Id;
            insert csrCase;
        }
        Case retrievedCase = CaseTestDataUtility.retrieveCaseAfterInsert(csrCase);
        System.assert(retrievedCase.OwnerId == proxyUser.Id, 'The owner was not updated to the Case Owner on insert');
        System.runAs(cccLicensedUser){
            retrievedCase.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
            update retrievedCase;
        }
        Case updatedCaseResult = CaseTestDataUtility.retrieveCaseAfterInsert(retrievedCase);
        System.assert(updatedCaseResult.Status == CaseHandlerConstants.CASE_STATUS_CLOSED, 'case did not close');
        System.assert(updatedCaseResult.OwnerId == proxyUser.Id, 'Owner was not meant to be changed on the update');
        Test.stopTest();
    }
    
    @isTest
    private static void testDataAccessRequestUpdate(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        TestUserSetupUtility.getAgentUser();
        Test.startTest();
        Case darCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
       		darCase = CaseTestDataUtility.buildDataAccessRequest(accountRecord);
            insert darCase;
        }
        Case retrievedCase = CaseTestDataUtility.retrieveCaseAfterInsert(darCase);
        System.assert(retrievedCase.OwnerId == CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID, 'The owner was not updated to the DAR Case Queue on insert');
        System.runAs(cccLicensedUser){
            retrievedCase.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
            update retrievedCase;
        }
        Case updatedCaseResult = CaseTestDataUtility.retrieveCaseAfterInsert(retrievedCase);
        System.assert(updatedCaseResult.Status == CaseHandlerConstants.CASE_STATUS_CLOSED, 'case did not close');
        System.assert(updatedCaseResult.OwnerId == CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID, 'Owner was not meant to be changed on the update');
        Test.stopTest();
    }
    
    @isTest
    private static void testCaseCreateWithAgentNoAgentRole(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User cccLicensedUser = TestUserSetupUtility.getCCCLicensedUser();
        TestUserSetupUtility.getAgentUser(); // owns the account
        User agentUser2 = TestUserSetupUtility.getSecondaryAgentUser();
        String errorMsg = '';
        Case caseRecord = new Case();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(cccLicensedUser){
            caseRecord = CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, agentUser2.Id);
            try{
            	insert caseRecord;

            }catch(Exception ex){
                //System.debug(ex.getMessage());
                errorMsg = ex.getMessage();
            }
        }
        System.assert(errorMsg.contains(AGENT_ROLE_VALIDATION_ERROR_MESSAGE), 'No error message');
        Test.stopTest();
    }
}