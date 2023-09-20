/**
 * @description OppNotificationChatterSender
 */
public with sharing class OppNotificationChatterSender {
    
    private static final String CLASS_NAME = 'OppNotificationChatterSender';
    private static final String ARCHIVED_CHATTEER = 'CANNOT_POST_TO_ARCHIVED_GROUP';
    private static final String POST_SKYPE_MESSAGE_METHOD_NAME = 'OppNotificationSender.postSkypeMessage'; 
    private static final String POST_ASSIGNED_T0_NAME = 'postFeedAssignedTo';
    private static final String POST_CHATTER_GROUP_NAME = 'postFeedCollabGroup';
    
    /**
     * @description postFeedAssignedTo
     * @param recipient 
     * @param chatterMessageProperties 
     */
    public static void postFeedAssignedTo(Id recipient, Map<String, String> chatterMessageProperties) {
        postFeedItem(recipient, chatterMessageProperties);
    }
    
    @future
    private static void postFeedItem(Id recipient, Map<String, String> chatterMessageProperties) {
        FeedItem post = new FeedItem();
        post.ParentId = recipient;
        post.Title = chatterMessageProperties.get('title');
        post.Body = chatterMessageProperties.get('chatterMessage');
        post.LinkUrl = chatterMessageProperties.get('redirectURL');
        
        try {
            UTIL_FeedItemDAO.insertFeedItems(new List<FeedItem>{post});
        }catch(Exception ex) {
            if (ex.getMessage().contains(ARCHIVED_CHATTEER)) {
                LoggingService.logHandledException(ex, CLASS_NAME, POST_SKYPE_MESSAGE_METHOD_NAME, System.LoggingLevel.WARN);
            } else {
                LoggingService.logHandledException(ex, CLASS_NAME, POST_ASSIGNED_T0_NAME, System.LoggingLevel.ERROR); 
            }         
        }
    }
    
    @future
    private static void postFeedItemConnectApi(Id recipient, Map<String, String> chatterMessageProperties, List<Id> mentionedUserIds) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        
        // create link
        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
        ConnectApi.LinkCapabilityInput linkInput = new ConnectApi.LinkCapabilityInput();
        linkInput.urlName = chatterMessageProperties.get('title');         
        linkInput.url = chatterMessageProperties.get('redirectURL');
        feedElementCapabilitiesInput.link = linkInput;
        feedItemInput.capabilities = feedElementCapabilitiesInput;
        
        // create message body container
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        // add message text
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = chatterMessageProperties.get('chatterMessage');
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        for(Id mentionedUser: mentionedUserIds) {
            ConnectApi.TextSegmentInput spaceCharacter = new ConnectApi.TextSegmentInput();
            spaceCharacter.text = ' ';
            
            ConnectApi.MentionSegmentInput msi = new ConnectApi.MentionSegmentInput(); // adds @mentions
            msi.id = mentionedUser;
            messageBodyInput.messageSegments.add(spaceCharacter);
            messageBodyInput.messageSegments.add(msi);
        }
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = recipient; //CollaborationGroupId
        
        try{
            ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        } catch(System.UnsupportedOperationException e){
            LoggingService.logHandledException(e, CLASS_NAME, POST_CHATTER_GROUP_NAME, System.LoggingLevel.ERROR);
        } catch(ConnectApi.ConnectApiException e){
            LoggingService.logHandledException(e, CLASS_NAME, POST_CHATTER_GROUP_NAME, System.LoggingLevel.ERROR);
        }        
    }
    
    /**
     * @description postFeedCollabGroup
     * @param recipient 
     * @param chatterMessageProperties 
     * @param mentionedUserIds 
     */
    public static void postFeedCollabGroup(Id recipient, Map<String, String> chatterMessageProperties, List<Id> mentionedUserIds) {
        if(mentionedUserIds.isEmpty()){
            postFeedItem(recipient, chatterMessageProperties);
        } else {
            postFeedItemConnectApi(recipient, chatterMessageProperties, mentionedUserIds);
        }
    }
}
