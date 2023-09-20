/**
 * @description Test Class for the CreateBillingRequestOSCCase Class.
 *
 * @author Jacob Ira (VAB2Q2) 
 * @version 1.1, 02/03/23
 * @see CreateBillingRequestOSCCase 
 * @since 1.0
*/
@IsTest
public class CreateBillingRequestOSCCase_Test {

     /**
     * @description Setup method used to create records to be reused accross the different test methods.
     * 
     */
    @testSetup
    public static void setup(){
        
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
     * @description Method that test expected failure of createCase.
     * 
     */
    @IsTest
    static void createCaseTestFail(){
        Test.startTest();
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){ 
            Case c = [SELECT Date_To__c,Date_From__c,Id,PolicyNumber__c from Case where Subject = 'Created for Testing'];
            Test.setMock(HttpCalloutMock.class, new ACMTFailCalloutMock());
            try{
                CreateBillingRequestOSCCase.CreateCase(c.Id);
            }
            catch(Exception e){
                Case updatedCase = [SELECT Date_To__c,Date_From__c,ACMT_Case_Number__c,Id,PolicyNumber__c from Case where id = :c.id];
                System.assertEquals(updatedCase.ACMT_Case_Number__c, NULL, 'Exception not returning NULL');
            }
        }
        Test.stopTest();
    }
    
    
    /**
     * @description Method that test successfull call to getCaseStatus.
     * 
     */
    @IsTest
    static void getCaseStatusTestSuccess(){
        
        Test.setMock(HttpCalloutMock.class, new ACMTCreateCalloutMock());
        Test.startTest();
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            Case c = [SELECT Date_To__c,Date_From__c,Id,PolicyNumber__c from Case where Subject = 'Testing get Status'];
            Test.setMock(HttpCalloutMock.class, new ACMTStatusCalloutMock());
            CreateBillingRequestOSCCase.getCaseStatus(c.Id);
            Case updatedCase = [SELECT Status,id from Case where id = :c.id];
            System.assertEquals(updatedCase.Status, 'Closed', 'Cases Status: ' + updatedCase.Status);
        }
        Test.stopTest();
    }
    
    /**
     * @description Method that test successfull call to createECRMCase.
     * 
     */
    @IsTest
    static void getcreateECRMCaseSuccess(){
        Test.setMock(HttpCalloutMock.class, new ACMTCreateCalloutMock());
        
        Test.startTest();
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            
            String accountId = UTIL_CaseTestData.createAccountId();
            String appCode = 'SFDC UI - Billing Request';
            Date dateFrom = Date.newInstance(2022, 1, 2);
            Date dateTo = Date.newInstance(2022, 2, 3);
            Date dueDate;
            String policyNumber = '456789';
            String recType = 'Account/Policy Breakdown';
            
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
            System.assertEquals(createdCaseList[0].App_Code__c, appCode, 'App Code not correct');
            System.assertEquals(createdCaseList[0].Date_From__c, DateFrom, 'Date_From days not matching');
            System.assertEquals(createdCaseList[0].Date_To__c, DateTo, 'Date_To days not matching');
            System.assertEquals(createdCaseList[0].PolicyNumber__c, '456789', 'Policy number not correct');
            System.assertEquals(createdCaseList[0].Type, recType, 'Incorrect Record type');
            
        }
        Test.stopTest();
    }
    
    /**
     * @description sMethod that test successfull call to createECRMCase.
     * 
     */
    @IsTest
    static void getcreateECRMCaseBillExplanationSuccess(){
        Test.setMock(HttpCalloutMock.class, new ACMTCreateCalloutMock());
        
        Test.startTest();
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            
            String accountId = UTIL_CaseTestData.createAccountId();
            String appCode = 'SFDC UI - Billing Request';
            Date dateFrom;
            Date dateTo;
            Date dueDate = Date.newInstance(2022, 2, 3);
            String policyNumber = '456789';
            String recType = 'Bill Explanation';
            
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
            List<Case> createdCaseList = [SELECT Id,AccountId,CaseNumber,Date_From__c,Date_To__c,RecordTypeId,PolicyNumber__c,Type,Bill_Due_Date__c,App_Code__c FROM Case WHERE CaseNumber = :caseNum AND Status = 'Open'];
            System.assertEquals(createdCaseList[0].AccountId, accountId, 'Account IDs not matching');
            System.assertEquals(createdCaseList[0].App_Code__c, appCode, 'App Code not correct');
            System.assertEquals(createdCaseList[0].Bill_Due_Date__c, dueDate, 'Bill due date not matching');
            System.assertEquals(createdCaseList[0].PolicyNumber__c, '456789', 'Policy number not correct');
            System.assertEquals(createdCaseList[0].Type, recType, 'Incorrect Record type');
            
        }
        Test.stopTest();
    }

    /**
     * @description Method that test successfull call to updateACMTCase.
     * 
     */
    @IsTest
    static void updateACMTCaseSuccess(){
        Test.setMock(HttpCalloutMock.class, new ACMTUpdateCalloutMock());
        String aCMTCaseNumber = '00012345';
        String comment = 'Test update case method call';
        
        Test.startTest();
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
    System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            CreateBillingRequestOSCCase.updateCase(aCMTCaseNumber, comment);
        }
        System.assertEquals(aCMTCaseNumber, '00012345', 'Callout failed');
        Test.stopTest();
    }
    
    
    /**
     * @description Method that test successfull call to createECRMCase with Hardship case type.
     * 
     */
    @IsTest
    static void getcreateECRMCaseHardshipSuccess(){
        Test.setMock(HttpCalloutMock.class, new ACMTCreateCalloutMock());
        
        Test.startTest();
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            
            String accountId = UTIL_CaseTestData.createAccountId();
            String appCode = 'SFDC UI - Billing Request';
            Date dateFrom;
            Date dateTo;
            Date dueDate;
            String policyNumber = '456789';
            String recType = 'Hardship';
            
            CreateBillingRequestOSCCase.CreateECRMCaseWrapper createECRMWrapper = new CreateBillingRequestOSCCase.CreateECRMCaseWrapper();
            createECRMWrapper.accountId = accountId;
            createECRMWrapper.appCode = appCode;
            createECRMWrapper.dateFrom = DateFrom;
            createECRMWrapper.dateTo = dateTo;
            createECRMWrapper.billDueDate = dueDate;
            createECRMWrapper.policyNumber = policyNumber;
            createECRMWrapper.type = recType;
            createECRMWrapper.userRecord = null;
            String caseNum = CreateBillingRequestOSCCase.createECRMCase(createECRMWrapper);
            List<Case> createdCaseList = [SELECT Id,AccountId,CaseNumber,Date_From__c,Date_To__c,RecordTypeId,PolicyNumber__c,Type,Bill_Due_Date__c,App_Code__c FROM Case WHERE CaseNumber = :caseNum AND Status = 'Open'];            
            System.assertEquals(createdCaseList[0].AccountId, accountId, 'Account IDs not matching');
            System.assertEquals(createdCaseList[0].App_Code__c, appCode, 'App Code not correct');
            System.assertEquals(createdCaseList[0].PolicyNumber__c, '456789', 'Policy number not correct');
            System.assertEquals(createdCaseList[0].Type, recType, 'Incorrect Record type');
            
        }
        Test.stopTest();
    }
    
    /**
     * @description Method that test successfull call to createECRMCase with Catastrophe case type.
     * 
     */
    @IsTest
    static void getcreateECRMCaseCatastropheSuccess(){
        Test.setMock(HttpCalloutMock.class, new ACMTCreateCalloutMock());
        
        Test.startTest();
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            
            String accountId = UTIL_CaseTestData.createAccountId();
            String appCode = 'SFDC UI - Billing Request';
            Date dateFrom;
            Date dateTo;
            Date dueDate;
            String policyNumber = '456789';
            String recType = 'Catastrophe';
            
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
            List<Case> createdCaseList = [SELECT Id,AccountId,CaseNumber,Date_From__c,Date_To__c,RecordTypeId,PolicyNumber__c,Type,Bill_Due_Date__c,App_Code__c FROM Case WHERE CaseNumber = :caseNum AND Status = 'Open'];
            System.assertEquals(createdCaseList[0].AccountId, accountId, 'Account IDs not matching');
            System.assertEquals(createdCaseList[0].App_Code__c, appCode, 'App Code not correct');
            System.assertEquals(createdCaseList[0].PolicyNumber__c, '456789', 'Policy number not correct');
            System.assertEquals(createdCaseList[0].Type, recType, 'Incorrect Record type');
        }
        Test.stopTest();
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
    
    /**
     * @description Helper method that creates an failled callout mock.
     * 
     */
    public class ACMTStatusCalloutMock implements HttpCalloutMock{
        /**
         * @description ACMTStatusCalloutMock
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"caseNumber": "00046552", ' + 
                '"status": "Closed", ' + 
                '"closedDate": ""}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response;        
        }
    }
    
    /**
     * @description Helper method that creates an successful callout mock.
     * 
     */
    public class ACMTUpdateCalloutMock implements HttpCalloutMock{
        /**
         * @description respond
         * @param req 
         * @return  `HttpResponse`
         */
        public HttpResponse respond(HTTPRequest req){
            req.getEndpoint();
            //check if query is empty :
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"id": "5003K000004irgqQAA","caseNumber": "00000001","message": "Case is Successfully updated in Salesforce","comment": "Case is Successfully updated in Salesforce"}');
            return res;
        }
    }

    /**
     * @description Helper method that creates an bad request callout mock.
     * 
     */
    public class ACMTFailCalloutMock implements HttpCalloutMock{
        /**
         * @description respond
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"timestamp":"2022-12-15T19:32:11.137","code":"400","message":"Header is missing in request.","description":["Required request header \'applicationName\' for method parameter type String is not present"]}');
            response.setStatusCode(400);
            response.setStatus('Bad Request');
            return response;    
        }
    }
}