/**
*  @Author : Dawgs Team
*  @Date Created : 08/14/2018
*  @description : This class will have helper methods for Primary Quote Trigger.
*/
public with sharing class HLPR_PrimaryQuote {

    private static final String AUTO_QUOTE_RECORD_TYPE_DEV_NAME = 'Auto_Quote';
    private static final String PRIMARY_AUTO_QUOTE_RECORD_TYPE_DEV_NAME = 'Primary_Auto_Quote';
    private static final String FIRE_QUOTE_RECORD_TYPE_DEV_NAME = 'FireQuote';
    private static final String PRIMARY_FIRE_QUOTE_RECORD_TYPE_DEV_NAME = 'PrimaryFireQuote';
    private static final String FIRE_LINE_OF_BUSINESS = 'Fire';
    private static final String AUTO_LINE_OF_BUSINESS = 'Auto';
    private static final String AUTOMATIC_ATTACH_METHOD = 'Automatic';
    public static final Map<String, Schema.Recordtypeinfo> QUOTE_RECORD_TYPE_MAP = Schema.Sobjecttype.Quote__c.getRecordTypeInfosByDeveloperName();

    /**
     * @description getting only the fire line of business opportunity ids from the quote list
     * @param quoteList
     * @return opportunityIdList
     */
    
    public static List<String> filterOpportunity(List<Quote__c> quoteList) {
        List<String> opportunityIdList = new List<String>();
        for(Quote__c qt : quoteList) {
            if(FIRE_LINE_OF_BUSINESS.equals(qt.LineOfBusiness__c)||AUTO_LINE_OF_BUSINESS.equals(qt.LineOfBusiness__c)) {
                opportunityIdList.add(qt.opportunity__c);
            }
        }
        return opportunityIdList;
    }

    /**
     * @description getting the primary recordtypeId for each LOB
     * @param recordTypeId
     * @return primaryRecordTypeId
     */
     
    public static String getPrimaryRecordTypeByLob(String recordTypeId) {
        String primaryRecordTypeId = '';
        if(QUOTE_RECORD_TYPE_MAP.get(PRIMARY_AUTO_QUOTE_RECORD_TYPE_DEV_NAME).RecordTypeId.equals(recordTypeId)) {
            primaryRecordTypeId = QUOTE_RECORD_TYPE_MAP.get(AUTO_QUOTE_RECORD_TYPE_DEV_NAME).RecordTypeId;
        } else if(QUOTE_RECORD_TYPE_MAP.get(PRIMARY_FIRE_QUOTE_RECORD_TYPE_DEV_NAME).RecordTypeId.equals(recordTypeId)) {
            primaryRecordTypeId = QUOTE_RECORD_TYPE_MAP.get(FIRE_QUOTE_RECORD_TYPE_DEV_NAME).RecordTypeId;
        }
        return primaryRecordTypeId;
    }

    /**
     * @description method to update opportunity information
     * @param opportunityListToBeUpdated
     */
    public static void updateOpportunity(List<Opportunity> opportunityListToBeUpdated) {
        if(!opportunityListToBeUpdated.isEmpty()) {
            update Security.stripInaccessible(AccessType.UPDATABLE, opportunityListToBeUpdated).getRecords();
        }
    }
     /**
     * @description getting only the Automatic Attach Method opportunity ids from the quote list
     * @param quoteList
     * @return excludedQuoteList
     */
    public static List<Quote__c> filterAutomaticOpportunity(List<Quote__c> quoteList) {
        List<Quote__c> excludedQuoteList = new List<Quote__c>();
        for(Quote__c qt : quoteList) {
       			if(AUTOMATIC_ATTACH_METHOD.equals(qt.Attachmethod__c)) {
                excludedQuoteList.add(qt);
            }
        }
        return excludedQuoteList;
    }
     /**
     * @description getting only the Automatic Attach Method opportunity ids from the quote list
     * @param excludedQuoteList
     * @return opportunityIdList
     */
     public static List<String> automaticOpportunityValues(List<Quote__c> excludedQuoteList) {
        List<String> opportunityIdList = new List<String>();
        for(Quote__c qt : excludedQuoteList) {
            if(AUTOMATIC_ATTACH_METHOD.equals(qt.Attachmethod__c)) {
                opportunityIdList.add(qt.opportunity__c);
            }
        }
        return opportunityIdList;
    }    
}