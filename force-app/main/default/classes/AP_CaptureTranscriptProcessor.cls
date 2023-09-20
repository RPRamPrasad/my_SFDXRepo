/**
  * @Name AP_CaptureTranscriptProcessor
  * @Author ITIC
  * @description This class contains methods to process and format the
  * transcripts containing Feed Item and Feed Comments
  */
  public without sharing class AP_CaptureTranscriptProcessor {
  	private static final String DT_FORMAT = ' GMT';
  	private static final String CHATTER_MONITORING = 'ChatterMonitoring';

	/**
	 * @description test method to create transcript
	 * @param capturedTranscriptBean
	 * @param timestampStr
	 * @return  `List<Captured_Feed_Transcript__c>`
	 */
    public List<Captured_Feed_Transcript__c> createTranscript(AP_CapturedTranscriptBean capturedTranscriptBean, String timestampStr){
    	List<Captured_Feed_Transcript__c> capturedTranscriptList = prepareTranscriptBody(capturedTranscriptBean, captureFeedItemAndSubject(capturedTranscriptBean,timestampStr));
    	Integer splitSize = retrieveSplitSize();
    	return splitEmailBodyLongTranscripts(capturedTranscriptList,splitSize,timestampStr);
     }

     private List<Captured_Feed_Transcript__c> splitEmailBodyLongTranscripts(List<Captured_Feed_Transcript__c> capturedTranscriptList,Integer fieldLength, String batchId){
     	List<Captured_Feed_Transcript__c> transcriptSplitList =  new List<Captured_Feed_Transcript__c>();
     	for(Captured_Feed_Transcript__c capturedTranscript: capturedTranscriptList){
     		if(isEmailBodyLong(capturedTranscript,fieldLength)){
		    	String[] emailBodySplitStr = splitByLength (capturedTranscript.EmailBody__c,fieldLength);
		     	for (Integer i=0;i<emailBodySplitStr.size();i++){
				    Captured_Feed_Transcript__c splitTranscript = cloneCapturedFeedTranscript(capturedTranscript);
				    splitTranscript.EmailBody__c = emailBodySplitStr[i];
				    splitTranscript.EmailSubject__c = capturedTranscript.EmailSubject__c+AP_UserProvisioningConstants.HYPHEN+(i+1);
				    transcriptSplitList.add(splitTranscript);
				}
     		} else{
     			transcriptSplitList.add(capturedTranscript);
     		}
     	}
		return transcriptSplitList;
     }

     private Captured_Feed_Transcript__c captureFeedItemAndSubject(AP_CapturedTranscriptBean capturedTranscriptBean, String timestampStr){
     	Captured_Feed_Transcript__c addTranscript = new Captured_Feed_Transcript__c();
     	addTranscript.FeedItem__c = capturedTranscriptBean.feedItem.Id;
     	addTranscript.BatchId__c = timestampStr;
     	addTranscript.EmailSubject__c = System.Label.CL_CAPTURE_TRANSCRIPT_SUBJECT + capturedTranscriptBean.feedItem.Id;
     	return addTranscript;
     }

     private List<Captured_Feed_Transcript__c> prepareTranscriptBody(AP_CapturedTranscriptBean capturedTranscriptBean, Captured_Feed_Transcript__c addTranscript){
     	Set<AP_TranscriptProcess> participantSet =  new Set<AP_TranscriptProcess >();
		AP_TranscriptProcess.TranscriptUserDataWrapperList transcriptObjectWrap = new AP_TranscriptProcess.TranscriptUserDataWrapperList();
		transcriptObjectWrap.uniqueKey = capturedTranscriptBean.feedItem.CreatedBy.Username;
		transcriptObjectWrap.pEmail = capturedTranscriptBean.feedItem.CreatedBy.email;
		transcriptObjectWrap.pName = capturedTranscriptBean.feedItem.CreatedBy.Name;
		transcriptObjectWrap.pAlias = capturedTranscriptBean.feedItem.CreatedBy.Alias;
		transcriptObjectWrap.pTitle = capturedTranscriptBean.feedItem.CreatedBy.Title;
		transcriptObjectWrap.pId = capturedTranscriptBean.feedItem.createdBy.Id;
 		AP_TranscriptProcess  transcriptObj =  new AP_TranscriptProcess(transcriptObjectWrap);
     	participantSet.add(transcriptObj);
     	String body =  addFeedItemBody(capturedTranscriptBean.feedItem);
     	for(FeedComment comment:capturedTranscriptBean.feedCommentList){
			AP_TranscriptProcess.TranscriptUserDataWrapperList transcriptCommentObjectWrap = new AP_TranscriptProcess.TranscriptUserDataWrapperList();
			transcriptCommentObjectWrap.uniqueKey = comment.CreatedBy.Username;
			transcriptCommentObjectWrap.pEmail = comment.CreatedBy.email;
			transcriptCommentObjectWrap.pName = comment.CreatedBy.Name;
			transcriptCommentObjectWrap.pAlias = comment.CreatedBy.Alias;
			transcriptCommentObjectWrap.pTitle = comment.CreatedBy.Title;
			transcriptCommentObjectWrap.pId = comment.CreatedBy.Id;
			AP_TranscriptProcess  transcriptCommentObj = new AP_TranscriptProcess(transcriptCommentObjectWrap);
     		participantSet.add(transcriptCommentObj);
     		body+= addCommentBody(comment, body);
     	}
     	body+= AP_UserProvisioningConstants.CONV_END;
     	FeedTranscriptListWrapperList captureFeedTranscriptWrap = new FeedTranscriptListWrapperList();
			captureFeedTranscriptWrap.participantSet = participantSet;
			captureFeedTranscriptWrap.feedWithComments = capturedTranscriptBean.feedItem;
			captureFeedTranscriptWrap.addTranscript = addTranscript;
			captureFeedTranscriptWrap.body = body;
	return (formatTranscript(captureFeedTranscriptWrap));
     }

	/**
	 * @description test method to format transcript
	 * @param feedTranscriptWrapper
	 * @return  `List<Captured_Feed_Transcript__c>`
	 */
     public List<Captured_Feed_Transcript__c> formatTranscript (FeedTranscriptListWrapperList feedTranscriptWrapper){
	Set<AP_TranscriptProcess > participantSet = feedTranscriptWrapper.participantSet;
	FeedItem feedWithComments = feedTranscriptWrapper.feedWithComments;
	Captured_Feed_Transcript__c addTranscript = feedTranscriptWrapper.addTranscript;
	String body = feedTranscriptWrapper.body;
		List<String> participantList = new List<String>();
		String participants;
     	Long countSendTo = 1;
     	Long sendToSize = retreiveSendToSize();
     	String header = prepareTranscriptHeader(feedWithComments);
     	for (AP_TranscriptProcess userInfo : participantSet){
     		countSendTo++;
     		String participantStr = collectParticipants(participants, userInfo);
     		if(math.mod(countSendTo, sendToSize)==0){
     			participantList.add(participantStr);
     			participants = null;
            } else {
            	participants = participantStr;
            }

			header+= prepareUserInfoInHeader(userInfo);
     	}
     	if(CollectionUtils.isNullOrEmptyList(participantList) || String.isNotBlank(participants)){
     		participantList.add(participants);
		 }
		 System.debug(LoggingLevel.DEBUG,'Actual Memory Used : ' +Limits.getHeapSize());
		 System.debug(LoggingLevel.DEBUG,'Total Memory that can be Used : ' +Limits.getLimitHeapSize());
     	FeedTranscriptListForParticipantWrapperList transcriptListForParticipantWrap = new FeedTranscriptListForParticipantWrapperList();
			transcriptListForParticipantWrap.addTranscript = addTranscript;
			transcriptListForParticipantWrap.participantList = participantList;
			transcriptListForParticipantWrap.header = header;
			transcriptListForParticipantWrap.body = body;
	return splitTranscriptForParticipant(transcriptListForParticipantWrap);
     }

	/**
	 * @description Feed transcript list wrapper list
	 */
	 public class FeedTranscriptListWrapperList{
		public Set<AP_TranscriptProcess > participantSet;
		public FeedItem feedWithComments;
		public Captured_Feed_Transcript__c addTranscript;
		public String body;
	}

     private Long retreiveSendToSize(){
     	CS_SendToSize__c sendToCS = CS_SendToSize__c.getInstance(CHATTER_MONITORING);
     	return Math.roundToLong(sendToCS.SendToSize__c);
     }

    private List<Captured_Feed_Transcript__c> splitTranscriptForParticipant(FeedTranscriptListForParticipantWrapperList splitTranscriptWrapper){
	Captured_Feed_Transcript__c addTranscript = splitTranscriptWrapper.addTranscript;
	List<String> participantList = splitTranscriptWrapper.participantList;
	String header = splitTranscriptWrapper.header;
	String body = splitTranscriptWrapper.body;
     	List<Captured_Feed_Transcript__c> addTranscriptList = new List<Captured_Feed_Transcript__c>();
		for(String participant: participantList){
     		Captured_Feed_Transcript__c cloneCapturedFeedTranscript = cloneCapturedFeedTranscript(addTranscript);
            cloneCapturedFeedTranscript.Participants__c = participant;
     		cloneCapturedFeedTranscript.EmailBody__c = header + AP_UserProvisioningConstants.CONV_START + body;
     		addTranscriptList.add(cloneCapturedFeedTranscript);
     	}
     	return addTranscriptList;
     }

	 private class FeedTranscriptListForParticipantWrapperList{
		private Captured_Feed_Transcript__c addTranscript;
		private List<String> participantList;
		private String header;
		private String body;
	}

      private Captured_Feed_Transcript__c cloneCapturedFeedTranscript(Captured_Feed_Transcript__c originalCapturedFeedTranscript) {
          Captured_Feed_Transcript__c cloneCapturedFeedTranscript = new Captured_Feed_Transcript__c();
          cloneCapturedFeedTranscript.BatchId__c = originalCapturedFeedTranscript.BatchId__c;
          cloneCapturedFeedTranscript.EmailBody__c = originalCapturedFeedTranscript.EmailBody__c;
          cloneCapturedFeedTranscript.EmailSubject__c = originalCapturedFeedTranscript.EmailSubject__c;
          cloneCapturedFeedTranscript.FeedItem__c = originalCapturedFeedTranscript.FeedItem__c;
          cloneCapturedFeedTranscript.Participants__c = originalCapturedFeedTranscript.Participants__c;
          return cloneCapturedFeedTranscript;
      }

     private String collectParticipants(String participant, AP_TranscriptProcess  userInfo){
     	if (participant!=null){
     		participant+= sendTo(userInfo);
     	}else {
     		participant= userInfo.email;
     	}
     	return participant;
     }

     private String sendTo(AP_TranscriptProcess  userInfo){
     	return (AP_UserProvisioningConstants.COMMA + userInfo.email);
     }

     private String prepareTranscriptHeader(FeedItem feedWithComments){
     	String header= AP_UserProvisioningConstants.FEED_ITEM_ID + feedWithComments.Id+ AP_UserProvisioningConstants.FEED_TYPE + feedWithComments.Parent.Type +
     				   AP_UserProvisioningConstants.FEED_NAME + feedWithComments.Parent.Name + AP_UserProvisioningConstants.SPACE + AP_UserProvisioningConstants.BEGIN_LINE +
     				   feedWithComments.ParentId + AP_UserProvisioningConstants.END_LINE + AP_UserProvisioningConstants.PARTICIPANTS;

     	return header;
     }

     private String prepareUserInfoInHeader(AP_TranscriptProcess  userInfo){
     	String userHeader = AP_UserProvisioningConstants.NEW_LINE + userInfo.Title + AP_UserProvisioningConstants.SPACE_HYPHEN + userInfo.Name +
     						AP_UserProvisioningConstants.SPACE + AP_UserProvisioningConstants.BEGIN_LINE + userInfo.Alias + AP_UserProvisioningConstants.END_LINE +
     						AP_UserProvisioningConstants.SPACE_HYPHEN + userInfo.UserName + AP_UserProvisioningConstants.SPACE_HYPHEN +
     						AP_UserProvisioningConstants.BEGIN_LINE + userInfo.Id + AP_UserProvisioningConstants.END_LINE;
     	return userHeader;
     }

     private String addFeedItemBody(FeedItem feedItem){
     	String feedItemBody= feedItem.CreatedBy.Name + AP_UserProvisioningConstants.SPACE + feedItem.CreatedBy.Alias +
     						 AP_UserProvisioningConstants.SPACE + feedItem.CreatedDate + DT_FORMAT;
  		if(feedItem.body!=null){
  			feedItemBody+= AP_UserProvisioningConstants.COLON + AP_UserProvisioningConstants.SPACE + feedItem.Body;
  		}
  		return feedItemBody;
     }

     private String addCommentBody(FeedComment comment, String body){
		body= AP_UserProvisioningConstants.NEW_LINE + comment.CreatedBy.Name + AP_UserProvisioningConstants.SPACE + comment.CreatedBy.Alias +
     		   AP_UserProvisioningConstants.SPACE + comment.CreatedDate+ DT_FORMAT + AP_UserProvisioningConstants.COLON + AP_UserProvisioningConstants.SPACE +
     		   comment.CommentBody;
     	return body;
     }

     private Boolean isEmailBodyLong(Captured_Feed_Transcript__c capturedTranscript, Integer splitSize){
     	if (capturedTranscript.EmailBody__c.length()>splitSize){
     		return True;
     	}
     	return False;
     }

     private String[] splitByLength(String bodyStr, integer splitSize){
		integer arraySize = (integer) Math.ceil((double)bodyStr.length()/splitSize);
		String[] returnArray = new String[arraySize];
	    integer index = 0;
	    for(integer i=0;i<bodyStr.length();i=i+splitSize){
	        if(bodyStr.length()-i<splitSize){
	            returnArray[index++] = bodyStr.substring(i);
	        }else{
	            returnArray[index++] = bodyStr.substring(i,i+splitSize);
	        }
	    }
	    return returnArray;
	}

     private integer retrieveSplitSize(){
     	return (Schema.SObjectType.Captured_Feed_Transcript__c.fields.EmailBody__c.getLength()-1);
     }
}