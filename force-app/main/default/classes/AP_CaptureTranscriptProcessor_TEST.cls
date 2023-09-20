/**
 * @className: AP_CaptureTranscriptProcessor_TEST
 * @description This is the test class checking code coverage for class AP_CaptureTranscriptProcessor
 * to test the chatter monitoring by capturing the transcripts.
 * @Author: Team ITIC
 */

@isTest(seeAllData = false)
private class AP_CaptureTranscriptProcessor_TEST {
	public static final String DT_FORMAT= ' GMT';
	private static User commonAgentUser = new User(Alias='ALIAS',LastName='AgentName',Username=UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='ASSOCID',UserExternalID__c='ASSOCID',Servicing_Agent_Associate_ID__c='ASSOCID',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
	/**
   * @description Test Helper method to setup data
   * @param User: None
   */
	@testsetup
    public static void testSetUpData(){
    	CS_SendToSize__c sendToCS = new CS_SendToSize__c(Name='ChatterMonitoring',SendToSize__c =100);
    	insert sendToCS;
    }

	/**
	 * @description test method to create users
	 */
    public static void createUsers(){
    	User processChatterUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin ('UserChatterProcessDataAdmin@statefarm.com');
		insert processChatterUser;
		UTIL_PermissionSetting_TEST.permissionForChatterMonitoringProcess (processChatterUser.Id);
		TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(processChatterUser);
		User processITIMUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin ('UserITIMProcessDataAdmin@statefarm.com');
	    insert processITIMUser;
	    UTIL_PermissionSetting_TEST.permissionForITIM (processITIMUser.Id);
    }
    /**
   * @description This method checks the post on collaboration group made by Agent is captured
   * @Name:  testFeedItemCaptureAgent
   * @param: None
   */
  	@isTest
    static void testFeedItemCaptureAgent(){
    	createUsers();
    	User processITIMUser = [select id from User where username ='UserITIMProcessDataAdmin@statefarm.com'];
    	User processChatterUser = [select id from User where username ='UserChatterProcessDataAdmin@statefarm.com'];
		User agent = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
    	agent.FirstName = 'Test';
    	agent.Title = 'Agent';
    	system.runAs(processITIMUser){
    		insert agent;
			TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
    	}
    	String space = AP_UserProvisioningConstants.SPACE;
    	String spaceHyphen = ' - ';
    	String agentName = agent.FirstName + space + agent.LastName;
    	Map<Id,FeedItem> feedItemMap = new Map<Id,FeedItem>();
    	FeedItem feedRecord = new FeedItem(body='Test for Feed Item',ParentId=agent.Id);
    	system.runAs(agent){
    		insert feedRecord;
    	}
    	FeedStage__c stageRecord = new FeedStage__c(FeedItemID__c=feedRecord.Id);
    	system.runAs(agent){
    		insert stageRecord;
    	}
    	FeedItem feedQuery = [SELECT Id, body, Type,(SELECT CreatedBy.Name,CreatedBy.Email,CreatedBy.Username,CreatedBy.Alias,
     													CreatedBy.Title,CreatedBy.Id,CreatedDate,CommentBody FROM FeedComments
     														order by CreatedDate asc), ParentId,Parent.Type, Parent.Name,CreatedBy.Id,CreatedBy.Title, CreatedBy.Name,
     															CreatedDate,Createdby.ProfileId, CreatedBy.Username,CreatedBy.email, CreatedBy.Alias
     																FROM FeedItem WHERE Id=:stageRecord.FeedItemID__c ];
		feedItemMap.put(feedQuery.Id,feedQuery);
		AP_CapturedTranscriptBean transcriptBean = new AP_CapturedTranscriptBean();
		List<FeedComment> commentList = new List<FeedComment>();
		transcriptBean.feedItem = feedQuery;
		for(FeedComment comment:feedQuery.FeedComments){
			commentList.add(comment);
		}
		transcriptBean.feedCommentList = commentList;
		system.runAs(processChatterUser){
			test.startTest();
			AP_CaptureTranscriptProcessor processor = new AP_CaptureTranscriptProcessor();
			List<Captured_Feed_Transcript__c> feedTranscript = processor.createTranscript(transcriptBean,String.valueOf(DateTime.now().getTime()));
			test.stopTest();
			String body= AP_UserProvisioningConstants.FEED_ITEM_ID + feedQuery.Id+ AP_UserProvisioningConstants.FEED_TYPE + feedQuery.Parent.Type +
	     					AP_UserProvisioningConstants.FEED_NAME + feedQuery.Parent.Name +space +AP_UserProvisioningConstants.BEGIN_LINE+ feedQuery.ParentId +
	     					AP_UserProvisioningConstants.END_LINE + AP_UserProvisioningConstants.PARTICIPANTS+
	     					AP_UserProvisioningConstants.NEW_LINE + agent.Title + spaceHyphen + agentName + space +
	     					AP_UserProvisioningConstants.BEGIN_LINE + agent.Alias + AP_UserProvisioningConstants.END_LINE + spaceHyphen +
	     					agent.Username + spaceHyphen + AP_UserProvisioningConstants.BEGIN_LINE + agent.Id + AP_UserProvisioningConstants.END_LINE +
	     					AP_UserProvisioningConstants.CONV_START +agentName + space +  agent.Alias + space +
	     					feedQuery.CreatedDate+DT_FORMAT + AP_UserProvisioningConstants.COLON + space + feedQuery.body + AP_UserProvisioningConstants.CONV_END;
			system.assert(feedTranscript[0].FeedItem__c == feedRecord.Id, 'Feed Item object should be equal to feed record Id');
			system.assert(feedTranscript[0].Participants__c == Agent.email, 'Participants object should be equal to agent email');
			system.assert(feedTranscript[0].EmailSubject__c == System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id, 'Email subject should be equal to:'+System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id);
			system.assert(feedTranscript[0].EmailBody__c == Body, 'Email body object should to be equal to body');
			system.assert(feedTranscript[0].BatchId__c != null, 'Batch Id object should no be null');
		}
    }

    /**
   * @description This method checks the captured Feed is split into new records if exceeds field length of email body
   * @Name:  testLongEmailBodyTranscripts
   * @param: None
   */
  	@isTest
    static void testLongEmailBodyTranscripts(){
    	createUsers();
    	User processITIMUser = [select id from User where username ='UserITIMProcessDataAdmin@statefarm.com'];
    	User processChatterUser = [select id from User where username ='UserChatterProcessDataAdmin@statefarm.com'];
    	User agent = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
    	agent.FirstName = 'Test';
    	agent.Title = 'Agent';
    	system.runAs(processITIMUser){
    		insert agent;
			TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
    	}
    	String space = AP_UserProvisioningConstants.SPACE;
    	String longText = 'Test for Feed Item';
    	String agentName;
		agentName = agent.FirstName + space + agent.LastName;
    	Map<Id,FeedItem> feedItemMap = new Map<Id,FeedItem>();
    	FeedItem feedRecord = new FeedItem(Body='Test for Feed Item',ParentId=agent.Id);
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
		for (Integer i=1; i<7280; i++){
			longText+=feedQuery.body;
		}
		feedQuery.body = longText;
		feedItemMap.put(feedQuery.Id,feedQuery);
		AP_CapturedTranscriptBean transcriptBean = new AP_CapturedTranscriptBean();
		List<FeedComment> commentList = new List<FeedComment>();
		transcriptBean.feedItem = feedQuery;
		for(FeedComment comment:feedQuery.FeedComments){
			commentList.add(comment);
		}
		transcriptBean.feedCommentList = commentList;
		system.runAs(processChatterUser){
			test.startTest();
			AP_CaptureTranscriptProcessor processor = new AP_CaptureTranscriptProcessor();
			List<Captured_Feed_Transcript__c> feedTranscript = processor.createTranscript(transcriptBean,String.valueOf(DateTime.now().getTime()));
			test.stopTest();

			system.assert(feedTranscript[0].FeedItem__c == feedRecord.Id, 'Feed Item object should be equal to feed record Id');
			system.assert(feedTranscript[0].Participants__c == Agent.email, 'Participants object should be equal to agent email');
			system.assert(feedTranscript[0].EmailSubject__c == System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id+'-'+1, 'Email subject object should be equal to:'+ System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id+'-'+1);
			system.assert(feedTranscript[0].BatchId__c != null, 'Batch Id object should not be null');
			system.assert(feedTranscript[1].EmailSubject__c == System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id+'-'+2, 'Email subject object should be equal to:'+ System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id+'-'+2);
			system.assert(feedTranscript[1].FeedItem__c == feedRecord.Id, 'Feed Item object should be equal to feed record Id');
			system.assert(feedTranscript[1].Participants__c == Agent.email, 'Participants object should be equal to agent email');
			system.assert(feedTranscript[1].BatchId__c != null, 'Batch Id object should not be null');
		}
    }


    /**
   * @description This method checks the post and comments on collaboration group made by Agent,Atm is captured
   * @Name:  testFeedItemAndCommentMoreParticipants
   * @param: None
   */
  	@isTest
    static void testFeedItemAndCommentMoreParticipants(){
    	createUsers();
    	User processITIMUser = [select id from User where username ='UserITIMProcessDataAdmin@statefarm.com'];
    	User processChatterUser = [select id from User where username ='UserChatterProcessDataAdmin@statefarm.com'];
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
    	String space=AP_UserProvisioningConstants.SPACE;
    	String spaceHyphen = ' - ';
    	String agentName = agent.FirstName + space + agent.LastName;
    	String atmName = atm.FirstName + space + atm.LastName;
    	Map<Id,FeedItem> feedItemMap = new Map<Id,FeedItem>();
    	FeedItem feedRecord = new FeedItem(body='Test for Feed Item',ParentId=agent.Id);
    	system.runAs(agent){
    		insert feedRecord;
    	}
    	FeedComment feedComment = new FeedComment(FeedItemId=feedRecord.id,commentbody='comment test feed');
    	system.runAs(atm){
    		insert feedComment;
    	}
    	FeedStage__c stageRecord = new FeedStage__c(FeedItemID__c=feedRecord.Id);
    	system.runAs(atm){
    		insert stageRecord;
    	}
    	FeedItem feedQuery = [SELECT Id, body, Type,(SELECT CreatedBy.Name,CreatedBy.Email,CreatedBy.Username,CreatedBy.Alias,
     													CreatedBy.Title,CreatedDate,CommentBody FROM FeedComments
     														order by CreatedDate asc), Parent.Type, Parent.Name,CreatedBy.Title, CreatedBy.Name,
     															CreatedDate,Createdby.ProfileId, CreatedBy.Username,CreatedBy.email, CreatedBy.Alias
     																FROM FeedItem WHERE Id=:stageRecord.FeedItemID__c ];
		feedComment = [SELECT CreatedBy.Name,CreatedBy.Email,CreatedBy.Username,CreatedBy.Alias,CreatedBy.Title,CreatedDate,CommentBody FROM FeedComment where id=:feedComment.id];
		feedItemMap.put(feedQuery.Id,feedQuery);
		AP_CapturedTranscriptBean transcriptBean = new AP_CapturedTranscriptBean();
		List<FeedComment> commentList = new List<FeedComment>();
		transcriptBean.feedItem = feedQuery;
		for(FeedComment comment:feedQuery.FeedComments){
			commentList.add(comment);
		}
		transcriptBean.feedCommentList = commentList;

		system.runAs(processChatterUser){
			test.startTest();
			AP_CaptureTranscriptProcessor processor = new AP_CaptureTranscriptProcessor();
			List<Captured_Feed_Transcript__c> feedTranscript = processor.createTranscript(transcriptBean,String.valueOf(DateTime.now().getTime()));
			test.stopTest();
			String agentInfo = agentName + space + agent.Alias + space + feedQuery.CreatedDate+ DT_FORMAT + AP_UserProvisioningConstants.COLON + space;
			String atmInfo = atmName + space + atm.Alias + space + feedComment.CreatedDate+ DT_FORMAT + AP_UserProvisioningConstants.COLON + space;
			String atmHeader = AP_UserProvisioningConstants.NEW_LINE + atm.Title + spaceHyphen + atmName + space +
								AP_UserProvisioningConstants.BEGIN_LINE + atm.Alias + AP_UserProvisioningConstants.END_LINE + spaceHyphen +
	     					    atm.Username + spaceHyphen + AP_UserProvisioningConstants.BEGIN_LINE + atm.Id + AP_UserProvisioningConstants.END_LINE;

			String agentHeader = AP_UserProvisioningConstants.NEW_LINE + agent.Title + spaceHyphen + AgentName + space +
								AP_UserProvisioningConstants.BEGIN_LINE + agent.Alias + AP_UserProvisioningConstants.END_LINE + spaceHyphen +
	     						agent.Username + spaceHyphen + AP_UserProvisioningConstants.BEGIN_LINE + agent.Id + AP_UserProvisioningConstants.END_LINE;

			String body= AP_UserProvisioningConstants.FEED_ITEM_ID + feedQuery.Id+ AP_UserProvisioningConstants.FEED_TYPE + feedQuery.Parent.Type +
	     					AP_UserProvisioningConstants.FEED_NAME + feedQuery.Parent.Name+ space +AP_UserProvisioningConstants.BEGIN_LINE+ feedQuery.ParentId +
	     					AP_UserProvisioningConstants.END_LINE + AP_UserProvisioningConstants.PARTICIPANTS+ agentHeader + atmHeader + AP_UserProvisioningConstants.CONV_START +
	     					agentInfo + feedQuery.body +AP_UserProvisioningConstants.NEW_LINE + atmInfo + feedComment.commentBody + AP_UserProvisioningConstants.CONV_END;
			system.assert(feedTranscript[0].FeedItem__c == feedRecord.Id, 'Feed Item object should be equal to feed record Id');
			system.assert(feedTranscript[0].Participants__c == Agent.email+','+ATM.email, 'Participants object should be equal to:'+ Agent.email+','+ATM.email);
			system.assert(feedTranscript[0].EmailSubject__c == System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id, 'Email subject object should be equal to:'+System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedRecord.Id);
			system.assert(feedTranscript[0].EmailBody__c == Body, 'Email Body object should be equal to body');
			system.assert(feedTranscript[0].BatchId__c != null, 'Batch Id object should not be null');
		}
    }

    /**
   * @description This method checks the captured transcripts split for participants more than 200
   * @Name:  testCapturedTranscriptSplitForTooManyParticipants
   * @param: None
   */
  	@isTest
    static void testCapturedTranscriptSplitForTooManyParticipants(){
    	createUsers();
    	User processITIMUser = [select id from User where username ='UserITIMProcessDataAdmin@statefarm.com'];
    	User processChatterUser;
		processChatterUser = [select id from User where username ='UserChatterProcessDataAdmin@statefarm.com'];
    	User agent = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
    	system.runAs(processITIMUser){
    		insert agent;
			TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
    	}
    	FeedItem feedItem = new FeedItem(body='Test for Feed Item',ParentId=Agent.Id);
    	system.runAs(agent){
    		insert feedItem;
    	}

    	Set<AP_TranscriptProcess> participantSet =  new Set<AP_TranscriptProcess >();
    	for(Integer i=1;i<=201;i++){
			AP_TranscriptProcess.TranscriptUserDataWrapperList participanTstranscriptCommentObjectWrap = new AP_TranscriptProcess.TranscriptUserDataWrapperList();
			participanTstranscriptCommentObjectWrap.uniqueKey = UTIL_TestUsername_TEST.getTestUsername();
			participanTstranscriptCommentObjectWrap.pEmail = 'email'+i+'@statefarm.com';
			participanTstranscriptCommentObjectWrap.pName = 'Name'+i;
			participanTstranscriptCommentObjectWrap.pAlias = 'ABC'+i;
			participanTstranscriptCommentObjectWrap.pTitle = 'Agent';
			participanTstranscriptCommentObjectWrap.pId = '123456789012'+i;
			AP_TranscriptProcess  transcriptCommentObj = new AP_TranscriptProcess(participanTstranscriptCommentObjectWrap);
    		participantSet.add(transcriptCommentObj);
    	}
    	Captured_Feed_Transcript__c addTranscript = new Captured_Feed_Transcript__c();
     	addTranscript.FeedItem__c = feedItem.Id;
     	addTranscript.BatchId__c = 'timestamp';
     	addTranscript.EmailSubject__c = System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + feedItem.Id;
     	String body = 'This is a Feed Item';
     	test.startTest();
     	AP_CaptureTranscriptProcessor captureTranscripProcessor = new AP_CaptureTranscriptProcessor();
		AP_CaptureTranscriptProcessor.FeedTranscriptListWrapperList formatFeedTranscriptWrap = new AP_CaptureTranscriptProcessor.FeedTranscriptListWrapperList();
			formatFeedTranscriptWrap.participantSet = participantSet;
			formatFeedTranscriptWrap.feedWithComments = feedItem;
			formatFeedTranscriptWrap.addTranscript = addTranscript;
			formatFeedTranscriptWrap.Body = Body;
		List<Captured_Feed_Transcript__c> capturedTranscriptList = captureTranscripProcessor.formatTranscript(formatFeedTranscriptWrap);
     	test.stopTest();
     	system.assert(capturedTranscriptList.size()==3, 'Size of captured transcript list should be equal to 3');

     	Set<String> capturedParticipantAllSet = new Set<String>();
     	for (Integer i=0;i<capturedTranscriptList.size();i++){
     		for (String capturedParticipant: (capturedTranscriptList[i].Participants__c).split(',')){
     			capturedParticipantAllSet.add(capturedParticipant);
     		}
     	}
     	system.assert(participantSet.size() == capturedParticipantAllSet.size(), 'size of the participant set should be equal to size of captured participant all set');
    }
}