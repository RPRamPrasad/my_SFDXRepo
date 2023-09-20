@isTest(seeAllData = false)
public with sharing class SCH_HistoricalOpportunityCampaign_TEST {
    public static Date todaysDate = System.today();
    public static Integer nextYear = todaysDate.Year() + 1;
    public static String cron_Exp = '0 0 0 1 6 ? '+nextYear;
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');

    /**
   * @description testSetUpData: Test Helper method to setup data  
   */
	@testsetup
	
	public static void testSetUpData(){
   		// generate process id
           
           CS_ApexBatchSize__c chatterMonitorCS = new CS_ApexBatchSize__c(Name='HistoricalOpportunityCampaign',BatchSize__c=200);
      	   insert chatterMonitorCS;
	}

    /**
	* @method test method to verify that the scheduler class is able to be scheduled properly 
	* @description  testScheduleOpportunityCampaign
	*/
	@isTest
	static void testScheduleOpportunityCampaign() {
        User systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
	    String jobId = null;
	    Test.startTest();
		system.runAs(systemAdminUser){
			jobId = System.schedule('ScheduleHistoricalCampaign', cron_Exp, new SCH_HistoricalOpportunityCampaign ());
	    }
		Test.stopTest();   
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];                            
	    System.assertEquals(cron_Exp, ct.CronExpression,'Expected Cron Expression is'+cron_Exp+'but actual is'+ct.CronExpression);
	    System.assertEquals(0, ct.TimesTriggered,'Times Triggered should be empty');
	    System.assertEquals(nextYear+'-06-01 00:00:00',String.valueOf(ct.NextFireTime),'Expected Fire Time is'+nextYear+'-06-01 00:00:00'+'but actual value is'+String.valueOf(ct.NextFireTime));
    }
}
