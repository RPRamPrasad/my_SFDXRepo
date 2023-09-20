/**
@description: this class is responsible for taking in Driver for the lead Oppurutunity Object. It is part of a SOAP call from the TP (Techinal Platform)
Team: Orca
Owner: Dhaval Pawar (FIIO)
Date: 4/14/2017
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     pmb violation fixes
*/
/**
 * @description HLPR_LeadDriver
 */
global with sharing class HLPR_LeadDriver {

    webservice String ageFirstDrivingLicenseIssued;
    webservice String bankruptcy;
    webservice String bankruptcyDate;
    webservice String birthDate;
    webservice String creditStanding;
    webservice String dateLicenseWasIssued;
    webservice String discounts;
    webservice String education;
    webservice String employed;
    webservice String employerAddress;
    webservice String employerName;
    webservice String firstName;
    webservice String gender;
    webservice String goodStudent;
    webservice String lastName;
    webservice String licenseNumber;
    webservice String maritalStatus;
    webservice String middleName;
    webservice String occupation;
    webservice String relationToOpportunity;
    webservice String stateLicenseIssued;
    webservice String timeWithEmployer;
    webservice String training;
    webservice String trainingCompletedDate;
}