/**
* Author : Team Incognito
* Date Created :
* Name : Batch class to create campaign records from Policy Number upload object
* @description Batch_ServiceCampaign
*/
public with sharing class Batch_ServiceCampaign implements Database.Batchable<sObject>, Database.Stateful{
    private static final String BATCH_CLASS_NAME = 'Batch_ServiceCampaign';
    private static final String BATCH_EXECUTE_METHOD = 'execute';
    private static final Boolean TO_BE_PROCESSED_TRUE = true;
    private String queryString;
    protected AP_BatchReportRequest request;
/**
 * @description start
 * @param bc 
 * @return  `Database.QueryLocator`
 */

    public Database.QueryLocator start(Database.BatchableContext bc){
        String query_String = 'Select Id, PolicyNumber__c, ToBeProcessed__c, CampaignName__c, CampaignStartDate__c, State__c,'+
                                        ' AdditionalInformation__c from Service_Campaign__c where ToBeProcessed__c =:TO_BE_PROCESSED_TRUE ';
        return Database.getQueryLocator(query_String);
    }
    /**
     * @description execute 
     * @param bc 
     * @param campaignList 
     */
    
    public void execute (Database.BatchableContext bc, List<Service_Campaign__c> serviceCampaignList){
        try{
            AP_ServiceCampaigns serviceCampaign = new AP_ServiceCampaigns();
            serviceCampaign.processServiceCampaign(serviceCampaignList,serviceCampaignList[0].CampaignName__c,
                                                    serviceCampaignList[0].CampaignStartDate__c);

            
        } catch (Exception e){ LoggingService.logHandledException(e, BATCH_CLASS_NAME, BATCH_EXECUTE_METHOD, System.LoggingLevel.ERROR);}
    }
    /**
     * @description finish
     * @param bc
     */
    public void finish (Database.BatchableContext bc){
         // execute Batch_HistoricalCampaignUpdate to update the campaign status and the campaign members count
         Batch_HistoricalCampaignUpdate batchUpdateCampaign = new Batch_HistoricalCampaignUpdate();
         Database.executeBatch(batchUpdateCampaign, 200);
    }

}