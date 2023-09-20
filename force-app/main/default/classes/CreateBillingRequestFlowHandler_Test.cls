/**
 * @description Test class used to test the behaviour and correctness of the CreateBillingRequestFlowHandler class
 *
 * @author Kiko Ferrer (VAD63S)
 * @version 1.0, 05/30/23
 * @see CreateBillingRequestFlowHandler
 * @since 1.0
*/
@IsTest
public class CreateBillingRequestFlowHandler_Test {
    /**
     * @description Setup method used to create records to be reused accross the different test methods.
     * 
     */
    @testSetup
    private static void setup(){
        User agent = TestDataFactory_User_Wrapper.generateAgentUser('alias', '12345678901');
        agent.Alias = 'alias';
        agent.State_Agent_Code__c = '18-1AED';
        //agent = TestDataFactory_User.insertUser(agent);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        
        
        Case c = new Case();
        c.Date_From__c = system.today();
        c.Date_To__c = system.today().addDays(10);
        c.Subject = 'Created for Testing';
        c.PolicyNumber__c = '0123456789';
        c.Status = 'Pending';
        c.Assigned_To__c = agent.Id;
        c.Type = 'Account/Policy Breakdown';
        c.recordtypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_BILLING_REQUEST;
        c.App_Code__c = 'SFDC UI - Billing Request';
        insert c;
        
        Case c1 = new Case();
        c1.Date_From__c = system.today();
        c1.Date_To__c = system.today().addDays(10);
        c1.Subject = 'Testing get Status';
        c1.Status = 'Pending';
        c1.ACMT_Case_Number__c = '00006182';
        c1.PolicyNumber__c = '0123456789';
        c1.Type = 'Account/Policy Breakdown';
        c1.recordtypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_BILLING_REQUEST;
        c1.App_Code__c = 'SFDC UI - Billing Request';
        insert c1;
    }
    
     /**
     * @description Method that test a successfull call to the createECRMCase() method.
     * 
     * @see CreateBillingRequestFlowHandler.createECRMCase
     */
    @IsTest
    public static void createECRMCaseSuccess() { 
        Test.setMock(HttpCalloutMock.class, new ACMTCreateCalloutMock());
        
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            
            String accountId = UTIL_CaseTestData.createAccountId();
            String appCode = 'SFDC UI - Billing Request';
            Date dateFrom = Date.newInstance(2022, 1, 2);
            Date dateTo = Date.newInstance(2022, 2, 3);
            Date dueDate;
            String policyNumber = '456789';
            String recType = 'Account/Policy Breakdown';
            List<CreateBillingRequestFlowHandler.InputVariables> inputVariables = new List<CreateBillingRequestFlowHandler.InputVariables>();
            CreateBillingRequestFlowHandler.InputVariables inputVariable = new CreateBillingRequestFlowHandler.InputVariables();
            inputVariable.accountId = accountId;
            inputVariable.appCode = appCode;
            inputVariable.dateFrom = dateFrom;
            inputVariable.dateTo = dateTo;
            inputVariable.policyNumber = policyNumber; 
            inputVariable.caseType = recType; 
            inputVariable.userRecord = Null;
            inputVariables.add(inputVariable);
            Test.startTest();
            List<CreateBillingRequestFlowHandler.OutputVariables> outputList = CreateBillingRequestFlowHandler.createECRMCase(inputVariables);
            Test.stopTest();
            CreateBillingRequestOSCCase.CreateECRMCaseWrapper createECRMWrapper = new CreateBillingRequestOSCCase.CreateECRMCaseWrapper();
            createECRMWrapper.accountId = accountId;
            createECRMWrapper.appCode = appCode;
            createECRMWrapper.dateFrom = dateFrom;
            createECRMWrapper.dateTo = dateTo;
            createECRMWrapper.billDueDate = dueDate;
            createECRMWrapper.policyNumber = policyNumber;
            createECRMWrapper.type = recType;
            createECRMWrapper.userRecord = null;
            String caseNum = CreateBillingRequestOSCCase.createECRMCase(createECRMWrapper);
            List<Case> createdCaseList = [SELECT Id,AccountId,CaseNumber,Date_From__c,Date_To__c,RecordTypeId,PolicyNumber__c,Type,Subject,Description,Reason,App_Code__c FROM Case WHERE caseNumber = :caseNum AND Status = 'Open'];
            System.assertEquals(createdCaseList.size(), 1, 'Size is not one');
            System.assertEquals(createdCaseList[0].AccountId, accountId, 'Account IDs not matching');
            System.assertEquals(createdCaseList[0].App_Code__c, appCode, 'Incorrect App Code');
            System.assertEquals(createdCaseList[0].Date_From__c, DateFrom, 'Date_From days not matching');
            System.assertEquals(createdCaseList[0].Date_To__c, DateTo, 'Date_To days not matching');
            System.assertEquals(createdCaseList[0].PolicyNumber__c, '456789', 'Policy number not correct');
            System.assertEquals(createdCaseList[0].Type, recType, 'Incorrect Record type');
        }
    }
    
     /**
     * @description Helper method that creates an successful callout mock.
     * 
     */
    public class ACMTCreateCalloutMock implements HttpCalloutMock{
        /**
         * @description ACMTCreateCalloutMock
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"id":"5003K000004wKrQQAU","caseNumber":"00047142","message":"Case is Successfully created in Salesforce","comments":"Agent code or Alias does not exist.","attachment":"Failed to insert the attachment"}');
            response.setStatusCode(201);
            response.setStatus('Created');
            return response;        
        }
    }
}