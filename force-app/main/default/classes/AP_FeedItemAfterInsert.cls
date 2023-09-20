/**
 *@description class to feed items after insert
 */
public with sharing class AP_FeedItemAfterInsert {
    private static final String CLASS_NAME = 'AP_FeedItemAfterInsert';
    private static final String METHOD_NAME = 'stageFeedItem';
    private static final String CLEANUP_METHOD_NAME = 'createChatterPostCleanup';
    private static final String LINK_POST = 'LinkPost';
    private static final String NOTIFICATION_TITLE = 'New or Unclaimed';

    /**
     * @description method to list stage feed item
     * @param feedItemList
     */
    public static void stageFeedItem (List<FeedItem> feedItemList) {
        List<FeedStage__c> feedStageList = new List<FeedStage__c>();
        try{
            for (FeedItem feedItem : feedItemList) {
                FeedStage__c feedStage = new FeedStage__c(FeedItemID__c = feedItem.Id);
                feedStageList.add(feedStage);
            }
            insert feedStageList;
        }
        catch(Exception e) { LoggingService.logHandledException(e, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);}
    }

    /**
     * @description method to create chatter post cleanup 
     * @param feedItemList
     */
    public static void createChatterPostCleanup(List<FeedItem> feedItemList){
        List<ChatterPostCleanup__c> chatterPostCleanupList = new List<ChatterPostCleanup__c>();
        try{
            for (FeedItem feedi : feedItemList) {
                if(feedi.Type.equals(LINK_POST) && feedi.Title.contains(NOTIFICATION_TITLE)){
                        ChatterPostCleanup__c chatterPost = new ChatterPostCleanup__c(Name = feedi.Id);
                        chatterPostCleanupList.add(chatterPost);
                    }
                }
            insert chatterPostCleanupList;
        }
        catch(Exception e) { LoggingService.logHandledException(e, CLASS_NAME, CLEANUP_METHOD_NAME, LoggingLevel.ERROR);}

    }
}