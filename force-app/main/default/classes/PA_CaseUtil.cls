/** 
@Name PA_CaseUtil
@description This class is used as a util to create policy transaction cases
*/
public with sharing class PA_CaseUtil {

    @TestVisible private boolean mockThrowException = false;
    @TestVisible private static final String ERROR_MESSAGE_PROXY_FAILURE = 'PA_CaseUtil - the agent proxy was not found';
    @TestVisible private static final String LOB_AUTO = 'Auto';
	@TestVisible private Id saveResultId;
    @TestVisible private List<Group> queueList = new List<Group>();
    @TestVisible private List<Case> cases = new List<Case>();
    public Case caseRecord = new Case();
    public Id parentRecordId;
    public Id caseContactAccountId;
    public String agentAssociateId;
    public boolean isCaseMigrationAction = false;
    public boolean isLegacyPolicy = true;
    public String agreementIndexId;
    public String policyNumber;
    public String sourceSystemCode;
    public String agreAccessKey;
    
    /**
    * @description Driver method to build and insert policy transaction case
    * @return String id of the created case
    */
    public String setupPolicyTransactionCase(){
        try {
            buildPolicyChangeCase();
            insertCase();
        }catch(Exception exp) {
            exp.setMessage('Policy:' + this.caseRecord.PolicyNumber__c + ' ' + exp.getMessage());
            LoggingService.logHandledException(exp, 'PA_CaseUtil', 'setupPolicyTransactionCase', LoggingLevel.ERROR);
        }
        return this.saveResultId;
    }

    @TestVisible
    private void buildPolicyChangeCase(){
        Account acct = PA_CaseUtilHelper.getAccountData(this.parentRecordId);
        boolean isCaseMigrationPolicyChange = this.isCaseMigrationAction;
        if(this.caseRecord.Reason == 'Added Vehicle'){
            setSubject(this.caseRecord.LOB__c + ' - Add Vehicle');
            setRequestType('Add Vehicle/Request', isCaseMigrationPolicyChange);
            if(!this.isLegacyPolicy) {
                setPolicyIdentifier();
            }
        }else{
            setPolicyIdentifier();
            setSubject(this.caseRecord.LOB__c + ' - Policy Change - ' + (isCaseMigrationPolicyChange ? this.caseRecord.ProductDescription__c : this.caseRecord.PolicyNumber__c));
        }
        setAccountId(acct.Id);
        if (this.caseContactAccountId == null) {
            setContactId(acct.PersonContactId);
        } else {
            Account caseContactAccount = PA_CaseUtilHelper.getAccountData(this.caseContactAccountId);
            setContactId(caseContactAccount.PersonContactId);
        }
        if (isCaseMigrationPolicyChange && !this.isLegacyPolicy) {
            setIsModPolicy();
            populateWorkItemLink();
        }
        setStatusChangeDate(Date.today());
        setRecordTypeId(isCaseMigrationPolicyChange ? CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE : CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST);
        setCaseOwnership();
        setAppCode('SFDC UI - Policy Change Action');
        addCaseToList();
    }
 
    @TestVisible
    private void addCaseToList(){
        this.cases.add(this.caseRecord);
    }

    @TestVisible
    private void insertCase(){
        List<Database.SaveResult> results = Database.insert(Security.stripInaccessible(AccessType.CREATABLE, this.cases, true).getRecords());
        this.saveResultId = results.get(0).getId();
    }

	@TestVisible
    private void setCaseOwnership(){
        try {
            if(Test.isRunningTest() && mockThrowException){
                throw new ProxyUserNotFoundException();
            }
            this.caseRecord.OwnerId = UTIL_AgentOfficeDetails.getProxyforGivenServicingAgentAssocId(this.agentAssociateId).Id;
        } catch (ProxyUserNotFoundException exp) {
            getCaseOwnerQueue();
            setCaseOwnerToQueue();
        }
    }

    @TestVisible
    private void setCaseOwnerToQueue(){
        if (!this.queueList.isEmpty()){
            this.caseRecord.OwnerId = this.queueList.get(0).Id;
            this.caseRecord.AssignmentReason__c = ERROR_MESSAGE_PROXY_FAILURE;
        }
    }

    @TestVisible
    private void getCaseOwnerQueue(){
        this.queueList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, developerName, Type FROM Group WHERE developerName = 'Case_Owner_Queue' AND Type = 'Queue'  LIMIT 1]).getRecords();
    }
    
    @TestVisible
    private void setPolicyIdentifier(){
        String policyId = (String.isNotBlank(this.caseRecord.PolicyNumber__c) ? this.caseRecord.PolicyNumber__c.trim() : null);
        if(LOB_AUTO.equalsIgnoreCase(this.caseRecord.LOB__c) && policyId != null){
            policyId = PA_CaseUtilHelper.getPolicyIdForAuto(this.caseRecord.PolicyNumber__c, this.isLegacyPolicy);
        }
        this.caseRecord.Policy_Identifier__c = policyId;
    }
    
    /**
    * @description Method to set lob on the case
    * @param lob
    */
    public void setLOB(String lob){
        this.caseRecord.LOB__c = lob;
    }
    
    @TestVisible
    private void setSubject(String subject){
        this.caseRecord.Subject = subject;
    }
    
    /**
    * @description Method to set policy number on the case
    * @param policyNumber
    */
    public void setPolicyNumber(String policyNumber){
        this.caseRecord.PolicyNumber__c = policyNumber;
        this.policyNumber = policyNumber;
    }
    
    /**
    * @description Method to set product description on the case
    * @param policyDesc
    */
    public void setProductDescription(String policyDesc){
        this.caseRecord.ProductDescription__c = policyDesc;
    }
    
    @TestVisible
    private void setAccountId(Id accountId){
        this.caseRecord.AccountId = accountId;
    }
    
    @TestVisible
    private void setContactId(Id contactId){
        this.caseRecord.ContactId = contactId;
    }

    /**
    * @description Method to set reason on the case
    * @param reason
    */
    public void setReason(String reason){
        this.caseRecord.Reason = reason;
    }
    
    @TestVisible
    private void setStatusChangeDate(Date statusChangeDate){
        this.caseRecord.Status_Changed_Date__c = statusChangeDate;
    }
    
    @TestVisible
    private void setRecordTypeId(Id recordTypeId){
        this.caseRecord.RecordTypeId = recordTypeId;
    }   
    @TestVisible
    private void setRequestType(String requestType, Boolean isCaseMigrationPolicyChange){
        if(isCaseMigrationPolicyChange){
            this.caseRecord.Request_Type__c = requestType;
        }
    }

    @TestVisible
    private void setAppCode(String appCode){
        this.caseRecord.App_Code__c = appCode;
    }

    @TestVisible
    private void setIsModPolicy() {
        this.caseRecord.isModPolicy__c = true;
    }

    @TestVisible
    private void populateWorkItemLink() {
        switch on this.sourceSystemCode {
            when '15' {
                if(LOB_AUTO.equalsIgnoreCase(this.caseRecord.LOB__c)) {
                    this.caseRecord.Work_Item_Id__c = 266;
                    this.caseRecord.Work_Item_Key__c = '&policyNumber=' + this.policyNumber;
                    this.caseRecord.Work_Item_Name__c = 'PolicyCenter';
                }
            }
            when '24' {
                this.caseRecord.Work_Item_Id__c = 269;
                this.caseRecord.Work_Item_Key__c = '&agreementIndexId=' + this.agreementIndexId + '&agreementNumber=' + this.agreAccessKey + '&applicationName=Auto&sourceSystemCode=' + this.sourceSystemCode;
                this.caseRecord.Work_Item_Name__c = 'PolicyCenter';
            }
        }
    }
}