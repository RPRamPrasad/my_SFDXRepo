/**
@description: this class is responsible for taking in Business Info for the lead coverage Object. It is part of a SOAP call from the TP (Techinal Platform)
Team: Orca
Owner: Dhaval Pawar (FIIO)
Date: 4/14/2017
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     pmb violation fixes
*/
/**
 * @description HLPR_LeadCoverage
 */
global with sharing class HLPR_LeadCoverage {

    webservice String deductible;
    webservice String description;
    webservice String coverageLimit;
    webservice String requestedOrCurrent;
    webservice String type;
}