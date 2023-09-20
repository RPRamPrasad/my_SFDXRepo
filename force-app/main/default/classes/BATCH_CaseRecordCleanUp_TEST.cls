/**
  * @name BATCH_CaseRecordCleanUp_TEST
  * @author Team Baby Yoda
  * @createdDate 05/24/2021
  * @description Apex unit testing for BATCH_CaseRecordCleanUp Batch class
  */
  @isTest(seeAllData = false)
  public class BATCH_CaseRecordCleanUp_TEST {

      /**
      *@description - This method will set up test data for First Agent Office(Creation of Agent, ATM, Proxy Users and Role hierarchy)
      *@author - Baby Yoda
      */
	  private static final Id MOCK_CASE_ID = '5002300000FakeAAAA'; 
      private static final Id MOCK_CASE_MASTERRECORDID = '5002300000FakeBBBB';
      private static final Id MOCK_TASK_ID = '5002300000FakeCCCC';
      
      @testsetup
      public static void userSetup() {  
          UTIL_CaseTestData.setUpUsersForCase();
          System.runAs(UTIL_CaseTestData.getSysAdminUser()){
              createAccountAndContact();
              Id accountId = UTIL_CaseTestData.getAccount().Id;
              UTIL_CaseTestData.createAgentRoleList(accountId);
          }
      }
      
      /**
       * @description createAccountAndContact
       */
      public static void createAccountAndContact(){
          Id accountId;
          accountId = UTIL_CaseTestData.createAccountId();
          UTIL_CaseTestData.contactId();
      }
  
  
      private static List<Case> caseSetup(){
        User sysAdmin;
        sysAdmin = UTIL_CaseTestData.getSysAdminUser();
        List<Case> mockedCases = new List<Case>();
        // Regular Closed Case
        String caseJSON1 = '{"Subject":"Case 1","Status":"Closed","RecordTypeId":"'+CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE+'"}';
        Case testCase1 = (Case) JSON.deserialize(caseJSON1, Case.class);
        // Closed Case that was created in error
        String caseJSON2 = '{"Subject":"Case 2","Status":"Closed","Created_In_Error__c":"true","RecordTypeId":"'+CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE+'"}'; 
        Case testCase2 = (Case) JSON.deserialize(caseJSON2, Case.class);
        // New Case
        String caseJSON3 = '{"Subject":"Case 4","Status":"New","RecordTypeId":"'+CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE+'"}';
        Case testCase3 = (Case) JSON.deserialize(caseJSON3, Case.class);
        // Merged New Case
        String caseJSON4 = '{"Subject":"Case 3","Status":"New","MasterRecordId":"'+MOCK_CASE_MASTERRECORDID+'","RecordTypeId":"'+CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE+'"}'; 
        Case testCase4 = (Case) JSON.deserialize(caseJSON4, Case.class);
        // Merged Case
        String caseJSON5 = '{"Subject":"Case 5","Status":"Merged","MasterRecordId":"'+MOCK_CASE_MASTERRECORDID+'","RecordTypeId":"'+CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE+'"}';
        Case testCase5 = (Case) JSON.deserialize(caseJSON5, Case.class);
        // Closed Case with Task  
        String caseJSON6 = '{"Subject":"Case 6","Status":"Closed","Id":"'+MOCK_CASE_ID+'","RecordTypeId":"'+CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE+'", "Tasks":{"totalSize":1,"done":true,"records":[{"WhatId":"'+MOCK_CASE_ID+'","IsClosed":"false"}]}}';
        Case testCase6 = (Case) JSON.deserialize(caseJSON6, Case.class);

        mockedCases.add(testCase1);
        mockedCases.add(testCase2);
        mockedCases.add(testCase3);
        mockedCases.add(testCase4);
        mockedCases.add(testCase5);
        mockedCases.add(testCase6);
        return mockedCases;
      }
      
      @isTest
    private static void batchTest(){
          List<Case> mockedCases = caseSetup();
          BATCH_CaseRecordCleanUp batchObjectRecordRemove = new BATCH_CaseRecordCleanUp();
          
          Test.startTest();
          batchObjectRecordRemove.execute(null, mockedCases);
          Test.stopTest();
         
        System.assertEquals(5, BATCH_CaseRecordCleanUp.testCases.size(), 'BATCH_CaseRecordCleanUp.updatedCases.size() is not the correct size');
      }
      
      @isTest
      private static void scheduleBatchTest(){
        BATCH_CaseRecordCleanUp sched= new BATCH_CaseRecordCleanUp();
        String cronExpr = '0 0 0 15 3 ? 2099';
        Test.startTest();
        String jobId = System.schedule('myJobTestJobName', cronExpr, sched);
        sched.execute(null);
        Test.stopTest();
        System.assert(jobId != null, 'Batch Process Id returned null.');
     }
  }