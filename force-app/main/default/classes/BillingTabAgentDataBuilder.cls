/**
* Author : Team Kraken
* Date Created : 2/12/21
* @description : Used to build BillingAccountData AgentData model.
*/

public inherited sharing class BillingTabAgentDataBuilder extends BillingTabModels {
    
    private BillingTabAgentDataBuilder(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('BillingTabAgentDataBuilder', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }

    /**
     * @description format data and use it to populate the agentData Object. 
     * @param stateAgentCode
     * @param agent
     * @return AgentData
     */
    public static AgentData buildAgentData(String stateAgentCode, User agent) {

        AgentData agentData = new AgentData(stateAgentCode);

        if(stateAgentCode != null && agent != null) {
            buildAgentNameAndCodes(agentData, agent.Name);
            buildAgentUrl(agentData);
        }

        return agentData;

    }

    /**
     * @description buildAgentData
     * @param stateAgentCode 
     * @param agentName 
     * @return  `AgentData`
     */
    public static AgentData buildAgentData(String stateAgentCode, String agentName) {

        AgentData agentData = new AgentData(stateAgentCode);
        if(stateAgentCode != null && agentName != null) {
            buildAgentNameAndCodes(agentData, agentName);
            buildAgentUrl(agentData);
        }

        return agentData;

    }

    /**
     * @description Determine if agent name is for standard or SFO agent, then send
     * to the appropriate method for formatting.
     * @param agentData
     * @param agentName
     */
    private static void buildAgentNameAndCodes(AgentData agentData, String agentName) {

        Pattern myPattern = Pattern.compile('[0-9]{2}-[0-9]{4} SFO ');
        Matcher myMatcher = myPattern.matcher(agentName);

        if(myMatcher.find()) {
            formatSFOAgentName(agentData, agentName, myMatcher);
        } else {
            formatStandardAgentName(agentData, agentName);
        }
        
    }

    /**
     * @description Format Agent Name.
     * @param agentData
     * @param agentName
     */
    private static void formatStandardAgentName(AgentData agentData, String agentName) {
        List<String> stateAndAgentCode = agentData.stateAgentCode.split('-', 2);
        agentData.stateCode = stateAndAgentCode[0];
        agentData.agentCode = stateAndAgentCode[1];
        agentData.servicingAgentName = agentName.split(',')[0];
    }

    /**
     * @description Format SFO Agent Name.
     * @param agentData
     * @param agentName
     * @param myMatcher
     */
    private static void formatSFOAgentName(AgentData agentData, String agentName, Matcher myMatcher ) {
        String foundString = myMatcher.group();
        agentData.stateCode = foundString.substring(0,2);
        agentData.agentCode = foundString.substring(3,7);
        agentData.servicingAgentName = agentName.substring(8).split(',')[0];
}

    /**
     * @description Build Agent URL, it will have different values for SFO vs Standard Agents.
     * @param agentData
     */
    private static void buildAgentUrl(AgentData agentData) {
        agentData.servicingAgentUrl = '/c/ExternalLinkApp.app?linkId=26' + '&primaryStateCode=' + 
        agentData.stateCode + '&primaryAgentCode=' + agentData.agentCode;

    }
}
