/**
* @author Team NSYNC
* @date 1072022
* @description Finds missing shares and creates them
*/
public with sharing class Batch_CreateMissingAgreeRiskShares implements Database.Batchable<sObject>, Database.Stateful{
    private Integer totalAgentOffices = 0; 
    private Integer agentOfficesWithMissingShares = 0;
    private Integer totalPoliciesWithMissingShares = 0;
    private static final String TOTAL_AGENT_OFFICES = 'Total Agent Offices';
    private static final String AGENT_OFFICES_MISSING_SHARES = 'Agent Offices with Missing Shares';
    private static final String TOTAL_POLICIES_MISSING_SHARES = 'Total Policies with Missing Shares';
/**    
* @description start
* @param batchableContext 
* @return  `Database.QueryLocator`
*/
     public Database.QueryLocator start(Database.BatchableContext batchableContext) {		
        String queryToRun = 'SELECT Id, servicing_agent_external_id__c FROM User where isactive = true and usertype__c = \'Agent Proxy\' and profile.name = \'1.05 Record Owner - No Login\'';
// Use the following query in our team sandbox for local testing (you don't want to run all users 34,000 of them)         
//        String queryToRun = 'SELECT Id, servicing_agent_external_id__c FROM User where isactive = true and usertype__c = \'Agent Proxy\' 
//        and profile.name = \'1.05 Record Owner - No Login\' and (User.Name LIKE \'Dan Cat%\' OR User.Name LIKE \'Jim Sp%\')';
        
        if(Test.isRunningTest()) {
            queryToRun = 'SELECT Id, servicing_agent_external_id__c FROM User where isactive = true and usertype__c = \'Agent Proxy\' and profile.name = \'1.05 Record Owner - No Login\' and Servicing_Agent_Associate_ID__c = \'1111111111X\'';
        } 
        return Database.getQueryLocator(queryToRun);
    }
/**    
* @description execute
* @param batchableContext 
* @param agentList 
*/
    public void execute(Database.BatchableContext batchableContext, List<User> agentList) {
        totalAgentOffices += agentList.size();
        Map<String, Integer> batchStatusMap = new AP_CreateMissingAgreeRiskShares().findAndCreateMissingShares(agentList);
        agentOfficesWithMissingShares += Integer.ValueOf(batchStatusMap.get(AGENT_OFFICES_MISSING_SHARES));
        totalPoliciesWithMissingShares += Integer.ValueOf(batchStatusMap.get(TOTAL_POLICIES_MISSING_SHARES));
    }
/**    
* @description finish
* @param batchableContext 
*/
    public void finish(Database.BatchableContext batchableContext) {
        Map<String, Integer> batchStatusMap = new Map<String, Integer>();
        batchStatusMap.put(TOTAL_AGENT_OFFICES, totalAgentOffices);
        batchStatusMap.put(AGENT_OFFICES_MISSING_SHARES, agentOfficesWithMissingShares);
        batchStatusMap.put(TOTAL_POLICIES_MISSING_SHARES, totalPoliciesWithMissingShares);
        new AP_CreateMissingAgreeRiskShares().createExceptionLogAsInfo(batchStatusMap);
    }
}