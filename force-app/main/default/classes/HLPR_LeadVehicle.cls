/**
@description: this class is responsible for taking in Driver Claim for the lead Oppurutunity Object. It is part of a SOAP call from the TP (Techinal Platform)
Team: Orca
Owner: Dhaval Pawar (FIIO)
Date: 4/14/2017
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     fixed pmd violations
*/
/**
 * @description HLPR_LeadVehicle
 */
global with sharing class HLPR_LeadVehicle {

    webservice String airbagType;
    webservice String customizationAmount;
    webservice String discounts;
    webservice String estimatedAnnualMileage;
    webservice String make;
    webservice String mileageOneWay;
    webservice String model;
    webservice String odometerReading;
    webservice String ownership;
    webservice String submodel;
    webservice String vIN;
    webservice String year;
}