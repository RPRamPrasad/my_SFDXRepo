/**
* Author : Team Kraken
* Date Created : 2/12/21
* @description : BillingAccountData model for BillingTab
*/

public with sharing class BillingAccountData extends BillingTabModels {
    private static final String SOURCE_SYSTEM_LOB = 'lob';
    
    @AuraEnabled
    public String billingAccountId;
    @AuraEnabled
    public Date accountCloseDate;
    @AuraEnabled
    public String billingAccountNumber;
    @AuraEnabled
    public Date billAccountDueDate;
    @AuraEnabled
    public Date billDueDate;
    @AuraEnabled
    public Decimal calculatedCurrentAmountDue;
    @AuraEnabled
    public Date cancellationDate;
    @AuraEnabled
    public Decimal lastBillAmount;
    @AuraEnabled
    public Date lastBillDueDate;
    @AuraEnabled
    public Decimal pastDueAmount;
    @AuraEnabled
    public String regionCode;
    @AuraEnabled
    public String sourceSystemIdentifier;
    @AuraEnabled
    public String sourceSystem;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public AgentData agentData;
    @AuraEnabled
    public List<InsurancePolicyData> insurancePolicies;
    @AuraEnabled
    public List<BillingParticipantData> billingParticipants;
/**
 * @description BillingAccountData
 * @param billingAccount 
 * @param participants 
 */
    public BillingAccountData(Billing_Account__c billingAccount, List<BillingParticipantData> participants) {

        this.billingAccountId = billingAccount.Id;
        this.accountCloseDate = billingAccount.AccountCloseDate__c;
        this.billingAccountNumber = billingAccount.AccountNumber__c;
        this.billAccountDueDate = billingAccount.BillAccountDueDate__c;
        this.billDueDate = billingAccount.BillDueDate__c;
        this.calculatedCurrentAmountDue = billingAccount.CalculatedCurrentAmountDue__c;
        this.cancellationDate = billingAccount.CancellationDate__c;
        this.lastBillAmount = billingAccount.LastBillAmount__c;
        this.lastBillDueDate = billingAccount.LastBillDueDate__c;
        this.pastDueAmount = billingAccount.PastDueAmount__c;
        this.regionCode = billingAccount.RegionCode__c;
        this.sourceSystemIdentifier = billingAccount.SourceSystemIdentifier__c;
        this.sourceSystem = billingAccount.SourceSystem__c;
        this.status = billingAccount.Status__c;
        this.type = billingAccount.Type__c;

        this.agentData = new AgentData(billingAccount.ServicingAgent__c);
        this.insurancePolicies = new List<InsurancePolicyData>();
        this.billingParticipants = participants;
    }

    /**
     * @description BillingAccountData
     */
    public BillingAccountData() {
        this.sourceSystem = SOURCE_SYSTEM_LOB;
        this.insurancePolicies = new List<InsurancePolicyData>();
    }
}