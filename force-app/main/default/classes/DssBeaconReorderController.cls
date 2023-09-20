public with sharing class DssBeaconReorderController {
	private static final String CLASS_NAME = 'DssBeaconReorderController';
    
    @AuraEnabled
    public  static String shipmentServiceCall(Object shipmentOrder) {       
        String returnValue = 'Error';
        
    if (shipmentOrder != null ) {
        String body = JSON.serialize(shipmentOrder);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:AWSBeaconService/shipmentOrder');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('applicationName', 'ECRM');
        req.setMethod('POST');      
        req.setBody(body);         
      
        try {
            HttpResponse res = http.send(req);           
            if(res.getStatusCode() == 200) {           
                returnValue = 'Success'; 
            } else {
                logException(JSON.serialize(res.getBody()),'shipmentServiceCall');
            }
        } catch(Exception ex) {
            logException(ex.getMessage(),'shipmentServiceCall');
        }  
    } else {
        returnValue = 'Error';
    }
    return returnValue;
    }


    @AuraEnabled
    public  static String mrsfServiceCall(String tcId, String enrollmentId) {       
    
    String body = '{"tcid":"'+tcId+'","enrollmentId":"'+enrollmentId+'"}';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:AWSBeaconService/orderStatus');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('applicationName', 'ECRM');
        req.setMethod('POST');      
   
        if(tcId != null) {             
            req.setBody(body);       
        } else if (enrollmentId != null){ 
            req.setBody(body);         
        } else {           
            logException(JSON.serialize(req.getBody()),'mrsfServiceCall');  
        }
        String jsonResponse;
   
        try {
            HttpResponse res = http.send(req);           
            if(res.getStatusCode() == 200) {           
                jsonResponse = (string) JSON.deserializeUntyped(res.getBody());                      
            } else {
                logException(JSON.serialize(res.getBody()),'mrsfServiceCall');
            }
        } catch(Exception ex) {
            logException(ex.getMessage(),'mrsfServiceCall');
        }  
    return jsonResponse;
    }
    
    @AuraEnabled
    public static String createSupportCase(DssLwcParams uiParams) {
        User loggedInUser = (User)Security.stripInaccessible(AccessType.READABLE, [select Alias,State_Agent_Code__c from User where Id =: UserInfo.getUserId() LIMIT 1]).getRecords()[0];
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ACMTCaseCreation/createCases');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('applicationName', 'ECRM');
        req.setMethod('POST');
        req.setBody(buildRequestBody(uiParams, loggedInUser));
        
        String supportCaseNumber = '';
        try {
            HttpResponse res = http.send(req);
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null & String.IsEmpty(supportCaseNumber)){
                    if(parser.getText() == 'caseNumber'){
                        parser.nextValue();
                        supportCaseNumber = parser.getText();
                    }
                }
            } else {
                logException(JSON.serialize(res.getBody()), 'createSupportCase');
            }
        } catch(Exception ex) {
            logException(ex.getMessage(), 'createSupportCase');
        }
        return supportCaseNumber;
    }
    
    private static String buildRequestBody(DssLwcParams uiParams, User loggedInUser) {
        DssRequestParams params = new DssRequestParams();
        params.subject = 'Automated Beacon Reorder Kickout - Assistance needed';
        params.type = 'Customer Communications';
        params.topic = 'Beacon Reorder';
        params.longPolicyNumber = uiParams.policyNumber;
        params.customerName = uiParams.clientName;
        params.agentCode = loggedInUser.State_Agent_Code__c;
        params.userAlias = loggedInUser.Alias;
        params.errorDescription = uiParams.errorDescription;
        params.description = 'Requesting additional support be provided to triage this customers Drive safe & Save Mobile beacon concern; Client ID - ' + uiParams.clientId + '; VIN - ' + uiParams.vin + '; Product Description - ' + uiParams.productDescription + ';';

        return Json.serialize(params);
    }
    
    @AuraEnabled
    public static void logException(String message, String method){
        LoggingService.logHandledException(new CalloutException(message), CLASS_NAME, method, System.LoggingLevel.ERROR);
    }

    @AuraEnabled
    @future
    public static void logAgentStatusTrackerOpen(){
        try {
            System.isFuture();
        }
        catch(Exception e) {
            LoggingService.logHandledException(new CalloutException(e.getMessage()), CLASS_NAME, 'logAgentStatusTrackerOpen', System.LoggingLevel.ERROR);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @TestVisible private class DssLwcParams {
        @AuraEnabled public String policyNumber {get; set;}
        @AuraEnabled public String vin {get; set;}
        @AuraEnabled public String clientId {get; set;}
        @AuraEnabled public String clientName {get; set;}
        @AuraEnabled public String productDescription {get; set;}
        @AuraEnabled public String errorDescription {get; set;}
    }
    
    @TestVisible private class DssRequestParams {
        @TestVisible private String longPolicyNumber;
        @TestVisible private String subject;
        @TestVisible private String description;
        @TestVisible private String type;
        @TestVisible private String topic;
        @TestVisible private String agentCode;
        @TestVisible private String userAlias;
        @TestVisible private String customerName;
		@TestVisible private String errorDescription;
    }
}