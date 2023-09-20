/**
* @author Moneyball
* @owner Moneyball
* @name RentalButtonController
* @createDate 01/31/2023
* @description class for http request for rental button
* @version 1.0
*/
public with sharing class RentalButtonController {
    /**
    * @name getClaimInvestigation
    * @description This method is to get ClaimInvestigationCausesOfLoss by calling an API.
    * @param input map with the callout name and parameters
    * @return HttpCalloutResponse Wrapped response with status code and body
    */
    @AuraEnabled(cacheable = true)
    public static HttpRequestCalloutHelper.HttpCalloutResponse getClaimInvestigation(Map<String, Object> input) {
        try {
            return HttpRequestCalloutHelper.doCallout(input);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @name getClaimCoverage
    * @description This method is to get ClaimIndividualcoverage by calling an API.
    * @param input map with the callout name and parameters
    * @return HttpCalloutResponse Wrapped response with status code and body
    */
    @AuraEnabled(cacheable = true)
    public static HttpRequestCalloutHelper.HttpCalloutResponse getClaimCoverage(Map<String, Object> input) {
        try {
            return HttpRequestCalloutHelper.doCallout(input);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @name getRepairAssignment
    * @description This method is to getRepairAssignment by calling an API.
    * @param input map with the callout name and parameters
    * @return HttpCalloutResponse Wrapped response with status code and body
    */
    @AuraEnabled(cacheable = true)
    public static HttpRequestCalloutHelper.HttpCalloutResponse getRepairAssignment(Map<String, Object> input) {
        try {
            return HttpRequestCalloutHelper.doCallout(input);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @name getClaimProvider
    * @description This method is to getClaimProvider by calling an API.
    * @param input map with the callout name and parameters
    * @return HttpCalloutResponse Wrapped response with status code and body
    */
    @AuraEnabled(cacheable = true)
    public static HttpRequestCalloutHelper.HttpCalloutResponse getClaimProvider(Map<String, Object> input) {
        try {
            return HttpRequestCalloutHelper.doCallout(input);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @name getRentalAssignment
    * @description This method is to getRentalAssignment by calling an API.
    * @param input map with the callout name and parameters
    * @return HttpCalloutResponse Wrapped response with status code and body
    */
    @AuraEnabled
    public static HttpRequestCalloutHelper.HttpCalloutResponse getRentalAssignment(Map<String, Object> input) {
        try {
            String calloutName = (String)input.get('calloutName');
            List<Object> objects = (List<Object>)input.get('calloutParams');
            List<String> parameters = new List<String>();
            for (Object o : objects) {
                parameters.add((String)o);
            }

            List<String> escapedParameters = new List<String>();
            escapedParameters.add(EncodingUtil.urlEncode(parameters[0], 'UTF-8'));
            Continuation_Callout__c calloutRecord = getCalloutConfiguration(calloutName);
            String endpoint = String.format(calloutRecord.EndpointURLTemplate__c, escapedParameters);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod(calloutRecord.RestVerb__c);
            if (String.isNotBlank(calloutRecord.BodyTemplate__c)) {
                request.setHeader('Content-Type', 'application/json');
                request.setBody(String.format(calloutRecord.BodyTemplate__c, parameters));
            }

            HttpResponse response = http.send(request);

            HttpRequestCalloutHelper.HttpCalloutResponse result = new HttpRequestCalloutHelper.HttpCalloutResponse();
            result.statusCode = response.getStatusCode();
            result.body = response.getBody();
            return result;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @name getRentalEligibleCallout
     * @description callout to rental eligible api and retreive eligibility info
     * @param externalClaimId, externalParticipantId
     * @return HttpRequestCalloutHelper.HttpCalloutResponse
     */
    @AuraEnabled
    public static HttpRequestCalloutHelper.HttpCalloutResponse getRentalEligibleCallout(String externalClaimId, String externalParticipantId){
        try {
            List<String> escapedParameters = new List<String>();
            escapedParameters.add(EncodingUtil.urlEncode(externalClaimId, 'UTF-8'));
            escapedParameters.add(EncodingUtil.urlEncode(externalParticipantId, 'UTF-8'));
            String calloutName = 'RentalEligibility';
            if(Test.isRunningTest()){
                calloutName = 'MockREST';
            }
            Continuation_Callout__c calloutRecord = getCalloutConfiguration(calloutName);
            String endpoint = String.format(calloutRecord.EndpointURLTemplate__c, escapedParameters);
            String accessToken = getAccessToken();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod(calloutRecord.RestVerb__c);
            request.setHeader('X-SF_AD_OIDC_TOKEN', accessToken);
            HttpResponse response = http.send(request);
            HttpRequestCalloutHelper.HttpCalloutResponse result = new HttpRequestCalloutHelper.HttpCalloutResponse();
            result.statusCode = response.getStatusCode();
            result.body = response.getBody();
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @name getAccessToken
     * @description get rental api access token
     * @return String
     */
    private static String getAccessToken(){
        String accessToken;
        if(Test.isRunningTest()){
            accessToken = 'accessToken';
        }
        else{
            accessToken = UTIL_SATS_SecurityUtils.retrieveAccessToken('ACCSE-ClaimsEligibility', 'Claims-RentalEligibility');
        }
        return accessToken;
    }

    /**
     * @name getCalloutConfiguration
     * @description retrieves Continuation_Callout__c object using callout name
     * @param calloutName
     * @return Continuation_Callout__c
     */
    private static Continuation_Callout__c getCalloutConfiguration(String calloutName) {
        List<Continuation_Callout__c> calloutConfigs = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT
                    BodyTemplate__c,
                    RestVerb__c,
                    EndpointURLTemplate__c
                FROM Continuation_Callout__c
                WHERE Name = :calloutName])
                .getRecords();
        if (calloutConfigs.isEmpty()) {
            throw new AuraHandledException('No callout record with name of ' + calloutName);
        }
        
        return calloutConfigs[0];
    }
}