/**
 * @author Orca
 * @name SR_InsurancePolicies
 * @description Queries info for primary named insured on fire and auto SR Payloads
 */
public without sharing class SR_InsurancePolicies {

    @TestVisible private SR_Payload payload = new SR_Payload();
    @TestVisible private List<InsurancePolicy> risks = new List<InsurancePolicy>();
    @TestVisible private List<InsurancePolicy> mockRisks = new List<InsurancePolicy>();
    /**
     * @description SR_InsurancePolicies
     * @param payload 
     */
    public SR_InsurancePolicies(SR_Payload payload){
        this.payload = payload;
    }
    /**
     * @description getInsurancePoliciesAuto
     * @return  `List<InsurancePolicy>`
     */
    public List<InsurancePolicy> getInsurancePoliciesAuto(){
        if(String.isNotEmpty(this.payload.matchParams.policyId)){
            getInsurancePoliciesForAutoPolicyId(); 
        }else if(String.isNotEmpty(this.payload.matchParams.policyDescription)){
            getInsurancePoliciesForAutoPolicyDesc();
        }
        return this.risks;
    }
    /**
     * @description getInsurancePoliciesFire
     * @return  `List<InsurancePolicy>`
     */
    public List<InsurancePolicy> getInsurancePoliciesFire(){
        getInsurancePoliciesForFire();
        return this.risks;
    }
    
    @TestVisible
    private void getInsurancePoliciesForAutoPolicyDesc(){
        String productDescription = payload.caseRecord.ProductDescription__c + '%';
        List<InsurancePolicyAsset> ipAssets = Security.stripInaccessible(AccessType.READABLE, [Select Id, InsurancePolicy.Id, InsurancePolicy.NameInsured.ClientIdentifier__c
																	  FROM InsurancePolicyAsset 
																	  WHERE InsurancePolicy.NameInsured.ClientIdentifier__c =: this.payload.matchParams.clientId 
																	  AND AssetName like: productDescription]).getRecords();
        if(!ipAssets.isEmpty()) {
            this.risks.add(ipAssets.get(0).InsurancePolicy);
        } else {
            this.risks = handleParticipantsProductDesc(this.risks, this.payload.matchParams.clientId, payload.caseRecord.ProductDescription__c);
        }
        if(isUnitTest()){
            this.risks = this.mockRisks;
        }
    }
    
    @TestVisible
    private void getInsurancePoliciesForAutoPolicyId(){
        String policyId = payload.matchParams.policyId.replace('-', '') + '%';
		this.risks = Security.stripInaccessible(AccessType.READABLE, [Select Id, NameInsured.ClientIdentifier__c 
																	  FROM InsurancePolicy 
																	  WHERE NameInsured.ClientIdentifier__c =: this.payload.matchParams.clientId 
																	  AND SFDCPolicyNumberSearchKey__c LIKE: policyId]).getRecords();
        if(this.risks.isEmpty()) {
            this.risks = handleParticipantsPolicyId(this.risks, this.payload.matchParams.clientId, policyId);
        }
        if(isUnitTest()){
            this.risks = this.mockRisks;
        }
    }
    
    @TestVisible
    private void getInsurancePoliciesForFire(){
        String policyId = payload.matchParams.policyId.replace('-', '') + '%';
        this.risks = Security.stripInaccessible(AccessType.READABLE, [Select Id, NameInsured.ClientIdentifier__c 
																	  FROM InsurancePolicy 
																	  WHERE NameInsured.ClientIdentifier__c =: this.payload.matchParams.clientId 
																	  AND SFDCPolicyNumberSearchKey__c LIKE: policyId]).getRecords();
        if(this.risks.isEmpty()) {
            this.risks = handleParticipantsPolicyId(this.risks, this.payload.matchParams.clientId, policyId);
        }
        if(isUnitTest()){
            this.risks = this.mockRisks;
        }
    }
    
    @TestVisible
    private List<InsurancePolicy> handleParticipantsPolicyId(List<InsurancePolicy> risks, String clientId, String policyId) {
        List<InsurancePolicyParticipant> ipps = Security.stripInaccessible(AccessType.READABLE, [Select InsurancePolicy.NameInsured.ClientIdentifier__c 
																		  FROM InsurancePolicyParticipant 
																		  WHERE PrimaryParticipantAccount.ClientIdentifier__c =: clientId 
																		  AND InsurancePolicy.SFDCPolicyNumberSearchKey__c LIKE: policyId]).getRecords();
        if(!ipps.isEmpty()) {
            risks.add(ipps.get(0).InsurancePolicy);
        }
        return risks;
    }
    
    @TestVisible
    private List<InsurancePolicy> handleParticipantsProductDesc(List<InsurancePolicy> risks, String clientId, String productDescription) {
        List<InsurancePolicyParticipant> secondaryClientPolicies = Security.stripInaccessible(AccessType.READABLE, [Select InsurancePolicy.NameInsured.ClientIdentifier__c,  
																											   InsurancePolicy.PolicyDescription FROM InsurancePolicyParticipant 
																											 WHERE PrimaryParticipantAccount.ClientIdentifier__c =: clientId]).getRecords();
        for(InsurancePolicyParticipant ipp : secondaryClientPolicies) {
            InsurancePolicy policy = ipp.InsurancePolicy;
            if(policy.PolicyDescription.contains(productDescription)) {
                risks.add(policy);
                break;
            }
        }
        return risks;
    }
    
    @TestVisible
    private Boolean isUnitTest(){
        return (Test.isRunningTest() && UnitTestDataUtility.isUnitTest);
    }
    
}