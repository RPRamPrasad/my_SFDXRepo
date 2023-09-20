/**
* Author : Team LHIPS/GlitterCloud
* Date Created : 10/11/2022
* @description : HA4C_PKCE class is to set Domain Orgin, Set Token to HA4C_PKCE VF Page
*/

public with sharing class HA4C_PKCE {
    private static final String CACHE_TOKEN = 'local.HA4CToken.token';

    /**
     * @description origin getter/ setter for vf page
     */
    public String origin {
        get {
            return 'https://' + DomainCreator.getLightningHostname();
        }
        set;
    }

    /**
     * @description token
     */
    public String token { get; set; }

    /**
     * @description setToken
     */
    public void setToken() {
        Cache.Session.put(CACHE_TOKEN, token);
    }

 /**
* @description method returns VF origin Domain
* @return String
*/
    @AuraEnabled(Cacheable=true)
    public static String getVFOrigin() {
        return 'https://' + DomainCreator.getVisualforceHostname('c');
    }

/**
* @description method returns CacheToken
* @return String
*/
    @AuraEnabled(Cacheable=true)
    public static String getHA4CToken() {
        if (Cache.Session.contains(CACHE_TOKEN)) {
            return String.valueOf(Cache.Session.get(CACHE_TOKEN));
        }
        return null;
    }

/**
 * @description isHatsUser
 * @return  `boolean`
 */
    public static boolean isHatsUser(user loggedInUser) {
        Boolean isHatsUser = false;
        String pilotUserField = loggedInUser.Pilot_User_2__c;
        if ((null != pilotUserField && pilotUserField.equalsIgnoreCase('HATSUser')) || FeatureManagement.checkPermission('HATS_User') ){
            isHatsUser = true;
        }
        return isHatsUser;
    }

/**
 * @description isHa4cUser
 * @return  `boolean`
 */
    public static boolean isHa4cUser(user loggedInUser) {
        Boolean isHa4cUser = false;
        String pilotUserField = loggedInUser.Pilot_User_1__c;
        if ((null != pilotUserField && pilotUserField.equalsIgnoreCase('Ha4cUser')) && ('Agent'.equals(loggedInUser.SubUserType__c) || 'ATM'.equals(loggedInUser.SubUserType__c) || 'Agent Intern'.equals(loggedInUser.SubUserType__c)) || 'PSO Employee'.equals(loggedInUser.SubUserType__c) || 'CCC Sales'.equals(loggedInUser.SubUserType__c) || 'Support'.equals(loggedInUser.UserType__c)){
            isHa4cUser = true;
        }
        return isHa4cUser;
    }

/**
 * @description isHatsorHa4cUser
 * @return  `boolean`
 */
    @AuraEnabled(cacheable=true)
    public static boolean isHatsORha4cUser() {
        User loggedInUser = UTIL_CurrentUser.retrieveCurrentUser();
        Boolean isHatsORha4cUser = false;
        Boolean isHatsUser = isHatsUser(loggedInUser);
        Boolean isHa4cUser = isHa4cUser(loggedInUser);
        try{
            if(isHatsUser || isHa4cUser ){
                isHatsORha4cUser = true;
            }
            return isHatsORha4cUser;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}
