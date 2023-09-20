/**
@description: this class is responsible for taking in Life Insured Info for the lead Oppurutunity Object. It is part of a SOAP call from the TP (Techinal Platform)
Team: Orca
Owner: Dhaval Pawar (FIIO)
Date: 4/14/2017
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     fixed pmd violations
*/
/**
 * @description HLPR_LeadLifeInsuredInfo
 */
global with sharing class HLPR_LeadLifeInsuredInfo {

    webservice String birthDate;
    webservice String employer;
    webservice String firstName;
    webservice String gender;
    webservice String healthCategory;
    webservice String height;
    webservice String lastName;
    webservice String maritalStatus;
    webservice String middleName;
    webservice String occupation;
    webservice String relationshipToOpportunity;
    webservice String smoker;
    webservice String timeWithEmployer;
    webservice String weight;
}