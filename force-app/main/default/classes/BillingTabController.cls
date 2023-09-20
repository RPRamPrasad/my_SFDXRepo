/**
* Author : Team Kraken
* Date Created : 2/12/21
* @description : Used to retrieve billing account information in the billing tab on the Account page
*/

public with sharing class BillingTabController extends BillingTabModels {
    private static final string CLASS_NAME = 'BillingTabController';
    
    /**
     * @description Returns a list of billing account data for a given list of account IDs.
     * @param accountIds
     * @return List<BillingAccountData>
     */
    @AuraEnabled(cacheable=false)
    public static List<BillingAccountData> getBillingAccounts(List<String> accountIds) {

        String methodName = 'getBillingAccounts';

        try{
            // All policies that the account is involved in
            Map<Id, InsurancePolicyData> insurancePolicyIdToData = new Map<Id, InsurancePolicyData>();
            getInsurancePolicies(accountIds, insurancePolicyIdToData);
            getInsurancePolicyParticipants(accountIds, insurancePolicyIdToData);
            List<Billing_Policy__c> billingPolicies = getBillingPolicies(insurancePolicyIdToData.keySet());

            // All billing account ids we need to query
            Map<Id, List<BillingParticipantData>> billingAccountIdToParticipant = getBillingParticipantBillingAccountIds(accountIds);

            Map<Id, Map<Id, InsurancePolicyData>> billingAccountIdToInsurancePolicyData = getBillingAccountIdsFromInsurancePolicies(billingPolicies, insurancePolicyIdToData);

            Set<Id> billingAccountIds = new Set<Id>();
            billingAccountIds.addAll(billingAccountIdToParticipant.keySet());
            billingAccountIds.addAll(billingAccountIdToInsurancePolicyData.keySet());


            List<Billing_Account__c> queriedBillingAccounts = getBillingAccountsByIds(billingAccountIds);

            List<BillingAccountData> billingAccounts = BillingTabBillingAccountDataBuilder.buildBillingAccounts(queriedBillingAccounts, billingAccountIdToInsurancePolicyData, billingAccountIdToParticipant);

            addLobAccounts(billingPolicies, insurancePolicyIdToData, billingAccounts);

            return billingAccounts;

        } catch(Exception e){
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            throw e;
        }
    }

    //deal with Line of Business Accounts
    @TestVisible
    private static List<BillingAccountData> addLobAccounts(List<Billing_Policy__c> billingPolicies, Map<Id, InsurancePolicyData> insurancePolicyIdToData, List<BillingAccountData> billingAccounts) {
        List<Id> billingPolicyInsurancePolicyId = new List<Id>();

        BillingAccountData lobBillingAccount = null;

        for(Billing_Policy__c billingPolicy : billingPolicies) {
            billingPolicyInsurancePolicyId.add(billingPolicy.InsurancePolicyId__c);
        }

        lobBillingAccount = new BillingAccountData();
        for(Id insurancePolicyId : insurancePolicyIdToData.keySet()) {
            if(!billingPolicyInsurancePolicyId.contains(insurancePolicyId)) {
                lobBillingAccount.insurancePolicies.add(insurancePolicyIdToData.get(insurancePolicyId));
            }
        }

            billingAccounts.add(lobBillingAccount);

        return billingAccounts;
    }

    private static List<Billing_Account__c> getBillingAccountsByIds(Set<Id> billingAccountIds) {
        String methodName = 'getBillingAccountsByIds';
        List<Billing_Account__c> billingAccounts = new List<Billing_Account__c>();

        try {
            billingAccounts = [
                SELECT Id, AccountNumber__c, CalculatedCurrentAmountDue__c, LastBillAmount__c, PastDueAmount__c, 
                    SourceSystemIdentifier__c, SourceSystem__c, Status__c, Type__c, AccountCloseDate__c, RegionCode__c, 
                    BillAccountDueDate__c, BillDueDate__c, CancellationDate__c, LastBillDueDate__c, ServicingAgent__c,
                    (SELECT InsurancePolicyId__c, BillingFrequency__c FROM BillingPolicyAccounts__r)
                FROM Billing_Account__c
                WHERE Id IN :billingAccountIds
                AND (CancellationDate__c = null OR CancellationDate__c >= TODAY)
                WITH SECURITY_ENFORCED                
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        return billingAccounts;
    }

    private static List<Billing_Policy__c> getBillingPolicies(Set<Id> insurancePolicyIds) {
        String methodName = 'getBillingPolicies'; 

        List<Billing_Policy__c> billingPolicies = new List<Billing_Policy__c>();

        try {
            billingPolicies = [
                SELECT BillingAccountID__c, InsurancePolicyId__c, BillingFrequency__c, PolicyActive__c, PolicyStatus__c, CancellationDate__c
                FROM Billing_Policy__c 
                WHERE InsurancePolicyId__c IN :insurancePolicyIds AND PolicyStatus__c != 'BACKOUT'
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        return billingPolicies;
    }

    @TestVisible
    private static Map<Id, Map<Id, InsurancePolicyData>> getBillingAccountIdsFromInsurancePolicies(List<Billing_Policy__c> billingPolicies, Map<Id, InsurancePolicyData> queriedInsurancePolicyData) {

        Map<Id, Map<Id, InsurancePolicyData>> billingAccountIdToInsurancePolicyData = new Map<Id, Map<Id, InsurancePolicyData>>();

        for (Billing_Policy__c policy : billingPolicies) {
            Map<Id, InsurancePolicyData> insurancePolicyIdToData = billingAccountIdToInsurancePolicyData.get(policy.BillingAccountID__c);            
            if (insurancePolicyIdToData == null) {
                insurancePolicyIdToData = new Map<Id, InsurancePolicyData>();
            }
            
            InsurancePolicyData ipData = queriedInsurancePolicyData.get(policy.InsurancePolicyId__c);
            ipData.billingFrequency.put(policy.BillingAccountID__c, policy.BillingFrequency__c);
            ipData.policyActive.put(policy.BillingAccountID__c, policy.PolicyActive__c);
            ipData.policyStatus.put(policy.BillingAccountID__c, policy.PolicyStatus__c);
            ipData.cancellationDate.put(policy.BillingAccountID__c, policy.CancellationDate__c);



            insurancePolicyIdToData.put(policy.InsurancePolicyId__c, ipData);
            billingAccountIdToInsurancePolicyData.put(policy.BillingAccountID__c, insurancePolicyIdToData);
        }

        return billingAccountIdToInsurancePolicyData;
    }

    private static void getInsurancePolicies(List<String> accountIds, Map<Id, InsurancePolicyData> insurancePolicyIdToData) {
        String methodName = 'getInsurancePolicies';
        List<InsurancePolicy> insurancePolicies = new List<InsurancePolicy>();

        try {
            insurancePolicies = [
                SELECT Id, PolicyDescription, Name, ProdLineCd__c, AgreAccessKey__c, Servicing_Agent__r.Name, Servicing_Agent__r.State_Agent_Code__c, AgreDisplayPartyName__c
                FROM InsurancePolicy
                WHERE NameInsuredId IN :accountIds
                AND isActive = true
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        for (InsurancePolicy insurancePolicy : insurancePolicies) {
            insurancePolicyIdToData.put(insurancePolicy.Id, new InsurancePolicyData(insurancePolicy));
        }
    }

    private static void getInsurancePolicyParticipants(List<String> accountIds, Map<Id, InsurancePolicyData> insurancePolicyIdToData) {
        String methodName = 'getInsurancePolicyParticipants';
                List<InsurancePolicyParticipant> insurancePolicyParticipants = new List<InsurancePolicyParticipant>();

        try {
            insurancePolicyParticipants = [
                SELECT Id, InsurancePolicyId, InsurancePolicy.PolicyDescription, InsurancePolicy.Name, InsurancePolicy.AgreAccessKey__c, InsurancePolicy.ProdLineCd__c, InsurancePolicy.Servicing_Agent__r.Name, InsurancePolicy.Servicing_Agent__r.State_Agent_Code__c, InsurancePolicy.AgreDisplayPartyName__c
                FROM InsurancePolicyParticipant
                WHERE PrimaryParticipantAccountId IN :accountIds
                AND InsurancePolicy.isActive = true
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        for (InsurancePolicyParticipant participant : insurancePolicyParticipants) {
            insurancePolicyIdToData.put(participant.InsurancePolicyId, new InsurancePolicyData(participant));
        }
    }

    private static Map<Id, List<BillingParticipantData>> getBillingParticipantBillingAccountIds(List<String> accountIds) {
        String methodName = 'getBillingParticipantBillingAccountIds';
        List<Billing_Participant__c> participants = new List<Billing_Participant__c>();

        try {
            participants = [
                SELECT Id, BillingAccountID__c, SFPolicyRoleId__c, ParticipantAccountId__r.Name, ParticipantAccountId__r.Id
                FROM Billing_Participant__c
                WHERE ParticipantAccountId__c IN :accountIds
                WITH SECURITY_ENFORCED
            ]; 
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        Map<Id, List<BillingParticipantData>> billingAccountIdToParticipants = new Map<Id, List<BillingParticipantData>>();
        for (Billing_Participant__c participant : participants) {
            List<BillingParticipantData> existingParticipants = billingAccountIdToParticipants.get(participant.BillingAccountID__c);
            
            if (existingParticipants == null) {
                existingParticipants = new List<BillingParticipantData>();
            }
            existingParticipants.add(new BillingParticipantData(participant));                        
            billingAccountIdToParticipants.put(participant.BillingAccountID__c, existingParticipants);
        }

        return billingAccountIdToParticipants;
    }


    /**
     * @description method to retrieve billing policy information associated with a billing account
     * @param billingAccountId
     * @return List<Billing_Policy__c>
     */
    @AuraEnabled(cacheable=false)
    public static List<Billing_Policy__c> getBillingPolicyInformationFromBillingAccount(String billingAccountId) {
        String methodName = 'getBillingPolicyInformationFromBillingAccount';

        if (!isValidBillingAccountId(methodName, billingAccountId)) {
            return new List<Billing_Policy__c>();
        }

        List<Billing_Policy__c> billingPolicies = new List<Billing_Policy__c>();

        try {
            billingPolicies = [
                SELECT BillingFrequency__c, CurrentAmountDue__c, InsurancePolicyId__r.Name, 
                    InsurancePolicyId__r.PolicyDescription, InsurancePolicyId__r.ProdLineCd__c, InsurancePolicyId__r.isActive, InsurancePolicyId__r.Status, PolicyActive__c, PolicyStatus__c,CancellationDate__c
                FROM Billing_Policy__c 
                WHERE BillingAccountID__c = : billingAccountId
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            throw new AuraHandledException(qe.getMessage());
        }


        return billingPolicies;
    }

     /**
     * @description method to retrieve the participant information related to a billing account
     * @param billingAccountId
     * @return List<Billing_Participant__c>
     */
    @AuraEnabled(cacheable=false)
    public static List<Billing_Participant__c> getParticipantInformationFromBillingAccount(String billingAccountId) {
        String methodName = 'getParticipantInformationFromBillingAccount';

        if (!isValidBillingAccountId(methodName, billingAccountId)) {
            return new List<Billing_Participant__c>();
        }

        List<Billing_Participant__c> billingParticipants = new List<Billing_Participant__c>();

        try {
            billingParticipants = [
                SELECT ParticipantAccountId__c,SFPolicyRoleId__c, ParticipantAccountId__r.ClientIdentifier__c, ParticipantAccountId__r.Name
                FROM Billing_Participant__c
                WHERE BillingAccountID__c = : billingAccountId 
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);

        }


        return billingParticipants;
    }

    /**
     * @description method to retrieve agent data associated with a billing account
     * @param billingAccountId
     * @return AgentData
     */
    @AuraEnabled(cacheable=false)
    public static AgentData getServicingAgent(String billingAccountId){
        String methodName = 'getServicingAgent';

        if (!isValidBillingAccountId(methodName, billingAccountId)) {
            return null;
        }

        AgentData agentData;
        Billing_Account__c billingServiceAgent = new Billing_Account__c();

        try {
            billingServiceAgent = [
                SELECT ServicingAgent__c
                FROM Billing_Account__c 
                WHERE Id = : billingAccountId 
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        String servincingAgentId = billingServiceAgent.ServicingAgent__c;

        agentData = BillingAccountDetailsDataBuilder.buildAgent(servincingAgentId);
        return agentData;
    }

    /**
     * @description method to retrieve the billing data related to a billing account
     * @param billingAccountId
     * @return Billing_Account__c
     */
    @AuraEnabled(cacheable=false)
    public static Billing_Account__c getBillingData(String billingAccountId) {
        String methodName = 'getBillingData';

        if (!isValidBillingAccountId(methodName, billingAccountId)) {
            return null;
        }

        Billing_Account__c billingData = new Billing_Account__c();

        try {
            billingData = [
                SELECT AccountNumber__c,BillDueDate__c, BillAccountDueDate__c, CalculatedCurrentAmountDue__c, Status__c, SourceSystem__c, Type__c, 
                CancellationDate__c, PastDueIndicator__c, PastDueAmount__c, LastBillAmount__c, LastBillDueDate__c, AccountCloseDate__c
                FROM Billing_Account__c
                WHERE Id = : billingAccountId
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        return billingData;
    }

    @TestVisible
    private static Boolean isValidBillingAccountId(String methodName, String billingAccountId) {
        try {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('billingAccountId', billingAccountId, Billing_Account__c.class);
            return true;
        } catch (InvalidParameterValueException e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        return false;
    }

}
