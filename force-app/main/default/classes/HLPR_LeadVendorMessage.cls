/**
@description: this class is responsible for taking in leads. . It is part of a SOAP call from the TP (Techinal Platform)
Team: ImpactForce
Owner: Wyatt Lansdale (F0AS)
Date: 8/31/2016
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     fixed pmd violations
*/
/**
 * @description HLPR_LeadVendorMessage
 */
global with sharing class HLPR_LeadVendorMessage {
   
   webservice HLPR_LeadAccount leadaccount;
   webservice HLPR_LeadAgentRole leadagentrole;
   webservice HLPR_LeadOpportunity leadopportunity;
   webservice String status;
}