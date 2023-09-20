/**
Decription:This class is responsible for taking in Agent Associate Id and Notification flag information for REST Webservice WS_OpportunityApiRestEndpoint
Team: ClubCar
Date: 7/19/2018
*/
/**
 * @description  HLPR_AgentOfficeData
 */
global with sharing class HLPR_AgentOfficeData {
    webservice String agentAssociateID;
    webservice Boolean sendNotification;
}