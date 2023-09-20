/**
 * @description class to feed comments after insert
 */
public with sharing class AP_FeedCommentAfterInsert {
	private static final String CLASS_NAME = 'AP_FeedCommentAfterInsert';
	private static final String METHOD_NAME = 'stageFeedComment';
    private static final String CLEANUP_METHOD_NAME = 'deleteChatterPostCleanup';
    /**
     * @description method to stage feed comment
     * @param feedCommentList
     */
    public static void stageFeedComment(List<FeedComment> feedCommentList) {
        List<FeedStage__c> feedStageList = new List<FeedStage__c>();
        try{
        	for (FeedComment feedComment : feedCommentList) {
        	    FeedStage__c feedStage = new FeedStage__c(FeedItemID__c = feedComment.FeedItemId);
        	    feedStageList.add(feedStage);
       		}
        	upsert feedStageList FeedItemID__c;
        }
        catch(Exception e) {LoggingService.logHandledException(e, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);}
    }

    /**
     * @description method to delete chatter post cleanup
     * @param feedCommentList
     */
    public static void deleteChatterPostCleanup(List<FeedComment> feedCommentList){
        List<ChatterPostCleanup__c> chatterPostCleanupList = new List<ChatterPostCleanup__c>();
        Set<String> feedItemIDs = new Set<String>();
        try{

            for (FeedComment feedC : feedCommentList) {
                 feedItemIDs.add(feedC.FeedItemId);
            }
            chatterPostCleanupList = [SELECT Name FROM ChatterPostCleanup__c WHERE Name IN: feedItemIDs];
            for(ChatterPostCleanup__c cpc:chatterPostCleanupList){
                cpc.OwnerId=UserInfo.getUserId();
            }
            Update chatterPostCleanupList;
            delete chatterPostCleanupList;
        }
        catch(Exception e) {LoggingService.logHandledException(e, CLASS_NAME, CLEANUP_METHOD_NAME, LoggingLevel.ERROR);}
    }
}