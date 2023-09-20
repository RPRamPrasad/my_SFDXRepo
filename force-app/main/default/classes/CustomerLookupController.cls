/****************************************************************************************
Name: CustomerLookupController
Copyright © State Farm
=========================================================================================
Purpose:
-------
Apex controller for the CustomerLookup.cmp

Team: Targaryen
@description Customer Lookup Controller
=========================================================================================
History
-------
VERSION         AUTHOR                  DATE                    DETAIL
1.0             w5sa		            2/22/2019              
1.1             w5sa                    7/11/2019               Security fix
1.2             w5sa                    8/13/2019               ClientId search
1.3             y3zo                    4/26/2020               SFICS users
******************************************************************************************/
public with sharing class CustomerLookupController {
    private static final List<String> FIELDS = new List<String>{'ClientIdentifier__c', 'RecordType.Name', 'Name', 'PersonBirthdate', 'LastName', 'FirstName', 'BillingStreet', 'BillingState', 'BillingPostalCode', 'BillingCountry', 'BillingCity',
        'PersonHomePhone', 'PersonMobilePhone', 'PersonOtherPhone', 'Phone', 'PersonEmail', 'DriversLicenseNumber__c', 'DriversLicenseStateProvince__c', 'EmployerName__pc'};
     
    private static final String PHONE ='Phone Number';
    private static final String NAME ='Name';
    private static final String CLIENT_ID = 'Client Id';
    @TestVisible public static String loggedInProfile = getLoggedInUser();
    private static final String SFICS_PERMISSION_NAME = 'SFICS_Users_Account_Edit_Access';

    /**
     * @description Search For Accounts
     * @param searchText
     * @param searchContext
     * @return List<Account>
     */
    @AuraEnabled
    public static List<Account> searchForAccounts(String searchText, String searchContext) {
        List<Account> accountResults = new List<Account>();
        
       	accountResults = CustomerLookupController.searchAccountsBy(searchContext, searchText);
        accountResults.sort();
        return accountResults;
    }

    /**
     * @description Current User
     * @return User
     */
    @AuraEnabled
    public static User currentUser() {
        if(loggedInProfile.equalsIgnoreCase(System.Label.CL_ATM_Profile)||loggedInProfile.equalsIgnoreCase(System.Label.CL_Agent_Profile) ||
           loggedInProfile.equalsIgnoreCase(System.Label.CL_TechSupport_Profile) || FeatureManagement.checkPermission(SFICS_PERMISSION_NAME)){
             return UTIL_CurrentUser.retrieveCurrentUser();
        } else{
            throw new AuraHandledException('NOT ALLOWED');
        } 
    }

    private static String getLoggedInUser(){
        String userId = userInfo.getUserId();
        List<User> loggedInUser =  [ select Id, Profile.Name, Name, Associate_ID__c, profileId, Servicing_Agent_External_ID__c 
                                                                                    from User where Id =:userId limit 1];     
        return loggedInUser.get(0).Profile.Name;
    }
    
    private static List<Account> searchAccountsBy(String searchContext, String searchText) {
        // Used to validate access for SOSL
     	List<String> validFields =  UTIL_LtngAccess.validateUserAccessibilitytoRead(FIELDS, 'Account');
     	List<Account> accountResults = new List<Account>();
        Integer validFieldsLength = validFields.size();
     	
     	if (validFieldsLength == CustomerLookupController.FIELDS.size()) {
     		if (CustomerLookupController.NAME.equalsIgnoreCase(searchContext)) {
            	accountResults = CustomerLookupController.searchByName(searchText);
        	} else if (CustomerLookupController.PHONE.equalsIgnoreCase(searchContext)) {
            	accountResults = CustomerLookupController.searchByPhone(searchText);
        	} else if (CustomerLookupController.CLIENT_ID.equalsIgnoreCase(searchContext)){
                accountResults = CustomerLookupController.searchByClientId(searchText);
            }
     	}
     	
     	return accountResults;
     }
     
     private static List<Account> searchByName(String searchText) {
     	List<Account> result = [FIND :String.escapeSingleQuotes(searchText) IN NAME FIELDS returning Account(Id,clientIdentifier__c, RecordType.Name, Name, PersonBirthdate, LastName, FirstName, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity,PersonHomePhone, PersonMobilePhone, PersonOtherPhone, Phone, PersonEmail, DriversLicenseNumber__c, DriversLicenseStateProvince__c, EmployerName__pc WHERE clientIdentifier__c != NULL)][0];
         return result;
     }
     
	private static List<Account> searchByPhone(String searchText) {
     	List<Account> result = [FIND :String.escapeSingleQuotes(searchText) IN PHONE FIELDS returning Account(Id,clientIdentifier__c, RecordType.Name, Name, PersonBirthdate, LastName, FirstName, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity,PersonHomePhone, PersonMobilePhone, PersonOtherPhone, Phone, PersonEmail, DriversLicenseNumber__c, DriversLicenseStateProvince__c, EmployerName__pc WHERE clientIdentifier__c != NULL)][0];
         return result;
     }

     private static List<Account> searchByClientId(String searchText) {
// Using StripInaccessible due to it being soql
        List<Account> result = new List<Account>();
        if (searchText.length() == 11 && searchText.isAlphanumeric()){
        	result = Security.stripInaccessible(AccessType.READABLE, [SELECT ClientIdentifier__c, Name, RecordType.Name, PersonBirthdate, LastName,  FirstName, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity,PersonHomePhone, PersonMobilePhone, PersonOtherPhone, Phone, PersonEmail, DriversLicenseNumber__c, DriversLicenseStateProvince__c, EmployerName__pc from Account WHERE ClientIdentifier__c=:String.escapeSingleQuotes(searchText).escapeHtml4()]).getRecords();            
         }
         return result;
         }

    
}