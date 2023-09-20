/**
 * @description common methods used in Activity Outline and Just One Thing components
 */
public with sharing class ActivityController {

    @TestVisible private static Boolean isCatch = false;

    /**
     * @description Retrieves the Accounts associated to the household
     * @param householdId Household record id
     * @return List of Accounts associated to the household
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getHouseholdMembers(Id householdId) {
        List<Account> householdMembers = new List<Account>();
        householdMembers = Security.stripInaccessible(AccessType.READABLE,[
                        SELECT Id, Name, PersonContactId
                        FROM Account
                        WHERE Primary_Household__pc = :householdId
        ]).getRecords();
        return householdMembers;
    }

    /**
     * @description Retrieves the current logged in user's pilot user field
     * @return A string containing the pilot user field, returns null by default
     */
    @AuraEnabled(cacheable=true)
    public static String getPilotField() {
        String userPilotField = null;

        try {
            User user = [SELECT Pilot_User_6__c FROM User WHERE Id =: UserInfo.getUserId() WITH SECURITY_ENFORCED];
            userPilotField = user.Pilot_User_6__c;
        } catch(Exception e) {
            throw new AuraHandledException('Retrieving user pilot field failed');
        }

        return userPilotField;
    }

    /**
     * @description returns recently accessed account id
     * @param householdId household id
     * @return accountId
     */
    @AuraEnabled
    public static String getRecentlyAccessedAccountId(Id householdId) {
        // When an account is accessed that is part of a household, the account gets cached by household id.
        String sessionPartString = '';
        try {
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.household');
            sessionPartString = (String)sessionPart.get(householdId);
        } catch (Exception e) {
            throw new AuraHandledException('Retrieving from local cache failed');
        }
        return sessionPartString;

    }

    /**
     * @description returns activity outline filter preferences based on userId
     * @return preferences
     */
    @AuraEnabled(cacheable=false)
    public static String getActivityOutlineFilterPreference() {
        String userPrefs = '';
        try {
            User loggedInUserInfo = [Select Id, Activity_Outline_Filter_Preferences__c
                                 FROM User WHERE Id =: UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];

            userPrefs = loggedInUserInfo.Activity_Outline_Filter_Preferences__c;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to retrieve user preferences');
        }
        return userPrefs;
    }

    /**
     * @description returns household navigator filter preferences based on userId
     * @return preferences
     */
    @AuraEnabled(cacheable=false)
    public static List<PreferenceItem> getHouseholdNavigatorFilterPreference() {
        List<PreferenceItem> userPrefs = new List<PreferenceItem>();
        try {
            User loggedInUserInfo = [Select Id, Activity_Outline_Filter_Preferences__c
                                     FROM User WHERE Id =: UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
            String preferences = loggedInUserInfo.Activity_Outline_Filter_Preferences__c;

            if(preferences != null && preferences.length() > 0) {
            JSONParser parser = JSON.createParser(preferences);
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    PreferenceItem pref = (PreferenceItem)parser.readValueAs(PreferenceItem.class);
                    userPrefs.add(pref);
                    parser.skipChildren();
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Failed to retrieve user preferences');
        }
        return userPrefs;
    }

    /**
     * @description updates activity outline filter preferences value
     * @param preferenceValue
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean updatePreferencesFromActivityOutlineFilters(String preferenceValue) {
        try{
            return updatePreferences(preferenceValue);
        } catch (Exception e) {
            throw new AuraHandledException('Failed to update user preferences, updatePreferencesFromActivityOutlineFilters');
        }
        
    }

    /**
     * @description updates activity outline filter preferences value
     * @param preferenceValue
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean updatePreferencesFromActivityOutlineSettings(String preferenceValue) {
        try{
            return updatePreferences(preferenceValue);
        } catch (Exception e) {
            throw new AuraHandledException('Failed to update user preferences, updatePreferencesFromActivityOutlineSettings');
        }
        
    }

    /**
     * @description updates a users activity outline preferences value
     * @param preferenceValue String of the preferences to be saved
     * @return Boolean indicating if the operation was successful
     */
    @AuraEnabled
    public static Boolean updatePreferencesFromVersioning(String preferenceValue) {
        try {
            return updatePreferences(preferenceValue);
        } catch (Exception e){
            throw new AuraHandledException('Failed to update user preferences, updatePreferencesFromVersioning');
        }
        
    }

    private static Boolean updatePreferences(String preferenceValue) {
        Boolean isSuccess = false;

        User currentUser = new User(Id = UserInfo.getUserId(), Activity_Outline_Filter_Preferences__c = preferenceValue);

        List<User> currentUserList = new List<User>{currentUser};
        update Security.stripInaccessible(
            AccessType.UPDATABLE,
            currentUserList
        ).getRecords();
        isSuccess = true;

        if(isCatch){
            throw new DMLException();
        }
        
        return isSuccess;
    }

    /**
     * @description properties that define a preference item
     */
    public with sharing class PreferenceItem {
        @AuraEnabled
        public String objectName;

        @AuraEnabled
        public List<String> activityTypes;

        @AuraEnabled
        public String activityOutlineView;

        @AuraEnabled
        public String version;

        @AuraEnabled
        public List<String> activitySettings;

        @AuraEnabled
        public String openActivitiesSort;

        @AuraEnabled
        public String closedActivitiesSort;

        @AuraEnabled
        public String searchPreference;

        @AuraEnabled
        public Boolean todoDefault;

        /**
         * @description constructor that initializes that default values for preference items
         */
        public PreferenceItem() {
            this.activityTypes = new List<String>();
            this.activitySettings = new List<String>();
            this.activityOutlineView = 'aoExpandGrouped';
            this.objectName = '';
            this.version = '3.3';
            this.openActivitiesSort = 'Descending';
            this.closedActivitiesSort = 'Descending';
            this.searchPreference = 'Button';
            this.todoDefault = false;
        }
    }
}