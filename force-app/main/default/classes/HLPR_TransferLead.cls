/**
 * Author : Golden Spikes Team
 * Date Created : 10/23/2020
 * @description HLPR_TransferLead : This Helper Class is used to support Batch_TransferLead Batch Apex class, which handles record owner update.
 */
public with sharing class HLPR_TransferLead {
    private static final String CLASS_NAME = 'HLPR_TransferLead';
    private static final String PROCESS_TRANSFER_LEAD_METHOD_NAME = 'processTransferLeadUpdate';
    private static final String PROCESS_BATCH_FINISH_METHOD_NAME = 'processBatchFinish';
    private static final String PROXY_CONCAT = 'P';
    private static Map<String, String> agentProxyMap;
    private static Map<String, String> leadProxyMap;
    private static final String TRANSFER_LEAD_BATCH_EMAIL_SUBJECT = 'Transfer Lead Batch Notification.';
    private static final String LEAD_BATCH_NONE = 'No Records processed by Lead transfer batch today';
    private static final String LEAD_BATCH_QUERIED = 'Total number of Lead records queried for transfer';
    private static final String TRANSFER_LEAD_BATCH_LEAD_PROCESSED = 'Total number of Lead records processed for transfer';
    private static final String TRANSFER_LEAD_BATCH_LEAD_SUCCESS = 'Total number of Lead records successfully transferred';
    private static final String TRANSFER_LEAD_BATCH_LEAD_FAILURE = 'Total number of Lead records failed to transfer';
    private static final String EMAIL_SPACE_WITH_EQUALS = ' = ';
    private static final String RICH_TEXT_NEW_LINE = '<br/>';
    private static final String SPACE_SYMBOL = ' ';
    private static LeadBatchResponse batchResponse;

    //wrapper class to handle the lead transfer update response.
    /**
     * @description LeadBatchResponse
     */
    public with sharing class LeadBatchResponse {
        public Integer noOfLeadRecordsQueried = 0;
        public Integer noOfLeadRecordsProcessed = 0;
        public Integer noOfLeadRecordsSuccess = 0;
        public Integer noOfLeadRecordsFailed = 0;
    }

    //method to handle the lead transfer update, lead metrics update and task creation on the batch chunk.
    /**
     * @description processTransferLeadUpdate
     * @name processTransferLeadUpdate
     * @param leadListRequest 
     * @param systemRecordOwnerSfdcId 
     * @return  `LeadBatchResponse`
     */
    public LeadBatchResponse processTransferLeadUpdate(List<Lead> leadListRequest, Id systemRecordOwnerSfdcId) {
        agentProxyMap = new Map<String, String>();
        leadProxyMap = new Map<String, String>();
        batchResponse = new LeadBatchResponse();
        try {
            if (leadListRequest != null && !leadListRequest.isEmpty()) {
                batchResponse.noOfLeadRecordsQueried = leadListRequest.size();
            }
            agentProxyMap = getAgentProxyId(leadListRequest);
            List<lead> updatedLeadList = handleUpdateLead(leadListRequest);
            handleUpdateLeadMetrics();
            handleLeadNotification(updatedLeadList);
        } catch (Exception transferLeadException) {
            LoggingService.logHandledException(transferLeadException, CLASS_NAME, PROCESS_TRANSFER_LEAD_METHOD_NAME, System.LoggingLevel.ERROR);
        }
        batchResponse.noOfLeadRecordsFailed = batchResponse.noOfLeadRecordsProcessed - batchResponse.noOfLeadRecordsSuccess;
        return batchResponse;
    }

    private static Map<String, String> getAgentProxyId(List<Lead> leadListRequest) {
        Set<String> transferAgentAssociateIdSet = new Set<String>();
        Map<String, String> agentProxyMap = new Map<String, String>();
        for (Lead ld : leadListRequest) {
            transferAgentAssociateIdSet.add(ld.AgentAssociateId__c + PROXY_CONCAT);
        }
        for (User agtProxy : [SELECT Id, UserExternalID__c FROM User WHERE UserExternalID__c IN :transferAgentAssociateIdSet WITH SECURITY_ENFORCED]) {
            agentProxyMap.put(agtProxy.UserExternalID__c, agtProxy.Id);
        }
        return agentProxyMap;
    }

    private static List<lead> handleUpdateLead(List<Lead> leadListRequest) {
        List<lead> updateLeadList = new List<Lead>();
        String agentProxySFDCId = '';
        for (Lead ld : leadListRequest) {
            agentProxySFDCId = agentProxyMap.get(ld.AgentAssociateId__c + PROXY_CONCAT);
            if (String.isNotBlank(agentProxySFDCId)) {
                ld.OwnerId = agentProxySFDCId;
                ld.AssignedTo__c = null;                
                updateLeadList.add(ld);
                leadProxyMap.put(ld.Id, ld.OwnerId);
            }
        }
        if (!updateLeadList.isEmpty()) {
            Integer updateLeadResultSize = updateLeadList.size();
            batchResponse.noOfLeadRecordsProcessed = updateLeadResultSize;
            update Security.stripInaccessible(AccessType.UPDATABLE, updateLeadList).getRecords();
            batchResponse.noOfLeadRecordsSuccess = updateLeadResultSize;
        }
        return updateLeadList;
    }

    private static void handleUpdateLeadMetrics() {
        List<LeadMetrics__c> updateLeadMetricsList = new List<LeadMetrics__c>();
        String agentProxySFDCId = '';
        Set<String> leadIds = leadProxyMap.keySet();
        for (LeadMetrics__c ldMetrics : [SELECT Id, AssignedTo__c, OwnerId, LeadSfdcId__c FROM LeadMetrics__c WHERE LeadSfdcId__c IN :leadIds WITH SECURITY_ENFORCED]) {
            agentProxySFDCId = leadProxyMap.get(ldMetrics.LeadSfdcId__c);
            if (String.isNotBlank(agentProxySFDCId)) {
                ldMetrics.OwnerId = agentProxySFDCId;
                ldMetrics.AssignedTo__c = null;
                ldMetrics.LeadTransferredBy__c = UserInfo.getUserId();
                updateLeadMetricsList.add(ldMetrics);
            }
        }
        if (!updateLeadMetricsList.isEmpty()) {
            update Security.stripInaccessible(AccessType.UPDATABLE, updateLeadMetricsList).getRecords();
        }
    }

    private static void handleLeadNotification(List<Lead> leadListRequest) {
        List<Task> createTaskList = new List<Task>();
        for (Lead ld : leadListRequest) {
            Task newtsk = HLPR_CreateLeadService.buildTask(ld);
            createTaskList.add(newtsk);
        }
        if (!createTaskList.isEmpty()) {
            UTIL_TaskDAO.insertTasks(createTaskList);
        }
    }

    //method to handle the batch finish.
    /**
     * @description processBatchFinish
     * @param batchJobId 
     * @param batchResponseList 
     * @param leadUpdateCustomSettingRecord 
     * @name processBatchFinish
     */
    public void processBatchFinish(String batchJobId, List<LeadBatchResponse> batchResponseList, CSLeadBatch__c leadUpdateCustomSettingRecord) {
        try {
            if (String.isNotBlank(leadUpdateCustomSettingRecord.BatchEmailRecipient__c)) {
                finishBatchLeadUpdate(batchJobId, batchResponseList, leadUpdateCustomSettingRecord);
            }
        } catch (Exception finishBatchException) {
            LoggingService.logHandledException(finishBatchException, CLASS_NAME, PROCESS_BATCH_FINISH_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }

    //method to handle send email - subject, to address, title of the email.
    private void finishBatchLeadUpdate(String batchJobId, List<LeadBatchResponse> batchResponseList, CSLeadBatch__c leadUpdateCustomSettingRecord) {
        String emailTitleBody = TRANSFER_LEAD_BATCH_EMAIL_SUBJECT + SPACE_SYMBOL + System.Label.CL_LEAD_JOB_ID + batchJobId;
        String finalEmailBody = '';
        if (batchResponseList != null && !batchResponseList.isEmpty()) {
            finalEmailBody = buildFinalEmailBodyforBatchResponses(batchResponseList, emailTitleBody);
            sendEmail(finalEmailBody, leadUpdateCustomSettingRecord);
        } else {
            finalEmailBody = emailTitleBody + RICH_TEXT_NEW_LINE + RICH_TEXT_NEW_LINE + LEAD_BATCH_NONE;
            sendEmail(finalEmailBody, leadUpdateCustomSettingRecord);
        }
    }

    //method to build the email body of the batch email.
    private String buildFinalEmailBodyforBatchResponses(List<LeadBatchResponse> batchResponseList, String emailTitleBody) {
        String finalEmailBody = '';
        Integer noOfLeadRecordsQueried = 0;
        Integer noOfLeadRecordsProcessed = 0;
        Integer noOfLeadRecordsSuccess = 0;
        Integer noOfLeadRecordsFailed = 0;
        for (LeadBatchResponse response : batchResponseList) {
            noOfLeadRecordsQueried += response.noOfLeadRecordsQueried;
            noOfLeadRecordsProcessed += response.noOfLeadRecordsProcessed;
            noOfLeadRecordsSuccess += response.noOfLeadRecordsSuccess;
            noOfLeadRecordsFailed += response.noOfLeadRecordsFailed;
        }
        String recordStats = LEAD_BATCH_QUERIED + EMAIL_SPACE_WITH_EQUALS + noOfLeadRecordsQueried + RICH_TEXT_NEW_LINE;
        recordStats += TRANSFER_LEAD_BATCH_LEAD_PROCESSED + EMAIL_SPACE_WITH_EQUALS + noOfLeadRecordsProcessed + RICH_TEXT_NEW_LINE;
        recordStats += TRANSFER_LEAD_BATCH_LEAD_SUCCESS + EMAIL_SPACE_WITH_EQUALS + noOfLeadRecordsSuccess + RICH_TEXT_NEW_LINE;
        recordStats += TRANSFER_LEAD_BATCH_LEAD_FAILURE + EMAIL_SPACE_WITH_EQUALS + noOfLeadRecordsFailed + RICH_TEXT_NEW_LINE;
        finalEmailBody = emailTitleBody + RICH_TEXT_NEW_LINE + RICH_TEXT_NEW_LINE + recordStats + RICH_TEXT_NEW_LINE;
        return finalEmailBody;
    }

    //method to send email for the batch recipients.
    private void sendEmail(String body, CSLeadBatch__c leadUpdateCustomSettingRecord) {
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setToAddresses(new List<String>{ leadUpdateCustomSettingRecord.BatchEmailRecipient__c });
        emailMessage.setSenderDisplayName(leadUpdateCustomSettingRecord.SenderDisplayName__c);
        emailMessage.setSubject(TRANSFER_LEAD_BATCH_EMAIL_SUBJECT);
        emailMessage.setHTMLBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ emailMessage });
    }
}