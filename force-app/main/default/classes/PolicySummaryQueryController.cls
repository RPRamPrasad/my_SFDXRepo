/**
* @description This class is used to power the backend of the Policy Summary LWC. Specifically, getting policy data.
* @Date: 09/26/2022
* @author: Team NSYNC - Wong Soon CIWA 
*/
public with sharing class PolicySummaryQueryController {
    
    @TestVisible
    static List<InsurancePolicy> mockPolicies;
    static List<String> activeSFPPStatuses = new List<String>{
        'PAID', 
        'BILLED', 
        'PAST-DUE', 
        'BILLING SUSPENDED',
        'OUT OF REG BILLING',
        'NONPAY NOTICE SENT',
        'ACCOUNT CLOSING',
        'PENDING',
        'ACTIVE'
    };
    
    /**
* @description fetchAllPolicies - get all Insurance Policies for either Account or Household
* @param inputRecordId 
* @param inputRecordTypeId 
* @return  `List<InsurancePolicy>`
*/

    @AuraEnabled(cacheable=true)
    public static List<InsurancePolicy> fetchAllPolicies(String inputRecordId, Id inputRecordTypeId) {
        
        try{
            if (isHouseholdRecord(inputRecordTypeId)) {
                return fetchAllPoliciesForHousehold(inputRecordId);
            } else {
                return fetchAllPoliciesForAccount(inputRecordId);
            }
        }catch(Exception excep){
            throw new AuraHandledException(excep.getMessage());
        } 
    }
    


    private static List<InsurancePolicy> fetchAllPoliciesForAccount(String recordId) {
        List<InsurancePolicy> acctPolicies;
        
        if (Test.isRunningTest())  {
            if (null == mockPolicies) {
                throw new QueryException('Script-thrown exception');
            }
            else {
                acctPolicies = mockPolicies;
            }
        } else {acctPolicies = Security.stripInaccessible(AccessType.READABLE, [
            SELECT Id, Name, PolicyName, PolicyDescription, Status, PolicyType, ProdLineCd__c, SourceSystemIdentifier, AgreAccessKey__c, SFDCPolicyNumberSearchKey__c, CancellationDate, RenewalDate, EffectiveDate, AgreSourceSysCd__c, PlcyTypeCd__c, NameInsuredId, NameInsured.Name, NameInsured.ClientIdentifier__c, NameInsured.PersonEmail, NI_RoleNameCd__c, NI_SecondaryRoleNameCd__c, AgreDisplayPartyName__c, Servicing_Agent__r.Name, ServicingAgentExternal__c, Servicing_Agent__r.Associate_Id__c, Servicing_Agent__r.State_Agent_Code__c, MasterDataLocationCd__c, CoCd__c, 
            (
                SELECT Id, AssetName, Description__c, RiskNumber__c, RiskStatusText__c, VIN_Address_Cov_Amt__c FROM InsurancePolicyAssets
            ), (
                SELECT Id, BillingAccountID__r.AccountNumber__c, BillingAccountID__r.Status__c, BillingAccountID__r.CalculatedCurrentAmountDue__c, BillingAccountID__r.PastDueAmount__c, BillingAccountID__r.PastDueIndicator__c, BillingAccountID__r.BillDueDate__c, BillingAccountID__r.SourceSystem__c FROM BillingPolicyAccounts__r WHERE PolicyActive__c = true OR (BillingAccountID__r.SourceSystem__c = 'SFPP' AND BillingAccountID__r.Status__c IN :activeSFPPStatuses)
            ), (
                SELECT Id, Name FROM Claims WHERE IsClosed = false
            )
            FROM InsurancePolicy WHERE Id IN (SELECT InsurancePolicyId FROM InsurancePolicyParticipant WHERE PrimaryParticipantAccountId = :recordId)]).getRecords();}
        
        return acctPolicies;
    }
    
    private static Boolean isHouseholdRecord(Id inputRecordTypeId) {
        
        Map<String, ID> accountRecordTypeMap = new Map<String, ID>();
        Map<String, Schema.Recordtypeinfo> schemaRtMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
        
        for (String s : schemaRtMap.keySet()) {
            accountRecordTypeMap.put(s, schemaRtMap.get(s).RecordTypeId);
        }
        
        return inputRecordTypeId.equals(accountRecordTypeMap.get('IndustriesHousehold'));
    }
    
    private static List<InsurancePolicy> fetchAllPoliciesForHousehold(String recordId) {
        List<InsurancePolicy> hhPolicies;


        if (Test.isRunningTest()) {
            if (null == mockPolicies) {
                throw new QueryException('Script-thrown exception');
            }
            else {
                hhPolicies = mockPolicies;
            }
        } else {hhPolicies = Security.stripInaccessible(AccessType.READABLE, [
            SELECT Id, Name, PolicyName, PolicyDescription, Status, PolicyType, ProdLineCd__c, SourceSystemIdentifier, AgreAccessKey__c, SFDCPolicyNumberSearchKey__c, CancellationDate, RenewalDate, EffectiveDate, AgreSourceSysCd__c, PlcyTypeCd__c, NameInsuredId, NameInsured.Name, NameInsured.ClientIdentifier__c, NameInsured.PersonEmail, NI_RoleNameCd__c, NI_SecondaryRoleNameCd__c, AgreDisplayPartyName__c, Servicing_Agent__r.Name, ServicingAgentExternal__c, Servicing_Agent__r.Associate_Id__c, Servicing_Agent__r.State_Agent_Code__c, MasterDataLocationCd__c, CoCd__c, 
            (
                SELECT Id, AssetName, Description__c, RiskNumber__c, RiskStatusText__c, VIN_Address_Cov_Amt__c FROM InsurancePolicyAssets
            ), (
                SELECT Id, BillingAccountID__r.AccountNumber__c, BillingAccountID__r.Status__c, BillingAccountID__r.CalculatedCurrentAmountDue__c, BillingAccountID__r.PastDueAmount__c, BillingAccountID__r.PastDueIndicator__c, BillingAccountID__r.BillDueDate__c, BillingAccountID__r.SourceSystem__c FROM BillingPolicyAccounts__r WHERE PolicyActive__c = true OR (BillingAccountID__r.SourceSystem__c = 'SFPP' AND BillingAccountID__r.Status__c IN :activeSFPPStatuses)
            ), (
                SELECT Id, Name FROM Claims WHERE IsClosed = false
            )
            FROM InsurancePolicy WHERE Id in (SELECT InsurancePolicyId from InsurancePolicyParticipant WHERE FinServ__Household__c = :recordId)]).getRecords();}
        
        return hhPolicies;
    }
}