/**
* @description This class is used to retrieve and save layout preference for the policy summary page.
* @Date: 10/26/2022
* @author: Team NSYNC - Alex Kahn WGH1 
*/
public with sharing class PolicySummaryPreferenceController {
    
    private static final String POLICY_SUMMARY_VIEW = 'PolicySummaryView';
    
    /**
    * @description fetchUserPreference - get user preference for policy summary view, 'policy-card' or 'policy-list'
    * @return  `String`
    */
    @AuraEnabled
    public static String fetchUserPreference() {
        String cachedView = retrieveCachedView();
        
        try{
            if (String.isNotBlank(cachedView)) {
                return cachedView;
            } else {
                List<Preference__c> dbViews = retrieveDbView();
                
                if (dbViews.isEmpty()) {
                    return 'policy-card';
                } else {
                    updateCachedView(dbViews.get(0).PreferenceValue__c);
                    return dbViews.get(0).PreferenceValue__c;
                }
            }
        } catch (Exception excep) {
            throw new AuraHandledException(excep.getMessage());
        } 
    }
    static String retrieveCachedView() {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.UserInfoPartition');
        
        if (sessionPart.contains(POLICY_SUMMARY_VIEW)) {
            return (String)sessionPart.get(POLICY_SUMMARY_VIEW);
        } else {
            return null;
        }
    }
    static List<Preference__c> retrieveDbView() {
        return Security.stripInaccessible(AccessType.READABLE, [
            SELECT PreferenceValue__c 
            FROM Preference__c 
            WHERE PreferenceName__c = :POLICY_SUMMARY_VIEW 
            AND PreferenceUser__c = :UserInfo.getUserId()
        ]).getRecords();
    }
    
    /**
    * @description updateUserView - update the layout preference
    * @param userView 
    */
    @AuraEnabled
    public static void updateUserView(String userView) {
        try {
            updateDbView(userView);
        } catch (Exception excep) {
            throw new AuraHandledException(excep.getMessage());
        }
        updateCachedView(userView);
    }
    static void updateCachedView(String userView) {
        Cache.Session.put('local.UserInfoPartition.PolicySummaryView', userView);
    }
    static void updateDbView(String userView) {
        List<Preference__c> userPrefs = retrieveDbView();
        
        if (userPrefs.isEmpty()) {
            Preference__c newPref = new Preference__c(
                PreferenceName__c = POLICY_SUMMARY_VIEW,
                PreferenceUser__c = UserInfo.getUserId(),
                PreferenceValue__c = userView,
                PreferenceLevel__c = 'User',
                PreferenceObject__c = 'InsurancePolicy'
            );
            
            userPrefs.add(newPref);
            try {
                insert Security.stripInaccessible(AccessType.CREATABLE, userPrefs).getRecords();
            } catch (Exception excep) {
                throw new AuraHandledException(excep.getMessage());
            }
        } else {
            userPrefs.get(0).PreferenceValue__c = userView;
            
            try {
                update Security.stripInaccessible(AccessType.UPDATABLE, userPrefs).getRecords();
            } catch (Exception excep) {
                throw new AuraHandledException(excep.getMessage());
            }
        }
    }
}