/**
 * Author : Golden Spikes Team
 * Date Created : 02/10/2021
 * @description : This Apex Class is used to get and save New Hot Prospect Chatter Frequencies.
 */
public with sharing class OptyHotProspectPreferenceController {
    private static final String HOT_PROSPECT_GROUPNAME_PREFIX = 'NewHotProspectNotifications-';
    private static final String AGENT_SUB_USER_TYPE = 'Agent';
    private static final String CLASS_NAME = 'OptyHotProspectPreferenceController';
    private static final String GET_LOGGED_IN_USER_NOTIFICATION_PREFERENCE_METHOD_NAME = 'getLoggedInUserNotificationPreferences';
    private static final String UPDATE_NOTIFICATION_PREFERENCES_METHOD_NAME = 'updateLoggedInUserNotificationPreferences';
    private static final String CHATTER_GROUP_URL = '/lightning/r/CollaborationGroup/[Id]/view';
    private static final String SFCOM_TURNED_OFF_ALERT = 'All Statefarm.com notifications have been turned off for all members of your office.';
    private static final String ILP_TURNED_OFF_ALERT = '\n All Internet Lead Provider notifications have been turned off for all members of your office.';


    private with sharing class NotificationPreferenceResponse {
        private String groupName;
        private String groupURL;
        private NotificationPreference__c loggedInUserNotificationPreferences = null;
        private Boolean isError = false;
        private Boolean allChatterNotificationsDisabled = false;
        private Boolean allChatterMentionsDisabled = false;
    }

    /**
     * @description This Method Used for getting Logged In User Notification Preferences
     * @name getLoggedInUserNotificationPreferences
     * @return Notification Preferences
    */
    @AuraEnabled
    public static String getLoggedInUserNotificationPreferences() {
        NotificationPreferenceResponse npr = new NotificationPreferenceResponse();
        try {
            User agentData = getAliasAndEmailPreference();
            if (String.isNotBlank(agentData.Alias)) {
                String groupName = HOT_PROSPECT_GROUPNAME_PREFIX + agentData.Alias;
                npr = getNotificationPreferences(groupName);

                if (agentData.UserPreferencesDisableAllFeedsEmail) {
                    npr.allChatterNotificationsDisabled = true;
                }
                if (agentData.UserPreferencesDisableMentionsPostEmail) {
                    npr.allChatterMentionsDisabled = true;
                }
            }
        } catch (Exception fetchException) {
            npr.isError = true;
            LoggingService.logHandledException(fetchException, CLASS_NAME, GET_LOGGED_IN_USER_NOTIFICATION_PREFERENCE_METHOD_NAME, System.LoggingLevel.ERROR);
            throw new AuraHandledException('Failed to Get User Notification Preferences.');
        }
        return JSON.serialize(npr);
    }

    /**
     * @description This Method Used for updating Logged In User Notification Preferences
     * @name updateLoggedInUserNotificationPreferences 
     * @param notificationPreferenceRecord
     * @param groupName 
     * @return updateMessage
    */
    @AuraEnabled 
    public static String updateLoggedInUserNotificationPreferences(NotificationPreference__c notificationPreferenceRecord, String groupName){
        String updateMessage = '';
        try{
            update Security.stripInaccessible(AccessType.UPDATABLE, new List<NotificationPreference__c>{notificationPreferenceRecord}).getRecords();
            if(groupName.startsWith(HOT_PROSPECT_GROUPNAME_PREFIX)){
                updateMessage += getWarningMessages(groupName);
            }
        } catch (Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME , UPDATE_NOTIFICATION_PREFERENCES_METHOD_NAME, System.LoggingLevel.ERROR);
            throw new AuraHandledException('Failed to Update User Notification Preferences.');
        }
        return updateMessage;
    }

    /**
     * @description Queries the logged in User's Alias and UserPreferencesDisableAllFeedsEmail fields
     * If not an agent, query Alias based on logged in User's Servicing_Agent_External_ID__c field
     * @return A User object containing the Alias and UserPreferencesDisableAllFeedsEmail field values
     */
    private static User getAliasAndEmailPreference() {
        User userRecordDB = new User();
        User retVal = new User();

        userRecordDB = [SELECT Id, SubUserType__c, Alias, Servicing_Agent_External_ID__c, 
        UserPreferencesDisableAllFeedsEmail, UserPreferencesDisableMentionsPostEmail FROM User
         WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];

        retVal.UserPreferencesDisableAllFeedsEmail = userRecordDB.UserPreferencesDisableAllFeedsEmail;
        retVal.UserPreferencesDisableMentionsPostEmail = userRecordDB.UserPreferencesDisableMentionsPostEmail;
        retVal.Alias = userRecordDB.Alias;
        
        //if not sub user type 'Agent', query for Alias based on logged in User's Servicing_Agent_External_ID__c
        if (!AGENT_SUB_USER_TYPE.equals(userRecordDB.SubUserType__c)) {
            retVal.Alias = [SELECT Alias FROM User 
            WHERE UserExternalID__c = :userRecordDB.Servicing_Agent_External_ID__c WITH SECURITY_ENFORCED LIMIT 1]?.Alias;
        }
        return retVal;
    }

    private static NotificationPreferenceResponse getNotificationPreferences(String groupName){
        NotificationPreferenceResponse npr = new NotificationPreferenceResponse();
        npr.groupName = groupName;
        CollaborationGroupMember cgm = getCollaborationGroupMemberRecord(groupName);
        if (cgm != null) {
            NotificationPreference__c retrievedPrefRecord = getNotificationPreferenceRecord();
            if (retrievedPrefRecord == null){
                npr.loggedInUserNotificationPreferences = createNotificationPreferenceRecord(cgm);
                cgm.NotificationFrequency = 'N';
                update Security.stripInaccessible(AccessType.UPDATABLE, new List<CollaborationGroupMember>{cgm}).getRecords();
            } else {  
                npr.loggedInUserNotificationPreferences = retrievedPrefRecord;                   
            }
        } else {
            List<CollaborationGroup> cg = [SELECT Id FROM CollaborationGroup WHERE Name = :groupName WITH SECURITY_ENFORCED LIMIT 1];
            if(cg.size() > 0){
                npr.groupURL = CHATTER_GROUP_URL.replace('[Id]', cg[0].Id);        
            }
        }
        return npr;
    }

    private static NotificationPreference__c createNotificationPreferenceRecord(CollaborationGroupMember cgm){
        NotificationPreference__c np = new NotificationPreference__c();
        np.notificationGroupMemberId__c = UserInfo.getUserId();
        if(cgm.NotificationFrequency != 'N') {
            np.enableSFComEmail__c = true;
            np.enableILPEmail__c = true;
            np.enableTempHotWarm__c = true;
            np.enableTempUrgent__c = true;
            np.defaultEmailSelection__c = true;
        } else {
            np.enableSFComEmail__c = false;
            np.enableILPEmail__c = false;
        }
        insert Security.stripInaccessible(AccessType.CREATABLE, new List<NotificationPreference__c>{np}).getRecords();
        return getNotificationPreferenceRecord();
    }

    private static NotificationPreference__c getNotificationPreferenceRecord(){
        NotificationPreference__c notificationPreferences;
        List<NotificationPreference__c> retrievedNp = [SELECT enableSFComSkype__c, enableSFComEmail__c, enableILPSkype__c, enableILPEmail__c, enableTempUrgent__c, enableTempHotWarm__c, enableTempColdNoTemp__c, enableOnlineBrowsing__c FROM NotificationPreference__c WHERE notificationGroupMemberId__c = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
        if (retrievedNp.size() > 0){
            notificationPreferences = retrievedNp.get(0);
        }
        return notificationPreferences;
    }

    private static CollaborationGroupMember getCollaborationGroupMemberRecord(String groupName){
        CollaborationGroupMember cgm;
        List<CollaborationGroupMember> retrievedCgm = [SELECT Id, NotificationFrequency, CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId = :UserInfo.getUserId() AND collaborationGroup.Name = :groupName WITH SECURITY_ENFORCED LIMIT 1];
        if(retrievedCgm.size() > 0) {
            cgm = retrievedCgm.get(0);
        }
        return cgm;
    }

    private static String getWarningMessages(String groupName){
        String warningMessage = '';
        Boolean stateFarmDotComTurnedOff = false;
        Boolean iLPTurnedOff = false;
        List<Id> collabGroupUserIds = new List<Id>();
        List<String> collabGroupUserNames = new List<String>();
        List<CollaborationGroupMember> collabGroupMembers = [SELECT MemberId, Member.LastName, CollaborationGroupId FROM CollaborationGroupMember WHERE collaborationGroup.Name = :groupName WITH SECURITY_ENFORCED];
        for(CollaborationGroupMember member: collabGroupMembers){
            collabGroupUserIds.add(member.MemberId);
            collabGroupUserNames.add(member.Member.LastName);
        }
        List<NotificationPreference__c> notificationPreferences = [SELECT enableSFComSkype__c, enableSFComEmail__c, enableILPSkype__c, enableILPEmail__c, enableTempUrgent__c, enableTempHotWarm__c, enableTempColdNoTemp__c, enableOnlineBrowsing__c FROM NotificationPreference__c WHERE notificationGroupMemberId__c IN :collabGroupUserIds WITH SECURITY_ENFORCED];
        //if every collab group member has a notification preference record, then verify whether all notifications turned off
        if(collabGroupUserIds.size() == notificationPreferences.size()){
            stateFarmDotComTurnedOff = isStateFarmDotComTurnedOff(notificationPreferences);
            iLPTurnedOff = isILPTurnedOff(notificationPreferences);
        }
        if(stateFarmDotComTurnedOff){
            warningMessage += SFCOM_TURNED_OFF_ALERT;
        }
        if(iLPTurnedOff){
            warningMessage += ILP_TURNED_OFF_ALERT;
        }
        if(warningMessage.length() > 1){
            FeedItem post = new FeedItem();
            post.ParentId = collabGroupMembers[0].CollaborationGroupId;
            post.Body = warningMessage;
            post.Title = 'New Hot Prospect Notifications Alert';
            insert Security.stripInaccessible(AccessType.CREATABLE, new List<FeedItem>{post}).getRecords();
        }
        return warningMessage;
    }

    private static Boolean isStateFarmDotComTurnedOff(List<NotificationPreference__c> preferences){
        Boolean allNotificationsTurnedOff = false;
        Integer numOfUsersWithNotificationsOff = 0;
        Integer numOfPreferences = preferences.size();
        for(NotificationPreference__c pref: preferences){
            if(pref.enableSFComSkype__c == false && pref.enableSFComEmail__c  == false){
                numOfUsersWithNotificationsOff++;
            }
        }
        if (numOfUsersWithNotificationsOff == numOfPreferences){
            allNotificationsTurnedOff = true;
        }
        return allNotificationsTurnedOff;
    }

    private static Boolean isILPTurnedOff(List<NotificationPreference__c> preferences){
        Boolean allNotificationsTurnedOff = false;
        Integer numOfUsersWithNotificationsOff = 0;
        Integer numOfPreferences = preferences.size();
        for(NotificationPreference__c pref: preferences){
            if(pref.enableILPSkype__c == false && pref.enableILPEmail__c  == false){
                numOfUsersWithNotificationsOff++;
            }
        }
        if (numOfUsersWithNotificationsOff == numOfPreferences){
            allNotificationsTurnedOff = true;
        }
        return allNotificationsTurnedOff;
    }
}