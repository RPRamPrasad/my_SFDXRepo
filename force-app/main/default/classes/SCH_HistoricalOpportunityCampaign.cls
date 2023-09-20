/**
 * @description SCH_HistoricalOpportunityCampaign
 * @Date Created :06/10/2019
 * @Author ITIC
 * @Name Scheduler class for Batch_HistoricalOpportunityCampaign process
 */
global with sharing class SCH_HistoricalOpportunityCampaign implements Schedulable { 
	public static final String HISTORICAL_OPPORTUNITY_CAMPAIGN = 'HistoricalOpportunityCampaign';
	private static final String BATCH_CLASS_NAME = 'Batch_NeglectedAbandonedAutoOpportunity';
/**
 * @description execute    
 * @param sc  
 */    
	global void execute(SchedulableContext sc) {
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