/**
 * @author: Moneyball
 * @name ClaimServiceEligibilityController
 * @description This class is for the claim service eligibility to use for logging purposes.
 */
public with sharing class ClaimServiceEligibilityController {
    
    /**
     * @name getNamedInsuredParticipants
     * @description Get the named insured participants for the claim.
     * @param input map with the callout name and parameters
     * @return HttpCalloutResponse Wrapped response with status code and body
     */
    @AuraEnabled(cacheable = true)
    public static HttpRequestCalloutHelper.HttpCalloutResponse getNamedInsuredParticipants(Map<String, Object> input) {
        try {
            return HttpRequestCalloutHelper.doCallout(input);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
