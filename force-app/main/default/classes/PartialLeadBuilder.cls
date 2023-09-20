/**
 * Author : Golden Spikes Team
 * Date Created : 10/08/2020
 * @description : This is a helper class for handling partial lead build from Create Lead Service.
 */
public with sharing class PartialLeadBuilder {
    private static final String HYPHEN_SYMBOL = '-';
    private static final String SEMICOLON_SEPERATOR = ';';
    private static final String FORWARD_SLASH_WITH_SPACE = ' / ';
    private static final String USER_EXTERNAL_ID_CONCATENATION_SYMBOL = '_';
    private static final String LEAD_PARTIAL_RECORD_TYPE_DEV_NAME = 'PartialLead';
    private static final String COUNTRY_US = 'US';
    private static final String STATE_FARM = 'State Farm';
    private static final String LEAD_DESCRIPTION_TARGET_LOB_STRING = '{LOBPRD}';
    private static String multiLob;
    private static String multiProduct;
/**
 * @description LeadRequest
 */
    public with sharing class LeadRequest {
        public HLPR_CreateLeadRequest.LeadInformation ldInfo;
        public Id agentProxySFDCID;
        public CMOpportunityMapping__mdt ldSourceMapping;
        public Boolean isCCCEligible;
    }
/**
 * @description buildLead
 * @param leadRequest 
 * @return  `Lead`
 */
    public static Lead buildLead(PartialLeadBuilder.LeadRequest leadRequest) {
        Lead newLead = new Lead();
        newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(LEAD_PARTIAL_RECORD_TYPE_DEV_NAME).getRecordTypeId();
        newLead.LeadSource = leadRequest.ldSourceMapping.LeadSource__c;
        setLeadLOBProduct(leadRequest.ldInfo.lobDetails);
        newLead.MultiLOB__c = multiLob;
        newLead.Product__c = multiProduct;
        if (String.isNotBlank(leadRequest.ldSourceMapping.Description__c)) {
            newLead.Description = getLeadDescription(leadRequest.ldInfo.lobDetails, leadRequest.ldSourceMapping.Description__c);
        }
        newLead.OwnerId = leadRequest.agentProxySFDCID;
        newLead.Country = COUNTRY_US;
        if (String.isNotBlank(leadRequest.ldInfo.firstName)) {
            newLead.FirstName = (leadRequest.ldInfo.firstName).left(40);
        }
        if (String.isNotBlank(leadRequest.ldInfo.lastName)) {
            newLead.LastName = (leadRequest.ldInfo.lastName).left(80);
        }
        newLead.Street = leadRequest.ldInfo.addressInfo.street;
        newlead.City = leadRequest.ldInfo.addressInfo.city;
        if (leadRequest.ldInfo.addressInfo.state != null) {
            newLead.State = leadRequest.ldInfo.addressInfo.state.trim().toUpperCase();
        }
        newLead.PostalCode = leadRequest.ldInfo.addressInfo.postalCode;
        newLead.Email = leadRequest.ldInfo.email;
        newLead.SubmittedMobilePhoneNumber__c = leadRequest.ldInfo.mobilePhone;
        newLead.Submitted_Phone_Number__c = leadRequest.ldInfo.phone;
        newLead.External_Lead_ID__c = leadRequest.ldInfo.externalLeadId;
        newLead.DateCaptured__c = leadRequest.ldInfo.capturedDateTime;
        newLead.SCode__c = leadRequest.ldInfo.sCode;
        newLead.AgentAssociateId__c = leadRequest.ldInfo.agentAssociateID;
        newLead.Agent__r = new User(UserExternalID__c = leadRequest.ldInfo.agentAssociateID + USER_EXTERNAL_ID_CONCATENATION_SYMBOL + leadRequest.ldInfo.agentAssociateID);
        if (leadRequest.isCCCEligible) {
            newLead.SourcedFromCCC__c = true;
        }
        newLead.VendorId__c = leadRequest.ldInfo.vendorID;
        newLead.LeadScore__c = leadRequest.ldInfo.leadScore;
        newLead.LeadTemperature__c = getLeadTemperature(leadRequest.ldInfo.leadScore);
        if (leadRequest.ldInfo.leadEstimatorInfo != null) {
            newLead.BusinessType__c = leadRequest.ldInfo.leadEstimatorInfo.typeOfBusiness;
            newLead.WorkLocation__c = leadRequest.ldInfo.leadEstimatorInfo.workLocation;
            newLead.InventoryEquipmentCoverage__c = leadRequest.ldInfo.leadEstimatorInfo.contentsAmount;
            newLead.LiabilityCoveragelimit__c = leadRequest.ldInfo.leadEstimatorInfo.additionalLiabilityAmount;
            newLead.EstimatedPremium__c = leadRequest.ldInfo.leadEstimatorInfo.premium;
            newLead.LiabilityAmount__c = leadRequest.ldInfo.leadEstimatorInfo.liabilityAmount;
            newLead.PayrollAmount__c = leadRequest.ldInfo.leadEstimatorInfo.payrollAmount;
            newLead.SquareFootageAmount__c = leadRequest.ldInfo.leadEstimatorInfo.squareFootageAmount;
            newLead.NumberOfOwners__c = leadRequest.ldInfo.leadEstimatorInfo.numberOfOwners;
            newLead.NumberOfDens__c = leadRequest.ldInfo.leadEstimatorInfo.numberOfDens;
            newLead.EstimatedAnnualSales__c = leadRequest.ldInfo.leadEstimatorInfo.estimatedAnnualSales;
        }
        return newLead;
    }

    private static String getLeadDescription(List<HLPR_CreateLeadRequest.LineOfBusinessDetails> lobList, String inputLeadDescription) {
        if (lobList != null && !lobList.isEmpty()) {
            String leadDecription = '';
            Integer count = 0;
            for (HLPR_CreateLeadRequest.LineOfBusinessDetails lobDetail : lobList) {
                String product = '';
                if (String.isNotBlank(lobDetail.product)) {
                    product = HYPHEN_SYMBOL + (lobDetail.product);
                }
                leadDecription = count > 0 ? leadDecription + FORWARD_SLASH_WITH_SPACE + lobDetail.lob + product : lobDetail.lob + product;
                count++;
            }
            inputLeadDescription = inputLeadDescription.replace(LEAD_DESCRIPTION_TARGET_LOB_STRING, leadDecription);
        }
        inputLeadDescription = inputLeadDescription.replace(LEAD_DESCRIPTION_TARGET_LOB_STRING, STATE_FARM);
        return inputLeadDescription;
    }

    private static void setLeadLOBProduct(List<HLPR_CreateLeadRequest.LineOfBusinessDetails> lobList) {
        multiLob = '';
        multiProduct = '';
        Integer count = 0;
        if (lobList != null && !lobList.isEmpty()) {
            for (HLPR_CreateLeadRequest.LineOfBusinessDetails lobDetail : lobList) {
                multiLob = count > 0 ? multiLob + SEMICOLON_SEPERATOR + lobDetail.lob : lobDetail.lob;
                multiProduct = count > 0 ? multiProduct + SEMICOLON_SEPERATOR + lobDetail.product : lobDetail.product;
                count++;
            }
        }
    }
    
    //method to get the Lead Temperature based on the Lead Score value
    private static String getLeadTemperature(Decimal leadScore) {
        String leadTemperature = 'Urgent';
        if(leadScore < 1) {
            leadTemperature = '';
        }
        else if(leadScore < 5) {
            leadTemperature = 'Warm';
        }
        else if(leadScore < 8) {
            leadTemperature = 'Hot';
        }
        return leadTemperature;
    }
}
