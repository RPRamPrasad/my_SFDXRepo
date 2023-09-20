/**
* @className: AP_BatchChatterTranscript_TEST
* @description This is the test class checking code coverage for class AP_BatchChatterTranscript
* to test the clean up of stage Feed and creating new records in captured Transcript Feeds.
* @author Team ITIC
*/
@isTest(seeAllData = false)
private class AP_BatchChatterTranscript_TEST {
    public static final String DT_FORMAT= ' GMT';

    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static final String CHATTER_MON_USER_ID = UTIL_TestUsername_TEST.getTestUsername('chatmon');
    private static final String ITIM_PROC_ID = UTIL_TestUsername_TEST.getTestUsername('itimuser');
    private static User commonAgentUser = new User(Alias='ALIAS',LastName='AgentName',Username=UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='ASSOCID',UserExternalID__c='ASSOCID',Servicing_Agent_Associate_ID__c='ASSOCID',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
    /**
   * @description Test Helper method to setup data
   * @param User: None
   */
    @testsetup
    public static void testSetUpData(){
    	CS_SendToSize__c sendToCS = new CS_SendToSize__c(Name='ChatterMonitoring',SendToSize__c =3);
    	insert sendToCS;
    	User systemUser = [select id,email from User where profile.name='System Administrator' AND isActive=true limit 1];
        User processITIMUser;
        processITIMUser = TestDataFactory_User_Wrapper.getITIMUser();
    	AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);
        insert sysAdminUserIdSetting;
    }

