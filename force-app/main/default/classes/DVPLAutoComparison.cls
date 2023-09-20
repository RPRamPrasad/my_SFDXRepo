public with sharing class DVPLAutoComparison {
    
    private static final String NO_PREMIUM_CHANGE = 'The premium did not change at renewal';
    private static final String DATE_FORMAT = 'yyyy-MM-dd';
    // Create a new External Service instance of a PolicyRetrievalAPI class to allow calling the DV API
    private static ExternalService.PolicyRetrievalAPI dvlDetails = new ExternalService.PolicyRetrievalAPI();
        
    // Custom inner class exception use to throw exceptions when DV API call record is not found
    class PolicyNotFoundException extends Exception {}
    
    class RetrievePolicyAmmUsingGET_ResponseException extends Exception {}
//Process PL Auto 
//@auraEnabled
public static String processPLAuto(ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response resp1, ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Request inputReq){
    String compResults;
    Integer dvCallCount = 0;
    DateTime startDateTime = resp1.Code200.policy.termVersion.fullTermStartDate;
    
                        DateTime endDateTime = resp1.Code200.policy.termVersion.fullTermEndDate;
                    
                        if(resp1.Code200.policy.policyStatusText == 'In Force'){
                            inputReq.asOfDate = endDateTime.addDays(2).format(DATE_FORMAT);
                            try{
                                dvCallCount += 1;
                                ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response resp2 = dvlDetails.retrievePolicyAmmUsingGET(inputReq);
                                if(resp2 != null && resp2.Code200.policy.policyStatusText != null && dvCallCount == 1){
                                    compResults = responsePLAuto(resp1,resp2);
                                } 
                            }catch(ExternalService.PolicyRetrievalAPI.RetrievePolicyAmmUsingGET_ResponseException e){
                                dvCallCount += 1;
                                inputReq.asOfDate = startDateTime.addDays(-2).format(DATE_FORMAT);
                                ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response resp3 = dvlDetails.retrievePolicyAmmUsingGET(inputReq);
                                if(resp3 != null && resp3.Code200.policy.policyStatusText != null){
                                    compResults = responsePLAuto(resp3,resp1);
                                } else {
                                    compResults = '{ "responseStatus" : ' + false  + ',"unableToLocatePolicy" :' + true + ',"isPLAuto" :' + true  +  '}';            
                                }
                            }
                        }else{
                            compResults = '{ "responseStatus" : ' + false  + ',"unableToLocatePolicy" :' + true + ',"isPLAuto" :' + true  +  '}';
                        }
    return compResults;
}
//JSON Response model
//Used to compare the two reponses from the DV API calls
    //@param resp1 - response from first DV API call
    //@param resp2 - response from second DV API call
    //
    //@return - a list of all changes from the comparision between the two API calls
    private static String responsePLAuto(ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response resp1, ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response resp2){
        List<Object> vehicleList= new List<Object>();
        Integer compCar = 0;
        String premChange = '';
        String vehStateCode = resp1.Code200.policy.stateFarmStateCode;
        
        for(Integer i=0;i<resp1.Code200.policy.termVersion.insurableRisk.size();i++){
            List<Object> showVehicleNameList = new List<Object>();
            List<Object> showRatingChangedList = new List<Object>();
            List<Object> showDiscountRemovedList= new List<Object>();
            List<Object> showDiscountChangedList= new List<Object>();
            List<Object> showAnnualMileageChangedList= new List<Object>();
            List<Object> showpremiumchangeStatementList= new List<Object>();
    
            String vehicleStr = DVComparisonHelper.findMatchingVehicle(resp1.Code200.policy.termVersion.insurableRisk[i],resp2.Code200.policy.termVersion);

            if(vehicleStr != ''){
                compCar = Integer.valueOf(vehicleStr.substring(0, 1));
               // responseList.add(vehicleStr.substring(1));
                showVehicleNameList.add(vehicleStr.substring(1));
            }else{
                compCar = i;
            }
                showVehicleNameList.add(resp1.Code200.policy.termVersion.insurableRisk[i].vehicle[0].modelYearNumber + ' ' + resp1.Code200.policy.termVersion.insurableRisk[i].vehicle[0].makeName + ' ' + resp1.Code200.policy.termVersion.insurableRisk[i].vehicle[0].modelName);
            
            showRatingChangedList.addAll(DVComparisonHelper.compareVehicles(resp1.Code200.policy.termVersion.insurableRisk[i].vehicle[0],resp2.Code200.policy.termVersion.insurableRisk[compCar].vehicle[0]));

            String criChange = DVComparisonHelper.compareCRI(resp1.Code200.policy.termVersion.insurableRisk[i].customerRatingIndex.customerRatingIndexCapCount,resp2.Code200.policy.termVersion.insurableRisk[compCar].customerRatingIndex.customerRatingIndexCapCount);
           // responseList.add(criChange);
            if (criChange != ''){
                showRatingChangedList.add(criChange);
            }
            
            //for discount removed items/list
            showDiscountRemovedList = DVDiscountComparison.findDiscountsRemoved(resp1.Code200.policy.termVersion.insurableRisk[i].pricingRuleSet,resp2.Code200.policy.termVersion.insurableRisk[compCar].pricingRuleSet);
            //for discount changed items/list
            showDiscountChangedList = DVDiscountComparison.findDiscountsChanged(resp1.Code200.policy.termVersion.insurableRisk[i],resp2.Code200.policy.termVersion.insurableRisk[compCar]);
         
            String strDSSI = DVComparisonDSSIHelper.displayDSSIVerbiage(resp1.Code200.policy.termVersion.insurableRisk[i].vehicle[0],resp2.Code200.policy.termVersion.insurableRisk[compCar].vehicle[0]);

            showAnnualMileageChangedList.addAll(DVComparisonHelper.compareAnnualMileageOfVehicles(resp1.Code200.policy.termVersion.insurableRisk[i].vehicle[0],resp2.Code200.policy.termVersion.insurableRisk[compCar].vehicle[0]));
            premChange = DVComparisonHelper.findPremChange(resp1.Code200.policy.termVersion.insurableRisk[i].totalRiskPremiumAmount,resp2.Code200.policy.termVersion.insurableRisk[compCar].totalRiskPremiumAmount,'A');

            if(premChange != NO_PREMIUM_CHANGE){
                showpremiumchangeStatementList.add(premChange);
            }else{
                showRatingChangedList.clear();
                showDiscountRemovedList.clear();
                showDiscountChangedList.clear();
                showAnnualMileageChangedList.clear();
                showpremiumchangeStatementList.clear();
            }

            DVPremiumChangeResponse objVehicle = new DVPremiumChangeResponse();
            objVehicle.vehicleName = showVehicleNameList;
            objVehicle.ratingChanges = showRatingChangedList;
            objVehicle.setDiscRemoved(showDiscountRemovedList);
            objVehicle.setDiscChanged(showDiscountChangedList);
            objVehicle.mileageChanged = showAnnualMileageChangedList;
            objVehicle.premiumChangeStatement = showpremiumchangeStatementList;
            objVehicle.setDSS(strDSSI);
            objVehicle.setStateDSSMessage(vehStateCode);
            objVehicle.noPremiumChange = (showpremiumchangeStatementList.size()>0)?false : true;
            vehicleList.add(objVehicle);
        }

        String finalResponse = '{ "premiumChangeResponse" :' + JSON.serialize(vehicleList) + ',"responseStatus" : ' + true + ',"isPLAuto" :' + true  +  ',"unableToLocatePolicy" :' + false + '}';
        
        return finalResponse;
    }


}
