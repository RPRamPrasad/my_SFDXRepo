/**
@Author Team Dream Builders/Impact Force
@Name UTIL_FeedItemDAO
@CreateDate 11/8/2016
@description Common class to access various Task related operations for various Processor.
@Version 2.0
*/
public without sharing class UTIL_FeedItemDAO {

    /**
    * @description Takes the List of FeedItems and inserts them
    * 
    * @param feedItemList - List<FeedItem> list of feedItems for inserting
    */
    public static void insertFeedItems(List<FeedItem> feedItemList) {
        if(feedItemList != null && !feedItemList.isEmpty()) {
            insert feedItemList;
        } 
    }
    
    /**
    * @description Takes the List of FeedItems and update them
    * 
    * @param feedItemList - List<FeedItem> list of feedItems for update
    */
    public static void updateFeedItems(List<FeedItem> feedItemList) {
        if(feedItemList != null && !feedItemList.isEmpty()) {
            update feedItemList;
        } 
    }
    
    /**
    * @description Takes the List of FeedItems and upsert them
    * 
    * @param feedItemList - List<FeedItem> list of feedItems for upsert
    */
    public static void upsertFeedItems(List<FeedItem> feedItemList) {
        if(feedItemList != null && !feedItemList.isEmpty()) {
            upsert feedItemList;
        } 
    }
    
    /**
    * @description Takes the List of FeedItems and delete them
    * 
    * @param feedItemList - List<FeedItem> list of feedItems for delete
    */
    public static void deleteFeedItems(List<FeedItem> feedItemList) {
        if(feedItemList != null && !feedItemList.isEmpty()) {
            delete feedItemList;
        } 
    }
    
}