public with sharing class DVFireComparison {
    
    //private static final String FILTER_STR = 'POLICY,RISK,COVERAGE,PHYOBJCT';
    //private static final String DATA_FILTER_STR = 'CRICUI';
    private static final String NO_PREMIUM_CHANGE = 'The premium did not change at renewal';
    private static final String DATE_FORMAT = 'yyyy-MM-dd';
    
    
    // Create a new External Service instance of a PolicyRetrievalAPI class to allow calling the DV API
    private static ExternalService.PolicyRetrievalAPI dvlDetails = new ExternalService.PolicyRetrievalAPI();
   // private static ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Request req = new ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Request();
    // Custom inner class exception use to throw exceptions when DV API call record is not found
    class PolicyNotFoundException extends Exception {}
    
    class RetrievePolicyAmmUsingGET_ResponseException extends Exception {}

    //class for processing PL Fire payload and produce premium change comparision.
    //@AuraEnabled
    public static String processPLFire(ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response resp1, ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Request inputReq){
        String compResults;

        DateTime startDateTime = resp1.Code200.policy.termVersion.fullTermStartDate;
        DateTime endDateTime = resp1.Code200.policy.termVersion.fullTermEndDate;
        //Date startDate = date.newinstance(startDateTime.year(), startDateTime.month(), startDateTime.day());
        //Date endDate = date.newinstance(endDateTime.year(), endDateTime.month(), endDateTime.day());
        Integer dvCallCount = 0;
        if(resp1.Code200.policy.policyStatusText == 'In Force'){
            inputReq.asOfDate = endDateTime.addDays(2).format(DATE_FORMAT);
                try{
                    dvCallCount += 1;
                    ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response resp2 = dvlDetails.retrievePolicyAmmUsingGET(inputReq);
                    if(resp2 != null && resp2.Code200.policy.policyStatusText != null && dvCallCount == 1){
                        compResults = responsePLFire(resp1,resp2);
                    } 
                }catch(ExternalService.PolicyRetrievalAPI.RetrievePolicyAmmUsingGET_ResponseException e){
                    dvCallCount += 1;
                    inputReq.asOfDate = startDateTime.addDays(-1).format(DATE_FORMAT);
                    ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response resp3 = dvlDetails.retrievePolicyAmmUsingGET(inputReq);
                    if(resp3 != null && resp3.Code200.policy.policyStatusText != null){
                        compResults = responsePLFire(resp3,resp1);
                    } else {
                        compResults = '{ "responseStatus" : ' + false  + ',"unableToLocatePolicy" :' + true + ',"isPLFire" :' + true  +  '}';            
                    }
                }
        }  else {
            compResults = '{ "responseStatus" : ' + false  + ',"unableToLocatePolicy" :' + true + ',"isPLFire" :' + true  +  '}';
        }
        return compResults;
    }

//JSON Response model - PLFire
//Used to compare the two reponses from the DV API calls
    //@param resp1 - response from first DV API call
    //@param resp2 - response from second DV API call
    //
    //@return - a list of all changes from the comparision between the two API calls
    private static String responsePLFire(ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response resp1, ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response resp2){
        //String responseList = '{"PremiumChangeResponse":"}';
        List<Object> locationList= new List<Object>();
        Integer compCar = 0;
        String premChange = '';
        //String vehStateCode = '';
        //vehStateCode = resp1.Code200.policy.stateFarmStateCode;

        for(Integer i=0;i<resp1.Code200.policy.termVersion.insurableRisk.size();i++){
            //List<Object> showVehicleNameList= new List<Object>();
            List<Object> showRatingChangedList= new List<Object>();
            List<Object> showDiscountRemovedList= new List<Object>();
            List<Object> showDiscountChangedList= new List<Object>();
            List<Object> showAnnualMileageChangedList= new List<Object>();
            List<Object> showpremiumchangeStatementList= new List<Object>();
    
            String criChange = DVComparisonHelper.compareCRI(resp1.Code200.policy.termVersion.insurableRisk[i]?.customerRatingIndex?.customerRatingIndexCapCount,resp2.Code200.policy.termVersion.insurableRisk[compCar]?.customerRatingIndex?.customerRatingIndexCapCount);

            if (criChange != ''){
                showRatingChangedList.add(criChange);
            }

                
            String strInflation = '';
            if (resp2.Code200.policy.termVersion.policyCoverageSet.coverage[0]?.inflationAdjustment?.indexValue > resp1.Code200.policy.termVersion.policyCoverageSet.coverage[0]?.inflationAdjustment?.indexValue) {
                strInflation = 'Inflation Coverage Index Increased';
            }
            else if (resp1.Code200.policy.termVersion.policyCoverageSet.coverage[0]?.inflationAdjustment?.indexValue > resp2.Code200.policy.termVersion.policyCoverageSet.coverage[0]?.inflationAdjustment?.indexValue) {
                strInflation = 'Inflation Coverage Index Decreased';
            }
            if (strInflation != ''){
                showRatingChangedList.add(strInflation);
            }

            premChange = DVComparisonHelper.findPremChange(resp1.Code200.policy.termVersion.totalPolicyPremiumAmount,resp2.Code200.policy.termVersion.totalPolicyPremiumAmount,'F');
            //Boolean noPremiumChange = false;

            if(premChange != NO_PREMIUM_CHANGE){
                showpremiumchangeStatementList.add(premChange);
            }else{
                showRatingChangedList.clear();
                showpremiumchangeStatementList.clear();
                //noPremiumChange = true;
            }

            DVPremiumChangeResponse objLocation = new DVPremiumChangeResponse();

            objLocation.vehicleName = null;
            objLocation.ratingChanges = showRatingChangedList;
            objLocation.setDiscRemoved(showDiscountRemovedList);
            objLocation.setDiscChanged(showDiscountChangedList);
            objLocation.mileageChanged = showAnnualMileageChangedList;

            objLocation.premiumChangeStatement = showpremiumchangeStatementList;
            objLocation.noPremiumChange = (showpremiumchangeStatementList.size()>0)?false : true;


            locationList.add(objLocation);
        }

        String finalResponse = '{ "premiumChangeResponse" :' + JSON.serialize(locationList) + ',"responseStatus" : ' + true  + ',"unableToLocatePolicy" :' + false + ',"isPLFire" :' + true  +  '}';
        return finalResponse;
    }


}
