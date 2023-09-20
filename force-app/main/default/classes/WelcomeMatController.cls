/**
* @name WelcomeMatController
* @author  Poseidon
* @createdDate 09/10/2018
* @description Controller used by the WelcomeMatUtil component to fetch WelcomeMat object
*/
public with sharing class WelcomeMatController {
    private static final String CLASS_NAME = 'WelcomeMatController';
    private static String userProfileName;
    private static Boolean welcomeMatViewed;
    private static String agentUser = '2.00 Agent';
    
/**
 * @description currentUserProfile
 * @return userProfileName
 */
    @AuraEnabled
    public static String currentUserProfile(){
        User currentUser = UTIL_CurrentUser.retrieveCurrentUser();
        userProfileName = currentUser.Profile.Name;
        return userProfileName; 
    }
    /**
     * @description cureentUserProfileWelcomeMatViewed
     * @return welcomeMatViewed
     */
    @AuraEnabled
    public static Boolean currentUserProfileWelcomeMatViewed(){
        User currentUser = UTIL_CurrentUser.retrieveCurrentUser();
        welcomeMatViewed = currentUser.WelcomeMatViewed__c;
        return welcomeMatViewed;
    }
    /**
     * @description fetchWelcomeMatData
     * @return welcomeMatData
     */
    @AuraEnabled    
    public static List<WelcomeMat__c> fetchWelcomeMatData(){

        List<WelcomeMat__c> welcomeMatData = new List<WelcomeMat__c>();

        welcomeMatData = [SELECT Welcome_Mat_Title__c, WelcomeMatDescription__c, WelcomeMat_Section_Number__c, WelcomeMat_Section_Link__c,
                         WelcomeMat_Icon__c, WelcomeMatUser__c, WelcomeMat_TileToOpenInTab__c, WelcomeMat_ReleaseNoteId__c, WelcomeMat_DefaultUser__c FROM WelcomeMat__c
                         WHERE WelcomeMatUser__c =:userProfileName WITH SECURITY_ENFORCED ORDER BY WelcomeMat_Section_Number__c ASC LIMIT 500];    	
        
        if(welcomeMatData.isEmpty()) {
            welcomeMatData = [SELECT Welcome_Mat_Title__c, WelcomeMatDescription__c, WelcomeMat_Section_Number__c, WelcomeMat_Section_Link__c,
                             WelcomeMat_Icon__c, WelcomeMatUser__c, WelcomeMat_TileToOpenInTab__c, WelcomeMat_ReleaseNoteId__c, WelcomeMat_DefaultUser__c FROM WelcomeMat__c
                             WHERE WelcomeMatUser__c =:agentUser WITH SECURITY_ENFORCED ORDER BY WelcomeMat_Section_Number__c ASC LIMIT 500];
        
        }
        return welcomeMatData;
    }
    /**
     * @description updateUserProfileWelcomeMatViewd
     * @param welcomeMatViewed
     */
     @AuraEnabled
     public static void updateUserProfileWelcomeMatViewed(boolean welcomeMatViewed){
        User currentUser = UTIL_CurrentUser.retrieveCurrentUser();
        List<User> userList = new List<User>();
        currentUser.WelcomeMatViewed__c = welcomeMatViewed;
        userList.add(currentUser);
        
        try {
            update Security.stripInaccessible(AccessType.UPDATABLE, userList).getRecords();
        } catch (DmlException dmlException) {
            LoggingService.logHandledException(dmlException, CLASS_NAME, 'Exception occurred while updating data in WelcomeMatController', System.LoggingLevel.ERROR);
        }
        
    } 
 
}