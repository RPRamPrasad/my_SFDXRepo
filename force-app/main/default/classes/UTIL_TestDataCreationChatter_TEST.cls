/**
  *    Author          : Golden Spikes Team
  *    Date Created    : 03/29/2016
  *    Description     : Utility class used by Test Methods.
  */

/**
  *    Author          : Loco Motivated
  *    Date Created    : 04/01/2017
  *    @description     : Utility class used by Test Methods.
  */
@isTest (seeAllData=false)
public class UTIL_TestDataCreationChatter_TEST {

   /**
    *   @description <This method is used to define a API Test user with Sys Admin Profile>
    *   @name createAPITestUser
    *   @return <User>
    */
    public static User createAPITestUser(){
        User apiUser= new User(alias = 'APIP', email= 'apiu@statefarm.com',
        emailencodingkey='UTF-8',lastname='apiUser', languagelocalekey='en_US',
        localesidkey='en_US', timezonesidkey='Europe/London', username='apiu@statefarm.com');
        apiUser.ProfileId = [select Id from Profile where name = 'System Administrator' LIMIT 1].Id;
        return apiUser;
    }

   /**
    *   @description <This method is used to define a NON API Test user with Agent Profile>
    *   @name createNonAPITestUser
    *   @param profileName
    *   @return <User>
    */
    public static User createNonAPITestUser(String profileName){
        User nonAPIUser = new User(alias = 'NAPI', email='napi@statefarm.com', emailencodingkey='UTF-8', lastname='nonApiUser',
        languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username= 'napi@statefarm.com');
        nonAPIUser.ProfileId = [select Id from Profile where name =: profileName LIMIT 1].Id;
        nonAPIUser.put('UserPermissionsMarketingUser', true);
        return nonAPIUser;
    }

   /**
    *   @description <This method is used to insert TEST FeedItem record>
    *   @name createFeedItem
    *   @param feedItemBody
    *   @return List of FeedItem
    */
    public static List<FeedItem> createFeedItem(String feedItemBody) {

        List<FeedItem> feedItems = new List<FeedItem>();
        feedItems.add(new FeedItem(ParentId = UserInfo.getUserId(), Body = feedItemBody, IsRichText=true));
        insert feedItems;
        return feedItems;
    }

   /**
    *   @description <This method is used to insert TEST FeedComment record>
    *   @name createFeedComment
    *   @param feedCommentBody
    *   @return List of FeedComment
    */
    public static List<FeedComment> createFeedComment(String feedCommentBody) {

        List<FeedItem> feedItems = createFeedItem('Testing Feed Item');
        List<FeedComment> feedComments = new List<FeedComment>();
        feedComments.add(new FeedComment(FeedItemId = feedItems[0].Id, CommentBody = feedCommentBody));
        insert feedComments;
        return feedComments;
    }

    /**
    *   @description <This method is used to insert Test Chatter Group>
    *   @name createChatterGroup
    *   @return CollaborationGroup
    */
    public static CollaborationGroup createChatterGroup() {

        CollaborationGroup testGroup = new CollaborationGroup(name = '@Tst@Chat@Grp@'+System.Now() , CollaborationType = 'Public');
        insert testGroup;
        return testGroup;
    }

    /**
    *   @description <This method is used to insert Test Chatter Group with Group Post>
    *   @name createChatterGroupFeed
    *   @return FeedItem
    */
    public static FeedItem createChatterGroupFeed() {

        CollaborationGroup testChatterGroup = createChatterGroup();
        FeedItem testgroupfeed = new FeedItem(body = 'Testing Chatter Group Feed ', ParentId = testChatterGroup.Id);
        insert testgroupfeed;
        return testgroupfeed;
    }


}