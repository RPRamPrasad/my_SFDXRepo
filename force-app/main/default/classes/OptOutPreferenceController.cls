/**
 * Author : Golden Spikes Team
 * Date Created : 01/23/2023
 * @description : This Apex Class is used to get and save Opt Out Preference Settings.
 */
public with sharing class OptOutPreferenceController {

    private static final String CLASS_NAME = 'OptOutPreferenceController';
    private static final String UPDATE_OPT_OUT_PREFERENCE_METHOD_NAME = 'updateOptOutPreference';
/**
 * @description getLoggedInUserOptOutPreference
 * @return  `User`
 */
    @AuraEnabled
    public static User getLoggedInUserOptOutPreference() {
        User loggedInUserInfo = null;
        try {
              loggedInUserInfo = [Select Id, UserType__c, OptPreference__c 
                                 FROM User WHERE Id =: UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
        } catch(Exception e) {
		    throw new AuraHandledException(e.getMessage());
        }
        return loggedInUserInfo;
    }

/**
 * @description updateOptOutPreference
 * @param preferenceValue 
 * @return  `Boolean`
 */
    @AuraEnabled
    public static Boolean updateOptOutPreference(String preferenceValue) {
        Boolean isSuccess = false;
        try {
            update Security.stripInaccessible(
                AccessType.UPDATABLE,
                new List<User>{ new User(Id = UserInfo.getUserId(), OptPreference__c = preferenceValue) }
            ).getRecords();
            isSuccess = true;
        } catch (Exception updateException) {
            LoggingService.logHandledException(updateException, CLASS_NAME, UPDATE_OPT_OUT_PREFERENCE_METHOD_NAME, System.LoggingLevel.ERROR);
            throw new AuraHandledException('Failed to Update User Opt-In/Opt-Out Preferences.');
        }
        return isSuccess;
    }
}
