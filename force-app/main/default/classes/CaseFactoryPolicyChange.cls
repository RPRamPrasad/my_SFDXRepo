/** 
* @description case factory used to build policy change cases 
* @Owner: CATS
*/
public with sharing class CaseFactoryPolicyChange extends CaseFactory{
    private String policyIdentifier;
    private String productDescription;
    private boolean issued;
    private boolean isEscalated;
    private Date effectiveDate;
    /**
     * @description setPolicyIdentifier
     * @param policyIdentifier 
     * @return  `CaseFactoryPolicyChange`
     */
    public CaseFactoryPolicyChange setPolicyIdentifier(String policyIdentifier){
        this.policyIdentifier = policyIdentifier;
        return this;
    }
    /**
     * @description setProductDescription
     * @param productDescription 
     * @return  `CaseFactoryPolicyChange`
     */
    public CaseFactoryPolicyChange setProductDescription(String productDescription){
        this.productDescription = productDescription;
        return this;
    }
    /**
     * @description setIssued
     * @param issued 
     * @return  `CaseFactoryPolicyChange`
     */
    public CaseFactoryPolicyChange setIssued(boolean issued){
        this.issued = issued;
        return this;
    }
    /**
     * @description setIsEscalated
     * @param isEscalated 
     * @return  `CaseFactoryPolicyChange`
     */
    public CaseFactoryPolicyChange setIsEscalated(boolean isEscalated){
        this.isEscalated = isEscalated;
        return this;
    }
    /**
     * @description setEffectiveDate
     * @param effectiveDate 
     * @return  `CaseFactoryPolicyChange`
     */
	public CaseFactoryPolicyChange setEffectiveDate(Date effectiveDate){
        this.effectiveDate = effectiveDate;
        return this;
    }    
    /** @description buildCase
      * @param accountObject 
      * @param caseOwnerId 
      * @return  `Case`
      */
    public Case buildCase(SObject accountObject, Id caseOwnerId){
        Case policyChangeCase = new Case();  
        policyChangeCase.Subject = subject;
        policyChangeCase.Description = description;
        policyChangeCase.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE;
        policyChangeCase.App_Code__c = String.isNotBlank(appCode) ? appCode : null;
        policyChangeCase.Issued__c = issued;
        policyChangeCase.IsEscalated = isEscalated;
        policyChangeCase.Effective_Date__c = String.isNotBlank(String.valueOf(effectiveDate)) ? effectiveDate : null;
        setProductFields(policyChangeCase);
        setUserFields(policyChangeCase, caseOwnerId);
        setCustomerFields(policyChangeCase, accountObject);
        return policyChangeCase;
    }
    
    private void setProductFields(Case caseRecord){
        caseRecord.ProductDescription__c = String.isNotBlank(productDescription) ? productDescription : null;
        caseRecord.Policy_Identifier__c = String.isNotBlank(policyIdentifier) ? policyIdentifier : null;
    }
    
    private void setUserFields(Case caseRecord, Id caseOwnerId){
        caseRecord.OwnerId = String.isNotBlank(caseOwnerId) ? caseOwnerId : UserInfo.getUserId();
        caseRecord.Assigned_To__c = String.isNotEmpty(assignedTo) ? assignedTo : null;
    }
    
    private void setCustomerFields(Case caseRecord, SObject accountObject){
        if(accountObject != null){
            caseRecord.ContactId = String.valueOf(accountObject.get('PersonContactId'));
            caseRecord.AccountId = String.valueOf(accountObject.get('Id'));
        }
    }
}