/**
@description: this class is responsible for taking in lead info for the Oppurutunity Object. It is part of a SOAP call from the TP (Techinal Platform)
Will also provide input for REST Webservice WS_OpportunityApiRestEndpoint (07/19/2018)
Team: ImpactForce
Owner: Wyatt Lansdale (F0AS)
Date: 8/31/2016
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     fixed pmd violations
*/
/**
 * @description HLPR_LeadOpportunity
 */
global with sharing  class HLPR_LeadOpportunity {

    webservice String name;
    webservice String stageName;
    webservice String leadType;
    webservice String lOB;
    webservice String opportunity_Originator;
    webservice String marketingSource;
    webservice String marketingSubSource;
    webservice String recordType;    
    webservice String product;
    webservice String eventCode;
    webservice String opportunityDetail;
    webservice Decimal prospectCost;
    webservice String subsidy;
    webservice Decimal subsidyAmount;
    webservice String leadId;
    webservice String email;
    webservice String phone;
    webservice String leadTransactionId;
    webservice String vendorId;
    webservice id simpleId;
    webservice String validatorID;
    webservice String temperature;
    webservice String description;
    webservice HLPR_LeadGeneralPartyInfo leadGeneralPartyInfo; 
    webservice String sourceComments;
    webservice String status;
    webservice String subStatus;
    webservice String entryWebProperty;
    webservice String agentProperty;
    webservice String referringDomain;
    webservice String campaignID;
    webservice String marketingChannel;
    webservice Integer appCode;
    webservice String externalId;
    Webservice String productSystemName;
    Webservice Date effectiveDate;
    Webservice String stateCode;
    webservice Boolean doNotDedup;
}