/****************************************************************************************
Name: HLPR_UpdateOppRequest
=========================================================================================
Decription: 
 This class will accept Inputs for the REST Webservice WS_UpdateOpportunity.
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.00            Team Akita            10/03/2018               Initial Development
******************************************************************************************/
/**
 * @description HLPR_UpdateOppRequest
 */
global with sharing class HLPR_UpdateOppRequest {
    
    webservice HLPR_AgentOfficeData agentOfficeData;
    webservice HLPR_UpdateOpportunityData updateOpportunityData;
}