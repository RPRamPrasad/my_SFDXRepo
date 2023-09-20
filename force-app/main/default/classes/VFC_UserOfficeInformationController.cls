/**
* Author : Golden Spikes Team
* Date Created : 08/09/2018
* @description : This Apex Class is used to query the logged in user agent office information.
*/

public with sharing class VFC_UserOfficeInformationController {

    private static final String CLASS_NAME = 'VFC_UserOfficeInformationController';
    private static final String METHOD_NAME = 'queryOfficeInformation';
    private static final String USER_EXTERNAL_ID_CONCATENATION_SYMBOL = '_';
    /**
     * @description officeName
     */
    public String officeName {get; set;}    
    /**
     * @description VFC_UserOfficeInformationController
     */
    public VFC_UserOfficeInformationController() {
        AP_ClickJackPrevention.setRequiredHeaders();
    }
    /**
     * @description queryOfficeInformation
     */
    public void queryOfficeInformation() {
       User loggedInUser = [Select id, profile.name, Servicing_Agent_Associate_ID__c from User Where id =: UserInfo.getUserId() Limit 1];
       String loggedInUserProfileName = loggedInUser.profile.name;

       if((UTIL_Constants.AGENT_PROFILE_NAME).equals(loggedInUserProfileName) || (UTIL_Constants.ATM_PROFILE_NAME).equals(loggedInUserProfileName)) {
            officeName = Label.CL_USER_LOGGED_IN_OFFICE + UTIL_Constants.SPACE_SYMBOL;
            for(User usr: [Select Name from User Where UserExternalID__c =: loggedInUser.Servicing_Agent_Associate_ID__c + USER_EXTERNAL_ID_CONCATENATION_SYMBOL + loggedInUser.Servicing_Agent_Associate_ID__c limit 1]) {
               officeName += usr.Name;
            }
       } else {
           officeName = Label.CL_USER_LOGGED_IN_AS + UTIL_Constants.SPACE_SYMBOL + UserInfo.getName();
       }
    }
}