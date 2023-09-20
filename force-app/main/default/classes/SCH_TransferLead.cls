/**
 * Author : Golden Spikes Team
 * Date Created : 10/23/2020
 * @description SCH_TransferLead : Scheduler class for scheduling Batch_TransferLead.
 *
 */
public with sharing class SCH_TransferLead implements Schedulable {
    private static final String CS_TRANSFER_LEAD_BATCH_CONFIG_NAME = 'Transfer_Lead_Batch';
    private String leadTransferUpdateQuery = 'SELECT Id, AgentAssociateId__c, LeadSource, Description, OwnerId, AssignedTo__c FROM Lead WHERE ' +
        'RecordTypeId =: recordTypeId AND CreatedDate >=: todaysDate AND OwnerId =: systemRecordOwnerSfdcId AND ' +
        'SourcedFromCCC__c = TRUE and isConverted = FALSE WITH SECURITY_ENFORCED LIMIT : batchQueryLimit';

    //method to schedule the lead transfer update batch apex class.
    /**
     * @description execute
     * @param scheduleContext 
     */
    public void execute(SchedulableContext scheduleContext) {
        CSLeadBatch__c leadCSBatchRecord = queryLeadBatchCustomSettingRecord();
        if (leadCSBatchRecord != null) {
            Integer batchSize = (Integer) leadCSBatchRecord.BatchSize__c;
            Database.executeBatch(new Batch_TransferLead(leadTransferUpdateQuery, leadCSBatchRecord), batchSize);
        }
    }

    //method to get Transfer Lead Batch custom setting record
    /**
     * @description queryLeadBatchCustomSettingRecord
     * @return  `CSLeadBatch__c`
     */
    public static CSLeadBatch__c queryLeadBatchCustomSettingRecord() {
        CSLeadBatch__c leadUpdateCSRecord;
        Map<String, CSLeadBatch__c> leadCSBatchRecordMap = CSLeadBatch__c.getAll();
        if (leadCSBatchRecordMap.get(CS_TRANSFER_LEAD_BATCH_CONFIG_NAME) != null && !leadCSBatchRecordMap.isEmpty()) {
            leadUpdateCSRecord = leadCSBatchRecordMap.get(CS_TRANSFER_LEAD_BATCH_CONFIG_NAME);
        }
        return leadUpdateCSRecord;
    }
}