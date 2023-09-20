/**
* Author : Golden Spikes Team
* Date Created : 10/18/2018
* @description : This apex class is used to perform queries(without FLS/Object access check) by quote lightning components.
*/

public with sharing class UTIL_LtngQuoteDataAccess {
    /**
     * @description method to performQueryOnQuoteODATASummary
     * @param paramLOB
     * @param paramClientIdentifier
     * @param paramServicingAgentAssociateId
     * @return existingOpportunityQuoteMap
     */
    public static List<Quotes__x> performQueryOnQuoteODATASummary(String paramLOB, String paramClientIdentifier, String paramServicingAgentAssociateId) {
        return [Select id, ApplicantFirstName__c, ApplicantLastName__c, ApplicantSuffix__c, ApplicantOrganizationName__c, ApplicantCity__c, 
            ApplicantStateCode__c, ApplicantAddressLine1__c, ApplicantAddressLine2__c, ApplicantPostalCode__c, CurrentInsurer__c, QuoteMonthlyPremiumAmount__c,
            QuoteTotalPremiumAmount__c, VehicleExpirationDate__c, QuoteEffectiveDate__c, QuotePayloadIdentifier__c
            from Quotes__x WHERE LineOfBusiness__c =: paramLOB AND ClientId__c =: paramClientIdentifier 
            AND AssociateId__c =: paramServicingAgentAssociateId];
    }
    /**
     * @description method to performQueryOnQuoteODATADetail
     * @param paramSelectedQuotePayLoadSet
     * @return existingOpportunityQuoteMap
     */
    public static List<QuoteDetails__x> performQueryOnQuoteODATADetail(Set<String> paramSelectedQuotePayLoadSet) {
        return [Select QuotePayloadIdentifier__c, VehicleInfo__c, DriverInfo__c from QuoteDetails__x 
                                    WHERE QuotePayloadIdentifier__c in: paramSelectedQuotePayLoadSet];
    }
    /**
     * @description method to performQueryOnOpportunity
     * @param paramOpportunityId
     * @return opportunitydetails
     */
    public static List<Opportunity> performQueryOnOpportunity(String paramOpportunityId) {
        return [Select id, name,status__c, owner.Servicing_Agent_Associate_ID__c, LOB__c, Product__c, Account.ClientIdentifier__c, 
                        Account.name, stageName, Assigned_To__c,Quote_Received__c from Opportunity WHERE id =: paramOpportunityId Limit 1];
    }
    /**
     * @description method to performQueryOnQuote
     * @param paramQuoteId
     * @return Quotedetails
     */
    public static Quote__c performQueryOnQuote(String paramQuoteId) {
        return [Select Id, Name, MonthlyPremium__c, TotalPremiumAllVehicles__c, Opportunity__c, PrimaryQuote__c,
                CurrentInsurerName__c, XDate__c, RecordTypeId from Quote__c Where Id =: paramQuoteId limit 1];
    }
    /**
     * @description method to performQueryOnUser
     * @return SubUserType
     */
    public static String performQueryOnUser() {
        return [SELECT SubUserType__c FROM User WHERE Id =: UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1]?.SubUserType__c;
    }
}