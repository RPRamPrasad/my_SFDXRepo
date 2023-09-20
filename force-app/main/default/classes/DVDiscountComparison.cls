public with sharing class DVDiscountComparison {
    
    private static FINAL String DISCOUNT_NOT_FOUND = 'no';
 
    //Loops through all discounts on the policy to find if any of the discounts have changed
    //@param initVal - initial policy discounts
    //@param compVal - policy discounts we are comparing against the initial policy
    //
    //@return a list of all discounts that were changed/removed from the policy
    public static List<Object> findDiscountsRemoved(ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution initVal, ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution compVal){
        //  List<Object> responseList = new List<Object>();
          List<Object> discountsRemoved = new List<Object>();
          String matchFound = '';
          
          for (Integer k=0; k < initVal.pricingAdjustment.size();k++){
              String matchName = initVal.pricingAdjustment[k].pricingRuleSetUniqueName;
              // + initVal.pricingAdjustment[k].pricingRuleSetAdjustmentAmount;
              matchFound = 'no';
              for(Integer l=0; l < compVal.pricingAdjustment.size() && matchFound.equals(DISCOUNT_NOT_FOUND);l++){
                  if(matchName.equals(compVal.pricingAdjustment[l].pricingRuleSetUniqueName)){
                      matchFound = 'yes';
                  }
              }
  
              if(matchFound.equals(DISCOUNT_NOT_FOUND)){
                  discountsRemoved.add(initVal.pricingAdjustment[k].pricingRuleSetUniqueName);
              }
          }
          
          return discountsRemoved;
      }
  
  
      //Loops through all discounts on the policy to find if any of the discounts have changed
      //@param initVal - initial policy discounts
      //@param compVal - policy discounts we are comparing against the initial policy
      //
      //@return a list of all discounts that were changed/removed from the policy
      
      public static List<Object> findDiscountsChanged(ExternalService.PolicyRetrievalAPI_InsurableRisk res1, ExternalService.PolicyRetrievalAPI_InsurableRisk res2){
  
          ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution initVal = new ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution();
          ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution compVal = new ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution();
  
          initVal = res1.pricingRuleSet;
          compVal = res2.pricingRuleSet;
  
          //List<Object> responseList = new List<Object>();
          List<String> discountsChanged = new List<String>();
          String matchFound = '';
          Integer discountIdFound1;
          Integer discountIdFound2;
          
          for (Integer k=0; k < initVal.pricingAdjustment.size();k++){
              String matchName = initVal.pricingAdjustment[k].pricingRuleSetUniqueName;
              //+ initVal.pricingAdjustment[k].pricingRuleSetAdjustmentAmount;
              matchFound = 'no';
              for(Integer l=0; l < compVal.pricingAdjustment.size() && matchFound.equals(DISCOUNT_NOT_FOUND);l++){
                  if(matchName.equals(compVal.pricingAdjustment[l].pricingRuleSetUniqueName)){
                    //+ compVal.pricingAdjustment[l].pricingRuleSetAdjustmentAmount
                      matchFound = 'yes';
                      discountIdFound1 = k;
                      discountIdFound2 = l;
                  }
              }
              if(!matchFound.equals(DISCOUNT_NOT_FOUND)){
                  //discountsChanged.add(k + ' discount changed');
                  matchName = initVal.pricingAdjustment[discountIdFound1].pricingRuleSetUniqueName + initVal.pricingAdjustment[discountIdFound1].pricingRuleSetAdjustmentAmount;
                  String compareName = compVal.pricingAdjustment[discountIdFound2].pricingRuleSetUniqueName + compVal.pricingAdjustment[discountIdFound2].pricingRuleSetAdjustmentAmount;
                  if(matchName != compareName){
                        discountsChanged.add(initVal.pricingAdjustment[discountIdFound1].pricingRuleSetUniqueName);
                  } 
              }
          }
                 
          return discountsChanged;
      }
        

}