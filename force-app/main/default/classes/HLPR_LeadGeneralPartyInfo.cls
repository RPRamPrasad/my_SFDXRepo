/**
@description: this class is responsible for taking in General Party Info for the lead Oppurutunity Object. It is part of a SOAP call from the TP (Techinal Platform)
Team: Orca
Owner: Dhaval Pawar (FIIO)
Date: 4/13/2017
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     fixed pmd violations
*/
/**
 * @description HLPR_LeadGeneralPartyInfo
 */
global with sharing class HLPR_LeadGeneralPartyInfo {
    
    webservice String citizenship;
    webservice String contactPreference;
    webservice String designation;
    webservice String email;
    webservice String firstName;
    webservice String language;
    webservice String lastName;
    webservice String middleName;
    webservice String militaryService;
    webservice String homePhone;
    webservice String mobilePhone;
    webservice String workPhone;
    webservice String workExtension;
    webservice String tDDPhone;
    webservice String insuranceRenewalDate;
    webservice String monthsWithCarrier;
    webservice String totalYearsInsured;
    webservice String insuranceCancellation;
    webservice String nameOfCarrier;
    webservice String insuranceCancellationDate;
    webservice String insuranceCancellationReason;
    webservice List<HLPR_LeadAddress> leadAddressList;
    webservice List<HLPR_LeadClaim> leadClaimList;
    webservice List<HLPR_LeadDriver> leadDriverList;
    webservice List<HLPR_LeadMovingViolation> leadMovingViolationList;
    webservice List<HLPR_LeadVehicle> leadVehicleList;
    webservice List<HLPR_LeadDwelling> leadDwellingList;
    webservice List<HLPR_LeadBusinessInfo> leadBusinessInfoList;
    webservice List<HLPR_LeadLifeInsuredInfo> leadLifeInsuredInfoList;
    webservice List<HLPR_LeadCoverage> leadCoverageList;
}