/**
 * @description class for Opportunity_COAProcessor
 */
public with sharing class Opportunity_COAProcessor {
    /**
    *  @description function to get the formulated state code
    *  @name  getStateCodeFromNewAgentOffice
    *  @param name
    *  @return FormattedStateValue
    */
    public static String getStateCodeFromNewAgentOffice(String name){
        List<String> splitOnCommas = name.split(',');
        String stateValueWithAgentCode = splitOnCommas[2].substring(0,8);
        String stateValue = splitOnCommas[2].substring(0,3).trim();
        return getStateCodeValue(stateValue, stateValueWithAgentCode);
    }
    /**
    *  @description function to get the formulated state code
    *  @name  getStateCodeValue
    *  @param stateCode
    *  @param stateAndOfficeCode
    *  @return FormattedStateValue
     */
    private static String getStateCodeValue(String stateCode,String stateAndOfficeCode){
        Set<String> abbreVationSet= new Set<String>{stateCode};
        Map<String, String> stateValueSet = LWC_NewOpportunityWorkflow.getStateAbbreviations(abbreVationSet);
        String stateValueFromAbbrevation='';
        for (String state : stateValueSet.keySet()) {
            stateValueFromAbbrevation=stateValueSet.get(state);
        }
        return stateValueFromAbbrevation + ' / '+stateAndOfficeCode;
    }

    /**
    *  @description function to get the formulated state code
    *  @name  getStateCodeBasedOnStateCode
    *  @param stateAndOfficeCode
    *  @return FormattedStateValue
     */
    public static String getStateCodeBasedOnStateCode(String stateAndOfficeCode){
        String stateValue = stateAndOfficeCode.split('-')[0].trim();   
        return getStateCodeValue(stateValue, stateAndOfficeCode);
    }

    /**
    *  @description function to get the formulated state code
    *  @name  validateSAndMStcodeAssignStateCode
    *  @param approriateOpportunitiesWrapper
    *  @param newOrUpdatedStateCodeValue
    *  @param oppStatecode
    *  @return FormattedStateValue
    */
    public static String validateSAndMStcodeAssignStateCode(UTIL_ChangeofAgentProcessor.ReassignOpportunitiesWrapperList approriateOpportunitiesWrapper,String newOrUpdatedStateCodeValue,String oppStatecode){
        String stateCodeAgentListValue = approriateOpportunitiesWrapper.stateAgentCodeListString;
        List<String> stateCodeList = stateCodeAgentListValue.split(',');
        String updatedStateCodeValue='';
        if(stateCodeList.size()>1 ){
            if(oppStatecode !=null){ 
                updatedStateCodeValue=validateMASingleAgent(stateCodeList,approriateOpportunitiesWrapper, oppStatecode);
            }
        }
        else{
            updatedStateCodeValue= newOrUpdatedStateCodeValue;
        }
        return updatedStateCodeValue;
    }
    /**
    *  @description function to get the formulated state code
    *  @name  validateMASingleAgent
    *  @param stateCodeList
    *  @param approriateOpportunitiesWrapper
    *  @param oppStatecode
    *  @return FormattedStateValue
     */
    private static String validateMASingleAgent(List<String> stateCodeList,UTIL_ChangeofAgentProcessor.ReassignOpportunitiesWrapperList approriateOpportunitiesWrapper,String oppStatecode){
        Boolean isMultiOfficeAgent =true;
        String oppState = oppStatecode.split('/')[1].trim().substring(0,2).trim();
        String updatedStateCodeValue = '';
       
            for(String stateCodeValue:stateCodeList){
                List<String> splitOnHyphen = stateCodeValue.split('-');
                String stateValue = splitOnHyphen[0].trim();
                if(!stateValue.equalsIgnoreCase(oppState)){
                    isMultiOfficeAgent=false;
                }
            }
            if(isMultiOfficeAgent){
                updatedStateCodeValue= getStateCodeBasedOnStateCode(approriateOpportunitiesWrapper.stateAgentCode); 
            }
            else{
                for(String stateCodeValue:stateCodeList){
                    List<String> splitOnHyphen = stateCodeValue.split('-');
                    String stateValue = splitOnHyphen[0].trim();
                    if(stateValue.equalsIgnoreCase(oppState)){
                        updatedStateCodeValue= getStateCodeValue(stateValue, stateCodeValue);
                        break;
                    }
                }
            }
        return updatedStateCodeValue;
    }
}