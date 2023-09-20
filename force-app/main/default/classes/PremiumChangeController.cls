/**
* @name PremiumChangeController
* @author Team PCU Orca
* @createDate 07/12/2023
* @description The Apex class for Premium Change modal from policy actions.
*/
public with sharing class PremiumChangeController {
    private static final String CLASS_NAME = 'PremiumChangeController';
    private static final Integer ERROR_STATUS_CODE = 404;
	private static final String ERROR_RESPONSE_MESSAGE = 'Unable to find Dv information for given policy #';
    private static final String ERROR_RESPONSE = '{ "responseStatus" : ' + ERROR_STATUS_CODE  + ',"errorMsg" :' + ERROR_RESPONSE_MESSAGE +'}';
    private static final String CONSUMER_NAME = 'ECRM';
    private static final String PRODUCER_APINAME = 'PremiumChange-AWS';
    private static final String APPLICATION_TYPE = 'ECRM';

    /**
* @description getAzureToken
* @method: This method retrieves Azure Token.
*/
  //  @TestVisible
    public static String getAzureToken() {
        String accessToken;
        if(Test.isRunningTest()){
            accessToken = 'fakeToken';
        } else {
            accessToken = UTIL_SATS_SecurityUtils.retrieveAccessToken(CONSUMER_NAME, PRODUCER_APINAME);
        }
        return accessToken;
    }

    /**
* @description callPremiumChange
* @method: This method makes the actual callout to the web service
*/

    @AuraEnabled
    public static String callPremiumChange(String policyId){

        try {
            BodyPayload payload = new BodyPayload();
       		HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:PremiumChangeCallout/getPremiumChange');
            req.setMethod('POST');
            req.setHeader('Authorization','Bearer '+ getAzureToken());
            req.setHeader('Content-Type', 'application/json');
            req.setBody(buildPremiumChangePayload(policyId,payload));
            req.setTimeout(30 * 1000);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            return res.getBody();
        } catch(Exception e) {
            logException(e.getMessage(), ERROR_RESPONSE);
            return ERROR_RESPONSE ;
        }
    }

    public static String buildPremiumChangePayload(String policyId, BodyPayload payload){

        // Getting logged In user from sub user type
        List<User> loggedInUser = Security.stripInaccessible(AccessType.READABLE,[SELECT Alias, UserType__c, SubUserType__c
                                                                                  FROM User
                                                                                  WHERE Id =:UserInfo.getUserId() LIMIT 1
                                                                                 ]).getRecords();
        payload.loggedInSubUserType = loggedInUser.get(0).SubUserType__c;
        payload.loggedInUserAlias = loggedInUser.get(0).Alias;

        // Getting policy number, LOB and agreement index key from Insurance Policy
        List<InsurancePolicy> secureIp = Security.stripInaccessible(AccessType.READABLE, [SELECT Name,AgreSourceSysCd__c,ProdLineCd__c,AgreAccessKey__c FROM InsurancePolicy WHERE Id = :policyId LIMIT 1]).getRecords(); //Checks for user permissions to ensure FLS
        InsurancePolicy ip = secureIp[0];
        payload.policyNumber = ip.Name;
        payload.lob = ip.ProdLineCd__c;
        payload.agreementAccessKey = ip.AgreAccessKey__c;
        payload.agreementSourceSystemCode = ip.AgreSourceSysCd__c;
        // Getting state from Insurance Policy Asset if Insurance policy LOB is Fire or F
        payload.body = '{"agreSourceSystemCode":'+ payload.agreementSourceSystemCode + ',"policyNumber":"' + payload.policyNumber +'","lob":"' + payload.lob +'","applicationType":"' + APPLICATION_TYPE + '","agreementAccessKey":"'+ payload.agreementAccessKey +'","loggedInUser":"'+ payload.loggedInSubUserType +'","loggedInUserAlias":"'+ payload.loggedInUserAlias +'"}';
        return payload.body;
    }

    @TestVisible private class BodyPayload {
        @AuraEnabled public String policyNumber {get; set;}
        @AuraEnabled public String body {get; set;}
        @AuraEnabled public String lob {get; set;}
        @AuraEnabled public String agreementAccessKey {get; set;}
        @AuraEnabled public String loggedInSubUserType {get; set;}
        @AuraEnabled public String loggedInUserAlias {get; set;}
        @AuraEnabled public String agreementSourceSystemCode {get; set;}

    }


    public static void logException(String message, String method){
        LoggingService.logHandledException(new CalloutException(message), CLASS_NAME, method, System.LoggingLevel.ERROR);
    }
}