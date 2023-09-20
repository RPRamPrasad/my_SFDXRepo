/**
  * @name SCH_CreateMissingAgreeRiskShares_TEST 
  * @author NSYNC
  * @description Test class for SCH_CreateMissingAgreeRiskShares
  */
@isTest
private class SCH_CreateMissingAgreeRiskShares_TEST {
    //set it to a time Next year 
    public static Integer yearNext = System.today().Year() + 1;
    public static String cron_Exp = '0 0 0 1 6 ? '+yearNext;
    
    /**
    * @method test method to verify that the scheduler class is able to be scheduled properly 
    * @description  testScheduleCreateMissingShares
    */
    public static testmethod void testScheduleCreateMissingShares() {
        User sysAdminUser = new User(alias = 'testSys', email='remCmpMemSysAd@statefarm.com', emailencodingkey='UTF-8', lastname='Sys User', 
                                    languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', 
                                    username= 'remCmpMemSysAd@statefarm.com');
        sysAdminUser.ProfileId = [select Id from Profile where name = :UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME LIMIT 1].Id;
        System.runAs(sysAdminUser) {
            CS_ApexBatchSize__c passBatchSize = new CS_ApexBatchSize__c();
            passBatchSize.Name ='CreateMissingAgreeRiskShares';
            passBatchSize.BatchSize__c =2;
            insert passBatchSize;
        }
        User processID = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin('CreateRiskShareTestSystemAdm@statefarm.com');   
        insert processID;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(processID);        
        // Query your permission set name from Organization that your want to test.
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'SF_CRM_AgreeRiskShare_PermSet' Limit 1];
        
        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment permSetAssign = new PermissionSetAssignment();        
        permSetAssign.AssigneeId = processID.Id;
        permSetAssign.PermissionSetId = permSet.Id;
        insert permSetAssign;
        System.runas(processID){
            Test.StartTest();
            // Schedule the test job
            String jobId = System.schedule('RunBatchApexTest', cron_Exp,
                                         new SCH_CreateMissingAgreeRiskShares());
            // Get the information from the CronTrigger API object
            CronTrigger cronTriggerTest = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                               FROM CronTrigger 
                                   WHERE id = :jobId];
            Test.StopTest();                               
            // Verify the expressions are the same
            System.assertEquals(cron_Exp, cronTriggerTest.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, cronTriggerTest.TimesTriggered);
            // Verify the next time the job will run
            System.assertEquals(yearNext+'-06-01 00:00:00',String.valueOf(cronTriggerTest.NextFireTime)); 
        }
    }
}