/**
* @Name LeadConversionController
* @Author Golden Spikes Team
* @description This is a utility class that implements removal of CampaignMembers and custom Lead Conversion
*/
public with sharing class LeadConversionController {
    private static final String CLASS_NAME = 'LeadConversionController';
    private static final String CONVERT_LEAD_METHOD_NAME = 'convertLead';
    private static final String UPDATE_LEAD_METRICS_METHOD_NAME = 'updateLeadMetrics';
    private static final String CONVERTED_STATUS = 'Converted';
    private static final String CAMPAIGN_REMOVAL_METHOD_NAME = 'campaignRemoval';
    private static final String OPPORTUNITY_CREATE_METHOD_NAME = 'createOpportunities';
    private static final String LEAD_ID = 'Lead ID: ';
    private static final String ACC_ID = 'Account ID: ';
    private static final String US = 'US';
    private static final String LEAD_REFERRAL_RECORD_TYPE_DEV_NAME = 'SF_Referral';
    private static final String LEAD_PARTIAL_RECORD_TYPE_DEV_NAME = 'PartialLead';
    private static final String HYPEN = '-';
    private static String convertedOpportunityIdsForMetrics = '';
    private static final String LEAD_ID_PARAMETER = 'leadId';
/**
 * @description ConvertLeadWrapper
 */
    public with sharing class ConvertLeadWrapper {
        /**
         * @description leadRecord
         */
        @AuraEnabled public Lead leadRecord { get; set; }
        /**
         * @description rtMapByName
         */
        @AuraEnabled public Map<String, String> rtMapByName { get; set; }
        /**
         * @description subUserType
         */
        @AuraEnabled public String subUserType { get; set; }
        /**
         * @description appName
         */
        @AuraEnabled public String appName { get; set; }
    }
/**
 * @description fetchLeadDataWrapper
 * @param leadId 
 * @return  `ConvertLeadWrapper`
 */
    public static ConvertLeadWrapper fetchLeadDataWrapper(String leadId) {
        ConvertLeadWrapper wrapRec = new ConvertLeadWrapper();
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId(LEAD_ID_PARAMETER, leadId, Lead.class);
        wrapRec.leadRecord = UTIL_LeadDAO.getLeadInfo(leadId);
        wrapRec.rtMapByName = getAccountRTMap();
        wrapRec.appName = 'ECRM 3.0';
        wrapRec.subUserType = [SELECT SubUserType__c FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED Limit 1]?.SubUserType__c;
        return wrapRec;
    }

    private static Map<String, String> getAccountRTMap() {
        Map<String, String> rtMapByName = new Map<String, String>();
        for (Schema.RecordTypeInfo rtInfo : Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.FULL).getRecordTypeInfos()) {
            if (UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME.equalsIgnoreCase(rtInfo.getDeveloperName()) || UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME.equalsIgnoreCase(rtInfo.getDeveloperName())) {
                rtMapByName.put(rtInfo.getName(), String.valueOf(rtInfo.getRecordTypeId()));
            }
        }
        return rtMapByName;
    }

    //entry point method for convertLead
    /**
     * @description convertLead 
     * @param leadId 
     * @param accId 
     * @return  `Boolean`
     */
    @AuraEnabled
    public static Boolean convertLead(Id leadId, Id accId) {
        Boolean success = false;
        Boolean canBeConverted = true;
        Lead leadRecord = [SELECT Id, RecordType.DeveloperName FROM Lead WHERE Id = :leadId WITH SECURITY_ENFORCED LIMIT 1];
        if (!(LEAD_REFERRAL_RECORD_TYPE_DEV_NAME.equals(leadRecord.RecordType.DeveloperName) || LEAD_PARTIAL_RECORD_TYPE_DEV_NAME.equals(leadRecord.RecordType.DeveloperName))) {            
            canBeConverted = campaignRemoval(leadId, accId); // Removing all the associated Campaigns before LeadConversion
        }
        if (canBeConverted) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadid(leadId);
            lc.setAccountid(accId);
            lc.SetOverWriteLeadSource(false);
            lc.setConvertedStatus(CONVERTED_STATUS);
            lc.setDoNotCreateOpportunity(true);
            try {
                AP_AccountTrigger.iAmTrustworthy = true;
                Database.convertLead(lc);
                Database.update(new Account(Id = accId, Edit_In_VFP__c = true, IsSourcedFromLead__c = true));
                success = true;
            } catch (DMLException convertError) {
                success = false;
                convertError.setMessage(LEAD_ID + leadId + ACC_ID + accId + ' ' + convertError.getMessage());
                LoggingService.logHandledException(convertError, CLASS_NAME, CONVERT_LEAD_METHOD_NAME, LoggingLevel.ERROR);
            }
        }
        return success;
    }

    //method for removing all the CampignMembers who are already converted from Lead to Prospect
    private static Boolean campaignRemoval(Id leadId, Id accId) {
        Boolean isError = false;
        List<CampaignMember> listCM = [SELECT Id FROM CampaignMember WHERE LeadId = :LeadId WITH SECURITY_ENFORCED];
        Savepoint sp = Database.setSavepoint();
        try {
            if(!listCM.isEmpty()) {
                List<CampaignMember> updatedCampaignMemberlist = new List<CampaignMember>();
                for (CampaignMember cm : listCM) {
                    cm.WillConvert__c = true;
                    updatedCampaignMemberlist.add(cm);
                }
                update Security.stripInaccessible(AccessType.UPDATABLE, updatedCampaignMemberlist).getRecords();
                if(Schema.sObjectType.CampaignMember.isDeletable()) {
                    Database.delete(updatedCampaignMemberlist);
                }
            }
        } catch(DMLException cleanUpException) {
            Database.rollback(sp);
            cleanUpException.setMessage(LEAD_ID + leadId + ACC_ID + accId + ' ' + cleanUpException.getMessage());
            LoggingService.logHandledException(cleanUpException, CLASS_NAME, CAMPAIGN_REMOVAL_METHOD_NAME, LoggingLevel.ERROR);
            isError=true;
        }
        return !isError;
    }

    //entry point method for handling opportunity creation/creating stage orchestration for lead conversion/updating lead metrics
    /**
     * @description handleOpportunities
     * @param optyCreateRequest 
     * @return  `String`
     */
    @AuraEnabled
    public static String handleOpportunities(HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest optyCreateRequest) {
        String convertedOpportunityIds = '';
        convertedOpportunityIdsForMetrics = '';
        List<String> convertedOpportunityIdWithLOBList = new List<String>();
        List<opportunity> insertedOpportunity = new List<Opportunity>();
        try {
            Account act = [SELECT Id, ClientIdentifier__c, FirstName, LastName FROM Account WHERE Id = :optyCreateRequest.actId WITH SECURITY_ENFORCED LIMIT 1];
            if (String.isNotBlank(optyCreateRequest.lobValues)) {
               insertedOpportunity = HLPR_OppCreateOnLeadConversion.createOpportunities(optyCreateRequest, act);
                for (Opportunity opty : insertedOpportunity) {
                    convertedOpportunityIdsForMetrics += opty.id + HYPEN;
                    convertedOpportunityIdWithLOBList.add(opty.id + HYPEN + opty.LOB__c);
                }
                convertedOpportunityIds = JSON.serialize(convertedOpportunityIdWithLOBList);
            }
            HLPR_StageOrchestrationOnLeadConversion.createstageOrchestrationRecord(optyCreateRequest.leadRecord.Id, act);
            updateLeadMetrics(optyCreateRequest.leadRecord, optyCreateRequest.actId, convertedOpportunityIds);
        } catch (Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME, OPPORTUNITY_CREATE_METHOD_NAME, LoggingLevel.ERROR);
        }
        return JSON.serialize(insertedOpportunity);
    }

    //method for updating LeadMetrics only for Referral Record Type and for Partial Lead Record Type.
    private static void updateLeadMetrics(Lead leadRecord, Id accId, String convertedOpportunityIds) {
        List<LeadMetrics__c> updateLeadMetricsList = new List<LeadMetrics__c>();        
        if (leadRecord != null && (LEAD_REFERRAL_RECORD_TYPE_DEV_NAME.equals(leadRecord.RecordType.DeveloperName) || LEAD_PARTIAL_RECORD_TYPE_DEV_NAME.equals(leadRecord.RecordType.DeveloperName))) {            
            for (LeadMetrics__c ldMetrics : [SELECT id, Status__c FROM LeadMetrics__c WHERE LeadSfdcId__c = :leadRecord.Id WITH SECURITY_ENFORCED LIMIT 1]) {
                ldMetrics.Status__c = CONVERTED_STATUS;
                ldMetrics.LeadConvertedBy__c = UserInfo.getUserId();
                ldMetrics.LeadConvertedDate__c = System.now();
                ldMetrics.ConvertedAccountId__c = accId;
                if (String.isNotBlank(convertedOpportunityIdsForMetrics)) {
                    ldMetrics.ConvertedOpportunityIds__c = convertedOpportunityIdsForMetrics.removeEnd(HYPEN);
                }
                updateLeadMetricsList.add(ldMetrics);
            }
            if (!updateLeadMetricsList.isEmpty()) {                
                List<Database.SaveResult> leadMetricsUpdateResultList = Database.update(updateLeadMetricsList, false);                                
                LoggingService.logDatabaseResult(leadMetricsUpdateResultList, updateLeadMetricsList, CLASS_NAME, UPDATE_LEAD_METRICS_METHOD_NAME, System.LoggingLevel.ERROR);
            }
        }
    }

    //method for retrieving OppQuoteCanvasable after Lead Conversion
    /**
     * @description isOppQuoteCanvasable
     * @param oppId
     * @return  `String`
     */
    @AuraEnabled
    public static String isOppQuoteCanvasable(String oppId) {
        return HLPR_OppButtonController.isOppQuoteCanvasable(oppId);
   }
}