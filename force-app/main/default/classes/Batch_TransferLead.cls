/**
 * Author : Golden Spikes Team
 * Date Created : 10/23/2020
 * Description : This Batch Class is called by SCH_TransferLead scheduler class and updates the Lead records.
 * @description Batch_TransferLead
 */
public with sharing class Batch_TransferLead implements Database.Batchable<sObject>, Database.StateFul {
    private static final String PARTIAL_LEAD_RECORD_TYPE_DEV_NAME = 'PartialLead';
    private String recordTypeId;
    private Id systemRecordOwnerSfdcId;
    private Date todaysDate;
    private Integer batchQueryLimit;
    private String queryLeads;
    private CSLeadBatch__c leadTransferCustomSettingRecord;
    private List<HLPR_TransferLead.LeadBatchResponse> batchResponseList = new List<HLPR_TransferLead.LeadBatchResponse>();

    /**
     * @description Batch_TransferLead
     * @param query 
     * @param customSettingRecord 
     */
    public Batch_TransferLead(String query, CSLeadBatch__c customSettingRecord) {
        this.leadTransferCustomSettingRecord = customSettingRecord;
        this.batchQueryLimit = (Integer) (leadTransferCustomSettingRecord.QuerySize__c);
        this.recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(PARTIAL_LEAD_RECORD_TYPE_DEV_NAME).getRecordTypeId();
        this.systemRecordOwnerSfdcId = SystemRecordOwnerDetails.getSystemRecordOwnerId();
        this.todaysDate = System.today().addDays(- (Integer) (leadTransferCustomSettingRecord.QueryFilterStartDay__c));
        this.queryLeads = query;
    }

    //start method of the batch
    /**
     * @description start
     * @param bc 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.queryLeads);
    }

    //execute method for the batch
    /**
     * @description execute
     * @param bc 
     * @param scope 
     */
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        this.batchResponseList.add(new HLPR_TransferLead().processTransferLeadUpdate((List<Lead>) scope, systemRecordOwnerSfdcId) );
    }

    //method for the batch which sends email from the responses collected.
    /**
     * @description finish
     * @param bc 
     */
    public void finish(Database.BatchableContext bc) {
        new HLPR_TransferLead().processBatchFinish(bc.getJobId(), batchResponseList, leadTransferCustomSettingRecord);
    }
}