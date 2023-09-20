/**
* @author Team NSYNC
* @date 10/7/2022
* @description Finds missing shares and creates them
*/
public with sharing class AP_CreateMissingAgreeRiskShares { 
    private static final String CLASS_NAME = 'AP_CreateMissingAgreeRiskShares';
    private static final String TOTAL_AGENT_OFFICES = 'Total Agent Offices';
    private static final String AGENT_OFFICES_MISSING_SHARES = 'Agent Offices with Missing Shares';
    private static final String TOTAL_POLICIES_MISSING_SHARES = 'Total Policies with Missing Shares';
    /**
* @description findAndCreateMissingShares Finds missing shares and creates them.
* Change the maxSize from 9999 to 1 when testing.
* @param agentList
* @return  `Map<String, Integer>`
* 
*/    
    public Map<String, Integer> findAndCreateMissingShares(List<User> agentList) {
        List<InsurancePolicyShare> insurancePolicyShareInsertList = new List<InsurancePolicyShare>();
        Integer agentOfficesWithMissingShares = 0;
        Integer totalPoliciesWithMissingShares = 0;
        Map<String, Integer> batchStatusMap = new Map<String, Integer>();
        Integer maxSize = 9999;
        if(Test.isRunningTest()) {
            maxSize = 1;
        } 
        
        for (User anAgent:agentList) {
            List<InsurancePolicyParticipant> insurancePolicyParticipantList = queryInsurancePolicyParticipant(anAgent);
            if (insurancePolicyParticipantList.isEmpty()) {
                continue;
            }
            else {
                Set<InsurancePolicy> insurancePolicyList = new Set<InsurancePolicy>();
                Integer setSize = 0;
                for (InsurancePolicyParticipant insurancePolicyParticipant:insurancePolicyParticipantList) {
                    setSize++;
                    InsurancePolicy insurancePolicy = new InsurancePolicy();
                    insurancePolicy.id = insurancePolicyParticipant.InsurancePolicyId;
                    insurancePolicyList.add(insurancePolicy);
                    if (setSize > maxSize) {
                        break;
                    }
                } 
                agentOfficesWithMissingShares++;
                totalPoliciesWithMissingShares += insurancePolicyList.size();
                insurancePolicyShareInsertList = createShares(insurancePolicyList, anAgent);
                UTIL_InsurancePolicyShares.insertInsurancePolicyShares(insurancePolicyShareInsertList);
            }
        }
        batchStatusMap.put(AGENT_OFFICES_MISSING_SHARES, agentOfficesWithMissingShares);
        batchStatusMap.put(TOTAL_POLICIES_MISSING_SHARES, totalPoliciesWithMissingShares);
        return batchStatusMap;
    }
    private List<InsurancePolicyParticipant> queryInsurancePolicyParticipant(User anAgent) {
        return [SELECT InsurancePolicy.Id FROM InsurancePolicyParticipant WHERE primaryparticipantaccountid in (SELECT Customer__c FROM AgentRole__c where agent__r.userexternalid__c = :anAgent.servicing_agent_external_id__c) and InsurancePolicyId not in (SELECT parentId FROM InsurancePolicyShare WHERE AccessLevel = 'Read' AND RowCause = 'Manual' AND UserOrGroupid = :anAgent.Id) WITH SECURITY_ENFORCED];
    }
    private List<InsurancePolicyShare> createShares(Set<InsurancePolicy> insurancePolicyList, User anAgent) {
        List<InsurancePolicyShare> insurancePolicyShareInsertList = new List<InsurancePolicyShare>();
        for (InsurancePolicy insurancePolicy:insurancePolicyList) {
            insurancePolicyShareInsertList.add(createShare(insurancePolicy, anAgent));
        }
        return insurancePolicyShareInsertList;
    }
    private InsurancePolicyShare createShare(InsurancePolicy insurancePolicy, User anAgent) {
        InsurancePolicyShare anInsurancePolicyShare = new InsurancePolicyShare();
        anInsurancePolicyShare.ParentId = insurancePolicy.Id;
        anInsurancePolicyShare.UserOrGroupId = anAgent.Id;
        anInsurancePolicyShare.AccessLevel = 'Read';
        anInsurancePolicyShare.RowCause = 'Manual';
        return anInsurancePolicyShare;       
    }
    /**
* @description createExceptionLogAsInfo End of Job display results in the exceptionLog__c cobject
* @param batchStatusMap
*/    
    public void createExceptionLogAsInfo(Map<String, Integer> batchStatusMap){
        ExceptionLog__c logToInsert = populateExceptionLogInfo(batchStatusMap);
        LoggingService.logListException(new List<ExceptionLog__c>{logToInsert});
    }
    
    private ExceptionLog__c populateExceptionLogInfo(Map<String, Integer> batchStatusMap){
        String message = 'Results for ' + CLASS_NAME + ' : Total Agent Offices - ' + batchStatusMap.get(TOTAL_AGENT_OFFICES) + ', Agent Offices with Missing Shares - ' + batchStatusMap.get(AGENT_OFFICES_MISSING_SHARES) + ', Shares inserted - ' + batchStatusMap.get(TOTAL_POLICIES_MISSING_SHARES);
        return new UTIL_ExceptionBuilder()
            .setClassName(CLASS_NAME)
            .setMethodName('execute')
            .setSeverityLevel(System.LoggingLevel.INFO.name())
            .setExceptionMessage(message)
            .setExceptionType(System.LoggingLevel.INFO.name())
            .isHandled(true)
            .setOrganizationId(UserInfo.getOrganizationId())
            .setOrganizationName(UserInfo.getOrganizationName())
            .setUserId(UserInfo.getUserId())
            .build();
    }
}