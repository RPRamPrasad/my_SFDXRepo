/**
Decription: this class is responsible for taking in Address for the lead Oppurutunity Object. It is part of a SOAP call from the TP (Techinal Platform)
Team: Orca
Owner: Dhaval Pawar (FIIO)
Date: 4/14/2017
*/
/**
 * @description HLPR_LeadAddress
 */
global with sharing class HLPR_LeadAddress {

    webservice String city;
    webservice String state;
    webservice String zip;
    webservice String type;
    webservice String address1;
    webservice String address2;
    webservice String careOf;
    webservice String country;
}