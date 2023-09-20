/**
@description: this class is responsible for taking in Business Info for the lead Oppurutunity Object. It is part of a SOAP call from the TP (Techinal Platform)
Team: Orca
Owner: Dhaval Pawar (FIIO)
Date: 4/14/2017
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     pmb violation fixes 
*/
/**
 * @description HLPR_LeadBusinessInfo
 */
global with sharing class HLPR_LeadBusinessInfo {

    webservice String annualGrossSale;
    webservice String description;
    webservice String estimatedAnnualCostRentLease;
    webservice String hasRentedLeasedVehicle;
    webservice String jobDuties;
    webservice String numberOfEmployees;
    webservice String payrollCosts;
    webservice String subcontractedDuties;
    webservice String totalCosts;
    webservice String type;
    webservice String yearsInBusiness;
}