    /**
     * @description testmethod to create users
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
   * @description This method checks the feed stage data is deleted post processing
   * @Name:  testClenUpStageFeed
   */
    @isTest
    static void testCleanUpStageFeed(){
    	createUsers();
        User processChatterUser = [select id from User where username =: CHATTER_MON_USER_ID];
        User processITIMUser = [select id from User where username =: ITIM_PROC_ID];
        User agent = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
        agent.FirstName = 'Test';
        agent.Title = 'Agent';

        system.runAs(processITIMUser){
            insert agent;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);

        }
        FeedItem feedRecord = new FeedItem(Body='Test for Feed Item',ParentId=agent.Id);
        system.runAs(agent){
            insert feedRecord;
        }
        FeedStage__c stageRecord = new FeedStage__c(FeedItemID__c=feedRecord.Id);
        system.runAs(agent){
            insert stageRecord;
        }
        List<FeedStage__c> stageRecordList = new List<FeedStage__c>();
        stageRecordList.add(stageRecord);
        system.runAs(processChatterUser){
            test.startTest();
            AP_BatchChatterTranscript transcript = new AP_BatchChatterTranscript();
            transcript.processTranscriptForChatterMonitoring(stageRecordList,String.valueOf(DateTime.now().getTime()));
            test.stopTest();
        }
        Integer stageFeedCount = [Select count() from FeedStage__c where id=:stageRecord.id];
        system.assert(stageFeedCount==0,'Stage feed count should be equal to 0');
    }

    /**
   * @description This method checks the Feed Item is captured
   * @Name:  testInsertCaptureTranscript
   * @param: None
   */
    @isTest
    static void testInsertCaptureTranscript(){
    	createUsers();
        User processChatterUser = [select id from User where username =: CHATTER_MON_USER_ID];
        User processITIMUser = [select id from User where username =: ITIM_PROC_ID];
        User agent = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
        agent.FirstName = 'Test';
        agent.Title = 'Agent';
        system.runAs(processITIMUser){
            insert agent;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        }
        String space=AP_UserProvisioningConstants.SPACE;
        String spaceHyphen = ' - ';
        String agentName = agent.FirstName + space + agent.LastName;
        FeedItem feedRecord = new FeedItem(body='Test for Feed Item',ParentId=agent.Id);
        system.runAs(agent){
            insert feedRecord;
        }
        FeedStage__c stageRecord = new FeedStage__c(FeedItemID__c=feedRecord.Id);
        system.runAs(agent){
            insert stageRecord;
        }
        FeedItem feedQuery = [SELECT Id, body, Type,(SELECT CreatedBy.Name,CreatedBy.Email,CreatedBy.Username,CreatedBy.Alias,
                                                     CreatedBy.Title,CreatedDate,CommentBody FROM FeedComments
                                                     order by CreatedDate asc), Parent.Type, Parent.Name,CreatedBy.Title, CreatedBy.Name,
                              CreatedDate,Createdby.ProfileId, CreatedBy.Username,CreatedBy.email, CreatedBy.Alias
                              FROM FeedItem WHERE Id=:stageRecord.FeedItemID__c ];

        String body= AP_UserProvisioningConstants.FEED_ITEM_ID + feedQuery.Id+ AP_UserProvisioningConstants.FEED_TYPE + feedQuery.Parent.Type +
	     			 AP_UserProvisioningConstants.FEED_NAME + feedQuery.Parent.Name +space +AP_UserProvisioningConstants.BEGIN_LINE+ feedQuery.ParentId +
	     			 AP_UserProvisioningConstants.END_LINE + AP_UserProvisioningConstants.PARTICIPANTS+
	     			 AP_UserProvisioningConstants.NEW_LINE + agent.Title + spaceHyphen + agentName + space +
	     			 AP_UserProvisioningConstants.BEGIN_LINE + agent.Alias + AP_UserProvisioningConstants.END_LINE + spaceHyphen +
	     			 agent.Username + spaceHyphen + AP_UserProvisioningConstants.BEGIN_LINE + agent.Id + AP_UserProvisioningConstants.END_LINE +
	     			 AP_UserProvisioningConstants.CONV_START +agentName + space +  agent.Alias + space +
	     			 feedQuery.CreatedDate+DT_FORMAT + AP_UserProvisioningConstants.COLON + space + feedQuery.body + AP_UserProvisioningConstants.CONV_END;

        List<FeedStage__c> stageRecordList = new List<FeedStage__c>();
        stageRecordList.add(stageRecord);
        system.runAs(processChatterUser){
            test.startTest();
            AP_BatchChatterTranscript transcript = new AP_BatchChatterTranscript();
            transcript.processTranscriptForChatterMonitoring(stageRecordList,String.valueOf(DateTime.now().getTime()));
            test.stopTest();
        }
        Captured_Feed_Transcript__c capturedFeed = [Select Id,EmailBody__c,EmailSubject__c,FeedItem__c,Participants__c,BatchId__c from Captured_Feed_Transcript__c where FeedItem__c=:feedRecord.Id];
        system.assert(capturedFeed.Participants__c == Agent.email,'Participants object should be equal to agent email');
        system.assert(capturedFeed.EmailSubject__c == System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id,'Email subject for the email sould be equal to :'+ System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT+feedRecord.Id);
        system.assert(capturedFeed.EmailBody__c == Body, 'Email body should be equal to Body');
        system.assert(capturedFeed.BatchId__c!=null, 'Batch Id object should not equal to null');
    }

    /**
   * @description This method executes the batch and test the feed on Accounts are captured
   * @Name:  testInsertCaptureTranscriptForAccount
   */
    @isTest
    static void testInsertCaptureTranscriptForAccount(){
    	createUsers();
        User processChatterUser = [select id from User where username =: CHATTER_MON_USER_ID];
        User agent = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
        agent.FirstName = 'Test';
        agent.Title = 'Agent';
        User processITIMUser = TestDataFactory_User_Wrapper.getITIMUser();
        system.runAs(processITIMUser){
            insert agent;
	        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        }

        Account accountTest = new Account(Edit_In_VFP__c=true,firstname ='SSSSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c='TESTCLNTID1');
        system.runAs(agent){
            insert accountTest;
        }
        FeedItem feedRecord = new FeedItem(Body='Test for Feed Item on Account',ParentId=accountTest.Id);
        User systemUser = [select id,email from User where username=:SYSADMIN_USER_ID ];
        system.runAs(systemUser){
            insert feedRecord;
        }
        FeedStage__c stageRecord = new FeedStage__c(FeedItemID__c=feedRecord.Id);
        system.runAs(agent){
            insert stageRecord;
        }
        List<FeedStage__c> feedStageList =  new List<FeedStage__c>();
        feedStageList.add(stageRecord);
        system.runAs(processChatterUser){
            test.startTest();
            AP_BatchChatterTranscript transcript = new AP_BatchChatterTranscript();
            transcript.processTranscriptForChatterMonitoring(feedStageList,String.valueOf(DateTime.now().getTime()));
            test.stopTest();
        }
        Integer stageFeedCount = [Select count() from FeedStage__c where id=:stageRecord.id];
        Captured_Feed_Transcript__c capturedFeed = [Select Id,EmailBody__c,EmailSubject__c,FeedItem__c,Participants__c,BatchId__c from Captured_Feed_Transcript__c where FeedItem__c=:feedRecord.Id];
        system.assert(stageFeedCount==0, 'Stage feed count should be equal to 0');
        system.assert(capturedFeed.Participants__c == systemUser.email, 'Participant object should be equal to user email');
        system.assert(capturedFeed.EmailSubject__c == System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id, 'Email subject should be equal to : '+System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id);
        system.assert(capturedFeed.EmailBody__c!= null, 'Email body should not be null');
        system.assert(capturedFeed.BatchId__c!=null, 'Batch Id should not be null');
    }

    /**
   * @description This method executes the batch and test the feed on Accounts are captured
   * @Name:  testInsertCaptureTranscriptForAccount
   * @param: None
   */
    @isTest
   static void testTranscriptForBulkFeedComment(){
   		createUsers();
        User systemUser = [select id,email from User where username =: SYSADMIN_USER_ID];
        User processITIMUser = [select id from User where username =: ITIM_PROC_ID];

        User processChatterUser = [select id from User where username =: CHATTER_MON_USER_ID];
        User agent = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
        agent.FirstName = 'Test';
        agent.Title = 'Agent';
        system.runAs(processITIMUser){
            insert agent;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        }
        FeedItem feedRecord = new FeedItem(Body='Test for Feed Item on Account', ParentId=agent.Id);
        system.runAs(systemUser){
            insert feedRecord;
        }
        List<FeedComment> feedCommentList = new List<FeedComment>();
        for (Integer i=0;i<200;i++){
        	FeedComment comment = new FeedComment(FeedItemId=feedRecord.id,CommentBody='This is a test comment '+i);
        	feedCommentList.add(comment);
        }
        FeedStage__c stageRecord = new FeedStage__c(FeedItemID__c=feedRecord.Id);
        system.runAs(agent){
        	//insert feedCommentList;
            insert stageRecord;
        }
        List<FeedStage__c> feedStageList =  new List<FeedStage__c>();
        feedStageList.add(stageRecord);
        system.runAs(processChatterUser){
            test.startTest();
            AP_BatchChatterTranscript transcript = new AP_BatchChatterTranscript();
            transcript.processTranscriptForChatterMonitoring(feedStageList,String.valueOf(DateTime.now().getTime()));
            test.stopTest();
        }
        Integer stageFeedCount;
        stageFeedCount = [Select count() from FeedStage__c where id=:stageRecord.id];
        List<Captured_Feed_Transcript__c> capturedFeedList = [Select Id,EmailBody__c,EmailSubject__c,FeedItem__c,Participants__c,BatchId__c from Captured_Feed_Transcript__c where FeedItem__c=:feedRecord.Id];
        system.assert(capturedFeedList.size()>0, 'Size of the capture feed list is greaterthan 0');
        for (Captured_Feed_Transcript__c capturedFeed: capturedFeedList){
        	system.assert(capturedFeed.BatchId__c!=null, 'Batch Id should not be null');
        }
    }

    /**
   * @description This method checks the post and comments on collaboration group made by Agent,Atm is captured
   * @Name:  testFeedItemAndCommentMoreParticipants
   * @param: None
   */
    @isTest
    static void testFeedItemAndCommentMoreParticipantsWithSendToSize(){
    	createUsers();
    	User systemUser;
        systemUser = [select id,email from User where username =: SYSADMIN_USER_ID];
        User processITIMUser = [select id from User where username =: ITIM_PROC_ID];

        User processChatterUser = [select id from User where username =: CHATTER_MON_USER_ID];
    	User agent = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
    	agent.FirstName = 'Test';
    	agent.Title = 'Agent';
    	system.runAs(processITIMUser){
    		insert agent;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
    	}
        User testATMUser = new User(Alias='ALIASTM',LastName='ATMName',Username=UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='TASSOCID',UserExternalID__c='TASSOCID',Servicing_Agent_Associate_ID__c='ASSOCID',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
    	User atm = UTIL_UserProvisioning_TEST.buildATMUser(testATMUser);
    	atm.FirstName = 'Test';
    	atm.Title = 'ATM';
    	system.runAs(processITIMUser){
    		insert atm;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atm);
    	}
        testATMUser = new User(Alias='ALIAST2',LastName='ATMName2',Username=UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='T2ASSOCID',UserExternalID__c='T2ASSOCID',Servicing_Agent_Associate_ID__c='ASSOCID',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
    	User atm2 = UTIL_UserProvisioning_TEST.buildATMUser(testATMUser);
    	atm2.FirstName = 'Test2';
    	atm2.Title = 'ATM';
    	system.runAs(processITIMUser){
    		insert atm2;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(atm2);
    	}


    	FeedItem feedRecord = new FeedItem(Body='Test for Feed Item',ParentId=agent.Id);
    	system.runAs(agent){
    		insert feedRecord;
    	}
    	FeedComment feedComment = new FeedComment(FeedItemId=feedRecord.id,commentbody='comment test feed');
    	system.runAs(atm){
    		insert feedComment;
    	}
    	FeedComment feedComment2 = new FeedComment(FeedItemId=feedRecord.id,commentbody='second comment on test feed');
    	system.runAs(atm2){
    		insert feedComment2;
    	}
    	FeedStage__c stageRecord = new FeedStage__c(FeedItemID__c=feedRecord.Id);
    	system.runAs(atm){
    		insert stageRecord;
    	}
    	List<FeedStage__c> feedStageList =  new List<FeedStage__c>();
        feedStageList.add(stageRecord);
        system.runAs(processChatterUser){
            test.startTest();
            AP_BatchChatterTranscript transcript = new AP_BatchChatterTranscript();
            transcript.processTranscriptForChatterMonitoring(feedStageList,String.valueOf(DateTime.now().getTime()));
            test.stopTest();
        }
        Integer stageFeedCount = [Select count() from FeedStage__c where id=:stageRecord.id];
        List<Captured_Feed_Transcript__c> capturedTranscriptList = [Select Id,EmailBody__c,EmailSubject__c,FeedItem__c,Participants__c,BatchId__c from Captured_Feed_Transcript__c where FeedItem__c=:feedRecord.Id];
        system.assert(stageFeedCount==0, 'Stage feed count should be equal to 0');
        system.assert(capturedTranscriptList.size()==2, 'size of the capture transcript list is euqal to 2');
			for(Captured_Feed_Transcript__c capturedFeedTranscript: capturedTranscriptList){
				system.assert(capturedFeedTranscript.FeedItem__c == feedRecord.Id, 'Feed Item object should be equal to feed record Id');
				system.assert(capturedFeedTranscript.EmailSubject__c == System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id, 'Email subject should be equal to:'+ System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id);
				system.assert(capturedFeedTranscript.EmailBody__c != null, 'Email body should not be null');
				system.assert(capturedFeedTranscript.BatchId__c != null, 'Batch Id should not be null');
				system.assert(capturedFeedTranscript.Participants__c != null, 'Participants object should not be null');
			}
    }
}