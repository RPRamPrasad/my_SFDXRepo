/**
@description: this class is responsible for taking in Claim for the lead Oppurutunity Object. It is part of a SOAP call from the TP (Techinal Platform)
Team: Orca
Owner: Dhaval Pawar (FIIO)
Date: 4/14/2017
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     pmb violation fixes
*/
/**
 * @description HLPR_LeadClaim
 */
global with sharing class HLPR_LeadClaim {

    webservice String typeOfLoss;
    webservice String claimDate;
    webservice String amountPaid;
    webservice String description;
}