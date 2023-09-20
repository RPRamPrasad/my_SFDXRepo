/**
 * @className: BATCH_ChatterMonitoring
 * @description This is the test class checking code coverage for class AP_BatchChatterTranscript
 * to test the clean up of stage Feed and creating new records in captured Transcript Feeds.
 * @Author: Team ITIC
 */

@isTest(seeAllData = false)
private class BATCH_ChatterMonitoring_TEST {
	private static final Integer BATCH_SIZE=1;

	private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static final String CHATTER_MON_USER_ID = UTIL_TestUsername_TEST.getTestUsername('chatmon');
    private static final String ITIM_PROC_ID = UTIL_TestUsername_TEST.getTestUsername('itimuser');
 /**
   * @description testSetUpData: Test Helper method to setup data
   */
 @testsetup
	public static void testSetUpData(){
		CS_SendToSize__c sendToCS = new CS_SendToSize__c(Name='ChatterMonitoring',SendToSize__c =100);
    	insert sendToCS;
    	CS_EnvironmentURLCustomSetting__c envURLCustomSetting = new CS_EnvironmentURLCustomSetting__c(Name='Customer_Aggregator_SR_API_Key',Value__c='ac3fa473-d302-4fc6-9eee-912cf9a96fe3');
      	CS_EnvironmentURLCustomSetting__c envURLCategory = new CS_EnvironmentURLCustomSetting__c(Name='SR_CATEGORY',Value__c='NO_SUB_CATEGORY');
        insert envURLCustomSetting;
        insert envURLCategory;
   }

	/**
	 * @description test method to create users
	 */
   public static void createUsers(){
   		User systemUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile(SYSADMIN_USER_ID);
        insert systemUser;
		User processChatterUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin (CHATTER_MON_USER_ID);
		insert processChatterUser;
		TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(processChatterUser);
		UTIL_PermissionSetting_TEST.permissionForChatterMonitoringProcess (processChatterUser.Id);
		User processITIMUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin (ITIM_PROC_ID);
	    insert processITIMUser;
	    UTIL_PermissionSetting_TEST.permissionForITIM (processITIMUser.Id);
   }
	/**
   * @description This method executes the batch and test the feed items are captured
   * @Name:  testChatterFeedTranscriptProcess
   */
   	@isTest
    static void testChatterFeedTranscriptProcess(){
    	createUsers();
    	User processChatterUser = [select id from User where username =: CHATTER_MON_USER_ID];
		User processITIMUser = [select id from User where username =: ITIM_PROC_ID];
		User testAgentUser = new User(Alias='ALIAS',LastName='AgentName',Username=UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='ASSOCID',UserExternalID__c='ASSOCID',Servicing_Agent_Associate_ID__c='ASSOCID',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
		User agent = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
    	agent.FirstName = 'Test';
    	agent.Title = 'Agent';
    	system.runAs(processITIMUser){
    		insert agent;
    	}
		TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);

    	FeedItem feedRecord = new FeedItem(Body='Test for Feed Item',ParentId=agent.Id);
    	FeedItem feedRecordNext = new FeedItem(Body='Test for Feed Item next Topic',ParentId=agent.Id);
    	system.runAs(agent){
    		insert feedRecord;
    	}
    	FeedStage__c stageRecord = new FeedStage__c(FeedItemID__c=feedRecord.Id);
    	FeedStage__c stageRecord2;
		stageRecord2 = new FeedStage__c(FeedItemID__c=feedRecordNext.Id);
    	system.runAs(agent){
    		insert stageRecord;
    	}
		
    	system.runAs(processChatterUser){
			test.startTest();
			CS_ChatterMonitoringBatchId__c chatterMonitoringBatchId = new CS_ChatterMonitoringBatchId__c();
        	chatterMonitoringBatchId.Name = 'ChatterMonitoringBatchId';
        	chatterMonitoringBatchId.lastExecutedBatchId__c = system.now().format('yyyyMMddhhmmssSSS');
        	insert chatterMonitoringBatchId;
	    	BATCH_ChatterMonitoring monitorPrpocess= new BATCH_ChatterMonitoring();
	    	database.executebatch(monitorPrpocess,BATCH_SIZE);
	    	test.stopTest();
    	}
    	Integer stageFeedCount = [Select count() from FeedStage__c where id=:stageRecord.id];
    	Captured_Feed_Transcript__c capturedFeed = [Select Id,EmailBody__c,EmailSubject__c,FeedItem__c,Participants__c from Captured_Feed_Transcript__c where FeedItem__c=:feedRecord.Id];
    	system.assert(stageFeedCount==0, 'stage Feed count equal to 0');
    	system.assert(capturedFeed.Participants__c == Agent.email, 'participant object capturedfeed equal to email agent');
    	system.assert(capturedFeed.EmailSubject__c == System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id, 'Email subject for the email sould be equal to:'+System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT+feedRecord.Id);
    	system.assert(capturedFeed.EmailBody__c!= null, 'Email body should not be Null');
	}
}