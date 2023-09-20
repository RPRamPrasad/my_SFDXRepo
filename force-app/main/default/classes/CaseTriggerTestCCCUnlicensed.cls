/** 
* @description case trigger test for CCC Unlicensed
* @Owner: CATS
*/
@isTest
(seeAllData=false)
private class CaseTriggerTestCCCUnlicensed {
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
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnLicensedUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Case csrCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
       		csrCase = CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, null);
            csrCase.Case_Owner__c = agentUser.Id;
            insert csrCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(csrCase);
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST, 'The record type was not set to CSR');
        System.assert(insertResult.Status == CaseHandlerConstants.CASE_STATUS_NEW, 'The status is not set to pending');
        System.assert(insertResult.OwnerId == proxyUser.Id, 'case owner was not updated to the proxy');
        System.assert(insertResult.OwnerId == insertResult.Case_Owner__c, 'case owner fields are not in sync');
        Test.stopTest();
    }
    
    @isTest
    private static void testCustomerServiceRequestUpdate(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnLicensedUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Case csrCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
       		csrCase = CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, null);
            csrCase.Case_Owner__c = agentUser.Id;
            insert csrCase;
        }
        Case retrievedCase = CaseTestDataUtility.retrieveCaseAfterInsert(csrCase);
        System.assert(retrievedCase.OwnerId == proxyUser.Id, 'The owner was not updated to the proxy on insert');
        System.runAs(cccUnlicensedUser){
            retrievedCase.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
            update retrievedCase;
        }
        Case updatedCaseResult = CaseTestDataUtility.retrieveCaseAfterInsert(retrievedCase);
        System.assert(updatedCaseResult.Status == CaseHandlerConstants.CASE_STATUS_CLOSED, 'case did not close');
        System.assert(updatedCaseResult.OwnerId == proxyUser.Id , 'Owner was not meant to be changed on the update');
        Test.stopTest();
    }
    
    @isTest              
    private static void testDataAccessRequestInsert(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnLicensedUser();
        Test.startTest();
        Case darCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
       		darCase = CaseTestDataUtility.buildDataAccessRequest(accountRecord);
            insert darCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(darCase);
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_DATA_ACCESS_REQUEST, 'The record type was not set to DAR');
        System.assert(insertResult.Status == CaseHandlerConstants.CASE_STATUS_RECEIVED, 'The status is not set to Received');
        System.assert(insertResult.OwnerId == CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID , 'Owner was not meant to be changed on the update');
        Test.stopTest();
    }
    
	@isTest
    private static void testDataAccessRequestUpdate(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnLicensedUser();
        Test.startTest();
        Case darCase = new Case();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
       		darCase = CaseTestDataUtility.buildDataAccessRequest(accountRecord);
            insert darCase;
        }
        Case retrievedCase = CaseTestDataUtility.retrieveCaseAfterInsert(darCase);
        System.assert(retrievedCase.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_DATA_ACCESS_REQUEST, 'The record type was not set to DAR');
        System.assert(retrievedCase.Status == CaseHandlerConstants.CASE_STATUS_RECEIVED, 'The status is not set to Received');
        System.runAs(cccUnlicensedUser){
            retrievedCase.Status = CaseHandlerConstants.CASE_STATUS_PROCESSING;
            update retrievedCase;
        }
        Case updatedCaseResult = CaseTestDataUtility.retrieveCaseAfterInsert(retrievedCase);
        System.assert(updatedCaseResult.Status == CaseHandlerConstants.CASE_STATUS_PROCESSING, 'case status is not set to processing');
        System.assert(updatedCaseResult.OwnerId == CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID , 'Owner was not meant to be changed on the update');
        Test.stopTest();
    }
    
    @isTest
    private static void testCaseCreateWithAgentNoAgentRole(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User cccUnlicensedUser = TestUserSetupUtility.getCCCUnLicensedUser();
        TestUserSetupUtility.getAgentUser(); // owns the account
        User agentUser2;
        agentUser2 = TestUserSetupUtility.getSecondaryAgentUser();
        String errorMsg = '';
        Case caseRecord = new Case();
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUnlicensedUser);
        System.runAs(cccUnlicensedUser){
            caseRecord = CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, agentUser2.Id);
            try{
            	insert caseRecord;

            }catch(Exception ex){
                //System.debug('ex msg: '+ex.getMessage());
                errorMsg = ex.getMessage();
            }
        }
        System.assert(errorMsg.contains(AGENT_ROLE_VALIDATION_ERROR_MESSAGE), 'No error message');
        Test.stopTest();
    }
}