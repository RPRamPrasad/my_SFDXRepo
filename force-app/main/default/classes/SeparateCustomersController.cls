/**
  *    Author          : Garvit (ywk1)
  *    Team            : Targaryen (CMM)
  *    Date Created    : 07/25/2019
  *    @description     : Apex class SeparateCustomersController             
  *    Version         : 1.0
  */
  public with Sharing class SeparateCustomersController {
    @TestVisible public static String loggedInProfile = UTIL_LtngProfileDataAccess.getProfileName();  
    private static final String CLASS_NAME = 'SeparateCustomersController';
    private static final String S1_THEME = 'Theme4t';
    @TestVisible static Boolean isSalesforce1Theme = UserInfo.getUiThemeDisplayed().equals(S1_THEME);
       
    /**
     * @description Get Details
     * @param recId
     * @return Account
     */
    @AuraEnabled
    public static Account getDetails(String recId){
        ID.valueOf(recId);
        if(isSalesforce1Theme) {
            throw new AuraHandledException('MOBILE');
        }else if(loggedInProfile.equalsIgnoreCase(System.Label.CL_ATM_Profile)||loggedInProfile.equalsIgnoreCase(System.Label.CL_Agent_Profile)){
            String strRecId = String.escapeSingleQuotes(recId);

            List<Account> accList = Security.stripInaccessible(AccessType.READABLE,[ Select Id, Name, BillingStreet, BillingCity, BillingState,BillingCountry,BillingPostalCode,BillingAddressType__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode,ShippingAddressType__c, ClientIdentifier__c 
                                        From Account WHERE Id =:strRecId]).getRecords();
            return accList.isEmpty()?null:accList[0];
        } else{
            throw new AuraHandledException('NOT ALLOWED');
        }
    }
    
    /**
     * @description Get Custom Setting Details
     * @return CS_HpsmWebService__c
     */
   @AuraEnabled
    public static CS_HpsmWebService__c getCustomSettingDetails(){
        CS_HpsmWebService__c csvalues = CS_HpsmWebService__c.getValues('separate');
        return csvalues;
    }
    
  

    /**
     * @description Get State Agent Code
     * @return String
     */
    @AuraEnabled
    public static String getStateAgentCode(){
        User loggedInUser = UTIL_CurrentUser.retrieveCurrentUser();
        String loggedInUserProfileName=loggedInUser.Profile.Name;
        String expectedAgentExternalId=loggedInUser.Servicing_Agent_Associate_ID__c+'_'+loggedInUser.Servicing_Agent_Associate_ID__c;
        string stateAgtCode;
		
		if(loggedInUserProfileName.equalsIgnoreCase(System.Label.CL_ATM_Profile)||loggedInUserProfileName.equalsIgnoreCase(System.Label.CL_Agent_Profile)){
            List<User> usrList = Security.stripInaccessible(AccessType.READABLE,[Select Id, State_Agent_Code__c
            From User WHERE UserExternalId__c =:expectedAgentExternalId]).getRecords();
            stateAgtCode = usrList.isEmpty()?'':usrList[0].State_Agent_Code__c;
        } else {
            stateAgtCode = '';
        }
        return stateAgtCode;
    }
  
    /**
     * @description Check For Spi
     * @param comments
     * @param textlabel
     * @return String
     */
	@AuraEnabled
    public static String checkForSpi(String comments, String textlabel){
        String errorMessage = '';
        if((comments!=null && comments!='') && (textlabel!=null && textlabel!='')){
    	 	AP_SPISecurityValidator spiSecurity = new AP_SPISecurityValidator();
        	errorMessage = spiSecurity.handle(comments,textlabel);
        }
        
		return errorMessage;        
    }

}