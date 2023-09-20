/****************************************************************************************
Name: HLPR_CreateOppRequest
=========================================================================================
Decription: 
 This class will accept Inputs for the REST Webservice WS_OpportunityApiRestEndpoint.
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.00            Team ClubCar            7/19/2018               Initial Development
******************************************************************************************/
/**
 * @description HLPR_CreateOppRequest
 */
global with sharing class HLPR_CreateOppRequest {
    webservice HLPR_LeadAccount accountData;
    webservice HLPR_AgentOfficeData agentOfficeData;
    webservice HLPR_LeadOpportunity opportunityData;
    webservice String status;
}