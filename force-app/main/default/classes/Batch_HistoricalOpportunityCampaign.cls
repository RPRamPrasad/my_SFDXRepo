/**
* Author : Team ITIC
* Date Created :06/10/2019
* Name : Batch class to create historical campaigns from Closed Opportunities in salesforce.
* @description Batch_HistoricalOpportunityCampaign
*/

global with sharing class Batch_HistoricalOpportunityCampaign implements Database.Batchable<sObject>, Database.Stateful{
    private static final String BATCH_CLASS_NAME = 'Batch_HistoricalOpportunityCampaign';
    private static final String BATCH_EXECUTE_METHOD = 'execute';
    private String queryString;
    protected AP_BatchReportRequest request;
  /**
   * @description Batch_HistoricalOpportunityCampaign
   * @param requestData 
   */
    
    public Batch_HistoricalOpportunityCampaign(AP_BatchReportRequest requestData){
        this.request = requestData;
        this.queryString = request.getQueryString();
    }
/**
 * @description start
 * @param bc 
 * @return  `Database.QueryLocator`
 */

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(queryString);
    }
    /**
     * @description execute
     * @param bc 
     * @param opportunityList 
     */
    
    global void execute (Database.BatchableContext bc, List<Opportunity> opportunityList){
    try{
        AP_HistoricalOpportunityCampaign historicalOpportunityCampaign = new AP_HistoricalOpportunityCampaign();
        historicalOpportunityCampaign.processOpportunityCampaign(opportunityList, request);
        } catch (Exception e){ LoggingService.logHandledException(e, BATCH_CLASS_NAME, BATCH_EXECUTE_METHOD, System.LoggingLevel.ERROR);}
    }
    /**
     * @description finish
     * @param bc 
     */
    
    global void finish (Database.BatchableContext bc){
        // execute Batch_HistoricalCampaignUpdate to update the campaign status and the campaign members count
        Batch_HistoricalCampaignUpdate batchUpdateCampaign = new Batch_HistoricalCampaignUpdate();
        Database.executeBatch(batchUpdateCampaign, 200);
    }
 }