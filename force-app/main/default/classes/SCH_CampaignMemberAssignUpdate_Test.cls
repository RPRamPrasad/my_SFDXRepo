/**
  * @name SCH_CampaignMemberAssignUpdate_Test
  * @author Incognito
  * @description Test class for SCH_CampaignMemberAssignUpdate
  */
  @isTest(seeAllData = false)
  private class SCH_CampaignMemberAssignUpdate_Test {
    public static Date todaysDate = System.today();
    public static Integer nextYear = todaysDate.Year() + 1;
    public static String cronExp = '0 0 0 1 6 ? '+ nextYear;
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');

    /**
   * @description testSetUpData: Test Helper method to setup data  
   */
    @testsetup
    public static void testSetUpData(){
           // generate process id
           
           CS_ApexBatchSize__c batchSize = new CS_ApexBatchSize__c(Name='CampaignMemberAssignUpdate',BatchSize__c=200);
             insert batchSize;
    }

    /**
    * @method test method to verify that the scheduler class is able to be scheduled properly 
    * @description   testScheduleOpportunityCampaign
    */
    @isTest
    static void testScheduleCampMembAssignUpdate() {
        User systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        String jobId = null;
        Test.startTest();
        system.runAs(systemAdminUser){
            jobId = System.schedule('ScheduleCampMemAssignUpdate', cronExp, new SCH_CampaignMemberAssignUpdate ());
        }
        Test.stopTest();   
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];                            
        System.assertEquals(cronExp, ct.CronExpression,'Expected value is ' +cronExp+' , but actual value is '+ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered,'Expected value is 0, but actual value is '+ct.TimesTriggered);
        System.assertEquals(nextYear+'-06-01 00:00:00',String.valueOf(ct.NextFireTime),'Expected Fired time is not matched with actual time');
    }
}