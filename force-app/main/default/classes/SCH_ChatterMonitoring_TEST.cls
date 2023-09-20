/**
  * @name SCH_ChatterMonitoring_TEST
  * @author ITIC
  * @description Test class for SCH_ChatterMonitoringProcess
  */
@isTest(seeAllData = false)
private class SCH_ChatterMonitoring_TEST {
    public static Date todaysDate = System.today();
    //set it to a time Next year
    public static Integer nextYear = todaysDate.Year() + 1;
    public static String cronExp = '0 0 0 1 6 ? '+nextYear;

    /**
   * @description testSetUpData: Test Helper method to setup data
   */
   @testsetup
   public static void testSetUpData(){
   		CS_SendToSize__c sendToCS = new CS_SendToSize__c(Name='ChatterMonitoring',SendToSize__c =100);
    	insert sendToCS;
    	CS_EnvironmentURLCustomSetting__c envURLCustomSetting = new CS_EnvironmentURLCustomSetting__c(Name='Customer_Aggregator_SR_API_Key',Value__c='ac3fa473-d302-4fc6-9eee-912cf9a96fe3');
      	insert envURLCustomSetting;
      	CS_ApexBatchSize__c chatterMonitorCS = new CS_ApexBatchSize__c(Name='ChatterMonitoringProcess',BatchSize__c=200);
      	insert chatterMonitorCS;
   }

	/**
	 * @description test method to create users
	 */
   public static void createUsers(){
   	  User processITIMUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin ('UserITIMProcess@statefarm.com');
      insert processITIMUser;
      UTIL_PermissionSetting_TEST.permissionForITIM (processITIMUser.Id);

   	  User processChatterUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin ('UserChatterDataAdmin@statefarm.com');
	  insert processChatterUser;
	  UTIL_PermissionSetting_TEST.permissionForChatterMonitoringProcess (processChatterUser.Id);
   }
    /**
    * @description test method to verify that the scheduler class is able to be scheduled properly
    * @name   testScheduleRollout
    */
    @isTest
    static void testScheduleChatterMonitoring() {
    	createUsers();
      	User processChatterUser = [select id from User where username ='UserChatterDataAdmin@statefarm.com'];
		User processITIMUser = [select id from User where username ='UserITIMProcess@statefarm.com'];
		User testAgentUser = new User(Alias='ALIAS',LastName='AgentName',Username='useragent@statefarm.com',Associate_ID__c='ASSOCID',UserExternalID__c='ASSOCID',Servicing_Agent_Associate_ID__c='ASSOCID',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
		User agent = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
    	agent.FirstName = 'Test';
    	agent.Title = 'Agent';
    	system.runAs(processITIMUser){
    		insert agent;
    	}
    	FeedItem feedRecord = new FeedItem(Body='Test for Feed Item',ParentId=agent.Id);
    	system.runAs(agent){
    		insert feedRecord;
    	}
    	FeedStage__c stageRecord = new FeedStage__c(FeedItemID__c=feedRecord.Id);
    	system.runAs(agent){
    		insert stageRecord;
    	}
	  	system.runAs(processChatterUser){
		  Test.startTest();
		  CS_ChatterMonitoringBatchId__c chatterMonitoringBatchId = new CS_ChatterMonitoringBatchId__c();
		  chatterMonitoringBatchId.Name = 'ChatterMonitoringBatchId';
		  chatterMonitoringBatchId.lastExecutedBatchId__c = system.now().format('yyyyMMddhhmmssSSS');
		  insert chatterMonitoringBatchId;


	      // Schedule the test job
	      String jobId = System.schedule('Chatter Monitoring Process', cronExp,
	                                     new SCH_ChatterMonitoringProcess());

	      // Get the information from the CronTrigger API object
	      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
	                           FROM CronTrigger
	                               WHERE id = :jobId];
		  Test.stopTest();
	      // Verify the expressions are the same
	      System.assertEquals(cronExp, ct.CronExpression, 'CronExression and  CRON EXPRESSION should be same');
	      // Verify the job has not run
	      System.assertEquals(0, ct.TimesTriggered, 'CronTrigger is 0 if there is no job to run');
	      // Verify the next time the job will run
	      System.assertEquals(nextYear+'-06-01 00:00:00',String.valueOf(ct.NextFireTime), 'Job will run when value of next fire time is equal to nextYear+-06-01 00:00:00');
		  }
      }
}