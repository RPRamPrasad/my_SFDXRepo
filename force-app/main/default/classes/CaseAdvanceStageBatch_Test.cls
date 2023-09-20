/**
  * @name CaseAdvanceStageBatch_Test
  * @author Team Baby Yoda
  * @createdDate 06/29/2020
  * @description Apex unit testing for CaseAdvanceStageBatch Batch class
*/
@isTest(seeAllData = false)
private class CaseAdvanceStageBatch_Test {

    @testSetup
    private static void testSetUp(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CaseTestDataUtility.createAccount();
            CaseTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), CaseTestDataUtility.getAccount());
            CS_Case_Config__c policyChangeAutoCloseDays = new CS_Case_Config__c();
            policyChangeAutoCloseDays.Name = 'PolicyChangeAutoCloseDays';
            policyChangeAutoCloseDays.Value__c = 5;
            CS_Case_Config__c policyChangeAutoAgentReviewDays = new CS_Case_Config__c();
            PolicyChangeAutoAgentReviewDays.Name = 'PolicyChangeAutoAgentReviewDays';
            PolicyChangeAutoAgentReviewDays.Value__c = 2;
            CS_Case_Config__c policyChangeAutoUnSnoozeDays = new CS_Case_Config__c();
            PolicyChangeAutoUnSnoozeDays.Name = 'PolicyChangeAutoUnSnoozeDays';
            PolicyChangeAutoUnSnoozeDays.Value__c = 1;
            insert new List<CS_Case_Config__c>{policyChangeAutoCloseDays,PolicyChangeAutoAgentReviewDays,PolicyChangeAutoUnSnoozeDays};
        }
    }
    
    @isTest
    private static void scheduleBatchTest(){
        CaseAdvanceStageBatch sched= new CaseAdvanceStageBatch();
        String cronExpr = '0 0 0 15 3 ? 2099';
        Test.startTest();
        String jobId = System.schedule('myJobTestJobName', cronExpr, sched);
        sched.execute(null);
        Test.stopTest();
        System.assert(jobId != null, 'Batch Process Id returned null.');
    }
    
    /**
    * @description : test method for Cases requiring Case Stage update due to inactivity 
    * @Author: Baby Yoda
    */
    @isTest
    private static void batchTest(){
        List<Case> mockedCases = caseSetup();
        CaseAdvanceStageBatch recordUpdateBatch = new CaseAdvanceStageBatch();
        
        Test.startTest();
        recordUpdateBatch.execute(null, mockedCases);
        Test.stopTest();
        
        System.assertEquals(3, CaseAdvanceStageBatch.updatedCases.size(), 'CaseAdvanceStageBatch.updatedCases.size() is not the correct size');
        System.assertEquals('Agent Review',CaseAdvanceStageBatch.updatedCases[0].Status, 'Did Not change from Request Sumitted to Agent Review');
        System.assertEquals('Closed',CaseAdvanceStageBatch.updatedCases[1].Status, 'Did not Change from Agent Review to Closed');
        System.assert(!CaseAdvanceStageBatch.updatedCases[2].Snooze__c, 'Did not Unsnooze');
    }
    
    private static List<Case> caseSetup(){
		User proxyUser;
        proxyUser = TestUserSetupUtility.getProxyUser();
        User sysAdmin;
        sysAdmin = TestUserSetupUtility.getSysAdminUser();
        Account accountRecord;
        accountRecord = CaseTestDataUtility.getAccount();
        List<Case> mockedCases = new List<Case>();

        String caseJSON1 = '{"Subject":"Case 1","Status":"Request Submitted","CreatedDate":'+JSON.serialize(DateTime.now().addDays(-7))+',"LastModifiedDate":'+JSON.serialize(DateTime.now().addDays(-3))+',"RecordTypeId":"'+CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE
            +'","Histories":{"totalSize":1,"done":true,"records":[{"CreatedDate":'+JSON.serialize(DateTime.now().addDays(-7))+'}]}}';
        Case testCase1 = (Case) JSON.deserialize(caseJSON1, Case.class);
        String caseJSON2 = '{"Subject":"Case 2","Status":"Agent Review","CreatedDate":"2020-01-04T17:54:26.000+0000","LastModifiedDate":"2020-05-04T17:54:26.000+0000","RecordTypeId":"'+CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE+'"}'; 
        Case testCase2 = (Case) JSON.deserialize(caseJSON2, Case.class);
        //Added scenario 3 - this case should not be updated even if the SOQL incorrectly added it to the list
        String caseJSON3 = '{"Subject":"Case 3","Status":"New","CreatedDate":"2020-01-04T17:54:26.000+0000","LastModifiedDate":"2020-05-04T17:54:26.000+0000","RecordTypeId":"'+CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE+'"}'; 
        Case testCase3 = (Case) JSON.deserialize(caseJSON3, Case.class);
        String caseJSON4 = '{"Subject":"Case 4","Snooze__c":true,"Status":"Agent Review","CreatedDate":'+JSON.serialize(DateTime.now().addDays(-7))+',"LastModifiedDate":'+JSON.serialize(DateTime.now().addDays(-3))+',"RecordTypeId":"'+CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE
            +'","Histories":{"totalSize":1,"done":true,"records":[{"CreatedDate":'+JSON.serialize(DateTime.now().addDays(-7))+'}]}}';
        Case testCase4 = (Case) JSON.deserialize(caseJSON4, Case.class);
        String caseJSON5 = '{"Subject":"Case 4","Snooze__c":true,"Status":"Agent Review","CreatedDate":'+JSON.serialize(DateTime.now().addDays(-7))+',"LastModifiedDate":'+JSON.serialize(DateTime.now().addDays(-3))+',"RecordTypeId":"'+CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE
            +'","Histories":{"totalSize":1,"done":true,"records":[{"CreatedDate":'+JSON.serialize(DateTime.now())+'}]}}';
        Case testCase5 = (Case) JSON.deserialize(caseJSON5, Case.class);
        
        mockedCases.add(testCase1);
        mockedCases.add(testCase2);
        mockedCases.add(testCase3);
        mockedCases.add(testCase4);
        mockedCases.add(testCase5);
        return mockedCases;
    }
}