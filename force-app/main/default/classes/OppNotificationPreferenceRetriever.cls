/**
 * @description This class determines if user(s) within a collaboration should receive skype and/or email notifications on an opportunity. 
 * TEST CLASS: OppNotificationPreferenceRetriever_TEST.cls
 * @author Team Opptimizers 
 */
public with sharing class OppNotificationPreferenceRetriever {

    private static final String CLASS_NAME = 'OppNotificationPreferenceRetriever';
    private static final String PREFERENCE_REQUEST_METHOD_NAME = 'getNotificationPreferencesFromDB';
    
    /**
     * @description The inner class to store preference booleans on skype and email notifications
     */
    public with sharing class EmailSkypePreference {
        private Boolean receivesEmail;
        private Boolean receivesSkype;

        /**
         * @description EmailSkypePreference
         * @param receivesEmail 
         * @param receivesSkype 
         */
        public EmailSkypePreference(Boolean receivesEmail, Boolean receivesSkype) {
            this.receivesEmail = receivesEmail;
            this.receivesSkype = receivesSkype;
        }

        /**
         * @description shouldSendEmailNotification
         * @return  `Boolean`
         */
        public Boolean shouldSendEmailNotification() {
            return this.receivesEmail;
        }

        /**
         * @description shouldSendSkypeNotification
         * @return  `Boolean`
         */
        public Boolean shouldSendSkypeNotification() {
            return this.receivesSkype;
        }
    }

    /**
     * @description getNotificationPreferences
     * @param opp 
     * @param collabGroupMemberIds 
     * @return  `Map<Id, EmailSkypePreference>`
     */
    public static Map<Id, EmailSkypePreference> getNotificationPreferences(Opportunity opp, List<Id> collabGroupMemberIds) {

        Map<Id, EmailSkypePreference> retVal = new Map<Id, EmailSkypePreference>();

        //default all group members to email false, Skype true, potentially overriden in below for loop.
        for(Id groupMemberId: collabGroupMemberIds) { //key Id groupMemberId is the same key as in below for loop, of np.notificationGroupMemberId__c, so that is how potential overriding happens. 
            retVal.put(groupMemberId, new EmailSkypePreference(false, true));
        }

        List<NotificationPreference__c> preferencesFromDB = getNotificationPreferencesFromDB(collabGroupMemberIds);
        
        for(NotificationPreference__c np: preferencesFromDB) {

            if(('Statefarm.com').equals(opp.Opportunity_Originator__c)) {
                Map<String, Boolean> sfComPrefs = setSFComPreferences(opp, np);
                retVal.put(np.notificationGroupMemberId__c, 
                    new EmailSkypePreference(
                    sfComPrefs.get('email'), 
                    sfComPrefs.get('skype')
                ));
             }
            else if(('Internet Lead Provider').equals(opp.Opportunity_Originator__c)) {
                retVal.put(np.notificationGroupMemberId__c,
                    new EmailSkypePreference(
                    np.enableILPEmail__c, 
                    np.enableILPSkype__c
                ));
            }
            else {
                retVal.put(np.notificationGroupMemberId__c,
                    new EmailSkypePreference(
                    np.defaultEmailSelection__c, 
                    true 
                ));
            } 
        }
        return retVal;
    }

    private static List<NotificationPreference__c> getNotificationPreferencesFromDB(List<Id> collabGroupMemberIds) {

        List<NotificationPreference__c> retVal = new List<NotificationPreference__c>();
        try {
            retVal = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT enableILPEmail__c, enableILPSkype__c, 
                enableSFComEmail__c, enableSFComSkype__c, enableOnlineBrowsing__c,
                enableTempColdNoTemp__c, enableTempHotWarm__c, enableTempUrgent__c, defaultEmailSelection__c, notificationGroupMemberId__c 
                FROM NotificationPreference__c WHERE notificationGroupMemberId__c IN: collabGroupMemberIds])
                .getRecords();
        } catch(QueryException e) {
            LoggingService.logHandledException(e, CLASS_NAME, PREFERENCE_REQUEST_METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return retVal;
    }

    private static Map<String, Boolean> setSFComPreferences(Opportunity opp, NotificationPreference__c preference) {

        Map<String, Boolean> retVal = new Map<String, Boolean>();
        retVal.put('email', false);
        retVal.put('skype', false);

        if(canSendSFComNotification(opp, preference)) {
            if(preference.enableSFComEmail__c == true) {
                retVal.put('email', true);
            }
            if(preference.enableSFComSkype__c == true) {
                retVal.put('skype', true);
            }
        }
        return retVal;
    }

    private static Boolean canSendSFComNotification(Opportunity opp, NotificationPreference__c preference) {
       
        Boolean retVal = false;

        if(('Online Browsing').equals(opp.Marketing_Sub_Source__c) && preference.enableOnlineBrowsing__c == true) {
            retVal = true;
        }
        else { 
            switch on opp.Temperature__c {
                when 'Urgent' {
                    if(preference.enableTempUrgent__c == true) {
                        retVal = true;
                    }
                }	
                when 'Hot', 'Warm' {		
                    if(preference.enableTempHotWarm__c == true) {
                        retVal = true;
                    }
                }
                when 'Cold', '' {
                    if(preference.enableTempColdNoTemp__c == true) {
                        retVal = true;
                    }
                }
                when else {		 
                    retVal = true;
                }
            }
        }
        return retVal;
    }
}