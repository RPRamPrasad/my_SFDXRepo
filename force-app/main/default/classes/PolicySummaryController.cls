/**
 * @description This class is used to power the backend of the Policy Summary LWC.
   Specifically, getting policy rollup counts and executing risk searches.
 * @Date: 08/13/2021
 * @author: Team NSYNC (Policy Core, formerly Kraken) - Joseph Remy XGRG
 */
public with sharing class PolicySummaryController {
    private static final String CLASS_NAME = 'PolicySummaryController';

    @TestVisible
    private static List<InsurancePolicy> mockPolicies;
    @TestVisible private static Boolean isCatch = false;
/**
 * @description getPoliciesForRollup
 * @param recordId 
 * @param acctRecordTypeId 
 * @return  `List<InsurancePolicy>`
 */
    @AuraEnabled(cacheable=true)
    public static List<InsurancePolicy> getPoliciesForRollup(Id recordId, Id acctRecordTypeId) {
        List<InsurancePolicy> policies;

        // Get HH record type id
        Id hhRecordTypeId = getHouseholdRecordTypeId();

    try{
        if(isCatch){
            throw new DMLException();
        }
        if (acctRecordTypeId == hhRecordTypeId) {
            // LWC is on HH acct, return HH policies
            policies = getPoliciesForHousehold(recordId);
        } else {
            // LWC is on a customer/org/individual acct, return acct policies
            policies = getPoliciesForIndividualAcct(recordId);
        }

        return policies;
    }
    catch(Exception e){
            AP_LogHolder logHolder = new AP_LogHolder();
            logHolder.info('PolicySummaryController', e.getMessage() + System.now());
            logHolder.writeToLogExceptionObject();
            return new List<InsurancePolicy>();
    }
    }
/**
 * @description getPoliciesForSearch
 * @param ipSfdcIds 
 * @return  `List<InsurancePolicy>`
 */
    @AuraEnabled
    public static List<InsurancePolicy> getPoliciesForSearch(List<Id> ipSfdcIds) {
        try {
            return [
                SELECT
                    AgreSourceSysCd__c,
                    EffectiveDate,
                    Id,
                    Name,
                    PolicyDescription,
                    PolicyName,
                    PolicyType,
                    RenewalDate,
                    Servicing_Agent__c,
                    SFDCPolicyNumberSearchKey__c,
                    Status,
                    (SELECT AssetName, Id, VIN__c FROM InsurancePolicyAssets)
                FROM InsurancePolicy
                WHERE Id IN :ipSfdcIds
                WITH SECURITY_ENFORCED
                ORDER BY Status ASC, PolicyType ASC, EffectiveDate DESC
            ];

        } catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'getPoliciesForSearch', System.LoggingLevel.ERROR);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
     *
     * Get Policies Helpers
     *
     */

    private static List<InsurancePolicy> getPoliciesForHousehold(Id hhId) {
        // Grab from IP Participants
        List<InsurancePolicyParticipant> hhPoliciesFromIPP = [
            SELECT
                InsurancePolicy.Id,
                InsurancePolicy.PolicyType,
                InsurancePolicy.SourceSystemIdentifier,
                InsurancePolicy.Status
            FROM InsurancePolicyParticipant
            WHERE FinServ__Household__c = :hhId
            WITH SECURITY_ENFORCED
        ];

        // Query Insurance Policy based on HH id
        List<InsurancePolicy> hhPolicies;
        if (Test.isRunningTest() && mockPolicies != null) {
            hhPolicies = mockPolicies;
        } else {
            hhPolicies = [
                SELECT Id, PolicyType, SourceSystemIdentifier, Status
                FROM InsurancePolicy
                WHERE FinServ__Household__c = :hhId
                WITH SECURITY_ENFORCED
            ];
        }

        return dedupePolicies(hhPoliciesFromIPP, hhPolicies);
    }

    private static List<InsurancePolicy> getPoliciesForIndividualAcct(Id acctId) {
        // Grab from IP Participants
        List<InsurancePolicyParticipant> policiesFromIPP = [
            SELECT
                InsurancePolicy.Id,
                InsurancePolicy.PolicyType,
                InsurancePolicy.SourceSystemIdentifier,
                InsurancePolicy.Status
            FROM InsurancePolicyParticipant
            WHERE PrimaryParticipantAccountId = :acctId
            WITH SECURITY_ENFORCED
        ];

        // Query Insurance Policy based on NI field
        List<InsurancePolicy> policiesUsingNI = [
            SELECT Id, PolicyType, SourceSystemIdentifier, Status
            FROM InsurancePolicy
            WHERE NameInsuredId = :acctId
            WITH SECURITY_ENFORCED
        ];

        return dedupePolicies(policiesFromIPP, policiesUsingNI);
    }

    /*
     *
     * Common Helpers
     *
     */

    /**
     * @description dedupePolicies
     * @param insPoliciesFromIPP
     * @param insPolicies
     * Dedupes InsurancePolicies between IP and IPP based on Salesforce Id
     * @return List of InsurancePolicy for Acct/HH
     */
    private static List<InsurancePolicy> dedupePolicies(
        List<InsurancePolicyParticipant> insPoliciesFromIPP,
        List<InsurancePolicy> insPolicies
    ) {
        Map<Id, InsurancePolicy> dedupeMap = new Map<Id, InsurancePolicy>();

        for (InsurancePolicyParticipant ipp : insPoliciesFromIPP) {
            dedupeMap.put(ipp.InsurancePolicy.Id, ipp.InsurancePolicy);
        }

        for (InsurancePolicy ip : insPolicies) {
            dedupeMap.put(ip.Id, ip);
        }

        return dedupeMap.values();
    }

    /**
     * @description getHouseholdRecordTypeId
     * Gets the Id of the Household Record Type Id on Account obj
     * @return Id of HH Record Type on Acct (cached)
     */
    public static Id getHouseholdRecordTypeId() {
        return loadHouseholdRecordType();
    }

    /**
     * @description loadHouseholdRecordType
     * Loads the HH record type id from the Account obj
     * @return id of HH Record Type on Acct obj
     */
    private static Id loadHouseholdRecordType() {
        Map<String, ID> accountRecordTypeMap = new Map<String, ID>();
        Map<String, Schema.Recordtypeinfo> schemaRtMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
        for (String s : schemaRtMap.keySet()) {
            accountRecordTypeMap.put(s, schemaRtMap.get(s).RecordTypeId);
        }

        return accountRecordTypeMap.get('IndustriesHousehold');
    }
}
