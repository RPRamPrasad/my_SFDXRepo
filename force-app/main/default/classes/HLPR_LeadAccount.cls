/**
@description: this class is responsible for taking in lead info for the Account Object. It is part of a SOAP call from the TP (Techinal Platform)
Will also provide input for REST Webservice WS_OpportunityApiRestEndpoint (07/19/2018)
Team: ImpactForce
Owner: Wyatt Lansdale (F0AS)
Date: 8/31/2016
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     fixed pmd violations
*/
/**
 * @description HLPR_LeadAccount
 */
global with sharing class HLPR_LeadAccount {

    webservice String clientID;
    webservice String accountType;
    
    webservice String phone;
    webservice String emailAddress;
    webservice String firstName;
    webservice String lastName;
    webservice String address;
    webservice String address2;
    webservice String city;
    webservice String country;
    webservice String state;
    webservice String zip;
    
    
    //Below variables are created for Phone Defect fix
    webservice String workPhoneExtension;
    webservice String personMobilePhone;
    webservice String personHomePhone;
    webservice String tDDPhone;
    webservice String hasPermissionToServiceText;
    webservice String hasPermissiontoText;
    webservice String hasPermissionToClaimText;
    webservice Boolean personDoNotCall=false; 
    webservice Boolean isHearingImpaired=false;
}