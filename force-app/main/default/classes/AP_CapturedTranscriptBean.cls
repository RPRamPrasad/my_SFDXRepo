/**
 * @description class to captured transcript bean
 */
public with sharing class AP_CapturedTranscriptBean {

	/**
	 * @description getter and setter method to feed item
	 */
	public FeedItem feedItem {get;set;}

	/**
	 * @description getters and setters method to feed comment list
	 */
	public List<FeedComment> feedCommentList {get;set;}


}