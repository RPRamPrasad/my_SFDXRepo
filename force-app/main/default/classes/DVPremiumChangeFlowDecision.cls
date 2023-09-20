public with sharing class DVPremiumChangeFlowDecision {
    
    private static final List<String> AUTO_PL_POLICYNAME = new String[] {'PRIVATE PASSENGER','PRIVATE','MOTORHOME','MOTORCYCLE','UTILITY TRAILER','GOLFMOBILE','MULTIPLE VEHICLE'};
    private static final List<String> FIRE_PL_POLICYNAME = new String[] {'HOMEOWNERS SPECIAL FORM POLICY','HOMEOWNERS POLICY','CONDOMINIUM UNITOWNERS POLICY','PERSONAL ARTICLES POLICY','PERSONAL LIABILITY UMBRELLA POLICY','PREMISES/ PERSONAL LIABILITY POLICY','MANUFACTURED HOME POLICY','BOATOWNERS POLICY','MANUFACTURED HOME SPECIAL FORM POLICY','RENTERS POLICY'};
    private static final List<String> AUTO_BL_POLICYNAME = new String[] {'COMMERCIAL','PRIVATE PASSENGER','PRIVATE','CHURCH BUS','FLEET','MULTIPLE VEHICLE'};
    private static final List<String> FIRE_BL_POLICYNAME = new String[] {'WORKERS COMPENSATION POLICY','COMMERCIAL LIABILITY UMBRELLA POLICY','BUSINESSOWNERS','WORKERS COMPENSATION POLICY','COMMERCIAL LIABILITY UMBRELLA POLICY','BUSINESSOWNERS','INLAND MARINE POLICY', 'APARTMENT POLICY','RELIGIOUS ORGANIZATION POLICY','CONTRACTORS POLICY','ARTISAN AND SERVICE CONTRACTOR POLICY',
        'OFFICE POLICY','MEDICAL OFFICE POLICY','HOME PRODUCT SALES POLICY','COMMERCIAL',
        'ANIMAL CARE SERVICES','ANIMAL CARE SERVICES POLICY','APARTMENT POLICY','AUTO SERVICES','AUTO SERVICES POLICY',
        'BUSINESS - MERCANTILE / SERVICE POLICY','BUSINESS - OFFICE POLICY','BUSINESS SERVICES POLICY','BUSINESSOWNERS',
        'BUSINESSOWNERS POLICY','DISTRIBUTORS','DISTRIBUTORS POLICY','DRUG STORE','DRUG STORE POLICY',
        'DRY CLEANING AND LAUNDERING SERVICES','DRY CLEANING AND LAUNDERING SERVICES POLICY','FLORIST',
        'FLORIST POLICY','FOOD SHOP','FOOD SHOP POLICY','GROCERY STORE','GROCERY STORE POLICY','HAIR SALON',
        'DAY SPA AND BARBER','DAY SPA AND BARBER POLICY','HOME PRODUCT SALES','HOME PRODUCT SALES POLICY',
        'MEDICAL OFFICE','MEDICAL OFFICE POLICY','RESTAURANT','RESTAURANT POLICY','RETAIL SALES','RETAIL SALES POLICY'};

    // Used to get lob, risk primary use code, agreement source code for validating and also returning appropriate Flow Code.
    public static String determinePremiumChangeFlowAndMessage(ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response policyResponse){
        
        ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response initPolicyResponse = new ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response();

        
        String returnMessage = 'unableToLocatePolicy';

        initPolicyResponse = policyResponse;

        String policyBusinessLineCode = initPolicyResponse.Code200.policy.businessLineCode;
        String policyProductDescriptionText = initPolicyResponse.Code200.policy.productDescriptionText;

       // Integer policyAgreSourceSystemCode = initPolicyResponse.Code200.policy.agreSourceSystemCode;
        
       if(policyBusinessLineCode.toUpperCase() =='F') {
        if(FIRE_PL_POLICYNAME.contains(policyProductDescriptionText.toUpperCase()) ){
            returnMessage = 'PLFire';
        } else if(policyBusinessLineCode.toUpperCase() =='F' && FIRE_BL_POLICYNAME.contains(policyProductDescriptionText.toUpperCase()) ){
            returnMessage = 'BLFire';
        }
       } else if(policyBusinessLineCode.toUpperCase() =='A') {
            String policyRiskUseCode = initPolicyResponse.Code200.policy.termVersion.insurableRisk[0].riskPrimaryUseCode;
            if(isPersonalLines(policyProductDescriptionText,policyRiskUseCode) ){
                returnMessage = 'PLAuto';
            } else if(policyBusinessLineCode.toUpperCase() =='A' && isBusinessLines(policyProductDescriptionText,policyRiskUseCode)  ){
                returnMessage = 'BLAuto';
            }
       }

        return returnMessage;
    }

    //This method will take first response from DV and request obect and based on LOB logic will call appropriate LOB process methods.
    public static String processLineOfBusiness(ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Response resp1, ExternalService.PolicyRetrievalAPI.retrievePolicyAmmUsingGET_Request inputReq){
            String responseFromLOB;
            String strFlowValidationCheck = 'unableToLocatePolicy';

            strFlowValidationCheck = determinePremiumChangeFlowAndMessage(resp1);
            
                if (strFlowValidationCheck != 'unableToLocatePolicy' && strFlowValidationCheck != '') {
                    if (strFlowValidationCheck == 'PLAuto') {
                        responseFromLOB = DVPLAutoComparison.processPLAuto(resp1,inputReq);
                    } else if (strFlowValidationCheck == 'PLFire') {
                        //Repeat similar logic of reading term dates, make DV call with term end date + 1 day, if that fails or does not return then make one more DV call with term start date - 1 day (previous term)
                        responseFromLOB = DVFireComparison.processPLFire(resp1,inputReq);
                        //compResults = '{ "responseStatus" : ' + false  + ',"responseStatusCode" :' + 400 + ',"unableToLocatePolicy" :' + true + ',"isPLFire" :' + true  + ',"flowName" : "' + strFlowValidationCheck +   '"}';
                    } else if (strFlowValidationCheck == 'BLFire') {
                        responseFromLOB = '{ "responseStatus" : ' + true  + ',"unableToLocatePolicy" :' + true + ',"isBLFire" :' + true  +  '}';
                    } else if (strFlowValidationCheck == 'BLAuto'){
                        responseFromLOB = DVBLAutoComparison.processBLAuto(resp1,inputReq);
                    } else {
                        responseFromLOB = '{ "responseStatus" : ' + false  + ',"unableToLocatePolicy" :' + true + '}';
                    }
                } else {
                    responseFromLOB = '{ "responseStatus" : ' + false  + ',"unableToLocatePolicy" :' + true + '}';
                }

            return responseFromLOB;
    }

    private static Boolean isPersonalLines(String policyDescription, String riskUsecode) {

        Boolean plLines = false;

        if (AUTO_PL_POLICYNAME.contains(policyDescription.toUpperCase()) && ( riskUsecode != null && (riskUsecode != '09' && riskUsecode != '9' && riskUsecode != '10'))){
            plLines = true;
        }
        return plLines;

    }

    private static Boolean isBusinessLines(String policyDescription, String riskUsecode) {

        Boolean blLines = false;

        if (AUTO_BL_POLICYNAME.contains(policyDescription.toUpperCase()) && ( riskUsecode != null && (riskUsecode == '09' || riskUsecode == '9' || riskUsecode == '10'))){
            blLines = true;
        }
        return blLines;

    }


}