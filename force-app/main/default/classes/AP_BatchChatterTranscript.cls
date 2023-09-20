/**
* @name AP_BatchChatterTranscript
* @author Team ITIC
* @date 2/07/2017
* @description This is a batch utility class to handle Chatter/ Feed monitoring for Collaboration group,
* Standard and Custom Object Feeds
*/

public without sharing class AP_BatchChatterTranscript {
    private static final String CLASS_NAME = 'AP_BatchChatterTranscript';
    private AP_LogHolder logHolder =  new AP_LogHolder();
    private AP_CapturedTranscriptBean capturedTranscriptBean;
    private List<Captured_Feed_Transcript__c> transcriptList = new List<Captured_Feed_Transcript__c>();

    /**
     * @description Process Transcript For Chatter Monitoring
     * @param stageFeedList
     * @param timestampStr
     */
    public void processTranscriptForChatterMonitoring(List<FeedStage__c> stageFeedList, String timestampStr){
    	cleanStageFeedItems(stageFeedList);
        processTranscripts(stageFeedList,timestampStr);
    }

    private void cleanStageFeedItems (List<FeedStage__c> stageFeedForDeleteList) {
        Database.delete(stageFeedForDeleteList,False);
    }

    private void processTranscripts (List<FeedStage__c> stageFeedList, String timestampStr) {
    	Set<String> feedItemIdSet = collectFeedItemsFromStage(stageFeedList);
        collectFeedAndComments(feedItemIdSet, timestampStr);
        insertTranscripts(transcriptList);
    }

    private Set<String> collectFeedItemsFromStage(List<FeedStage__c> stageFeedList){
        Set<String> feedIdMonitoredSet = new Set<String>();
        UTIL_ParameterValidator_SalesforceId parameterValidator = new UTIL_ParameterValidator_SalesforceId();
        for (FeedStage__c stageFeed: stageFeedList){
            feedIdMonitoredSet.add(parameterValidator.validateParameter('FeedItemID__c', stageFeed.FeedItemID__c));
        }
        return feedIdMonitoredSet;
    }

    private void collectFeedAndComments(Set<String> feedIdMonitoredSet, String timestampStr){
    	AP_CaptureTranscriptProcessor transcriptProcessor = new AP_CaptureTranscriptProcessor();
        if (Schema.sObjectType.FeedItem.isAccessible()) {
        	for(FeedItem feedItemAndComments : [SELECT Id, body, Type,
                                                  	(SELECT CreatedBy.Name,CreatedBy.Email,CreatedBy.Username,CreatedBy.Alias,
                                                   		CreatedBy.Id, CreatedBy.Title,CreatedDate,CommentBody FROM FeedComments
                                                   			order by CreatedDate asc), ParentId, Parent.Type, Parent.Name,CreatedBy.Title,
                                                  				CreatedBy.Name,CreatedDate,Createdby.ProfileId, CreatedBy.Username,
                                                  					CreatedBy.email, CreatedBy.Alias,CreatedBy.Id
                                                  						FROM FeedItem WHERE Id=:feedIdMonitoredSet]){
			excludeTrackedFeedWithNoComments(feedItemAndComments);
			transcriptList.addAll(transcriptProcessor.createTranscript(capturedTranscriptBean,timestampStr));
      		}
        }
    }

    private void excludeTrackedFeedWithNoComments(FeedItem feedItemAndComments){
    	if(!isTrackedChangeFeed(feedItemAndComments)){
    		capturedTranscriptBean = new AP_CapturedTranscriptBean();
    		List<FeedComment> commentList = new List<FeedComment>();
    		capturedTranscriptBean.feedItem = feedItemAndComments;
    		for(FeedComment comment: feedItemAndComments.FeedComments){
    			commentList.add(comment);
    		}
    		capturedTranscriptBean.feedCommentList = commentList;
        }
    }

    private Boolean isTrackedChangeFeed(FeedItem feedItemCheck){
        String trackedChange = 'TrackedChange';
        return ((feedItemCheck.Type).equals(trackedChange) && feedItemCheck.FeedComments==null);
    }

    private void insertTranscripts (List<Captured_Feed_Transcript__c> newTranscriptList) {
        Savepoint commitSavePoint = Database.setSavepoint();
        try {
            List<Database.Saveresult> insertTranscriptResultList = Database.insert(newTranscriptList, false);
            for (Integer i = 0; i < newTranscriptList.size(); i++) {
                if(!insertTranscriptResultList[i].isSuccess()) {
                    String errorMessage = newTranscriptList[i].FeedItem__c + UTIL_Constants.COLON_SYMBOL+insertTranscriptResultList[i].getErrors();
                    logHolder.error(CLASS_NAME, errorMessage);
                }
            }
            if (logHolder!=null){
                logHolder.writeToLogExceptionObject();
            }
        } catch(Exception e){
            Database.rollback(commitSavePoint);
            throw e;
        }
    }
}