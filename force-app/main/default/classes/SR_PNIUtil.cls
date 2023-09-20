/**
* @author Baby Yoda
* @name SR_PNIUtil
* @date Created 02/10/2021
* @description SR_PNIUtil utility class. This class will help to identify Primary Named Insured Account in AgreementPartyRole__c & AgreementRisk__c 
*/
public without sharing class SR_PNIUtil {
    /**
     * @param payload
     * @return boolean
     * @description validation method
     */
    public Boolean isValidForPNI(SR_Payload payload){
        return (payload != null && (isValidAutoPayload(payload) || isValidFirePayload(payload)) && String.isNotEmpty(payload.matchParams.clientId));
    }
    
    /**
     * @param payload
     * @return boolean
     * @description determines if payload is valid auto
     */
    public Boolean isValidAutoPayload(SR_Payload payload){
        return (isValidLOB('Auto', payload) && (isValidAppCode(SR_Constants.CASE_APP_CODE_AUTO_CHANGE_AND_SERVICE, payload) || isValidAppCode(SR_Constants.CASE_APP_CODE_AUTO_PVC, payload) || isValidAppCode(SR_Constants.CASE_APP_CODE_LIFECYCLE, payload)));
    }
    
    /**
     * @param payload
     * @return boolean
     * @description determines if payload is valid fire
     */
    public Boolean isValidFirePayload(SR_Payload payload){
        return isValidLOB('Fire', payload) && (isValidAppCode(SR_Constants.CASE_APP_CODE_FIRE_PVC, payload) || isValidAppCode(SR_Constants.CASE_APP_CODE_LIFECYCLE, payload)) && payload.matchParams != null  && String.isNotEmpty(payload.matchParams.policyId);
    }
    
    /**
     * @param lob
     * @param payload
     * @return boolean
     * @description validation method for lob
     */
    @TestVisible
    private Boolean isValidLOB(String lob, SR_Payload payload){
        return hasLOB(payload) && payload.caseRecord.LOB__c.equals(lob);
    }
    
    @TestVisible
    private Boolean isValidAppCode(String appCode, SR_Payload payload){
        return hasAppCode(payload) && payload.caseRecord.App_Code__c.equals(appCode);
    }

    @TestVisible
    private Boolean hasCase(SR_Payload payload){
        return payload.caseRecord != null;
    }
    
    @TestVisible
    private Boolean hasAppCode(SR_Payload payload){
        return hasCase(payload) && payload.caseRecord.App_Code__c != null;
    }
    
    @TestVisible
    private Boolean hasLOB(SR_Payload payload){
        return hasCase(payload) && payload.caseRecord.LOB__C != null;
    }
    /**
     * @description isUnitTest
     * @return  `Boolean`
     */
    @TestVisible
    public Boolean isUnitTest(){
        return (Test.isRunningTest() && UnitTestDataUtility.isUnitTest);
    }
}