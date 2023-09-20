/**
 Author Team Clubcar
 Name - LWC_OpportunityStartJourney
 @description - Helper class used by LWC OppStartStopJourney and OppStartStopHeadless component
=========================================================================================================================================
History
-------
VERSION         AUTHOR                  DATE                DETAIL
1.0            Team Clubcar            06/21/2021           Initial Development
*****************************************************************************************************************************************/
public with sharing class LWC_OpportunityStartJourney { 
    private static map<id,Journey__c> journeyMap;
    private static List<Journey__c> journeyList = new List<Journey__c>();
    private static final String BIZ_LINE_CODE_GENERAL = 'General';
    private static final String BIZ_LINE_CODE_SMALL_BIZ = 'Small Business';
    private static final String CATEGORY_NAME = 'Prospect Customers';
    private static final String OPP_PRODUCT_ARTISAN_SERVICE = 'Artisan and Service Contractor Policy';
    private static final String OPP_PRODUCT_BUSINESS_INSURANCE = 'Business Insurance';
    private static final String OPP_PRODUCT_COMMERCIAL_INLAND = 'Commercial Inland Marine Policy';
    private static final String OPP_PRODUCT_COMMERCIAL_LIABILITY = 'Commercial Liability Umbrella Policy';
    private static final String OPP_PRODUCT_RESIDUAL = 'Residual Workers Compensation';
    private static final String OPP_PRODUCT_WORKERS = 'Workers Compensation and Employers Liability Policy';
    private static final String OPP_LOB_FIRE = 'Fire';
    private static final String JNY_LOB_RENTERFIRE = 'Renter - Fire';
    private static final String DEFAULT_OPTION = '-- Select Journey --';
    private static final String JNY_LOB_HOMEFIRE = 'Home - Fire';
    private static List<CM_USStateCodeMapping__mdt> metaDataStateCodeMapping;
    private static Map<String, String> stateCodeMap;

    /**
    * @description Entry Level method for the class, This method will be called by LWC
    * @name - retrieveJourneyDetails
    * @param  opportunityId - Opportunity Salesforce Id 
    * @return List<Journey__c> - This method return list of Journey's
    */
    @AuraEnabled
    public static List<Journey__c> retrieveJourneyDetails (Id opportunityId) {
        Opportunity oppRecord = queryOpportunityFields(opportunityId); 
        getJourneyNamesBasedOnOppCriteria(oppRecord);
        return journeyList;
    }
    
	// helper method to build conditions for dynamic query
    private static void getJourneyNamesBasedOnOppCriteria(Opportunity oppRecord) {
        String businessLineCode = 'BusinessLineCode__c INCLUDES (:BIZ_LINE_CODE_GENERAL,';
        if (oppRecord.LOB__c.equals(OPP_LOB_FIRE)) {
            if(isValidSmallBusinessOppProduct(oppRecord)){ 
                businessLineCode += ':BIZ_LINE_CODE_SMALL_BIZ))';
            } else  {
                businessLineCode += ':JNY_LOB_HOMEFIRE,:JNY_LOB_RENTERFIRE))';
            }
        } else {
           businessLineCode += ':opportunityLob))';
        }
        getMapOfJourneys(businessLineCode, oppRecord);
    }
    
	// helper method to query required opportunity fields
    private static Opportunity queryOpportunityFields(Id oppRecordId) {
        return [SELECT Id, Name, LOB__c, OppAccountStateCode__c, IsAccountHealthSourced__c, Product__c,X_Date__c,createddate,Journey_ID__c, stageName, assigned_to__c FROM Opportunity 
                WHERE Id = :oppRecordId WITH SECURITY_ENFORCED]; 
    }
    
	// helper method to verify if opportunity is of type Small Business
    private static boolean isValidSmallBusinessOppProduct(Opportunity oppRecord) {
        boolean prodValidFlag = false;
        Set<String> setOfValidProducts = new Set<String>{OPP_PRODUCT_ARTISAN_SERVICE,OPP_PRODUCT_BUSINESS_INSURANCE,OPP_PRODUCT_COMMERCIAL_INLAND,
            OPP_PRODUCT_COMMERCIAL_LIABILITY,OPP_PRODUCT_RESIDUAL,OPP_PRODUCT_WORKERS};            
                if(oppRecord.product__c!=null && setOfValidProducts.contains(oppRecord.product__c)){
                    prodValidFlag = true;
                }
        return prodValidFlag;
    }
    
	// helper method to query journey records based on dynamic SOQL
    private static void getMapOfJourneys(String businessLineCode, Opportunity oppRecord) {
        retrieveStateCodeMapping();
        String numericStateCode;
        numericStateCode = stateCodeMap.get(oppRecord.OppAccountStateCode__c); 
        String queryStart = 'SELECT id, name, StateCode__c, JourneyName__c,Type__c, EffectiveDate__c'
            +' FROM journey__c where Categoryname__c =:CATEGORY_NAME AND MasterJourneyId__c != null'
            +' AND EffectiveDate__c <=today and ExpirationDate__c>=today AND StateCode__c =:numericStateCode'
            +' AND (';
        String opportunityLob;
        opportunityLob = oppRecord.LOB__c;
        String queryStr = queryStart + businessLineCode;
        journeyList = Security.stripInaccessible(AccessType.READABLE,Database.query(String.escapeSingleQuotes(queryStr))).getRecords(); 
    }
    
	// helper method to retrieve statecode mapping
    private static void retrieveStateCodeMapping () {
        if (metaDataStateCodeMapping == null) {
            metaDataStateCodeMapping = [Select DeveloperName, State__c, StateCode__c
                                        from CM_USStateCodeMapping__mdt where State__c != null WITH SECURITY_ENFORCED Limit 51];
            stateCodeMap = new Map<String, String>();
            if(metaDataStateCodeMapping != null && !metaDataStateCodeMapping.isEmpty()){
                for (CM_USStateCodeMapping__mdt mappingRecord : metaDataStateCodeMapping){
                    stateCodeMap.put(mappingRecord.State__c, mappingRecord.StateCode__c);
                }
            } 
        } 
    }

    /**
    * @description - This method will be called by LWC
    * @name - journeyStepPreviewData
    * @param  oppRecord - Opportunity record
    * @param  selectedJourneyRecord - Journey__c record
    * @return StartJourneyController.JourneyPreviewData - This method return wrapper for Journey steps
    */
    @AuraEnabled(cacheable=true)
    public static StartJourneyController.JourneyPreviewData journeyStepPreviewData(Opportunity oppRecord, Journey__c selectedJourneyRecord) {
        StartJourneyController.JourneyPreviewData  instanceOfJourneyPreviewData = new StartJourneyController.JourneyPreviewData();
        Date journeyStartDate = OppCalJrnyStartDate.calculateJourneyStartDate(oppRecord, selectedJourneyRecord);
        Double numberOfMembers = 1; 
        instanceOfJourneyPreviewData = StartJourneyController.retrieveJourneyPreviewData(selectedJourneyRecord.Id, numberOfMembers, journeyStartDate);
        return instanceOfJourneyPreviewData;
    }
}