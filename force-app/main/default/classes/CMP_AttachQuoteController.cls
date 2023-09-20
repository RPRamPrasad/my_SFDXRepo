/**
* Author : Golden Spikes Team
* Date Created : 09/06/2018
* @ModifiedDate 12/5/2018 Deleted the code to set XDate__c and CurrentInsurerName__c in the method syncPrimaryQuoteInfo()
* @description  This Apex Class is used for lightning components to fetch and attach quote summary
                 and detail information from ODATA to Custom Quote Object.
*/
public with sharing class CMP_AttachQuoteController {

    private static final String CLASS_NAME = 'CMP_AttachQuoteController';
    private static final String PROCESS_QUOTE_SUMMARY_METHOD_NAME = 'processQuoteSummary';
    private static final String PROCESS_SAVE_QUOTE_METHOD_NAME = 'processSaveQuote';
    private static final String SAVE_QUOTE_SUMMARY_DETAIL_METHOD_NAME = 'saveQuoteSummaryDetail';
    private static final String AUTO_QUOTE_RECORD_TYPE_NAME = 'Auto Quote';
    private static final String PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME = 'Primary Auto Quote';
    private static final String QUOTE_NAME_SEPERATOR = '-';
    private static final Integer PRIMARY_QUOTE_SIZE = 1;
    private static final String STATUS_QUOTE_PROVIDED = 'Quote Provided';
    private static final String STAGE_NAME_QUOTING = 'Quoting';
    private static final List<String> EXCLUDE_STAGE_NAMES = new String[] {'App Submitted', 'Closed', 'Closed Won','Not Now -  Follow Up'};
    private static final List<String> EXCLUDE_STATUS_NAMES = new String[] {'Quote Provided', 'Application Pending'};

    private static Map<String, Schema.Recordtypeinfo> quoteRecordTypeMap = new Map<String, Schema.Recordtypeinfo>();
    private static Opportunity opportunityInfo;

    @TestVisible public static final List<Quotes__x> MOCKED_QUOTE_SUMMARY_LIST = new List<Quotes__x>();
    private static List<Quotes__x> oDATAQuoteSummaryList;

    @TestVisible public static final List<QuoteDetails__x> MOCKED_QUOTE_DETAIL_LIST = new List<QuoteDetails__x>();
    private static List<QuoteDetails__x> oDATAQuoteDetailList = new List<QuoteDetails__x>();

    private static Map<String, Quote__c> selectedQuoteIndexRecordMap;
    private static Map<String, String> quotePayLoadIdentifierMap;
    private static Map<String, QuoteDetails__x> selectedQuoteDetailMap;
    private static Opportunity opportunityForPrimaryQuote;
    private static QuoteSaveResponse qtSaveResponse;

    /**
     * @description wrapper class to store the quote query response.
     */
    public with sharing class QuoteQueryResponse {
        @AuraEnabled
        public String opportunityName = '';
        @AuraEnabled
        public String accountName = '';
        @AuraEnabled
        public List<Quote__c> quoteRecordsToDisplay = new List<Quote__c>();
        @AuraEnabled
        public Map<String, String> quotePayLoadIdentifierMap = new Map<String, String>();
        @AuraEnabled
        public String pageMessage = '';
        @AuraEnabled
        public Boolean isSuccessOnFetchQuote = false;
    }

    /**
     * @description wrapper class to store the quote save response.
     */
    public with sharing class QuoteSaveResponse {
        @AuraEnabled
        public Boolean isSuccessOnSaveQuote = false;
        @AuraEnabled
        public String pageMessage = '';
    }

    /**
     * @description Entry point method for quote Fetch
     * @param opportunityId
     * @return QuoteQueryResponse
     */
    @AuraEnabled
    public static QuoteQueryResponse processQuoteSummary(String opportunityId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('opportunityId', opportunityId, Opportunity.class);
        List<Opportunity> opportunityInfoList = new List<Opportunity>();
        opportunityInfo = new Opportunity();
        Map<String, String> quotePayLoadIdentifierMap = new Map<String, String>();
        QuoteQueryResponse qtResponse = new QuoteQueryResponse();
        try {
            opportunityInfoList = UTIL_LtngQuoteDataAccess.performQueryOnOpportunity(opportunityId);
            if (opportunityInfoList?.size() > 0) {
                opportunityInfo = opportunityInfoList[0];
            }
            qtResponse.opportunityName = opportunityInfo.name;
            qtResponse.accountName = opportunityInfo.Account.name;
            qtResponse.pageMessage = CMP_AttachQuoteControllerUtility.validateBeforeQuoteQuery(opportunityInfo);

            if(String.isBlank(qtResponse.pageMessage)) {
                queryQuoteSummary();
                buildQuoteRecordTypeInfo();
                List<Quote__c> quoteInfoList = new List<Quote__c>();
                Integer i=0;

                for(Quotes__x quoteSummaryExtInfo: oDATAQuoteSummaryList) {
                    quoteInfoList.add(buildQuoteRecord(quoteSummaryExtInfo));
                    if(String.isNotBlank(quoteSummaryExtInfo.QuotePayloadIdentifier__c)) {
                        quotePayLoadIdentifierMap.put(String.valueOf(i), quoteSummaryExtInfo.QuotePayloadIdentifier__c);
                    }
                    i++;
                }

                if(quoteInfoList.isEmpty()) {
                    qtResponse.pageMessage = Label.CL_QUOTE_FETCH_NOT_AVAILABLE;
                } else {
                    qtResponse.quotePayLoadIdentifierMap = quotePayLoadIdentifierMap;
                    qtResponse.quoteRecordsToDisplay = quoteInfoList;
                    qtResponse.isSuccessOnFetchQuote = true;
                }
            }
        } catch(Exception quoteSummaryException) {
            qtResponse.isSuccessOnFetchQuote = false;
            qtResponse.pageMessage = Label.CL_QUOTE_FETCH_EXCEPTION_MSG;
            LoggingService.logHandledException(quoteSummaryException, CLASS_NAME, PROCESS_QUOTE_SUMMARY_METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return qtResponse;
    }

    //method to query the ODATA Quotes__x object and get the quote summary Info
    private static void queryQuoteSummary() {
        oDATAQuoteSummaryList = new List<Quotes__x>();
        if(Test.isRunningTest()) {
            oDATAQuoteSummaryList = MOCKED_QUOTE_SUMMARY_LIST;
        } else {
            oDATAQuoteSummaryList = UTIL_LtngQuoteDataAccess.performQueryOnQuoteODATASummary(opportunityInfo.LOB__c, opportunityInfo.Account.ClientIdentifier__c, opportunityInfo.Owner.Servicing_Agent_Associate_ID__c);
        }
    }

    //method to form the quote record
    private static Quote__c buildQuoteRecord(Quotes__x quoteSummaryExtInfo) {
        return new Quote__c (
            name = buildQuoteName(),
            Opportunity__c = opportunityInfo.id,
            RecordTypeId = quoteRecordTypeMap.get(AUTO_QUOTE_RECORD_TYPE_NAME).RecordTypeId,
            MonthlyPremium__c = quoteSummaryExtInfo.QuoteMonthlyPremiumAmount__c,
            TotalPremiumAllVehicles__c = quoteSummaryExtInfo.QuoteTotalPremiumAmount__c,
            EffectiveDate__c = quoteSummaryExtInfo.QuoteEffectiveDate__c,
            FirstName__c = quoteSummaryExtInfo.ApplicantFirstName__c,
            LastName__c = quoteSummaryExtInfo.ApplicantLastName__c,
            Suffix__c = quoteSummaryExtInfo.ApplicantSuffix__c,
            OrganizationName__c = quoteSummaryExtInfo.ApplicantOrganizationName__c,
            City__c = quoteSummaryExtInfo.ApplicantCity__c,
            State__c = quoteSummaryExtInfo.ApplicantStateCode__c,
            Street1__c = quoteSummaryExtInfo.ApplicantAddressLine1__c,
            Street2__c = quoteSummaryExtInfo.ApplicantAddressLine2__c,
            PostalCode__c = quoteSummaryExtInfo.ApplicantPostalCode__c
            
        );
    }

    //method to get the quote name
    private static String buildQuoteName() {
        String quoteName = '';
        quoteName = opportunityInfo.LOB__c;
        if(String.isNotBlank(opportunityInfo.Product__c)) {
            quoteName += QUOTE_NAME_SEPERATOR + opportunityInfo.Product__c;
        }
        return quoteName;
    }

    //method to get the quote record type Info
    private static void buildQuoteRecordTypeInfo() {
        quoteRecordTypeMap = Schema.Sobjecttype.Quote__c.getRecordTypeInfosByName();
    }

    /**
     * @description Entry point method for quote save
     * @param selectedQuoteRecords
     * @param quotePayLoads
     * @param opportunityId
     * @return QuoteSaveResponse
     */
    @AuraEnabled
    public static QuoteSaveResponse processSaveQuote(String selectedQuoteRecords, String quotePayLoads, String opportunityId) {
        List<Opportunity> opportunityInfoList = new List<Opportunity>();
        opportunityInfoList = UTIL_LtngQuoteDataAccess.performQueryOnOpportunity(opportunityId);
        if (opportunityInfoList?.size() > 0) {
            opportunityInfo = opportunityInfoList[0];
        }
        qtSaveResponse = new QuoteSaveResponse();
        try {
            selectedQuoteIndexRecordMap = (Map<String, Quote__c>) JSON.deserialize(selectedQuoteRecords, Map<String, Quote__c>.class);
            quotePayLoadIdentifierMap = (Map<String, String>) JSON.deserialize(quotePayLoads, Map<String, String>.class);
            if(!selectedQuoteIndexRecordMap.isEmpty()) {
                processQuoteDetail(opportunityInfo);
            }
        } catch (Exception quoteSaveException) {
            qtSaveResponse.pageMessage = Label.CL_QUOTE_SAVE_EXCEPTION_MSG;
            LoggingService.logHandledException(quoteSaveException, CLASS_NAME, PROCESS_SAVE_QUOTE_METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return qtSaveResponse;
    }

    // method to process the selected quote for getting the quote detail information and to sync the quote Info to opportunity.
    private static void processQuoteDetail(Opportunity opportunityInfo) {
        opportunityForPrimaryQuote = null;
        selectedQuoteDetailMap = new Map<String, QuoteDetails__x>();
        List<Quote__c> selectedQuoteList = new List<Quote__c>();
        Set<String> selectedQuotePayLoadSet = new Set<String>();

        if(!quotePayLoadIdentifierMap.isEmpty()) {
            for(String selVal : selectedQuoteIndexRecordMap.keySet()) {
                selectedQuotePayLoadSet.add(quotePayLoadIdentifierMap.get(selVal));
            }
        }

        if(!selectedQuotePayLoadSet.isEmpty()) {
            queryQuoteDetail(selectedQuotePayLoadSet);
        }

        for(String selVal: selectedQuoteIndexRecordMap.keySet()) {
            Quote__c quoteToBeInserted = selectedQuoteIndexRecordMap.get(selVal);
            if(selectedQuoteDetailMap.get(quotePayLoadIdentifierMap.get(selVal)) != null) {
                quoteToBeInserted.VehicleInfo__c = selectedQuoteDetailMap.get(quotePayLoadIdentifierMap.get(selVal)).VehicleInfo__c;
                quoteToBeInserted.DriverInfo__c = selectedQuoteDetailMap.get(quotePayLoadIdentifierMap.get(selVal)).DriverInfo__c;
            }
            selectedQuoteList.add(quoteToBeInserted);
        }

        if(PRIMARY_QUOTE_SIZE == selectedQuoteIndexRecordMap.keySet().size()) {
            syncPrimaryQuoteInfo(selectedQuoteList, opportunityInfo);
        }
        else {
            opportunityForPrimaryQuote = new Opportunity();
            validateStageAndStatus(opportunityInfo);
        }

        saveQuoteSummaryDetail(selectedQuoteList);
    }

    // method to query the quote detail information
    private static void queryQuoteDetail(Set<String> selectedQuotePayLoadSet) {
        if(Test.isRunningTest()) {
            oDATAQuoteDetailList = MOCKED_QUOTE_DETAIL_LIST;
        } else {
            oDATAQuoteDetailList = UTIL_LtngQuoteDataAccess.performQueryOnQuoteODATADetail(selectedQuotePayLoadSet);
        }
        for(QuoteDetails__x quoteDetailExtInfo : oDATAQuoteDetailList) {
            selectedQuoteDetailMap.put(quoteDetailExtInfo.QuotePayloadIdentifier__c, quoteDetailExtInfo);
        }
    }

    //if the selected quote is only one and there is no quote available on the opportunity,
    //  then make primary on the selected quote and sync the quote information to opportunity
    private static void syncPrimaryQuoteInfo(List<Quote__c> selectedQuoteList, Opportunity opportunityInfo) {
        List<Quote__c> primaryQuoteList = null;
        String opportunityId = opportunityInfo.Id;
        primaryQuoteList = [Select Id from Quote__c WHERE Opportunity__c = :opportunityId WITH SECURITY_ENFORCED LIMIT 1];
        opportunityForPrimaryQuote = new Opportunity();
        
        if(primaryQuoteList.isEmpty()) {
            buildQuoteRecordTypeInfo();
            selectedQuoteList.get(0).PrimaryQuote__c = true;
            selectedQuoteList.get(0).RecordTypeId = quoteRecordTypeMap.get(PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME).RecordTypeId;
            opportunityForPrimaryQuote.Monthly_Premium__c = selectedQuoteList.get(0).MonthlyPremium__c;
            opportunityForPrimaryQuote.Amount = selectedQuoteList.get(0).TotalPremiumAllVehicles__c;

            if(String.isNotBlank(selectedQuoteList.get(0).VehicleInfo__c)) {
                Map<String, Object> vechicleObjMap = (Map<String, Object>) JSON.deserializeUntyped(selectedQuoteList.get(0).vehicleINfo__c);
                List<Object> lstVehicleObject = (List<Object>) vechicleObjMap.get('vehicleDetails');
                opportunityForPrimaryQuote.Number_of_Vehicles__c = lstVehicleObject.size();
            }
            
        }
        validateStageAndStatus(opportunityInfo);
    }

    //method to insert the selected quote and update the opportunity if the selected quoted is primary
    private static void saveQuoteSummaryDetail(List<Quote__c> selectedQuoteList) {
        Savepoint sp = Database.setSavepoint();
        try {
            if(opportunityForPrimaryQuote != null) {
                AP_OpportunityTrigger.doNotExecuteReOpenProcess();
                List<Opportunity> oppList = new List<Opportunity>{opportunityForPrimaryQuote};
                update Security.stripInaccessible(AccessType.UPDATABLE, oppList).getRecords();
            }
            if(!selectedQuoteList.isEmpty()) {
                insert Security.stripInaccessible(AccessType.CREATABLE, selectedQuoteList).getRecords();
            }
            qtSaveResponse.isSuccessOnSaveQuote = true;
        } catch(Exception saveQuoteOpportunityException) {
            qtSaveResponse.pageMessage = Label.CL_QUOTE_SAVE_EXCEPTION_MSG;
            Database.rollback(sp);
            LoggingService.logHandledException(saveQuoteOpportunityException, CLASS_NAME, SAVE_QUOTE_SUMMARY_DETAIL_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }

    /**
     * @description validates and sets the opportunity stage and status
     * @param opportunityInfo
     */
    public static void validateStageAndStatus(Opportunity opportunityInfo){
        opportunityForPrimaryQuote.Id = opportunityInfo.Id;
        if(!(EXCLUDE_STAGE_NAMES).contains(opportunityInfo.StageName)){ 
            opportunityForPrimaryQuote.StageName= STAGE_NAME_QUOTING;         	
            if(!EXCLUDE_STATUS_NAMES.contains(opportunityInfo.status__c))
            {
                opportunityForPrimaryQuote.Status__c = STATUS_QUOTE_PROVIDED; 
            }	
        }
        opportunityForPrimaryQuote.Quote_Received__c = (opportunityInfo.Quote_Received__c == null) ? Date.today() : opportunityInfo.Quote_Received__c; 

    }
}