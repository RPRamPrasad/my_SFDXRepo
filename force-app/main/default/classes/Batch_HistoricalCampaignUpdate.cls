/**
* Author : Team ITIC
* Date Created :09/06/2019
* Name : Batch class to update status for historical campaigns from Closed Opportunities in salesforce.
* @description Batch_HistoricalCampaignUpdate
*/

global with sharing class Batch_HistoricalCampaignUpdate implements Database.Batchable<sObject>, Database.Stateful{
    private static final String BATCH_CLASS_NAME = 'Batch_HistoricalCampaignUpdate';
    private static final String BATCH_EXECUTE_METHOD = 'execute';
    private static final String FULFILLMENT_COMPLETED = 'Fulfillment Completed';
    private static final String FULFILLMENT_PENDING = 'Fulfillment Pending';
    private static final String REPORT = 'Report';
    private String queryString;
    protected AP_BatchReportRequest request;
/**
 * @description start
 * @param bc 
 * @return  `Database.QueryLocator`
 */

    global Database.QueryLocator start(Database.BatchableContext bc){
        String query_String = 'Select Id, Name, Source__c, Original_Campaign_Count__c, Submitted_Campaign_Count__c, NumberOfContacts'+
                                        ' from Campaign where Source__c =:REPORT and '+ 
                                         +'Status =:FULFILLMENT_PENDING and CreatedDate = THIS_MONTH';
        return Database.getQueryLocator(query_String);
    }
    /**
     * @description execute 
     * @param bc 
     * @param campaignList 
     */
    
    global void execute (Database.BatchableContext bc, List<Campaign> campaignList){
        try{
            List<Campaign> campaignsForUpdateList = new List<Campaign>();
            AP_HistoricalOpportunityCampaign historicalOpportunityCampaign = new AP_HistoricalOpportunityCampaign();
            for(Campaign campaignForUpdate: campaignList){
                campaignForUpdate.Original_Campaign_Count__c= campaignForUpdate.NumberOfContacts;
                campaignForUpdate.Submitted_Campaign_Count__c= campaignForUpdate.NumberOfContacts;
                campaignForUpdate.Status = FULFILLMENT_COMPLETED;
                campaignsForUpdateList.add(campaignForUpdate);
            }
            if (!CollectionUtils.isNullOrEmptyList(campaignsForUpdateList)){
                historicalOpportunityCampaign.updateCampaign(campaignsForUpdateList);
            }
        } catch (Exception e){ LoggingService.logHandledException(e, BATCH_CLASS_NAME, BATCH_EXECUTE_METHOD, System.LoggingLevel.ERROR);}
    }
    /**
     * @description finish
     * @param bc
     */
    global void finish (Database.BatchableContext bc){
        AP_LogHolder logHolder = new AP_LogHolder();
	    logHolder.info(BATCH_CLASS_NAME, 'start time of execution: ' + System.now());
	    logHolder.writeToLogExceptionObject();
    }
}
