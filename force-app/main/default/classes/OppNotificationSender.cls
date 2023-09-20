/**
 * @description TEST CLASS: OppNotificationSender_TEST.cls
 * @author Team Opptimizers 
 */
public with sharing class OppNotificationSender {

    private static final String CLASS_NAME = 'OppNotificationSender';
    private static final String POST_CHATTER_MESSAGE_METHOD_NAME = 'postChatterMessage'; 
    private static final String POST_SKYPE_MESSAGE_METHOD_NAME = 'postSkypeMessage'; 
    private static final String READ_TIMED_OUT = 'Read timed out';
    private static final String OPP_NEW_STAGE = 'New';
    private static final String OPP_ORIGINATOR_ATM = 'Agent/Team Member';

    private static OppNotification notification = new OppNotification(); 
    private static Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> preferences = new Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference>();
    private static Boolean sendChatterToAssignedUser = false; 
    private static Boolean sendChatterAndSkypeToAll = false; 

    /**
     * @description sendOppNotifications
     * @param opp 
     * @param agentUser 
     */
    public static void sendOppNotifications(Opportunity opp, User agentUser) {
        
        List<CollaborationGroup> chatterGroup = UTIL_OpportunityNotificationManager.getChatterGroup(agentUser);   

        if(chatterGroup != null && chatterGroup.size() == 1) { 
            List<Id> chatterGroupMemberIds = UTIL_OpportunityNotificationManager.getChatterMemberIds(chatterGroup[0].Id);

            //filters for those who are eligible for a notification and sets booleans for send chatter to assigned only and send skype/chatter to all
            List<Id> eligibleForNotifications = getEligibleUsers(opp, chatterGroupMemberIds);
    
            if(!eligibleForNotifications.isEmpty()) { // avoids calling unneeded code if no one is to be notified
                postNotifications(opp, chatterGroup[0], eligibleForNotifications);
            } 
        } 
    } 

    private static void postNotifications(Opportunity opp, CollaborationGroup chatterGroup, List<Id> eligibleForNotifications) {
        
        Map<String, String> notificationMessageMap = notification.setBaseNotificationProperties(opp); // populates a map with base notification properties
        //get user's notification preferences preferences 
        preferences = OppNotificationPreferenceRetriever.getNotificationPreferences(opp, eligibleForNotifications);

        if(sendChatterToAssignedUser){
            notification.setRecipient(opp.Assigned_To__c);
            postChatterMessage(notification.getRecipient(), notificationMessageMap);
        } 
        
        else if(sendChatterAndSkypeToAll) {
            notification.setRecipient(chatterGroup.Id);
            postChatterMessage(notification.getRecipient(), notificationMessageMap);

            Set<String> emailsToBeNotfied = UTIL_OpportunityNotificationManager.getEmailsToRecieveSkype(eligibleForNotifications, opp, preferences);
            if(!emailsToBeNotfied.isEmpty()) { // avoids uneeded db calls
                //the skype message is the chatter message plus, skype message
                String skypeMessage = notificationMessageMap.get('chatterMessage') + notification.createSkypeMessage(opp, notificationMessageMap.get('redirectURL'));
                postSkypeMessage(emailsToBeNotfied, skypeMessage);
            }  
        }
    } 

    // the users who are eligible for receiving a notification
    private static List<Id> getEligibleUsers(Opportunity opp, List<Id> chatterGroupMemberIds) {   
        
        List<Id> retVal = new List<Id>();
        Boolean isNewStage = oppIsNewStage(opp);
        Boolean hasAssignedUser = oppHasAssignedUser(opp);

        if(OPP_ORIGINATOR_ATM.equals(opp.Opportunity_Originator__c)){ 
            if(!isNewStage && hasAssignedUser) {
                // chatter notification to opportunity assigned to user
                retVal.add(opp.Assigned_To__c);
                sendChatterToAssignedUser = true;
            }
        }
        else { 
            if(isNewStage) {
                // chatter and skype notifications to all chatter group members
                retVal = chatterGroupMemberIds;
                sendChatterAndSkypeToAll = true;
            } 
            else if(hasAssignedUser) {
                // chatter notification to opportunity assigned to user
                retVal.add(opp.Assigned_To__c);
                sendChatterToAssignedUser = true;
            } 
            else {
                // chatter and skype notifications to all chatter group members
                retVal = chatterGroupMemberIds;
                sendChatterAndSkypeToAll = true;
            }
        }
        return retVal;
    }

    private static Boolean oppIsNewStage(Opportunity opp) {
        return opp.StageName.equals(OPP_NEW_STAGE);
    }

    private static Boolean oppHasAssignedUser(Opportunity opp) {
        return String.isNotBlank(opp.Assigned_To__c);
    }

    //@future
    private static void postChatterMessage(Id recipient, Map<String, String> chatterMessageProperties) { 
        if(sendChatterToAssignedUser) {
            OppNotificationChatterSender.postFeedAssignedTo(recipient, chatterMessageProperties);
        }
        else {
            List<Id> usersToBeMentioned = UTIL_OpportunityNotificationManager.getUsersToBeMentioned(preferences);
            OppNotificationChatterSender.postFeedCollabGroup(recipient, chatterMessageProperties, usersToBeMentioned);
        }
    }
    
    @future(callout=true)
    private static void postSkypeMessage(Set<String> emailsToBeNotfied, String skypeMessage) {
        
        List<String> emails = new List<String>();
        emails.addAll(emailsToBeNotfied); 

        try { 
            emails = UTIL_Randomization.randomizeStringList(emails); // randomize emails so that order of reception is always varied
            UTIL_PostSkypeMessage.postSyncMessageToSkype(skypeMessage, emails);
        } catch(Exception ex) {
            if (ex.getmessage().contains(READ_TIMED_OUT)) {
                LoggingService.logHandledException(ex, CLASS_NAME , POST_SKYPE_MESSAGE_METHOD_NAME, System.LoggingLevel.WARN);                
            } else {
                LoggingService.logHandledException(ex, CLASS_NAME , POST_SKYPE_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            }
        }
    }
}