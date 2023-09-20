/**
* Author : Team Kraken
* Date Created : 2/12/21
* @description : Used to build BillingAccountData model list
*/

public with sharing class BillingTabBillingAccountDataBuilder extends BillingTabModels {
    private static final string CLASS_NAME = 'BillingTabBillingAccountDataBuilder';
    private static BillingTabBillingAccountDataBuilderWrapper billingWrap = new BillingTabBillingAccountDataBuilderWrapper();
    private BillingTabBillingAccountDataBuilder(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info(CLASS_NAME, 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
/**
 * @description buildBillingAccounts
 * @param queriedBillingAccounts 
 * @param billingAccountIdToInsurancePolicyData 
 * @param billingAccountIdToParticipants 
 * @return  `List<BillingAccountData>`
 */
    public static List<BillingAccountData> buildBillingAccounts(
        List<Billing_Account__c> queriedBillingAccounts, 
        Map<Id, Map<Id, InsurancePolicyData>> billingAccountIdToInsurancePolicyData,
        Map<Id, List<BillingParticipantData>> billingAccountIdToParticipants) {

        Map<Id, BillingAccountData> billingAccounts = new Map<Id, BillingAccountData>();

        Map<Id, String> billingAccountsToStateAgentCode = new Map<Id, String>();
        Map<Id, Map<Id, Billing_Policy__c>> missingInsurancePolicies = new Map<Id, Map<Id, Billing_Policy__c>>();

        for (Billing_Account__c billingAccount : queriedBillingAccounts) {
            List<BillingParticipantData> participants = processdBillingAccountToParticipants(billingAccount, billingAccountsToStateAgentCode, billingAccountIdToParticipants);

            missingInsurancePolicies = processBillingPolicies(billingAccount, billingAccountIdToInsurancePolicyData, missingInsurancePolicies);
            
            billingAccounts.put(billingAccount.Id, new BillingAccountData(billingAccount, participants));
        }
        
        processAgentData(billingAccountsToStateAgentCode, billingAccounts);
        processInsurancePolicyData(missingInsurancePolicies, billingAccounts, billingAccountIdToInsurancePolicyData);

        return billingAccounts.values();
    }

    private static List<BillingParticipantData> processdBillingAccountToParticipants(Billing_Account__c billingAccount, Map<Id, String> billingAccountsToStateAgentCode, Map<Id, List<BillingParticipantData>> billingAccountIdToParticipants) {
        String agent = billingAccount.ServicingAgent__c;

        billingWrap.processdBillingAccountToParticipants(billingAccount, agent, billingAccountsToStateAgentCode);
        List<BillingParticipantData> participants = new List<BillingParticipantData>();
        if (billingAccountIdToParticipants.containsKey(billingAccount.Id)) {
            participants = billingAccountIdToParticipants.get(billingAccount.Id);
        }

        return participants;
    }

    private static Map<Id, Map<Id, Billing_Policy__c>> processBillingPolicies(Billing_Account__c billingAccount, 
        Map<Id, Map<Id, InsurancePolicyData>> billingAccountIdToInsurancePolicyData, Map<Id, Map<Id, Billing_Policy__c>> missingInsurancePolicies) {
        
        Map<Id, Map<Id, Billing_Policy__c>> returnMissingInsurancePolicies = new Map<Id, Map<Id, Billing_Policy__c>>();
        returnMissingInsurancePolicies = billingWrap.processBillingPolicies(billingAccount, billingAccountIdToInsurancePolicyData, missingInsurancePolicies);
        return returnMissingInsurancePolicies;
    }

    private static void processInsurancePolicyToBillingPolicy(InsurancePolicyToBillingPolicyDAO insurancePolicyTOBillingPolicyDao) {
        if (insurancePolicyTOBillingPolicyDao.billingPolicy.InsurancePolicyId__c != null 
            && (insurancePolicyTOBillingPolicyDao.billingAccountIdToInsurancePolicyData.get(insurancePolicyTOBillingPolicyDao.billingAccount.Id) == null
            || !insurancePolicyTOBillingPolicyDao.billingAccountIdToInsurancePolicyData.get(insurancePolicyTOBillingPolicyDao.billingAccount.Id).containsKey(insurancePolicyTOBillingPolicyDao.billingPolicy.InsurancePolicyId__c))) {
            
            Map<Id, Billing_Policy__c> insurancePolicyIdToBillingPolicy = getInsurancePolicyIdToBillingPolicy(insurancePolicyTOBillingPolicyDao.missingInsurancePolicies, insurancePolicyTOBillingPolicyDao.billingAccount.Id);

            insurancePolicyIdToBillingPolicy.put(insurancePolicyTOBillingPolicyDao.billingPolicy.InsurancePolicyId__c, insurancePolicyTOBillingPolicyDao.billingPolicy);

            insurancePolicyTOBillingPolicyDao.missingInsurancePolicies.put(insurancePolicyTOBillingPolicyDao.billingAccount.Id, insurancePolicyIdToBillingPolicy);
        }
    }

    private static Map<Id, Billing_Policy__c> getInsurancePolicyIdToBillingPolicy(Map<Id, Map<Id, Billing_Policy__c>> missingInsurancePolicies, Id billingAccountId) {
        Map<Id, Billing_Policy__c> insurancePolicyIdToBillingPolicy = missingInsurancePolicies.get(billingAccountId);
        if (insurancePolicyIdToBillingPolicy == null) {
            insurancePolicyIdToBillingPolicy = new Map<Id, Billing_Policy__c>();
        }

        return insurancePolicyIdToBillingPolicy;
    }

    private static void processAgentData(Map<Id, String> billingAccountsToStateAgentCode, Map<Id, BillingAccountData> billingAccounts) {
        String methodName = 'processAgentData';

        // Agent 1 (single state standard)
        //  State_Agent_Code__c = '12-3456'
        //  State_Agent_Code_List__c = '12-3456' (or just empty string?)

        // Agent 2 (multi state)
        //  State_Agent_Code__c = '99-9999'  (primary state)
        //  State_Agent_Code_List__c = '45-6789' (other states)

        // This query will overselect all agents with the state agent codes we are looking for
        // then we will try to find the agent by primary state agent code (State_Agent_Code__c).
        // If we can't find the agent that way, we will locate the agent by using the values in their State_Agent_Code_List__c (primary & secondaries)

        // 2 BA - 2 SA

        List<User> agents = new List<User>();        
        try {
            agents = [
                SELECT Id, Name, State_Agent_Code__c, State_Agent_Code_List__c, Associate_ID__c, Servicing_Agent_Associate_ID__c, MasterUserRecord__c, isActive
                FROM User 
                WHERE 
                    State_Agent_Code__c IN :billingAccountsToStateAgentCode.values()
                AND
                    MasterUserRecord__c = true
                AND
                    isActive = true
                AND
                (
                    SubUserType__c = 'Agent'
                    OR
                    SubUserType__c = 'PSO'
                    OR
                    SubUserType__c = 'SFO'
                )
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
        assignAgents(billingAccountsToStateAgentCode, billingAccounts, agents);
    }

    private static void assignAgents(Map<Id, String> billingAccountsToStateAgentCode, Map<Id, BillingAccountData> billingAccounts, List<User> agents) {
        for (Id billingAccountId : billingAccounts.keySet()) {

            String stateAgentCode = billingAccountsToStateAgentCode.get(billingAccountId);
            AgentDataHolder adh = new AgentDataHolder(billingAccountId, stateAgentCode, agents);
            adh.billingAccounts = billingAccounts;
            
            Boolean foundPrimary = evaluateAgents(adh);
            
            billingWrap.assignAgents(billingAccountId, billingAccounts, foundPrimary);
        }
    }

    private static Boolean evaluateAgents(AgentDataHolder agentDataHolder) {
        Boolean foundPrimary = false;
        foundPrimary = billingWrap.evaluateAgents(agentDataHolder);

        return foundPrimary;
    }


    private static void findSecondary(Id billingAccountId, Map<Id, BillingAccountData> billingAccounts, BillingAccountData billingAccountData) {
        String methodName = 'processAgentDataSecondary';
        List<User> agents = new List<User>();
        String stateAgentCode = billingAccountData.agentData.stateAgentCode;
        String stateCodeWildcard = '%' + stateAgentCode + '%';

        if(stateAgentCode != null) {
            try {
                agents = UTIL_BillingAccountDataFindSA.createSecondaryAgentList(stateCodeWildcard);

            } catch (System.QueryException qe) {
                LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            }
    
            AgentDataHolder adh = new AgentDataHolder(billingAccountId, stateAgentCode, agents);
            adh.billingAccounts = billingAccounts;
            
            if(agents != null && !agents.isEmpty()) {
               buildAndAssignAgent(adh, agents.get(0)); 
            }            
        }        
    }

    private static void buildAndAssignAgent(AgentDataHolder agentDataHolder, User agent) {
        BillingAccountData billingAccount = agentDataHolder.billingAccounts.get(agentDataHolder.billingAccountId);
        billingAccount.agentData = BillingTabAgentDataBuilder.buildAgentData(billingAccount.agentData.stateAgentCode, agent);
        agentDataHolder.billingAccounts.put(agentDataHolder.billingAccountId, billingAccount);
    }


    /**
    * @description : This method loops through the billing accounts and finds any associated Insurance Policies which are not directly
    * Related to the ECRM account owner.  These are insurance policies that came as a result of the ECRM Account owner being a participant
    * on insurance policies.  This is being done so that the policy information can be combined with the necessary fields on Billing_Policy__c.
    * @param missingInsurancePolicies
    * @param billingAccounts
    * @param billingAccountIdToInsurancePolicyData
    */
    private static void processInsurancePolicyData(Map<Id, Map<Id, Billing_Policy__c>> missingInsurancePolicies, 
        Map<Id, BillingAccountData> billingAccounts, 
        Map<Id, Map<Id, InsurancePolicyData>> billingAccountIdToInsurancePolicyData) {
        
        List<InsurancePolicy> queriedPolicies = getInsurancePolicies(missingInsurancePolicies);
        List<Billing_Policy__c> billingPoliciesInAccountList = getBillingPolicies(billingAccounts.keySet());

        for (BillingAccountData billingAccount : billingAccounts.values()) {
            
            Map<Id, InsurancePolicyData> insurancePolicyMap = billingAccountIdToInsurancePolicyData.get(billingAccount.billingAccountId);
        
            if (insurancePolicyMap != null) {
                List<InsurancePolicyData> existingPolicies = billingAccount.insurancePolicies;
                existingPolicies.addAll(insurancePolicyMap.values());
            }

            Map<Id, Billing_Policy__c> missingInsurancePolicyIdsToBillingPolicy = missingInsurancePolicies.get(billingAccount.billingAccountId);
            
            BillingPolicyDAO buildBillingPolicyDataArgs = new BillingPolicyDAO();
            buildBillingPolicyDataArgs.missingInsurancePolicyIdsToBillingPolicy = missingInsurancePolicyIdsToBillingPolicy;
            buildBillingPolicyDataArgs.billingPoliciesInAccountList = billingPoliciesInAccountList;
            buildBillingPolicyDataArgs.billingAccount = billingAccount;
            buildBillingPolicyDataArgs.queriedPolicies = queriedPolicies;

            buildBillingPolicyData(buildBillingPolicyDataArgs);
        }
    }

    /**
    * @description : This method combines the fields from the Billing_Policy__c object with the fields from the InsurancePolicy object.
    * @param billingPolicyDao
    */
    private static void buildBillingPolicyData(BillingPolicyDAO billingPolicyDao) {

        if (billingPolicyDao.missingInsurancePolicyIdsToBillingPolicy != null) {
            Map<Id,InsurancePolicyData> insurancePolicyDataToPolicyMap = new Map<Id,InsurancePolicyData>();
            List<Id> queriedPolicyIds = new List<Id>();

            for (InsurancePolicy policy : billingPolicyDao.queriedPolicies) {
                if (billingPolicyDao.missingInsurancePolicyIdsToBillingPolicy.containsKey(policy.Id)) {
                    insurancePolicyDataToPolicyMap.put(policy.Id, new InsurancePolicyData(policy));
                    queriedPolicyIds.add(policy.Id);
                }
            }

            List<Billing_Policy__c> billingPolicies = new List<Billing_Policy__c>();
            Set<Id> billingAccountId = New Set<Id>();
            billingAccountId.add(billingPolicyDao.billingAccount.billingAccountId);
            billingPolicies.addAll(billingPolicyDao.billingPoliciesInAccountList);
            
            for(Billing_Policy__c billingPolicy: billingPolicies) {
                InsurancePolicyData ipData = insurancePolicyDataToPolicyMap.get(billingPolicy.InsurancePolicyId__c);

                if(ipData != null && billingPolicy.BillingAccountID__c == billingPolicyDao.billingAccount.billingAccountId) {
                    ipData.billingFrequency.put(billingPolicyDao.billingAccount.billingAccountId, billingPolicy.BillingFrequency__c);
                    ipData.policyActive.put(billingPolicyDao.billingAccount.billingAccountId, billingPolicy.PolicyActive__c);
                    ipData.policyStatus.put(billingPolicyDao.billingAccount.billingAccountId, billingPolicy.PolicyStatus__c);
                    ipData.cancellationDate.put(billingPolicyDao.billingAccount.billingAccountId, billingPolicy.CancellationDate__c);

                    billingPolicyDao.billingAccount.insurancePolicies.add(ipData);
                }
            }
        }
    }

    private static List<Billing_Policy__c> getBillingPolicies(Set<Id> billingAccountIds) {
        String methodName = 'getBillingPolicies';
        List<Billing_Policy__c> billingPolicies = new List<Billing_Policy__c>();

        try {
            billingPolicies = [
                SELECT BillingAccountID__c, InsurancePolicyId__c, BillingFrequency__c, PolicyActive__c, PolicyStatus__c, CancellationDate__c
                FROM Billing_Policy__c 
                WHERE BillingAccountID__c IN :billingAccountIds AND PolicyStatus__c != 'BACKOUT'
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        return billingPolicies;
    }

    private static List<InsurancePolicy> getInsurancePolicies(Map<Id, Map<Id, Billing_Policy__c>> missingInsurancePolicies) {
        String methodName = 'getInsurancePolicies';
        Set<Id> insurancePolicyIds = new Set<Id>();

        for (Id billingAccountId : missingInsurancePolicies.keySet()) {
            Map<Id, Billing_Policy__c> insurancePolicyToBillingPolicies = missingInsurancePolicies.get(billingAccountId);
            if (insurancePolicyToBillingPolicies != null) {
                insurancePolicyIds.addAll(insurancePolicyToBillingPolicies.keySet());
            }
        }

        List<InsurancePolicy> queriedPolicies = new List<InsurancePolicy>();
            try {
            queriedPolicies = [
                SELECT Id, PolicyDescription, Name, ProdLineCd__c, AgreAccessKey__c, Servicing_Agent__r.Name, Servicing_Agent__r.State_Agent_Code__c, AgreDisplayPartyName__c
                FROM InsurancePolicy
                WHERE Id IN :insurancePolicyIds
                AND isActive = true
                WITH SECURITY_ENFORCED
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
        
        return queriedPolicies;
    }
/**
 * @description AgentDataHolder
 */
    public with sharing class AgentDataHolder {
        public Id billingAccountId;
        public String stateAgentCode;
        public List<User> agents;
        public Map<Id, BillingAccountData> billingAccounts;
/**
 * @description AgentDataHolder
 * @param billingAccountId 
 * @param stateAgentCode 
 * @param agents 
 */
        public AgentDataHolder(Id billingAccountId, String stateAgentCode, List<User> agents) {
            this.billingAccountId = billingAccountId;
            this.stateAgentCode = stateAgentCode;
            this.agents = agents;
        }
    }

    private class BillingTabBillingAccountDataBuilderWrapper{
        private void processdBillingAccountToParticipants(Billing_Account__c billingAccount, String agent, Map<Id, String> billingAccountsToStateAgentCode) {
            if (agent != null && agent != '') {
                billingAccountsToStateAgentCode.put(billingAccount.Id, agent);
            }
        }

    private Map<Id, Map<Id, Billing_Policy__c>> processBillingPolicies(Billing_Account__c billingAccount, Map<Id, Map<Id, InsurancePolicyData>> billingAccountIdToInsurancePolicyData, Map<Id, Map<Id, Billing_Policy__c>> missingInsurancePolicies) {
        for (Billing_Policy__c billingPolicy : billingAccount.BillingPolicyAccounts__r) {
            InsurancePolicyToBillingPolicyDAO insurancePolicyTOBillingPolicyDao = new InsurancePolicyToBillingPolicyDAO();

            insurancePolicyTOBillingPolicyDao.billingAccountIdToInsurancePolicyData = billingAccountIdToInsurancePolicyData;
            insurancePolicyTOBillingPolicyDao.billingPolicy = billingPolicy;
            insurancePolicyTOBillingPolicyDao.billingAccount = billingAccount;
            insurancePolicyTOBillingPolicyDao.missingInsurancePolicies = missingInsurancePolicies;
            processInsurancePolicyToBillingPolicy(insurancePolicyTOBillingPolicyDao);
        }
        return missingInsurancePolicies;
    }
    
    private void assignAgents(Id billingAccountId, Map<Id, BillingAccountData> billingAccounts, Boolean foundPrimary) {
        if(!foundPrimary) {
            findSecondary(billingAccountId, billingAccounts, billingAccounts.get(billingAccountId));
        }
    }

    private Boolean evaluateAgents(AgentDataHolder agentDataHolder) {
        Boolean foundPrimary = false;   
        for (User agent : agentDataHolder.agents) {
            if (agentDataHolder.stateAgentCode == agent.State_Agent_Code__c
                && agent.MasterUserRecord__c == true
                && agent.isActive == true) {
                buildAndAssignAgent(agentDataHolder, agent);
                foundPrimary = true;
                break;
                }
            }
            return foundPrimary;
        }
    }
}
