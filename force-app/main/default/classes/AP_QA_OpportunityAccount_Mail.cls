/****************************************************************************************
Name: AP_QA_OpportunityAccount_Mail
Copyright © State Farm
=========================================================================================
@description : This class implements AP_PreRedirectAction
Team: ClubCar
=========================================================================================
VERSION         AUTHOR                    DATE                   DETAIL
2.0             ClubCar                  02/18/2020               Updated PMD finding for CRUD violations
******************************************************************************************/
public with sharing class AP_QA_OpportunityAccount_Mail implements AP_PreRedirectAction {
    
    private Map<String,String> requestParameters {get;set;}
    
    /**
    * @description  starts the execution with the provided details 
    */
    public void execute(){
            String accountId = requestParameters.get(LinkConstants.INPUT_PARAM_ACCOUNT_ID);
            Account acct= [select id, name,IsDeathNotificationReceived__pc,ClientIdentifier__c  from Account where id=: accountId WITH SECURITY_ENFORCED LIMIT 1];
            
            if( acct.IsDeathNotificationReceived__pc){
                
                throw new LinkBuilderController.LinkException(System.Label.CL_SELECTMAILER_CLIENT_DECEASED);
                
            }
            String clientId = acct.ClientIdentifier__c;
            HLPR_MarketingMailManagementFacade mailFacade = new  HLPR_MarketingMailManagementFacade();
            Boolean mailIndicator = mailFacade.retrieveDoNotSolicitMailIndicator(clientId);
            String appId = HLPR_MarketingMailMgnt_AppId_Logic.determineAppIDForMail(mailIndicator);
            requestParameters.put('appId', appId);
    }
    /**
    * @description  setting RequestParameters
    * @param requestParameters
    */
    public void setRequestParameters(Map<String,String> requestParameters){
        
        this.requestParameters = requestParameters;
    }
    
}