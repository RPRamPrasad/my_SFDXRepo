/****************************************************************************************
Name: HLPR_MarketingMailManagementFacade
Copyright © State Farm
=========================================================================================
@description : Facade for consuming TP Service MarketingMailManagement  
Team: ClubCar
=========================================================================================
******************************************************************************************/ 
public with sharing class HLPR_MarketingMailManagementFacade {
    
    public final static String SERVICE_EMAIL_INDICATOR = 'doNotSolicitServiceIndicator';
    public final static String MARKETING_EMAIL_INDICATOR = 'doNotSolicitMarketingIndicator';
    private final static String SR_API_KEY = 'SR_API_KEY';
    private final static String SR_CATEGORY = 'SR_CATEGORY';
    private final static String MARKETING_MAIL_MANAGEMENT_SR_CATEGORY = 'Customer_Aggregator_SR_Category';
    private final static String MARKETING_MAIL_MANAGEMENT_SR_API_KEY = 'Marketing_Mail_Management_SR_API_Key';
    private final static String ROUTER_DOWN_ERROR_MESSAGE = 'The ability to call MarketingMailManagement is currently unavailable. Please try again later.';
    private final static String CLASS_NAME = 'HLPR_MarketingMailManagementFacade';
    private final static String ROUTE_REQUEST_METHOD_NAME_MAIL = 'retrieveDoNotSolicitMailIndicator';
    private final static String ROUTE_REQUEST_METHOD_NAME_EMAIL = 'retrieveDoNotSolicitEmailIndicator';
    private final static String DEFAULT_CATEGORY = 'NO_CATEGORY';
    
    /**
    * @description retrieveDoNotSolicitMailIndicator used to check the Mail indicator for a particular client
    * @param  clientID
    * @return response - boolean true or false returned based on the response
    */
    public Boolean retrieveDoNotSolicitMailIndicator(String clientID) {
        Boolean response = true;
        try {
            response = createPort().retrieveDoNotSolicitMailIndicator(clientId);
        } catch (System.Exception e) {
            LoggingService.logHandledException(new System.CalloutException(ROUTER_DOWN_ERROR_MESSAGE, e), CLASS_NAME , ROUTE_REQUEST_METHOD_NAME_MAIL, System.LoggingLevel.ERROR);
        }
        return response;
    }
    
    /**
    * @description retrieveDoNotSolicitEmailIndicator used to check the Email indicator for a particular client
    * @param  emailAddress
    * @return response - Map holds the email and boolean true or false returned based on the response
    */
    public Map<String, Boolean> retrieveDoNotSolicitEmailIndicator(String emailAddress) {
        Map<String, Boolean> response = new Map<String, Boolean>();
        try {
            response = buildEmailResponse(createPort().retrieveDoNotSolicitEmailIndicator(emailAddress));
        } catch (System.Exception e) {
            LoggingService.logHandledException(new System.CalloutException(ROUTER_DOWN_ERROR_MESSAGE, e), CLASS_NAME , ROUTE_REQUEST_METHOD_NAME_EMAIL, System.LoggingLevel.ERROR);
            throw new LinkBuilderController.LinkException(System.Label.CL_SELECTMAILER_MMM_SERVICE_FAIL);
        }
        return response;
    }
    
    private Map<String, Boolean> buildEmailResponse(MarketingMailManagement.DoNotSolicitEmailResponse_element doNotSolicitEmail) {
        Map<String, Boolean> response = new Map<String, Boolean>();
        response.put(SERVICE_EMAIL_INDICATOR, doNotSolicitEmail.doNotSolicitServiceIndicator);
        response.put(MARKETING_EMAIL_INDICATOR, doNotSolicitEmail.doNotSolicitMarketingIndicator);
        return response;
    }
    
    private MarketingMailManagement.MarketingMailManagementPort createPort() {
        MarketingMailManagement.MarketingMailManagementPort port = new MarketingMailManagement.MarketingMailManagementPort();
        if (port.inputHttpHeaders_x == null) {
            port.inputHttpHeaders_x = new Map<String, String>();
        }
        port.inputHttpHeaders_x.put(SR_API_KEY, getApiKey().Value__c);
        port.inputHttpHeaders_x.put(SR_CATEGORY, getCategory());
        return port;
    }
    
    private CS_EnvironmentURLCustomSetting__c getApiKey() {
        return [select Value__c from CS_EnvironmentURLCustomSetting__c where Name =:MARKETING_MAIL_MANAGEMENT_SR_API_KEY WITH SECURITY_ENFORCED];
    }
    
    private String getCategory() {
        String returnCategory = DEFAULT_CATEGORY;
        try {
            returnCategory = [select Value__c from CS_EnvironmentURLCustomSetting__c where Name =:MARKETING_MAIL_MANAGEMENT_SR_CATEGORY].Value__c;
        } catch (Exception e) {
            returnCategory = '';
        }
        return returnCategory;
    }
}