/**
 * @description This class will be used to test the Agreement Risk Share Utility Class
 * @Date: 09/17/20
 * @author: Jonathan Larkin VAASTT
 */
@isTest
(seeAllData = false)
public class UTIL_AgencyShares_TEST{

    /**
     * @description Setup Tests by generating agent data and bypassing the appropraite triggers.
     */
    @testsetup
    public static void testSetupData() {

        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

    }

    /** 
     * @description validate that we can succesfully create a map of proxies for two agents.
     */
    @isTest
    private static void getAgentProxyMapForTwoAgents() {

        Test.startTest();

        TestDataFactory_AgencyShares.createDataForSharesTesting();

        /**************************** Agents ****************************/
        User agentUser1 = [SELECT id, email  FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_ONE_EMAIL];
        User agentUser2 = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.AGENT_TWO_EMAIL];

        /**************************** Proxys ****************************/
        User proxyUser1 = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.PROXY_ONE_EMAIL];
        User proxyUser2 = [SELECT id, email FROM User WHERE email=:TestDataFactory_AgencyShares.PROXY_TWO_EMAIL];

        // Add Agents to the list, add one of them twice to validate it still works.
        List<id> agentIds = new List<id>();
        agentIds.add(agentUser1.id);
        agentIds.add(agentUser1.id);
        agentIds.add(agentUser2.id);

        Map<id,id> agentProxyMap = UTIL_AgencyShares.getAgentProxyMap(agentIds);

        // One entry for each agent should be returned
        System.assertEquals(2, agentProxyMap.size(), 'There should be exactly one entry for both agents.');

        //Verify that each agent maps to the appropriate proxy
        System.assertEquals(proxyUser1.id, agentProxyMap.get(agentUser1.id), 'Agent 3 mapped to the wrong proxy.');
        System.assertEquals(proxyUser2.id, agentProxyMap.get(agentUser2.id), 'Agent 2 mapped to the wrong proxy.');

        Test.stopTest();

    }




    /** 
     * @description validate exception handling.
     */
    @isTest
    private static void getAgentProxyMapException() {
        
        Test.startTest();

        // All we need for this test is an emtpy list, the test error will be thrown before we get too any real logic.
        List<id> agentId = new List<id>();

        /**************************** Throw DML Exception  ****************************/
        UTIL_AgencyShares.throwErrorForTest = new DmlException();
        Map<id,id> agentProxyMap = UTIL_AgencyShares.getAgentProxyMap(agentId);

        system.assert(agentProxyMap.isEmpty(), 'This assert should not fail');

        /**************************** Throw Query Exception  ****************************/
        UTIL_AgencyShares.throwErrorForTest = new QueryException();
        agentProxyMap = UTIL_AgencyShares.getAgentProxyMap(agentId);

        system.assert(agentProxyMap.isEmpty(), 'This assert should not fail');

        Test.stopTest();

    }




    /** 
    * @description Verify that Agent Proxy Map can handle an empty list of agents, without throwing an exception.
    */
    @isTest
    private static void getAgentProxyMapEmptyExternalMapId() {

        List<id> agentId = new List<id>();
        Map<id,id> agentProxyMap = UTIL_AgencyShares.getAgentProxyMap(agentId);

        System.assert(agentProxyMap.isEmpty(), 'This Assert should not fail');

    }
}
