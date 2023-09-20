@isTest
(seeAllData=false)
public class CaseRelationServiceTest {

    @TestSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAllUsers();
        CaseTestSetup.setupTest(TestUserSetupUtility.getAgentUser());
    }

    @isTest
    private static void testCSRCaseAsAgent(){
        Test.startTest();
        User agent = TestUserSetupUtility.getAgentUser();
        List<Case> csrCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
        csrCases = closeCases(csrCases);
        System.runAs(agent){
            update csrCases;
        }
        csrCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
        //Test Starts
        System.runAs(agent){
            List<Task> csrtasks = CaseTestSetup.buildTasks(csrCases);
            insert csrtasks;
        }
        csrCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
        for(Case csr : csrCases){
            System.assertEquals(1, csr.tasks.size(), 'tasks on each csr case');
            System.assertEquals(CaseHandlerConstants.CASE_STATUS_PENDING, csr.Status, 'Re-open status check');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testRetentionCaseAsAgent(){
        Test.startTest();
        User agent = TestUserSetupUtility.getAgentUser();
        List<Case> retCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_RETENTION);
        retCases = closeCases(retCases);
        System.runAs(agent){
            update retCases;
        }
        retCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_RETENTION);
        //Test Starts
        System.runAs(agent){
            List<Task> rettasks = CaseTestSetup.buildTasks(retCases);
            
            insert rettasks;
        }
        retCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_RETENTION);
        for(Case ret : retCases){
            System.assertEquals(1, ret.tasks.size(), 'tasks on each ret case');
            System.assertEquals(CaseHandlerConstants.CASE_STATUS_PENDING, ret.Status, 'Re-open status check');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testPolicyChangeCaseAsAgent(){
        Test.startTest();
        User agent = TestUserSetupUtility.getAgentUser();
        List<Case> pcCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE);
        pcCases = closeCases(pcCases);
        System.runAs(agent){
            update pcCases;
        }
        pcCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE);
        //Test Starts
        System.runAs(agent){
            List<Task> pctasks = CaseTestSetup.buildTasks(pcCases);
            insert pctasks;
        }
        pcCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE);
        List<Task> tasksToClose = new List<Task>();
        for(Case pc : pcCases){
            System.assertEquals(1, pc.tasks.size(), 'tasks on each pc case');
            System.assertEquals(CaseHandlerConstants.CASE_STATUS_AGENT_REVIEW, pc.Status, 'Re-open status check');
            System.assertEquals(true, pc.IsEscalated, 'escalation check');
            System.assertEquals(pc.tasks.get(0).ActivityDate, pc.Follow_up_Date__c, 'follow up date');
            tasksToClose.addAll(pc.tasks);
        }
        System.runAs(agent){
            tasksToClose = closeTasks(tasksToClose);
            update tasksToClose;
        }
        pcCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE);
        for(Case pc : pcCases){
            System.assertEquals(false, pc.IsEscalated, 'escalation check');
            System.assertEquals(null, pc.Follow_up_Date__c, 'follow up date');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testCOACaseAsAgentWithLog(){
        Test.startTest();
        User agent = TestUserSetupUtility.getAgentUser();
        List<Case> coaCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
        coaCases = changeCaseReasons(coaCases, CaseHandlerConstants.CASE_REASON_CHANGE_OF_ADDRESS);
        System.runAs(agent){
            update coaCases;
        }
        coaCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
        //Test Starts
        System.runAs(agent){
            List<Task> coaLogs = CaseTestSetup.buildLogs(coaCases);
            insert coaLogs;
        }
        coaCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
        for(Case csr : coaCases){
            System.assertEquals(1, csr.tasks.size(), 'logs on each coa case');
            System.assertEquals(CaseHandlerConstants.CASE_STATUS_CLOSED, csr.Status, 'Auto Close status check');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testCOACaseAsAgentWithTask(){
        Test.startTest();
        User agent = TestUserSetupUtility.getAgentUser();
        List<Case> coaCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
        coaCases = changeCaseReasons(coaCases, CaseHandlerConstants.CASE_REASON_CHANGE_OF_ADDRESS);
        System.runAs(agent){
            update coaCases;
        }
        coaCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
        //Test Starts
        List<Task> coaTasks = CaseTestSetup.buildTasks(coaCases);
        System.runAs(agent){
            insert coaTasks;
        }
        coaCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
        for(Case csr : coaCases){
            System.assertEquals(1, csr.tasks.size(), 'tasks on each coa case');
            System.assertEquals(CaseHandlerConstants.CASE_STATUS_PENDING, csr.Status, 'Auto Close status check');
        }
        coaTasks = closeTasks(coaTasks);
        System.runAs(agent){
            update coaTasks;
        }
        coaCases = getCases(CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
        for(Case csr : coaCases){
            System.assertEquals(1, csr.tasks.size(), 'tasks on each coa case');
            System.assertEquals(CaseHandlerConstants.CASE_STATUS_CLOSED, csr.Status, 'Auto Close status check');
        }
        Test.stopTest();
    }
    
    private static List<Task> closeTasks(List<Task> tasks){
        for(Task t : tasks){
            t.Status = TaskHandlerConstants.TASK_STATUS_COMPLETED;
        }
        return tasks;
    }
    
    private static List<Case> closeCases(List<Case> cases){
        for(Case cr : cases){
            System.assert(!cr.IsClosed, 'cases were already closed');
            cr.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
        }
        return cases;
    }
    
    private static List<Case> changeCaseReasons(List<Case> cases, String reason){
        for(Case cr : cases){
            cr.Reason = reason;
        }
        return cases;
    }
    
    private static List<Case> getCases(Id recordType){
        return [SELECT Id, Subject, OwnerId, ContactId, isEscalated, RecordTypeId, Follow_up_date__c, Status, Request_Type__c, isClosed,
                (SELECT Id, WhatId, Subject, OwnerId, ActivityDate FROM Tasks) 
                FROM Case WHERE RecordTypeId =: recordType];
    }
    
}