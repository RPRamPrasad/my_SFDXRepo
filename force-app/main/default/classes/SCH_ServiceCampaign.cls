/**
 * @description SCH_ServiceCampaign
 * @Date Created :02/07/2023
 * @Author Incognito
 * @Name Scheduler class for Batch_ServiceCampaign process
 */
public with sharing class SCH_ServiceCampaign implements Schedulable { 
	public static final String HISTORICAL_OPPORTUNITY_CAMPAIGN = 'HistoricalOpportunityCampaign';
	private static final String BATCH_CLASS_NAME = 'Batch_ServiceCampaign';
/**
 * @description execute    
 * @param sc  
 */    
	public void execute(SchedulableContext sc) {
		CS_ApexBatchSize__c batchSizeCS = CS_ApexBatchSize__c.getInstance(HISTORICAL_OPPORTUNITY_CAMPAIGN);
		Integer batchSize= Integer.valueOf(batchSizeCS.BatchSize__c);
		Batch_ServiceCampaign campaignProcess = new Batch_ServiceCampaign();
        Database.executebatch(campaignProcess,batchSize);
	}

}