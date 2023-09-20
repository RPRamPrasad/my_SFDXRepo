/**
*  @Author : Golden Spikes Team
*  @Date Created : 03/28/2016
*  @description : This class will prevent deletion of Chatter feed post and feed comment for Agent and ATM
*/
public without sharing class AP_PreventChatterDelete {
    /**
    * @description : This method will prevent deletion of Chatter Feed Post and Feed Comment for Agent and ATM.
    * @param records String errorMsg : The calling method passes a list of sObject records and the error message.
    * @param errorMsg
    */

    @TestVisible
    private static Boolean isBatch = false;

     public static void preventDelete(List<SObject> records, String errorMsg) {
        for(SObject record: records) {
            if(Test.isRunningTest()?isBatch:System.isBatch()){
                if('FeedItem'== record.getSObjectType().getDescribe().getName()){
                    FeedItem feedItem = (FeedItem) record;
                    feedItemCommentCount(feedItem, record, errorMsg);
                  }
            }else{
                record.addError(errorMsg);
            }

        }
    }

    /**
     * @description method for feed item comment count
     * @param feedItem
     * @param record
     * @param errorMsg
     */
    public static void feedItemCommentCount(FeedItem feedItem, SObject record, String errorMsg){
		if(feedItem.CommentCount > 0){
        record.addError(errorMsg);
        }
	}
}