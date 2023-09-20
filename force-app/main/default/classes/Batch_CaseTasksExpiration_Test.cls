/**
  * @name Batch_CaseTasksExpiration_Test
  * @author Team Baby Yodas
  * @createdDate 01/21/2019
  * @description Apex unit testing for Batch_CaseTasksExpiration Batch class
  */
@isTest(seeAllData = false)
public class Batch_CaseTasksExpiration_Test {
    private static Integer daysOlderThan = 0;
    private static Integer monthsOlderThan = 0;
    private static Integer yearsOlderThan = 0;

    /**
    *@description - This method will set up test data for First Agent Office(Creation of Agent, ATM, Proxy Users and Role hierarchy)
    *@author - Baby Yodas
    */
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


    private static List<Case> getOpenCases(Boolean caseUpdated) {
        List<Case> casesToProcess = new List<Case>();
        
        DateTime searchDate = System.Now().addDays(-daysOlderThan);
        for (List<Case> openCases : [SELECT Id, Status, Expired__c, LastModifiedDate, CreatedDate
                                     FROM Case 
                                     WHERE Status != 'Closed'
                                     AND CreatedDate <= :searchDate] ) { 
            for (Case openCase : openCases) {
                if (caseUpdated || openCase.LastModifiedDate.isSameDay(openCase.CreatedDate)) {
                    casesToProcess.add(openCase);
                }
            } 
        }        
        return casesToProcess;
    }

    private static List<Case> getExpirableCases(List<Case> openCases, Boolean noCaseTask) {
        List<Case> expirableCaseList = new List<Case>();
        List<Task> caseTasks = new List<Task>();
        Date task3DaysOverDue = Date.today().addDays(-3);
        
        // Prepare list of fetched case Ids
        List<String> openCaseIDs = new List<String>();
        for (Case openCase : openCases) {
            openCaseIDs.add(openCase.Id);
        }

        if (noCaseTask) {
        // Prepare a filtered list of above case Ids for which task is created
	        caseTasks = [SELECT WhatId FROM Task Where WhatId in :openCaseIDs ];
        } else {
    	    caseTasks = [SELECT WhatId, Status, Expired__c  
                                FROM Task 
                                WHERE WhatId IN :openCaseIDs 
                                AND IsRecurrence = false
                                AND IsClosed = false
                         		AND ActivityDate > :task3DaysOverDue
                                ];
        }
        Set<Id> caseIdsWithTask = new Set<Id>();
        for (Task task : caseTasks) {
            caseIdsWithTask.add(task.WhatId);
        }
            
        // Filter out case Ids with task created. Remaining cases have no tasks and are ready to be expired
        for (Case openCase : openCases) {
            if (!caseIdsWithTask.contains(openCase.Id)) {
                expirableCaseList.add(openCase);
            }
        }
        
		return expirableCaseList;        
    }
    
    
    /**
    * @description :  test method for Expiration of Cases with No Task via Batch 
    * @Author :  Baby Yodas
    */
    @isTest
    public static void testWithTaskOpenCaseTasksExpirationViaBatch() {
        Batch_CaseTasksExpiration.days90OlderThan = daysOlderThan;
        Batch_CaseTasksExpiration.days30OlderThan = daysOlderThan;
        Batch_CaseTasksExpiration batchCaseTasksExpiration = new Batch_CaseTasksExpiration();
        Case testCase = new Case();
        Case testCase1 = new Case();
        system.runAs(UTIL_CaseTestData.getSysAdminUser()){
            testCase = UTIL_CaseTestData.createDARCaseWithContactAndOwnerId(UTIL_CaseTestData.getAgentProxyUser().Id, UTIL_CaseTestData.getAccount().PersonContactId);
            testCase1 = UTIL_CaseTestData.createDARCaseWithContactAndOwnerId(UTIL_CaseTestData.getAgentProxyUser().Id, UTIL_CaseTestData.getAccount().PersonContactId);
        }
        system.runAs(UTIL_CaseTestData.getSysAdminUser()){
            List<Task> taskList = new List<Task>();
            Task task = new Task (Status = 'In Progress', Subject = 'Test Source Update', OwnerId = UTIL_CaseTestData.getAgentProxyUser().Id, WhatId = testCase.Id
                                  , ActivityDate = Date.today().addDays(-4), IsRecurrence = false);
            taskList.add(task);
            Task task1 = new Task (Status = 'In Progress', Subject = 'Test Source Update', OwnerId = UTIL_CaseTestData.getAgentProxyUser().Id, WhatId = testCase1.Id, ActivityDate = Date.today().addDays(1));
            taskList.add(task1);
            insert taskList;
        }

        system.runAs(UTIL_CaseTestData.getSysAdminUser()){
            List<Case> casesToProcess = getOpenCases(true);
            List<Case> expirableCaseList = getExpirableCases(casesToProcess, false);
        
            Test.startTest();
            Database.executeBatch(batchCaseTasksExpiration, 2000);

            Test.stopTest();
            List<Case> casesLeftAfterProcess = getOpenCases(true);

            System.assert(!casesLeftAfterProcess.isEmpty(), 'No cases left after process.');
            System.assert(casesToProcess.size() - expirableCaseList.size() > 0, 'No cases left after process.');
        }
        
    }
    
    /**
    * @description : test method to verify that the scheduler class is able to be scheduled properly 
    * @Author: Baby Yodas
    */ 
    @isTest
  	static void testScheduleCaseTasksExpiration() {     
        Date todaysDate = System.today();
        Integer nextYear = todaysDate.Year() + 1; //set it to a time which is after some time from now. Next year is an example
        String expireCaseRunExp = '0 0 0 1 8 ? ' + nextYear;  //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    	system.runAs(UTIL_CaseTestData.getApiOnlyUser()){
            Test.startTest();
            Batch_CaseTasksExpiration scheduleCaseExpirationBatch = new Batch_CaseTasksExpiration();//schedule the job      
            String expireCaseBatchJobId = System.schedule('Batch_CaseTasksExpiration', expireCaseRunExp, scheduleCaseExpirationBatch);
            List<CronTrigger> cronTriggerTest = [select id, TimesTriggered, CronExpression From CronTrigger where Id = :expireCaseBatchJobId];
            Test.stopTest(); 
            system.assertEquals(true, cronTriggerTest!=null && cronTriggerTest.size() == 1,'Failed Scheduling Expire Case Batch Job');//verify if the job was scheduled.                 
            System.assertEquals(0, cronTriggerTest.get(0).TimesTriggered, 'Failed to run the job.'); //verify that job didnt run yet.
        }
  	}  
    
}