@isTest
(seeAllData=false)
private class ACMT_Case_Rest_Test {
    @testSetup
    static void dataSetup() {
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            String accId = UTIL_CaseTestData.createAccountId();
            
            Billing_Account__c ba = new Billing_Account__c(AccountNumber__c = '123456789', Name = '123456789', SourceSystemIdentifier__c = '123456789');
            insert ba;
            
            Billing_Participant__c bp = new Billing_Participant__c(Name = '123456789', BillingAccountID__c = ba.id, SourceSystemIdentifier__c = '123456789', ParticipantAccountId__c = accId);
            insert bp;
            
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('alias', '12345678901');
            agent.State_Agent_Code_List__c = '18-1AED';
            agent.State_Agent_Code__c = '18-1AED';
            agent = TestDataFactory_User.insertUser(agent);
            
            User agentOffice = TestDataFactory_User_Wrapper.generateAgentUser('aliis', '12345678912');
            agentOffice.LastName = 'User, 18-1AED-Office';
            agentOffice.State_Agent_Code__c = '18-1AED';
            agentOffice = TestDataFactory_User.insertUser(agentOffice);
            
            
        }
    }
    
    @isTest 
    private static void successfulCreation() {
        Test.setMock(HttpCalloutMock.class, new ACMTCreateCalloutMock());
        
        Case c = new Case();
        c.App_Code__c = 'SF Billing Chat';
        c.Date_From__c = Date.newInstance(2022,01,01);
        c.Date_To__c = Date.newInstance(2022,12,01);
        c.Bill_Due_Date__c = Date.newInstance(2022,01,01);
        c.PolicyNumber__c = '123456789';
        c.Type = 'Bill Explanation';
        User testUser = [Select Id,Alias,State_Agent_Code__c,IsActive FROM User WHERE State_Agent_Code_List__c = '18-1AED' AND Alias = 'alias'];
        Test.startTest();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            RestRequest req = new RestRequest();
            RestResponse restRes = new RestResponse();
            req.requestURI = '/services/apexrest/xyz'; //Request URL
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= restRes;
            ACMT_Case_Response__mdt res = ACMT_Case_Rest.handleRequest(c,testUser);
            System.assertEquals('Case is Successfully created in Salesforce',res.Message__c,'Expected success but was ' + res.Message__c);
            
        }
        Test.stopTest();
    }
    
    @isTest 
    private static void incorrectCaseType() {
        Test.setMock(HttpCalloutMock.class, new ACMTCreateCalloutMock());
        
        Case c = new Case();
        c.App_Code__c = 'SF Billing Chat';
        c.Date_From__c = Date.newInstance(2022,01,01);
        c.Date_To__c = Date.newInstance(2022,12,01);
        c.Bill_Due_Date__c = Date.newInstance(2022,01,01);
        c.PolicyNumber__c = '123456789';
        c.Type = 'Test';
        User testUser = [Select Id,Alias,State_Agent_Code__c,IsActive FROM User WHERE State_Agent_Code_List__c = '18-1AED' AND Alias = 'alias'];
        Test.startTest();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            RestRequest req = new RestRequest();
            RestResponse restRes = new RestResponse();
            req.requestURI = '/services/apexrest/xyz'; //Request URL
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= restRes;
            ACMT_Case_Response__mdt res = ACMT_Case_Rest.handleRequest(c,testUser);
            System.assertEquals('The Case type you have entered is not supported.',res.Message__c,'Expected non-supported case type but was ' + res.Message__c);
            
        }
        Test.stopTest();
    }
    
    @isTest 
    private static void incorrectAccountNumber() {
        Test.setMock(HttpCalloutMock.class, new ACMTCreateCalloutMock());
        
        Case c = new Case();
        c.App_Code__c = 'SF Billing Chat';
        c.Date_From__c = Date.newInstance(2022,01,01);
        c.Date_To__c = Date.newInstance(2022,12,01);
        c.Bill_Due_Date__c = Date.newInstance(2022,01,01);
        c.PolicyNumber__c = '123456700';
        c.Type = 'Test';
        User testUser = [Select Id,Alias,State_Agent_Code__c,IsActive FROM User WHERE State_Agent_Code_List__c = '18-1AED' AND Alias = 'alias'];
        Test.startTest();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            RestRequest req = new RestRequest();
            RestResponse restRes = new RestResponse();
            req.requestURI = '/services/apexrest/xyz'; //Request URL
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= restRes;
            ACMT_Case_Response__mdt res = ACMT_Case_Rest.handleRequest(c,testUser);
            System.assertEquals('invalid billing account',res.Message__c,'Expected invalid billing account but was ' + res.Message__c);
            
        }
        Test.stopTest();
    }
    
    @isTest 
    private static void incorrectAlias() {
        Test.setMock(HttpCalloutMock.class, new ACMTCreateCalloutMock());
        
        Case c = new Case();
        c.App_Code__c = 'SF Billing Chat';
        c.Date_From__c = Date.newInstance(2022,01,01);
        c.Date_To__c = Date.newInstance(2022,12,01);
        c.Bill_Due_Date__c = Date.newInstance(2022,01,01);
        c.PolicyNumber__c = '123456789';
        c.Type = 'Test';
        User testUser = new User();
        testUser.State_Agent_Code_List__c = '18-TEST';
        testUser.Alias = 'TEST';
        Test.startTest();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            RestRequest req = new RestRequest();
            RestResponse restRes = new RestResponse();
            req.requestURI = '/services/apexrest/xyz'; //Request URL
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= restRes;
            ACMT_Case_Response__mdt res = ACMT_Case_Rest.handleRequest(c,testUser);
            System.assertEquals('User not found for selected State Agent Code',res.Message__c,'Expected user not found but was ' + res.Message__c);
            
        }
        Test.stopTest();
    }
    
    @isTest 
    private static void caseAlreadyExists() {
        Test.setMock(HttpCalloutMock.class, new ACMTCreateCalloutMock());
        User testUser = [Select Id,Alias,State_Agent_Code__c,IsActive FROM User WHERE State_Agent_Code_List__c = '18-1AED' AND Alias = 'alias'];
        String resString = 'A Case was created on';
        Case c = new Case();
        c.App_Code__c = 'SF Billing Chat';
        c.Date_From__c = Date.newInstance(2022,01,01);
        c.Date_To__c = Date.newInstance(2022,12,01);
        c.Bill_Due_Date__c = Date.newInstance(2022,01,01);
        c.PolicyNumber__c = '123456789';
        c.Type = 'Bill Explanation';
        
        Test.startTest();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            RestRequest req = new RestRequest();
            RestResponse restRes = new RestResponse();
            req.requestURI = '/services/apexrest/xyz'; //Request URL
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= restRes;
            ACMT_Case_Response__mdt res = ACMT_Case_Rest.handleRequest(c,testUser);
            System.assertEquals('Case is Successfully created in Salesforce',res.Message__c,'Expected success message but was ' + res.Message__c);
            
            ACMT_Case_Response__mdt res2 = ACMT_Case_Rest.handleRequest(c,testUser);
            System.assert(res2.Message__c.contains(resString),res2.Message__c);
        }
        Test.stopTest();
    }
    
    /**
	* @description - Mock callout to ACMT for a successfull Case creation
	*/
    public class ACMTCreateCalloutMock implements HttpCalloutMock{
        /**
		* @description - mock ACMT success response
         * @param req : mock request
         * @return HttpResponse - successful case creation
		*/
        public HttpResponse respond(HTTPRequest req){
            req.getEndpoint();
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"id":"5003K000003e1vaQAA","caseNumber":"00006182","message":"Case is Successfully created in Salesforce","comments":"Agent code or Alias is Updated.","attachment":"Failed to insert the attachment"}');
            return res;
        }
    }
}