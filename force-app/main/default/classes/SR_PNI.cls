/**
* @author Baby Yoda
* @name SR_PNI
* @date Created 02/10/2021
* @description SR_PNI utility class. This class will help to identify Primary Named Insured Account
*/

public without sharing class SR_PNI {
    @TestVisible private List<SR_Payload> payloads = new List<SR_Payload>();
    @TestVisible private List<SR_Payload> updatedPayloads = new List<SR_Payload>();
    @TestVisible private SR_Payload payload;
    @TestVisible private List<InsurancePolicy> insurancePolicies = new List<InsurancePolicy>();
    @TestVisible private String mockString;
    @TestVisible SR_PNIUtil util = new SR_PNIUtil();
    @TestVisible SR_InsurancePolicies risks;
    
    /**
     * @param payloads
     * @description construction class 
     */
    public SR_PNI(List<SR_Payload> payloads){
        this.payloads = payloads;
        if(payloads != null && payloads.size() == 1){
            this.payload = payloads.get(0);
            this.risks = new SR_InsurancePolicies(this.payload);
        }
    }
    
    /**
	* @return payload with PNI
	* @description Get PNI
	*/
    public List<SR_Payload> handlePNI(){
        if(this.util.isValidForPNI(this.payload)){
            handleLOB();
            this.updatedPayloads.add(this.payload);
        }
        return (this.updatedPayloads.isEmpty()) ? this.payloads : this.updatedPayloads;
    }

    @TestVisible
    private List<SR_Payload> handleLOB(){
        if(this.payload.caseRecord.LOB__c.equals('Auto')){
            handlePNIAuto();
        }else if(this.payload.caseRecord.LOB__c.equals('Fire')){
            handlePNIFire();
        }
        return this.payloads;
    }
    
    @TestVisible
    private void handlePNIAuto(){
        this.insurancePolicies = this.risks.getInsurancePoliciesAuto();
        if(!this.insurancePolicies.isEmpty()){
            setClientIds((this.util.isUnitTest()) ? this.mockString : this.insurancePolicies.get(0).NameInsured.ClientIdentifier__c);
        }
    }
    
    @TestVisible
    private void setClientIds(String clientId){
        this.payload.matchParams.secondaryClientId = this.payload.matchParams.clientId;
		this.payload.matchParams.clientId = clientId;
    }
    
    @TestVisible
    private void handlePNIFire(){
        this.insurancePolicies = this.risks.getInsurancePoliciesFire();
        if(!this.insurancePolicies.isEmpty()){
            setClientIds((this.util.isUnitTest()) ? this.mockString : this.insurancePolicies.get(0).NameInsured.ClientIdentifier__c);
        }
    }
}