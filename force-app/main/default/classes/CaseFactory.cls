/** 
* @description case factory used to build cases 
* @Owner: Grumpycats
*/
public virtual with sharing class CaseFactory {

    public static final String EXCEPTION_MESSAGE_DATAACCESSREQUEST = 'The Data Access Request was not able to be created. If the issue persists please reach out to technical support';
	public static final String EXCEPTION_MESSAGE_CUSTOMERONBOARDING = 'The New Customer Onboarding Case was not able to be created. If the issue persists please reach out to technical support';
    public static final String EXCEPTION_MESSAGE_CUSTOMERSERVICEREQUEST = 'The Customer Service Request Case was not able to be created. If the issue persists please reach out to technical support';
    public static final String EXCEPTION_MESSAGE_RETENTIONCASE = 'The Customer Retention Case was not able to be created. If the issue persists please reach out to technical support';
    public String assignedTo;
    public String subject; 
    public String description; 
    public String appCode; 
    public String caseType; 
    public String reason;
    public String status;
    public String relatedOpportunityId;
    /**
     * @description setRelatedOpportunityId
     * @param relatedOpportunityId 
     * @return  `CaseFactory`
     */
    public CaseFactory setRelatedOpportunityId(String relatedOpportunityId){
        this.relatedOpportunityId = relatedOpportunityId;
        return this;
    }
	/**
     * @description setAssignedTo
     * @param assignedTo 
     * @return  `CaseFactory`
     */
    public CaseFactory setAssignedTo(String assignedTo){
        this.assignedTo = assignedTo;
        return this;
    }
    /**
     * @description setSubject
     * @param subject 
     * @return  `CaseFactory`
     */
    public CaseFactory setSubject(String subject){
        this.subject = subject;
        return this;
    }
    /**
     * @description setDescription
     * @param description 
     * @return  `CaseFactory`
     */
    public CaseFactory setDescription(String description){
        this.description = description;
        return this;
    }
    /**
     * @description  setAppcode
     * @param appCode 
     * @return  `CaseFactory`
     */
    public CaseFactory setAppCode(String appCode){
        this.appCode = appCode;
        return this;
    }
    /**
     * @description setCaseType
     * @param caseType 
     * @return  `CaseFactory`
     */
    public CaseFactory setCaseType(String caseType){
        this.caseType = caseType;
        return this;
    }
    /**
     * @description setReason
     * @param reason 
     * @return  `CaseFactory`
     */
    public CaseFactory setReason(String reason){
        this.reason = reason;
        return this;
    }
    /**
     * @description setStatus
     * @param status 
     * @return  `CaseFactory`
     */
    public CaseFactory setStatus(String status){
        this.status = status;
        return this;
    }
}