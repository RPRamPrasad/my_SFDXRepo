/**
@description: this class is responsible for taking in Dwelling for the lead Oppurutunity Object. It is part of a SOAP call from the TP (Techinal Platform)
Team: Orca
Owner: Dhaval Pawar (FIIO)
Date: 4/14/2017
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     fixed pmd violations
*/
/**
 * @description HLPR_LeadDwelling
 */
global with sharing class HLPR_LeadDwelling {

    webservice String constructionType;
    webservice String distanceFireHydrant;
    webservice String distanceFireStation;
    webservice String foundationType;
    webservice String hasCarportOrGarage;
    webservice String hasCentralAir;
    webservice String hasCoveredPatio;
    webservice String hasDeadboltLocks;
    webservice String hasDog;
    webservice String hasFireExtinguisher;
    webservice String hasFireSprinkler;
    webservice String hasPool;
    webservice String hasPoolFence;
    webservice String hasSecuritySystem;
    webservice String hasSmokeAlarm;
    webservice String heatingType;
    webservice String numberOfBathrooms;
    webservice String numberOfBedrooms;
    webservice String numberOfFireplaces;
    webservice String numberOfFloors;
    webservice String numberOfUnits;
    webservice String purchaseDate;
    webservice String roofType;
    webservice String type;
    webservice String value;
    webservice String wiringType;
    webservice String withinCityLimits;
    webservice String yearBuilt;
}