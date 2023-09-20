/****************************************************************************************
Name: AP_QA_OpportunityAccount_Email
=========================================================================================
@description : This class implements AP_PreRedirectAction
Team: ClubCar
=========================================================================================
History
VERSION         AUTHOR                    DATE                   DETAIL
2.0             ClubCar                  02/18/2020              Updated PMD finding for CRUD violations
******************************************************************************************/
public with sharing class AP_QA_OpportunityAccount_Email implements AP_PreRedirectAction {
    
    private final static String APP_ID = 'appId';
    private Map<String,String> requestParam;
    private HLPR_MarketingMailManagementFacade emailIndicator;
    private final static String YES = 'yes';
    private final static String NO = 'no';
	
    /**
    * @description  holds the current emailIndicator
    * @param emailIndicator
    */
    public AP_QA_OpportunityAccount_Email(HLPR_MarketingMailManagementFacade emailIndicator){
        this.emailIndicator  =  emailIndicator;
    }
    /**
    * @description  holds the current HLPR_MarketingMailManagementFacade instance
    */
    public AP_QA_OpportunityAccount_Email(){
        this.emailIndicator  =  new HLPR_MarketingMailManagementFacade();
    }
    /**
    * @description  starts the execution with the provided details 
    */
    public void execute(){       
        String accountId = requestParam.get(LinkConstants.INPUT_PARAM_ACCOUNT_ID);
            Account acct= [select id, name, PersonEmail, PersonEmail__c, IsDeathNotificationReceived__pc, HasPermissionToServiceEmail__c,
                                HasPermissionToMarketingEmail__c, IsSubjecttoCASL__c from Account where id=: accountId WITH SECURITY_ENFORCED LIMIT 1];

            if (acct.IsDeathNotificationReceived__pc){
                throw new LinkBuilderController.LinkException(System.Label.CL_SELECTMAILER_CLIENT_DECEASED);  
            } 
            
            if(String.isBlank(acct.PersonEmail)){
                throw new LinkBuilderController.LinkException(System.Label.CL_SELECTMAILER_MISSING_EMAIL); 
            }
            
            Map<String, Boolean> fullMapInstance = emailIndicator.retrieveDoNotSolicitEmailIndicator(acct.PersonEmail__c);     	
            // Compare CASL, customer permission, and do not solicit
            Boolean doNotSendService = doNotSendService(acct) || fullMapInstance.get(HLPR_MarketingMailManagementFacade.SERVICE_EMAIL_INDICATOR); 
            // Compare customer permission and do not solicit 
            Boolean doNotSendMarketing = doNotSendMarketing(acct) || fullMapInstance.get(HLPR_MarketingMailManagementFacade.MARKETING_EMAIL_INDICATOR); 
            
            if(doNotSendService && doNotSendMarketing){
                throw new LinkBuilderController.LinkException(System.Label.CL_SELECTMAILER_DONOTSOLICIT);   
            }
            requestParam.put(APP_ID, HLPR_MarketingMailMgnt_AppId_Logic.determineAppIDForEmail(doNotSendMarketing, doNotSendService));
    }
    /**
    * @description  setting RequestParameters
    * @param requestParameters
    */
    public void setRequestParameters(Map<String,String> requestParameters){
        this.requestParam = requestParameters;  
    }
    
    private Boolean doNotSendMarketing(Account acct) {
    	Boolean doNotSendMarketing = false; // Assume we can send marketing email
    	if (YES.equalsIgnoreCase(acct.IsSubjecttoCASL__c)) {
        		doNotSendMarketing = true; // If they are subject to CASL, assume we shouldn't send marketing email 
      		if(YES.equalsIgnoreCase(acct.HasPermissionToMarketingEmail__c)) {
      			doNotSendMarketing = false; // If CASL, only if we have permission should we send marketing email
      		}
      	} else if (NO.equalsIgnoreCase(acct.HasPermissionToMarketingEmail__c)) {
      		doNotSendMarketing = true; // If not CASL, only if we don't have permission should we not send marketing email
      	}
      	return doNotSendMarketing;
    }
    
     private Boolean doNotSendService(Account acct) {
     	Boolean doNotSendService = false; // Assume we can send service email
     	if (NO.equalsIgnoreCase(acct.HasPermissionToServiceEmail__c)) {
      		doNotSendService = true; // Only if we don't have permission should we not send service email
      	}
      	return doNotSendService;
     }
    
}