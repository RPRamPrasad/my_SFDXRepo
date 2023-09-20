/**
 * @description Validation class for SR_Rest flows
 * @Owner CATs
 */
public without sharing class SR_Validation {
    
    @TestVisible private SR_Payload payload = new SR_Payload();
    @TestVisible private SR_MatchParams matchParams = new SR_MatchParams();
    @TestVisible private static final Integer VALID_POLICY_ID_LENGTH = 20;
    @TestVisible private static final Integer VALID_PRODUCT_DESC_LENGTH = 255;
    /**
     * @description SR_Validation
     * @param payload 
     */
    public SR_Validation(SR_Payload payload){
        this.payload = payload;
        this.matchParams = payload.matchParams;
    }
    /**
     * @description isValidpayload
     * @return  `boolean`
     */
    public boolean isValidPayload() {
        return (this.matchParams != null && hasRequiredFields() && hasSObject() && hasValidMatchingFields() && hasValidRecordType());
    }
    
    @TestVisible
    private boolean hasRequiredFields(){
        return (hasValue(this.matchParams.ownerAssociateId) && hasValue(this.matchParams.clientId) && hasValue(this.matchParams.recordTypeName));
    }
    
    @TestVisible
    private boolean hasValidMatchingFields(){
        // need to figure out if this is used and what is used for
        return (isSalesforceId() && isValidPolicyId() && isValidProductDesc());
    }
    
    @TestVisible
    private boolean isSalesforceId(){
        return (hasEmptyValue(this.matchParams.caseId) || (hasValue(this.matchParams.caseId) && isInstanceOfId(this.matchParams.caseId))) ? true : false;
    }
    
    @TestVisible
    private boolean isInstanceOfId(String caseId){
        return caseId instanceof Id;
    }
    
    @TestVisible
    private boolean isValidPolicyId(){ 
        return (hasEmptyValue(this.matchParams.policyId) || (hasValidPolicyId())) ? true : false;
    }
    
    @TestVisible
    private boolean hasValidPolicyId(){
        return hasValue(this.matchParams.policyId) && (hasValidLength(this.matchParams.policyId, VALID_POLICY_ID_LENGTH));
    }
    
    @TestVisible
    private boolean isValidProductDesc(){
        return (hasEmptyValue(this.matchParams.policyDescription) || (hasValidPolicyDesc())) ? true : false;
    }
    
    @TestVisible
    private boolean hasValidPolicyDesc(){
        return hasValue(this.matchParams.policyDescription) && (hasValidLength(this.matchParams.policyDescription, VALID_PRODUCT_DESC_LENGTH));
    }
    
    @TestVisible
    private boolean hasEmptyValue(String field){
        return String.isEmpty(field);
    }
    
    @TestVisible
    private boolean hasValue(String field){
        return field != null && String.isNotEmpty(field);
    }
    
    @TestVisible
    private boolean hasValidLength(String value, Integer length){
        return value.length() <= length;
    }
    
    @TestVisible
    private boolean hasValidRecordType(){      
        return (Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(this.matchParams.recordTypeName) == null) ? false : true;
    }
    
    @TestVisible
    private boolean hasSObject(){
        return (this.payload.caseRecord != null || this.payload.taskRecord != null || this.payload.logRecord != null || this.payload.defaults != null);
    }
}