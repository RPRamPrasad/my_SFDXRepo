/**
* @description : this class is responsible for taking in leads. . It is part of a SOAP call from the TP (Techinal Platform)
Team: Dream Builders
Owner: kavitha Boppudi(F1A1)
Date: 02/03/2017
*/

global with sharing class HLPR_SFComLeadRequest {
   webservice HLPR_LeadAccount leadaccount;
   webservice HLPR_LeadAgentRole leadagentrole;
   webservice HLPR_LeadOpportunity leadopportunity;
   webservice String status;
}