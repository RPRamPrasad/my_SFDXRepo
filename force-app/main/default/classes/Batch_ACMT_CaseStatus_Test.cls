@isTest(seeAllData = false)
public class Batch_ACMT_CaseStatus_Test {
    
    /**
     * @description setup
     */
    @testSetup
    public static void setup(){
        
        Case c = new Case();
        c.Date_From__c = system.today();
        c.Date_To__c = system.today().addDays(10);
        c.Subject = 'Created for Testing';
        c.PolicyNumber__c = '0123456789';
        c.Status = 'Open';
        c.Type = 'Bill/Policy Breakdown';
        c.recordtypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_BILLING_REQUEST;
        insert c;
        
        Case c1 = new Case();
        c1.Date_From__c = system.today();
        c1.Date_To__c = system.today().addDays(10);
        c1.Subject = 'Testing get Status';
        c1.Status = 'Open';
        c1.ACMT_Case_Number__c = '00006182';
        c1.PolicyNumber__c = '0123456789';
        c1.Type = 'Bill/Policy Breakdown';
        c1.recordtypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_BILLING_REQUEST;
        insert c1;
    }
    
    @isTest
    public static void testJobSchedule() {
        String cronExp = '0 0 0 1 8 ? ' + (System.today().Year() + 1);  //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        Test.startTest();
        String jobId = System.schedule('Batch_ACMT_CaseStatus',cronExp,new Batch_ACMT_CaseStatus());
        List<CronTrigger> cronTriggerTest = [select id, TimesTriggered, CronExpression From CronTrigger where Id = :jobId];
        Test.stopTest(); 
        system.assertEquals(true, cronTriggerTest!=null && cronTriggerTest.size() == 1,'Failed Scheduling Batch Job');//verify if the job was scheduled.                 
        System.assertEquals(0, cronTriggerTest.get(0).TimesTriggered, 'Failed to run the job.'); //verify that job didnt run yet.
    }
    
    @isTest
    public static void testBatchExecute() {
        // Note: System.TypeException: Methods defined as TestMethod do not support Web service callouts
        Batch_ACMT_CaseStatus batch_ACMT_CaseStatus = new Batch_ACMT_CaseStatus();
        Test.setMock(HttpCalloutMock.class, new ACMTStatusCalloutMock());
        
        Test.startTest();
        Database.executeBatch(batch_ACMT_CaseStatus, 100);
		Case updateCase = [SELECT Status from Case where Subject = 'Created for Testing'];
        system.assertEquals('Open', updateCase.Status,'Expected value is Open, but actual value is '+updateCase.Status);
        Test.stopTest();       
    }
    
    @isTest
    public static void testBillingRequestCaseStatusUpdate() {

        Batch_ACMT_CaseStatusHelper batch_ACMT_CaseStatus = new Batch_ACMT_CaseStatusHelper();
        Test.setMock(HttpCalloutMock.class, new ACMTStatusCalloutMock());

        Test.startTest();
		String status = Batch_ACMT_CaseStatusHelper.getCaseStatus('ACMTCase1');
        system.assert(status == 'Closed', 'Returned Status: ' + status);
        Test.stopTest();       

    }

    @isTest
    public static void testBuildLog() {
        Id ownerUser = '005000000000000000';
        Id contactId = '003000000000000000';
        Id recordId = '500000000000000000';

        Test.starttest();
        Task logTask = Batch_ACMT_CaseStatusHelper.buildLog(ownerUser, contactId, recordId);
        System.assertEquals(ownerUser, logTask.OwnerId,'Expected value is '+ownerUser+', but actual value is '+logTask.OwnerId);
        System.assertEquals(contactId, logTask.WhoId,'Expected value is '+contactId+', but actual value is' +logTask.WhoId);
        System.assertEquals(recordId, logTask.WhatId,'Expected value is '+recordId+', but actual value is '+logTask.WhatId);
        Test.stopTest();       
    }
    
    /**
     * @description ACMTStatusCalloutMock
     */
    public class ACMTStatusCalloutMock implements HttpCalloutMock{
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
            res.setBody('{"caseNumber": "00000001","status": "Closed"}');
            return res;
        }
    }
    
}