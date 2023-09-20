/**
* @Name LeadConversionController 
* @Author Golden Spikes Team
* @Description This is a helper class to create Opportunity records on Lead Conversion.
* @description HLPR_OppCreateOnLeadConversion
*/
public with sharing class HLPR_OppCreateOnLeadConversion {
    private static final String HYPEN = '-';
    private static final String SPACE = ' ';
    private static final Integer OPPORTUNITY_NAME_SIZE_LIMIT = 120;
    private static final String OPPORTUNITY_MAPPING_TYPE = 'Lead Conversion';
    private static final String SUB_USER_TYPE_CCC = 'CCC Sales';
    private static final String OPPORTUNITY_STAGE_NAME = 'New';
    private static final String OPPORTUNIY_MGMT_RECORD_TYPE_NAME = 'Opportunity_Management';
    private static final String DEFAULT_OPPORTUNITY_ORIGINATOR = 'Agent/Team Member';
    private static final String OPPORTUNITY_ORIGINATOR_CCC = 'Customer Care Center';
    private static final String OPPORTUNITY_QUOTING_STAGE_NAME = 'Quoting';
    private static final String OPPORTUNITY_QUOTING_STATUS_NAME = 'Quote In Progress';
    private static final String INTERNET_LEAD_PROVIDER_QUOTE_WIZARD = 'Internet Lead Provider - QuoteWizard';
    private static final String QUOTE_WIZARD_VENDOR_ID = 'ILP1';
    private static final String QUOTE_WIZARD_LEAD_TYPE = 'AUTOSTDUSL';
    private static String opportunityOriginator = DEFAULT_OPPORTUNITY_ORIGINATOR;
    private static String marketingSource = '';
    private static String marketingSubSource = '';
/**
 * @description OpportunityCreateRequest
 */
    public with sharing class OpportunityCreateRequest {
        /**
         * @description leadRecord
         */
        @AuraEnabled public Lead leadRecord {get; set;}
        /**
         * @description actId
         */
        @AuraEnabled public Id actId {get; set;}
        /**
         * @description lobValues
         */
        @AuraEnabled public String lobValues {get; set;}
        /**
         * @description loggedInUserSubUserType
         */
        @AuraEnabled public String loggedInUserSubUserType {get; set;}
        /**
         * @description campaignId
         */
        @AuraEnabled public Id campaignId {get; set;}
        /**
         * @description stateCode
         */
        @AuraEnabled public String stateCode {get; set;}
    }

    //method to create opportunities on lead conversion
    /**
     * @description createOpportunities
     * @param optyCreateRequest 
     * @param act 
     * @return  `List<Opportunity>`
     */
    public static List<Opportunity> createOpportunities(HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest optyCreateRequest, Account act) {
        List<Opportunity> optyToBeInserted = new List<Opportunity>();
        Id opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OPPORTUNIY_MGMT_RECORD_TYPE_NAME).getRecordTypeId();
        setOpportunityMappingValues(optyCreateRequest.leadRecord.LeadSource, optyCreateRequest.loggedInUserSubUserType);
        String opportunityOwnerId = getOpportunityOwnerId(optyCreateRequest.loggedInUserSubUserType, optyCreateRequest.leadRecord);
        List<LWC_NewOpportunityWorkflow.ProductLineItem> parsedData = (List<LWC_NewOpportunityWorkflow.ProductLineItem>)JSON.deserialize(optyCreateRequest.lobValues, List<LWC_NewOpportunityWorkflow.ProductLineItem>.class);
        List<LWC_NewOpportunityWorkflow.ProductLineItem> sortedLOBs = LWC_NewOpportunityWorkflow.sortLOBsBasedOnPriority(parsedData);
        for(LWC_NewOpportunityWorkflow.ProductLineItem lob :sortedLOBs) {
                Opportunity opty = new Opportunity(
                    CloseDate = Date.today() + 60,
                    Opportunity_Originator__c = opportunityOriginator,
                    Marketing_Source__c = marketingSource,
                    Marketing_Sub_Source__c = marketingSubSource,
                    RecordTypeId = opportunityRecordTypeId,
                    AccountId = act.Id,
                    Name = buildOpportunityName(lob.selectedLineOfBusiness, act.FirstName, act.LastName),
                    LOB__c = lob.selectedLineOfBusiness,
                    Product__c = lob.selectedProduct?.productDescription,
                    Requested_Effective_Date__c = lob.selectedEffectiveDate,
                    State_Code__c = optyCreateRequest.stateCode,
                    Product_System_Name__c = lob.selectedProduct?.productSystemName,
                    JointType__c = String.isNotEmpty(lob.jointType) ? lob.jointType : null,
                    AdditionalOwner__c = String.isNotEmpty(lob.additionalOwner) ? lob.additionalOwner: null,
                    OwnerId = opportunityOwnerId,
                    EventCode__c = validateLobForSCode(optyCreateRequest.leadRecord.MultiLOB__c, lob.selectedLineOfBusiness) ? optyCreateRequest.leadRecord.SCode__c : '',                    
                    LeadSource = optyCreateRequest.leadRecord.LeadSource,
                    DateCaptured__c = optyCreateRequest.leadRecord.DateCaptured__c,
                    CampaignId = optyCreateRequest.campaignId,
                    ExternalILPId__c = optyCreateRequest.leadRecord.VendorId__c,
                    ExternalID__c = optyCreateRequest.leadRecord.External_Lead_ID__c,
                    Lead_ID__c = optyCreateRequest.leadRecord.Id,
                    StageName = OPPORTUNITY_STAGE_NAME
                );
                if(INTERNET_LEAD_PROVIDER_QUOTE_WIZARD.equals(optyCreateRequest.leadRecord.LeadSource)) {
                    opty.Vendor_ID__c = QUOTE_WIZARD_VENDOR_ID;
                    opty.LeadType__c = QUOTE_WIZARD_LEAD_TYPE;
                }
                optyToBeInserted.add(opty);
        }
        return handleOpportunityCreation(optyToBeInserted);
    }

    //method to create opportunities on lead conversion for selected LOBs
    /**
     * @description handleOpportunityCreation
     * @param optyToBeInserted 
     * @param List<Opportunity>
     * @return  `List<Opportunity>`
     */
    private static List<Opportunity> handleOpportunityCreation(List<Opportunity> optyToBeInserted) {
        if (!optyToBeInserted.isEmpty() && Schema.sObjectType.Opportunity.isUpdateable() && String.isNotBlank(optyToBeInserted[0].Product__c)) {
            optyToBeInserted[0].StageName = OPPORTUNITY_QUOTING_STAGE_NAME;
            optyToBeInserted[0].Status__c = OPPORTUNITY_QUOTING_STATUS_NAME;
            optyToBeInserted[0].Assigned_To__c =  UserInfo.getUserId();
            optyToBeInserted[0].OppQuoteInProgressDateTime__c = System.now();
            optyToBeInserted[0].OppContactEstablishedDateTime__c = System.now();
            optyToBeInserted[0].OppAssignedDateTime__c = System.now();
            optyToBeInserted[0].Sales_Attempts__c = 1;
        }
        if (!optyToBeInserted.isEmpty() && Schema.sObjectType.Opportunity.isCreateable()) {
            Database.insert(optyToBeInserted);
        }
        return optyToBeInserted;
    }
    
    //method to validate lob for SCode population
    private static Boolean validateLobForSCode(String lobList, String lob) {
        Boolean isSCodeToBePopulated = false;
        if (String.isNotBlank(lobList)) {
            isSCodeToBePopulated = ((lobList).toUpperCase()).contains(lob.toUpperCase());
        }
        return isSCodeToBePopulated;
    }

    //method to set the opportunity mapping values using custom metadata
    private static void setOpportunityMappingValues(String leadSource, String loggedInUserSubUserType) {
        if (String.isNotBlank(leadSource)) {
            for (CMOpportunityMapping__mdt optyMappingMDT : [SELECT LeadSource__c, OpportunityOriginator__c, MarketingSource__c, MarketingSubSource__c FROM CMOpportunityMapping__mdt
                WHERE MappingType__c = :OPPORTUNITY_MAPPING_TYPE AND LeadSource__c = :leadSource WITH SECURITY_ENFORCED LIMIT 1]) {
                opportunityOriginator = SUB_USER_TYPE_CCC.equals(loggedInUserSubUserType) ? OPPORTUNITY_ORIGINATOR_CCC : optyMappingMDT.OpportunityOriginator__c;
                marketingSource = optyMappingMDT.MarketingSource__c;
                marketingSubSource = optyMappingMDT.MarketingSubSource__c;
            }
        }
    }

    //method to get the opportunity ownerId
    private static String getOpportunityOwnerId(String loggedInUserSubUserType, Lead leadRecord) {
        String opportunityOwnerId = '';
        if (SUB_USER_TYPE_CCC.equals(loggedInUserSubUserType)) {
            opportunityOwnerId = [SELECT ID FROM User WHERE UserExternalID__c =: leadRecord.AgentAssociateId__c + 'P' WITH SECURITY_ENFORCED LIMIT 1]?.Id;
        } else {
            opportunityOwnerId = leadRecord.ownerId;
        }
        return opportunityOwnerId;
    }

    //method to build the opportunity name
    private static String buildOpportunityName(String paramLOB, String paramAccountFirstName, String paramAccountLastName) {
        String opportunityName = paramLOB + HYPEN;
        if (String.isNotBlank(paramAccountFirstName)) {
            opportunityName += paramAccountFirstName + SPACE;
        }
        opportunityName += paramAccountLastName;
        return opportunityName.left(OPPORTUNITY_NAME_SIZE_LIMIT);
    }
}