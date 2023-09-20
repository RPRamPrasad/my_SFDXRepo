/**
* Class that is used to interact with DV API to make comparisions between the current policy and identify any changes that may have occured.
*/
public with sharing class DVComparison {
    
    private static final String FILTER_STR = 'POLICY,RISK,COVERAGE,PHYOBJCT';
    private static final String DATA_FILTER_STR = 'CRICUI';
    private static final String NO_PREMIUM_CHANGE = 'The premium did not change at renewal';
    private static final String DATE_FORMAT = 'yyyy-MM-dd';
    // Create a new External Service instance of a PolicyRetrievalAPI class to allow calling the DV API
    private static ExternalService.PolicyRetrievalAPI dvlDetails = new ExternalService.PolicyRetrievalAPI();
    private static ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Request req = new ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Request();
    
    // Custom inner class exception use to throw exceptions when DV API call record is not found
    class PolicyNotFoundException extends Exception {}

    class RetrievePolicyAmmUsingGET_ResponseException extends Exception {}
    
    
    
   
    //Determines whether the effective date or the renewal date is closer to todays date to use in the DV API call.
    //@param policyId - policy that is being used for DV API call
    @auraEnabled
    public static String policyComparison(String policyId){
        String compResults;
        
        List<InsurancePolicy> secureIp = Security.stripInaccessible(AccessType.READABLE, [SELECT Name,AgreAccessKey__c,ProdLineCd__c FROM InsurancePolicy WHERE Id = :policyId LIMIT 1]).getRecords(); //Checks for user permissions to ensure FLS 
        InsurancePolicy ip = secureIp[0];
        
        req.agreementAccessKey = ip.AgreAccessKey__c;
       
        req.filters = FILTER_STR;
        req.dataFilters = DATA_FILTER_STR;
        req.asOfDate = DateTime.now().format(DATE_FORMAT);
        //compResults.add(req.asOfDate);
        //String policyDesc = '';
        try{
            ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response resp1 = dvlDetails.retrievePolicyAmmUsingGET(req);
            if(resp1.Code200.policy != null) {
                //cal helper class
                compResults = DVPremiumChangeFlowDecision.processLineOfBusiness(resp1,req);
            } else {
                compResults = '{ "responseStatus" : ' + false  + ',"unableToLocatePolicy" :' + true + '}';
            }
        }
        catch(ExternalService.PolicyRetrievalAPI.RetrievePolicyAmmUsingGET_ResponseException e){
            LoggingService.logHandledException(e, 'DVComparison', 'callDVServices', LoggingLevel.ERROR);
            //throw new RetrievePolicyAmmUsingGET_ResponseException('Error: '+ e.responseCode + ' -> ' + e.getMessage());
            compResults = '{ "responseStatus" : ' + false  + ',"unableToLocatePolicy" :' + true + '}';
        }
        
        return compResults;
    }
    

}