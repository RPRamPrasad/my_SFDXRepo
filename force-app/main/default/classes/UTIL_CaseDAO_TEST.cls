@isTest(seeAllData=false)
public class UTIL_CaseDAO_TEST {
    private static String className = 'UTIL_CaseDAO_TEST';
    private static User runAsUser;
    private static Integer countOfCaseBeforeInsert = [SELECT count() FROM Task];
    private static String productDescriptionOverLimit = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas tincidunt lectus at consectetur consequat. Aliquam ultrices, magna eu rhoncus vestibulum, massa quam interdum ligula, ac pulvinar felis leo ac massa. Aliquam ullamcorper, tortor eu condimentum facilisis, ex nisl elementum nibh nullam.';
        
    //test setup
    private static User setUpTestData() {
        User testAgentUser1 = new User(Alias='agen',LastName='agentTestUserForCase',Username='agentTestUserForCase@statefarm.com.bad',Associate_ID__c='zzzzxzxzx',UserExternalID__c='zzzzxzxzx',Servicing_Agent_Associate_ID__c='zzzzxzxzx');
        runAsUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
        insert runAsUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(runAsUser);
        
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, runAsUser);
        insert passTriggerAll;
        
        return runAsUser;
    }
    @isTest
    static void testInsertCasesForAccountSuccess() {     
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Case testCase1 = new Case(Description = 'Cases Received',Case_Originator__c = 'Agent Office', AccountId = UTIL_CaseTestData.createAccountId(), ProductDescription__c = productDescriptionOverLimit);
            Test.startTest();          
            UTIL_CaseDAO.insertCases(new List<Case>{testCase1});                     
            Test.stopTest();            
        }        
        Integer countCurrentCases = [SELECT count() FROM Case];
        System.assertEquals(countOfCaseBeforeInsert+1, countCurrentCases, 'Expected value is '+countOfCaseBeforeInsert+', but actual value is '+countCurrentCases);
    }
    @isTest
    static void testinsertCasesForAccountFail() {     
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Case testCase1;
            testCase1 = null;
            Test.startTest();          
            UTIL_CaseDAO.insertCases(null);
            Test.stopTest();  
            Integer countCurrentCases = [SELECT count() FROM Case];
            System.assertEquals(countOfCaseBeforeInsert, countCurrentCases, 'Expected value is '+countOfCaseBeforeInsert+', but actual value is '+countCurrentCases);       
        }                
    }
    @isTest
    static void testupdateCasesForAccountFail() {     
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Case testCase1 = new Case(Description = 'New',Case_Originator__c = 'Agent Office', AccountId = UTIL_CaseTestData.createAccountId());
            Test.startTest();          
            UTIL_CaseDAO.insertCases(new List<Case>{testCase1});
            testCase1.Status = 'Fake Value';
            UTIL_CaseDAO.updateCases(null);            
            Test.stopTest();  
            System.assertEquals([Select Status from Case Where Id =:testCase1.Id Limit 1].Status,'New','Status should be New');
            
        }        
        
    }
    @isTest
    static void closeCasesandDisassociatewithParentsuccess(){
        UTIL_CaseTestData.setUpUsersForCase();
        User apiUser = UTIL_CaseTestData.apiOnlyUser;
        //This permset should be replaced with SF_CRM_StageOrch_PermSetPID once it got right access
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SF_CRM_CaseAPI_PermSetPID'];
        insert new PermissionSetAssignment(AssigneeId = apiUser.id, PermissionSetId = ps.Id);
        System.runAs(apiUser) {
            Case testCase1 = new Case(Status = 'New',Case_Originator__c = 'Agent Office', AccountId = UTIL_CaseTestData.createAccountId(), RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
            UTIL_CaseDAO.insertCases(new List<Case>{testCase1});
            Test.startTest();              
            UTIL_CaseDAO.closeCasesAndDisassociateWithParent(new List<Case>{testCase1}, UTIL_CaseTestData.apiOnlyUser.Id, 'test');
            Test.stopTest();
            Case testCase1Update = [Select Status from Case where Id =: testCase1.Id Limit 1];
            System.assertEquals(testCase1Update.Status, UTIL_StageOrchestrationConstants.CASE_CLOSE_STATUS, 'Expected value is '+testCase1Update.Status+', but actual value is '+UTIL_StageOrchestrationConstants.CASE_CLOSE_STATUS);
        }
    }
    @isTest  
    static void singleCaseCreation(){
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Case testCase = new Case(Status = 'New',Case_Originator__c = 'Agent Office', AccountId = UTIL_CaseTestData.createAccountId(), ProductDescription__c = productDescriptionOverLimit);
            Test.startTest();              
            UTIL_CaseDAO.insertCase(testCase);
            Test.stopTest();
            Case testCaseInserted = [Select Status from Case where Id =: testCase.Id];
            System.assertEquals(testCaseInserted.Status,'New', 'Expected value is '+testCaseInserted.Status+', but actual value is New');
        }
        
    }
    @isTest
    static void testTaskCancelledStatusForCaseInDeleteSucess(){    
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {                
            Case testCase1 = new Case(Status ='New',Case_Originator__c = 'Agent Office', AccountId = UTIL_CaseTestData.createAccountId());
            UTIL_CaseDAO.insertCases(new List<Case>{testCase1});
            task task = new task(Status ='Not Started', WhatId = testCase1.Id);
            insert task;
            Test.startTest();              
            UTIL_CaseDAO.closeTasksRelatedToCasesForDelete(new List<Case>{testCase1});			
            Test.stopTest();
            Task testTask1Update = [Select Status from Task where Id =: task.Id Limit 1];
            System.assertEquals(testTask1Update.Status,UTIL_StageOrchestrationConstants.TASK_CANCELLED_STATUS, 'Expected value is '+testTask1Update.Status+', but actual value is '+UTIL_StageOrchestrationConstants.TASK_CANCELLED_STATUS);	   
        } 
    }
    @isTest
    static void testTaskCancelledStatusForCaseInDeletefailure(){    
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {                
            Case testCase1 = new Case(Status ='New',Case_Originator__c = 'Agent Office', AccountId = UTIL_CaseTestData.createAccountId());
            UTIL_CaseDAO.insertCases(new List<Case>{testCase1});
            task task = new task(Status ='Not Started', WhatId = testCase1.Id);
            insert task;
            Test.startTest();              
            UTIL_CaseDAO.closeTasksRelatedToCasesForDelete(new List<Case>{});			
            Test.stopTest();
            Task testTask1Update = [Select Status from Task where Id =: task.Id Limit 1];
            System.assertEquals(testTask1Update.Status,'Not Started', 'Expected value is '+testTask1Update.Status+', but actual value is Not Started');	   
        } 
    }
    @isTest
    static void testTaskRemoveFromBookStatusForCaseInRemovesucess(){
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Case testCase2 = new Case(Status ='inprogress',Case_Originator__c = 'Agent Office', AccountId = UTIL_CaseTestData.createAccountId());
            UTIL_CaseDAO.insertCases(new List<case>{testCase2});
            task task = new task(Status = 'In Progress', WhatId = testCase2.Id);
            insert task;
            Test.startTest();
            UTIL_CaseDAO.closeTasksRelatedToCasesForRemove(new List<Case>{testCase2});           
            Test.stopTest();
            Task testTask2Update = [Select Status from Task where Id=: task.Id Limit 1];
            System.assertEquals(testTask2Update.Status,UTIL_StageOrchestrationConstants.OPPORTUNITY_TASK_CLOSED_REASON, 'Expected value is '+testTask2Update.Status+', but actual value is '+UTIL_StageOrchestrationConstants.OPPORTUNITY_TASK_CLOSED_REASON);            
        }
        
    }
    @isTest
    static void testTaskRemoveFromBookStatusForCaseRemovefailure(){
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Case testCase2 = new Case(Status ='new',Case_Originator__c = 'Agent Office', AccountId = UTIL_CaseTestData.createAccountId());
            UTIL_CaseDAO.insertCases(new List<Case>{testCase2});
            task task = new task(Status ='In Progress', WhatId = testCase2.Id);
            insert task;
            Test.startTest();
            UTIL_CaseDAO.closeTasksRelatedToCasesForRemove(new List<Case>{});            
            Test.stopTest();
            Task testTask2update = [Select Status from Task where Id=: task.Id Limit 1];
            System.assertEquals(testTask2Update.Status,'In Progress', 'Expected value is '+testTask2Update.Status+', but actual value is In Progress');
            
        }
    }
}