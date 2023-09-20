/**
 * @description SR_MatchingRulesUtil
 */
public without sharing class SR_MatchingRulesUtil {  
    /**
     * @description isTier1Payload
     * @param payload 
     * @return  `boolean`
     */  
    @TestVisible
    public static boolean isTier1Payload(SR_Payload payload){
        return payload.matchParams.caseId != null && String.isNotEmpty(payload.matchParams.caseId); 
    }
    /**
     * @description isTier2Payload
     * @param payload 
     * @return  `boolean`
     */
    @TestVisible
    public static boolean isTier2Payload(SR_Payload payload){
        return payload.matchParams.policyId != null && String.isNotEmpty(payload.matchParams.policyId) && payload.matchParams.vehicleId != null && String.isNotEmpty(payload.matchParams.vehicleId); 
    }
    /**
     * @description isTier3Payload
     * @param payload 
     * @return  `boolean`
     */
    @TestVisible
    public static boolean isTier3Payload(SR_Payload payload){
        return payload.matchParams.policyId != null && String.isNotEmpty(payload.matchParams.policyId);
    }
    /**
     * @description isTier4Payload
     * @param payload 
     * @return  `boolean`
     */
    @TestVisible
    public static boolean isTier4Payload(SR_Payload payload){
        return payload.matchParams.policyDescription != null && String.isNotEmpty(payload.matchParams.policyDescription); 
    }
    /**
     * @description isMultiTierPayload
     * @param payload 
     * @return  `boolean`
     */
	@TestVisible
    public static boolean isMultiTierPayload(SR_Payload payload){
        return isTier3Payload(payload) && isTier4Payload(payload);
    }
}