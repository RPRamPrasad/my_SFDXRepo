/** 
* @description case trigger test - Case API 
* @Owner: Grumpycats
*/
@isTest
(seeAllData=false)
private class CaseTriggerTestAPI {
    private static final String OWNER_NOT_THE_PROXY='The owner was not the proxy';
    @testSetup
    private static void testSetUp(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CaseTestDataUtility.createAccount();
            CaseTestDataUtility.addUserToCaseAPI(TestUserSetupUtility.getApiOnlyUser());
            CaseTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), CaseTestDataUtility.getAccount());
        }
    }
    
    //Customer Service Request Insert
    @isTest
    private static void testCustomerServiceRequestInsert(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User apiOnlyUser = TestUserSetupUtility.getApiOnlyUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Case csrCase = new Case();
        System.runAs(apiOnlyUser){
       		csrCase = CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, proxyUser.Id);
            insert csrCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(csrCase);
        System.assert(insertResult.OwnerId == proxyUser.Id, OWNER_NOT_THE_PROXY);
        System.assert(insertResult.Assigned_To__c == null, 'The assigned to was not null');
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST, 'The record type was not CSR');
        System.assert(insertResult.Status == CaseHandlerConstants.CASE_STATUS_NEW, 'The status is not new');
        Test.stopTest();
    }
    
 
    
    //Data Access Request Insert
    @isTest
    private static void testDataAccessRequestInsert(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User apiOnlyUser = TestUserSetupUtility.getApiOnlyUser();
        TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Case darCase = new Case();
        System.runAs(apiOnlyUser){
       		darCase = CaseTestDataUtility.buildDataAccessRequest(accountRecord); 
            insert darCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(darCase);
        System.assert(insertResult.OwnerId == CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID, 'The owner was not updated to the queue');
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_DATA_ACCESS_REQUEST, 'The record type was not set to DAR');
        System.assert(insertResult.Status == CaseHandlerConstants.CASE_STATUS_RECEIVED, 'The status is not set to received');
        Test.stopTest();
    }
    
   
    
  //Retention Case  
    @isTest
    private static void testRetentionCaseInsert(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User apiOnlyUser = TestUserSetupUtility.getApiOnlyUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        Case retentionCase = new Case();
        System.runAs(apiOnlyUser){
       		retentionCase = CaseTestDataUtility.buildRetentionCase(accountRecord, proxyUser.Id);
            insert retentionCase;
        }
        Case insertResult = CaseTestDataUtility.retrieveCaseAfterInsert(retentionCase);
        System.assert(insertResult.OwnerId == proxyUser.Id, OWNER_NOT_THE_PROXY);
        System.assert(insertResult.Assigned_To__c == null, 'The assigned was not null');
        System.assert(insertResult.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_RETENTION, 'The record type was not set to retention');
        System.assert(insertResult.Status == CaseHandlerConstants.CASE_STATUS_NEW, 'The status is not set to new');
        Test.stopTest();
    }
    
    @istest
    private static void testBulkInsert(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User apiOnlyUser = TestUserSetupUtility.getApiOnlyUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Test.startTest();
        List <Case> apiCaseList = new List <Case>();
        System.runAs(apiOnlyUser){
            apiCaseList.add(CaseTestDataUtility.buildRetentionCase(accountRecord, proxyUser.Id));
            apiCaseList.add(CaseTestDataUtility.buildRetentionCase(accountRecord, proxyUser.Id));
            apiCaseList.add(CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, proxyUser.Id));
            apiCaseList.add(CaseTestDataUtility.buildCustomerServiceRequest(accountRecord, proxyUser.Id));
            apiCaseList.add(CaseTestDataUtility.buildDataAccessRequest(accountRecord));
            apiCaseList.add(CaseTestDataUtility.buildDataAccessRequest(accountRecord));
            insert apiCaseList;
        }
		List <Case> insertedCases = CaseTestDataUtility.retrieveCaseListAfterInsert(apiCaseList);
        System.assert(insertedCases.size() == 6, 'Inserted Cases size should be 6');
        Integer csrCount = 0;
        Integer darCount = 0;
        Integer retentionCount = 0;
        for(Case caseRecord : insertedCases){
            if(caseRecord.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST){
                csrCount = csrCount + 1;
                System.assert(caseRecord.OwnerId == proxyUser.Id, OWNER_NOT_THE_PROXY);
                System.assert(caseRecord.Case_Owner__c == caseRecord.OwnerId, 'case owner fields were not in sync');
                System.assert(caseRecord.Status == CaseHandlerConstants.CASE_STATUS_NEW, 'case status was not new');
                System.assert(caseRecord.Assigned_To__c == null, 'Assigned to was set by Case API');
            }else if(caseRecord.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_DATA_ACCESS_REQUEST){
                darCount = darCount + 1;
                System.assert(caseRecord.OwnerId == CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID, 'the owner was not the Dar Queue');
                System.assert(caseRecord.Status == CaseHandlerConstants.CASE_STATUS_RECEIVED, 'case status was not received');
                System.assert(caseRecord.Assigned_To__c == null, 'Assigned to was set by Case API');
            }else if(caseRecord.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_RETENTION){
                retentionCount = retentionCount + 1;
                System.assert(caseRecord.OwnerId == proxyUser.Id, OWNER_NOT_THE_PROXY);
                System.assert(caseRecord.Case_Owner__c == caseRecord.OwnerId, 'case owner fields were not in sync');
                System.assert(caseRecord.Status == CaseHandlerConstants.CASE_STATUS_NEW, 'case status was not new');
                System.assert(caseRecord.Assigned_To__c == null, 'Assigned to was set by Case API');
            }
        }
        System.assert(csrCount == 2, 'there were not 2 customer service request cases');
        System.assert(darCount == 2, 'there were not 2 data access request cases');
        System.assert(retentionCount == 2, 'there were not 2 retention cases');
    }
       
}