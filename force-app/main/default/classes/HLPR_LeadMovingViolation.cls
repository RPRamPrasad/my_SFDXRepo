/**
@description: this class is responsible for taking in Moving Violation for the lead Oppurutunity Object. It is part of a SOAP call from the TP (Techinal Platform)
Team: Orca
Owner: Dhaval Pawar (FIIO)
Date: 4/19/2017
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     fixed pmd violations
*/
/**
 * @description HLPR_LeadMovingViolation
 */
global with sharing class HLPR_LeadMovingViolation {

    webservice String violationType;
    webservice String violationDate;
    webservice String violationDescription;
}