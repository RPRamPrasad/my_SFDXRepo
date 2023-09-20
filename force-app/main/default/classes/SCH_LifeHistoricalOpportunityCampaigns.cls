/**
 * @Name SCH_LifeHistoricalOpportunityCampaign
 * @Date Created :09/01/2021
 * @Author ITIC
 * @description Scheduler class for BatchHistoricalOpportunityCampaign process
 *
 * */
public with sharing class SCH_LifeHistoricalOpportunityCampaigns implements Schedulable { 
	public static final String HISTORICAL_OPPORTUNITY_CAMPAIGN = 'HistoricalOpportunityCampaign';
	private static final String BATCH_CLASS_NAME = 'Batch_LifeAgedOpportunity';
/**
 * @description execute    
 * @param context Database.SchedulableContext 
 * */    
	public void execute(SchedulableContext context) {
		CS_ApexBatchSize__c batchSizeCS = CS_ApexBatchSize__c.getInstance(HISTORICAL_OPPORTUNITY_CAMPAIGN);
		Integer batchSize= Integer.valueOf(batchSizeCS.BatchSize__c);
		Batch_HistoricalOpportunityCampaign campaignProcess = new Batch_HistoricalOpportunityCampaign (retrieveReportData());
        Database.executebatch(campaignProcess,batchSize);
	}
/* *
 * @method retrieveReportData    
 * @param: String 
 * @return: AP_RetrieveBatchReportFieldData
 * */ 
	private AP_BatchReportRequest retrieveReportData(){
		AP_RetrieveBatchReportFieldData  reportFieldValue = new AP_RetrieveBatchReportFieldData();
		return reportFieldValue.setBatchReportRequest(BATCH_CLASS_NAME);
	}
}
