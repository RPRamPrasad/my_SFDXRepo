/**
 * @description SR_MatchingTierUtil
 */
public without sharing class SR_MatchingTierUtil {

    @TestVisible public boolean mockOwnerIsAMatch = false;
	/**
     * @description hasNoPolicyId
     * @param payload 
     * @param caseRecord 
     * @return  `boolean`
     */
    public boolean hasNoPolicyId(SR_Payload payload, Case caseRecord) {
        return String.isBlank(payload.matchParams.policyId) || String.isBlank(caseRecord.Policy_Identifier__c);
    }
    /**
     * @description isPolicyIdAMatch
     * @param payload 
     * @param caseRecord 
     * @return  `boolean`
     */
    public boolean isPolicyIdAMatch(SR_Payload payload, Case caseRecord){
        return (payload.matchParams.policyId == caseRecord.Policy_Identifier__c);
    }
/**
 * @description isVehicleIdAMatch
 * @param payload 
 * @param caseRecord 
 * @return  `boolean`
 */
    public boolean isVehicleIdAMatch(SR_Payload payload, Case caseRecord){
        return (payload.matchParams.vehicleId == caseRecord.Vehicle_Identifier__c);
    }
    /**
     * @description isPolicyDescAMatch
     * @param payload 
     * @param caseRecord 
     * @return  `boolean`
     */
    public boolean isPolicyDescAMatch(SR_Payload payload, Case caseRecord){
        return (payload.matchParams.policyDescription == caseRecord.ProductDescription__c);
    }
    /**
     * @description isPolicyDescAMatchOnFirstTwoWords
     * @param payload 
     * @param caseRecord 
     * @return  `boolean`
     */
    public boolean isPolicyDescAMatchOnFirstTwoWords(SR_Payload payload, Case caseRecord){
        boolean isMatch = false;
        if(String.isNotBlank(caseRecord.ProductDescription__c) && String.isNotBlank(payload.matchParams.policyDescription)){
            String trimmedPolicyDesc = getFirstTwoWords(payload.matchParams.policyDescription);
            String caseProductDescription = caseRecord.ProductDescription__c.toUpperCase();
            isMatch = caseProductDescription.contains(trimmedPolicyDesc);
        }
        return isMatch;
    }

    @TestVisible
    private String getFirstTwoWords(String policyDescription){
        String trimmedPolicyDesc = policyDescription.trim().toUpperCase();
        List<String> descSplit = trimmedPolicyDesc.split(' ', 4);
        if(descSplit.size() >= 2){
           return descSplit.get(0) + ' ' +  descSplit.get(1); 
        }else{
           return trimmedPolicyDesc;
        }
    }
    /**
     * @description ownerIsAMatch
     * @param payload 
     * @param caseRecord 
     * @return  `boolean`
     */
    public boolean ownerIsAMatch(SR_Payload payload, Case caseRecord){
        boolean ownerIsAMatch = (payload.matchParams.ownerAssociateId == caseRecord.Owner_User_External_Id__c);
        if(Test.isRunningTest() && mockOwnerIsAMatch){
            return true;
        }
        return ownerIsAMatch;
    }
    /**
     * @description recordTypeIsAMatch
     * @param payload 
     * @param caseRecord 
     * @return  `boolean`
     */
    public boolean recordTypeIsAMatch(SR_Payload payload, Case caseRecord){
        return (Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(payload.matchParams.recordTypeName).getRecordTypeId() == caseRecord.RecordTypeId);
    }
    
}