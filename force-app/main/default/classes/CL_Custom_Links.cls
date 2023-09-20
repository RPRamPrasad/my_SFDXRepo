/**
* @author : Team Kraken
* @date Created : 11/8/2018
* @description : Class that builds specific Custom Links for URLGateway in Lightning
* Version : 1.0
*/

public with sharing class CL_Custom_Links {
    
    @TestVisible public static String loggedInProfile = UTIL_LtngProfileDataAccess.getProfileName();
    public static User currentUser = UTIL_CurrentUser.retrieveCurrentUser();
    @TestVisible public static List<User> mockedUserList;  
    private static final String S1_THEME = 'Theme4t';
    @TestVisible static Boolean isSalesforce1Theme = UserInfo.getUiThemeDisplayed().equals(S1_THEME);
    private static String interactionId='';
    private static final String ECE_600_CUSTOM_PERMISSION = 'Customer_Profile_Print';
    private static final String CPP_AGENT_ATM_CUSTOM_PERMISSION = 'CPP_Agent_ATM_Permission';
    private static final String AUTHENTICATE_IPS = 'CIMAuthenticate';
    
    /**
    * @description buildOCATLink : Build URL for gateway data for Customer Information Management (CIM) Authentication Link.
    * @param recordId 
    * @return  `String`
    * @exception 
    */
    @AuraEnabled
    public static String buildOCATLink(String recordId) {
 
        if(isSalesforce1Theme) {
            throw new AuraHandledException('MOBILE');
        } else if (Label.CL_CCCUnlicensedProfile.equals(loggedInProfile) || Label.CL_CCCLicensedProfile.equals(loggedInProfile) || Label.CL_Enterprise_Profile .equals(loggedInProfile)) {       
            return '/c/ExternalLinkApp.app?linkId=222&accountId=' + recordId + '&userid=' + currentUser.Alias;
        } else {
            throw new AuraHandledException('NOT ALLOWED');
        }
    }
    
    /**
    * @description buildCIMAuthLink : Build URL for gateway data for Customer Information Management (CIM) Authentication Link.
    * @param recordId 
    * @return  `String`
    * @exception 
    */
    @AuraEnabled
    public static String buildCIMAuthLink(String recordId) {
 
        if(isSalesforce1Theme) {
            throw new AuraHandledException('MOBILE');
        } else if (Label.CL_CCCLicensedProfile.equals(loggedInProfile) || Label.CL_CCCUnlicensedProfile.equals(loggedInProfile) || FeatureManagement.checkPermission(AUTHENTICATE_IPS)) {
            return '/c/ExternalLinkApp.app?linkId=216&accountId=' + recordId + '&userid=' + currentUser.Alias;
        } else {
            throw new AuraHandledException('NOT ALLOWED');
        }
    }
    
    /** 
    * @description buildCallTrackerLink : Build URL for gateway data for CCC - Call Tracker Link
    * @param recordId 
    * @return  `String`
    * @exception 
    */
    @AuraEnabled
    public static String buildCallTrackerLink(String recordId) {

        if(isSalesforce1Theme) {
            throw new AuraHandledException('MOBILE');
        }else if (Label.CL_CCCLicensedProfile.equals(loggedInProfile) || Label.CL_CCCUnlicensedProfile.equals(loggedInProfile)) { 
            return '/c/ExternalLinkApp.app?linkId=227&accountId=' + recordId;
        } else { 
            throw new AuraHandledException('NOT ALLOWED');
        }

    }

    /**
    * @description buildCIALinkPilot : build URL for gateway data for Customer Initiated Assignment (CIA) Link.  Changes link ID based on logged in user profile
    * @param recordId 
    * @return  `String`
    * @exception 
    */
    @AuraEnabled
    public static String buildCIALinkPilot(String recordId) {
        if(isSalesforce1Theme) {
            throw new AuraHandledException('MOBILE');
        } else {
            return '/c/ExternalLinkApp.app?linkId=75&accountId=' + recordId;
        }
    }

    /** 
    * @description build URL for gateway data for Customer Profile Print.  Changes link ID based on logged in user profile
    * @param recordId
    * @return String
    */
    @AuraEnabled
    public static String buildProfilePrintLink(String recordId) {
        if(isSalesforce1Theme) {
            throw new AuraHandledException('MOBILE');
          } else if(FeatureManagement.checkPermission(CPP_AGENT_ATM_CUSTOM_PERMISSION)|| FeatureManagement.checkPermission(ECE_600_CUSTOM_PERMISSION)){
              Boolean isCPPAccessUsers = true;
            return '/c/ExternalLinkApp.app?linkId=55&accountId=' + recordId + '&ECEuser='+isCPPAccessUsers;
        } else{
            throw new AuraHandledException('NOT ALLOWED');              
        }
    }
    
    /** 
    * @description buildCurrMarkOppsLink : build URL for gateway data for Customer Marketing Opportunity.  Changes link ID based on logged in user profile
    * @param recordId
    * @return String
    */
    @AuraEnabled
    public static String buildCurrMarkOppsLink(String recordId) {
        if(isSalesforce1Theme) {
            throw new AuraHandledException('MOBILE');
        } else {
            return '/c/ExternalLinkApp.app?linkId=80&accountId=' + recordId;
        }
    }

    /** 
    * @description buildCallTrackerLinkForCCCSalesOnAccountCreate : build URL for gateway data for Call Tracker Application.
    * @param customerId, callKey
    * @return String
    */

    public static String buildCallTrackerLinkForCCCSalesOnAccountCreate(String customerId,  String interactionId) {

        if(isSalesforce1Theme) {
            throw new AuraHandledException('MOBILE');
        }else if (String.isNotBlank(customerId) ) { 
            return '/c/ExternalLinkApp.app?linkId=227&accountId=' + customerId +'&callKey=' +interactionId;
        } else { 
            throw new AuraHandledException('NOT ALLOWED');
        }

    }

}