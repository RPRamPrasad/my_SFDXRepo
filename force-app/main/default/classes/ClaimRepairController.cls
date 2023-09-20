/**
 * @author: Moneyball
 * @name ClaimRepairController
 * @description This class is for the claim repair component to use for logging purposes.
 */
public with sharing class ClaimRepairController {

    public static final String CALLOUT_NAME_KEY = 'calloutName';
    public static final String CALLOUT_PARAMS_KEY = 'calloutParams';

    
    /**
     * @name getRepairAssignments
     * @description Get the repair assignements for the claim by calling an API.
     * @param input map with the callout name and parameters
     * @return HttpCalloutResponse Wrapped response with status code and body
     */
    @AuraEnabled(cacheable = true)
    public static HttpRequestCalloutHelper.HttpCalloutResponse getRepairAssignments(Map<String, Object> input) {
        try {
            return HttpRequestCalloutHelper.doCallout(input);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @name getRepairEligibleCallout
     * @description This is a generic method to make a get HTTP request.
     * @param input map with the callout name and parameters
     * @return HttpCalloutResponse wrapped response with status code and body
     */  
    @AuraEnabled
    public static HttpCalloutResponse getRepairEligibleCallout(Map<String, Object> input) {

        try {

            String calloutName = (String)input.get(CALLOUT_NAME_KEY);
            List<Object> objects = (List<Object>)input.get(CALLOUT_PARAMS_KEY);
            List<String> parameters = new List<String>();
            for (Object o : objects) {
                parameters.add((String)o);
            }

            List<String> escapedParameters = getEscapedParameters(parameters);
            Continuation_Callout__c calloutRecord = getCalloutConfiguration(calloutName);
            String endpoint = String.format(calloutRecord.EndpointURLTemplate__c, escapedParameters);
            String accessToken = getAccessToken();
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod(calloutRecord.RestVerb__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-SF_AD_OIDC_TOKEN', accessToken);
            for (Continuation_Callout_Header__c header : calloutRecord.Continuation_Callout_Headers__r) {
                request.setHeader(header.Key__c, header.Value__c);
            }
            if (String.isNotBlank(calloutRecord.BodyTemplate__c)) {
                request.setBody(String.format(calloutRecord.BodyTemplate__c, parameters));
            }
            HttpResponse response = http.send(request);
            HttpCalloutResponse result = new HttpCalloutResponse();
            result.statusCode = response.getStatusCode();
            result.body = response.getBody();

          return result;

        }catch (Exception e) {
            throw new AuraHandledException('Error calling ' + e.getMessage());
            
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
            accessToken = UTIL_SATS_SecurityUtils.retrieveAccessToken('ACCSE-ClaimsEligibility', 'Claims-RepairEligibility');
        }
        return accessToken;
    }


    /**
     * @name HttpCalloutResponse
     * @description Wraps the response back to the caller.
     */ 
    public class HttpCalloutResponse {
        /**
         * @name statusCode
         * @description get and set statusCode
         * @return Integer
         */
        @AuraEnabled
        public Integer statusCode {get;set;}

        /**
         * @name body
         * @description get and set body
         * @return String
         */
        @AuraEnabled
        public String body {get;set;}
    }

    /**
     * @name getEscapedParameters
     * @description escape url parameter values
     * @param parameters
     * @return list<String>
     */
    private static List<String> getEscapedParameters(List<String> parameters) {
        List<String> escapedParameters = new List<String>();
        for (String param : parameters) {
            escapedParameters.add(EncodingUtil.urlEncode(param, 'UTF-8'));
        }

        return escapedParameters;
    }

    /**
     * @name getCalloutConfiguration
     * @description retrieves Continuation_Callout__c object using callout name
     * @param calloutName
     * @return Continuation_Callout__c
     */
    private static Continuation_Callout__c getCalloutConfiguration(String calloutName) {
        UTIL_ParameterValidator parameterValidator = UTIL_ParameterValidationFactory.getParameterValidator(ParameterType.ALL_PARAMETER);
        parameterValidator.validateParameter(CALLOUT_NAME_KEY, String.escapeSingleQuotes(calloutName));
        List<Continuation_Callout__c> calloutConfigs = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT
                    BodyTemplate__c,
                    RestVerb__c,
                    EndpointURLTemplate__c
                FROM Continuation_Callout__c
                WHERE Name = :String.escapeSingleQuotes(calloutName)])
                .getRecords();
        if (calloutConfigs.isEmpty()) {
            throw new AuraHandledException('No callout record with name of ' + calloutName);
        }

        return calloutConfigs[0];
    }
}
