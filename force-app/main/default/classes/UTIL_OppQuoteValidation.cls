/**
 * @description UTIL_OppQuoteValidation Description
 * Team: Optimizers
 */
public with sharing class UTIL_OppQuoteValidation {
    static final String CLASS_NAME = 'UTIL_OppQuoteValidation';
    private static final List<String> NONHEALTHLOBLIST = new String[] {'Bank', 'Investments', 'Life','Auto','Fire'};
    private static String isQuoteCanvasable = 'false';
    private static final List<String> HEALTHPRODLISTSTOPQUOTING = new String[] {'Disability Income - Attained Age', 'Disability Income - Issue Age', 'Short-Term Disability Income'};
    private static String isProductSellable = 'Yes';
    private static String isProductValid ='No';
    public  static OpportunityProduct__c oppProduct;
    private static final List<String> LOBLIST = new String[] {'Bank', 'Investments', 'Life'};
    private static final String PSN_EFFECTIVEDATE_ERROR_MSG='Please validate the choices below.';
    private static final String PRODUCT_INVALID_ERROR_MSG='The Line of Business, Effective Date and Product combination is not valid. Please validate the choices below.';
    private static final String SUCCESS = 'success';
    private static final String FAILURE = 'failure';
    private static String userStateValue = '';
    private static String stateAgentCode = '';
    private static final String QUOTE_IN_PROGRESS_STATUS = 'Quote In Progress';
    private static final List<String> EXCLUDE_STATUS_NAMES = new String[] {'Quote Provided', 'Application Pending'};

    /**
     * @description getResponseMapOnQuoteValidation
     * validateIsQuotingApplicable This method throws an error if PSN is empty and if not then it will invoke
     * effectivedate validation
     * @param opp (Opportunity):  Object}
     * @return Map<String,String> : Return response list
     */
    public static Map<String,String> getResponseMapOnQuoteValidation(Opportunity opp){
        setStateCodeValue(opp);
        Map<String,String> responseMap = !String.isBlank(opp.Product_system_name__c)? updateOppOnLobOrNavToProdValidation(opp):errorRespWhenPSNEmpty(opp);
        return responseMap;
    }
 
    private static Map<String,String> errorRespWhenPSNEmpty(Opportunity opp){
        if(!String.isBlank(opp.Product__c) && !String.isBlank(opp.State_code__c)){
            // In this scenario we are just setting the value if Product is Valid
             oppProduct =retrieveOppProductIfValid(opp);
            if(oppProduct == null){
                getProductDetails(opp);
            } 
         }
        return sendErrorOrSuccessResponse(PSN_EFFECTIVEDATE_ERROR_MSG,FAILURE,opp);
    }

    private static Map<String,String> updateOppOnLobOrNavToProdValidation(Opportunity opp){
        if(LOBLIST.contains(opp.LOB__c)){
            Opportunity updateOpp = new Opportunity();
            updateOpp.id=opp.id;
            updateOpp.Requested_Effective_Date__c = Date.today();
            update Security.stripInaccessible(AccessType.UPDATABLE, new List<Opportunity>{updateOpp}).getRecords();
            oppProduct = getProductDetails(opp);
            Map<String,String> responseMap = new  Map<String,String>(); 
            responseMap =  sendErrorOrSuccessResponse(SUCCESS,SUCCESS,opp);
            return responseMap;
        }
        else{
            return sendRespOnEffDateAndProductValidation(opp);
        }
    }

    private static Map<String,String> sendRespOnEffDateAndProductValidation(Opportunity opp){
            buildOppProductRequest(opp);
            oppProduct = getProductDetails(opp);
        	
            if(oppProduct != null){
                if(isEffectivdateInValidDateRange(opp)){
                   return validateAndFetchProductInfo(opp) != null?sendErrorOrSuccessResponse(SUCCESS,SUCCESS,opp):sendErrorOrSuccessResponse(PSN_EFFECTIVEDATE_ERROR_MSG,FAILURE,opp);
                }
                else{
                    sendErrorOrSuccessResponse(PSN_EFFECTIVEDATE_ERROR_MSG,FAILURE,opp);
                }
            }
            return sendErrorRespOnProdValidation(opp);
    }

    private static Map<String,String> sendErrorRespOnProdValidation(Opportunity opp){
        return sendErrorOrSuccessResponse(PRODUCT_INVALID_ERROR_MSG,FAILURE,opp);
    }

    private static Boolean isEffectivdateInValidDateRange(Opportunity opp){
        Date currentDate = Date.today();
        Decimal errorPastDays = oppProduct.ErrorPastDays__c;
        Decimal errorFutureDays  = oppProduct.ErrorFutureDays__c; 
        Boolean isPastDaysValid = true;
        if(errorPastDays != null){
            Date errorPastDate = currentDate.addDays(-(errorPastDays.intValue()));
            isPastDaysValid =  (opp.Requested_Effective_Date__c >= errorPastDate);
        }
        Boolean isFutureDaysValid = true;
        if(errorFutureDays != null){
            Date errorFutureDate = currentDate.addDays((oppProduct.ErrorFutureDays__c.intValue()));
            isFutureDaysValid = (opp.Requested_Effective_Date__c <= errorFutureDate);
        }
        if(!isFutureDaysValid || !isPastDaysValid){
            return false;
        }
        return true;  
    }

   private static OpportunityProduct__c retrieveOppProductIfValid(Opportunity opp){
        OpportunityProduct__c oppProductValid = validateAndFetchProductInfo(opp);
        if(oppProductValid != null){
            isProductValid = 'Yes';
        }
        return oppProductValid;
   }
 
    private static OpportunityProduct__c validateAndFetchProductInfo(Opportunity opp){
        OpportunityProductValidation.OpportunityDetails oppDetails = buildOppProductRequest(opp);
        oppProduct = OpportunityProductValidation.validateOpportunityProduct(oppDetails);
        return oppProduct;
    }
 
    private static OpportunityProductValidation.OpportunityDetails buildOppProductRequest(Opportunity opp){
        OpportunityProductValidation.OpportunityDetails oppDetails = new OpportunityProductValidation.OpportunityDetails();
        oppDetails.lob=opp.lob__c;
        oppDetails.productDescription = opp.product__c;
        oppDetails.stateCode = userStateValue;
        oppDetails.effectiveDate = opp.Requested_Effective_Date__c;
        oppDetails.productSystemName=opp.Product_System_Name__c;
        return oppDetails;
    }
 
    private static OpportunityProduct__c getProductDetails(Opportunity opp){
        OpportunityProductValidation.OpportunityDetails oppDetails =  buildOppProductRequest(opp);
        oppProduct = OpportunityProductValidation.getProductInformation(oppDetails);
        if(oppProduct == null){
            isProductSellable = 'No';
        }
        return oppProduct;
    }

    private static Map<String,String> sendResponseMapOnProductError(Opportunity opp){
        getProductDetails(opp);
        return sendErrorOrSuccessResponse(PRODUCT_INVALID_ERROR_MSG,FAILURE,opp);
    }
 
    private static Map<String,String> sendErrorOrSuccessResponse(String error,String respStatus,Opportunity opp){
       Map<String,String> responseMap = new Map<String,String>();
        responseMap.put('status',respStatus);
        responseMap.put('errorInfo',error);
        responseMap.put('isQuoteCanvasable',String.valueOf(opp.IsQuoteCanvasable__c));
        responseMap.put('lob',opp.lob__c);
        responseMap.put('accountId',opp.AccountId);
        responseMap.put('product',opp.product__c);
        responseMap.put('effectiveDate',String.valueOf(opp.Requested_Effective_Date__c));
        responseMap.put('isProductEditable',(!String.isBlank(opp.Product_system_name__c)?'false':'true'));
        responseMap.put('ProductObjectInfo',JSON.serialize(oppProduct));
        responseMap.put('userState',opp.State_Code__c);
        responseMap.put('isProductSellable',isProductSellable);
        responseMap.put('stageName',opp.stageName);
        responseMap.put('oppStatus',opp.status__c);
        responseMap.put('isProductValid',isProductValid);
        responseMap.put('userStateValue',userStateValue);
        responseMap.put('stateAgentCode',stateAgentCode);
        responseMap.put('productSystemName',opp.Product_System_Name__c);
        responseMap.put('isHealthSourced',String.valueOf(opp.Account.IsHealthSourced__pc));
        return responseMap;
    }

    /**
     * @description validateAndReturnHealthSource
     * @param opp 
     * @return  `String`
     */
    public static String validateAndReturnHealthSource(Opportunity opp){
        // Check for the phifield
        if (opp.Account.IsHealthSourced__pc) {
            if (NONHEALTHLOBLIST.contains(opp.lob__c)) {
                return 'Yes';
            } else if ('Health'.equals(opp.lob__c) && HEALTHPRODLISTSTOPQUOTING.contains(opp.product__c)) {
                return 'Yes';
            }
        }
        return 'No';
    }

    /**
     * @description updateOpportunity
     * @param updateOpp 
     * @return  `String`
     */
    public static String updateOpportunity(Opportunity updateOpp) { 
        Opportunity opp = new Opportunity();
        opp.id = updateOpp.Id;
        String oppUpdated = 'Success';
        opp.stageName= 'Quoting';
        try{
            if(!EXCLUDE_STATUS_NAMES.contains(updateOpp.status__c))
            {
                opp.status__c = QUOTE_IN_PROGRESS_STATUS;
            }
            update Security.stripInaccessible(AccessType.UPDATABLE, new List<Opportunity>{opp}).getRecords(); 
            oppUpdated = 'Success';
        }
        catch(Exception e){
            LoggingService.logHandledException(e, CLASS_NAME, 'updateOpportunity',System.LoggingLevel.ERROR);
            oppUpdated = 'Failure';
        }
        return oppUpdated;
    }

    /**
     * @description newAppQuoteUrl
     * @param opp 
     * @param oppProd 
     * @param profileName 
     * @return  `Static String`
     */
    public Static String newAppQuoteUrl(Opportunity opp,OpportunityProduct__c oppProd,  String profileName){
        if(opp.isQuoteCanvasable__c){
            return 'QuoteIsCanvasable';
        }
        else{
            return HLPR_OppButtonNavController.newAppQuoteUrl(opp,oppProd,profileName);
        }
    }
    private static void setStateCodeValue(Opportunity opp){
        if(!String.isBlank(opp.State_Code__c)){
            List<String> stateCodeList = opp.State_Code__c.split('/');
            userStateValue = stateCodeList.get(0).trim();
            stateAgentCode = stateCodeList.get(1).trim();
        }
    }
}
